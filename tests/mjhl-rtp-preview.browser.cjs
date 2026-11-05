'use strict';
// 真 Chromium + 页面实际函数/DOM + 实际嵌套 Worker；仅使用本地静态文件，不访问正式服务。
const fs=require('node:fs'),path=require('node:path'),http=require('node:http'),assert=require('node:assert/strict');
const playwright=process.env.PLAYWRIGHT_MODULE || 'C:/Users/Administrator/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules/playwright';
const {chromium}=require(playwright);
const root=path.resolve(__dirname,'..'),out=path.join(root,'.build/mjhl-rtp-preview');
const read=file=>fs.readFileSync(path.join(root,file),'utf8').replace(/^\uFEFF/,'');
const view=process.env.MJHL_VIEW_PATH?fs.readFileSync(process.env.MJHL_VIEW_PATH,'utf8').replace(/^\uFEFF/,''):read('TTY.Web/Areas/Game/Views/GameConfig/ConfigEditor.cshtml');
const panel=view.slice(view.indexOf('<div id="gcMjhlAgentPanel"'),view.indexOf('<div class="gc-common gc-base-info">'));
const functions=view.slice(view.indexOf('    function gcMjhlApplyMode('),view.indexOf('\n    function gcApplyType()'))
    .replace(/@Url.Content\("~([^"\n]+)"\)/g,'$1');
