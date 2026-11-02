'use strict';
// 纠偏编排的边界测试使用可知统计替身；真实随机流、免费链和分布在 verification/stream 测试覆盖。
// 不把此文件的合成统计当成游戏实际 RTP 验收证据，不访问网络或数据库。
const assert=require('node:assert/strict'),fs=require('node:fs'),path=require('node:path'),vm=require('node:vm');
const E=require('../TTY.Web/Scripts/app/mjhl.engine.js');
const source=fs.readFileSync(path.join(__dirname,'../TTY.Web/Scripts/app/mjhl.engine.js'),'utf8');
const copy=x=>JSON.parse(JSON.stringify(x));
const near=(a,b)=>assert(Math.abs(a-b)<1e-11,a+' != '+b);
function stats(total,count,half=.0001){return {total,normal:total,free:0,hit:1,miss:0,scatter:0,cap:0,half95:half,count,mean:total,m2:count,
    intervalReliable:true,unobservedReturn:false,roundHit:1,distribution:{zero:0,small:count,medium:0,big:0,mega:0,super:0}};}
const chosen=1.0764071408794338, anchor=stats(.9726766239999776,50000000,.0030935348005542596);
const points=[
    {factor:1.053431725929847,stats:stats(.8993944499989524,5000000,.007089887190396709)},
    {factor:1.0927453807438776,stats:stats(1.0353013499978002,5000000,.007896862714179036)},
    {factor:1.073855723686543,stats:stats(.9641557199986472,5000000,.007496630909734073)},
    {factor:1.07763365509801,stats:stats(.9779068399985074,5000000,.00771084688441506)},
    {factor:1.0754613593725628,stats:stats(.9639029299985957,5000000,.006848994188391612)}
];
const beforePoints=JSON.stringify(points), suggestion=E.correctionFactor(chosen,anchor,points,.97,.005,5000000);
assert(!suggestion.reason);near(suggestion.factor,1.0757591877956105);near(suggestion.slope,4.130891675342404);
assert.equal(suggestion.low.factor,1.0754613593725628);assert.equal(suggestion.high.factor,1.0927453807438776);
assert.equal(JSON.stringify(points),beforePoints);
assert.equal(E.correctionFactor(chosen,Object.assign({},anchor,{intervalReliable:false}),points,.97,.005,5000000).reason,'anchor_precision');
assert.equal(E.correctionFactor(chosen,Object.assign({},anchor,{half95:.006}),points,.97,.005,5000000).reason,'anchor_precision');
assert.equal(E.correctionFactor(chosen,anchor,[],.97,.005,5000000).reason,'no_reliable_slope');
assert.equal(E.correctionFactor(chosen,stats(4,50000000,.001),points,.97,.005,5000000).reason,'outside_bracket');
assert.equal(E.correctionFactor(chosen,stats(.97,50000000,.001),points,.97,.005,5000000).reason,'unchanged_factor');
const base=E.smallWinProfile(E.defaults()),previous=E.scaleOrdinary(base,chosen,null,true),corrected=E.scaleOrdinary(base,suggestion.factor,null,true);
assert.notDeepEqual(previous.weights,corrected.weights);assert.deepEqual(E.validate(corrected),[]);
for(const mode of ['n','f'])for(let row=9;row<11;row++)assert.deepEqual(previous.weights[mode][row],corrected.weights[mode][row]);
assert.equal(previous.goldChance,corrected.goldChance);assert.deepEqual(previous.enabled,corrected.enabled);
near(E.verificationZ(10),2.8070337683438114);assert(E.verificationZ(10)>E.verificationZ(5));

