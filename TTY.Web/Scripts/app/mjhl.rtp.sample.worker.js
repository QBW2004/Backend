/* 只计算指定固定分片；开奖、连消、免费和奖金全部调用同一引擎。 */
importScripts('mjhl.engine.js?v=mjhl-agent-20261102-v10');
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
