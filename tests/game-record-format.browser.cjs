'use strict';
// Real shared script, page formatters and EasyUI; fixture data only, no HTTP/DB.
const fs = require('node:fs'), path = require('node:path'), assert = require('node:assert/strict');
const { chromium } = require(process.env.PLAYWRIGHT_MODULE || 'C:/Users/Administrator/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules/playwright');
const root = path.resolve(__dirname, '..'), web = path.join(root, 'TTY.Web');
const read = p => fs.readFileSync(path.join(web, p), 'utf8');
function extract(source, name) {
    const match = source.match(new RegExp('        function ' + name + '\\([^]*?\\n        \\}'));
    assert.ok(match, 'Function exists: ' + name);
    return match[0];
}
const shared = read('Scripts/app/gold-format.js');
const libraries = read('Scripts/jquery-2.1.4.js') + '\n' + read('Scripts/jquery.easyui.min.js') + '\n' + read('Scripts/app/common.js');
const cases = [
    { name: 'AgencyInfo/Index', functions: ['fmtCoins'], formatter: 'fmtCoins' },
    { name: 'AgencyRecord/Index', functions: ['escapeAuditHtml', 'fmtOptType', 'fmtContents', 'getRechargeExchangeMsg', 'getAngencyMsg'], formatter: 'fmtContents' },
    { name: 'UserRecord/Index', functions: ['isGameRec', 'isDecimalBetFish', 'fmtContents', 'getRechargeExchageMsg', 'getLoginMgs', 'fmtBet', 'fmtWinLoss', 'fmtScore'], formatter: 'fmtContents' },
    { name: 'GameRecord/TableRecords', functions: ['fmtCoins'], formatter: 'fmtCoins' }
];
const row = { amount: 123.45, OPT: 0, UserID: 'fixture', ID: 'fixture', OptID: 'operator', SrcUserTitle: '代理', DestUserTitle: '玩家', COINS: 123.45, BEF_COINS: 0, AFT_COINS: 123.45 };
const script = js => '<script>' + js.replace(/<\/script/gi, '<\\/script') + '</script>';
const attr = text => text.replace(/&/g, '&amp;').replace(/"/g, '&quot;').replace(/</g, '&lt;');
for (const file of ['Views/Mgr/Index.cshtml', 'Views/Shared/Layout/_ContentLayout.cshtml']) {
    const source = read(file);
    assert.ok(source.includes('~/Scripts/app/gold-format.js?v='), file + ' loads shared script');
    assert.ok(source.indexOf('window.isRMB') < source.indexOf('gold-format.js'), file + ' initializes configuration first');
}
(async () => {
    const started = Date.now(), results = [];
    const browser = await chromium.launch({ headless: true, executablePath: process.env.CHROME_PATH || 'C:/Program Files/Google/Chrome/Application/chrome.exe' });
    try {
        for (const item of cases) {
            const source = read('Areas/Game/Views/' + item.name + '.cshtml');
            assert.ok(!source.includes('top.goldFormat'), item.name + ' is independent of parent');
            const fishIds = source.match(/var _decimalBetFishIds = \[[^\]]*\];/);
            const functions = (fishIds ? fishIds[0] : '') + '\n' + item.functions.map(n => extract(source, n)).join('\n');
            for (const converted of [false, true]) for (const mode of ['direct', 'pc-frame', 'plain-frame']) {
                const page = await browser.newPage(), errors = [];
                await page.route('**/*', route => route.abort());
                page.on('pageerror', e => errors.push(e.message));
                const config = 'window.isRMB=' + converted + ';window.ExchangeRate="10";';
                const init = '$.parser.auto=false;$("#grid").datagrid({width:800,height:200,columns:[[{field:"amount",title:"amount",width:700,formatter:' + item.formatter + '}]],data:{total:1,rows:[' + JSON.stringify(row) + ']}});';
                const child = '<!doctype html><meta charset="utf-8"><table id="grid"></table>' + script(config + shared) + script(libraries) + script(functions) + script(init);
                const html = mode === 'direct' ? child : '<!doctype html>' + (mode === 'pc-frame' ? script(config + shared) : '') + '<iframe srcdoc="' + attr(child) + '"></iframe>';
                await page.setContent(html, { waitUntil: 'load' });
                const target = mode === 'direct' ? page.mainFrame() : page.frames().find(f => f !== page.mainFrame());
                const state = await target.evaluate(() => ({ text: document.querySelector('.datagrid-body td[field="amount"]').textContent, topType: typeof top.goldFormat }));
                const amount = converted ? '12.35' : '123.45';
                assert.ok(state.text.includes(amount), item.name + ': ' + state.text);
                if (item.name === 'GameRecord/TableRecords') assert.ok(state.text.startsWith('-'), 'table sign preserved');
                if (mode === 'plain-frame') assert.equal(state.topType, 'undefined');
                if (mode === 'pc-frame') assert.equal(await target.evaluate(() => top.goldFormat(123.45)), converted ? '12.35' : 123.45);
                if (item.name === 'UserRecord/Index') {
                    const bet = await target.evaluate(() => fmtBet(25, { OPT: 3, GAME_TYPE: 3 }));
                    assert.equal(bet, converted ? '0.25' : '2.5', 'fish tenth scaling preserved');
                    const loss = await target.evaluate(() => fmtScore(0, { OPT: 3, EnterCoins: 100, LeaveCoins: 50 }));
                    assert.ok(loss.includes(converted ? '-5.00' : '-50'), 'loss sign preserved');
                }
                const boundary = await target.evaluate(() => [goldFormat(0), goldFormat(-12.5), goldFormat(0.30000000000000004), goldFormat('2.5'), goldFormat('123'), goldFormat(null), goldFormat(undefined)]);
                assert.deepEqual(boundary, converted ? ['0.00', '-1.25', '0.03', '0.25', '123', null, undefined] : [0, -12.5, 0.3, '2.5', '123', null, undefined]);
                assert.deepEqual(errors, [], item.name + ' pageerrors');
                results.push({ page: item.name, converted, mode, result: 'PASS' });
                await page.close();
            }
        }
    } finally { await browser.close(); }
    console.log(JSON.stringify({ result: 'PASS', scenarios: results.length, elapsedMs: Date.now() - started, results }, null, 2));
})().catch(e => { console.error(e); process.exitCode = 1; });
