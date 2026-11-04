const assert = require('node:assert/strict');
const {weighted} = require('../TTY.Web/Scripts/app/game.phenixconfig.js');
const start=Date.now();let checks=0;
const check=(actual,expected)=>{assert.equal(actual,expected);++checks;};
check(weighted([1,2,3],[60,30,10]).average,1.5);
check(weighted([1,2,3],[6,3,1]).average,1.5);
check(weighted([1,14],[0,8]).average,14);
check(weighted([14,1,2],[0,60,40]).average,1.4);
check(weighted([1,14],[2147483646,1]).sum,2147483647);
check(weighted([1,2],[1,3]).probabilities.reduce((a,b)=>a+b,0),1);
for(const [v,w] of [[[],[]],[[1],[0]],[[1,1],[1,2]],[[0],[1]],[[15],[1]],[[1.5],[1]],[[1],[0.5]],[[1],[-1]],[[1],[Infinity]],[[1],[NaN]],[[1,2],[1]],[[1,2],[2147483647,1]]]){
 assert.throws(()=>weighted(v,w));++checks;
}
console.log(`PASS ${checks} weighted RTP checks in ${Date.now()-start}ms`);
