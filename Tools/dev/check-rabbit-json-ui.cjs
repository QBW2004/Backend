// Run check-rabbit-rules.ps1 first: these bodies come from real MVC ExecuteResult calls.
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict'),{spawn}=require('node:child_process');
const {chromium}=require('C:/Users/Administrator/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules/playwright');
const root=path.resolve(__dirname,'../..'),out=path.join(root,'.build/rabbit-rules-validation');
const rabbit=fs.readFileSync(path.join(out,'rabbit-default-response.json'),'utf8');
const phenix=fs.readFileSync(path.join(out,'phenix-stored-response.json'),'utf8');
(async()=>{
 const start=Date.now(),server=spawn(process.execPath,[path.join(__dirname,'preview-rabbit-config.cjs'),'--port=0','--no-auto'],{cwd:root,windowsHide:true});
 let browser,mode='valid';const checks=[],errors=[];
 const check=(name,value)=>{assert.ok(value,name);checks.push(name);};
 try{
  const base=await new Promise((resolve,reject)=>{server.stdout.on('data',b=>{const m=b.toString().match(/http:\/\/127\.0\.0\.1:\d+\//);if(m)resolve(m[0]);});server.on('error',reject);server.on('exit',c=>reject(new Error('preview exited '+c)));});
  browser=await chromium.launch({headless:true,executablePath:'C:/Program Files/Google/Chrome/Application/chrome.exe'});
  const page=await browser.newPage({viewport:{width:1440,height:1050}});page.setDefaultTimeout(5000);page.on('pageerror',e=>errors.push(e.message));
  await page.route('**/GameConfig/GetRabbitConfig',async route=>{
   const scenario=mode;
   if(scenario==='network')return route.abort('connectionfailed');
   if(scenario==='timeout'){await new Promise(r=>setTimeout(r,200));return route.abort().catch(()=>{});}
   if(scenario==='late-failure'){await new Promise(r=>setTimeout(r,150));return route.fulfill({json:{code:0,content:'旧桌请求失败'}});}
   if(scenario==='malformed-json')return route.fulfill({contentType:'application/json',body:'{'});
   const data=JSON.parse(rabbit);
   if(scenario==='array')data.config=[[[]]];
   if(scenario==='null')data.config=null;
   if(scenario==='field')data.config.smallFourMultiplier=0;
   if(scenario==='form-field')data.config.specialRules.five.forcedSuccessChance={numerator:2,denominator:1};
   if(scenario==='backend')return route.fulfill({json:{code:0,content:'规则查询失败'}});
   return route.fulfill({contentType:'application/json',body:scenario==='valid'?rabbit:JSON.stringify(data)});
  });
  await page.route('**/GameConfig/GetPhenixConfig',route=>route.fulfill({contentType:'application/json',body:phenix}));
  await page.goto(base+'tables');await page.selectOption('#gcTypeSel','1');await page.selectOption('#gcGameSel','55');
  await page.waitForFunction(()=>window.rabbitConfigIsReady());
  check('真实MVC回包恢复三项倍率',JSON.stringify(await page.locator('#gcHm7,#gcHm8,#gcHm10').allTextContents())===JSON.stringify(['50.00（规则值）','120.00（规则加权）','333.33（规则加权）']));
  check('真实MVC回包恢复RTP',await page.locator('#rbTableRtp').textContent()==='84.13%');
  const posted=await page.evaluate(()=>JSON.parse(rabbitConfigCollect().RabbitConfigJson));
  check('表单收集保留本桌规则与隐藏参数',posted.smallFourMultiplier===50&&posted.keepMax===3&&posted.specialRules.five.forcedSuccessChance.denominator===4);
  await page.evaluate(()=>$.ajaxPrefilter(options=>{if(options.url.includes('GetRabbitConfig')){window.lastRuleTimeout=options.timeout;if(window.fastTimeout)options.timeout=100;}}));
  for(const scenario of ['array','null','field','form-field','backend','network','malformed-json','timeout']){
   mode=scenario;await page.evaluate(fast=>{window.fastTimeout=fast;rabbitConfigReload();},scenario==='timeout');
   await page.waitForFunction(()=>!document.querySelector('#gcReset').disabled&&document.querySelector('#rbTableStatus').textContent!=='正在读取玩法规则…');
   const failed=await page.evaluate(()=>({ready:rabbitConfigIsReady(),disabled:document.querySelector('#gcSave').disabled,rtp:document.querySelector('#rbTableRtp').textContent,status:document.querySelector('#rbTableStatus').textContent,details:document.querySelector('#rabbitConfigStatus').textContent,timeout:window.lastRuleTimeout}));
   check(scenario+'失败清空RTP、禁止保存并显示原因',!failed.ready&&failed.disabled&&failed.rtp==='—'&&failed.status===failed.details&&failed.status.includes('刷新'));
   check(scenario+'不会伪报载入成功',!failed.details.includes('已载入'));
   if(scenario==='timeout')check('超时有明确提示且正式超时为15秒',failed.timeout===15000&&failed.status.includes('超时'));
   mode='valid';await page.evaluate(()=>{window.fastTimeout=false;rabbitConfigReload();});await page.waitForFunction(()=>rabbitConfigIsReady());
   check(scenario+'刷新后可恢复且没有覆盖原倍率',await page.locator('#rbSmallFour').inputValue()==='50'&&await page.locator('#gcSave').isEnabled()&&await page.locator('#rbTableRtp').textContent()==='84.13%');
  }
  mode='late-failure';const oldResponse=page.waitForResponse(r=>r.url().endsWith('/GetRabbitConfig')&&new URLSearchParams(r.request().postData()).get('tableIndex')==='-1');await page.evaluate(()=>rabbitConfigReload());
  mode='valid';await page.evaluate(()=>gcSelectTableById(55001));await oldResponse;await page.waitForFunction(()=>rabbitConfigIsReady()&&document.querySelector('#gcId').value==='55001');
  check('旧桌失败响应不会覆盖新桌状态',await page.locator('#rbTableStatus').textContent()==='已读取本桌玩法规则 · 修改后实时重算');
  await page.locator('#gcPayoutTable').screenshot({path:path.join(out,'rabbit-json-fixed.png')});
  await page.selectOption('#gcGameSel','5');await page.waitForFunction(()=>GC_TABLES.some(t=>t.id===5000)&&document.querySelector('#gcGameId').value==='5');
  await page.evaluate(()=>gcSelectTableById(5000));await page.waitForFunction(()=>document.querySelector('#pxWeightedPayout').textContent==='832.00 倍');
  check('火凤凰实际MVC回包保留独立档位',JSON.stringify(await page.locator('#pxAuthTable .px-wv').evaluateAll(es=>es.map(e=>e.value)))==='["2","14"]');
  check('浏览器没有未处理异常',errors.length===0);
  fs.writeFileSync(path.join(out,'json-browser-checks.json'),JSON.stringify({checks,errors,elapsedMs:Date.now()-start},null,2));
  console.log(`PASS ${checks.length} MVC-response browser checks in ${Date.now()-start}ms`);
 }finally{await browser?.close();server.kill();}
})().catch(e=>{console.error(e);process.exitCode=1;});
