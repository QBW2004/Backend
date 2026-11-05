'use strict';
// 游戏配置「代理线专属桌台」按钮显隐与专属新建（2026-11-05）：加载真实 ConfigEditor 页面 DOM/脚本与共享 common.js，
// 接口全部由本地内存模拟。LINE_UI_VIEW 可指向其它版本的 cshtml（用于复现旧版问题）。
const fs = require('node:fs'), path = require('node:path'), http = require('node:http'), assert = require('node:assert/strict');
const { chromium } = require(process.env.PLAYWRIGHT_MODULE || 'C:/Users/Administrator/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules/playwright');
const root = path.resolve(__dirname, '..'), web = path.join(root, 'TTY.Web');
const viewFile = process.env.LINE_UI_VIEW || path.join(web, 'Areas/Game/Views/GameConfig/ConfigEditor.cshtml');
const raw = fs.readFileSync(viewFile, 'utf8').replace(/^\uFEFF/, '');
const body = raw.slice(raw.indexOf('<div class="gc-wrap">')).replace(/@\*[\s\S]*?\*@/g, '').replace(/@Html.Partial\("[^"]+"\)/g, '')
    .replace('@Html.AntiForgeryToken()', '<input name="__RequestVerificationToken" type="hidden" value="fixture-csrf">')
    .replace(/@Url.Action\("([^"]+)",\s*"([^"]+)"[^)]*\)/g, (_, a, c) => '/' + c + '/' + a).replace(/@Url.Content\("~([^"]*)"\)/g, '$1');
const html = `<!doctype html><meta charset="utf-8"><style>${raw.match(/<style>([\s\S]*?)<\/style>/)[1].replaceAll('@@', '@')}</style>
<script src="/Scripts/jquery-2.1.4.js"></script><script src="/Scripts/easyloader.js"></script><script src="/Scripts/app/common.js"></script><script src="/Scripts/app/mjhl.engine.js"></script>
<script>window.Worker=function(){this.postMessage=function(){};this.terminate=function(){};};</script><main class="main">${body}</main>`;

const GAME = 30;
// 内存里的桌台：idx → owner（'' 公共，'#' 已收回）
let tables = { 0: '', 1: '', 2: '' };
const posts = [], checks = [], errors = [];
let lineOptionReads = 0;
const check = (value, name) => { assert.ok(value, name); checks.push(name); };
const owned = line => Object.values(tables).filter(o => o === line).length;
const names = {};
const row = idx => ({ id: GAME * 1000 + idx, GAME_ID: GAME, tableName: names[idx] || ((tables[idx] ? tables[idx] + '-' : '公共') + idx), Enabled: 1, BetMin: 1, BetMax: 10, COIN_NEED: 1, EX_COIN: 1, COIN_SC: 1, Game_Mo: 1, scoreSwitch: 1 });

