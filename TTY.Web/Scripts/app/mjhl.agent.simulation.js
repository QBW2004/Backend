/* 普通权重试算：与原 mjhl.engine.js 共用奖金规则，不包含指定玩家赠送/吃分控制。 */
(function (root, factory) {
    if (typeof module === 'object' && module.exports) module.exports = factory(require('./mjhl.engine.js'));
    else root.MjhlAgentSimulation = factory(root.MjhlEngine);
})(this, function (E) {
    'use strict';
    function clone(value) { return JSON.parse(JSON.stringify(value)); }
    function profile(config) {
        if (!config || config.gameId !== 54 || !Number.isFinite(config.targetRtp) || config.targetRtp < 0 || config.targetRtp > 1000) throw new Error('目标 RTP 须为 0～1000%。');
        if (typeof config.scatterEnabled !== 'boolean' || typeof config.freeRetrigger !== 'boolean') throw new Error('至尊开关格式错误。');
        var p = E.defaults();
        p.weights = clone(config.weights); p.goldChance = config.goldChance;
        // 目标只是搜索条件，原引擎该字段不参与开奖；不改旧按桌配置的校验口径。
        p.targetRtp = 90; p.targetScatter = 0; p.weightTotal = 10000;
        var errors = E.validate(p);
        if (errors.length) throw new Error(errors.join('\n'));
        if (!config.scatterEnabled) { p.weights.n[10].fill(0); p.weights.f[10].fill(0); }
        else if (!config.freeRetrigger) p.weights.f[10].fill(0);
        return p;
    }
    function validate(config) {
        profile(config);
        var b = config.bets;
        if (!b || !Number.isInteger(b.scorePerCoin) || b.scorePerCoin < 1 || b.scorePerCoin > 100000) throw new Error('每钻原分须为 1～100000 的整数。');
        function units(v) {
            if (!Number.isFinite(v) || v < 0 || Math.abs(v * 100000 - Math.round(v * 100000)) > 0.00001) throw new Error('筹码最多保留五位钻小数。');
            var raw = v * b.scorePerCoin * 10;
            if (raw < 1 || raw > 42949672950 || Math.abs(raw - Math.round(raw)) > 0.00001) throw new Error('筹码须能精确换算为 0.1 原分，且不超过钱包范围。');
            return Math.round(raw);
        }
        units(b.min); units(b.max); units(b.entry);
        if (b.min < .4 || b.max < b.min) throw new Error('最小筹码至少 0.4 钻，最大不能小于最小。');
        if (!Array.isArray(b.chips) || !b.chips.length || b.chips.length > 200) throw new Error('筹码须有 1～200 档。');
        b.chips.forEach(function (v, i) { units(v); if (v < b.min || v > b.max || (i && v <= b.chips[i - 1])) throw new Error('筹码须在范围内，去重并按从小到大排列。'); });
        if (b.chips.indexOf(b.entry) < 0) throw new Error('默认筹码必须属于筹码列表。');
        return config;
    }
    function sample(config, count, seed, onProgress) {
        return new Promise(function (resolve, reject) { E.sample(profile(config), count, seed, { onProgress: onProgress }, function (error, stats) { if (error) reject(error); else resolve(stats); }); });
    }
    function output(config, stats, seed) {
        return { count: stats.count, seed: seed, rtp: stats.total * 100, normalRtp: stats.normal * 100, freeRtp: stats.free * 100,
            half95: stats.half95 * 100, hitRate: stats.hit * 100, triggerRate: stats.scatter * 100, capRate: stats.cap * 100,
            normalOnly: true, ruleVersion: 'mjhl-source-20261101' };
    }
    function scaled(config, factor) {
        var next = clone(config), defaults = E.defaults().weights;
        ['n', 'f'].forEach(function (m) { for (var c = 0; c < 5; c++) {
            var shares = config.weights[m].slice(0, 9).map(function (r) { return r[c]; });
            var sum = shares.reduce(function (a, b) { return a + b; }, 0);
            if (!sum) { shares = defaults[m].slice(0, 9).map(function (r) { return r[c]; }); sum = shares.reduce(function (a, b) { return a + b; }, 0); }
            var room = 10000 - config.weights[m][9][c] - config.weights[m][10][c];
            var amount = Math.max(0, Math.min(room, Math.round(sum * factor)));
            var exact = shares.map(function (x) { return x * amount / sum; }), values = exact.map(Math.floor);
            var rest = amount - values.reduce(function (a, b) { return a + b; }, 0);
            var order = exact.map(function (x, i) { return { i: i, frac: x - values[i] }; }).sort(function (a, b) { return b.frac - a.frac || a.i - b.i; });
            for (var j = 0; j < rest; j++) values[order[j].i]++;
            for (var s = 0; s < 9; s++) next.weights[m][s][c] = values[s];
        } });
        return next;
    }
    async function run(job, onProgress) {
        var start = Date.now(), config = clone(validate(job.config)), count = job.count, seed = job.seed;
        if (!Number.isInteger(count) || count < 1000 || count > 100000) throw new Error('模拟局数须为 1000～100000。');
        if (!Number.isInteger(seed) || seed < 0 || seed > 4294967295) throw new Error('随机种子格式错误。');
        function progress(value) { if (onProgress) onProgress(value); }
        function measure(c, n, seq, phase) { return sample(c, n, seq, function (done, total) { progress({ phase: phase, completed: done, total: total }); }); }
        if (job.type === 'sample') {
            var stats = await measure(config, count, seed, 'sample');
            return Object.assign(output(config, stats, seed), { type: 'sample', durationMs: Date.now() - start });
        }
        if (job.type !== 'calibrate') throw new Error('未知计算类型。');
        var trainCount = Math.max(10000, Math.min(20000, count)), verifySeed = (seed ^ 0x9e3779b9) >>> 0;
        var best = null, attempts = 0, rejected = 0, seen = {};
        async function evaluate(candidate, factor) {
            var key = JSON.stringify(profile(candidate));
            if (Object.prototype.hasOwnProperty.call(seen, key)) return seen[key];
            try {
                var stats = await measure(candidate, trainCount, seed, 'training');
                var point = { config: candidate, factor: factor, stats: stats, error: Math.abs(stats.total * 100 - config.targetRtp) };
                attempts++; seen[key] = point;
                if (!best || point.error < best.error) best = point;
                progress({ phase: 'search', completed: attempts, total: 0, deviation: best.error, rejected: rejected });
                return point;
            } catch (error) { if (error.code !== 'MJHL_GENERATION_LIMIT') throw error; rejected++; seen[key] = null; return null; }
        }
        if (config.targetRtp === 0) {
            var zero = clone(config);
            ['n', 'f'].forEach(function (m) { zero.weights[m] = Array.from({ length: 11 }, function () { return [0,0,0,0,0]; }); for (var c = 0; c < 5; c++) zero.weights[m][c % 2][c] = 10000; });
            await evaluate(zero, 0);
        } else {
            await evaluate(clone(config), 1);
            var points = [], factors = [0,.25,.5,.75,1,1.25,1.5,2,3,4,8];
            for (var i = 0; i < factors.length; i++) { var p = await evaluate(scaled(config, factors[i]), factors[i]); if (p) points.push(p); }
            var brackets = [];
            for (var k = 0; k + 1 < points.length; k++) if ((points[k].stats.total * 100 - config.targetRtp) * (points[k+1].stats.total * 100 - config.targetRtp) <= 0) brackets.push([points[k], points[k+1]]);
            brackets.sort(function (a, b) { return Math.min(a[0].error, a[1].error) - Math.min(b[0].error, b[1].error); });
            for (var z = 0; z < Math.min(2, brackets.length); z++) {
                var left = brackets[z][0], right = brackets[z][1];
                for (var step = 0; step < 7; step++) {
                    var mid = (left.factor + right.factor) / 2, q = await evaluate(scaled(config, mid), mid);
                    if (!q) break;
                    if ((left.stats.total * 100 - config.targetRtp) * (q.stats.total * 100 - config.targetRtp) <= 0) right = q; else left = q;
                }
            }
        }
        if (!best) throw new Error('没有可完整结束的候选权重，请降低至尊权重后重试。');
        var verified = await measure(best.config, count, verifySeed, 'validation');
        return Object.assign(output(best.config, verified, verifySeed), { type: 'calibrate', config: best.config, targetRtp: config.targetRtp,
            deviation: Math.abs(verified.total * 100 - config.targetRtp), withinTolerance: Math.abs(verified.total * 100 - config.targetRtp) <= 3,
            trainingSeed: seed, trainingCount: trainCount, trainingRtp: best.stats.total * 100, attempts: attempts, rejected: rejected,
            zeroReallocated: config.targetRtp === 0, durationMs: Date.now() - start });
    }
    return { profile: profile, validate: validate, run: run };
});
