const fs=require('fs'),path=require('path'),assert=require('assert/strict');
const {chromium}=require('C:/Users/Administrator/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules/playwright');
const root=path.resolve(__dirname,'../..'),out=path.join(root,'.build/prize-pool-ui');fs.mkdirSync(out,{recursive:true});
const read=file=>fs.readFileSync(path.join(root,file),'utf8').replace(/^\uFEFF/,'');
function html(view,script,agent=false){
 const source=read(view),style=source.match(/<style>([\s\S]*?)<\/style>/)[1].replaceAll('@@media','@media');
 let body=source.slice(source.indexOf('<div class="container">'),source.lastIndexOf('@section scripts'));
 body=body.replace(/@if \(can(?:Card|Release|Kill)\)\s*\{\s*(<option[^]*?<\/option>)\s*\}/g,'$1').replaceAll('@today','2026-11-02');
 return `<!doctype html><html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><style>${read('TTY.Web/Content/css/phone.css')}\n${style}</style></head><body><input name="__RequestVerificationToken" value="fixture-token" hidden><div class="header"><div class="header-content"><h1>${agent?'代理流水':'送奖管理'}</h1>${agent?'':'<button id="poolRechargeBtn" class="refresh-btn" style="font-size:13px;padding:0 9px">充值奖池</button>'}</div></div>${body}<script>${read('TTY.Web/Scripts/jquery-2.1.4.min.js')}</script><script>window.MConfig={isRMB:true,exchangeRate:100,page:'${agent?'agentflow':'control'}',playableGames:null,user:{accounts:'operator',priv:0},perms:{isSuper:true}};window.MPagePreset=${agent?'{agentId:"operator"}':'{}'};</script><script>${read('TTY.Web/Scripts/app/phone/phone.core.js')}</script><script>${read(script)}</script></body></html>`;
}
(async()=>{
 const began=Date.now(),browser=await chromium.launch({headless:true,executablePath:'C:/Program Files/Google/Chrome/Application/chrome.exe'});
 let checks=0;
 try{
 const page=await browser.newPage({viewport:{width:390,height:1000}});page.setDefaultTimeout(5000);const errors=[],requests=[];
 page.on('pageerror',e=>errors.push(e.message));
 const wallet={Balance:324,Diamonds:100};let recordStatus=0,rejectRemoval=false;
 await page.route('http://mth-preview.test/**',async route=>{
  const u=new URL(route.request().url()),form=Object.fromEntries(new URLSearchParams(route.request().postData()||''));
  if(u.pathname==='/')return route.fulfill({contentType:'text/html',body:html('TTY.Web/Areas/Mobile/Views/Home/Control.cshtml','TTY.Web/Scripts/app/phone/phone.control.js')});
  if(u.pathname==='/flow')return route.fulfill({contentType:'text/html',body:html('TTY.Web/Areas/Mobile/Views/Home/AgentFlow.cshtml','TTY.Web/Scripts/app/phone/phone.agentflow.js',true)});
  requests.push({url:u.pathname,form});let data={code:1,content:'操作成功',datas:[]};
  if(u.pathname.endsWith('/Wallet'))data.datas={...wallet};
  if(u.pathname.endsWith('/Player'))data=form.ID==='125847'?{code:1,datas:{Player:{ID:'125847',INHALL:true,TodayWinLoss:128.25,Profit:-356.5},CurrentBetDiamonds:5}}:{code:0,content:'未查询到该玩家'};
  if(u.pathname.endsWith('/CardQuote'))data={code:1,datas:{Quote:{BetDiamonds:5,Multiplier:65,RequiredDiamonds:325,Estimated:false},Wallet:{...wallet}}};
  if(u.pathname.endsWith('/Records'))data={total:2,sentDiamonds:325,rows:[{ID:1,UserID:'125847',ControlMode:6,CardAction:5,CardValue:7,Status:2,GameName:'大字版',TableId:15,ActualCardType:'小四梅',AwardDiamonds:325,AwardTime:'2026-11-02T14:10:00',CreatedTime:'2026-11-02T14:00:00'},{ID:2,UserID:'125848',ControlMode:5,CardAction:0,Status:recordStatus,CreatedTime:'2026-11-02T15:00:00'}]};
  if(u.pathname.endsWith('/RemoveRecord')){if(rejectRemoval)data={code:0,content:'该送奖记录已变化，请刷新后重试！'};else{recordStatus=1;data={code:1,content:'移除成功'};}}
  if(u.pathname.endsWith('/Transfer')){const n=Number(form.Amount);if(form.Withdraw==='1'){wallet.Balance-=n;wallet.Diamonds+=n;}else{wallet.Balance+=n;wallet.Diamonds-=n;}data.content=form.Withdraw==='1'?'奖池提取成功':'奖池充值成功';}
  if(u.pathname.endsWith('/GetAgencyDetail'))data={code:1,datas:{ID:'operator',COINS:100,PrizePoolBalance:324}};
  if(u.pathname.endsWith('/Ledger'))data={total:1,balance:324,summary:{Recharge:100,Withdrawal:-20,Sent:325},rows:[{ID:1,Kind:3,ChangeDiamonds:-325,BalanceAfter:324,GameName:'大字版',UserID:'125847',RecTime:'2026-11-02T14:00:00'}]};
  return route.fulfill({contentType:'application/json',body:JSON.stringify(data)});
 });
 await page.goto('http://mth-preview.test/');await page.waitForFunction(()=>document.querySelector('#poolBalance').textContent==='324');
 await page.locator('#ctrlAccount').fill('125847');await page.locator('#queryBtn').click();await page.waitForFunction(()=>document.querySelector('#stBet').textContent==='5');
 assert.equal(await page.locator('#stToday').innerText(),'+128.25');checks++;
 assert.equal(await page.locator('#stTotal').innerText(),'-356.5');checks++;
 await page.locator('.upsel-trigger').click();await page.locator('.upsel-item[data-v="7"]').click();
 await page.locator('#applyBtn').click();await page.getByText('奖池余额不足，请充值奖池',{exact:true}).waitFor();checks++;
 assert.equal(requests.filter(r=>r.url.endsWith('/ApplyTotalControl')).length,0);checks++;
 await page.locator('.modal-overlay.show .modal-btn.confirm').click();
 wallet.Balance=325;await page.locator('#controlRefresh').click();await page.waitForFunction(()=>document.querySelector('#poolBalance').textContent==='325');
 await page.locator('#applyBtn').click();await page.getByText(/本次送奖需 325钻/).waitFor();checks++;
 await page.locator('.modal-overlay.show .modal-btn').first().click();
 await page.locator('#ctrlMode').selectOption('5');assert.equal(await page.locator('#rowGold').isVisible(),true);assert.equal(await page.locator('#rowCardAction').isVisible(),false);checks+=2;
 await page.locator('#ctrlMode').selectOption('4');assert.equal(await page.locator('#rowGold').isVisible(),true);checks++;
 await page.locator('#ctrlMode').selectOption('6');
 for(const width of [320,390,768]){
  await page.setViewportSize({width,height:1000});
  assert.equal(await page.evaluate(()=>document.documentElement.scrollWidth>innerWidth),false);checks++;
  const bounds=await page.locator('#rowCardValue').evaluate(e=>{const r=e.getBoundingClientRect(),c=e.querySelector('.upsel-trigger').getBoundingClientRect();return c.right<=r.right+1&&c.width>100;});assert.equal(bounds,true);checks++;
 }
 await page.setViewportSize({width:390,height:1000});
 await page.locator('#poolRechargeBtn').click();await page.locator('.modal-overlay.show #poolAmount').fill('10');await page.locator('.modal-overlay.show .modal-btn.confirm').click();await page.getByText('奖池充值成功',{exact:true}).waitFor();await page.locator('.modal-overlay.show .modal-btn.confirm').click();
 assert.equal(wallet.Balance,335);assert.equal(wallet.Diamonds,90);checks+=2;
 await page.locator('#poolRechargeBtn').click();await page.locator('.modal-overlay.show #poolDirection').selectOption('out');await page.locator('.modal-overlay.show #poolAmount').fill('10');await page.locator('.modal-overlay.show .modal-btn.confirm').click();await page.getByText('奖池提取成功',{exact:true}).waitFor();await page.locator('.modal-overlay.show .modal-btn.confirm').click();
 assert.equal(wallet.Balance,325);assert.equal(wallet.Diamonds,100);checks+=2;
 await page.locator('.upsel-trigger').click();await page.locator('.upsel-item[data-v="7"]').click();
 await page.screenshot({path:path.join(out,'control-390.png'),fullPage:true});
 await page.locator('.history-section').screenshot({path:path.join(out,'control-records-390.png')});
 await page.locator('.control-table-scroll').evaluate(e=>{e.scrollLeft=e.scrollWidth;});assert.ok(await page.locator('.control-table-scroll').evaluate(e=>e.scrollLeft>0));checks++;
 await page.locator('#ctrlAccount').fill('missing');assert.equal(await page.locator('#applyBtn').isDisabled(),true);checks++;
 assert.equal(await page.locator('.record-remove-btn').count(),1);checks++;
 assert.equal(await page.locator('#controlRows tr').first().locator('button').count(),0);checks++;
 assert.equal(await page.locator('.record-remove-btn').evaluate(e=>getComputedStyle(e).backgroundColor),'rgb(255, 59, 48)');checks++;
 await page.locator('.record-remove-btn').click();await page.locator('.modal-overlay.show .modal-btn').first().click();
 assert.equal(requests.filter(r=>r.url.endsWith('/RemoveRecord')).length,0);checks++;
 rejectRemoval=true;
 await page.locator('.record-remove-btn').click();await page.locator('.modal-overlay.show .modal-btn.confirm').click();
 await page.getByText('该送奖记录已变化，请刷新后重试！',{exact:true}).waitFor();await page.locator('.modal-overlay.show .modal-btn.confirm').click();
 await page.locator('.record-remove-btn:enabled').waitFor();assert.equal(recordStatus,0);checks++;
 rejectRemoval=false;
 await page.locator('.record-remove-btn').click();await page.locator('.modal-overlay.show .modal-btn.confirm').click();
 await page.getByText('移除成功',{exact:true}).waitFor();await page.locator('.modal-overlay.show .modal-btn.confirm').click();
 await page.waitForFunction(()=>document.querySelectorAll('.record-remove-btn').length===0);checks++;
 const removal=requests.filter(r=>r.url.endsWith('/RemoveRecord')).at(-1);
 assert.equal(removal.form.ControlId,'2');assert.equal(removal.form.ID,'125848');assert.equal(removal.form.Mode,'5');checks+=3;
 assert.equal(removal.form.__RequestVerificationToken,'fixture-token');checks++;
 await page.goto('http://mth-preview.test/flow');await page.waitForFunction(()=>document.querySelector('#poolSentTotal').textContent==='325');
 assert.equal(await page.locator('#poolWithdrawTotal').innerText(),'-20');checks++;
 await page.locator('#poolQueryType').selectOption('player');await page.locator('#poolPlayer').fill('125847');await page.locator('#filterBtn').click();
 await page.waitForFunction(()=>document.querySelector('#flowTableBody').textContent.includes('125847'));
 assert.ok(requests.some(r=>r.url.endsWith('/Ledger')&&r.form.PlayerID==='125847'));checks++;
 for(const width of [320,390,768]){
  await page.setViewportSize({width,height:1000});
  assert.equal(await page.evaluate(()=>document.documentElement.scrollWidth>innerWidth),false);checks++;
  assert.equal(await page.locator('.pool-date-filter').evaluate(e=>{const a=e.querySelector('input').getBoundingClientRect(),b=e.querySelector('button').getBoundingClientRect();return Math.abs(a.top-b.top)<2;}),true);checks++;
 }
 await page.setViewportSize({width:390,height:1000});
 await page.screenshot({path:path.join(out,'ledger-390.png'),fullPage:true});
 assert.deepEqual(errors,[]);checks++;
 fs.writeFileSync(path.join(out,'result.json'),JSON.stringify({checks,elapsedMs:Date.now()-began,requests},null,2));
 console.log(`PASS ${checks} real Chromium layout/quote/transfer/history checks in ${Date.now()-began}ms`);
 }finally{await browser.close();}
})().catch(e=>{console.error(e);process.exitCode=1;});
