'use strict';
const assert=require('node:assert/strict'),fs=require('node:fs'),path=require('node:path');
const {server}=require('./mjhl-rtp-preview.browser.cjs');
const {chromium}=require(process.env.PLAYWRIGHT_MODULE||'C:/Users/Administrator/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules/playwright');
(async()=>{
    const report=[],out=process.env.MJHL_RESULT_DIR||path.resolve(__dirname,'../.build/mjhl-rtp-fast');fs.mkdirSync(out,{recursive:true});
    await new Promise(resolve=>server.listen(0,'127.0.0.1',resolve));
    try{
        for(let trial=0;trial<3;trial++){
            const browser=await chromium.launch({headless:true,executablePath:process.env.CHROME_PATH||'C:/Program Files/Google/Chrome/Application/chrome.exe'});
            try{
                const page=await browser.newPage({viewport:{width:1440,height:1000}}),errors=[];
                page.on('pageerror',e=>errors.push(e.message));await page.goto('http://127.0.0.1:'+server.address().port+'/');
                // Record when the actual UI has accepted the final result, not just the preview.
                await page.evaluate(()=>{
                    window.finalMs=null;var controls=gcMjhlControls;
                    gcMjhlControls=function(){controls();if(!GC_MJHL_CALIBRATING&&!GC_MJHL_RTP_RESULT&&GC_MJHL_RTP_JOB==='')window.finishedAt=performance.now();};
                    start('default','verify');
                    var watch=setInterval(function(){if(GC_MJHL_RTP_RESULT){finalMs=performance.now()-began;clearInterval(watch);}},4);
                });
                await page.waitForFunction(()=>finalMs!==null,null,{timeout:20000});
                const state=await page.evaluate(()=>({ms:finalMs,hardware:navigator.hardwareConcurrency,result:GC_MJHL_RTP_RESULT,text:$('#mjhlActualRtp').text(),saveDisabled:$('#mjhlAgentSave').prop('disabled')}));
                assert(state.result.precisionReached);assert(state.result.half95<=.01);assert.equal(state.result.method,'renewal-importance-v1');assert(!state.saveDisabled);
                assert(await page.locator('#mjhlActualRtp').isVisible());assert(!state.text.includes('估算'));assert.deepEqual(errors,[]);
                if(trial===0)await page.screenshot({path:path.join(out,'verified.png')});
                await page.evaluate(()=>gcMjhlSave());assert.equal(await page.evaluate(()=>saves),1);
                assert(JSON.stringify(state.result).length<=1800,'saved evidence must fit existing summary storage');
                report.push({trial,...state});console.log(JSON.stringify({trial,ms:state.ms,rtp:state.result.total,half95pp:state.result.half95*100,count:state.result.count,hardware:state.hardware}));
            }finally{await browser.close();}
        }
        fs.writeFileSync(path.join(out,'browser-results.json'),JSON.stringify(report,null,2));
        assert(report.every(r=>r.ms<3000),'default configuration final verification must finish within 3 seconds');
    }finally{await new Promise(resolve=>server.close(resolve));}
})().catch(e=>{console.error(e);server.close();process.exitCode=1;});
