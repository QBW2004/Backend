// 执行实际 Razor 内的 JS，验证数量模式、异步响应及提交参数；不连接游戏服。
const fs = require('fs');
const vm = require('vm');
const assert = require('assert');
const path = require('path');
const source = fs.readFileSync(path.join(__dirname, '../../TTY.Web/Areas/Game/Views/Robot/Index.cshtml'), 'utf8');
const script = source.match(/@section include_res\{\s*<script>([\s\S]*?)<\/script>/)[1]
    .replace(/@Html.Raw\(@"([\s\S]*?)"\);/g, (_, js) => js.replace(/""/g, '"'));
const elements = new Map();
const requests = [];
let message;
function element(selector) {
    if (!elements.has(selector)) elements.set(selector, { value: '', visible: true, disabled: false, data: [], options: {} });
    const state = elements.get(selector);
    const widget = {
        toggle: value => { state.visible = value; return widget; },
        text: value => { if (value === undefined) return state.text; state.text = value; return widget; },
        val: () => selector.includes("name='GameId'") ? element('#addGameId').combobox('getValue') : element('#addLine').combobox('getValue'),
        serializeObject: () => ({ GameType: element('#addGameType').combobox('getValue'), GameId: element('#addGameId').combobox('getValue'), TABLE_ID: 77, RobotNo: 1 }),
        combobox: operation,
        numberbox: operation
    };
    function operation(command, value) {
        if (typeof command === 'object') Object.assign(state.options, command);
        else if (command === 'getValue') return state.value;
        else if (command === 'getData') return state.data;
        else if (command === 'setValue') state.value = String(value);
        else if (command === 'clear') state.value = '';
        else if (command === 'disable') state.disabled = true;
        else if (command === 'enable') state.disabled = false;
        else if (command === 'loadData') state.data = value;
        return widget;
    }
    return widget;
}
const context = { $: x => typeof x === 'function' ? undefined : element(x), window: {}, request: (url, data, callback) => requests.push({ url, data, callback }), showMsg: x => { message = x; } };
vm.createContext(context);
vm.runInContext(script, context);
context.robotInputsReady = true;
element('#addGameType').combobox('setValue', 1);
context.configureRobotInputs();
assert(!elements.get('#tableRobotRow,#tableRobotCountRow').visible);
assert(elements.get('#cardRobotCountRow,#cardRobotHintRow').visible);
assert(elements.get('#addTABLE_ID').disabled);
element('#addGameId').combobox('setValue', 5);
element('#addLine').combobox('setValue', '_public');
context.getRoom();
const stale = requests.pop();
element('#addLine').combobox('setValue', 'agentA');
context.getRoom();
const current = requests.pop();
stale.callback({ code: 1, total: 99, current: 0, remaining: 99 });
assert.strictEqual(context.cardCapacityReady, false);
current.callback({ code: 1, total: 10, current: 4, remaining: 6 });
assert.strictEqual(context.cardTotal, 10);
assert.strictEqual(elements.get('#addCardRobotNo').options.max, 10);
assert.strictEqual(elements.get('#addCardRobotNo').options.min, 0);
assert.strictEqual(element('#addCardRobotNo').numberbox('getValue'), '4');
for (const value of ['-1', '1.5', 'abc', '11']) {
    element('#addCardRobotNo').numberbox('setValue', value);
    context.SaveRobot();
    assert.strictEqual(message.code, 0);
    assert.strictEqual(requests.length, 0);
}
for (const value of ['0', '2', '10']) {
    element('#addCardRobotNo').numberbox('setValue', value);
    context.SaveRobot();
    const save = requests.pop();
    assert.strictEqual(save.data.RobotNo, value);
    assert(!('TABLE_ID' in save.data));
}
context.getRoom();
requests.pop().callback({ code: 1, total: 10, current: 10, remaining: 0 });
assert(!elements.get('#addCardRobotNo').disabled);
assert.strictEqual(element('#addCardRobotNo').numberbox('getValue'), '10');
context.getRoom();
requests.pop().callback({ code: 1, total: 0, current: 0, remaining: 0 });
assert(elements.get('#addCardRobotNo').disabled);
context.SaveRobot();
assert.strictEqual(requests.length, 0);
element('#addGameType').combobox('setValue', 2);
context.configureRobotInputs();
assert(elements.get('#tableRobotRow,#tableRobotCountRow').visible);
assert(!elements.get('#addTABLE_ID').disabled);
assert(!elements.get('#addRobotNo').disabled);
console.log('PASS card robot page: total entry 0~capacity, prefilled current count, stale response, no-table line, request payload and type switch');
