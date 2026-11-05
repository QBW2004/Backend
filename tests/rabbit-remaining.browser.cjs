'use strict';
// 真实活动配置视图 + 隔离 MySQL 测试产生的 MVC 回包；仅启动本机 HTTP，无线上写入。
const fs = require('node:fs'), path = require('node:path'), http = require('node:http'), assert = require('node:assert/strict');
const { chromium } = require(process.env.PLAYWRIGHT_MODULE || 'C:/Users/Administrator/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules/playwright');
const root = path.resolve(__dirname, '..'), web = path.join(root, 'TTY.Web');
const out = path.join(root, '.build/rabbit-remaining-validation');
const raw = fs.readFileSync(process.env.RABBIT_REMAINING_VIEW || path.join(web, 'Areas/Game/Views/ActivityConfig/Index.cshtml'), 'utf8');
const body = raw.slice(raw.indexOf('<div class="ac-wrap">'))
    .replace('@Html.AntiForgeryToken()', '<input name="__RequestVerificationToken" type="hidden" value="fixture">')
    .replace(/@Url.Action\("([^"]+)",\s*"([^"]+)"[^)]*\)/g, (_, a, c) => '/' + c + '/' + a);
const html = `<!doctype html><meta charset="utf-8"><style>${raw.match(/<style>([\s\S]*?)<\/style>/)[1]}</style>
<script src="/Scripts/jquery-2.1.4.js"></script><script src="/Scripts/easyloader.js"></script><script src="/Scripts/app/common.js"></script>${body}`;
let data = JSON.parse(fs.readFileSync(path.join(out, 'scheduled/remaining-zero.json'), 'utf8'));
const errors = [], checks = [];
const server = http.createServer((req, res) => {
    const route = new URL(req.url, 'http://localhost').pathname;
    if (route === '/') { res.setHeader('Content-Type', 'text/html;charset=utf-8'); return res.end(html); }
    if (route === '/ActivityConfig/GetRabbitRace') { res.setHeader('Content-Type', 'application/json;charset=utf-8'); return res.end(JSON.stringify(data)); }
    const file = path.resolve(web, '.' + route);
    if (file.startsWith(web + path.sep) && fs.existsSync(file) && fs.statSync(file).isFile()) return res.end(fs.readFileSync(file));
    res.statusCode = 404; res.end();
});
(async () => {
    const started = performance.now();
    await new Promise(r => server.listen(0, '127.0.0.1', r));
    const browser = await chromium.launch({ headless: true, executablePath: process.env.CHROME_PATH || 'C:/Program Files/Google/Chrome/Application/chrome.exe' });
    try {
        const page = await browser.newPage({ viewport: { width: 1100, height: 800 } });
        page.on('pageerror', e => errors.push(e.message));
        await page.goto('http://127.0.0.1:' + server.address().port);
        await page.waitForFunction(() => document.querySelector('#acUsed').textContent === '50');
        async function checkRemaining(expected, label) {
            await page.waitForFunction(e => document.querySelector('#acRemain').textContent === e, expected);
            assert.ok(await page.locator('#acRemain').isVisible(), label + ': visible'); checks.push(label);
        }
        await checkRemaining('0', 'exhausted actual MVC response displays 0');
        assert.match(await page.locator('.ac-guide').innerText(), /下一次设定的开始时间才恢复/); checks.push('scheduled reset guidance');
        await page.screenshot({ path: path.join(out, 'remaining-zero.png') });
        for (const [enabled, value, expected, label] of [
            [true, 1, '1', 'one available'], [true, 50, '50', 'full quota'],
            [true, 0, '0', 'positive then exhausted'], [false, 0, '0', 'disabled zero'],
            [true, null, '0', 'null fallback'], [true, -1, '0', 'negative lower bound']
        ]) {
            data = { ...data, enabled, remainingToday: value };
            const reply = page.waitForResponse(r => r.url().endsWith('/ActivityConfig/GetRabbitRace'));
            await page.locator('#acReload').click(); await reply;
            await checkRemaining(expected, label);
        }
        assert.deepEqual(errors, []); checks.push('no browser script errors');
        console.log(`PASS ${checks.length} Chromium checks in ${((performance.now() - started) / 1000).toFixed(3)}s`);
    } finally { await browser.close(); server.close(); }
})().catch(e => { console.error(e); server.close(); process.exitCode = 1; });
