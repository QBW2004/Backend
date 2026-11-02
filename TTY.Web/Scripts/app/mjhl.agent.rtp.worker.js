/* 在独立线程完整计算付费局及其免费链，避免长链试算阻塞后台操作。 */
importScripts('mjhl.engine.js?v=mjhl-agent-20261102-v10', 'mjhl.rtp.pool.js?v=mjhl-agent-20261102-v10');
self.onmessage = function (event) {
    var job = event.data;
    var progressAt = 0;
    // 只加速后台试算；游戏服务端开奖不依赖此工作池。
    var pool = MjhlRtpPool.create({ engine:MjhlEngine,
        workerUrl:'mjhl.rtp.sample.worker.js?v=mjhl-agent-20261102-v10',
        maxWorkers:Math.max(1, Math.min(4, (self.navigator && self.navigator.hardwareConcurrency) || 2)) });
    function progress(value) {
        var now = Date.now();
        if (value.total && value.completed < value.total && now - progressAt < 100) return;
        progressAt = now;
        self.postMessage({ progress:value });
    }
    function done(error, result) {
        pool.dispose();
        if (error) self.postMessage({ error: error.message, code: error.code || '', diagnostic: result || null });
        else self.postMessage({ result: result });
    }
    try {
        if (job.type === 'sample') {
            MjhlEngine.sample(job.profile, 100000, 20261102, {
                onProgress: function (done, total) { progress({ completed:done, total:total }); }
            }, done);
        } else if (job.type === 'verify') {
            MjhlEngine.verifyRtp(job.profile, {
                validationCount:50000000, tolerancePercent:1, quickCheckpoints:true, sampleRunner:pool.sample,
                onValidationProgress:function (done, total) { progress({ phase:'verify', completed:done, total:total }); },
                onCheckpoint:function (stats) { progress({ phase:'verify', actual:stats.total, count:stats.count }); }
            }, done);
        } else if (job.type === 'calibrate') {
            MjhlEngine.calibrateRtp(job.profile, job.target, {
                searchCount: 50000, refineCount: 1000000, validationCount: 50000000, tolerancePercent:1, preferSmallWins:true,
                quickCheckpoints:true, sampleRunner:pool.sample,
                iterations: 8, maxCorrections:1, maxTotalSamples:151000000, seed:job.seed === undefined ? MjhlEngine.freshSeed() : job.seed,
                validationSeed128:job.validationSeed128 || MjhlEngine.freshSeed128(), reservedScatter:job.reservedScatter,
                onProgress: function (best, factor, stats, phase) {
                    progress({ phase:phase, actual:stats ? stats.total : null, count:stats ? stats.count : 0 });
                },
                onMeasureProgress:function (phase,done,total) {
                    progress({ phase:phase, completed:done, total:total });
                },
                onValidationProgress: function (done, total, round) {
                    progress({ phase:'verify', completed:done, total:total, verificationRound:round });
                }
            }, done);
        } else done(new Error('未知试算操作。'));
    } catch (error) { done(error); }
};
