/* 运行实际电脑版提交函数，验证“关闭”与有效控制的阈值输入边界。 */
'use strict';
const assert = require('assert');
const fs = require('fs');
const path = require('path');
const vm = require('vm');
const view = fs.readFileSync(path.join(__dirname, '../TTY.Web/Areas/Game/Views/UserInfo/OnlineUsers.cshtml'), 'utf8');
const start = view.indexOf('    function SaveTotalCtrl()');
const end = view.indexOf('    function CloseTotalCtrl()', start);
assert(start >= 0 && end > start, '电脑版总控提交入口缺失');
function submit(mode, strength, gold) {
    const values = {
        '#hfID_Total': 'local-test', '#selE_Mode_Total': mode,
        '#selE_Strength_Total': strength, '#numGold_Total': gold,
        '#selE_Action_Total': 19, '#selE_Type_Total': 6,
        '#selE_Number_Total': 1, '#selE_Total_Total': 5
    };
    let sent = null, error = null;
    const context = {
        $: selector => ({ val: () => values[selector], combobox: () => values[selector], numberbox: () => values[selector] }),
        request: (url, data) => { sent = { url, data }; },
        showUserToast: text => { error = text; },
        showUserResult() {}, loadTotalCtrlStatus() {}, refreshChangedUserRow() {}
    };
    vm.createContext(context);
    vm.runInContext(view.slice(start, end), context);
    context.SaveTotalCtrl();
    return { sent, error };
}
for (const mode of [4, 5]) {
    const closed = submit(mode, '0', '');
    assert.strictEqual(closed.error, null);
    assert.strictEqual(closed.sent.url, '/Game/UserInfo/ApplyTotalControl');
    assert.strictEqual(closed.sent.data.Strength, '0');
    assert.strictEqual(closed.sent.data.GoldThreshold, 0);
    for (const gold of ['', '0', '-1']) {
        const rejected = submit(mode, '3', gold);
        assert.strictEqual(rejected.sent, null);
        assert(rejected.error);
    }
    const active = submit(mode, '3', '2');
    assert.strictEqual(active.error, null);
    assert.strictEqual(active.sent.data.GoldThreshold, '2');
}
const gift = submit(6, '', '');
assert.strictEqual(gift.error, null);
assert.strictEqual(gift.sent.data.CardAction, 19);
assert.strictEqual(gift.sent.data.CardNumber, 1);
assert.strictEqual(gift.sent.data.CardTotal, 5);
assert.strictEqual(gift.sent.data.GoldThreshold, 0);
console.log('PASS actual desktop form: kill/release zero closes without target; active controls require target; gift remains count-based');
