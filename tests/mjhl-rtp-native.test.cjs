'use strict';
const assert=require('node:assert/strict'),fs=require('node:fs'),path=require('node:path');
const E=require('../TTY.Web/Scripts/app/mjhl.engine.js'),N=require('../TTY.Web/Scripts/app/mjhl.rtp.native.js'),V=require('../TTY.Web/Scripts/app/mjhl.rtp.verify.js');
const encoded=require('../TTY.Web/Scripts/app/mjhl.rtp.wasm.js'),native=N.create(E,encoded),words=[0x12345678,0x31415926,0x27182818,0x13572468];
const sample=(p,n,component)=>new Promise((resolve,reject)=>native.sample(p,n,words,{component},(e,s)=>e?reject(e):resolve(s)));
function reference(p,n){const random=E.xoshiro128ss(words);return new Promise((resolve,reject)=>E.sample(p,n,0,{random,batchSize:10000},(e,s)=>e?reject(e):resolve(Object.assign(s,{nativeDraws:random.drawCount()}))));}
(async()=>{
    assert.equal(WebAssembly.Module.imports(new WebAssembly.Module(Buffer.from(encoded,'base64'))).length,0);
    const profiles=[E.defaults()];
    for(const goldChance of [0,1.23,100]){const p=E.defaults();p.goldChance=goldChance;profiles.push(p);}
    for(const total of [100,1000000]){const p=E.defaults();p.weightTotal=total;for(const mode of ['n','f'])for(let s=0;s<11;s++)for(let c=0;c<5;c++)p.weights[mode][s][c]=Math.floor(p.weights[mode][s][c]*total/10000);profiles.push(p);}
    for(const mode of ['n','f']){const p=E.defaults();p.weights[mode][10].fill(0);profiles.push(p);}
    const restricted=E.defaults();restricted.enabled=restricted.enabled.map((on,i)=>i===0||i===2);profiles.push(restricted);
    for(let i=0;i<profiles.length;i++){
        const before=JSON.stringify(profiles[i]),n=1000,a=await sample(profiles[i],n),b=await reference(profiles[i],n);
        assert.deepEqual(a,b,'native/JS full-round parity, profile '+i);assert.equal(JSON.stringify(profiles[i]),before);
    }
    const loop=E.defaults();for(const mode of ['n','f']){loop.weights[mode]=Array.from({length:11},()=>Array(5).fill(0));loop.weights[mode][10].fill(10000);}
    await assert.rejects(sample(loop,1),e=>e.code==='MJHL_GENERATION_LIMIT');await assert.rejects(reference(loop,1),e=>e.code==='MJHL_GENERATION_LIMIT');
    await assert.rejects(sample(E.defaults(),1,3),/分组/);
    const merge=V.merge,one=(x,y)=>({count:1,mean:x,m2:0,meanGrants:y,m2Grants:0,cov:0});
    const all=[one(1,10),one(3,0),one(8,2),one(2,4)],left=all.reduce(merge,null),right=merge(merge(all[0],all[1]),merge(all[2],all[3]));assert.deepEqual(left,right);
    const n={count:1000,mean:.5,m2:999,meanGrants:0,m2Grants:0,cov:0},f={count:1000,mean:0,m2:0,meanGrants:0,m2Grants:0,cov:0};
    const est=V.estimate([n,f,f],2);assert.equal(est.total,.5);assert.equal(est.half95,2/Math.sqrt(1000));
    assert.equal(V.estimate([n,{...f,meanGrants:1},f],2).reliable,false);
    assert.throws(()=>V.estimate([null,f,f],2),/不完整/);
    let called=false;V.verify({...E,verifyRtp(p,o,done){called=true;done(null,{small:true});}},E.defaults(),{validationCount:100,sampleRunner(){}},(e,r)=>{assert(!e);assert(r.small);});assert(called,'small remaining budget must use the original bounded verifier');
    const runner=(p,count,seed,opts,done)=>done(null,{count,mean:opts.component===0?.8:0,m2:opts.component===0?count-1:0,meanGrants:0,m2Grants:0,cov:0,parallelDraws:count,parallelBatches:[{count,seed128:opts.validationSeed128}]});
    const verify=opts=>new Promise((resolve,reject)=>V.verify(E,E.defaults(),{sampleRunner:runner,...opts},(e,r)=>e?reject(e):resolve(r)));
    const precise=await verify({confidenceCheckCount:10});assert(precise.precisionReached);assert.equal(precise.stats.intervalZ,E.verificationZ(10));assert.equal(precise.stats.count,9000000);
    const miss=await verify({targetPercent:50});assert(miss.targetMiss);assert.equal(miss.targetReached,false);
    let cancel=false;await assert.rejects(verify({cancelled:()=>cancel,onCheckpoint:()=>{cancel=true;}}),e=>e.code==='MJHL_RTP_CANCELLED');
    console.log(JSON.stringify({pass:'9 native/JS complete-round profiles, exact random draws/statistics, limit errors, covariance merge, confidence and remaining budget',rounds:9000}));
})().catch(e=>{console.error(e);process.exitCode=1;});
