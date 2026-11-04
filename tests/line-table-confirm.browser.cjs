// Real confirmation helper, EasyUI loader and table-action functions; HTTP writes stay local.
'use strict';
const fs = require('node:fs'), path = require('node:path'), http = require('node:http');
const assert = require('node:assert/strict');
const { chromium } = require(process.env.PLAYWRIGHT_MODULE || 'C:/Users/Administrator/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules/playwright');
const root = path.resolve(__dirname, '..'), web = path.join(root, 'TTY.Web');
const out = path.join(root, '.build/line-table-confirm');
const read = p => fs.readFileSync(path.join(web, p), 'utf8').replace(/^\uFEFF/, '');
const view = read('Areas/Game/Views/GameConfig/ConfigEditor.cshtml');
const actions = view.slice(view.indexOf('    function gcLineToken()'), view.indexOf('    // 加分幅度归一化'));
const common = process.env.COMMON_JS ? fs.readFileSync(process.env.COMMON_JS, 'utf8') : read('Scripts/app/common.js');
const old = process.argv.includes('--expect-stall');
const posts = [], checks = [], errors = [];
let mode = 'ready';
const html = `<!doctype html><meta charset="utf-8">
<link rel="stylesheet" href="/Content/easyui/themes/bootstrap/easyui.css">
<script src="/Scripts/jquery-2.1.4.js"></script><script src="/Scripts/easyloader.js"></script>
<script src="/Scripts/app/common.js"></script>
<div class="main"><form id="gcForm"><input name="__RequestVerificationToken" value="local-csrf"></form>
<select id="gcGameSel"><option value="5">火凤凰</option></select>
<select id="gcLineSel"><option value="fixture-agent">测试代理</option></select>
<input class="easyui-numberbox" value="1">
<button id="gcLineCopy">从公共桌台复制一套</button><button id="gcLineRecall">收回专属桌台</button></div>
<script>
var GC_URL={lineCopy:'/CopyPublicTablesToLine',lineRecall:'/RecallLineTables'},reloads=0,results=[];
function gcCurLine(){return $('#gcLineSel').val()||'';} function gcGetType(){return 1;}
function gcMsg(data){results.push(data);} function gcLoadLines(done){done();} function gcLoadTables(){reloads++;}
${actions}
$('#gcLineCopy').on('click',gcLineCopy);$('#gcLineRecall').on('click',gcLineRecall);
</script>`;
const server = http.createServer(async (req, res) => {
    const route = new URL(req.url, 'http://localhost').pathname;
    if (route === '/') { res.setHeader('Content-Type', 'text/html; charset=utf-8'); res.end(html); return; }
    if (req.method === 'POST') {
        let body = ''; for await (const part of req) body += part;
        posts.push({ route, params: Object.fromEntries(new URLSearchParams(body)) });
        res.setHeader('Content-Type', 'application/json');
        res.end(JSON.stringify({ code: mode === 'failure' ? 0 : 1, content: mode === 'failure' ? '模拟业务失败' : '完成' })); return;
    }
    if (route === '/Content/easyui/plugins/jquery.linkbutton.js') {
        if (mode === 'blocked') { res.writeHead(404).end(); return; }
        if (mode === 'slow') await new Promise(resolve => setTimeout(resolve, 2600));
    }
    const file = path.resolve(web, '.' + route);
    if (!file.startsWith(web + path.sep) || !fs.existsSync(file)) { res.writeHead(404).end(); return; }
    res.setHeader('Content-Type', route.endsWith('.js') ? 'application/javascript; charset=utf-8' : 'text/css');
    res.end(route === '/Scripts/app/common.js' ? common : fs.readFileSync(file));
});
function check(value, name) { assert.ok(value, name); checks.push(name); }
(async () => {
    const start = Date.now(); fs.mkdirSync(out, { recursive: true });
    await new Promise(resolve => server.listen(0, '127.0.0.1', resolve));
    const browser = await chromium.launch({ headless: true, executablePath: process.env.CHROME_PATH || 'C:/Program Files/Google/Chrome/Application/chrome.exe' });
    try {
        for (const scenario of (old ? ['slow', 'blocked'] : ['cold', 'slow', 'blocked', 'ready', 'failure'])) {
            mode = scenario;
            console.log('scenario=' + scenario);
            const page = await browser.newPage(); page.setDefaultTimeout(5000);
            page.on('pageerror', e => { errors.push(e.message); console.error('browser error: ' + e.message); });
            await page.goto('http://127.0.0.1:' + server.address().port, { waitUntil: 'domcontentloaded' });
            if (scenario === 'slow' || scenario === 'blocked') {
                await page.waitForFunction(() => !!document.querySelector('script[src*="jquery.linkbutton.js"]'));
            }
            if (scenario === 'ready' || scenario === 'failure') {
                await page.evaluate(() => new Promise(resolve => easyloader.load('messager', resolve)));
            }
            let nativeCount = 0, accept = false;
            page.on('dialog', async dialog => { nativeCount++; check(dialog.type() === 'confirm', 'native dialog is confirmation'); await (accept ? dialog.accept() : dialog.dismiss()); });
            if (old) {
                await page.click('#gcLineCopy'); await page.click('#gcLineRecall');
                await page.waitForTimeout(4500);
                check(nativeCount === 0, scenario + ': no native confirmation');
                check(await page.locator('.messager-window:visible').count() === 0, scenario + ': no EasyUI confirmation');
                check(posts.length === 0, scenario + ': no write request');
                await page.close(); continue;
            }
            for (const [button, route] of [['#gcLineCopy', '/CopyPublicTablesToLine'], ['#gcLineRecall', '/RecallLineTables']]) {
                const before = posts.length, previousReloads = await page.evaluate(() => reloads);
                const easyui = scenario === 'ready' || scenario === 'failure';
                accept = false;
                let began = Date.now(); await page.click(button);
                if (easyui) { await page.locator('.messager-window:visible .messager-button a').nth(1).click(); }
                check(Date.now() - began < 2000, scenario + button + ': immediate confirmation');
                check(posts.length === before, scenario + button + ': cancel sends no write');
                accept = true;
                const response = page.waitForResponse(r => r.url().endsWith(route));
                await page.click(button);
                if (easyui) { await page.locator('.messager-window:visible .messager-button a').first().click(); }
                await response; await page.waitForFunction(n => results.length === n, (button === '#gcLineCopy' ? 1 : 2));
                check(posts.length === before + 1, scenario + button + ': accept sends exactly once');
                assert.deepEqual(posts.at(-1), { route, params: { GAME_ID: '5', ...(button === '#gcLineCopy' ? { GAME_TYPE: '1' } : {}), LINE: 'fixture-agent', __RequestVerificationToken: 'local-csrf' } });
                checks.push(scenario + button + ': correct game, line, type and CSRF');
                check(await page.evaluate(() => reloads) === previousReloads + (scenario === 'failure' ? 0 : 1), scenario + button + ': refresh only on success');
            }
            // A delayed module must never reopen the dialog or replay a previously accepted write.
            if (scenario === 'slow') {
                const count = posts.length, dialogs = nativeCount;
                await page.waitForTimeout(2900);
                check(posts.length === count && nativeCount === dialogs && await page.locator('.messager-window:visible').count() === 0, 'late loader does not replay confirmations or writes');
            }
            await page.evaluate(() => { $('#gcLineSel').val(''); gcLineCopy(); gcLineRecall(); });
            check(await page.evaluate(() => results.length) === 2, scenario + ': empty selection does not submit');
            await page.close();
        }
        check(errors.length === 0, 'no uncaught browser errors');
        const report = { expectedOldFailure: old, checks, errors, elapsedMs: Date.now() - start };
        fs.writeFileSync(path.join(out, old ? 'before.json' : 'after.json'), JSON.stringify(report, null, 2));
        console.log(JSON.stringify({ checks: checks.length, elapsedMs: report.elapsedMs, expectedOldFailure: old }));
    } finally { await browser.close(); server.closeAllConnections(); await new Promise(resolve => server.close(resolve)); }
})().catch(error => { console.error(error); process.exitCode = 1; });
