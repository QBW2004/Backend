/* 固定分片的 RTP 计算池。分片顺序、种子与统计合并顺序固定，线程数只影响速度。
 * 每个样本仍是同一引擎完整的付费局与全部免费链；不得按哪个线程先结束选择样本。 */
(function (root, factory) {
    var api = factory(root);
    if (typeof module === 'object' && module.exports) module.exports = api;
    else root.MjhlRtpPool = api;
})(typeof self !== 'undefined' ? self : this, function (root) {
    'use strict';
    var PART = 250000, RNG_NAME = 'xoshiro128** 1.1 / fixed-250000-round streams';
    function copy(x) { return JSON.parse(JSON.stringify(x)); }
    function error(message, code) { var e = new Error(message); e.code = code || 'MJHL_RTP_POOL'; return e; }
    function integer(n) { return typeof n === 'number' && isFinite(n) && Math.floor(n) === n; }
    function seedKey(words) {
        if (!words || words.length !== 4) throw error('并行计算的种子必须是4个32位整数。');
        var any = 0;
        for (var i = 0; i < 4; i++) {
            if (!integer(words[i]) || words[i] < 0 || words[i] > 4294967295) throw error('并行计算的种子无效。');
            any |= words[i];
        }
        if (!any) throw error('并行计算的种子不能全零。');
        return words.join(',');
    }
    function create(options) {
        options = options || {};
        var engine = options.engine || root.MjhlEngine;
        if (!engine) throw error('未加载麻将胡了计算引擎。');
        var hardware = Number(options.hardwareConcurrency || (root.navigator && root.navigator.hardwareConcurrency)) || 2;
        var workerCount = Math.max(1, Math.min(4, Math.floor(Number(options.maxWorkers || options.workers) || 4), Math.floor(hardware)));
        var workerUrl = options.workerUrl || 'mjhl.rtp.sample.worker.js';
        var factory = options.workerFactory || (typeof root.Worker === 'function' ? function (url) { return new root.Worker(url); } : null);
        var slots = [], training = {}, validations = {}, seedRegistry = {}, active = null, serialOnly = !factory, disposed = false, jobNumber = 0;

        function terminateWorkers() {
            for (var i = 0; i < slots.length; i++) {
                clearTimeout(slots[i].timer);
                slots[i].worker.onmessage = null; slots[i].worker.onerror = null;
                try { slots[i].worker.terminate(); } catch (ignored) {}
            }
            slots = [];
        }
        function cancellation() { return error('已取消计算，参数未修改。', 'MJHL_RTP_CANCELLED'); }
        function finish(job, e, stats) {
            if (active !== job || job.finished) return;
            job.finished = true; clearTimeout(job.cancelTimer); active = null;
            if (e) terminateWorkers();
            job.done(e, stats);
        }
        function stopRequested(job) {
            if (active !== job || job.finished) return true;
            if (job.opts.cancelled && job.opts.cancelled()) { finish(job, cancellation()); return true; }
            return false;
        }
        function watchCancel(job) {
            if (stopRequested(job)) return;
            job.cancelTimer = setTimeout(function () { watchCancel(job); }, 25);
        }
        function freshWords() {
            // 验证种子与本池已使用的训练/验证种子分开；整个计划在开奖前生成并固定。
            for (var tries = 0; tries < 100; tries++) {
                var words = engine.freshSeed128(), key = seedKey(words);
                if (!seedRegistry[key]) { seedRegistry[key] = true; return words.slice(0); }
            }
            throw error('无法生成互不重复的验证种子，请重新计算。');
        }
        function planFor(seed, opts, requestedEnd) {
            var plan, i, words, key;
            if (opts.parallelPlan) {
                plan = copy(opts.parallelPlan);
                var used = {};
                for (i = 0; i < plan.length; i++) {
                    var item = plan[i];
                    if (!item || item.offset !== i * PART || !integer(item.count) || item.count < 1 || item.count > PART) throw error('重放计划的分片范围无效。');
                    key = seedKey(item.seed128);
                    if (used[key]) throw error('重放计划的分片种子不能重复。');
                    used[key] = true;
                }
                if (!plan.length || plan[plan.length - 1].offset + plan[plan.length - 1].count < requestedEnd) throw error('重放计划没有覆盖本次样本。');
                return plan;
            }
            if (opts.validationSeed128) {
                var maximum = Number(opts.validationCount);
                if (!integer(maximum) || maximum < requestedEnd || maximum > 50000000) throw error('验证计划的总样本数无效。');
                key = seedKey(opts.validationSeed128) + '|' + maximum;
                if (!validations[key]) {
                    plan = [];
                    for (i = 0; i < maximum; i += PART) plan.push({ seed128: freshWords(), offset: i, count: Math.min(PART, maximum - i) });
                    validations[key] = plan;
                }
                return validations[key];
            }
            // 搜索使用同一 seed 的共同随机数，增加样本只延长计划，不改先前分片。
            // 独立验证始终走上方 freshSeed128 计划，不能沿用搜索的随机流。
            key = String(Number(seed) >>> 0);
            if (!training[key]) training[key] = { random: engine.mulberry32(Number(seed) >>> 0), parts: [] };
            var train = training[key];
            while (train.parts.length * PART < requestedEnd) {
                words = [];
                for (i = 0; i < 4; i++) words.push(Math.floor(train.random() * 4294967296) >>> 0);
                if (!(words[0] | words[1] | words[2] | words[3])) words[3] = 1;
                seedRegistry[seedKey(words)] = true;
                train.parts.push({ seed128: words, offset: train.parts.length * PART, count: PART });
            }
            return train.parts;
        }
        function progress(job, index, count) {
            if (stopRequested(job)) return;
            job.progress[index] = count;
            if (job.opts.onProgress) {
                var total = 0;
                for (var i = 0; i < job.progress.length; i++) total += job.progress[i] || 0;
                job.opts.onProgress(total, job.count);
            }
        }
        function accept(job, index, stats, draws) {
            if (stopRequested(job)) return;
            var task = job.tasks[index];
            if (!stats || stats.count !== task.count || !integer(draws) || draws < 0 || job.results[index]) {
                finish(job, error('计算分片返回的数据不完整或重复。')); return;
            }
            job.results[index] = { stats: stats, draws: draws }; job.completed++;
            progress(job, index, task.count);
            if (job.completed !== job.tasks.length) return;
            var merged = null, batches = [], totalDraws = 0;
            // 按逻辑片号合并，浮点加法次序也不受线程完成先后影响。
            for (var i = 0; i < job.tasks.length; i++) {
                var result = job.results[i], t = job.tasks[i];
                merged = engine.mergeSampleStats(merged, result.stats); totalDraws += result.draws;
                batches.push({ seed128: t.seed128.slice(0), offset: t.offset, count: t.count, draws: result.draws });
            }
            merged.half95 = merged.count > 1 ? 1.96 * Math.sqrt(merged.m2 / (merged.count - 1) / merged.count) : 0;
            merged.parallelBatches = batches; merged.parallelDraws = totalDraws; merged.parallelRng = RNG_NAME;
            merged.parallelWorkers = job.workerCount;
            finish(job, null, merged);
        }
        function runSerial(job) {
            if (stopRequested(job)) return;
            if (job.next >= job.tasks.length) return;
            var index = job.next++, task = job.tasks[index], random;
            try { random = engine.xoshiro128ss(task.seed128); }
            catch (e) { finish(job, e); return; }
            try {
                engine.sample(job.profile, task.count, 0, {
                    random: random, batchSize: 10000,
                    cancelled: function () { return active !== job || !!(job.opts.cancelled && job.opts.cancelled()); },
                    onProgress: function (n) { progress(job, index, n); }
                }, function (e, stats) {
                    if (active !== job || job.finished) return;
                    if (e) { finish(job, e); return; }
                    accept(job, index, stats, random.drawCount());
                    if (active === job) setTimeout(function () { runSerial(job); }, 0);
                });
            } catch (e) { finish(job, e); }
        }
        function fallback(job) {
            if (active !== job || job.finished) return;
            // 只在子线程尚未启动成功时降级。重跑同一整份计划，不能保留先完成片段造成偏差。
            terminateWorkers(); serialOnly = true;
            job.next = 0; job.completed = 0; job.results = []; job.progress = []; job.workerCount = 1;
            runSerial(job);
        }
        function dispatch(slot) {
            var job = active;
            if (!job || !slot.ready || slot.busy || stopRequested(job) || job.next >= job.tasks.length) return;
            var index = job.next++, task = job.tasks[index]; slot.busy = { job: job.id, index: index };
            try { slot.worker.postMessage({ type: 'sample', jobId: job.id, partId: index, profile: job.profile, count: task.count, seed128: task.seed128, offset: task.offset }); }
            catch (e) { finish(job, e); }
        }
        function startWorkers(job) {
            try {
                while (slots.length < workerCount) {
                    (function () {
                        var worker = factory(workerUrl), slot = { worker: worker, ready: false, busy: null, timer: null };
                        slots.push(slot);
                        worker.onmessage = function (event) {
                            var data = event.data || {}, current = active;
                            if (data.type === 'ready') { slot.ready = true; clearTimeout(slot.timer); dispatch(slot); return; }
                            if (!current || !slot.busy || data.jobId !== current.id || data.partId !== slot.busy.index) return;
                            var index = slot.busy.index;
                            if (data.type === 'progress') { progress(current, index, Math.min(current.tasks[index].count, Math.max(0, data.completed || 0))); return; }
                            slot.busy = null;
                            if (data.error) { finish(current, error(data.error, data.code || 'MJHL_RTP_SAMPLE')); return; }
                            if (data.type !== 'result') { finish(current, error('计算线程返回了未知消息。')); return; }
                            accept(current, index, data.stats, data.draws); dispatch(slot);
                        };
                        worker.onerror = function (event) {
                            if (event.preventDefault) event.preventDefault();
                            if (!active) { terminateWorkers(); return; }
                            if (!slot.ready) fallback(active);
                            else finish(active, error(event.message || '计算线程异常。', 'MJHL_RTP_WORKER'));
                        };
                        slot.timer = setTimeout(function () { if (!slot.ready && active) fallback(active); }, 10000);
                    })();
                }
                for (var i = 0; i < slots.length; i++) dispatch(slots[i]);
            } catch (e) { fallback(job); }
        }
        function sample(profile, count, seed, opts, onDone) {
            opts = opts || {};
            if (disposed) { onDone(error('计算池已关闭。')); return; }
            if (active) { onDone(error('已有计算任务正在进行。', 'MJHL_RTP_POOL_BUSY')); return; }
            var offset = opts.sampleOffset === undefined ? 0 : Number(opts.sampleOffset), plan, tasks = [];
            try {
                if (!integer(count) || count < 1 || count > 50000000 || !integer(offset) || offset < 0 || offset % PART !== 0) throw error('计算分片必须从25万回合的整数边界开始。');
                if (opts.cancelled && opts.cancelled()) { onDone(cancellation()); return; }
                var invalid = engine.validate(profile);
                if (invalid.length) throw error(invalid.join('\n'), 'MJHL_RTP_PROFILE');
                plan = planFor(seed, opts, offset + count);
                for (var at = offset; at < offset + count; at += PART) {
                    var item = plan[at / PART], amount = Math.min(PART, offset + count - at);
                    if (!item || item.count < amount) throw error('重放计划的分片长度不足。');
                    tasks.push({ seed128: item.seed128.slice(0), offset: at, count: amount });
                }
            } catch (e) { onDone(e); return; }
            var job = { id: ++jobNumber, profile: copy(profile), count: count, opts: opts, done: onDone, tasks: tasks,
                next: 0, completed: 0, results: [], progress: [], finished: false, workerCount: serialOnly ? 1 : Math.min(workerCount, tasks.length) };
            active = job; watchCancel(job);
            if (active !== job) return;
            if (serialOnly) runSerial(job); else startWorkers(job);
        }
        function cancel() { if (active) finish(active, cancellation()); else terminateWorkers(); }
        function dispose() { disposed = true; cancel(); terminateWorkers(); }
        // 返回已生成计划用于审计/重放；显式计划也可直接来自结果的 parallelBatches。
        function exportPlan(seed, opts) {
            opts = opts || {};
            var key = opts.validationSeed128 ? seedKey(opts.validationSeed128) + '|' + opts.validationCount : String(Number(seed) >>> 0);
            var plan = opts.validationSeed128 ? validations[key] : training[key] && training[key].parts;
            return plan ? copy(plan) : [];
        }
        return { sample: sample, cancel: cancel, dispose: dispose, exportPlan: exportPlan };
    }
    return { create: create, PART: PART, RNG_NAME: RNG_NAME };
});