const server = http.createServer(async (req, res) => {
    const route = new URL(req.url, 'http://localhost').pathname;
    const json = data => { res.setHeader('Content-Type', 'application/json;charset=utf-8'); res.end(JSON.stringify(data)); };
    if (route === '/') { res.setHeader('Content-Type', 'text/html;charset=utf-8'); res.end(html); return; }
    if (route.startsWith('/GameConfig/')) {
        let b = ''; for await (const part of req) b += part; const p = Object.fromEntries(new URLSearchParams(b));
        if (route.endsWith('/GetGameList')) return json([{ id: 54, text: '麻将胡了', gameType: 3, paraType: 3 }, { id: GAME, text: '测试牌机', gameType: 1, paraType: 1 }]);
        if (route.endsWith('/GetLineOptions')) {
            lineOptionReads++;
            const pub = Object.values(tables).filter(o => o === '').length;
            return json({ code: 1, datas: { Ready: true, Owned: Object.values(tables).filter(o => o && o !== '#').length, Recycled: owned('#'),
                Lines: [{ id: '', text: '公共桌台', count: pub }, { id: 'lineA', text: 'lineA', count: owned('lineA') }, { id: 'lineB', text: 'lineB', count: owned('lineB') }] } });
        }
        if (route.endsWith('/GetTableConfig')) {
            const line = p.LINE || '';
            return json({ code: 1, datas: Object.keys(tables).map(Number).filter(i => tables[i] === line).map(row) });
        }
        if (route.endsWith('/GetMjhlAgentLines')) return json({ code: 1, datas: { Lines: [{ id: '*', text: '默认' }], CanEdit: false } });
        if (route.endsWith('/GetMjhlAgentConfig')) return json({ code: 0, content: 'fixture' });
        posts.push({ route, params: p });
        if (route.endsWith('/CopyPublicTablesToLine')) {
            const pub = Object.keys(tables).map(Number).filter(i => tables[i] === '');
            let next = Math.max(...Object.keys(tables).map(Number)) + 1;
            pub.forEach(() => { tables[next++] = p.LINE; });
            return json({ code: 1, content: '已复制' });
        }
        if (route.endsWith('/RecallLineTables')) {
            Object.keys(tables).forEach(i => { if (tables[i] === p.LINE) tables[i] = '#'; });
            return json({ code: 1, content: '已收回' });
        }
        if (route.endsWith('/SaveTableConfig')) {
            const next = Math.max(...Object.keys(tables).map(Number)) + 1;
            if (p.ID && p.ID !== '-1') { names[Number(p.ID) % 1000] = p.TableName; return json({ code: 1, content: '保存成功' }); }
            tables[next] = p.LINE || '';
            names[next] = p.TableName;
            return json({ code: 1, content: '保存成功' });
        }
        res.writeHead(404).end(); return;
    }
    const file = path.resolve(web, '.' + route); if (!file.startsWith(web + path.sep) || !fs.existsSync(file)) { res.writeHead(404).end(); return; }
    res.setHeader('Content-Type', route.endsWith('.js') ? 'text/javascript; charset=utf-8' : 'text/css'); res.end(fs.readFileSync(file));
});

