'use strict';
// 2026-11-06：玩家不在游戏里（离线卡片、在线但未坐机台的卡片、玩家详细信息、会员盈亏）时剩余分数是不足 1 钻的尾分，显示 0，
// 钻按整数钻显示不折算尾分；坐在机台上的在线玩家卡片仍显示准确机台分。真实视图 + 真实页面脚本，接口全部为本地模拟，不连数据库或游戏服。
// 运行：node Tools/dev/check-phone-tail-score.cjs [预览输出目录]
//   传入目录时额外写出可在浏览器打开的预览页（players.html / detail.html / huiyuan.html，内置模拟接口）。
const fs = require('node:fs'), path = require('node:path'), assert = require('node:assert/strict');
const { chromium } = require(process.env.PLAYWRIGHT_MODULE || 'C:/Users/Administrator/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules/playwright');
const root = path.resolve(__dirname, '../..');
const read = f => fs.readFileSync(path.join(root, f), 'utf8').replace(/^\uFEFF/, '');
const shot = path.join(root, '.build/phone-tail-score'); fs.mkdirSync(shot, { recursive: true });

function viewParts(name) {
    const v = read('TTY.Web/Areas/Mobile/Views/Home/' + name + '.cshtml');
    const style = v.match(/<style>([\s\S]*?)<\/style>/)[1].replaceAll('@@media', '@media');
    const body = v.slice(v.indexOf('<div class="container"'), v.lastIndexOf('@section scripts'))
        .replace(/@\*[\s\S]*?\*@/g, '')
        .replace(/@if \([^\n]+\)\s*\{\s*([\s\S]*?)\s*\}/g, '$1');
    return { style, body };
}
const offline = (id, score, coins) => ({ ID: id, NAME: id, AGENCY: 'sjxhly', INHALL: false, GAME_SCORE: score, Score: score, COINS: coins, Coins: coins, TodayWinLoss: -174, Profit: -174, LastLoginTime: '2026-11-06T03:08:28' });
const data = {
    '/Game/UserInfo/GetOnlineUsers': { code: 1, datas: [
        { ID: 'a18009', NAME: 'seated', AGENCY: 'sjxhly', INHALL: true, Status: 0, IsSitDown: true, GameID: 5, RoomId: 0, TableId: 0, TableDisplay: '1', CurBet: 10, GameScore: 1234, GameCoins: 60, Coins: 60, TodayWinLoss: 3, Profit: 3 },
        { ID: 'a18010', NAME: 'hall', AGENCY: 'sjxhly', INHALL: true, Status: 1, IsSitDown: false, GameID: 0, GameScore: 27, GameCoins: 5381, Coins: 5381, TodayWinLoss: -174, Profit: -174 },
        { ID: 'a18011', NAME: 'oldCenterHall', AGENCY: 'sjxhly', INHALL: true, Status: 1, GameID: 0, GameScore: 99, GameCoins: 5071, Coins: 5071, TodayWinLoss: -479, Profit: -479 },
        { ID: 'a18012', NAME: 'oldCenterSeated', AGENCY: 'sjxhly', INHALL: true, Status: 0, GameID: 5, RoomId: 0, TableId: 1, CurBet: 10, GameScore: 888, GameCoins: 0, Coins: 0, TodayWinLoss: 0, Profit: 0 }], controls: [] },
    '/Game/UserInfo/GetOfflineUsers': { total: 2, rows: [offline('a18005', 27, 5381), offline('a18001', 99, 5071)], controls: [] },
    '/Game/UserInfo/GetTodayWinLoss': { code: 1, datas: { total: 14255 } },
    '/Game/UserInfo/GetActiveTotalControls': { code: 1, datas: [] },
    '/Game/GameSetting/GetDisplayGames': [{ GameId: 5, Name: '大字版' }],
    '/Game/UserInfo/GetUserDetail': { code: 1, datas: { ID: 'a18005', NAME: 'jishhi', AGENCY: 'sjxhly', PWD: '123456', GAME_SCORE: 27, COINS: 5381, TodayBuy: 5555, TodayBack: 0, TodayWinLoss: -174, COINS_BUY: 5555, COINS_BACK: 0, TotalWinLoss: -174, Controls: [], RegTime: '2026-11-06T03:06:29', LastLoginTime: '2026-11-06T03:08:28' } },
    '/Game/UserInfo/GetMemberWinLoss': { total: 2, rows: [{ ID: 'a18005', COINS: 5381, GAME_SCORE: 27, Profit: -174, COINS_BUY: 5555, COINS_BACK: 0, TodayWinLoss: -174, TodayBuy: 5555, TodayBack: 0, AGENCY: 'sjxhly' }, { ID: 'a18001', COINS: 5071, GAME_SCORE: 99, Profit: -479, COINS_BUY: 5550, COINS_BACK: 0, TodayWinLoss: -479, TodayBuy: 5550, TodayBack: 0, AGENCY: 'sjxhly' }] },
    '/Game/UserInfo/GetMemberWinLossStats': { code: 1, datas: { TotalWinLoss: -653, TotalBuy: 11105, TotalBack: 0, TodayWinLoss: -653, TodayBuy: 11105, TodayBack: 0 } }
};
const pages = {
    players: { view: 'Index', script: 'phone.players.js', page: 'players', head: '<button id="refreshBtn">刷新</button><span id="totalWinLoss"></span><div id="mLoading" class="loading-container"></div>', preset: '{}' },
    detail: { view: 'PlayerDetail', script: 'phone.playerdetail.js', page: 'playerdetail', head: '', preset: "{account:'a18005',canModifyPwd:false}" },
    huiyuan: { view: 'Huiyuan', script: 'phone.huiyuan.js', page: 'huiyuan', head: '', preset: '{}' }
};
function html(key, mockAjax) {
    const p = pages[key], { style, body } = viewParts(p.view);
    // 预览模式：在页面内用模拟数据替换 $.ajax（不发任何网络请求）
    const mock = mockAjax ? `<script>(function(){var D=${JSON.stringify(data)};$.ajax=function(o){var d=$.Deferred(),u=String(o.url).split('?')[0];setTimeout(function(){d.resolve(D[u]||{code:1,datas:[]})},120);var pr=d.promise();pr.abort=function(){};return pr;};})();</script>` : '';
    return `<!doctype html><html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>剩余分数预览-${key}（模拟数据）</title>
<style>${read('TTY.Web/Content/css/phone.css')}\n${style}</style></head><body><input name="__RequestVerificationToken" value="fixture" hidden>${p.head}${body}
<script>${read('TTY.Web/Scripts/jquery-2.1.4.min.js')}</script>${mock}
<script>window.MConfig={page:'${p.page}',isRMB:false,exchangeRate:100,user:{accounts:'fixture',priv:0},perms:{isSuper:true}};window.MPagePreset=${p.preset};</script>
<script>${read('TTY.Web/Scripts/app/phone/phone.core.js')}</script><script>MApp.initShell && MApp.initShell();</script>
<script>${read('TTY.Web/Scripts/app/phone/' + p.script)}</script></body></html>`;
}

