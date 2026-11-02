'use strict';

// 直接执行后台实际开奖引擎与 worker；不读取数据库、不发送网络请求。
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');
const scripts = path.resolve(__dirname, '../TTY.Web/Scripts/app');
const E = require(path.join(scripts, 'mjhl.engine.js'));
const S = require(path.join(scripts, 'mjhl.agent.simulation.js'));
const clone = value => JSON.parse(JSON.stringify(value));
const workerSource = fs.readFileSync(path.join(scripts, 'mjhl.agent.rtp.worker.js'), 'utf8');

function workerSample(job) {
    return new Promise((resolve, reject) => {
        const self = { postMessage(value) {
            if (value.error) reject(new Error(value.error));
            else if (value.result) resolve(value.result);
        } };
        const scope = { self, MjhlEngine:E, MjhlRtpPool:{create:()=>({sample:E.sample,dispose:()=>{}})}, Date, Error, importScripts(name) {
            assert.match(name, /^mjhl\.engine\.js\?/);
        } };
        vm.createContext(scope); vm.runInContext(workerSource, scope);
        self.onmessage({data:job});
    });
}

(async () => {
    const engineDefault = E.defaults();
    const config = { gameId:54, targetRtp:97, scatterEnabled:true, freeRetrigger:true,
        goldChance:engineDefault.goldChance, weights:clone(engineDefault.weights),
        bets:{min:.4,max:60,chips:[.4,.8,2,60],entry:.8,scorePerCoin:100} };
    S.validate(config);
    const original = JSON.stringify(config);
    const weighted = S.profile(config);
    const changedTarget = clone(config); changedTarget.targetRtp=1000;
    assert.deepEqual(S.profile(changedTarget), weighted, 'the target is not itself an outcome probability');

    const controls = clone(config);
    controls.control = {type:19,value:6,number:5,totalNumber:5};
    controls.kill = {type:27,value:11,targetCoins:1000,consumedCoins:300};
    controls.history = [{manual_control:true,bet:1,win:999999999}];
    assert.deepEqual(S.profile(controls), weighted, 'normal profile contains only configured game rules');
    const noRetrigger = clone(config); noRetrigger.freeRetrigger=false;
    const effectiveFreeOff = S.profile(noRetrigger);
    assert.deepEqual(effectiveFreeOff.weights.n[10], weighted.weights.n[10]);
    assert.deepEqual(effectiveFreeOff.weights.f[10], [0,0,0,0,0]);
    const noNatural = clone(config); noNatural.scatterEnabled=false;
    const effectiveAllOff = S.profile(noNatural);
    assert.deepEqual(effectiveAllOff.weights.n[10], [0,0,0,0,0]);
    assert.deepEqual(effectiveAllOff.weights.f[10], [0,0,0,0,0]);

    // 实际 worker 固定使用 100000 个完整付费回合，包含自然免费和连消。
    const baseline = await workerSample({type:'sample',profile:clone(weighted)});
    const withControlMetadata = await workerSample({type:'sample',profile:S.profile(controls),
        manual_control:true,ctrl_type:27,ctrl_value:11,target:1000,
        recordedRtp:999999,history:controls.history});
    assert.equal(baseline.count,100000);
    assert.deepEqual(withControlMetadata,baseline, 'control state, manual histories and target cannot change natural RTP');
    assert.equal(JSON.stringify(config),original, 'sampling does not rewrite the source configuration');
    assert.deepEqual(controls.weights,config.weights, 'control metadata cannot alter agent weights');

    const view=fs.readFileSync(path.resolve(__dirname,'../TTY.Web/Areas/Game/Views/GameConfig/ConfigEditor.cshtml'),'utf8');
    const start=view.indexOf('    function gcMjhlRtpValid('), end=view.indexOf('    function gcMjhlSavedRtp(',start);
    assert(start>=0 && end>start);
    const display={};vm.createContext(display);vm.runInContext(view.slice(start,end),display);
    const rendered=display.gcMjhlRtpText(baseline,false);
    assert(rendered.includes((baseline.total*100).toFixed(2)+'%'));
    assert(rendered.includes('误差约 ±') && !rendered.includes('完整回合'));
    assert(!rendered.includes('999999'));
    console.log('PASS actual worker: 2 x 100000 full rounds, identical natural RTP with gift/kill/history metadata; switches and display use effective configured rules');
    console.log(JSON.stringify({count:baseline.count,actualPercent:baseline.total*100,half95Percent:baseline.half95*100}));
})().catch(error=>{console.error(error);process.exitCode=1;});
