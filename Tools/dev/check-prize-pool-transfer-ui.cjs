// 手机端奖池充值弹窗：只能数字 + 充值（蓝）/提取（红）两个按钮（2026-11-06）
// 真实 Control.cshtml 样式/结构 + 真实 phone.core.js / phone.control.js，HTTP 接口为本地模拟，不连任何后台或数据库。
// 运行：node Tools/dev/check-prize-pool-transfer-ui.cjs   截图输出 .build/prize-pool-ui/pool-buttons-*.png
const fs=require('fs'),path=require('path'),assert=require('assert/strict');
const {chromium}=require('C:/Users/Administrator/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules/playwright');
const root=path.resolve(__dirname,'../..'),out=path.join(root,'.build/prize-pool-ui');fs.mkdirSync(out,{recursive:true});
const read=file=>fs.readFileSync(path.join(root,file),'utf8').replace(/^\uFEFF/,'');
function html(){
 const source=read('TTY.Web/Areas/Mobile/Views/Home/Control.cshtml'),style=source.match(/<style>([\s\S]*?)<\/style>/)[1].replaceAll('@@media','@media');
 let body=source.slice(source.indexOf('<div class="container">'),source.lastIndexOf('@section scripts'));
 body=body.replace(/@if \(can(?:Card|Release|Kill)\)\s*\{\s*(<option[^]*?<\/option>)\s*\}/g,'$1').replaceAll('@if (showPool) {','').replaceAll('@today','2026-11-06');
 return `<!doctype html><html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><style>${read('TTY.Web/Content/css/phone.css')}\n${style}</style></head><body><input name="__RequestVerificationToken" value="fixture-token" hidden><div class="header"><div class="header-content"><h1>送奖管理</h1><button id="poolRechargeBtn" class="refresh-btn" style="font-size:13px;padding:0 9px">充值奖池</button></div></div>${body}<script>${read('TTY.Web/Scripts/jquery-2.1.4.min.js')}</script><script>window.MConfig={isRMB:true,exchangeRate:100,page:'control',playableGames:null,user:{accounts:'operator',priv:0},perms:{isSuper:true}};window.MPagePreset={};</script><script>${read('TTY.Web/Scripts/app/phone/phone.core.js')}</script><script>${read('TTY.Web/Scripts/app/phone/phone.control.js')}</script></body></html>`;
}
(async()=>{
 const began=Date.now(),browser=await chromium.launch({headless:true,executablePath:'C:/Program Files/Google/Chrome/Application/chrome.exe'});
 let checks=0;
 try{
  const page=await browser.newPage({viewport:{width:390,height:844},hasTouch:true,isMobile:true});page.setDefaultTimeout(5000);
  const errors=[],transfers=[];page.on('pageerror',e=>errors.push(e.message));
  // 模拟服务端：与 B_PrizePool.Transfer 同口径——不足整笔拒绝、不截断；serverPool 可单独设置模拟前端余额已过期
  const wallet={Balance:100,Diamonds:50};let serverPool=null;
  await page.route('http://mth-preview.test/**',async route=>{
   const u=new URL(route.request().url()),form=Object.fromEntries(new URLSearchParams(route.request().postData()||''));
   if(u.pathname==='/')return route.fulfill({contentType:'text/html',body:html()});
   let data={code:1,content:'操作成功',datas:[]};
   if(u.pathname.endsWith('/Wallet'))data.datas={...wallet};
   if(u.pathname.endsWith('/Records'))data={total:0,sentDiamonds:0,rows:[]};
   if(u.pathname.endsWith('/Transfer')){
    transfers.push(form);const n=Number(form.Amount),w=form.Withdraw==='1',pool=serverPool===null?wallet.Balance:serverPool;
    if(!(n>0))data={code:0,content:'充值/提取金额必须为正整数钻！'};
    else if(w&&pool<n)data={code:0,content:'奖池余额不足，当前奖池 '+pool+' 钻，无法提取 '+n+' 钻！'};
    else if(!w&&wallet.Diamonds<n)data={code:0,content:'我的钻石不足，当前 '+wallet.Diamonds+' 钻，无法充值 '+n+' 钻！'};
    else{wallet.Balance+=w?-n:n;wallet.Diamonds+=w?n:-n;data.content=w?'奖池提取成功':'奖池充值成功';}
   }
   return route.fulfill({contentType:'application/json',body:JSON.stringify(data)});
  });
  const ok=page.locator('.modal-overlay.show .modal-btn.confirm'),amt=page.locator('.modal-overlay.show #poolAmount'),inBtn=page.locator('.modal-overlay.show .modal-btn.pool-in-btn'),outBtn=page.locator('.modal-overlay.show .modal-btn.pool-out-btn');
  const balanceIs=v=>page.waitForFunction(v=>document.querySelector('#poolBalance').textContent===v,v);
  const open=async()=>{await page.locator('#poolRechargeBtn').click();await amt.waitFor();};
  await page.goto('http://mth-preview.test/');await balanceIs('100');

  // 1) 布局：只能数字的框；底部“充值”蓝、“提取”红，并排等宽且有间隙
  await open();
  assert.deepEqual([await amt.getAttribute('type'),await amt.getAttribute('inputmode'),await amt.getAttribute('pattern')],['text','numeric','[0-9]*']);checks++;
  assert.equal(await page.locator('.modal-overlay.show #poolSignBtn').count(),0);checks++;
  assert.deepEqual([await inBtn.innerText(),await outBtn.innerText()],['充值','提取']);checks++;
  const st=await page.locator('.modal-overlay.show .modal-footer').evaluate(f=>{const [x,y]=f.querySelectorAll('.modal-btn'),a=x.getBoundingClientRect(),b=y.getBoundingClientRect(),c=e=>getComputedStyle(e).backgroundColor;return {inBg:c(x),outBg:c(y),inC:getComputedStyle(x).color,outC:getComputedStyle(y).color,gap:b.left-a.right,sameW:Math.abs(a.width-b.width)<1,sameRow:Math.abs(a.top-b.top)<1};});
  assert.deepEqual([st.inBg,st.outBg,st.inC,st.outC],['rgb(0, 122, 255)','rgb(255, 59, 48)','rgb(255, 255, 255)','rgb(255, 255, 255)']);checks++;
  assert.ok(st.gap>=11&&st.sameW&&st.sameRow,JSON.stringify(st));checks++;
  // 只能数字：负号、字母、小数点被去掉，全角数字转半角
  await amt.tap();await page.keyboard.type('-3a0.');assert.equal(await amt.inputValue(),'30');checks++;
  await amt.fill('５'); await amt.dispatchEvent('input');assert.equal(await amt.inputValue(),'5');checks++;
  await amt.fill('30');await amt.dispatchEvent('input');
  await page.screenshot({path:path.join(out,'pool-buttons-390.png')});

  // 2) 提取：奖池 → 我的钻
  await outBtn.tap();await page.getByText('已从奖池提取 30 钻到我的钻石',{exact:true}).waitFor();checks++;
  assert.deepEqual([transfers.at(-1).Amount,transfers.at(-1).Withdraw],['30','1']);checks++;
  await ok.click();await balanceIs('70');assert.equal(await page.locator('#myDiamonds').innerText(),'80');checks+=2;

  // 3) 充值：我的钻 → 奖池
  await open();await amt.fill('15');await inBtn.click();await page.getByText('奖池充值成功',{exact:true}).waitFor();await ok.click();
  await balanceIs('85');assert.equal(await page.locator('#myDiamonds').innerText(),'65');checks+=2;
  assert.deepEqual([transfers.at(-1).Amount,transfers.at(-1).Withdraw],['15','0']);checks++;

  // 4) 前端校验：提取超奖池、充值超我的钻、空/0 均不发请求
  await open();const before=transfers.length;
  await amt.fill('86');await outBtn.click();await page.getByText('奖池余额不足，当前奖池 85 钻',{exact:true}).waitFor();checks++;
  await amt.fill('66');await inBtn.click();await page.getByText('我的钻石不足，当前 65 钻',{exact:true}).waitFor();checks++;
  await amt.fill('');await inBtn.click();await page.getByText('请输入大于 0 的整数钻数',{exact:true}).waitFor();checks++;
  await amt.fill('0');await outBtn.click();await page.getByText('请输入大于 0 的整数钻数',{exact:true}).waitFor();checks++;
  assert.equal(transfers.length,before);checks++;
  await page.screenshot({path:path.join(out,'pool-buttons-insufficient-390.png')});

  // 5) 前端余额过期，服务端按真实奖池拒绝：显示服务端原文，余额不变（不截断成扣到0）
  serverPool=10;await amt.fill('20');await outBtn.click();
  await page.getByText('奖池余额不足，当前奖池 10 钻，无法提取 20 钻！',{exact:true}).waitFor();checks++;
  assert.equal(wallet.Balance,85);checks++;
  await ok.click();serverPool=null;await balanceIs('85');

  // 6) 点遮罩关闭不发请求；320 宽度不溢出、两按钮仍并排
  await open();const n=transfers.length;await page.mouse.click(5,5);await page.waitForTimeout(200);
  assert.equal(await page.locator('.modal-overlay.show').count(),0);assert.equal(transfers.length,n);checks+=2;
  await page.setViewportSize({width:320,height:700});await open();await amt.fill('1');
  assert.equal(await page.evaluate(()=>document.documentElement.scrollWidth>innerWidth),false);checks++;
  assert.ok(await page.locator('.modal-overlay.show .modal-footer').evaluate(f=>{const [x,y]=f.querySelectorAll('.modal-btn');return Math.abs(x.getBoundingClientRect().top-y.getBoundingClientRect().top)<1;}));checks++;
  await page.screenshot({path:path.join(out,'pool-buttons-320.png')});

  assert.deepEqual(errors,[]);checks++;
  console.log(`PASS ${checks} pool recharge/withdraw UI checks in ${((Date.now()-began)/1000).toFixed(2)}s`);
 }finally{await browser.close();}
})().catch(e=>{console.error(e);process.exit(1);});
