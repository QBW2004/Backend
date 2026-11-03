/* Node worker_threads 版麻将 RTP 采样线程，与 mjhl.rtp.sample.worker.js 同一协议。 */
'use strict';
const { parentPort } = require('worker_threads');
const path = require('path');
const ENGINE = path.resolve(__dirname, '..', '..', '..', 'TTY.Web', 'Scripts', 'app', 'mjhl.engine.js');
const MjhlEngine = require(ENGINE);
parentPort.on('message', function (job) {
    var random, lastProgress = 0;
    function done(error, stats) {
        if (error) parentPort.postMessage({ type: 'result', jobId: job.jobId, partId: job.partId, error: error.message, code: error.code || '' });
        else parentPort.postMessage({ type: 'result', jobId: job.jobId, partId: job.partId, stats: stats, draws: random.drawCount() });
    }
    if (job.type !== 'sample') { done(new Error('计算线程收到未知任务。')); return; }
    try {
        random = MjhlEngine.xoshiro128ss(job.seed128);
        MjhlEngine.sample(job.profile, job.count, 0, { random: random, batchSize: 10000, onProgress: function (completed) {
            var now = Date.now();
            if (completed < job.count && now - lastProgress < 200) return;
            lastProgress = now;
            parentPort.postMessage({ type: 'progress', jobId: job.jobId, partId: job.partId, completed: completed });
        } }, done);
    } catch (e) { done(e); }
});
parentPort.postMessage({ type: 'ready' });
