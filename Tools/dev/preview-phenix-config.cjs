/* Local preview uses the real Razor page, JS and CSS with isolated example data. */
const fs=require('node:fs'),path=require('node:path'),http=require('node:http'),assert=require('node:assert/strict');
const root=path.resolve(__dirname,'../..'),web=path.join(root,'TTY.Web'),out=path.join(root,'.build/phenix-redesign-20261103');
fs.mkdirSync(out,{recursive:true});
const read=p=>fs.readFileSync(path.join(web,p),'utf8').replace(/^\uFEFF/,'');
const raw=read('Areas/Game/Views/GameConfig/ConfigEditor.cshtml');
const defaults=JSON.parse(read('Models/PhenixConfig.cs').match(/DefaultJson = @"(.*?)";/)[1].replaceAll('""','"'));
const copy=v=>JSON.parse(JSON.stringify(v));
function render(s){return s.replace(/@\*[\s\S]*?\*@/g,'').replace(/@Url.Action\("([^"]+)"[^)]*\)/g,'/$1').replace(/@Url.Content\("~([^"]*)"(?:\s*\+\s*YYT.Common.ConfigHelper.Get\("WebVer"\))?\)/g,'$1').replace('@Html.Raw(YYT.Web.Models.PhenixConfig.DefaultJson)',JSON.stringify(defaults)).replaceAll('@@','@');}
let body=raw.slice(raw.indexOf('<div class="gc-wrap">')).replace('@Html.AntiForgeryToken()','<input type="hidden" name="__RequestVerificationToken" value="preview-token">');
body=body.replace(/@Html.Partial\("([^"]+)"\)/g,(_,p)=>p==='_PhenixConfig'?read('Areas/Game/Views/GameConfig/'+p+'.cshtml'):'');
const styles=raw.match(/<style>([\s\S]*?)<\/style>/)[1];
const html=render(`<!doctype html><html lang="zh-CN"><head><meta charset="utf-8"><title>火凤凰桌台配置 · 本地预览</title><style>body{font:14px/1.5 "Microsoft YaHei",Arial;margin:0;background:#f5f7fa}.preview-bar{padding:13px 24px;background:#2f4050;color:#d9e4ef;display:flex;justify-content:space-between;font-size:13px}.preview-bar strong{font-size:15px;font-weight:500;color:#fff}.main{max-width:1500px;margin:0 auto}.gc-left{width:210px!important;flex-basis:210px!important}.gc-card-bd{padding:14px 18px!important}${styles}</style><script src="/Scripts/jquery-2.1.4.js"></script><script src="/Scripts/jquery.easyui.min.js"></script><script>window.easyloader={load:function(m,f){f();}};window.loginTimeoutCallback=function(){};</script><script src="/Scripts/app/common.js"></script></head><body><div class="preview-bar"><strong>游戏配置 / 火凤凰 / 桌台配置</strong><span>本地交互预览 · 示例参数 · 保存仅写入内存</span></div><div class="main">${body}</div></body></html>`);
const games=[{id:5,text:'火凤凰',gameType:1,paraType:1},{id:55,text:'大白兔',gameType:1,paraType:1}];
const tables={};
for(const g of games)tables[g.id]=[0,1].map(i=>({id:g.id*1000+i,tableName:`${i+1}号桌台`,minBet:1,maxBet:100,coinSc:100,coinNeed:1,exCoin:100,gameMo:1,scoreSwitch:10,enabled:1,idleFireTimeoutSec:2,cardDif:'3434453555777533',hypeType:0,payoutOn:1,jokerOn:1,jk1:6210,jk2:2200,jk3:0,payout:Object.fromEntries([0,1800,800,300,250,70,20,10,5,2,1,1,0].map((p,i)=>['p'+i,p]))}));
const configs={},captures=[];let delayGet=0,failGet=false,failSave=false;
const server=http.createServer(async(req,res)=>{
 try{
  const url=new URL(req.url,'http://localhost'),route=url.pathname;
  const json=v=>{res.setHeader('Content-Type','application/json;charset=utf-8');res.end(JSON.stringify(v));};
  if(route==='/'){
   res.setHeader('Content-Type','text/html;charset=utf-8');
   const startScript=process.argv.includes('--test')?'':`<script>$(function(){var phase=0;var timer=setInterval(function(){if(!phase&&$('#gcTypeSel option[value="1"]').length){phase=1;$('#gcTypeSel').val('1').trigger('change');}else if(phase===1&&$('#gcGameSel option[value="5"]').length){phase=2;$('#gcGameSel').val('5').trigger('change');}else if(phase===2&&$('#pxAvgPayout').text()==='120.00 倍'){clearInterval(timer);$('#pxRtpSummary')[0].scrollIntoView({block:'start'});}},50);});</script>`;
   res.end(html.replace('</body>',startScript+'</body>'));return;
  }
  let rawBody='';for await(const c of req)rawBody+=c;
  const p=Object.fromEntries(new URLSearchParams(rawBody));
  if(route==='/GetGameList')return json(games);
  if(route==='/GetLineOptions')return json({code:1,datas:{Ready:true,Owned:0,Recycled:0,Lines:[{id:'',text:'公共桌台',count:2}]}});
  if(route==='/GetTableConfig')return json({code:1,datas:tables[p.GAME_ID]||[]});
  if(route==='/GetPhenixConfig'){
   const data=copy(configs[p.tableIndex]||defaults),fail=failGet,delay=delayGet;failGet=false;
   if(delay)await new Promise(r=>setTimeout(r,delay));
   return json(fail?{code:0,content:'模拟载入失败'}:{code:1,config:data});
  }
  if(route==='/SaveTableConfig'){
   captures.push(copy(p));if(failSave){failSave=false;res.writeHead(503);res.end('模拟请求失败');return;}
   const g=Number(p.GAME_ID),isNew=Number(p.ID)<0,i=isNew?tables[g].length:Number(p.ID)%1000;
   if(p.PhenixConfigJson)configs[i]=JSON.parse(p.PhenixConfigJson);
   const row=copy(tables[g][i]||tables[g][0]);Object.assign(row,{id:g*1000+i,tableName:p.TableName,maxBet:Number(p.MaxBet),minBet:Number(p.MinBet)});
   for(let h=0;h<=12;h++){row.payout['p'+h]=Number(p['hp'+h]);row.payout['e'+h]=Number(p['he'+h]??1);}
   tables[g][i]=row;return json({code:1,datas:true,content:'本地预览：已在内存中保存，可重新载入核对'});
  }
  const file=path.resolve(web,'.'+route);
  if(file.startsWith(web+path.sep)&&fs.existsSync(file)&&fs.statSync(file).isFile()){
   res.setHeader('Content-Type',file.endsWith('.css')?'text/css':'application/javascript');res.end(fs.readFileSync(file));return;
  }
  res.writeHead(404);res.end();
 }catch(e){res.writeHead(500);res.end(e.stack);}
});
async function test(){
 const {chromium}=require('C:/Users/Administrator/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules/playwright');
 const start=Date.now(),checks=[],errors=[];
 const browser=await chromium.launch({headless:true,executablePath:'C:/Program Files/Google/Chrome/Application/chrome.exe'});
 const check=(name,value)=>{assert.ok(value,name);checks.push(name);};
 try{
  const page=await browser.newPage({viewport:{width:1440,height:1100}});page.setDefaultTimeout(7000);page.on('pageerror',e=>errors.push(e.message));

  // 2026-11-05 新建流程：新桌点「保存」后弹张数（编辑已有桌不弹）；弹出时输入张数回车
  const clickSave=async(n=1)=>{const isNew=Number(await page.locator('#gcId').inputValue())<0;await page.locator('#gcSave').click();if(!isNew)return;const win=page.locator('#gcNewTableWin');const shown=await win.waitFor({state:'visible',timeout:400}).then(()=>true).catch(()=>false);if(shown){const t=page.locator('#gcNewTableWin .textbox-text:visible').first();await t.fill(String(n));await page.keyboard.press('Enter');}};
  await page.goto(`http://127.0.0.1:${server.address().port}/`);
  await page.selectOption('#gcTypeSel','1');await page.selectOption('#gcGameSel','5');
  await page.waitForFunction(()=>document.querySelector('#pxAvgPayout').textContent==='120.00 倍');
  check('JSON 展示与重复保存按钮已移除',await page.locator('#phenixConfig textarea,#phenixConfigSave').count()===0);
  check('杂牌余量自动计算且只读',await page.locator('#gcHp0').inputValue()==='6741'&&await page.locator('#gcHp0').getAttribute('readonly')!==null);
  check('默认加权均值',await page.locator('#pxAvgMultiple').textContent()==='加权平均翻倍 ×1.500');
  check('综合 RTP 包含正宗翻倍',await page.locator('#pxRtpTotal').textContent()==='82.30%');
  check('基础 RTP 独立显示',await page.locator('#pxRtpBase').textContent()==='80.30%');
  check('翻倍增量不重复计算基础赔付',await page.locator('#pxRtpExtra').textContent()==='+2.00 个百分点');
  check('正宗总贡献',await page.locator('#pxAuthRtp').textContent()==='6.00%');
  check('每档概率',JSON.stringify(await page.locator('.px-prob').allTextContents())===JSON.stringify(['60.00%','30.00%','10.00%']));
  await page.locator('.px-ww').nth(2).fill('110');
  check('编辑实时更新 RTP',await page.locator('#pxRtpTotal').textContent()==='85.30%');
  await page.locator('#pxAuthOn').uncheck();
  check('关闭正宗恢复基础 RTP',await page.locator('#pxRtpTotal').textContent()==='80.30%');
  await page.locator('#pxAuthOn').check();await page.locator('#gcHeChk8').uncheck();
  check('停用大四梅贡献为零',await page.locator('#pxAuthRtp').textContent()==='0.00%');
  check('停用不会减少其他牌型 RTP',await page.locator('#pxRtpTotal').textContent()==='76.30%');
  await page.locator('#gcHeChk8').check();await page.locator('#phenixConfigLoad').click();
  await page.waitForFunction(()=>document.querySelector('.px-ww').value==='60');
  await page.locator('#pxAuthAdd').click();
  check('自动补入未使用档位',await page.locator('.px-wv').last().inputValue()==='4');
  await page.locator('.px-wv').last().fill('14');await page.locator('.px-ww').last().fill('10');
  check('X14 正确显示奖励',await page.locator('.px-payout').last().textContent()==='1120 倍');
  const before=captures.length;await clickSave(1);await page.waitForFunction(()=>!GC_LABA_SAVING);
  check('统一保存一次提交完整规则',captures.length===before+1&&JSON.parse(captures.at(-1).PhenixConfigJson).specialRules.authentic.multipliers.values.at(-1)===14);
  check('防伪令牌保留',captures.at(-1).__RequestVerificationToken==='preview-token');
  await page.waitForFunction(()=>document.querySelectorAll('.px-wv').length===4&&!document.querySelector('.px-wv').disabled);
  await page.locator('.px-wv').last().fill('1');const duplicate=captures.length;await clickSave(1);
  check('重复档位阻止提交',captures.length===duplicate&&await page.locator('#pxRtpTotal').textContent()==='—');
  await page.locator('.px-wv').last().fill('14');await page.locator('.px-ww').last().fill('0.5');await clickSave(1);
  check('小数权重拒绝',captures.length===duplicate);
  await page.locator('.px-delete').last().click();await page.locator('#phenixConfigLoad').click();
  await page.waitForFunction(()=>document.querySelectorAll('.px-wv').length===4);
  failSave=true;const badCount=captures.length;await clickSave(1);await page.waitForFunction(()=>!GC_LABA_SAVING);
  check('HTTP 失败后可重试',captures.length===badCount+1&&!(await page.locator('#gcSave').isDisabled()));
  failGet=true;await page.locator('#phenixConfigLoad').click();await page.waitForFunction(()=>document.querySelector('#phenixConfigStatus').textContent.includes('模拟载入失败'));
  const loadFailCount=captures.length;await clickSave(1);check('载入失败阻止覆盖',captures.length===loadFailCount);
  await page.locator('#phenixConfigLoad').click();await page.waitForFunction(()=>document.querySelectorAll('.px-wv').length===4&&document.querySelector('#pxRtpTotal').textContent!=='—');
  delayGet=150;await page.evaluate(()=>{gcSelectTableById(5000);gcSelectTableById(5001);});await page.waitForTimeout(220);delayGet=0;
  check('迟到规则不能覆盖另一桌',await page.locator('#gcId').inputValue()==='5001'&&await page.locator('.px-wv').count()===3);
  await page.evaluate(()=>gcPrepareNewTableForm(2));
  check('批量新建载入缺省规则',await page.locator('#gcId').inputValue()==='-1'&&await page.locator('.px-wv').count()===3);
  await page.locator('#gcTableName').fill('预览新桌');const batch=captures.length;await clickSave(2);await page.waitForFunction(()=>!GC_BATCH_SAVING);
  check('批量各桌携带正宗权重',captures.length===batch+2&&captures.slice(-2).every(p=>p.PhenixConfigJson));
  await page.selectOption('#gcGameSel','55');
  check('切换其他游戏恢复布局',!(await page.locator('#pxRtpSummary').isVisible())&&!(await page.locator('#gcForm').getAttribute('class')).includes('gc-phenix-mode'));
  await page.selectOption('#gcGameSel','5');await page.evaluate(()=>gcSelectTableById(5001));
  await page.waitForFunction(()=>document.querySelector('#pxAvgPayout').textContent==='120.00 倍');
  // Focus the preview on the actual configuration tables, retaining the rest of the page below.
  await page.locator('.app-toast-wrap').evaluateAll(es=>es.forEach(e=>e.remove()));
  await page.screenshot({path:path.join(out,'full-page.png'),fullPage:true});
  await page.evaluate(()=>scrollTo(0,0));
  const box=await page.locator('#pxRtpSummary').boundingBox(),last=await page.locator('#phenixConfig').boundingBox();
  await page.screenshot({path:path.join(out,'phenix-config-preview.png'),fullPage:true,clip:{x:box.x-18,y:box.y-14,width:box.width+36,height:last.y+last.height-box.y+28}});
  await page.setViewportSize({width:1280,height:900});check('常用桌面宽度无横向溢出',await page.evaluate(()=>document.documentElement.scrollWidth===innerWidth));
  check('无浏览器脚本错误',errors.length===0);
  fs.writeFileSync(path.join(out,'browser-checks.json'),JSON.stringify({checks,errors,elapsedMs:Date.now()-start},null,2));
  console.log(`PASS ${checks.length} Chromium checks in ${Date.now()-start}ms`);
 }finally{await browser.close();}
}
server.listen(process.argv.includes('--test')?0:18785,'127.0.0.1',async()=>{
 console.log(`Preview: http://127.0.0.1:${server.address().port}/`);
 if(process.argv.includes('--test')){try{await test();}catch(e){console.error(e);process.exitCode=1;}finally{server.close();}}
});
