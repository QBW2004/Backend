'use strict';
// Independent full-paid-round reference. No importance sampling is used for the reference.
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict');
const E=require('../TTY.Web/Scripts/app/mjhl.engine.js'),H=require('./helpers/mjhl-rtp-node-worker.js');
const V=require('../TTY.Web/Scripts/app/mjhl.rtp.verify.js');
const out=path.resolve(__dirname,'../.build/mjhl-rtp-fast');fs.mkdirSync(out,{recursive:true});
const p=E.defaults(),start=performance.now(),planRng=E.xoshiro128ss([0x87654321,0x18273645,0xfedcba98,0x56473829]);
const plan=Array.from({length:200},(_,i)=>({offset:i*250000,count:250000,seed128:Array.from({length:4},()=>planRng.uint32())}));
(async()=>{
    const pool=H.createPool({maxWorkers:8,hardwareConcurrency:16});let reference;
    try{reference=await new Promise((resolve,reject)=>pool.sample(p,50000000,0,{parallelPlan:plan},(e,s)=>e?reject(e):resolve(s)));}finally{pool.dispose();}
    fs.writeFileSync(path.join(out,'full-round-reference.json'),JSON.stringify({ms:performance.now()-start,profile:p,stats:reference,plan},null,2));
    console.log(JSON.stringify({reference:'50000000 complete paid rounds',ms:performance.now()-start,rtp:reference.total,half95pp:reference.half95*100,draws:reference.parallelDraws}));
    const report=[];
    for(let run=0;run<5;run++){
        const rng=E.xoshiro128ss([0x33333333+run,0x55555555,0x77777777,0x99999999]);
        const engine=Object.assign({},E,{freshSeed128:()=>Array.from({length:4},()=>rng.uint32())});
        const samplePool=H.createPool({engine,maxWorkers:8,hardwareConcurrency:16});const began=performance.now();
        try{
            const result=await new Promise((resolve,reject)=>V.verify(engine,p,{sampleRunner:samplePool.sample,validationCount:50000000,tolerancePercent:1},(e,s)=>e?reject(e):resolve(s)));
            const s=result.stats,delta=Math.abs(s.total-reference.total),combined=Math.sqrt(s.varianceOfMean+reference.m2/(reference.count-1)/reference.count);
            assert(result.precisionReached);assert(s.half95<=.01);assert(delta<4*combined,'independent RTP estimates disagree');
            assert(s.components[1].mean>0,'blank substitution residual must be included');
            report.push({run,ms:performance.now()-began,rtp:s.total,half95pp:s.half95*100,deltaPercent:delta*100,standardErrors:delta/combined,stats:s});
            console.log(JSON.stringify(report[report.length-1]));
        }finally{samplePool.dispose();}
    }
    fs.writeFileSync(path.join(out,'independent-checks.json'),JSON.stringify(report,null,2));
})().catch(e=>{console.error(e);process.exitCode=1;});
