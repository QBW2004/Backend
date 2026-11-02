const fs = require('fs');
const path = require('path');
const vm = require('vm');
const assert = require('assert');
const root = path.resolve(__dirname, '../..');
function extract(source, prefix) {
    const start = source.indexOf(prefix);
    assert(start >= 0, `Missing ${prefix}`);
    const opening = source.indexOf('{', start);
    let depth = 1, end = opening + 1;
    while (depth) { depth += (source[end] === '{') - (source[end] === '}'); end++; }
    return source.slice(start, end);
}
const core = fs.readFileSync(path.join(root, 'TTY.Web/Scripts/app/phone/phone.core.js'), 'utf8');
const desktop = fs.readFileSync(path.join(root, 'TTY.Web/Views/Mgr/Index.cshtml'), 'utf8');
const context = vm.createContext({ M: {}, MConfig: { isRMB: false, exchangeRate: 100 }, isRMB: false, ExchangeRate: 100 });
vm.runInContext(extract(core, 'M.gold = function') + ';', context);
vm.runInContext(extract(desktop, 'function goldFormat('), context);
vm.runInContext(extract(desktop, 'function formatMoney('), context);
let checks = 0;
for (const [input, expected] of [[2363, '2363'], [-0.4, '-0.4'], [0.1 + 0.2, '0.3'], [0.005, '0.005'], [0, '0'], [-0.00000001, '-1e-8'], [4688.75, '4688.75']]) {
    assert.strictEqual(context.M.gold(input), expected); checks++;
    assert.strictEqual(String(context.goldFormat(input)), expected); checks++;
}
context.MConfig.isRMB = true;
context.isRMB = true;
assert.strictEqual(context.M.gold(4688.75), '46.89'); checks++;
assert.strictEqual(context.goldFormat(4688.75), '46.89'); checks++;
console.log(`PASS ${checks} actual mobile/desktop amount-format checks`);
