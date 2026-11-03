/* 麻将胡了代理线配置 RTP 调校（本地复刻后台 worker 链路）。
 * 用法: node run-calibrate.js [--verify-only <weights-json>] [--workers N]
 * 成功时把可保存的代理线 configJson + 校验摘要写到 out/ 目录。 */
'use strict';
const path = require('path');
const fs = require('fs');
const crypto = require('crypto');
const { Worker } = require('worker_threads');
const APP = path.resolve(__dirname, '..', '..', '..', 'TTY.Web', 'Scripts', 'app');
const E = require(path.join(APP, 'mjhl.engine.js'));
const Pool = require(path.join(APP, 'mjhl.rtp.pool.js'));
const WORKER_JS = path.resolve(__dirname, 'mjhl-rtp-node-worker.js');

const args = process.argv.slice(2);
function argOf(name, dflt) { var i = args.indexOf(name); return i >= 0 && i + 1 < args.length ? args[i + 1] : dflt; }
const WORKERS = Math.max(1, Math.min(15, parseInt(argOf('--workers', '14'), 10) || 14));
const TARGET = Number(argOf('--target', '80'));
const VERIFY_ONLY = argOf('--verify-only', null);

function workerFactory() {
    var w = new Worker(WORKER_JS);
    var impl = { worker: w, _onm: null, _one: null };
    impl.postMessage = function (m) { w.postMessage(m); };
    impl.terminate = function () { try { w.terminate(); } catch (e) {} };
    Object.defineProperty(impl, 'onmessage', {
        set: function (fn) { impl._onm = fn; w.removeAllListeners('message'); if (fn) w.on('message', function (d) { fn({ data: d }); }); },
        get: function () { return impl._onm; }
    });
    Object.defineProperty(impl, 'onerror', {
        set: function (fn) { impl._one = fn; w.removeAllListeners('error'); if (fn) w.on('error', function (e) { fn({ message: e && e.message || 'worker error', preventDefault: function () {} }); }); },
        get: function () { return impl._one; }
    });
    return impl;
}

// C# MjhlAgentConfig.Default() + 运营指定押注参数
function agentConfig(weights) {
    return {
        gameId: 54, targetRtp: TARGET, goldChance: 8, scatterEnabled: true, freeRetrigger: true,
        weights: weights,
        bets: { min: 0.4, max: 60, chips: [0.4, 0.8, 1.2, 1.6, 2, 4, 6, 10, 15, 20, 30, 40, 60], entry: 6, scorePerCoin: 1 }
    };
}
function defaultWeights() {
    var d = E.defaults();
    return { n: d.weights.n, f: d.weights.f };
}
// 与 MjhlAgentSimulation.profile 同构（scatterEnabled/freeRetrigger 均为 true）
function engineProfile(config) {
    return { version: 1, weightTotal: 10000, enabled: [true, true, true, true, true, true, true, true, true, true, true],
        weights: JSON.parse(JSON.stringify(config.weights)), goldChance: config.goldChance,
        retrigger: true, retriggerAward: 0, retriggerLimit: 0, freeLimit: 0,
        targetRtp: config.targetRtp, targetScatter: 0, spinCount: 100000, calibrationSamples: 1000 };
}
// C# JsonConvert 序列化口径：整型原样、decimal 无小数位时补 .0、字段按声明序
function csDec(v) {
    var s = String(v);
    return /^-?\d+$/.test(s) ? s + '.0' : s;
}
function csJson(cfg) {
    function mat(m) { return '[' + m.map(function (r) { return '[' + r.join(',') + ']'; }).join(',') + ']'; }
    return '{"gameId":' + cfg.gameId +
        ',"targetRtp":' + csDec(cfg.targetRtp) +
        ',"goldChance":' + csDec(cfg.goldChance) +
        ',"scatterEnabled":' + cfg.scatterEnabled +
        ',"freeRetrigger":' + cfg.freeRetrigger +
        ',"weights":{"n":' + mat(cfg.weights.n) + ',"f":' + mat(cfg.weights.f) + '}' +
        ',"bets":{"min":' + csDec(cfg.bets.min) +
        ',"max":' + csDec(cfg.bets.max) +
        ',"chips":[' + cfg.bets.chips.map(csDec).join(',') + ']' +
        ',"entry":' + csDec(cfg.bets.entry) +
        ',"scorePerCoin":' + cfg.bets.scorePerCoin + '}}';
}

