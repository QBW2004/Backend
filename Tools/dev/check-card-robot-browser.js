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
const body = source.slice(source.indexOf('<div id="robotWorkspace"')).replace(/@\*[\s\S]*?\*@/g, '');
const styles = source.match(/<style>([\s\S]*?)<\/style>/)[1].replace(/@@/g, '@');
const html = `<!doctype html><html><head><meta charset="utf-8">
<link rel="stylesheet" href="/Content/easyui/themes/bootstrap/easyui.css">
<link rel="stylesheet" href="/Content/easyui/themes/icon.css">
<link rel="stylesheet" href="/Content/css/layout.css">
<script src="/Scripts/jquery-2.1.4.js"></script>
<script src="/Scripts/easyloader.js"></script>
<script src="/Scripts/app/common.js"></script>
<script>${script}</script><style>${styles}</style></head><body><div class="main">${body}</div></body></html>`;
const saves = [];
const errors = [];
const calls = [];
let statusUnavailable = false;
let scheduleUnavailable = false;
let playTimeUnavailable = false;
let playTime = { code: 1, Enabled: false, MinHours: 2, MaxHours: 4 };
let schedule = { Enabled: 0, StartTime: '02:00', EndTime: '05:00' };
let accounts = Array.from({ length: 27 }, (_, i) => ({
    RobotId: i + 1, UserName: 'robot' + (i + 1), UserNick: '测试账户' + (i + 1),
    Ico: 0, Lev: 1, Sex: i % 2, Gold: 100000,
    GAME_NAME: i < 20 ? '火凤凰' : '', GAME_ID: i < 20 ? 5 : -1,
    LINE_AGENT: i < 20 ? 'sucai' : '', TABLE_NAME: i < 20 ? (i + 1) + '号机' : '', TABLE_ID: i < 20 ? i : -1,
    SeatIndex: i < 20 ? 0 : -1, Connected: i < 22, Sitting: i < 20,
    Status: i < 20 ? '已入座' : (i < 22 ? '未入座' : '未上线')
}));
const mime = { '.js': 'application/javascript', '.css': 'text/css', '.png': 'image/png', '.gif': 'image/gif' };
const server = http.createServer(async (req, res) => {
    if (req.url === '/') { res.setHeader('Content-Type', 'text/html; charset=utf-8'); res.end(html); return; }
    if (req.url.startsWith('/Game/Robot/') || req.url.startsWith('/Game/UserRobot/')) {
        let payload = '';
        for await (const chunk of req) payload += chunk;
        const params = Object.fromEntries(new URLSearchParams(payload));
        calls.push({ url: req.url, params });
        if (process.env.ROBOT_UI_DEBUG) console.log(req.url, params);
        let data;
        switch (req.url) {
            case '/Game/Robot/GetRobot': {
                let rows = [
                    { ID: 0, GAME_ID: 5, GAME_NAME: '火凤凰', LINE_AGENT: 'sucai', TOTAL_SEATS: 24, CONFIGURED_ROBOT_COUNT: 10, ROBOT_COUNT: statusUnavailable ? -1 : 8 },
                    { ID: 0, GAME_ID: 16, GAME_NAME: '明星97', LINE_AGENT: 'sucai', TOTAL_SEATS: 12, CONFIGURED_ROBOT_COUNT: 5, ROBOT_COUNT: statusUnavailable ? -1 : 3 }
                ];
                if (params.GameId && Number(params.GameId) >= 0) rows = rows.filter(r => r.GAME_ID === Number(params.GameId));
                data = { total: rows.length, rows }; break;
            }
            case '/Game/Robot/GetRobotSeats': {
                if (statusUnavailable) { data = { code: 0, content: '机器人状态暂不可用' }; break; }
                let rows = accounts.filter(r => !params.SeatAccount || r.UserName.includes(params.SeatAccount) || r.UserNick.includes(params.SeatAccount));
                if (Number(params.SeatGameId) >= 0 && params.SeatGameId) rows = rows.filter(r => r.GAME_ID === Number(params.SeatGameId));
                if (params.SeatLine && params.SeatLine !== '*') rows = rows.filter(r => r.LINE_AGENT === (params.SeatLine === '_public' ? '' : params.SeatLine));
                if (params.SeatStatus === 'idle') rows = rows.filter(r => !r.Sitting);
                if (params.SeatStatus === 'offline') rows = rows.filter(r => !r.Connected);
                if (params.SeatStatus === 'seated') rows = rows.filter(r => r.Sitting);
                const total = rows.length, size = Number(params.rows || 20), page = Number(params.page || 1);
                data = { code: 1, total, rows: rows.slice((page - 1) * size, page * size), summary: {
                    Total: accounts.length, Online: accounts.filter(r => r.Connected).length,
                    Seated: accounts.filter(r => r.Sitting).length, Idle: accounts.filter(r => !r.Sitting).length
                } }; break;
            }
            case '/Game/Robot/GetRobotLineFilter': data = [{ id: '*', text: '全部', selected: true }, { id: 'sucai', text: 'sucai' }]; break;
            case '/Game/Robot/GetRobotShuffleSchedule': data = scheduleUnavailable ? { code: 0, content: '计划读取失败' } : schedule; break;
            case '/Game/Robot/GetRobotPlayTime': data = playTimeUnavailable ? { code: 0, content: '游玩时长读取失败' } : playTime; break;
            case '/Game/Robot/SaveRobotPlayTime': playTime = { code: 1, Enabled: params.Enabled === '1', MinHours: Number(params.MinHours), MaxHours: Number(params.MaxHours) }; data = { code: 1, content: '游玩时长已保存' }; break;
            case '/Game/Robot/GetRobotSeatOptions': data = { code: 1, GameId: 5, Line: '_public', TableId: 0, SeatIndex: 0 }; break;
            case '/Game/Robot/GetGamesTreeData':
                data = [{ id: Number(params.GameType), children: Number(params.GameType) === 3
                    ? [{ id: 16, text: '明星97' }, { id: 40, text: '水果拉霸' }, { id: 53, text: '水浒传' }]
                    : Number(params.GameType) === -1 ? [{ id: 5, text: '火凤凰' }, { id: 16, text: '明星97' }, { id: 40, text: '水果拉霸' }, { id: 53, text: '水浒传' }]
                        : [{ id: 5, text: '火凤凰' }] }]; break;
            case '/Game/Robot/GetRobotLineOptions':
                data = [{ id: '_public', text: '公共桌台', selected: true }, { id: 'sucai', text: 'sucai（24张专属桌台）' }, { id: 'empty', text: '无机台' }]; break;
            case '/Game/Robot/GetCardRobotCapacity':
                data = params.Line === 'sucai' ? { code: 1, total: 24, current: 10, remaining: 14 }
                    : params.Line === 'empty' ? { code: 1, total: 0, current: 0, remaining: 0 }
                        : { code: 1, total: 10, current: 2, remaining: 8 }; break;
            case '/Game/Robot/GetRobotTableList': data = [{ id: 0, text: '桌台1', selected: true }]; break;
            case '/Game/Robot/SaveRobot': saves.push(params); data = { code: 1, content: '机器人已保存' }; break;
            case '/Game/Robot/RemoveRobotSeat': data = { code: 1, content: '机器人已离座' }; break;
            case '/Game/Robot/ShuffleRobots': data = { code: 1, content: '已开始打乱机器人' }; break;
            case '/Game/Robot/SaveRobotShuffleSchedule': schedule = { Enabled: Number(params.Enabled), StartTime: params.StartTime, EndTime: params.EndTime }; data = { code: 1, content: '定时打乱已保存' }; break;
            case '/Game/Robot/SetRobotSeat': data = { code: 1, content: '机器人座位已保存' }; break;
            case '/Game/Robot/OnlineRobot': data = { code: 1, content: '机器人已上线' }; break;
            case '/Game/Robot/ReloadRobotAccounts': data = { code: 1, content: '账户已刷新' }; break;
            case '/Game/Robot/BatchDeleteRobotAccounts': accounts = accounts.filter(r => !params.Ids.split(',').includes(String(r.RobotId))); data = { code: 1, content: '已删除选中账户' }; break;
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
        await page.waitForFunction(() => $('#robotStatTotal').text() === '27');
        assert.strictEqual(await page.locator('.robot-panel:visible').count(), 1);
        assert.strictEqual(await page.locator('#robot-live').isVisible(), true);
        assert.strictEqual(await page.locator('#robotStatOnline').innerText(), '22');
        assert.strictEqual(await page.locator('#robotStatSeated').innerText(), '20');
        assert.strictEqual(await page.locator('#robotStatIdle').innerText(), '7');
        assert.strictEqual(calls.filter(c => c.url.endsWith('/GetRobotSeats')).length, 1, 'only one initial live query');
        assert.strictEqual(await page.locator('#robot-live').getByText('删除账户', { exact: true }).count(), 0);
        if (output) { fs.mkdirSync(output, { recursive: true }); await page.screenshot({ path: path.join(output, 'live.png') }); }
        await page.getByRole('tab', { name: '座位配置' }).click();
        await page.waitForFunction(() => $('#quotaFilterGame').combobox('getData').length === 5);
        assert.strictEqual(await page.locator('#quotaFilterGame + span input.textbox-text').evaluate(input => input.readOnly), true);
        await page.locator('#quotaFilterGame + span .combo-arrow').click();
        await page.locator('.combobox-item:visible').filter({ hasText: /^明星97$/ }).click();
        await page.getByRole('button', { name: '查询配置' }).click();
        await page.waitForFunction(() => $('#tb_Robot').datagrid('getData').total === 1 && $('#tb_Robot').datagrid('getRows')[0].GAME_ID === 16);
        assert.strictEqual(calls.filter(c => c.url.endsWith('/GetRobot')).at(-1).params.GameId, '16');
        assert(!('GameName' in calls.filter(c => c.url.endsWith('/GetRobot')).at(-1).params));
        assert.strictEqual(await page.evaluate(() => $('#seatFilterGame').combobox('getValue')), '-1', 'quota dropdown does not change live game filter');
        if (output) await page.screenshot({ path: path.join(output, 'quota-game-dropdown.png') });
        await page.locator('#quotaFilterGame + span .combo-arrow').click();
        await page.locator('.combobox-item:visible').filter({ hasText: /^全部游戏$/ }).click();
        await page.getByRole('button', { name: '查询配置' }).click();
        await page.waitForFunction(() => $('#tb_Robot').datagrid('getData').total === 2);
        for (const [type, game] of [[1, 5], [3, 16], [3, 40], [3, 53]]) {
        const beforeSaves = saves.length;
        await page.getByText('设置机器人数量', { exact: true }).click();
        await page.locator('#addWin').waitFor({ state: 'visible' });
        async function select(id, value) {
            await page.evaluate(({ id, value }) => $(id).combobox('setValue', value), { id, value });
        }
        await select('#addGameType', type);
        await page.waitForFunction(id => $('#addGameId').combobox('getData').some(row => row.id === id), game);
        await select('#addGameId', game);
        await page.waitForFunction(() => $('#addLine').combobox('getData').some(row => row.id === 'sucai'));
        await page.waitForFunction(() => cardCapacityReady);
        await select('#addLine', 'sucai');
        if (process.env.ROBOT_UI_DEBUG) console.log(await page.evaluate(() => ({ line: $('#addLine').combobox('getValue'), ready: cardCapacityReady, total: cardTotal, version: roomRequestVersion, fields: $('#form3').serializeArray() })));
        await page.waitForFunction(() => cardCapacityReady && cardTotal === 24);
        const input = page.locator('#addCardRobotNo + span input.textbox-text');
        const disabled = await input.isDisabled();
        console.log('sucai capacity=24 current=10 visibleInputDisabled=' + disabled);
        if (output) { fs.mkdirSync(output, { recursive: true }); await page.screenshot({ path: path.join(output, `robot-${game}.png`) }); }
        assert.strictEqual(disabled, false, 'capacity response must enable the actual EasyUI input');
        assert.strictEqual(await input.inputValue(), '10');
        assert((await input.boundingBox()).width > 100, 'visible number input retains its width');
        await input.fill('12');
        await page.getByText('保存', { exact: true }).click();
        await page.waitForFunction(() => $('.messager-body').length > 0);
        assert.strictEqual(saves.length, beforeSaves + 1, 'save button accepts a real click');
        assert.deepStrictEqual(saves[beforeSaves], { GameType: String(type), GameId: String(game), Line: 'sucai', RobotNo: '12' });
        await page.getByText('确定', { exact: true }).click();
        // Reopening the same dialog repeats the disable/reconfigure cycle that triggered the defect.
        await page.getByText('设置机器人数量', { exact: true }).click();
        await page.locator('#addWin').waitFor({ state: 'visible' });
        await select('#addGameType', type);
        await page.waitForFunction(id => $('#addGameId').combobox('getData').some(row => row.id === id), game);
        await select('#addGameId', game);
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
        assert.strictEqual(saves.length, beforeSaves + 2);
        assert.strictEqual(saves[beforeSaves + 1].RobotNo, '0', 'clearing robots is submitted as zero');
        await page.getByText('确定', { exact: true }).click();
        }
        // Filters stay scoped to their own tabs; overview stays global even with one filtered row.
        await page.getByRole('tab', { name: '实时状态' }).click();
        await page.locator('#seatFilterAccount + span input.textbox-text').fill('robot27');
        await page.getByRole('button', { name: '筛选', exact: true }).click();
        await page.waitForFunction(() => $('#tb_RobotSeat').datagrid('getData').total === 1);
        assert.strictEqual(await page.locator('#robotStatTotal').innerText(), '27');
        assert.strictEqual(await page.locator('#robot-live').getByText('移除座位', { exact: true }).count(), 0, 'offline accounts have no remove-seat action');
        await page.getByRole('tab', { name: '账户管理' }).click();
        await page.waitForFunction(() => $('#tb_RobotAccount').data('datagrid') && $('#tb_RobotAccount').datagrid('getData').total === 27);
        assert.strictEqual(await page.locator('#deleteSelectedAccounts').isDisabled(), true);
        await page.locator('#robot-accounts .datagrid-body input[type=checkbox]').first().check();
        await page.evaluate(() => $('#tb_RobotAccount').datagrid('getPager').pagination('select', 2));
        await page.waitForFunction(() => $('#tb_RobotAccount').datagrid('getRows')[0].RobotId === 21);
        assert.strictEqual(await page.locator('#deleteSelectedAccounts').isDisabled(), true, 'paging clears old selections');
        await page.evaluate(() => $('#tb_RobotAccount').datagrid('getPager').pagination('select', 1));
        await page.waitForFunction(() => $('#tb_RobotAccount').datagrid('getRows')[0].RobotId === 1);
        const checks = page.locator('#robot-accounts .datagrid-body input[type=checkbox]');
        await checks.nth(0).check(); await checks.nth(1).check();
        assert.strictEqual(await page.locator('#robotSelectedCount').innerText(), '已选 2 个');
        if (output) await page.screenshot({ path: path.join(output, 'accounts.png') });
        await page.getByRole('button', { name: '删除选中账户', exact: true }).click();
        await page.getByText('确定', { exact: true }).click();
        await page.waitForFunction(() => $('#tb_RobotAccount').datagrid('getData').total === 25);
        assert.deepStrictEqual(calls.find(c => c.url.endsWith('/BatchDeleteRobotAccounts')).params, { Ids: '1,2', ids: '1,2' });
        await page.getByText('确定', { exact: true }).click();
        assert.strictEqual(await page.locator('#deleteSelectedAccounts').isDisabled(), true);
        assert.strictEqual(await page.locator('#robotSelectedCount').innerText(), '已选 0 个');
        await page.getByRole('tab', { name: '实时状态' }).click();
        assert.strictEqual(await page.locator('#seatFilterAccount + span input.textbox-text').inputValue(), 'robot27');
        await page.getByRole('button', { name: '重置', exact: true }).click();
        await page.waitForFunction(() => $('#tb_RobotSeat').datagrid('getData').total === 25);

        await page.getByRole('tab', { name: '自动调度' }).click();
        await page.waitForFunction(() => $('#scheduleStatus').text() === '未启用');
        await page.waitForFunction(() => $('#playTimeStatus').text() === '未启用');
        const playTimeCard = page.locator('.robot-schedule-card').filter({ has: page.locator('#playTimeEnabled') });
        const shuffleCard = page.locator('.robot-schedule-card').filter({ has: page.locator('#shuffleEnabled') });
        assert(await playTimeCard.innerText().then(text => text.includes('1～5 分钟') && text.includes('原座位')));
        await page.locator('#playTimeEnabled').check();
        await page.evaluate(() => { $('#playTimeMinHours').numberbox('setValue', 1.5); $('#playTimeMaxHours').numberbox('setValue', 3); });
        await page.locator('#saveRobotPlayTime').click();
        await page.waitForFunction(() => $('#playTimeStatus').text() === '已启用 · 1.5～3 小时');
        assert.deepStrictEqual(calls.find(c => c.url.endsWith('/SaveRobotPlayTime')).params, { Enabled: '1', MinHours: '1.5', MaxHours: '3' });
        await page.getByText('确定', { exact: true }).click();
        const savesBeforeInvalid = calls.filter(c => c.url.endsWith('/SaveRobotPlayTime')).length;
        await page.evaluate(() => { $('#playTimeMinHours').numberbox('setValue', 4); $('#playTimeMaxHours').numberbox('setValue', 2); });
        await page.locator('#saveRobotPlayTime').click();
        await page.getByText('确定', { exact: true }).click();
        assert.strictEqual(calls.filter(c => c.url.endsWith('/SaveRobotPlayTime')).length, savesBeforeInvalid);
        await page.evaluate(() => { $('#playTimeMinHours').numberbox('setValue', 0.1); $('#playTimeMaxHours').numberbox('setValue', 0.1); });
        await page.locator('#saveRobotPlayTime').click();
        await page.waitForFunction(() => $('#playTimeStatus').text() === '已启用 · 0.1～0.1 小时');
        await page.getByText('确定', { exact: true }).click();
        playTimeUnavailable = true;
        await playTimeCard.getByRole('button', { name: '重新读取' }).click();
        await page.waitForFunction(() => $('#playTimeStatus').text().includes('读取失败'));
        assert.strictEqual(await page.locator('#saveRobotPlayTime').isDisabled(), true);
        assert.strictEqual(await page.locator('#saveRobotSchedule').isDisabled(), false);
        await page.getByText('确定', { exact: true }).click();
        playTimeUnavailable = false;
        await playTimeCard.getByRole('button', { name: '重新读取' }).click();
        await page.waitForFunction(() => !$('#saveRobotPlayTime').prop('disabled'));
        await page.locator('#playTimeEnabled').uncheck();
        await page.locator('#saveRobotPlayTime').click();
        await page.waitForFunction(() => $('#playTimeStatus').text() === '未启用');
        await page.getByText('确定', { exact: true }).click();
        await page.locator('#shuffleEnabled').check();
        await page.evaluate(() => { $('#shuffleStart').timespinner('setValue', '23:00'); $('#shuffleEnd').timespinner('setValue', '02:00'); });
        await page.getByRole('button', { name: '保存定时设置' }).click();
        await page.waitForFunction(() => $('#scheduleStatus').text().includes('23:00–02:00'));
        assert.strictEqual(calls.find(c => c.url.endsWith('/SaveRobotShuffleSchedule')).params.StartMinute, '1380');
        await page.getByText('确定', { exact: true }).click();
        if (output) await page.screenshot({ path: path.join(output, 'schedule.png') });
        scheduleUnavailable = true;
        await shuffleCard.getByRole('button', { name: '重新读取' }).click();
        await page.waitForFunction(() => $('#scheduleStatus').text().includes('读取失败'));
        assert.strictEqual(await page.locator('#saveRobotSchedule').isDisabled(), true, 'failed read must not enable saving default settings');
        await page.getByText('确定', { exact: true }).click();
        scheduleUnavailable = false;
        await shuffleCard.getByRole('button', { name: '重新读取' }).click();
        await page.waitForFunction(() => !$('#saveRobotSchedule').prop('disabled'));

        // Inspect all three grids after being initialized hidden, and after changing viewport size.
        for (const width of [1440, 1100, 800, 540]) {
            await page.setViewportSize({ width, height: 850 });
            for (const [name, id] of [['实时状态', 'tb_RobotSeat'], ['座位配置', 'tb_Robot'], ['账户管理', 'tb_RobotAccount']]) {
                await page.getByRole('tab', { name }).click();
                await page.waitForFunction(id => $('#' + id).datagrid('getPanel').width() > 200, id);
                const bounds = await page.evaluate(id => {
                    const panel = $('#' + id).datagrid('getPanel')[0].getBoundingClientRect();
                    return { left: panel.left, right: panel.right, width: document.documentElement.clientWidth };
                }, id);
                assert(bounds.left >= 0 && bounds.right <= bounds.width + 1, `${width}px ${name}: grid fits viewport`);
                assert.strictEqual(await page.locator('.robot-panel:visible').count(), 1);
            }
            if (output) await page.screenshot({ path: path.join(output, `accounts-${width}.png`) });
        }
        await page.getByRole('tab', { name: '账户管理' }).focus();
        await page.keyboard.press('ArrowRight');
        assert.strictEqual(await page.getByRole('tab', { name: '自动调度' }).getAttribute('aria-selected'), 'true');
        await page.setViewportSize({ width: 1100, height: 850 });
        statusUnavailable = true;
        await page.getByRole('tab', { name: '实时状态' }).click();
        await page.waitForFunction(() => $('#robotStatTotal').text() === '—');
        assert.strictEqual(await page.evaluate(() => $('#tb_RobotSeat').datagrid('getData').total), 0);
        await page.getByText('确定', { exact: true }).click();
        statusUnavailable = false;
        await page.getByRole('button', { name: '刷新状态' }).click();
        await page.waitForFunction(() => $('#robotStatTotal').text() === '25');
        assert.deepStrictEqual(errors, [], 'no browser JS errors');
        console.log(`PASS real EasyUI: play-time range/fixed/decimal/disable/invalid/failure recovery; four tabs, global counts, isolated filters, exact batch deletion, cross-midnight schedule, 4 viewport widths; card + 3 laba quantity regression (${Date.now() - start} ms)`);
    } finally {
        if (browser) await browser.close();
        server.close();
    }
})().catch(error => { console.error(error); console.error('Browser errors:', errors); process.exitCode = 1; });
