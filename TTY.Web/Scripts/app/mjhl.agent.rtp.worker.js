/* 在独立线程完整计算付费局及其免费链，避免长链试算阻塞后台操作。 */
importScripts('mjhl.engine.js?v=mjhl-verify-20261105-v1', 'mjhl.rtp.pool.js?v=mjhl-verify-20261105-v1');
var mjhlFast = null;
try {
    importScripts('mjhl.rtp.native.js?v=mjhl-verify-20261105-v1','mjhl.rtp.wasm.js?v=mjhl-verify-20261105-v1','mjhl.rtp.verify.js?v=mjhl-verify-20261105-v1');
    mjhlFast=MjhlRtpNative.create(MjhlEngine,MjhlRtpWasm);
} catch (nativeError) { /* The existing verifier remains available without WebAssembly. */ }
self.onmessage = function (event) {
    var job = event.data;
    var progressAt = 0;
    // 只加速后台试算；游戏服务端开奖不依赖此工作池。
    var pool = MjhlRtpPool.create({ engine:MjhlEngine,
        workerUrl:'mjhl.rtp.sample.worker.js?v=mjhl-verify-20261105-v1',nativeSampler:mjhlFast,
        maxWorkers:Math.max(1, Math.min(8, Math.ceil(((self.navigator && self.navigator.hardwareConcurrency) || 2)/2))) });
    function verify(profile,opts,done){
        if(!mjhlFast){MjhlEngine.verifyRtp(profile,opts,done);return;}
        MjhlRtpVerify.verify(MjhlEngine,profile,opts,function(error,result){
            if(error&&error.code==='MJHL_NATIVE_UNAVAILABLE'){MjhlEngine.verifyRtp(profile,opts,done);return;}
            done(error,result);
        });
    }
    function progress(value) {
        var now = Date.now();
        if (value.total && value.completed < value.total && now - progressAt < 100) return;
        progressAt = now;
        self.postMessage({ progress:value });
    }
    function done(error, result) {
        pool.dispose();
        function publish(error) {
            if (error) self.postMessage({ error: error.message, code: error.code || '', diagnostic: result || null });
            else self.postMessage({ result: result });
        }
        // RTP uses variance reduction; the displayed payout histogram remains an independent
        // complete-paid-round sample, with its own explicitly recorded denominator.
        if(!error&&mjhlFast&&result&&result.stats&&result.stats.method&&
            (job.type==='verify'||(job.type==='calibrate'&&result.success))){
            mjhlFast.sample(job.type==='calibrate'?result.profile:job.profile,2000,MjhlEngine.freshSeed128(),{},function(e,stats){
                if(!e){result.stats.distribution=stats.distribution;result.stats.distributionCount=stats.count;}
                publish(e);
            });return;
        }
        publish(error);
    }
    function runFullCalculation() {
        try {
            if (job.type === 'sample') {
                MjhlEngine.sample(job.profile, 100000, 20261102, {
                    onProgress: function (done, total) { progress({ completed:done, total:total }); }
                }, done);
            } else if (job.type === 'verify') {
                verify(job.profile, {
                    validationCount:50000000, tolerancePercent:1, quickCheckpoints:true, sampleRunner:pool.sample,
                    onValidationProgress:function (done, total) { progress({ phase:'verify', completed:done, total:total }); },
                    onCheckpoint:function (stats) { progress({ phase:'verify', actual:stats.total, count:stats.count, estimate:stats }); }
                }, done);
            } else if (job.type === 'calibrate') {
                MjhlEngine.calibrateRtp(job.profile, job.target, {
                    verifier:verify,
                    searchCount: 50000, refineCount: 1000000, validationCount: 50000000, tolerancePercent:1, preferSmallWins:true,
                    quickCheckpoints:true, sampleRunner:pool.sample,
                    iterations: 8, maxCorrections:1, maxTotalSamples:151000000, seed:job.seed === undefined ? MjhlEngine.freshSeed() : job.seed,
                    validationSeed128:job.validationSeed128 || MjhlEngine.freshSeed128(), reservedScatter:job.reservedScatter,
                    onProgress: function (best, factor, stats, phase) {
                        progress({ phase:phase, actual:stats ? stats.total : null, count:stats ? stats.count : 0, estimate:stats });
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
    }
    // 固定小样本只供快速展示，不进入候选搜索、独立复核或可保存结果。
    // 仍结算完整付费回合及全部免费链；独立随机流避免改变正式计算的样本。
    try {
        if ((job.type !== 'verify' && job.type !== 'calibrate') ||
            (job.type === 'calibrate' && Number(job.target) === 0) || MjhlEngine.proveZeroReturn(job.profile)) {
            runFullCalculation(); return;
        }
        MjhlEngine.sample(job.profile, 2000, 0, {
            random:MjhlEngine.xoshiro128ss(MjhlEngine.freshSeed128()), batchSize:200
        }, function (error, stats) {
            // 初始配置的长链可能超限，不能因此阻断原本可调整成功的校准。
            if (error) self.postMessage({ previewError:error.message });
            else self.postMessage({ preview:stats, beforeCalibration:job.type === 'calibrate' });
            setTimeout(runFullCalculation, 0);
        });
    } catch (error) { done(error); }
};