var t0 = Date.now();
function log() { var a = Array.prototype.slice.call(arguments); a.unshift('[' + ((Date.now() - t0) / 1000).toFixed(1) + 's]'); console.log.apply(console, a); }

var pool = Pool.create({ engine: E, maxWorkers: WORKERS, workerFactory: workerFactory });

var config = agentConfig(VERIFY_ONLY ? JSON.parse(fs.readFileSync(VERIFY_ONLY, 'utf8')) : defaultWeights());
var profile = engineProfile(config);
var verr = E.validate(profile);
if (verr.length) { console.error('profile 校验失败: ' + verr.join('\n')); process.exit(2); }
log('引擎档案就绪，workers=' + WORKERS + ' 目标RTP=' + TARGET + (VERIFY_ONLY ? '（仅复核）' : ''));

var lastPhase = '';
function progress(best, factor, stats, phase) {
    var s = phase + (factor != null ? ' factor=' + Number(factor).toFixed(6) : '') +
        (stats && isFinite(stats.total) ? ' actual=' + (stats.total * 100).toFixed(2) + '%' : '') +
        (stats ? ' count=' + stats.count : '');
    if (phase !== lastPhase || stats) { log(s); lastPhase = phase; }
}
var opts = {
    searchCount: 50000, refineCount: 1000000, validationCount: 50000000, tolerancePercent: 1,
    preferSmallWins: true, quickCheckpoints: true, sampleRunner: pool.sample,
    iterations: 8, maxCorrections: 1, maxTotalSamples: 151000000,
    reservedScatter: { n: [0, 0, 0, 0, 0], f: [0, 0, 0, 0, 0] },
    onProgress: progress,
    onMeasureProgress: function (phase, done, total) { if (done === total) log(phase + ' ' + done + '/' + total); },
    onValidationProgress: function (done, total, round) {
        var pct = Math.floor(done / total * 100);
        if (pct % 10 === 0 && pct !== progress._lastPct) { progress._lastPct = pct; log('verify round' + round + ' ' + done + '/' + total + ' (' + pct + '%)'); }
    }
};
if (VERIFY_ONLY) { opts.validationOnly = true; opts.candidateFactor = 1; }

E.calibrateRtp(profile, TARGET, opts, function (err, result) {
    pool.dispose();
    if (err) { console.error('调校失败: ' + err.message + (err.code ? ' [' + err.code + ']' : '')); if (result) console.error(JSON.stringify({ actual: result.actual, samples: result.samples, factor: result.factor })); process.exit(1); }
    log('调校成功 factor=' + result.factor + ' actual=' + (result.actual * 100).toFixed(4) + '% samples=' + result.samples +
        ' half95=' + (result.stats.half95 * 100).toFixed(4) + 'pp');
    var outDir = path.resolve(__dirname, 'out');
    if (!fs.existsSync(outDir)) fs.mkdirSync(outDir);
    var cfg = agentConfig({ n: result.profile.weights.n, f: result.profile.weights.f });
    var json = csJson(cfg);
    var hash = crypto.createHash('sha256').update(json, 'utf8').digest('hex');
    var simResult = { total: result.stats.total, half95: result.stats.half95, count: result.stats.count,
        distribution: result.stats.distribution, precisionReached: true, intervalReliable: result.stats.intervalReliable !== false,
        unobservedReturn: !!result.stats.unobservedReturn, exact: !!result.exact, normalOnly: true };
    fs.writeFileSync(path.join(outDir, 'config.json'), json);
    fs.writeFileSync(path.join(outDir, 'weights.json'), JSON.stringify(cfg.weights));
    fs.writeFileSync(path.join(outDir, 'report.json'), JSON.stringify({
        configJson: json, configHash: hash,
        rtp: result.actual * 100, half95pp: result.stats.half95 * 100, samples: result.stats.count,
        factor: result.factor, targetMiss: result.targetMiss, stoppedEarly: result.stoppedEarly,
        validationAttempts: result.validationAttempts.length,
        simulated: '正常权重试算，不含赠送/吃分控制；' + JSON.stringify(simResult)
    }, null, 2));
    log('已写出 out/config.json out/report.json hash=' + hash.slice(0, 16) + '…');
    process.exit(0);
});
