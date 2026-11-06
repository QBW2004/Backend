'use strict';
// 真实 EasyUI 格式化器和手机记录页；请求全部拦截，不连接数据库或游戏服。
const fs = require('node:fs'), path = require('node:path'), assert = require('node:assert/strict');
const { chromium } = require(process.env.PLAYWRIGHT_MODULE || 'C:/Users/Administrator/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules/playwright');
const web = path.resolve(__dirname, '../TTY.Web'), read = p => fs.readFileSync(path.join(web, p), 'utf8');
const script = js => '<script>' + js.replace(/<\/script/gi, '<\\/script') + '</script>';
const extract = (source, name) => {
    const m = source.match(new RegExp('(?:    |        )function ' + name + '\\([^]*?\\n(?:    |        )\\}'));
    assert.ok(m, name); return m[0];
};
const labels = ['1', '14', '贵宾桌', '<img src=x onerror=alert(1)>', '', null, '--'];
(async () => {
    const started = performance.now(); let checks = 0;
    const browser = await chromium.launch({ headless: true, executablePath: process.env.CHROME_PATH || 'C:/Program Files/Google/Chrome/Application/chrome.exe' });
    try {
        for (const item of [
            ['UserInfo/OnlineUsers', 'fmtTable', 'TableDisplay'],
            ['UserInfo/OnlinePlayers', 'fmtTable', 'CurrentTableDisplay'],
            ['UserRecord/Index', 'fmtTableId', 'TableDisplay']
        ]) {
            const page = await browser.newPage(), errors = [];
            await page.route('**/*', r => r.abort()); page.on('pageerror', e => errors.push(e.message));
            const source = read('Areas/Game/Views/' + item[0] + '.cshtml');
            const header = source.match(new RegExp('<th field="' + item[2] + '"[^]*?</th>'));
            assert.ok(header, 'actual view binding ' + item[0]);
            const rows = labels.map(label => ({ [item[2]]: label, TableId: 24, TABLE_ID: 24, OPT: 2 }));
            if (item[0] === 'UserRecord/Index') rows.push({ TableDisplay: '1', TABLE_ID: 24, OPT: 0 });
            await page.setContent('<table id="grid"><thead><tr>' + header[0] + '</tr></thead></table>'
                + script(read('Scripts/jquery-2.1.4.js')) + script(read('Scripts/jquery.easyui.min.js'))
                + script((item[0] === 'UserRecord/Index' ? extract(source, 'isGameRec') : '') + extract(source, item[1]))
                + script('$.parser.auto=false;$("#grid").datagrid({width:500,height:320,data:{total:' + rows.length + ',rows:' + JSON.stringify(rows) + '}});'));
            const cells = await page.locator('.datagrid-body td[field="' + item[2] + '"] .datagrid-cell').allTextContents();
            assert.deepEqual(cells, [...labels.map(v => v == null || v === '' ? '--' : v), ...(rows.length > labels.length ? ['--'] : [])]); checks += cells.length;
            assert.equal(await page.locator('.datagrid-body img').count(), 0); checks++;
            assert.equal(await page.evaluate(() => $('#grid').datagrid('getRows')[0].TABLE_ID), 24); checks++;
            assert.deepEqual(errors, []); checks++;
            await page.close();
        }

        const view = read('Areas/Mobile/Views/Home/GameRecord.cshtml');
        const body = view.slice(view.indexOf('<div class="container"'), view.lastIndexOf('@section scripts')).replaceAll('@today', '2026-11-06');
        const css = view.match(/<style>([^]*?)<\/style>/)[1].replaceAll('@@media', '@media');
        const records = labels.map((label, i) => ({ OPT: [2, 3, 7, 8][i % 4], TABLE_ID: 24, TableDisplay: label,
            REC_TIME: '2026-11-06T12:00:00', GAME_TYPE: 15, GameName: '大字板', SEAT_ID: 0, OPT_COINS: 100, EnterCoins: 1000, LeaveCoins: 1100 }));
        records.push({ OPT: 0, TABLE_ID: 24, TableDisplay: '1' });
        let current = records, requests = 0;
        const page = await browser.newPage({ viewport: { width: 390, height: 844 } }), errors = [];
        page.setDefaultTimeout(4000); page.on('pageerror', e => errors.push(e.message));
        await page.route('**/*', async route => {
            const url = new URL(route.request().url());
            if (url.pathname === '/') return route.fulfill({ contentType: 'text/html', body: '<!doctype html><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><style>'
                + read('Content/css/phone.css') + css + '</style><button id="refreshBtn">刷新</button><div id="mLoading"></div>' + body
                + script(read('Scripts/jquery-2.1.4.min.js'))
                + script('window.MConfig={page:"gamerecord",isRMB:false,exchangeRate:100,user:{accounts:"fixture"},perms:{}};window.MPagePreset={account:"a18001"};')
                + script(read('Scripts/app/phone/phone.core.js')) + script('MApp.initShell();')
                + script(read('Scripts/app/phone/phone.gamerecord.js')) });
            assert.equal(url.pathname, '/Game/UserRecord/GetUserRecords'); requests++;
            return route.fulfill({ contentType: 'application/json', body: JSON.stringify({ total: current.length, rows: current }) });
        });
        await page.goto('http://player-table.test/');
        await page.locator('#recordTableBody tr').first().waitFor();
        assert.deepEqual(await page.locator('#recordTableBody tr td:nth-child(3)').allTextContents(), [...labels.map(v => v == null || v === '' ? '--' : v), '--']); checks += records.length;
        assert.equal(await page.locator('#recordTableBody img').count(), 0); checks++;
        for (const width of [320, 390, 768]) {
            await page.setViewportSize({ width, height: 844 });
            assert.ok(await page.evaluate(() => document.documentElement.scrollWidth <= innerWidth)); checks++;
        }
        current = [{ ...records[0], TableDisplay: '2', TABLE_ID: 25 }];
        await Promise.all([page.waitForResponse(r => r.url().endsWith('/GetUserRecords')), page.locator('#filterBtn').click()]);
        await page.waitForFunction(() => document.querySelector('#recordTableBody tr td:nth-child(3)').textContent === '2'); checks++;
        assert.ok(requests >= 2); checks++;
        assert.deepEqual(errors, []); checks++;
        console.log(JSON.stringify({ result: 'PASS', checks, seconds: Number(((performance.now() - started) / 1000).toFixed(2)) }));
    } finally { await browser.close(); }
})().catch(e => { console.error(e); process.exitCode = 1; });