const events=view.split(/\r?\n/).filter(line=>/\$\('#gcMjhlAgentPanel \.gc-weight-body'\)\.on|\$\('#mjhlScatterEnabled,#mjhlFreeRetrigger'\)\.on|\$\('#mjhlGoldChance'\)\.on|\$\('#mjhlTargetRtp'\)\.on/.test(line)).join('\n');
const html=`<!doctype html><meta charset="utf-8"><style>${view.match(/<style>([\s\S]*?)<\/style>/)[1].replaceAll('@@media','@media')}</style><div class="gc-wrap"><div id="gcForm">${panel}</div></div>
<script src="/Scripts/jquery-2.1.4.min.js"></script><script src="/Scripts/app/mjhl.engine.js"></script><script>
var GC_MJHL_AGENT=null,GC_MJHL_AGENT_SAVED=null,GC_MJHL_AGENT_CAN_EDIT=true,line='fixture',saves=0,toasts=[],GC_MJHL_NAMES=MjhlEngine.NAMES;
function gcCurLine(){return line;}function gcIsMjhl(){return true;}function gcSetParaVisible(){}function gcMsg(){}function gcLineToken(){return 'fixture';}function gcApplyLineUi(){}
function showToast(text){toasts.push(text);}function request(){saves++;}var GC_URL={mjhlAgentSave:'fixture'};
$.ajax=function(){saves++;var response={done:function(){return response;},fail:function(){return response;},always:function(){return response;}};return response;};
${functions}
${events}
$('#mjhlRtpVerify').on('click',gcMjhlVerify);$('#mjhlRtpCalibrate').on('click',gcMjhlCalibrate);
var previewTimes=[],realPreview=gcMjhlPreviewRtp;
gcMjhlPreviewRtp=function(){realPreview.apply(null,arguments);previewTimes.push(performance.now()-began);};
function fixture(name){var p=MjhlEngine.defaults();return {gameId:54,targetRtp:80,goldChance:name==='gold100'?100:p.goldChance,
scatterEnabled:name!=='noScatter',freeRetrigger:name!=='noRetrigger',weights:p.weights,bets:{min:.4,max:60,chips:[.4,2,60],entry:2,scorePerCoin:1}};}
var began=0;
function start(name,type){gcMjhlCancelRtp();began=performance.now();previewTimes=[];gcMjhlApplyMode(true);gcMjhlFill(fixture(name),{canEdit:true});
if(type==='calibrate'){gcMjhlCancelRtp();gcMjhlRunRtp('calibrate');}}
</script>`;
const server=http.createServer((req,res)=>{
    const url=new URL(req.url,'http://localhost');res.setHeader('Cache-Control','no-store');
    if(url.pathname==='/'){res.setHeader('Content-Type','text/html; charset=utf-8');res.end(html);return;}
    if(!/^\/Scripts\/(jquery-2\.1\.4\.min\.js|app\/mjhl\.(engine|rtp\.pool|rtp\.native|rtp\.verify|rtp\.wasm|rtp\.sample\.worker|agent\.rtp\.worker)\.js)$/.test(url.pathname)){res.writeHead(404).end();return;}
    res.setHeader('Content-Type','text/javascript; charset=utf-8');res.end(read('TTY.Web'+url.pathname));
});
module.exports={server,html};
if(require.main===module)(async()=>{
    fs.mkdirSync(out,{recursive:true});await new Promise(resolve=>server.listen(0,'127.0.0.1',resolve));
    const browser=await chromium.launch({headless:true,executablePath:process.env.CHROME_PATH || 'C:/Program Files/Google/Chrome/Application/chrome.exe'});
    const report=[],errors=[];
    try{
        const page=await browser.newPage({viewport:{width:1440,height:1000}});page.on('pageerror',e=>errors.push(e.message));
        const cdp=await page.context().newCDPSession(page);
        for(const [name,type,slowdown] of [['default','verify',1],['default','calibrate',1],['noScatter','verify',1],['noRetrigger','verify',1],['gold100','verify',1],['default','verify',4]]){
            await cdp.send('Emulation.setCPUThrottlingRate',{rate:slowdown});
            await page.goto('http://127.0.0.1:'+server.address().port+'/');
            await page.evaluate(({name,type})=>start(name,type),{name,type});
            await page.waitForFunction(()=>previewTimes.length>0,null,{timeout:3000});
            assert(await page.locator('#mjhlActualRtp').isVisible());
            const state=await page.evaluate(()=>({ms:previewTimes[0],text:$('#mjhlActualRtp').text(),progress:$('#mjhlRtpProgress').text(),running:GC_MJHL_CALIBRATING,result:GC_MJHL_RTP_RESULT,saveDisabled:$('#mjhlAgentSave').prop('disabled')}));
            assert(state.ms<3000);assert(state.text.includes('估算'));assert(state.running);assert.equal(state.result,null);assert(state.saveDisabled);
            await page.waitForFunction(()=>/正在/.test($('#mjhlRtpProgress').text()),null,{timeout:3000});
            assert((await page.locator('#mjhlActualRtp').textContent()).includes('估算'));
            if(report.length===0)await page.screenshot({path:path.join(out,'preview.png')});
            await page.evaluate(()=>gcMjhlCancelRtp());report.push({name,type,slowdown,...state});
        }
        await cdp.send('Emulation.setCPUThrottlingRate',{rate:1});
        // 人工权重编辑包含页面600ms防抖，仍须3秒内显示新估算。
        await page.evaluate(()=>{start('default','verify');gcMjhlCancelRtp();var input=$('#mjhlWeightBody input').first();input.val(Number(input.val())+1);began=performance.now();previewTimes=[];input.trigger('input');});
        await page.waitForFunction(()=>previewTimes.length>0,null,{timeout:3000});
        const editMs=await page.evaluate(()=>previewTimes[0]);assert(editMs<3000);report.push({name:'manual-edit-with-debounce',ms:editMs});
        await page.evaluate(()=>{gcMjhlCancelRtp();began=performance.now();$('#mjhlTargetRtp').val(0);gcMjhlCalibrate();});
        await page.waitForFunction(()=>!!(GC_MJHL_RTP_RESULT&&GC_MJHL_RTP_RESULT.exact));
        const exact=await page.evaluate(()=>({text:$('#mjhlActualRtp').text(),progress:$('#mjhlRtpProgress').text(),ms:performance.now()-began}));
        assert(exact.text.includes('精确值'));assert.equal(exact.progress,'');report.push({name:'zero-final',...exact});
        assert.deepEqual(errors,[]);fs.writeFileSync(path.join(out,'browser-results.json'),JSON.stringify(report,null,2));console.log(JSON.stringify({pass:true,report}));
    }finally{await browser.close();await new Promise(resolve=>server.close(resolve));}
})().catch(e=>{console.error(e);server.close();process.exitCode=1;});
