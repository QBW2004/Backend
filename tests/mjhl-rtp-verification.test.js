'use strict';
// 真实引擎的统计/验证边界测试；不连接数据库、不发游戏请求、不修改业务配置。
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');
const E = require('../TTY.Web/Scripts/app/mjhl.engine.js');
const copy = value => JSON.parse(JSON.stringify(value));
const sample = (profile, count, random) => new Promise((resolve,reject) => E.sample(profile,count,17,{random,batchSize:5000},(err,stats)=>err?reject(err):resolve(stats)));
const verify = (profile,options) => new Promise(resolve=>E.verifyRtp(profile,options,(error,result)=>resolve({error,result})));
const calibrate = (profile,target,options) => new Promise(resolve=>E.calibrateRtp(profile,target,options,(error,result)=>resolve({error,result})));
const keys = ['zero','small','medium','big','mega','super'];
const words = [11,22,33,44];
function near(a,b,label,tolerance=1e-10) { assert(Math.abs(a-b)<=tolerance,label+': '+a+' / '+b); }
function checkDistribution(stats) {
    assert.equal(keys.reduce((n,key)=>n+stats.distribution[key],0),stats.count);
    for(const key of keys) assert(Number.isInteger(stats.distribution[key])&&stats.distribution[key]>=0);
    assert.equal(stats.roundHit,1-stats.distribution.zero/stats.count);
}
(async function(){
    for(const [value,band] of [[0,'zero'],[.001,'small'],[4.999999,'small'],[5,'medium'],[19.999999,'medium'],[20,'big'],[34.999999,'big'],[35,'mega'],[49.999999,'mega'],[50,'super'],[5000,'super']]) assert.equal(E.payoutBand(value),band);
    const profile=E.defaults(), original=JSON.stringify(profile), count=20000;
    const whole=await sample(profile,count,E.xoshiro128ss(words));
    const stream=E.xoshiro128ss(words), first=await sample(profile,7777,stream), second=await sample(profile,count-7777,stream);
    const merged=E.mergeSampleStats(E.mergeSampleStats(null,first),second);
    checkDistribution(whole);checkDistribution(merged);
    assert.deepEqual(whole.distribution,merged.distribution);
    for(const key of ['normal','free','total','mean','hit','miss','scatter','cap','roundHit'])near(whole[key],merged[key],key);
    near(whole.m2,merged.m2,'parallel M2',1e-6);
    near(whole.half95,1.96*Math.sqrt(merged.m2/(count-1)/count),'merged confidence');
    assert.equal(JSON.stringify(profile),original);

    const low=await verify(profile,{validationCount:2000,blockCount:700,tolerancePercent:.000001,validationSeed128:words});
    assert(!low.error);assert.equal(low.result.precisionReached,false);assert.equal(low.result.exact,false);assert.equal(low.result.stats.count,2000);
    checkDistribution(low.result.stats);
    const direct=await sample(profile,2000,E.xoshiro128ss(words));
    assert.deepEqual(low.result.stats.distribution,direct.distribution);
    near(low.result.stats.total,direct.total,'verify does not alter profile');
    near(low.result.stats.m2,direct.m2,'verify cumulative M2',1e-6);
    assert.deepEqual(low.result.validationBatches.map(x=>[x.offset,x.count]),[[0,700],[700,700],[1400,600]]);
    assert.deepEqual(low.result.plannedCheckpoints,[2000]);
    near(E.verificationZ(5),2.57582930355,'five planned looks');
    const tenLook=await verify(profile,{validationCount:2000,blockCount:700,validationSeed128:words,confidenceCheckCount:10});
    assert.deepEqual(tenLook.result.stats.distribution,low.result.stats.distribution);
    assert.equal(tenLook.result.stats.total,low.result.stats.total);
    assert.equal(tenLook.result.confidenceCheckCount,10);
    near(tenLook.result.stats.half95/low.result.stats.half95,E.verificationZ(10)/E.verificationZ(1),'same samples, stricter joint interval');
    assert.equal(JSON.stringify(profile),original);

    const zero=await calibrate(profile,0,{});assert(!zero.error&&zero.result.exact);
    const zeroOriginal=JSON.stringify(zero.result.profile);
    const noReturn=await verify(zero.result.profile,{validationCount:1000,validationSeed128:words});
    assert(!noReturn.error&&noReturn.result.precisionReached);assert.equal(noReturn.result.exact,true);
    assert.equal(noReturn.result.stats.total,0);assert.equal(noReturn.result.stats.count,0);assert.equal(noReturn.result.stats.distribution.zero,0);
    assert.equal(noReturn.result.validationDraws,0);assert(noReturn.result.reason.includes('前两轴'));
    assert.equal(JSON.stringify(zero.result.profile),zeroOriginal);
    const provenZeroCheck=await calibrate(zero.result.profile,0,{validationOnly:true,maxCorrections:1});
    assert(!provenZeroCheck.error);assert(provenZeroCheck.result.success&&provenZeroCheck.result.exact);
    assert.equal(provenZeroCheck.result.stats.count,0);assert.equal(provenZeroCheck.result.validationDraws,0);
    assert.deepEqual(provenZeroCheck.result.validationSeed128,[]);assert.deepEqual(provenZeroCheck.result.plannedCheckpoints,[]);
    const provenWrongTarget=await calibrate(zero.result.profile,97,{validationOnly:true,maxCorrections:1});
    assert.equal(provenWrongTarget.error.code,'MJHL_RTP_NOT_REACHED');assert.equal(provenWrongTarget.result.profile,null);
    assert(provenWrongTarget.result.exact);assert.equal(provenWrongTarget.result.stats.count,0);
    assert.equal(provenWrongTarget.result.validationAttempts.length,1);assert.deepEqual(provenWrongTarget.result.validationAttempts[0].validationSeed128,[]);
    assert.equal(JSON.stringify(zero.result.profile),zeroOriginal);
    const rare=copy(zero.result.profile);rare.weights.n[1][1]=9999;rare.weights.n[0][1]=1;
    const rareBefore=JSON.stringify(rare),unseen=await verify(rare,{validationCount:100,validationSeed128:words});
    assert.equal(E.proveZeroReturn(rare),false);assert(!unseen.error);assert.equal(unseen.result.exact,false);assert.equal(unseen.result.precisionReached,false);
    assert.equal(unseen.result.stats.total,0);assert.equal(unseen.result.stats.count,100);assert.equal(unseen.result.stats.unobservedReturn,true);assert.equal(unseen.result.stats.intervalReliable,false);
    assert.equal(JSON.stringify(rare),rareBefore);
    const canScatter=copy(zero.result.profile);canScatter.weights.n[0][2]=9999;canScatter.weights.n[10][2]=1;assert.equal(E.proveZeroReturn(canScatter),false);
    const canFill=copy(zero.result.profile);canFill.weights.n[0][0]=9999;assert.equal(E.proveZeroReturn(canFill),false);
    // 验证实际sample/verify的10000个同步小块不会递归爆栈；盘面生成换成可知分布，计时器用队列驱动。
    // 真实盘面/免费链的统计一致性已由前面的连续随机流测试覆盖。
    const queue=[],engineScope={module:{exports:{}},setTimeout:fn=>queue.push(fn)};
    const engineText=fs.readFileSync(path.join(__dirname,'../TTY.Web/Scripts/app/mjhl.engine.js'),'utf8');
    const syntheticText=engineText.replace(/function generateRound\(c, r, bet, record\) \{[\s\S]*?\n    \}/,'function generateRound(c,r,bet,record) { var amount=r()<0.5?0:betTicks(bet)*2; return {total:amount,trig:{totalWin:amount,hit:amount>0,scatterMax:0},capped:false}; }');
    assert.notEqual(syntheticText,engineText);
    vm.runInNewContext(syntheticText,engineScope);
    const constant=copy(zero.result.profile);constant.goldChance=0;for(const row of constant.weights.n)row.fill(0);constant.weights.n[0]=[10000,10000,10000,10000,10000];
    let smallBlocks;
    engineScope.module.exports.verifyRtp(constant,{validationCount:1000000,blockCount:100,validationSeed128:words},(error,result)=>{smallBlocks={error,result};});
    while(queue.length)queue.shift()();
    assert(smallBlocks&&!smallBlocks.error);assert.equal(smallBlocks.result.stats.count,1000000);
    assert.equal(smallBlocks.result.validationBatches.length,10000);assert.equal(smallBlocks.result.precisionReached,true);assert.equal(smallBlocks.result.stats.intervalReliable,true);
    let earlyMiss;
    engineScope.module.exports.verifyRtp(constant,{validationCount:5000000,targetPercent:1000,validationSeed128:words},(error,result)=>{earlyMiss={error,result};});
    while(queue.length)queue.shift()();
    assert(earlyMiss&&!earlyMiss.error);assert.equal(earlyMiss.result.stats.count,1000000);assert.equal(earlyMiss.result.targetMiss,true);assert.equal(earlyMiss.result.stoppedEarly,true);assert.equal(earlyMiss.result.targetReached,false);
    const constantCheck=await verify(constant,{validationCount:1000,validationSeed128:words});
    assert(!constantCheck.error);assert.equal(constantCheck.result.stats.total,5000);assert.equal(constantCheck.result.precisionReached,false);assert.equal(constantCheck.result.stats.intervalReliable,false);
    const cancelled=await verify(profile,{cancelled:()=>true});assert.equal(cancelled.error.code,'MJHL_RTP_CANCELLED');assert(!cancelled.result);
    let stop=false;
    const midCancel=await verify(profile,{validationCount:20000,cancelled:()=>stop,onValidationProgress:()=>{stop=true;}});
    assert.equal(midCancel.error.code,'MJHL_RTP_CANCELLED');assert(!midCancel.result);
    stop=false;
    const finalCancel=await verify(profile,{validationCount:1000,cancelled:()=>stop,onValidationProgress:()=>{stop=true;}});
    assert.equal(finalCancel.error.code,'MJHL_RTP_CANCELLED');assert(!finalCancel.result);
    stop=false;
    const checkpointCancel=await verify(profile,{validationCount:1000,cancelled:()=>stop,onCheckpoint:()=>{stop=true;}});
    assert.equal(checkpointCancel.error.code,'MJHL_RTP_CANCELLED');assert(!checkpointCancel.result);
    const invalid=copy(profile);invalid.weights.n[0][0]=10001;
    assert((await verify(invalid,{})).error);

    // 仅复核候选时不套用小奖塑形；离目标很远必须拒绝，而不是套用候选。
    const failed=await calibrate(profile,1000,{validationOnly:true,maxCorrections:99,preferSmallWins:true,validationCount:2000,validationSeed128:words});
    assert.equal(failed.error.code,'MJHL_RTP_NOT_REACHED');assert.equal(failed.result.profile,null);assert.equal(failed.result.success,false);
    assert.equal(failed.result.smallWinBias,false);
    assert.equal(failed.result.validationAttempts.length,1);assert.equal(failed.result.correction,null);
    assert.equal(failed.result.confidenceCheckCount,1);
    assert.equal(failed.result.tolerancePercent,.5);assert.deepEqual(failed.result.stats.distribution,direct.distribution);
    assert.equal(JSON.stringify(profile),original);
    const zeroTargetCheck=await calibrate(profile,0,{validationOnly:true,validationCount:2000,validationSeed128:words});
    assert.equal(zeroTargetCheck.error.code,'MJHL_RTP_NOT_REACHED');assert.equal(zeroTargetCheck.result.profile,null);assert.equal(zeroTargetCheck.result.exact,false);
    assert.deepEqual(zeroTargetCheck.result.stats.distribution,direct.distribution);assert.equal(JSON.stringify(profile),original);
    const shaped=E.smallWinProfile(profile);
    assert.deepEqual(E.validate(shaped),[]);assert.equal(shaped.goldChance,profile.goldChance);
    for(const mode of ['n','f'])for(let col=0;col<5;col++){
        for(let row=0;row<9;row++)assert(shaped.weights[mode][row][col]>0);
        for(let row=9;row<11;row++)assert.equal(shaped.weights[mode][row][col],profile.weights[mode][row][col]);
        assert(shaped.weights[mode][0][col]>shaped.weights[mode][7][col]);
    }
    const off=copy(profile),reserved={n:profile.weights.n[10].slice(),f:profile.weights.f[10].slice()};
    off.weights.n[10]=[0,0,0,0,0];off.weights.f[10]=[0,0,0,0,0];
    for(const factor of [0,.1,1,8]){
        const scaled=E.scaleOrdinary(E.smallWinProfile(off,reserved),factor,reserved,true);
        for(const mode of ['n','f']){assert.deepEqual(scaled.weights[mode][10],[0,0,0,0,0]);for(let row=0;row<9;row++)assert(scaled.weights[mode][row].every(x=>x>0));scaled.weights[mode][10]=reserved[mode];}
        assert.deepEqual(E.validate(scaled),[]);
    }
    assert.equal(JSON.stringify(profile),original);

    // 并行只改变采样调度；检查点预先固定，统计必须来自完整且数量吻合的逻辑分片。
    const shardCalls=[];
    const shardVerify=await verify(profile,{validationCount:50000000,quickCheckpoints:true,tolerancePercent:1,
        targetPercent:80,validationSeed128:words,sampleRunner:(p,n,seed,options,done)=>{
            shardCalls.push({n,offset:options.sampleOffset});
            done(null,{count:n,total:.8,normal:.7,free:.1,mean:.8,m2:n*.01,half95:.001,hit:.5,miss:.5,scatter:.1,cap:0,
                intervalReliable:true,unobservedReturn:false,distribution:{zero:n/2,small:n/2,medium:0,big:0,mega:0,super:0},
                parallelBatches:[{seed128:[5,6,7,8],offset:options.sampleOffset,count:n,draws:n*100}],parallelDraws:n*100,parallelRng:'test-shards'});
        }});
    assert(!shardVerify.error && shardVerify.result.targetReached);
    assert.deepEqual(shardVerify.result.plannedCheckpoints,[250000,1000000,3000000,10000000,50000000]);
    assert.deepEqual(shardCalls,[{n:250000,offset:0}]);
    assert.equal(shardVerify.result.validationDraws,25000000);
    assert.equal(shardVerify.result.validationRng,'test-shards');
    assert.deepEqual(shardVerify.result.validationBatches[0].seed128,[5,6,7,8]);
    const incomplete=await verify(profile,{validationCount:1000,sampleRunner:(p,n,seed,options,done)=>done(null,{count:n-1})});
    assert(incomplete.error && /样本不完整/.test(incomplete.error.message));

    // 只验证新检查点的控制边界：输入为明确标注的合成统计，不作为任何代理实际RTP证据。
    // 每批用同一个方差，累计误差仅随完整样本数下降；实际verifyRtp自行计算区间和停止条件。
    const firstCheckpoint=250000, jointZ=E.verificationZ(10);
    function controlledPart(n,options,total,firstHalf) {
        const variance=Math.pow(firstHalf/jointZ,2)*(firstCheckpoint-1);
        return {count:n,total,normal:total,free:0,mean:total,m2:variance*n,half95:0,hit:1,miss:0,scatter:0,cap:0,
            intervalReliable:true,unobservedReturn:false,roundHit:1,
            distribution:{zero:0,small:n,medium:0,big:0,mega:0,super:0},
            parallelBatches:[{seed128:options.validationSeed128.slice(),offset:options.sampleOffset,count:n,draws:n*101}],
            parallelDraws:n*101,parallelRng:'synthetic-boundary-statistics',parallelWorkers:4};
    }
    async function correctionBoundary(total,firstHalf,extra={}) {
        const checkpoints=[],parts=[],opts=Object.assign({validationCount:50000000,quickCheckpoints:true,tolerancePercent:1,
            targetPercent:80,allowTargetCorrection:true,confidenceCheckCount:10,validationSeed128:words,
            sampleRunner:(p,n,seed,options,done)=>{
                parts.push({n,offset:options.sampleOffset});done(null,controlledPart(n,options,total,firstHalf));
            },onCheckpoint:(stats,passed)=>checkpoints.push({count:stats.count,half95:stats.half95,total:stats.total,passed})},extra);
        const checked=await verify(profile,opts);assert(!checked.error);
        assert.deepEqual(checked.result.plannedCheckpoints,[250000,1000000,3000000,10000000,50000000]);
        assert.equal(checked.result.confidenceCheckCount,10);
        checkDistribution(checked.result.stats);
        for(const name of ['parallelBatches','parallelDraws','parallelRng','parallelWorkers'])assert.equal(checked.result.stats[name],undefined,'stale first-shard metadata '+name);
        assert.equal(checked.result.validationBatches.reduce((n,part)=>n+part.count,0),checked.result.stats.count);
        assert.equal(checked.result.validationDraws,checked.result.stats.count*101);
        assert.equal(checked.result.validationRng,'synthetic-boundary-statistics');
        return {result:checked.result,checkpoints,parts};
    }
    const correctionReady=await correctionBoundary(.807,.008);
    assert.equal(correctionReady.result.stats.count,250000);assert.equal(correctionReady.result.needsCorrection,true);
    assert.equal(correctionReady.result.precisionReached,true);assert.equal(correctionReady.result.targetReached,false);
    assert.equal(correctionReady.result.targetMiss,false);assert.equal(correctionReady.result.stoppedEarly,true);
    assert.equal(correctionReady.result.profile,undefined);assert.equal(correctionReady.result.success,undefined);
    assert.equal(correctionReady.checkpoints[0].passed,false);near(correctionReady.result.stats.half95,.008,'0.8 tolerance inclusive boundary');
    const correctionBelow=await correctionBoundary(.793,.008);
    assert.equal(correctionBelow.result.stats.count,250000);assert.equal(correctionBelow.result.needsCorrection,true);assert.equal(correctionBelow.result.targetReached,false);
    const highError=await correctionBoundary(.807,.00800001);
    assert(highError.result.stats.count>250000);assert(highError.checkpoints[0].half95>.008);assert(highError.checkpoints[0].half95<.01);
    const notPrecise=await correctionBoundary(.807,.010001);
    assert(notPrecise.result.stats.count>250000);assert(notPrecise.checkpoints[0].half95>.01);assert.equal(notPrecise.checkpoints[0].passed,false);
    const quarterEqual=await correctionBoundary(.8025,.008);
    assert(quarterEqual.result.stats.count>250000);assert.equal(quarterEqual.result.needsCorrection,false);assert.equal(quarterEqual.result.targetReached,true);
    const quarterBelow=await correctionBoundary(.80249,.008);
    assert(quarterBelow.result.stats.count>250000);assert.equal(quarterBelow.result.needsCorrection,false);
    const quarterAbove=await correctionBoundary(.80250001,.008);
    assert.equal(quarterAbove.result.stats.count,250000);assert.equal(quarterAbove.result.needsCorrection,true);assert.equal(quarterAbove.result.targetReached,false);
    const alreadyWithin=await correctionBoundary(.801,.008);
    assert.equal(alreadyWithin.result.stats.count,250000);assert.equal(alreadyWithin.result.targetReached,true);assert.equal(alreadyWithin.result.needsCorrection,false);
    const noCorrectionFlag=await correctionBoundary(.807,.008,{allowTargetCorrection:false});
    assert.equal(noCorrectionFlag.result.stats.count,3000000);assert.equal(noCorrectionFlag.result.targetReached,true);assert.equal(noCorrectionFlag.result.needsCorrection,false);
    const manualVerify=await correctionBoundary(.807,.008,{allowTargetCorrection:false,targetPercent:undefined});
    assert.equal(manualVerify.result.stats.count,250000);assert.equal(manualVerify.result.targetReached,null);assert.equal(manualVerify.result.needsCorrection,false);assert.equal(manualVerify.result.precisionReached,true);
    const flagWithoutTarget=await correctionBoundary(.807,.008,{targetPercent:undefined});
    assert.equal(flagWithoutTarget.result.needsCorrection,false);assert.equal(flagWithoutTarget.result.targetReached,null);

    // 保留真实calibrate/verify控制器：仅替换采样器，首轮精度已够但目标未达必须换候选与独立流。
    const trainingBase=profile.weights.n.slice(0,9).reduce((n,row)=>n+row[0],0), validationCalls=[],trainingCounts=[];
    const firstWords=[101,102,103,104],secondWords=[201,202,203,204];
    const twoRounds=await calibrate(profile,80,{searchCount:20000,refineCount:20000,iterations:8,
        validationCount:50000000,quickCheckpoints:true,tolerancePercent:1,maxCorrections:1,
        seed:7,validationSeed128:firstWords,correctionSeed128:secondWords,
        sampleRunner:(p,n,seed,options,done)=>{
            if(options.validationSeed128){
                const round=options.validationSeed128[0]===firstWords[0]?1:2;
                validationCalls.push({round,count:n,offset:options.sampleOffset,profile:copy(p),words:options.validationSeed128.slice()});
                done(null,controlledPart(n,options,round===1?.807:.8,.008));
            } else {
                trainingCounts.push(n);const total=p.weights.n.slice(0,9).reduce((sum,row)=>sum+row[0],0)/trainingBase;
                done(null,{count:n,total,normal:total,free:0,mean:total,m2:.00001,half95:.000001,hit:1,miss:0,scatter:0,cap:0,
                    intervalReliable:true,unobservedReturn:false,roundHit:1,distribution:{zero:0,small:n,medium:0,big:0,mega:0,super:0}});
            }
        }});
    assert(!twoRounds.error,twoRounds.error&&twoRounds.error.message);assert.equal(twoRounds.result.success,true);
    assert.equal(validationCalls.length,2);assert.deepEqual(validationCalls.map(x=>[x.round,x.offset,x.count]),[[1,0,250000],[2,0,250000]]);
    assert.notDeepEqual(validationCalls[0].profile.weights,validationCalls[1].profile.weights);
    assert.deepEqual(validationCalls[0].words,firstWords);assert.deepEqual(validationCalls[1].words,secondWords);
    assert.equal(twoRounds.result.validationAttempts.length,2);
    const [failedAttempt,passedAttempt]=twoRounds.result.validationAttempts;
    assert.equal(failedAttempt.success,false);assert.equal(passedAttempt.success,true);
    assert.equal(failedAttempt.confidenceCheckCount,10);assert.equal(passedAttempt.confidenceCheckCount,10);assert.equal(twoRounds.result.confidenceCheckCount,10);
    near(failedAttempt.stats.half95,.008,'first joint-ten-look interval');near(passedAttempt.stats.half95,.008,'second joint-ten-look interval');
    assert.equal(failedAttempt.stats.total,.807);assert.equal(twoRounds.result.stats.total,.8);assert.equal(twoRounds.result.stats.count,250000);
    assert.equal(twoRounds.result.validationDraws,250000*101);assert.equal(twoRounds.result.stats.distribution.small,250000);
    assert.deepEqual(failedAttempt.validationBatches[0].seed128,firstWords);assert.deepEqual(passedAttempt.validationBatches[0].seed128,secondWords);
    assert.deepEqual(twoRounds.result.validationBatches,passedAttempt.validationBatches);
    assert.equal(twoRounds.result.sampleBudget.used,trainingCounts.reduce((sum,n)=>sum+n,0)+500000);
    const beforePassedPlan=JSON.stringify(passedAttempt.validationBatches);twoRounds.result.validationBatches[0].seed128[0]=999;
    assert.equal(JSON.stringify(passedAttempt.validationBatches),beforePassedPlan,'attempt replay metadata must be a deep snapshot');
    assert.equal(JSON.stringify(profile),original);

    // Worker 路由测试：只校准按钮允许塑形，verify 必须使用原始 profile。
    const workerSource=fs.readFileSync(path.join(__dirname,'../TTY.Web/Scripts/app/mjhl.agent.rtp.worker.js'),'utf8');
    const calls=[],messages=[];
    const poolSample=function(){},disposed=[];
    const scope={importScripts:(...urls)=>urls.forEach(url=>assert(/mjhl\.(engine|rtp\.(pool|native|wasm|verify))\.js\?v=mjhl-verify-\d{8}-v\d+$/.test(url))),MjhlRtpPool:{create:()=>({sample:poolSample,dispose:()=>disposed.push(true)})},Date,setTimeout:fn=>fn(),self:{postMessage:value=>messages.push(value)},MjhlEngine:{
        proveZeroReturn:()=>false,xoshiro128ss:()=>()=>0.5,sample:(p,count,seed,opts,done)=>done(null,direct),
        freshSeed:()=>123456,freshSeed128:()=>words.slice(),
        verifyRtp:(p,opts,done)=>{calls.push({kind:'verify',p,opts});done(null,{stats:direct,precisionReached:false,exact:false});},
        calibrateRtp:(p,target,opts)=>calls.push({kind:'calibrate',p,target,opts})
    }};
    vm.runInNewContext(workerSource,scope);
    scope.self.onmessage({data:{type:'verify',profile}});assert.equal(calls[0].p,profile);assert.equal(calls[0].opts.validationCount,50000000);assert.equal(calls[0].opts.tolerancePercent,1);assert(!calls[0].opts.preferSmallWins);assert(messages[0].preview);assert.equal(messages[1].result.precisionReached,false);
    scope.self.onmessage({data:{type:'calibrate',profile,target:97,reservedScatter:reserved}});assert.equal(calls[1].opts.preferSmallWins,true);assert.equal(calls[1].opts.tolerancePercent,1);assert.equal(calls[1].opts.validationCount,50000000);assert.equal(calls[1].opts.refineCount,1000000);assert.equal(calls[1].opts.reservedScatter,reserved);assert.equal(calls[1].opts.seed,123456);assert.deepEqual(calls[1].opts.validationSeed128,words);
    assert.equal(calls[0].opts.sampleRunner,poolSample);assert.equal(calls[1].opts.sampleRunner,poolSample);assert(calls[0].opts.quickCheckpoints && calls[1].opts.quickCheckpoints);assert.equal(disposed.length,1);
    assert.equal(calls[1].opts.maxCorrections,1);assert.equal(calls[1].opts.maxTotalSamples,151000000);
    assert.equal(typeof calls[1].opts.onMeasureProgress,'function');calls[1].opts.onMeasureProgress('refine',25000,5000000);assert.equal(messages[messages.length-1].progress.phase,'refine');
    scope.self.onmessage({data:{type:'calibrate',profile,target:97,seed:19,validationSeed128:[1,2,3,4]}});assert.equal(calls[2].opts.seed,19);assert.deepEqual(calls[2].opts.validationSeed128,[1,2,3,4]);
    console.log('PASS real payout bands, continuous RNG + cumulative M2/distribution, verify no mutation/precision failure, exact-zero separation, cancellation, rejected calibration, positive small-win candidate, disabled-scatter reserve, target-correction boundaries, independent ten-look validation and replay metadata, worker routing; no network/DB writes.');
})().catch(error=>{console.error(error.stack);process.exitCode=1;});
