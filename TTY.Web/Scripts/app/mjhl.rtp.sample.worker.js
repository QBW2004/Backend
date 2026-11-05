/* 只计算指定固定分片；原生核心与 JavaScript 保持相同开奖、连消、免费和奖金规则。 */
importScripts('mjhl.engine.js?v=mjhl-verify-20261105-v1');
var mjhlNative = null;
try {
    importScripts('mjhl.rtp.native.js?v=mjhl-verify-20261105-v1','mjhl.rtp.wasm.js?v=mjhl-verify-20261105-v1');
    mjhlNative = MjhlRtpNative.create(MjhlEngine,MjhlRtpWasm);
} catch (nativeError) { /* Unsupported browsers retain the full-round JavaScript sampler. */ }
var mjhlSampleBusy = false;
self.onmessage = function (event) {
    var job = event.data || {}, random, lastProgress = 0;
    function done(error, stats) {
        mjhlSampleBusy = false;
        if (error) self.postMessage({ type: 'result', jobId: job.jobId, partId: job.partId, error: error.message, code: error.code || '' });
        else self.postMessage({ type: 'result', jobId: job.jobId, partId: job.partId, stats: stats, draws: random.drawCount() });
    }
    if (job.type !== 'sample' || mjhlSampleBusy) { done(new Error('计算线程收到重叠或未知任务。')); return; }
    mjhlSampleBusy = true;
    try {
        if (mjhlNative) {
            mjhlNative.sample(job.profile,job.count,job.seed128,{component:job.component,onProgress:function(completed){
                var now=Date.now();if(completed<job.count&&now-lastProgress<100)return;lastProgress=now;
                self.postMessage({type:'progress',jobId:job.jobId,partId:job.partId,completed:completed});
            }},function(error,stats){
                if(error){done(error);return;}
                var draws=stats.nativeDraws;delete stats.nativeDraws;random={drawCount:function(){return draws;}};done(null,stats);
            });return;
        }
        if(typeof job.component==='number'){
            var unavailable=new Error('当前浏览器无法使用快速复核。');unavailable.code='MJHL_NATIVE_UNAVAILABLE';done(unavailable);return;
        }
        random = MjhlEngine.xoshiro128ss(job.seed128);
        MjhlEngine.sample(job.profile, job.count, 0, { random: random, batchSize: 10000, onProgress: function (completed) {
            var now = Date.now();
            if (completed < job.count && now - lastProgress < 100) return;
            lastProgress = now;
            self.postMessage({ type: 'progress', jobId: job.jobId, partId: job.partId, completed: completed });
        } }, done);
    } catch (e) { done(e); }
};
self.postMessage({ type: 'ready' });