(async () => {
    const start = Date.now(); await new Promise(r => server.listen(0, '127.0.0.1', r));
    const browser = await chromium.launch({ headless: true, executablePath: process.env.CHROME_PATH || 'C:/Program Files/Google/Chrome/Application/chrome.exe' });
    try {
        const page = await browser.newPage({ viewport: { width: 1440, height: 1000 } }); page.setDefaultTimeout(5000); page.on('pageerror', e => errors.push(e.message));
        page.on('dialog', d => d.accept());
        const vis = async sel => page.locator(sel).isVisible();
        const settle = () => page.waitForLoadState('networkidle').then(() => page.waitForTimeout(150));
        const buttons = async () => ({ copy: await vis('#gcLineCopy'), recall: await vis('#gcLineRecall'), add: await vis('#gcNewTable'), del: await vis('#gcDelete') });
        // 共享 confirm：EasyUI 弹窗就绪时点「确定」，否则走浏览器原生确认框（上面 dialog 已自动接受）
        const okConfirm = async () => { await page.waitForTimeout(200); const b = page.locator('.messager-window a:has-text("确定")').first(); if (await b.isVisible().catch(() => false)) await b.click(); };

        await page.goto('http://127.0.0.1:' + server.address().port);
        await page.evaluate(() => { window.__toasts = []; const t = window.showToast; window.showToast = function (m) { window.__toasts.push(m); return t && t.apply(this, arguments); }; });
        await page.selectOption('#gcTypeSel', '1'); await page.selectOption('#gcGameSel', String(GAME)); await settle();
        let b = await buttons();
        check(b.add && !b.copy && !b.recall && b.del, 'public view: new/delete visible, copy/recall hidden');

        await page.selectOption('#gcLineSel', 'lineA'); await settle();
        b = await buttons();
        check(b.copy, 'line without exclusive tables: copy button visible after tables load');
        check(!b.recall && !b.add, 'line without exclusive tables: recall/new hidden');
        check((await page.locator('#gcLineTip').textContent()).includes('使用公共桌台'), 'tip says line uses public tables');
        check((await page.locator('#gcTableEmpty').textContent()).includes('从公共桌台复制一套'), 'empty list points to copy');
        check(await page.evaluate(() => { gcNewTable(); return !$('#gcNewTableWin').closest('.window').is(':visible'); }), 'new without exclusive tables is refused');

        await page.click('#gcLineCopy'); await okConfirm(); await settle();
        check(posts.at(-1).route.endsWith('/CopyPublicTablesToLine') && posts.at(-1).params.LINE === 'lineA' && posts.at(-1).params.GAME_TYPE === '1', 'copy posts line and type');
        b = await buttons();
        check(b.recall && b.add && b.del && !b.copy, 'after copy: recall/new/delete visible, copy hidden');
        check(await page.locator('#gcTableList li').count() === 3, 'after copy: 3 exclusive tables listed');
        check((await page.locator('#gcLineTip').textContent()).includes('新建桌台'), 'tip mentions adding exclusive tables');

        // 专属视图新建：点「新建桌台」直接进表单、桌名自动编号；点「保存」才弹张数，真实键盘输入 2 后回车，一次建 2 张且桌名顺延
        await page.click('#gcNewTable'); await page.waitForTimeout(150);
        check(!(await page.locator('#gcNewTableWin').isVisible()), 'new table opens form directly without count dialog');
        check((await page.locator('#gcCurTableName').textContent()).includes('【lineA】专属桌台'), 'new form titled as lineA exclusive');
        check(await page.inputValue('#gcTableName') === 'lineA-6', 'table name auto numbered after lineA-5: ' + await page.inputValue('#gcTableName'));
        check((await page.locator('#gcSave').textContent()).trim() === '保存', 'save button labelled 保存 for new table');
        for (const [sel, v] of [['#gcMinBet', '1'], ['#gcMaxBet', '10'], ['#gcScoreSwitch', '1']]) await page.fill(sel, v);
        const readsBefore = lineOptionReads, postsBefore = posts.length;
        await page.click('#gcSave'); await page.waitForSelector('#gcNewTableWin', { state: 'visible' });
        check(posts.length === postsBefore, 'nothing saved before count chosen');
        const countBox = page.locator('#gcNewTableWin .textbox-text:visible').first();
        const box = await countBox.boundingBox();
        check(box && box.width >= 60, 'count input visibly wide (bug was 8px): ' + (box && box.width));
        await countBox.click(); await page.keyboard.press('Control+A'); await page.keyboard.type('2'); await page.keyboard.press('Enter');
        await page.waitForFunction(() => !GC_BATCH_SAVING, null); await settle();
        const saves = posts.slice(postsBefore).filter(x => x.route.endsWith('/SaveTableConfig'));
        if (process.env.LINE_UI_DEBUG) console.log(JSON.stringify(posts.slice(postsBefore).map(x => [x.route, x.params.LINE, x.params.ID, x.params.TableName])), await page.evaluate(() => window.__toasts));
        check(saves.length === 2 && saves.every(x => x.params.LINE === 'lineA' && x.params.ID === '-1' && x.params.GAME_ID === String(GAME)), 'two new saves carry LINE=lineA and ID=-1');
        check(saves.map(x => x.params.TableName).join(',') === 'lineA-6,lineA-7', 'batch names sequential: ' + saves.map(x => x.params.TableName).join(','));
        check(saves[0].params.MinBet === saves[1].params.MinBet && saves[0].params.MaxBet === saves[1].params.MaxBet, 'batch tables share current parameters');
        check(owned('lineA') === 5 && await page.locator('#gcTableList li').count() === 5, 'lineA now has 5 exclusive tables');
        check(lineOptionReads > readsBefore && (await page.locator('#gcLineSel option[value="lineA"]').textContent()).includes('5'), 'line dropdown count refreshed');
        b = await buttons(); check(b.recall && b.add && !b.copy, 'buttons stable after add');

        // 选中已有桌台改参数保存：不弹张数，只更新这一张
        await page.locator('#gcTableList li').first().click(); await page.waitForTimeout(150);
        const editId = await page.inputValue('#gcId');
        check(Number(editId) >= 0 && (await page.locator('#gcSave').textContent()).trim() !== '保存', 'existing table selected, save not in new mode');
        await page.fill('#gcTableName', '改名桌'); for (const [sel, v] of [['#gcMinBet', '2'], ['#gcMaxBet', '20'], ['#gcScoreSwitch', '1']]) await page.fill(sel, v);
        const postsEdit = posts.length;
        await page.click('#gcSave'); await page.waitForTimeout(400); await settle();
        check(!(await page.locator('#gcNewTableWin').isVisible()), 'editing existing table does not show count dialog');
        const edits = posts.slice(postsEdit).filter(x => x.route.endsWith('/SaveTableConfig'));
        check(edits.length === 1 && edits[0].params.ID === editId && edits[0].params.TableName === '改名桌', 'single update for the selected table only');

        // 取消张数弹窗：不保存
        await page.click('#gcNewTable'); await page.waitForTimeout(150);
        for (const [sel, v] of [['#gcMinBet', '1'], ['#gcMaxBet', '10'], ['#gcScoreSwitch', '1']]) await page.fill(sel, v);
        const postsCancel = posts.length;
        await page.click('#gcSave'); await page.waitForSelector('#gcNewTableWin', { state: 'visible' });
        await page.click('#gcNewTableCancel'); await page.waitForTimeout(200);
        check(posts.length === postsCancel, 'cancel count dialog saves nothing');

        // 另一条线仍是公共
        await page.selectOption('#gcLineSel', 'lineB'); await settle();
        b = await buttons(); check(b.copy && !b.recall && !b.add, 'other line still uses public tables');
        await page.selectOption('#gcLineSel', ''); await settle();
        check(await page.locator('#gcTableList li').count() === 3, 'public view still lists only 3 public tables');
        await page.click('#gcNewTable'); await page.waitForTimeout(150);
        check(await page.inputValue('#gcTableName') === '公共3', 'public table name auto numbered: ' + await page.inputValue('#gcTableName'));

        // 收回
        await page.selectOption('#gcLineSel', 'lineA'); await settle();
        await page.click('#gcLineRecall'); await okConfirm(); await settle();
        check(posts.at(-1).route.endsWith('/RecallLineTables') && posts.at(-1).params.LINE === 'lineA', 'recall posts line');
        b = await buttons(); check(b.copy && !b.recall && !b.add, 'after recall: back to copy only');

        // 麻将胡了隐藏，切回普通游戏恢复
        await page.selectOption('#gcTypeSel', '3'); await page.selectOption('#gcGameSel', '54'); await settle();
        b = await buttons(); check(!b.copy && !b.recall && !b.add && !b.del, 'mjhl hides ordinary table operations');
        await page.selectOption('#gcTypeSel', '1'); await page.selectOption('#gcGameSel', String(GAME)); await settle();
        await page.selectOption('#gcLineSel', 'lineA'); await settle();
        b = await buttons(); check(b.copy && b.del, 'leaving mjhl restores buttons for the selected line');

        check(errors.length === 0, 'no page errors: ' + errors.join(' | '));
        console.log(JSON.stringify({ checks: checks.length, elapsedMs: Date.now() - start }));
    } catch (e) {
        console.log(JSON.stringify({ passedBeforeFailure: checks.length, failure: e.message, pageErrors: errors }));
        process.exitCode = 1;
    } finally { await browser.close(); server.close(); }
})();
