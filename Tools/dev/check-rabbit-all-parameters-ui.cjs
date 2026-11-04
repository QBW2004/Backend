// Verify the real editor submits every field from the actual Controller/MySQL fixture.
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict'),{spawn}=require('node:child_process');
const root=path.resolve(__dirname,'../..'),fixture=JSON.parse(fs.readFileSync(path.join(root,'.build/rabbit-rules-validation/all-parameters.json'),'utf8'));
const {chromium}=require('C:/Users/Administrator/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules/playwright');
const numbers={rbSmallFour:'smallFourMultiplier',rbReveal:'specialRules.authentic.revealTimeoutSeconds',rbAuthBase:'specialRules.authentic.baseMultiplier',rbFiveBase:'specialRules.five.baseMultiplier',rbFiveSuccess:'specialRules.five.successMultiplier',rbFiveMiss:'specialRules.five.missMultiplier',rbBurn:'specialRules.streak.burnRounds',rbContribution:'specialRules.streak.poolContributionBasisPoints',rbInitPool:'specialRules.streak.initialPool',rbPassTarget:'passTarget',rbPassBonus:'passBonus',rbExplodeTarget:'explodeTarget',rbExplodeBonus:'explodeBonus'};
const flags={rbAuthOn:'specialRules.authentic.enabled',rbFiveOn:'specialRules.five.enabled',rbStreakOn:'specialRules.streak.enabled',rbGuaranteeLast:'specialRules.streak.guaranteeLastRound',rbBlockHigher:'specialRules.streak.blockHigherPrizes',rbPassOn:'specialRules.settlement.passEnabled',rbExplodeOn:'specialRules.settlement.explodeEnabled'};
const chances={rbFiveForce:'specialRules.five.forcedSuccessChance',rbStart:'specialRules.streak.startChance',rbContinue:'specialRules.streak.continueChance',rbExpired:'specialRules.streak.expiredChance',rbSecondJoker:'specialRules.streak.secondJokerChance',rbJokerFirst:'specialRules.streak.jokerFirstChance'};
const at=(o,p)=>p.split('.').reduce((o,k)=>o[k],o);
let checks=0;const check=(v,name)=>{assert.ok(v,name);checks++;};
(async()=>{
 const clock=Date.now(),server=spawn(process.execPath,[path.join(__dirname,'preview-rabbit-config.cjs'),'--port=0','--no-auto'],{cwd:root,windowsHide:true,stdio:['ignore','pipe','pipe']});
 let browser;
 try{
  const base=await new Promise((resolve,reject)=>{const t=setTimeout(()=>reject(new Error('Preview startup timed out')),7000);server.stdout.on('data',d=>{const m=d.toString().match(/Preview: (http:\/\/127\.0\.0\.1:\d+\/)/);if(m){clearTimeout(t);resolve(m[1]);}});server.once('error',reject);server.once('exit',c=>reject(new Error('Preview stopped: '+c)));});
  browser=await chromium.launch({headless:true,executablePath:'C:/Program Files/Google/Chrome/Application/chrome.exe'});
  const page=await browser.newPage({viewport:{width:1440,height:1100}}),errors=[],captures=[];page.on('pageerror',e=>errors.push(e.message));
  await page.route('**/GameConfig/GetTableConfig',r=>r.fulfill({json:{code:1,datas:fixture.tables.map(t=>t.table)}}));
  await page.route('**/GameConfig/GetRabbitConfig',r=>{const p=new URLSearchParams(r.request().postData()),index=Number(p.get('tableIndex'));r.fulfill({json:{code:1,tableIndex:index,saved:index>=0,source:'table',config:fixture.tables[Math.max(0,index)].rules}});});
  await page.route('**/GameConfig/SaveTableConfig',r=>{captures.push(Object.fromEntries(new URLSearchParams(r.request().postData())));r.fulfill({json:{code:1,datas:true}});});
  await page.goto(base+'tables');await page.selectOption('#gcTypeSel','1');await page.selectOption('#gcGameSel','55');await page.waitForFunction(()=>document.querySelector('#gcGameId').value==='55'&&window.rabbitConfigIsReady());
  // Only one independent row in the editor is exercised at a time; source fixture tables differ in every category.
  for(const [i,fixtureRow] of fixture.tables.entries()){
   await page.evaluate(id=>gcSelectTableById(id),fixtureRow.id);await page.waitForFunction(id=>document.querySelector('#gcId').value===String(id)&&!document.querySelector('#gcSave').disabled,fixtureRow.id);
   for(const[id,p]of Object.entries(numbers))check(await page.locator('#'+id).inputValue()===String(at(fixtureRow.rules,p)),'numeric editor load '+i+'/'+id);
   for(const[id,p]of Object.entries(flags))check(await page.locator('#'+id).isChecked()===at(fixtureRow.rules,p),'flag editor load '+i+'/'+id);
   for(const[id,p]of Object.entries(chances))for(const[s,k]of [['N','numerator'],['D','denominator']])check(await page.locator('#'+id+s).inputValue()===String(at(fixtureRow.rules,p)[k]),'chance editor load '+i+'/'+id+s);
   for(const[id,v]of Object.entries({gcTableName:fixtureRow.form.TableName,gcMinBet:fixtureRow.form.MinBet,gcMaxBet:fixtureRow.form.MaxBet,gcCoinSc:fixtureRow.form.COIN_SC,gcCoinNeed:fixtureRow.form.COIN_NEED,gcExCoin:fixtureRow.form.EX_COIN,gcGameMo:fixtureRow.form.Game_Mo,gcScoreSwitch:fixtureRow.form.scoreSwitch,gcCardDif:fixtureRow.form.CardDIF,gcHypeType:fixtureRow.form.HYPE_TYPE,gcIdleSec:fixtureRow.form.IdleFireTimeoutSec}))check(await page.locator('#'+id).inputValue()===v,'table editor load '+i+'/'+id);
   const response=page.waitForResponse(r=>r.url().endsWith('/GetTableConfig'));await page.click('#gcSave');await response;await page.waitForFunction(()=>!window.GC_LABA_SAVING);
   const posted=captures.at(-1);check(posted.ID===String(fixtureRow.id),'submit targets exact table '+i);
   for(const[name,v]of Object.entries(fixtureRow.form)){
    if(name==='RabbitConfigJson'||name==='MaxSeats'||name==='hp0'||name==='he0')continue;
    check(posted[name]===v,'all named fields submitted '+i+'/'+name);
   }
   const actual=JSON.parse(posted.RabbitConfigJson);assert.deepEqual(actual,fixtureRow.rules,'all gameplay fields and hidden compatibility fields submitted '+i);checks++;
   check(await page.locator('#rbKeepMax,#rbKeepMinHands').count()===0,'keep module hidden '+i);
  }
  // Edit every rule control on a real page; no programmatic collect/config injection.
  await page.evaluate(()=>gcSelectTableById(55000));await page.waitForFunction(()=>document.querySelector('#gcId').value==='55000'&&!document.querySelector('#gcSave').disabled);
  const expected=structuredClone(fixture.tables[0].rules);
  const set=(p,v)=>{const a=p.split('.'),k=a.pop();a.reduce((o,k)=>o[k],expected)[k]=v;};
  for(const[id,p]of Object.entries(numbers)){const value=at(expected,p)+1;await page.fill('#'+id,String(value));set(p,value);}
  expected.specialRules.five.revealTimeoutSeconds=expected.specialRules.authentic.revealTimeoutSeconds;
  for(const[id,p]of Object.entries(flags)){await page.locator('#'+id).setChecked(false);set(p,false);}
  for(const[id,p]of Object.entries(chances)){const n=at(expected,p).numerator-1;await page.fill('#'+id+'N',String(n));set(p+'.numerator',n);}
  await page.fill('#rbFiveWinWeight','3');await page.fill('#rbFiveMissWeight','8');expected.specialRules.five.successChance={numerator:3,denominator:11};
  await page.locator('#rbAuthTable .rb-ww').first().fill('9');expected.specialRules.authentic.multipliers.weights[0]=9;
  await page.locator('#rbStreakTable .rb-ww').last().fill('11');expected.specialRules.streak.awardCounts.weights[2]=11;
  let response=page.waitForResponse(r=>r.url().endsWith('/GetTableConfig'));await page.click('#gcSave');await response;await page.waitForFunction(()=>!window.GC_LABA_SAVING);
  assert.deepEqual(JSON.parse(captures.at(-1).RabbitConfigJson),expected,'editing all numeric/chance/flag/weight controls submits correct values');checks++;
  check(errors.length===0,'no browser script errors');
  fs.writeFileSync(path.join(root,'.build/rabbit-redesign-20261103/all-parameters-browser.json'),JSON.stringify({checks,elapsedMs:Date.now()-clock,errors},null,2));
  console.log(`PASS ${checks} complete-field Chromium checks in ${Date.now()-clock}ms`);
 }finally{if(browser)await browser.close();server.kill();}
})().catch(e=>{console.error(e);process.exitCode=1;});
