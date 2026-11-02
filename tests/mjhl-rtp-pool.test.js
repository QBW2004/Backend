'use strict';
// 实际 worker_threads 跑浏览器 sample worker；固定计划改变并发度，结果/随机消耗必须完全相同。
// 不联网、不写数据库；这里只验证计算分片，不声称百万样本已达到某个 RTP 精度。
const assert = require('node:assert/strict');
const { performance } = require('node:perf_hooks');
const H = require('./helpers/mjhl-rtp-node-worker.js');
const E = require(H.enginePath), Pool = require(H.poolPath);
const copy = x => JSON.parse(JSON.stringify(x));
const plan = Array.from({ length: 4 }, (_, i) => ({ offset: i * 250000, count: 250000,
    seed128: [0x12345678 + i, 0x31415926 + i * 13, 0x27182818 + i * 37, 0x13572468 + i * 101] }));
const profile = E.defaults(), before = JSON.stringify(profile), beforePlan = JSON.stringify(plan);
function invoke(pool, p, count, seed, options) {
    return new Promise((resolve, reject) => {
        pool.sample(p, count, seed, options || {}, (error, stats) => error ? reject(error) : resolve(stats));
    });
}
function canonical(stats) { const c = copy(stats); delete c.parallelWorkers; return c; }
async function using(options, callback) {
    const pool = H.createPool(options);
    try { return await callback(pool); } finally { pool.dispose(); }
}
async function main() {
    let baseline;
    for (const workers of [1, 2, 4]) {
        const result = await using({ maxWorkers: workers }, async pool => {
            let last = 0, progressCalls = 0;
            const started = performance.now();
            const stats = await invoke(pool, profile, 1000000, 999, { parallelPlan: plan, onProgress(n, total) {
                assert(n >= last && n <= total); assert.equal(total, 1000000); last = n; progressCalls++;
            } });
            assert(progressCalls > 0); assert.equal(last, 1000000);
            assert.equal(stats.count, 1000000); assert.equal(stats.parallelWorkers, workers);
            assert.equal(stats.parallelBatches.length, 4);
            assert.equal(stats.parallelDraws, stats.parallelBatches.reduce((sum, x) => sum + x.draws, 0));
            assert(stats.parallelDraws > 54000000); // 每个付费回合包含54格及其补牌/免费/连消。
            assert.equal(stats.distribution.zero + stats.distribution.small + stats.distribution.medium + stats.distribution.big + stats.distribution.mega + stats.distribution.super, 1000000);
            console.log(JSON.stringify({ workers, count: stats.count, ms: performance.now() - started, draws: stats.parallelDraws, total: stats.total, m2: stats.m2 }));
            return stats;
        });
        if (!baseline) baseline = canonical(result); else assert.deepEqual(canonical(result), baseline);
    }
    assert.equal(JSON.stringify(profile), before); assert.equal(JSON.stringify(plan), beforePlan);
    // 不支持嵌套 Worker 时仍按同一固定计划串行，不能切换为不同的单一随机流。
    const fallback = await using({ workerFactory() { throw new Error('nested Worker unavailable'); } },
        pool => invoke(pool, profile, 1000000, 999, { parallelPlan: plan }));
    assert.deepEqual(canonical(fallback), baseline); assert.equal(fallback.parallelWorkers, 1);

    // 固定checkpoint分段调用与一次调用的原始分片完全相同；对统计采用相同合并树才要求逐位相同。
    await using({ maxWorkers: 2 }, async pool => {
        const first = await invoke(pool, profile, 250000, 1, { parallelPlan: plan, sampleOffset: 0 });
        const rest = await invoke(pool, profile, 750000, 1, { parallelPlan: plan, sampleOffset: 250000 });
        assert.deepEqual(first.parallelBatches.concat(rest.parallelBatches), baseline.parallelBatches);
        const merged = E.mergeSampleStats(copy(first), rest);
        assert.equal(merged.count, baseline.count);
        assert(Math.abs(merged.total - baseline.total) < 1e-12);
        assert(Math.abs(merged.m2 - baseline.m2) < baseline.m2 * 1e-12);
        await assert.rejects(invoke(pool, profile, 1000, 1, { parallelPlan: plan, sampleOffset: 1 }), /整数边界/);
        const badPlan = copy(plan); badPlan[1].seed128 = badPlan[0].seed128.slice();
        await assert.rejects(invoke(pool, profile, 1000, 1, { parallelPlan: badPlan }), /不能重复/);
    });

    // 搜索从5万增至30万时延长计划并保留头部；验证计划一次生成到总上限且与搜索隔离。
    const trainRandom = E.mulberry32(42), trainHead = Array.from({ length: 4 }, () => Math.floor(trainRandom() * 4294967296) >>> 0);
    let freshCalls = 0;
    const testEngine = Object.assign({}, E, { freshSeed128() {
        freshCalls++; return freshCalls === 1 ? trainHead.slice() : [11, 22, 33, 10000 + freshCalls];
    } });
    await using({ engine: testEngine, maxWorkers: 2 }, async pool => {
        const short = await invoke(pool, profile, 50000, 42);
        const head = pool.exportPlan(42); assert.equal(head.length, 1);
        const extended = await invoke(pool, profile, 300000, 42);
        const grown = pool.exportPlan(42); assert.equal(grown.length, 2); assert.deepEqual(grown[0], head[0]);
        assert.deepEqual(short.parallelBatches[0].seed128, extended.parallelBatches[0].seed128);
        const opts = { validationSeed128: [91, 92, 93, 94], validationCount: 1000000 };
        await invoke(pool, profile, 1000, 42, opts);
        const verifiedPlan = pool.exportPlan(42, opts);
        assert.equal(verifiedPlan.length, 4); assert.equal(freshCalls, 5); // 首个故意与训练碰撞，应重新生成。
        for (const v of verifiedPlan) for (const t of grown) assert.notDeepEqual(v.seed128, t.seed128);
        const savedPlan = JSON.stringify(verifiedPlan);
        await invoke(pool, profile, 1000, 42, opts);
        assert.equal(freshCalls, 5); assert.equal(JSON.stringify(pool.exportPlan(42, opts)), savedPlan);
    });

    // 取消须终止所有活动线程，只回调一次，不得带出未完成统计。
    await using({ maxWorkers: 4 }, async pool => {
        let cancelled = false, callbacks = 0, lateProgress = 0;
        const result = new Promise(resolve => pool.sample(profile, 5000000, 55, { cancelled: () => cancelled,
            onProgress() { if (cancelled) lateProgress++; } }, (error, stats) => { callbacks++; resolve({ error, stats }); }));
        setTimeout(() => { cancelled = true; }, 100);
        const stopped = await result;
        assert.equal(stopped.error.code, 'MJHL_RTP_CANCELLED'); assert.equal(stopped.stats, undefined);
        await new Promise(resolve => setTimeout(resolve, 100));
        assert.equal(callbacks, 1); assert.equal(lateProgress, 0);
        // 取消后可重用池，避免上次迟到的回包写入新任务。
        const recovered = await invoke(pool, profile, 1000, 55);
        assert.equal(recovered.count, 1000);
    });
    await using({ maxWorkers: 2 }, async pool => {
        const pending = invoke(pool, profile, 5000000, 56);
        setTimeout(() => pool.cancel(), 50);
        await assert.rejects(pending, e => e.code === 'MJHL_RTP_CANCELLED');
    });
    let cancellationChecks = 0, workerCreations = 0;
    await using({ workerFactory(url) { workerCreations++; return new H.BrowserWorker(url); } }, async pool => {
        await assert.rejects(invoke(pool, profile, 1000, 57, { cancelled: () => ++cancellationChecks > 1 }), e => e.code === 'MJHL_RTP_CANCELLED');
        assert.equal(workerCreations, 0, '建立任务后立刻取消时不能再启动迟到线程');
    });

    // 实际引擎遇到不可结束的免费链，必须透传错误，不得回退或伪造少量统计。
    const endless = E.defaults();
    for (const mode of ['n', 'f']) {
        for (let row = 0; row < 11; row++) endless.weights[mode][row] = [0, 0, 0, 0, 0];
        endless.weights[mode][10] = [10000, 10000, 10000, 10000, 10000];
    }
    await using({ maxWorkers: 2 }, async pool => {
        await assert.rejects(invoke(pool, endless, 100, 77), e => e.code === 'MJHL_GENERATION_LIMIT');
    });
    const startupFallback = H.createPool({ workerFactory: () => new H.BrowserWorker(pathMissing()) });
    try {
        const stats = await invoke(startupFallback, profile, 1000, 999, { parallelPlan: plan });
        assert.equal(stats.count, 1000); assert.equal(stats.parallelWorkers, 1);
    } finally { startupFallback.dispose(); }
    console.log('PASS actual 1/2/4 workers and sequential fallback replay exactly; fixed checkpoints, deterministic training extension, independent validation plans, cancellation/reuse and engine errors; no network/DB writes.');
}
function pathMissing() { return require('node:path').join(__dirname, '__missing_mjhl_worker_for_startup_fallback__.js'); }
main().catch(e => { console.error(e); process.exitCode = 1; });
