// Real views/scripts/styles, isolated in-memory data. No production requests.
const fs=require('node:fs'),path=require('node:path'),http=require('node:http'),assert=require('node:assert/strict');
const root=path.resolve(__dirname,'../..'),web=path.join(root,'TTY.Web'),out=path.join(root,'.build/rabbit-redesign-20261103');
fs.mkdirSync(out,{recursive:true});
const read=p=>fs.readFileSync(path.join(web,p),'utf8').replace(/^\uFEFF/,'');
const clone=v=>JSON.parse(JSON.stringify(v));
const defaults=JSON.parse(read('Models/RabbitConfig.cs').match(/DefaultJson = @"(.*?)";/)[1].replaceAll('""','"'));
const phenix=JSON.parse(read('Models/PhenixConfig.cs').match(/DefaultJson = @"(.*?)";/)[1].replaceAll('""','"'));
let failGet=false,failSave=false,delay=0;const readDelays={};const ruleRows=new Map();const aRule=clone(defaults),bRule=clone(defaults);aRule.futureKey={preserved:true};aRule.keepMax=9;aRule.keepMinHands=888;bRule.smallFourMultiplier=80;bRule.specialRules.authentic.multipliers.weights=[10,20,70,0,0,0,0,0,0,0,0,0,0,0];bRule.specialRules.five.successChance={numerator:3,denominator:4};ruleRows.set(0,aRule);ruleRows.set(1,bRule);
const attTables=[0,1].map(i=>({id:25000+i,tableName:`${i+1}号桌台`,minBet:1,maxBet:100,coinSc:100,coinNeed:1,exCoin:100,gameMo:1,scoreSwitch:10,enabled:1,idleFireTimeoutSec:2,cardDif:'3434453555777533',hypeType:0,payoutOn:1,jokerOn:1,jk1:6210,jk2:2200,jk3:0,goldFingerOn:1,goldFinger:2,diamondFlushOn:1,diamondFlush:20,allRoyalOn:1,allRoyal:10,jp5K:5100,jpRS:2100,jpSF:550,jp4K:250,jpDia:350,jpAR:2200,payout:Object.fromEntries([0,1800,800,300,250,70,20,10,5,2,1,1,0].map((p,i)=>['p'+i,p]))}));
const otherPoolTables={37:[{...clone(attTables[0]),id:37000,jp5K:null,jpRS:null,jpSF:null,jp4K:null}],44:[{...clone(attTables[0]),id:44000,jp5K:0,jpRS:2080,jpSF:530,jp4K:240}]};
const captures=[],tables=[0,1].map(i=>({id:55000+i,tableName:`${i+1}号桌台`,minBet:1,maxBet:100,coinSc:100,coinNeed:1,exCoin:100,gameMo:1,scoreSwitch:10,enabled:1,idleFireTimeoutSec:2,cardDif:'3434453555777533',hypeType:0,payoutOn:1,jokerOn:1,jk1:6210,jk2:2200,jk3:0,payout:Object.fromEntries([0,1800,800,300,250,70,20,10,5,2,1,1,0].map((p,i)=>['p'+i,p]))}));
function render(s){return s.replace(/@\*[\s\S]*?\*@/g,'').replace(/@Url.Action\("([^"]+)",\s*"([^"]+)"[^)]*\)/g,(_,a,c)=>a==='Index'?(c==='ActivityConfig'?'/rules':'/tables'):`/${c}/${a}`).replace(/@Url.Content\("~([^"]*)"(?:\s*\+\s*YYT.Common.ConfigHelper.Get\("WebVer"\))?\)/g,'$1').replace('@Html.Raw(YYT.Web.Models.RabbitConfig.DefaultJson)',JSON.stringify(defaults)).replace('@Html.Raw(YYT.Web.Models.PhenixConfig.DefaultJson)',JSON.stringify(phenix)).replaceAll('@@','@');}
function html(type){
 const raw=read(`Areas/Game/Views/${type==='activity'?'ActivityConfig/Index':'GameConfig/ConfigEditor'}.cshtml`),styles=raw.match(/<style>([\s\S]*?)<\/style>/)[1];
 let body=raw.slice(raw.indexOf(type==='activity'?'<div class="ac-wrap">':'<div class="gc-wrap">')).replace('@Html.AntiForgeryToken()','<input type="hidden" name="__RequestVerificationToken" value="rabbit-preview-token">');
 body=body.replace(/@Html.Partial\("([^"]+)"\)/g,(_,p)=>['_RabbitConfig','_RabbitPayout','_PhenixConfig','_AttMhbConfig'].includes(p)?read(`Areas/Game/Views/GameConfig/${p}.cshtml`):'');
 const auto=type==='activity'?'':`$(function(){var phase=0,t=setInterval(function(){if(!phase&&$('#gcTypeSel option[value="1"]').length){phase=1;$('#gcTypeSel').val('1').trigger('change');}else if(phase===1&&$('#gcGameSel option[value="55"]').length){phase=2;$('#gcGameSel').val('55').trigger('change');}else if(phase===2&&$('#rbTableRtp').text()!=='—'){phase=3;gcSelectTableById(Number($('#gcGameId').val())*1000);}else if(phase===3&&$('#rbTableRtp').text()!=='—'){clearInterval(t);${type==='rules'?"$('#rabbitConfig')[0].scrollIntoView();":"$('#rbTableStats')[0].scrollIntoView();"}}},50);});`;
 const autoScript=type==='att'?auto.replaceAll('value="55"','value="25"').replaceAll(".val('55')",".val('25')").replaceAll('#rbTableRtp','#amTotalRtp').replaceAll('#rbTableStats','#amRtpStats'):auto;
 return render(`<!doctype html><html lang="zh-CN"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>${type==='att'?'ATT满花版':'大白兔'}配置 · 本地预览</title><style>body{margin:0;background:#f5f7fa;font:14px/1.5 "Microsoft YaHei",Arial}.preview-nav{padding:12px 24px;background:#2f4050;color:#e0e8f1;display:flex;align-items:center;gap:22px;flex-wrap:wrap}.preview-nav strong{font-size:15px;font-weight:500}.preview-nav a{color:#e0e8f1;text-decoration:none;padding:5px 10px;border-radius:4px}.preview-nav a.active{background:#47627b;color:#fff}.preview-nav small{margin-left:auto;font-size:11px}.preview-main{max-width:1500px;margin:auto}${styles}</style><script src="/Scripts/jquery-2.1.4.js"></script><script src="/Scripts/jquery.easyui.min.js"></script><script>window.easyloader={load:function(m,f){f();}};window.loginTimeoutCallback=function(){};</script><script src="/Scripts/app/common.js"></script></head><body><nav class="preview-nav"><strong>桌台配置 / 预览</strong><a href="/tables" class="${type==='tables'||type==='rules'?'active':''}">大白兔桌台</a><a href="/activity">活动配置</a><a href="/att" class="${type==='att'?'active':''}">ATT满花版</a><small>示例参数 · 保存仅写内存</small></nav><main class="preview-main">${body}</main>${process.argv.includes('--test')||process.argv.includes('--no-auto')?'':`<script>${autoScript}</script>`}</body></html>`);
}
const activity={ready:true,code:1,enabled:true,saved:true,startTime:'10:00',endTime:'22:00',dailyQuota:50,multiplier:10,types:[7,8,9,10,11,12],typeOptions:['小四梅','大四梅','同花顺','五梅','同花大顺','五兔王'].map((name,i)=>({value:7+i,name})),open:true,usedToday:2,remainingToday:48,beijingNow:'2026-11-03 18:00'};
const server=http.createServer(async(req,res)=>{
 try{
  const u=new URL(req.url,'http://localhost'),route=u.pathname;
  const json=v=>{res.setHeader('Content-Type','application/json;charset=utf-8');res.end(JSON.stringify(v));};
  if(['/','/tables','/rules','/att','/activity'].includes(route)){res.setHeader('Content-Type','text/html;charset=utf-8');res.end(html(route==='/rules'?'rules':route==='/att'?'att':route==='/activity'?'activity':'tables'));return;}
  let b='';for await(const c of req)b+=c;const p=Object.fromEntries(new URLSearchParams(b));
  if(route.endsWith('/GetGameList'))return json([{id:55,text:'大白兔',gameType:1,paraType:1},{id:5,text:'火凤凰',gameType:1,paraType:1},{id:25,text:'ATT满花版',gameType:1,paraType:1},{id:37,text:'点石成金',gameType:1,paraType:1},{id:44,text:'NBA',gameType:1,paraType:1}]);
  if(route.endsWith('/GetLineOptions'))return json({code:1,datas:{Ready:true,Owned:0,Recycled:0,Lines:[{id:'',text:'公共桌台',count:2}]}});
  if(route.endsWith('/GetTableConfig'))return json({code:1,datas:otherPoolTables[p.GAME_ID]||(Number(p.GAME_ID)===25?attTables:Number(p.GAME_ID)===55?tables:tables.map(t=>({...t,id:5000+t.id%1000})))});
  if(route.endsWith('/GetRabbitConfig')||route.endsWith('/GetRabbitPayoutRules')){
   if(route.startsWith('/ActivityConfig/'))return json({code:0,content:'玩法规则已改为按桌配置'});
   const index=Number(p.tableIndex),data=clone(index<0?defaults:ruleRows.get(index)||defaults),wait=readDelays[index]??delay;if(wait)await new Promise(r=>setTimeout(r,wait));
   return json(failGet?{code:0,content:'模拟规则载入失败'}:{code:1,tableIndex:index,saved:ruleRows.has(index),shared:false,source:ruleRows.has(index)?'table':'default',config:data});
  }
  if(route.endsWith('/GetPhenixConfig'))return json({code:1,config:phenix});
  if(route.endsWith('/GetRabbitRace'))return json(activity);
  if(route.endsWith('/SaveRabbitConfig'))return json({code:0,content:'请使用桌台底部保存按钮'});
  if(route.endsWith('/SaveRabbitRace')){captures.push({route,p});return json({code:1,content:'预览：活动已保存'});}
  if(route.endsWith('/SaveTableConfig')){
   if(Number(p.GAME_ID)===25){
    captures.push({route,p});const t=attTables.find(t=>t.id===Number(p.ID))||attTables[0];
    t.tableName=p.TableName;for(let h=0;h<=12;h++){t.payout['p'+h]=Number(p['hp'+h]);t.payout['e'+h]=Number(p['he'+h]??1);}
    for(const [a,b]of[['goldFingerOn','GoldFingerOn'],['goldFinger','gf'],['diamondFlushOn','DiamondFlushOn'],['diamondFlush','dp'],['allRoyalOn','AllRoyalOn'],['allRoyal','ar']])t[a]=Number(p[b]);
    for(const [a,b]of[['jpSet5K','JP_5K'],['jpSetRS','JP_RS'],['jpSetSF','JP_SF'],['jpSet4K','JP_4K'],['jpSetDia','JP_DIA'],['jpSetAR','JP_AR']])if(b in p)t[a]=Number(p[b]);
    return json({code:1,datas:true,content:'预览：ATT桌台参数已保存'});
   }
   captures.push({route,p});if(Number(p.GAME_ID)===55){if(delay)await new Promise(r=>setTimeout(r,delay));if(failSave){failSave=false;res.writeHead(503);res.end('模拟请求失败');return;}}let t=tables.find(t=>t.id===Number(p.ID));if(!t&&Number(p.ID)<0&&Number(p.GAME_ID)===55){t=clone(tables[0]);t.id=55000+tables.length;tables.push(t);}if(t){if(Number(p.GAME_ID)===55)ruleRows.set(t.id%1000,JSON.parse(p.RabbitConfigJson));t.tableName=p.TableName;for(let h=0;h<=12;h++){t.payout['p'+h]=Number(p['hp'+h]);t.payout['e'+h]=Number(p['he'+h]??1);}}
   return json({code:1,datas:true,content:'预览：已保存当前桌台出现机会'});
  }
  const file=path.resolve(web,'.'+route);if(file.startsWith(web+path.sep)&&fs.existsSync(file)&&fs.statSync(file).isFile()){res.setHeader('Content-Type',file.endsWith('.css')?'text/css':'application/javascript');res.end(fs.readFileSync(file));return;}
  res.writeHead(404);res.end();
 }catch(e){res.writeHead(500);res.end(e.stack);}
});
async function test(){
 const{chromium}=require('C:/Users/Administrator/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules/playwright');
 const browser=await chromium.launch({headless:true,executablePath:'C:/Program Files/Google/Chrome/Application/chrome.exe'}),checks=[],errors=[],start=Date.now();
 const check=(n,v)=>{assert.ok(v,n);checks.push(n);};
 try{
  const page=await browser.newPage({viewport:{width:1440,height:1100}});page.setDefaultTimeout(7000);page.on('pageerror',e=>errors.push(e.message));
  const base=`http://127.0.0.1:${server.address().port}`;
  const ready=async(id)=>page.waitForFunction(id=>document.querySelector('#gcGameId').value==='55'&&document.querySelector('#gcId').value===String(id)&&!document.querySelector('#gcSave').disabled&&window.rabbitConfigIsReady(),id);
  const select=async(id)=>{await page.evaluate(id=>gcSelectTableById(id),id);await ready(id);};
  const save=async(id)=>{const refreshed=page.waitForResponse(r=>r.url().endsWith('/GetTableConfig'));await page.click('#gcSave');await refreshed;await ready(id);};
  await page.goto(base+'/tables');await page.selectOption('#gcTypeSel','1');await page.selectOption('#gcGameSel','55');await ready(-1);await select(55000);
  check('本桌规则与桌台参数合并在同一表单',await page.locator('#rabbitConfig').evaluate(e=>!!e.closest('#gcForm')));
  check('只保留底部两个按钮',await page.locator('#gcParaFoot button:visible').count()===2&&await page.locator('#rabbitConfigSave,#rabbitConfigLoad').count()===0);
  check('按钮位于全部设置之后',await page.locator('#rabbitConfig').evaluate(e=>!!(e.compareDocumentPosition(document.querySelector('#gcParaFoot'))&Node.DOCUMENT_POSITION_FOLLOWING)));
  check('页面明确仅当前桌台',await page.locator('#rabbitConfig').textContent().then(t=>t.includes('仅当前桌台')&&!t.includes('全部桌台共用')));
  check('留机模块和输入框完全移除',await page.locator('#rbKeepMax,#rbKeepMinHands').count()===0&&await page.locator('#rabbitConfig').textContent().then(t=>!t.includes('留机')));
  check('无JSON编辑器或重复预览表',await page.locator('#rabbitConfig textarea,#rbTableAuth,#rbTableFive').count()===0);
  check('CSS和数学模块仅加载一次',await page.locator('link[href*="game.rabbitconfig.css"]').count()===1&&await page.locator('script[src*="game.rabbit-math.js"]').count()===1);
  check('默认RTP含正宗与五枚期望',await page.locator('#rbTableRtp').textContent()==='84.13%'&&await page.locator('#rbTableBase').textContent()==='81.30%');
  check('正宗与五枚增量计算正确',await page.locator('#rbTableAuthExtra').textContent()==='+2.00 个百分点'&&await page.locator('#rbTableFiveExtra').textContent()==='+0.83 个百分点');
  check('正宗默认三档120倍',await page.locator('#rbAuthTable tbody tr').count()===3&&await page.locator('#rbAuthTable .rb-avg').textContent()==='120.00 倍');
  await page.fill('#gcHp8','10');check('牌型机会实时联动',await page.locator('#rbTableRtp').textContent()==='90.13%');await page.fill('#gcHp8','5');
  await page.fill('#rbSmallFour','60');await page.locator('#rbAuthTable .rb-ww').nth(2).fill('110');await page.fill('#rbFiveWinWeight','2');await page.fill('#rbFiveMissWeight','3');
  await page.click('#rbAuthAdd');await page.locator('#rbAuthTable .rb-ww').last().fill('10');
  check('本桌新增档位参加加权',await page.locator('#rbAuthTable tbody tr').count()===4&&await page.locator('#rbAuthTable .rb-avg').textContent()==='186.67 倍');
  await select(55001);
  check('第二桌载入不同倍率与权重',await page.locator('#rbSmallFour').inputValue()==='80'&&await page.locator('#rbAuthTable .rb-ww').first().inputValue()==='10'&&await page.locator('#rbAuthTable tbody tr').count()===3);
  check('第二桌独立五枚概率',await page.locator('#rbFiveWinPct').inputValue()==='75');
  await page.fill('#rbSmallFour','85');await page.selectOption('#rbAuthMode','probability');for(const[i,v]of['50','25','25'].entries())await page.locator('#rbAuthTable .rb-ap').nth(i).fill(v);
  await page.selectOption('#rbFiveMode','probability');await page.fill('#rbFiveWinPct','10');
  check('概率模式直接编辑并补齐落空',await page.locator('#rbFiveMissPct').inputValue()==='90'&&await page.locator('#rbFiveAveragePay').textContent()==='275.00 倍');
  const beforeB=captures.length;await save(55001);const bSaved=JSON.stringify(ruleRows.get(1));
  check('保存只提交当前桌号及本桌规则',captures.length===beforeB+1&&captures.at(-1).p.ID==='55001'&&JSON.parse(captures.at(-1).p.RabbitConfigJson).smallFourMultiplier===85);
  check('保存第二桌不覆盖第一桌',ruleRows.get(0).smallFourMultiplier===50&&ruleRows.get(0).specialRules.authentic.multipliers.weights[2]===10);
  await select(55000);
  check('切回第一桌保留自己的未保存草稿',await page.locator('#rbSmallFour').inputValue()==='60'&&await page.locator('#rbAuthTable .rb-ww').nth(2).inputValue()==='110'&&await page.locator('#rbAuthTable tbody tr').count()===4);
  await save(55000);
  check('第一桌保存不覆盖第二桌独立参数',JSON.stringify(ruleRows.get(1))===bSaved&&ruleRows.get(0).smallFourMultiplier===60);
  check('隐藏留机参数和未知键仍保留',ruleRows.get(0).keepMax===9&&ruleRows.get(0).keepMinHands===888&&ruleRows.get(0).futureKey.preserved);
  check('防伪令牌和旧赛跑关闭保留',captures.at(-1).p.__RequestVerificationToken==='rabbit-preview-token'&&ruleRows.get(0).race.enabled===false);
  await page.goto(base+'/tables');await page.selectOption('#gcTypeSel','1');await page.selectOption('#gcGameSel','55');await ready(-1);await select(55000);
  check('刷新页面回读本桌已保存档位',await page.locator('#rbSmallFour').inputValue()==='60'&&await page.locator('#rbAuthTable .rb-wv').last().inputValue()==='4');
  await page.selectOption('#rbAuthMode','probability');await page.locator('#rbAuthTable .rb-ap').first().fill('50');const invalid=captures.length;await page.click('#gcSave');
  check('概率合计非100阻止整个表单保存',captures.length===invalid&&await page.locator('#rbTableRtp').textContent()==='—');
  await select(55001);check('无效草稿不会污染另一桌RTP',await page.locator('#rbSmallFour').inputValue()==='85'&&await page.locator('#rbTableRtp').textContent()!=='—');await select(55000);
  check('切回仍保留原桌无效概率编辑',await page.locator('#rbAuthMode').inputValue()==='probability'&&await page.locator('#rbAuthTable .rb-ap').first().inputValue()==='50'&&await page.locator('#rbTableRtp').textContent()==='—');
  for(const[i,v]of['50','30','15','5'].entries())await page.locator('#rbAuthTable .rb-ap').nth(i).fill(v);await page.selectOption('#rbFiveMode','probability');await page.fill('#rbFiveWinPct','25');
  check('修正概率后立即恢复本桌RTP',await page.locator('#rbAuthTable .rb-avg').textContent()==='140.00 倍'&&await page.locator('#rbTableRtp').textContent()!=='—');
  await save(55000);check('概率精确映射到原协议整数',JSON.stringify(ruleRows.get(0).specialRules.authentic.multipliers.weights)==='[10,6,3,1]'&&ruleRows.get(0).specialRules.five.successChance.numerator===1&&ruleRows.get(0).specialRules.five.successChance.denominator===4);
  readDelays[0]=120;await page.evaluate(()=>rabbitConfigReload());await select(55001);await page.waitForTimeout(160);delete readDelays[0];
  check('迟到的另一桌规则响应不覆盖当前桌',await page.locator('#gcId').inputValue()==='55001'&&await page.locator('#rbSmallFour').inputValue()==='85');
  await select(55000);await page.fill('#rbSmallFour','65');delay=100;const saveResponse=page.waitForResponse(r=>r.url().endsWith('/SaveTableConfig'));await page.click('#gcSave');check('保存时锁定规则和恢复按钮',await page.locator('#rbSmallFour').isDisabled()&&await page.locator('#gcReset').isDisabled());await select(55001);await saveResponse;await ready(55001);delay=0;
  check('跨桌保存完成不把源桌参数写入当前桌编辑器',await page.locator('#rbSmallFour').inputValue()==='85'&&ruleRows.get(0).smallFourMultiplier===65&&JSON.stringify(ruleRows.get(1))===bSaved);
  await select(55000);failGet=true;await page.click('#gcRefresh');await page.waitForFunction(()=>document.querySelector('#rabbitConfigStatus').textContent.includes('模拟'));
  check('规则载入失败禁止保存且清空RTP',await page.locator('#gcSave').isDisabled()&&await page.locator('#rbTableRtp').textContent()==='—');
  await page.selectOption('#gcGameSel','5');await page.waitForFunction(()=>document.querySelector('#gcGameId').value==='5');check('失败不锁住其他游戏操作',await page.locator('#gcSave').isEnabled()&&await page.locator('#gcReset').isEnabled());
  failGet=false;await page.selectOption('#gcGameSel','55');await ready(-1);await select(55000);await page.fill('#rbSmallFour','66');failSave=true;
  const failedResponse=page.waitForResponse(r=>r.url().endsWith('/SaveTableConfig'));await page.click('#gcSave');await failedResponse;await ready(55000);
  check('请求失败保留本桌草稿并可重试',await page.locator('#rbSmallFour').inputValue()==='66'&&ruleRows.get(0).smallFourMultiplier===65);await save(55000);
  check('重试后只更新原桌',ruleRows.get(0).smallFourMultiplier===66&&JSON.stringify(ruleRows.get(1))===bSaved);
  const resetBefore=captures.length;await page.evaluate(()=>gcResetForm());
  check('恢复默认只改本桌表单且不自动保存',captures.length===resetBefore&&await page.locator('#rbSmallFour').inputValue()==='50'&&await page.locator('#gcScoreSwitch').inputValue()==='1'&&JSON.stringify(ruleRows.get(1))===bSaved);
  check('恢复默认仍保留隐藏留机参数',await page.evaluate(()=>JSON.parse(rabbitConfigCollect().RabbitConfigJson).keepMax===9&&JSON.parse(rabbitConfigCollect().RabbitConfigJson).keepMinHands===888));
  await save(55000);check('恢复默认保存不影响其他桌',ruleRows.get(0).smallFourMultiplier===50&&JSON.stringify(ruleRows.get(1))===bSaved);
  await page.evaluate(()=>gcPrepareNewTableForm(2));await ready(-1);check('新建桌台采用独立默认玩法',await page.locator('#rbSmallFour').inputValue()==='50');await page.fill('#rbSmallFour','77');await page.fill('#gcTableName','独立批量');
  const batchBefore=captures.length;await page.click('#gcSave');await page.waitForFunction(()=>!window.GC_BATCH_SAVING&&document.querySelector('#gcId').value==='55003');await ready(55003);
  check('批量新建各存一份规则行',captures.length===batchBefore+2&&ruleRows.get(2).smallFourMultiplier===77&&ruleRows.get(3).smallFourMultiplier===77);
  await select(55002);await page.fill('#rbSmallFour','78');await save(55002);check('批量创建后修改一桌不影响同批另一桌',ruleRows.get(2).smallFourMultiplier===78&&ruleRows.get(3).smallFourMultiplier===77&&JSON.stringify(ruleRows.get(1))===bSaved);
  for(const width of[1280]){await page.setViewportSize({width,height:900});check('规则表格没有页面横向溢出 '+width,await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth));}await page.setViewportSize({width:1440,height:1100});
  await page.locator('#rabbitConfig').screenshot({path:path.join(out,'rabbit-rules-preview.png')});await page.locator('#gcParaFoot').screenshot({path:path.join(out,'rabbit-bottom-actions-preview.png')});
  const activityPage=await browser.newPage();await activityPage.goto(base+'/activity');await activityPage.waitForFunction(()=>document.querySelector('#acQuota').value==='50');check('活动配置只有赛跑而无桌台玩法',await activityPage.locator('#rabbitConfig').count()===0);const activitySaved=activityPage.waitForResponse(r=>r.url().endsWith('/SaveRabbitRace'));await activityPage.click('#acSave');await activitySaved;await activityPage.close();
  await page.selectOption('#gcTypeSel','-1');check('清空游戏选择时隐藏规则',!(await page.locator('#rabbitConfig').isVisible()));
  await page.goto(base+'/att');await page.selectOption('#gcTypeSel','1');await page.selectOption('#gcGameSel','25');await page.waitForFunction(()=>document.querySelector('#amTotalRtp').textContent!=='—');await page.evaluate(()=>gcSelectTableById(25000));
  await page.waitForFunction(()=>document.querySelector('#gcId').value==='25000'&&document.querySelector('#gcJpTable tbody tr').children.length===5);
  check('ATT三档赔率与期望明确',await page.locator('#gcHm7').textContent().then(s=>s.includes('加权 45.50 倍')));
  check('金拇指五档完整',JSON.stringify(await page.locator('#amGfAwardRows strong').allTextContents())===JSON.stringify(['20 倍','50 倍','100 倍','200 倍','400 倍']));
  check('金拇指均值154倍',await page.locator('#amGfAverage').textContent()==='154');
  check('ATT触发控件只有一份',await page.locator('#gcGf,#gcDp,#gcAr,#gcGfOn,#gcDpOn,#gcArOn').count()===6&&await page.locator('#amFeatureTable input').count()===6);
  check('ATT六个奖池在同表编辑',await page.locator('#gcJpTable input:not(:disabled)').count()===6);
  check('六池当前值逐行显示',JSON.stringify(await page.locator('#gcJpTable .gc-jp-current-value').allTextContents())===JSON.stringify(['5100','2100','550','250','350','2200']));
  check('当前值只读且不参与提交',await page.locator('#gcJpTable .gc-jp-current-value').evaluateAll(es=>es.every(e=>!e.isContentEditable&&!e.hasAttribute('name')&&e.tagName==='OUTPUT')));
  check('表格下方不再显示当前值串',await page.locator('#gcJpInfo').textContent().then(s=>!s.includes('5100')&&!s.includes('2100')));
  check('ATT明确非完整RTP',await page.locator('#amRtpNote').textContent().then(s=>s.includes('不能作为完整返奖率')));
  check('ATT基础与金拇指计算值正确',await page.locator('#amBaseRtp').textContent()==='75.15%'&&await page.locator('#amTotalRtp').textContent()==='77.23%');
  check('ATT统一保存文案',await page.locator('#gcSave').textContent()==='保存并热更新');
  check('奖池下方没有分散设置框',await page.locator('#gcJpBox > .gc-form-row').count()===0);
  const baseRtp=await page.locator('#amBaseRtp').textContent(),totalRtp=await page.locator('#amTotalRtp').textContent();
  await page.fill('#gcGf','5');check('金拇指实时联动RTP',await page.locator('#amTotalRtp').textContent()!==totalRtp&&await page.locator('#amBaseRtp').textContent()===baseRtp);
  await page.locator('#gcGfOn').uncheck();check('关闭金拇指归零',await page.locator('#amGfRtp').textContent()==='+0.00 个百分点');await page.locator('#gcGfOn').check();
  const jpBefore=captures.length;await page.locator('#gcSave').click();await page.waitForFunction(()=>document.querySelector('#gcJpTable tbody tr').children.length===5);await page.waitForTimeout(100);
  check('奖池未修改不提交JP字段',captures.length===jpBefore+1&&!('JP_5K'in captures.at(-1).p));
  check('其他游戏不提交大白兔规则',!('RabbitConfigJson'in captures.at(-1).p));check('额外玩法原字段随统一保存',captures.at(-1).p.gf==='5'&&captures.at(-1).p.GoldFingerOn==='1'&&captures.at(-1).p.dp==='20'&&captures.at(-1).p.ar==='10');
  for(const[id,v]of[['gcJp5K','5201'],['gcJpRS','2202'],['gcJpSF','603'],['gcJp4K','304'],['gcJpDIA','405'],['gcJpAR','2306']])await page.fill('#'+id,v);
  await page.locator('#gcSave').click();await page.waitForTimeout(150);
  check('六个奖池全部原名提交',captures.at(-1).p.JP_5K==='5201'&&captures.at(-1).p.JP_RS==='2202'&&captures.at(-1).p.JP_SF==='603'&&captures.at(-1).p.JP_4K==='304'&&captures.at(-1).p.JP_DIA==='405'&&captures.at(-1).p.JP_AR==='2306');
  check('设置值与当前快照独立',await page.locator('#gcJp5K').inputValue()==='5201'&&await page.locator('.gc-jp-current-value').first().textContent()==='5100');
  await page.selectOption('#gcGameSel','37');await page.waitForFunction(()=>GC_TABLES[0]&&GC_TABLES[0].id===37000);await page.evaluate(()=>gcSelectTableById(37000));
  check('点石成金四池缺快照显示未获取',JSON.stringify(await page.locator('#gcJpTable .gc-jp-current-value').allTextContents())===JSON.stringify(['未获取','未获取','未获取','未获取']));
  check('点石成金四个设置框均在表内',await page.locator('#gcJpTable input.gc-jp-v').count()===4&&await page.locator('#gcJpBox input.gc-jp-v').count()===4);
  for(const[id,v]of[['gcJp5K','5001'],['gcJpRS','2002'],['gcJpSF','503'],['gcJp4K','204']])await page.fill('#'+id,v);
  await page.click('#gcSave');await page.waitForTimeout(100);check('点石成金四池沿用原字段提交',captures.at(-1).p.JP_5K==='5001'&&captures.at(-1).p.JP_RS==='2002'&&captures.at(-1).p.JP_SF==='503'&&captures.at(-1).p.JP_4K==='204'&&!('JP_DIA'in captures.at(-1).p));
  await page.selectOption('#gcGameSel','44');await page.waitForFunction(()=>GC_TABLES[0]&&GC_TABLES[0].id===44000);await page.evaluate(()=>gcSelectTableById(44000));
  check('NBA四池显示当前值且零有效',JSON.stringify(await page.locator('#gcJpTable .gc-jp-current-value').allTextContents())===JSON.stringify(['0','2080','530','240']));
  check('NBA三王额外奖仍在表内',await page.locator('#gcJpTable tbody .gc-jp-nba').count()===4);
  check('NBA四个设置框均在表内',await page.locator('#gcJpTable input.gc-jp-v').count()===4&&await page.locator('#gcJp5K').inputValue()==='0');
  await page.locator('.app-toast-wrap').evaluateAll(es=>es.forEach(e=>e.remove()));await page.locator('#gcJpBox').screenshot({path:path.join(out,'nba-jackpot-table-preview.png')});
  await page.selectOption('#gcGameSel','5');await page.waitForFunction(()=>document.querySelector('#gcGameId').value==='5');
  check('切游戏不残留ATT布局',!(await page.locator('#amRtpStats').isVisible()));
  await page.selectOption('#gcGameSel','25');await page.waitForFunction(()=>document.querySelector('#amRtpStats').style.display!=='none'&&document.querySelector('#gcJpTable tbody tr').children.length===5);
  await page.evaluate(()=>gcSelectTableById(25000));await page.waitForFunction(()=>document.querySelector('#gcId').value==='25000'&&document.querySelector('#gcGf').value==='5');
  check('切回ATT奖池输入未丢失',await page.locator('#gcJpTable input:not(:disabled)').count()===6&&await page.locator('#gcJp5K').count()===1);
  check('切回ATT额外字段仍可用',await page.locator('#gcGf').inputValue()==='5');
  await page.evaluate(()=>gcSelectTableById(25001));await page.waitForFunction(()=>document.querySelector('#gcId').value==='25001'&&document.querySelector('#gcGf').value==='2');
  check('ATT换桌回填正确',await page.locator('#gcJp5K').inputValue()==='5100');
  await page.locator('.app-toast-wrap').evaluateAll(es=>es.forEach(e=>e.remove()));await page.evaluate(()=>scrollTo(0,0));
  const am=await page.locator('#amRtpStats').boundingBox(),amLast=await page.locator('#gcJpBox').boundingBox();
  await page.screenshot({path:path.join(out,'attmhb-config-preview.png'),fullPage:true,clip:{x:am.x-18,y:am.y-14,width:am.width+36,height:amLast.y+amLast.height-am.y+28}});
  await page.locator('#gcJpBox').screenshot({path:path.join(out,'card-jackpot-table-preview.png')});
  await page.setViewportSize({width:1280,height:900});check('ATT常用桌面宽度无溢出',await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth));
  check('浏览器无脚本错误',errors.length===0);fs.writeFileSync(path.join(out,'browser-checks.json'),JSON.stringify({checks,errors,elapsedMs:Date.now()-start},null,2));console.log(`PASS ${checks.length} Chromium checks in ${Date.now()-start}ms`);
 }finally{await browser.close();}
}
server.listen(process.argv.includes('--test')||process.argv.includes('--port=0')?0:18786,'127.0.0.1',async()=>{console.log(`Preview: http://127.0.0.1:${server.address().port}/`);if(process.argv.includes('--test')){try{await test();}catch(e){console.error(e);process.exitCode=1;}finally{server.close();}}});
