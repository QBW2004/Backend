// Uses the real Razor page JS and bundled EasyUI in a local browser; all API replies are fixtures.
// node Tools/dev/check-card-robot-browser.js <playwright-module> <chromium-exe> [output-directory]
const fs = require('fs');
const path = require('path');
const http = require('http');
const assert = require('assert');
const { chromium } = require(process.argv[2] || 'playwright');
const root = path.resolve(__dirname, '../../TTY.Web');
const output = process.argv[4];
const source = fs.readFileSync(path.join(root, 'Areas/Game/Views/Robot/Index.cshtml'), 'utf8');
const script = source.match(/@section include_res\{\s*<script>([\s\S]*?)<\/script>/)[1]
    .replace(/@Html.Raw\(@"([\s\S]*?)"\);/g, (_, js) => js.replace(/""/g, '"'));
const body = source.slice(source.indexOf('<form id="frm_srch">')).replace(/@\*[\s\S]*?\*@/g, '');
const html = `<!doctype html><html><head><meta charset="utf-8">
<link rel="stylesheet" href="/Content/easyui/themes/bootstrap/easyui.css">
<link rel="stylesheet" href="/Content/easyui/themes/icon.css">
<link rel="stylesheet" href="/Content/css/layout.css">
<script src="/Scripts/jquery-2.1.4.js"></script>
<script src="/Scripts/easyloader.js"></script>
<script src="/Scripts/app/common.js"></script>
<script>${script}</script></head><body><div class="main">${body}</div></body></html>`;
const saves = [];
const errors = [];
const mime = { '.js': 'application/javascript', '.css': 'text/css', '.png': 'image/png', '.gif': 'image/gif' };
const server = http.createServer(async (req, res) => {
    if (req.url === '/') { res.setHeader('Content-Type', 'text/html; charset=utf-8'); res.end(html); return; }
    if (req.url.startsWith('/Game/Robot/')) {
        let payload = '';
        for await (const chunk of req) payload += chunk;
        const params = Object.fromEntries(new URLSearchParams(payload));
        if (process.env.ROBOT_UI_DEBUG) console.log(req.url, params);
        let data;
        switch (req.url) {
            case '/Game/Robot/GetRobot': data = { total: 0, rows: [] }; break;
            case '/Game/Robot/GetRobotLineFilter': data = [{ id: '*', text: '全部', selected: true }]; break;
            case '/Game/Robot/GetGamesTreeData':
                data = [{ id: Number(params.GameType), children: [{ id: 5, text: '火凤凰' }] }]; break;
            case '/Game/Robot/GetRobotLineOptions':
                data = [{ id: '_public', text: '公共桌台', selected: true }, { id: 'sucai', text: 'sucai（24张专属桌台）' }, { id: 'empty', text: '无机台' }]; break;
            case '/Game/Robot/GetCardRobotCapacity':
                data = params.Line === 'sucai' ? { code: 1, total: 24, current: 10, remaining: 14 }
                    : params.Line === 'empty' ? { code: 1, total: 0, current: 0, remaining: 0 }
                        : { code: 1, total: 10, current: 2, remaining: 8 }; break;
            case '/Game/Robot/GetRobotTableList': data = [{ id: 0, text: '桌台1', selected: true }]; break;
            case '/Game/Robot/SaveRobot': saves.push(params); data = { code: 1, content: '机器人已保存' }; break;
            default: res.statusCode = 404; res.end(req.url); return;
        }
        res.setHeader('Content-Type', 'application/json; charset=utf-8');
        res.end(JSON.stringify(data));
        return;
    }
    const file = path.resolve(root, '.' + new URL(req.url, 'http://localhost').pathname);
    if (!file.startsWith(root + path.sep) || !fs.existsSync(file) || !fs.statSync(file).isFile()) {
        res.statusCode = 404; res.end(); return;
    }
    res.setHeader('Content-Type', mime[path.extname(file)] || 'application/octet-stream');
    res.end(fs.readFileSync(file));
});

(async () => {
    const start = Date.now();
    let browser;
    try {
        await new Promise(resolve => server.listen(0, '127.0.0.1', resolve));
        browser = await chromium.launch({ headless: true, executablePath: process.argv[3] || undefined });
        const page = await browser.newPage({ viewport: { width: 1100, height: 850 } });
        page.setDefaultTimeout(8000);
        page.on('pageerror', error => errors.push(error.message));
        await page.goto(`http://127.0.0.1:${server.address().port}/`);
        await page.waitForFunction(() => window.robotInputsReady && $('#addGameType').data('combobox') && $('#addCardRobotNo').data('numberbox') && $('#addLine').data('combobox'));
        await page.getByText('添加机器人', { exact: true }).click();
        await page.locator('#addWin').waitFor({ state: 'visible' });
        async function select(id, value) {
            await page.evaluate(({ id, value }) => $(id).combobox('setValue', value), { id, value });
        }
        await select('#addGameType', 1);
        await page.waitForFunction(() => $('#addGameId').combobox('getData').some(row => row.id === 5));
        await select('#addGameId', 5);
        await page.waitForFunction(() => $('#addLine').combobox('getData').some(row => row.id === 'sucai'));
        await page.waitForFunction(() => cardCapacityReady);
        await select('#addLine', 'sucai');
        if (process.env.ROBOT_UI_DEBUG) console.log(await page.evaluate(() => ({ line: $('#addLine').combobox('getValue'), ready: cardCapacityReady, total: cardTotal, version: roomRequestVersion, fields: $('#form3').serializeArray() })));
        await page.waitForFunction(() => cardCapacityReady && cardTotal === 24);
        const input = page.locator('#addCardRobotNo + span input.textbox-text');
        const disabled = await input.isDisabled();
        console.log('sucai capacity=24 current=10 visibleInputDisabled=' + disabled);
        if (output) { fs.mkdirSync(output, { recursive: true }); await page.screenshot({ path: path.join(output, 'card-robot.png') }); }
        assert.strictEqual(disabled, false, 'capacity response must enable the actual EasyUI input');
        assert.strictEqual(await input.inputValue(), '10');
        assert((await input.boundingBox()).width > 100, 'visible number input retains its width');
        await input.fill('12');
        await page.getByText('保存', { exact: true }).click();
        await page.waitForFunction(() => $('.messager-body').length > 0);
        assert.strictEqual(saves.length, 1, 'save button accepts a real click');
        assert.deepStrictEqual(saves[0], { GameType: '1', GameId: '5', Line: 'sucai', RobotNo: '12' });
        await page.getByText('确定', { exact: true }).click();
        // Reopening the same dialog repeats the disable/reconfigure cycle that triggered the defect.
        await page.getByText('添加机器人', { exact: true }).click();
        await page.locator('#addWin').waitFor({ state: 'visible' });
        await select('#addGameType', 1);
        await page.waitForFunction(() => $('#addGameId').combobox('getData').some(row => row.id === 5));
        await select('#addGameId', 5);
        await page.waitForFunction(() => cardCapacityReady);
        await select('#addLine', 'empty');
        await page.waitForFunction(() => cardCapacityReady && cardTotal === 0);
        assert.strictEqual(await input.isDisabled(), true, 'zero-capacity line stays disabled');
        await select('#addLine', 'sucai');
        await page.waitForFunction(() => cardCapacityReady && cardTotal === 24);
        assert.strictEqual(await input.isDisabled(), false, 'switching back restores editing');
        await input.fill('0');
        await page.getByText('保存', { exact: true }).click();
        await page.waitForFunction(() => $('.messager-body').length > 0);
        assert.strictEqual(saves.length, 2);
        assert.strictEqual(saves[1].RobotNo, '0', 'clearing robots is submitted as zero');
        assert.deepStrictEqual(errors, [], 'no browser JS errors');
        console.log(`PASS real EasyUI browser: editable count, prefill, width, save payload, reopen, line switch, zero target (${Date.now() - start} ms)`);
    } finally {
        if (browser) await browser.close();
        server.close();
    }
})().catch(error => { console.error(error); console.error('Browser errors:', errors); process.exitCode = 1; });
