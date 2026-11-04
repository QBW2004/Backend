'use strict';
// 实际2000回合预览与参考引擎逐项一致；精确任务仅替换为探针，检查隔离及消息时序。
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');
const {performance} = require('node:perf_hooks');
const E = require('../TTY.Web/Scripts/app/mjhl.engine.js');
const source = fs.readFileSync(path.join(__dirname, '../TTY.Web/Scripts/app/mjhl.agent.rtp.worker.js'), 'utf8');
const words = [10, 20, 30, 40];
const copy = value => JSON.parse(JSON.stringify(value));
const sample = p => new Promise((resolve, reject) => E.sample(p, 2000, 0,
    {random:E.xoshiro128ss(words),batchSize:200}, (error, stats) => error ? reject(error) : resolve(stats)));
function run(job, overrides={}) {
    return new Promise((resolve,reject) => {
        const messages=[], calls=[], before=JSON.stringify(job), started=performance.now(); let disposed=0;
        const engine=Object.assign({},E,{
            freshSeed128:()=>words.slice(),
            sample(p,count,seed,opts,done) { calls.push({type:'preview',count,seed,random:opts.random}); E.sample(p,count,seed,opts,done); },
            verifyRtp(p,opts,done) { calls.push({type:'verify',profile:p,opts}); done(null,{stats:{total:0.8},precisionReached:false}); },
            calibrateRtp(p,target,opts,done) { calls.push({type:'calibrate',profile:p,target,opts}); done(null,{success:false}); }
        },overrides);
        const scope={MjhlEngine:engine, MjhlRtpPool:{create:()=>({sample:E.sample,dispose:()=>disposed++})},
            importScripts(){},Date,setTimeout,self:{postMessage(message) {
                messages.push({data:copy(message),ms:performance.now()-started});
                if (message.result || message.error) resolve({messages,calls,disposed,unchanged:JSON.stringify(job)===before});
            }}};
        try { vm.runInNewContext(source,scope); scope.self.onmessage({data:job}); } catch(e) {reject(e);}
    });
}
(async()=>{
    const profile=E.defaults(), expected=await sample(profile), timings=[];
    for (const type of ['verify','calibrate']) {
        const r=await run({type,profile,target:80,seed:42,validationSeed128:[1,2,3,4]});
        assert.equal(r.messages.length,2); assert(r.messages[0].data.preview);assert(r.messages[0].ms<3000);
        assert.deepEqual(r.messages[0].data.preview,expected);assert(expected.free>0);
        assert.equal(r.messages[0].data.beforeCalibration,type==='calibrate');assert(!r.messages[0].data.result);
        assert.equal(r.calls[0].count,2000);assert.equal(r.calls[1].type,type);assert.equal(r.calls[1].profile,profile);
        assert.equal(r.calls[1].opts.validationCount,50000000);assert.equal(r.calls[1].opts.tolerancePercent,1);
        assert(r.unchanged);assert.equal(r.disposed,1);timings.push({type,previewMs:r.messages[0].ms});
    }
    const zero=await run({type:'calibrate',profile,target:0});assert.equal(zero.calls.length,1);assert.equal(zero.calls[0].type,'calibrate');assert(!zero.messages[0].data.preview);
    const failed=await run({type:'calibrate',profile,target:80},{sample(p,n,s,o,done){done(new Error('long chain'));}});
    assert(failed.messages[0].data.previewError);assert(failed.messages[1].data.result);assert.equal(failed.calls[0].type,'calibrate');
    const unknown=await run({type:'unknown',profile});assert(unknown.messages[0].data.error);assert.equal(unknown.calls.length,0);
    console.log(JSON.stringify({pass:'完整样本一致、预览/复核隔离、原配置不变、失败继续调校、0%直达',timings}));
})().catch(e=>{console.error(e);process.exitCode=1;});