(async () => {
    const previewDir = process.argv[2];
    if (previewDir) { fs.mkdirSync(previewDir, { recursive: true }); for (const k of Object.keys(pages)) fs.writeFileSync(path.join(previewDir, k + '.html'), html(k, true)); }
    const began = Date.now(), errors = [];
    const browser = await chromium.launch({ headless: true, executablePath: process.env.CHROME_PATH || 'C:/Program Files/Google/Chrome/Application/chrome.exe' });
    let checks = 0;
    try {
        const page = await browser.newPage({ viewport: { width: 390, height: 844 } });
        page.setDefaultTimeout(4000);
        page.on('pageerror', e => errors.push(e.message));
        let current = 'players';
        await page.route('**/*', route => {
            const u = new URL(route.request().url());
            if (u.pathname === '/') return route.fulfill({ contentType: 'text/html', body: html(current, false) });
            if (u.pathname in data) return route.fulfill({ contentType: 'application/json', body: JSON.stringify(data[u.pathname]) });
            errors.push('Unexpected request: ' + u.pathname); return route.abort();
        });
        const card = id => page.locator('.player-card[data-account="' + id + '"] .remaining-score');

        // 在线卡片：准确机台分
        await page.goto('http://tail.test/');
        await card('a18009').waitFor();
        assert.equal(await card('a18009').innerText(), '1234分'); checks++;
        // 在线但在大厅（IsSitDown=false）：0分、整数钻；旧中心服无 IsSitDown 时按 Status/GameID 判断
        const dia = id => page.locator('.player-card[data-account="' + id + '"] .remaining-diamond').innerText();
        assert.deepEqual([await card('a18010').innerText(), await dia('a18010')], ['0分', '5381钻']); checks++;
        assert.deepEqual([await card('a18011').innerText(), await dia('a18011')], ['0分', '5071钻']); checks++;
        assert.equal(await card('a18012').innerText(), '888分'); checks++;
        await page.screenshot({ path: path.join(shot, 'players-online-390.png') });
        // 离线卡片：尾分 27 / 99 都显示 0分，钻不变
        await page.locator('.tab', { hasText: '离线玩家' }).first().click();
        await card('a18005').waitFor();
        assert.equal(await card('a18005').innerText(), '0分'); checks++;
        assert.equal(await card('a18001').innerText(), '0分'); checks++;
        assert.equal(await page.locator('.player-card[data-account="a18005"] .remaining-diamond').innerText(), '5381钻'); checks++;
        await page.screenshot({ path: path.join(shot, 'players-offline-390.png') });

        // 玩家详细信息：与列表同规则（M.playerBalance）。离线 Live=null → 0 + 库存整数钻
        const detailRow = data['/Game/UserInfo/GetUserDetail'].datas;
        const openDetail = async () => { current = 'detail'; await page.goto('http://tail.test/'); await page.waitForFunction(() => document.querySelector('#dScore').textContent !== '--'); };
        await openDetail();
        assert.deepEqual([await page.locator('#dScore').innerText(), await page.locator('#dCoins').innerText()], ['0', '5381']); checks++;
        await page.screenshot({ path: path.join(shot, 'detail-390.png') });
        // 在线但在大厅（IsSitDown=false）→ 0 + 实时整数钻
        detailRow.Live = { Status: 1, IsSitDown: false, GameID: 0, GameScore: 27, GameCoins: 5390, Coins: 5390 };
        await openDetail();
        assert.deepEqual([await page.locator('#dScore').innerText(), await page.locator('#dCoins').innerText()], ['0', '5390']); checks++;
        // 坐在机台上 → 准确机台分/钻（与在线卡片一致）
        detailRow.Live = { Status: 0, IsSitDown: true, GameID: 5, GameScore: 1234, GameCoins: 60, Coins: 60 };
        await openDetail();
        assert.deepEqual([await page.locator('#dScore').innerText(), await page.locator('#dCoins').innerText()], ['1234', '60']); checks++;
        await page.screenshot({ path: path.join(shot, 'detail-seated-390.png') });
        // 0.1 分炮鱼机坐机台：÷10 保留 1 位，与在线卡片同口径
        detailRow.Live = { Status: 0, IsSitDown: true, GameID: 3, GameScore: 125, GameCoins: 0, Coins: 0 };
        await openDetail();
        assert.equal(await page.locator('#dScore').innerText(), '12.5'); checks++;
        delete detailRow.Live;

        // 会员盈亏表格：剩余分数列 0，剩余钻不变
        current = 'huiyuan'; await page.goto('http://tail.test/');
        await page.locator('#memberList tr').first().waitFor();
        const cells = await page.locator('#memberList tr').evaluateAll(rs => rs.map(r => [r.cells[0].innerText, r.cells[1].innerText, r.cells[2].innerText]));
        assert.deepEqual(cells, [['a18005', '5381', '0'], ['a18001', '5071', '0']]); checks++;
        await page.screenshot({ path: path.join(shot, 'huiyuan-390.png') });

        assert.deepEqual(errors, []); checks++;
        console.log(JSON.stringify({ checks, seconds: +((Date.now() - began) / 1000).toFixed(2), result: 'PASS' }));
    } finally { await browser.close(); }
})().catch(e => { console.error(e); process.exit(1); });
