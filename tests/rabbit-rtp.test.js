const assert=require('node:assert/strict'),fs=require('node:fs');
const{weighted,chance,model,percentUnits,splitWeights,weightsFromPercentages,percentagesFromWeights}=require('../TTY.Web/Scripts/app/game.rabbit-math.js');
const raw=fs.readFileSync(require('node:path').join(__dirname,'../TTY.Web/Models/RabbitConfig.cs'),'utf8');
const defaults=JSON.parse(raw.match(/DefaultJson = @"(.*?)";/)[1].replaceAll('""','"'));
let checks=0;const start=Date.now(),copy=()=>JSON.parse(JSON.stringify(defaults));
function equal(a,b){assert.ok(Math.abs(a-b)<1e-10,`${a} != ${b}`);checks++;}
let m=model(copy());equal(m.small,50);equal(m.authentic,120);equal(m.five,1000/3);equal(m.auth.average,1.5);
equal(m.streak.average,996/168);equal(weighted({values:[1,14],weights:[0,7]},14).average,14);equal(chance({numerator:1,denominator:3}),1/3);
let c=copy();c.specialRules.authentic.enabled=false;c.specialRules.five.enabled=false;m=model(c);equal(m.authentic,80);equal(m.five,250);
c=copy();c.smallFourMultiplier=60;c.specialRules.authentic.baseMultiplier=100;c.specialRules.five.successChance={numerator:2,denominator:5};m=model(c);equal(m.small,60);equal(m.authentic,150);equal(m.five,350);
c.specialRules.five.forcedSuccessChance={numerator:1,denominator:1};equal(model(c).five,350);
c.specialRules.streak.poolContributionBasisPoints=10000;c.specialRules.streak.initialPool=123456;equal(model(c).five,350);
for(const [v,w,max]of[[[],[],14],[[1,1],[2,3],14],[[15],[1],14],[[1],[0],14],[[1],[0.1],14],[[1],[-1],14],[[1,2],[2147483647,1],14],[[1,2],[1],14]]){assert.throws(()=>weighted({values:v,weights:w},max));checks++;}
for(const ch of[{numerator:2,denominator:1},{numerator:0,denominator:0},{numerator:1.5,denominator:3},{numerator:-1,denominator:3},{numerator:1,denominator:Infinity}]){assert.throws(()=>chance(ch));checks++;}
assert.deepEqual(splitWeights(1,3),{numerator:1,denominator:4});checks++;
assert.deepEqual(splitWeights(0,5),{numerator:0,denominator:1});checks++;
assert.deepEqual(splitWeights(7,0),{numerator:1,denominator:1});checks++;
assert.deepEqual(weightsFromPercentages(['50','35','15']),[10,7,3]);checks++;
assert.deepEqual(weightsFromPercentages(['33.333333','33.333333','33.333334']),[33333333,33333333,33333334]);checks++;
assert.deepEqual(percentagesFromWeights([1,1,1]),['33.333334','33.333333','33.333333']);checks++;
equal(percentUnits('0.000001'),1);equal(percentUnits('100'),100000000);
for(const input of['-1','100.000001','1.2345678','',Infinity,'NaN']){assert.throws(()=>percentUnits(input));checks++;}
assert.throws(()=>weightsFromPercentages(['50','30','10']));checks++;
assert.throws(()=>splitWeights(0,0));checks++;
console.log(`PASS ${checks} Rabbit RTP checks in ${Date.now()-start}ms`);
