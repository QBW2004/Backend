'use strict';
// Actual editor DOM/functions/common confirmation and real MVC response fixtures; API mutations stay in local memory.
const fs=require('node:fs'),path=require('node:path'),http=require('node:http'),assert=require('node:assert/strict');
const {chromium}=require(process.env.PLAYWRIGHT_MODULE||'C:/Users/Administrator/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules/playwright');
const root=path.resolve(__dirname,'..'),web=path.join(root,'TTY.Web'),out=path.join(root,'.build/mjhl-inheritance');
const read=p=>fs.readFileSync(path.join(web,p),'utf8').replace(/^\uFEFF/,'');
const fixture=JSON.parse(fs.readFileSync(path.join(out,'controller-fixtures.json'),'utf8')),clone=o=>structuredClone(o);
const raw=read('Areas/Game/Views/GameConfig/ConfigEditor.cshtml');
const body=raw.slice(raw.indexOf('<div class="gc-wrap">')).replace(/@\*[\s\S]*?\*@/g,'').replace(/@Html.Partial\("[^"]+"\)/g,'')
    .replace('@Html.AntiForgeryToken()','<input name="__RequestVerificationToken" type="hidden" value="fixture-csrf">')
    .replace(/@Url.Action\("([^"]+)",\s*"([^"]+)"[^)]*\)/g,(_,a,c)=>'/'+c+'/'+a).replace(/@Url.Content\("~([^"]*)"\)/g,'$1');