function control(settings={}){
    const p=E.defaults(), original=JSON.stringify(p), sum=p.weights.n.slice(0,9).reduce((n,row)=>n+row[0],0);
    const sampleCalls=[],verifyCalls=[];let cancelled=false,result;
    const scope={module:{exports:{}},setTimeout:fn=>fn(),testSample(profile,count,seed,options,done){
        sampleCalls.push({profile:copy(profile),count});
        const value=profile.weights.n.slice(0,9).reduce((n,row)=>n+row[0],0)/sum;
        done(null,stats(value,count,settings.noSlope ? .2 : .0001));
    },testVerify(profile,options,done){
        verifyCalls.push({profile:copy(profile),options});
        const first=verifyCalls.length===1, success=!first&&!settings.failSecond;
        const total=first ? (settings.unchanged ? .80000000001 : .82) : settings.failSecond ? .82 : .8;
        const sample=stats(total,options.validationCount,settings.unchanged ? .005 : .001);
        done(null,{stats:sample,exact:false,precisionReached:true,targetReached:success,targetMiss:false,stoppedEarly:false,
            validationSeed128:options.validationSeed128.slice(),validationRng:'test only',validationDraws:123,
            validationBatches:[],plannedCheckpoints:[options.validationCount],confidenceCheckCount:options.confidenceCheckCount});
    }};
    const replaced=source.replace(/function sample\(profile, count, seed, opts, onDone\) \{[\s\S]*?\n    \}/,
        'function sample(profile,count,seed,opts,onDone) { testSample(profile,count,seed,opts,onDone); }')
        .replace(/function verifyRtp\(profile, opts, onDone\) \{[\s\S]*?\n    \}/,
        'function verifyRtp(profile,opts,onDone) { testVerify(profile,opts,onDone); }');
    assert.notEqual(replaced,source);vm.runInNewContext(replaced,scope);
    scope.module.exports.calibrateRtp(p,settings.target||80,{searchCount:20000,refineCount:20000,validationCount:20000,maxCorrections:99,maxFactor:settings.maxFactor,
        seed:7,validationSeed128:[1,2,3,4],correctionSeed128:settings.reuseSeed?[1,2,3,4]:[5,6,7,8],maxTotalSamples:settings.budget||1000000,
        cancelled:()=>cancelled,onProgress:(best,factor,sample,phase,measuredProfile)=>{
            if(sample&&phase!=='verify')assert(measuredProfile);
            if(settings.cancelCorrection&&phase==='correction')cancelled=true;
        }},(error,value)=>{result={error,value};});
    assert(result);assert.equal(JSON.stringify(p),original);return {result,verifyCalls,sampleCalls};
}
const success=control();assert(!success.result.error);assert.equal(success.verifyCalls.length,2);assert(success.result.value.success);
assert(success.verifyCalls.every(x=>x.options.confidenceCheckCount===10));
assert.notDeepEqual(success.verifyCalls[0].profile.weights,success.verifyCalls[1].profile.weights);
assert.deepEqual(Array.from(success.verifyCalls[0].options.validationSeed128),[1,2,3,4]);assert.deepEqual(Array.from(success.verifyCalls[1].options.validationSeed128),[5,6,7,8]);
assert.equal(success.result.value.stats.count,20000);assert.equal(success.result.value.validationAttempts.length,2);
assert.equal(success.result.value.validationAttempts[0].stats.total,.82);assert.equal(success.result.value.stats.total,.8);
assert.equal(success.result.value.sampleBudget.used,success.sampleCalls.length*20000+40000);
const exhausted=control({failSecond:true});assert.equal(exhausted.verifyCalls.length,2);assert.equal(exhausted.result.error.code,'MJHL_RTP_NOT_REACHED');assert.equal(exhausted.result.value.profile,null);
const reused=control({reuseSeed:true});assert.equal(reused.verifyCalls.length,1);assert.equal(reused.result.value.correctionSkippedReason,'reused_validation_seed');
const noChange=control({unchanged:true});assert.equal(noChange.verifyCalls.length,1);assert.equal(noChange.result.value.correctionSkippedReason,'unchanged_weights');
const noSlope=control({noSlope:true});assert.equal(noSlope.verifyCalls.length,1);assert.equal(noSlope.result.value.correctionSkippedReason,'no_reliable_slope');
const stopped=control({cancelCorrection:true});assert.equal(stopped.verifyCalls.length,1);assert.equal(stopped.result.error.code,'MJHL_RTP_CANCELLED');assert(!stopped.result.value);
const noBudget=control({budget:100});assert.equal(noBudget.result.error.code,'MJHL_RTP_BUDGET');assert.equal(noBudget.sampleCalls.length,0);assert.equal(noBudget.verifyCalls.length,0);
const firstOnlyBudget=control({budget:success.sampleCalls.length*20000+20000});assert.equal(firstOnlyBudget.verifyCalls.length,1);assert.equal(firstOnlyBudget.result.value.correctionSkippedReason,'sample_budget');
const fallbackBudget=control({target:1000,maxFactor:1,budget:100000});assert.equal(fallbackBudget.sampleCalls.length,5);assert.equal(fallbackBudget.verifyCalls.length,0);assert.equal(fallbackBudget.result.error.code,'MJHL_RTP_BUDGET');
console.log('PASS bounded one-correction controller, fresh independent validation, ten-look interval, no same-matrix retry, reliable slope, cancellation and shared sample budget; synthetic controller statistics are not actual game RTP.');
