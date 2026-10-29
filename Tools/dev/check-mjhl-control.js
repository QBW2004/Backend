// Run from the repository root: node Tools/dev/check-mjhl-control.js
'use strict';
const fs = require('fs');
const vm = require('vm');
const assert = require('assert');

const window = { MConfig: {} };
vm.runInNewContext(fs.readFileSync('TTY.Web/Scripts/app/phone/phone.core.js', 'utf8'), {
    window, jQuery: {}, document: {}, console
});
const mobile = window.MApp;
const expected = [
    '大奖（20~34倍）', '巨奖（35~49倍）', '超级巨奖（50~70倍）',
    '三个胡·10次免费（预估70）', '四个胡·12次免费（预估90）', '五个胡·14次免费（预估120）'
].map((text, index) => ({ id: index + 1, text }));

function normalize(rows) {
    return Array.from(rows, row => ({ id: row.id, text: row.text }));
}

function loadViewFunction(source, name, context) {
    const start = source.indexOf('function ' + name + '(');
    assert(start >= 0, name + ' missing');
    const open = source.indexOf('{', start);
    let depth = 1, end = open + 1;
    for (; depth && end < source.length; end++) {
        if (source[end] === '{') depth++;
        if (source[end] === '}') depth--;
    }
    assert.strictEqual(depth, 0, name + ' incomplete');
    vm.runInNewContext(source.slice(start, end), context);
}

assert.deepStrictEqual(normalize(mobile.cardTypeData(19)), expected);
assert.strictEqual(mobile.cardActionName(19), '麻将胡了');
assert(mobile.CARD_ACTIONS.some(row => row.id === 19));
assert(!mobile.CARD_ACTIONS.some(row => row.id === 18));
for (let value = 1; value <= 6; value++) {
    assert.strictEqual(mobile.cardTypeName(19, value), expected[value - 1].text);
    assert.strictEqual(mobile.cardControlParams(19, value), '麻将胡了 ' + expected[value - 1].text);
}

for (const path of [
    'TTY.Web/Areas/Game/Views/UserInfo/Index.cshtml',
    'TTY.Web/Areas/Game/Views/UserInfo/OnlineUsers.cshtml'
]) {
    const source = fs.readFileSync(path, 'utf8');
    const context = {};
    for (const name of ['valSelDataMjhl', 'totalCardActionData', 'labaTypeName', 'bindTotalCardAction']) {
        loadViewFunction(source, name, context);
    }
    assert.deepStrictEqual(normalize(context.valSelDataMjhl()), expected);
    assert(context.totalCardActionData().some(row => row.id === 19));
    assert(!context.totalCardActionData().some(row => row.id === 18));
    for (let value = 1; value <= 6; value++) {
        assert.strictEqual(context.labaTypeName(19, value), mobile.cardTypeName(19, value));
    }
    let loaded;
    context.$ = () => ({ combobox: (operation, data) => {
        assert.strictEqual(operation, 'loadData');
        loaded = data;
    } });
    context.bindTotalCardAction('19');
    assert.deepStrictEqual(normalize(loaded), expected);
    console.log('PASS desktop selector, six awards and record names: ' + path);
}
console.log('PASS mobile selector, six awards and confirmation/record names');