const html=`<!doctype html><meta charset="utf-8"><style>${raw.match(/<style>([\s\S]*?)<\/style>/)[1].replaceAll('@@','@')}</style>
<script src="/Scripts/jquery-2.1.4.js"></script><script src="/Scripts/easyloader.js"></script><script src="/Scripts/app/common.js"></script><script src="/Scripts/app/mjhl.engine.js"></script>
<script>window.Worker=function(){this.postMessage=function(){};this.terminate=function(){};};</script><main class="main">${body}</main>`;
let state=clone(fixture.inherited),canEdit=true,defaultAvailable=true,fail=false,delay=0,readDelay=0;
const posts=[],checks=[],errors=[];
const check=(value,name)=>{assert.ok(value,name);checks.push(name);};
const server=http.createServer(async(req,res)=>{
    const route=new URL(req.url,'http://localhost').pathname;
    const json=data=>{res.setHeader('Content-Type','application/json;charset=utf-8');res.end(JSON.stringify(data));};
    if(route==='/'){res.setHeader('Content-Type','text/html;charset=utf-8');res.end(html);return;}
    if(route.startsWith('/GameConfig/')){
        let body='';for await(const part of req)body+=part;const p=Object.fromEntries(new URLSearchParams(body));
        if(route.endsWith('/GetGameList'))return json([{id:54,text:'麻将胡了',gameType:3,paraType:3},{id:5,text:'火凤凰',gameType:1,paraType:1}]);
        if(route.endsWith('/GetLineOptions'))return json({code:1,datas:{Ready:true,Lines:[{id:'',count:2,text:'公共桌台'}]}});
        if(route.endsWith('/GetTableConfig'))return json({code:1,datas:[]});
        if(route.endsWith('/GetMjhlAgentLines'))return json({code:1,datas:{Lines:[{id:'*',text:'默认'},{id:'agentA',text:'agentA'+(state.configured?'（独立配置）':'（使用默认配置）')},{id:'agentB',text:'agentB（独立配置）'}],CanEdit:canEdit}});
        if(route.endsWith('/GetMjhlAgentConfig')){
            let data=clone(p.lineAgent==='agentA'?state:fixture.copied);data.lineAgent=p.lineAgent;data.canEdit=canEdit;data.defaultAvailable=defaultAvailable;
            if(p.lineAgent==='*'){data.sourceLine='*';data.inherited=false;data.configured=true;}
            if(readDelay)await new Promise(r=>setTimeout(r,readDelay));return json(data);
        }
        posts.push({route,params:p});if(delay)await new Promise(r=>setTimeout(r,delay));
        if(fail){res.writeHead(503).end();return;}
        if(route.endsWith('/CopyMjhlDefaultConfig'))state=clone(fixture.copied);
        else if(route.endsWith('/RecallMjhlAgentConfig'))state=clone(fixture.recalled);
        else if(!route.endsWith('/SaveMjhlAgentConfig')){res.writeHead(404).end();return;}
        return json({code:1,hotReload:true,content:'配置操作成功'});
    }
    const file=path.resolve(web,'.'+route);if(!file.startsWith(web+path.sep)||!fs.existsSync(file)){res.writeHead(404).end();return;}
    res.setHeader('Content-Type',route.endsWith('.js')?'text/javascript; charset=utf-8':'text/css');res.end(fs.readFileSync(file));
});
(async()=>{
    const start=Date.now();await new Promise(r=>server.listen(0,'127.0.0.1',r));
    const browser=await chromium.launch({headless:true,executablePath:process.env.CHROME_PATH||'C:/Program Files/Google/Chrome/Application/chrome.exe'});
    try{
        const page=await browser.newPage({viewport:{width:1440,height:1000}});page.setDefaultTimeout(5000);page.on('pageerror',e=>errors.push(e.message));
        let accept=false;page.on('dialog',d=>accept?d.accept():d.dismiss());
        await page.goto('http://127.0.0.1:'+server.address().port);await page.selectOption('#gcTypeSel','3');await page.selectOption('#gcGameSel','54');
        const loaded=line=>page.waitForFunction(line=>GC_MJHL_LOADED_LINE===line&&GC_MJHL_META&&GC_MJHL_META.lineAgent===line,line);
        await loaded('*');check(!await page.locator('#mjhlAgentCopy').isVisible()&&!await page.locator('#mjhlAgentRecall').isVisible(),'default row has no copy/recall buttons');
        await page.selectOption('#gcLineSel','agentA');await loaded('agentA');
        check(await page.locator('#mjhlAgentCopy').isVisible()&&!await page.locator('#mjhlAgentRecall').isVisible(),'inherited line offers copy only');
        check(await page.locator('#mjhlGoldChance').inputValue()===String(fixture.inherited.config.goldChance),'inherited fields match real Controller response');
        check((await page.locator('#gcLineTip').textContent()).includes('使用默认配置'),'inherited status explained');
        check(!await page.locator('#gcLineCopy').isVisible()&&!await page.locator('#gcLineRecall').isVisible(),'ordinary table operations stay hidden');
        check(await page.evaluate(()=>GC_MJHL_CALIBRATING)&&await page.locator('#mjhlAgentCopy').isEnabled(),'copy works while RTP verification runs');
        await page.click('#mjhlAgentCopy');check(posts.length===0,'copy cancel sends nothing');
        await page.fill('#mjhlGoldChance','22');delay=200;accept=true;
        await page.click('#mjhlAgentCopy');await page.waitForFunction(()=>GC_MJHL_WRITING);
        check(await page.locator('#mjhlAgentCopy').isDisabled()&&await page.locator('#mjhlAgentSave').isDisabled(),'mutation locks both actions and save');
        await page.evaluate(()=>gcMjhlChangeInheritance(true));await page.waitForFunction(()=>GC_MJHL_META&&GC_MJHL_META.configured&&!GC_MJHL_WRITING);delay=0;
        check(posts.length===1,'double click creates one request');
        assert.deepEqual(posts[0].params,{lineAgent:'agentA',expectedRevision:'0',expectedDefaultRevision:'1',__RequestVerificationToken:'fixture-csrf'});checks.push('copy submits target/source versions and CSRF, no unsaved parameter values');
        check(await page.locator('#gcLineSel').inputValue()==='agentA','refresh preserves selected line');
        check(await page.locator('#mjhlAgentRecall').isVisible()&&!await page.locator('#mjhlAgentCopy').isVisible(),'independent line offers recall only');
        check(await page.locator('#mjhlGoldChance').inputValue()===String(fixture.copied.config.goldChance),'copy replaces unsaved form with saved source');
        accept=false;await page.click('#mjhlAgentRecall');check(posts.length===1,'recall cancel sends nothing');
        accept=true;await page.click('#mjhlAgentRecall');await page.waitForFunction(()=>GC_MJHL_META&&GC_MJHL_META.inherited&&GC_MJHL_META.revision==='2'&&!GC_MJHL_WRITING);
        check(posts.length===2&&posts[1].route.endsWith('RecallMjhlAgentConfig'),'recall sends dedicated config action');
        check(await page.locator('#mjhlGoldChance').inputValue()===String(fixture.recalled.config.goldChance),'recall displays current default response');
        check((await page.locator('#mjhlAgentStatus').textContent()).includes('使用默认配置'),'recall source status shown');
        await page.screenshot({path:path.join(out,'inheritance-ui.png')});
        // Late response cannot switch the currently selected line or replace its fields.
        delay=250;await page.click('#mjhlAgentCopy');await page.selectOption('#gcLineSel','agentB');await loaded('agentB');
        await page.waitForFunction(()=>!GC_MJHL_WRITING);delay=0;
        check(await page.locator('#gcLineSel').inputValue()==='agentB'&&await page.evaluate(()=>GC_MJHL_META.lineAgent)==='agentB','late mutation reply cannot overwrite another line');
        await page.selectOption('#gcLineSel','agentA');await loaded('agentA');fail=true;
        await page.click('#mjhlAgentRecall');await page.waitForFunction(()=>!GC_MJHL_WRITING&&document.querySelector('.app-toast-error'));
        check(await page.locator('#mjhlAgentRecall').isEnabled(),'network failure releases buttons');
        check((await page.locator('.app-toast-error').last().textContent()).includes('刷新确认'),'network failure gives visible guidance');fail=false;
        defaultAvailable=false;await page.evaluate(()=>gcMjhlLoadConfig());await loaded('agentA');
        check(await page.locator('#mjhlAgentRecall').isDisabled(),'missing default blocks destructive recall');defaultAvailable=true;
        canEdit=false;await page.evaluate(()=>gcMjhlLoadConfig());await loaded('agentA');
        check(!await page.locator('#mjhlAgentCopy').isVisible()&&!await page.locator('#mjhlAgentRecall').isVisible(),'read-only agent cannot use operations');canEdit=true;
        readDelay=200;await page.evaluate(()=>gcMjhlLoadConfig());check(!await page.locator('#mjhlAgentRecall').isVisible(),'loading clears previous permission/state');await loaded('agentA');readDelay=0;
        // An already-open EasyUI dialog must not act on a later selection.
        await page.evaluate(()=>new Promise(r=>easyloader.load('messager',r)));
        const before=posts.length;await page.click('#mjhlAgentRecall');await page.evaluate(()=>$('#gcLineSel').val('agentB').trigger('change'));await loaded('agentB');
        await page.locator('.messager-window:visible .messager-button a').first().click();check(posts.length===before,'stale confirmation after selection change sends nothing');
        await page.selectOption('#gcTypeSel','1');await page.selectOption('#gcGameSel','5');
        check(!await page.locator('#mjhlAgentCopy').isVisible()&&!await page.locator('#mjhlAgentRecall').isVisible(),'switching games hides Mahjong operations');
        check(errors.length===0,'no uncaught script errors');
        fs.writeFileSync(path.join(out,'browser-checks.json'),JSON.stringify({checks,errors,elapsedMs:Date.now()-start},null,2));
        console.log(JSON.stringify({checks:checks.length,elapsedMs:Date.now()-start}));
    }finally{await browser.close();server.closeAllConnections();await new Promise(r=>server.close(r));}
})().catch(e=>{console.error(e);process.exitCode=1;});
