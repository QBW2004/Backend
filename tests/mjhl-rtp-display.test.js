'use strict';
// 直接执行后台实际格式化函数，目标数值不得冒充计算结果。
const fs = require('fs'), path = require('path'), vm = require('vm'), assert = require('assert');
const page = fs.readFileSync(path.join(__dirname, '../TTY.Web/Areas/Game/Views/GameConfig/ConfigEditor.cshtml'), 'utf8');
const start = page.indexOf('    function gcMjhlRtpValid('), end = page.indexOf('    function gcMjhlSavedRtp(', start);
assert(start >= 0 && end > start);
const scope = { targetRtp:97 }; vm.createContext(scope); vm.runInContext(page.slice(start,end),scope);
const stats = {total:0.96588971,half95:0.01504181,count:5000000,targetRtp:97};
const text = scope.gcMjhlRtpText(stats,false);
assert(text.includes('96.59%') && !text.includes('97.00%'));
assert.equal(text,'计算 RTP：96.59%（误差约 ±1.50 个百分点）');
assert(!text.includes('范围') && !text.includes('完整回合'));
assert(scope.gcMjhlRtpText({total:12.5,half95:.1,count:1000},false).includes('1250.00%'));
assert(scope.gcMjhlRtpText({total:0,half95:0,count:0},true).includes('精确值'));
assert(scope.gcMjhlRtpText({total:0,half95:0,count:1000},false).includes('误差暂无法确定'));
assert(scope.gcMjhlRtpText({total:.97,half95:0,count:1000},false).includes('误差暂无法确定'));
assert(scope.gcMjhlRtpText({total:.97,half95:.000001,count:1000},false).includes('误差小于 0.01'));
for (const invalid of [null,{}, {total:NaN,half95:0,count:10},{total:.97,half95:-1,count:10},{total:.97,half95:0,count:0}]) assert(!scope.gcMjhlRtpValid(invalid,false));
assert(!scope.gcMjhlRtpValid(stats,true), 'exact claim cannot replace a nonzero estimate by zero');
assert(scope.gcMjhlRtpText({...stats,historical:true},false).includes('上次计算'));
for (const name of process.argv.slice(2)) {
    const record=JSON.parse(fs.readFileSync(path.resolve(name),'utf8')), result=record.result;
    assert(!record.error && result && result.success && scope.gcMjhlRtpValid(result.stats,result.exact));
    const actual=scope.gcMjhlRtpText(result.stats,result.exact);
    assert(actual.includes((result.stats.total*100).toFixed(2)+'%'));
    console.log(path.basename(name)+': '+actual);
}
console.log('PASS actual RTP display: measured value with concise error, zero/unknown/tiny error boundaries, historical result, invalid result rejection');
