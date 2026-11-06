'use strict';
// 真实手机列表 DOM/脚本，HTTP 全部拦截为内存数据，不连接数据库或游戏服。
const fs = require('node:fs'), path = require('node:path'), assert = require('node:assert/strict');
const { chromium } = require(process.env.PLAYWRIGHT_MODULE || 'C:/Users/Administrator/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules/playwright');
const root = path.resolve(process.env.PHONE_BET_ROOT || path.join(__dirname, '..'));
const read = file => fs.readFileSync(path.join(root, file), 'utf8');
const view = read('TTY.Web/Areas/Mobile/Views/Home/Index.cshtml');
const body = view.slice(view.indexOf('<div class="container"'), view.lastIndexOf('@section scripts'))
    .replace(/@\*[\s\S]*?\*@/g, '')
    .replace(/@if \(ViewBag\.[^\n]+\)\s*\{\s*([\s\S]*?)\s*\}/g, '$1');
const style = view.match(/<style>([\s\S]*?)<\/style>/)[1].replaceAll('@@media', '@media');
const player = (id, fields) => ({ ID: id, NAME: id, INHALL: true, GameID: 54, RoomId: 0, TableId: 0,
    TodayWinLoss: 1.2, Profit: 2.4, CurBet: 0, CurBetDiamonds: 0.4, CurBetUnitsPerCoin: 1, ...fields });
const cases = [
    [player('decimal04'), '0.4'],
    [player('decimal12', { CurBet: 1, CurBetDiamonds: 1.2 }), '1.2'],
    [player('ratio100', { CurBet: 10, CurBetDiamonds: 0.105, CurBetUnitsPerCoin: 100 }), '10.5'],
    [player('ratio3', { CurBetDiamonds: 0.13333333333333333, CurBetUnitsPerCoin: 3 }), '0.4'],
    [player('stringValues', { CurBet: 99, CurBetDiamonds: '0.999', CurBetUnitsPerCoin: '100' }), '99.9'],
    [player('zero', { CurBetDiamonds: 0 }), '0'],
    [player('integer', { CurBet: 20, CurBetDiamonds: 20 }), '20'],
    [player('missingExact', { CurBet: 1, CurBetDiamonds: null }), '--'],
    [player('missingRatio', { CurBet: 1, CurBetUnitsPerCoin: null }), '--'],
    [player('zeroRatio', { CurBetUnitsPerCoin: 0 }), '--'],
    [player('invalidExact', { CurBetDiamonds: 'invalid' }), '--'],
    [player('fish', { GameID: 3, CurBet: 1 }), '0.1'],
    [player('card', { GameID: 5, CurBet: 120 }), '120']
];
let rows = cases.map(([row]) => row), failOnline = false;
function html() {
    return `<!doctype html><html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
        <style>${read('TTY.Web/Content/css/phone.css')}\n${style}</style></head><body>
        <button id="refreshBtn">刷新</button><span id="totalWinLoss"></span><div id="mLoading" class="loading-container"></div>${body}
        <script>${read('TTY.Web/Scripts/jquery-2.1.4.min.js')}</script>
        <script>window.MConfig={page:'players',isRMB:false,exchangeRate:100,user:{accounts:'fixture'},perms:{}};</script>
        <script>${read('TTY.Web/Scripts/app/phone/phone.core.js')}</script><script>MApp.initShell();</script>
        <script>${read('TTY.Web/Scripts/app/phone/phone.players.js')}</script></body></html>`;
}
(async () => {
    const began = performance.now(), errors = [];
    const browser = await chromium.launch({ headless: true, executablePath: process.env.CHROME_PATH || 'C:/Program Files/Google/Chrome/Application/chrome.exe' });
    let checks = 0;
    try {
        const page = await browser.newPage({ viewport: { width: 390, height: 844 } });
        page.setDefaultTimeout(3000);
        page.on('pageerror', error => errors.push(error.message));
        await page.route('**/*', async route => {
            const pathname = new URL(route.request().url()).pathname;
            if (pathname === '/') return route.fulfill({ contentType: 'text/html', body: html() });
            let result;
            switch (pathname) {
                case '/Game/UserInfo/GetOnlineUsers': result = failOnline ? { code: 0 } : { code: 1, datas: rows, controls: [] }; break;
                case '/Game/UserInfo/GetOfflineUsers': result = { total: 1, rows: [player('offline')], controls: [] }; break;
                case '/Game/UserInfo/GetTodayWinLoss': result = { code: 1, datas: { total: 1.2 } }; break;
                case '/Game/UserInfo/GetActiveTotalControls': result = { code: 1, datas: [] }; break;
                case '/Game/GameSetting/GetDisplayGames': result = [{ GameId: 54, Name: '麻将胡了' }]; break;
                default: errors.push('Unexpected request: ' + pathname); return route.abort();
            }
            return route.fulfill({ contentType: 'application/json', body: JSON.stringify(result) });
        });
        await page.goto('http://phone-bet.test/');
        await page.locator('#onlinePlayersSection .player-card').first().waitFor();
        const bet = id => page.locator('.player-card[data-account="' + id + '"] .info-item')
            .filter({ has: page.getByText('押注', { exact: true }) }).locator('.info-value');
        for (const [row, expected] of cases) {
            assert.equal(await bet(row.ID).textContent(), expected, row.ID); checks++;
        }
        assert.equal(await bet('offline').textContent(), '--'); checks++;
        for (const width of [320, 390, 768]) {
            await page.setViewportSize({ width, height: 844 });
            assert.equal(await page.evaluate(() => document.documentElement.scrollWidth <= innerWidth), true); checks++;
        }
        // 用真实刷新按钮验证小数变化及查询失败后保留最后成功值。
        rows = [player('decimal04', { CurBet: 1, CurBetDiamonds: 1.7 })];
        await Promise.all([
            page.waitForResponse(response => response.url().endsWith('/GetOnlineUsers')),
            page.locator('#refreshBtn').click()
        ]);
        await page.waitForFunction(() => document.querySelector('#onlinePlayerCount').textContent === '1');
        assert.equal(await bet('decimal04').textContent(), '1.7'); checks++;
        failOnline = true;
        await page.locator('#mLoading.show').waitFor({ state: 'hidden' });
        await Promise.all([
            page.waitForResponse(response => response.url().endsWith('/GetOnlineUsers')),
            page.locator('#refreshBtn').click()
        ]);
        await page.locator('#mLoading.show').waitFor({ state: 'hidden' });
        assert.equal(await bet('decimal04').textContent(), '1.7'); checks++;
        // 旧真金展示配置仍只换算一次，历史记录继续使用原来的原始值入口。
        const legacy = await page.evaluate(() => {
            MConfig.isRMB = true; MConfig.exchangeRate = 10;
            return { card: MApp.betGold(120, 5), fish: MApp.betGold(1, 3), record: MApp.betGold(1, 54) };
        });
        assert.deepEqual(legacy, { card: '12.00', fish: '0.01', record: '0.10' }); checks++;
        assert.deepEqual(errors, []); checks++;
        console.log(JSON.stringify({ checks, seconds: Number(((performance.now() - began) / 1000).toFixed(2)), result: 'PASS' }));
    } finally { await browser.close(); }
})().catch(error => { console.error(error); process.exitCode = 1; });
