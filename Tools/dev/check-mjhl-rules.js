// 独立固定盘面验收：按客户端规则核算，不靠累计 RTP 判断正确性。
'use strict';
var assert = require('assert');
var fs = require('fs'), path = require('path'), vm = require('vm');
var E = require('../../TTY.Web/Scripts/app/mjhl.engine.js');
var started = Date.now(), checks = 0;
function check(name, fn) { fn(); checks++; console.log('[ OK ] ' + name); }
function grid(fill) { return E.COL_LEN.map(function (n) { return Array(n).fill(fill); }); }
function cell(g, c, r, value) { g[c][E.BUF_TOP[c] + r] = value; }
function profile(regular, scatterNormal, scatterFree) {
    var p = E.defaults(); p.goldChance = 0; p.enabled[E.IDX_WILD] = false;
    ['n', 'f'].forEach(function (m) {
        var sc = m === 'n' ? scatterNormal : scatterFree;
        p.weights[m].forEach(function (w) { w.fill(0); });
        for (var c = 0; c < 5; c++) {
            p.weights[m][regular[c] - 1][c] = p.weightTotal - sc;
            p.weights[m][E.IDX_SCATTER][c] = sc;
        }
    });
    return p;
}
function pushGrid(values, free, scatterCount, scatterCol) {
    for (var c = 0; c < 5; c++) for (var r = 0; r < E.COL_LEN[c]; r++) {
        var scatter = c === scatterCol && r >= E.BUF_TOP[c] && r < E.BUF_TOP[c] + scatterCount;
        values.push(scatter ? 0.95 : 0.1);
        if (!scatter && c >= 1 && c <= 3 && !(free && c === 2)) values.push(0.5);
    }
}
function stream(values) { var i = 0; return function () { return i < values.length ? values[i++] : 0.1; }; }

check('手工盘面：红中三连4 ways，押注200赢320', function () {
    var g = grid(30); cell(g, 0, 0, 7); cell(g, 0, 1, 7); cell(g, 1, 2, 7); cell(g, 2, 0, 107); cell(g, 2, 3, 7);
    var ev = E.evaluate(g, 200 * E.BET_SCALE, 1); assert.strictEqual(ev.total, 320 * E.SCORE_SCALE); assert.strictEqual(ev.lines[0].ways, 4);
});
check('押注0.1/0.4/0.5等保留0.005分奖金，整数档结果不变', function () {
    var g = grid(30); cell(g, 0, 0, 1); cell(g, 1, 0, 1); cell(g, 2, 0, 1);
    [1, 4, 5, 10, 19, 20, 40, 100, 200].forEach(function (bet) {
        var ev = E.evaluate(g, bet, 1);
        assert.strictEqual(ev.total, bet); assert.strictEqual(ev.lines[0].win, bet);
        assert.strictEqual(ev.total / E.SCORE_SCALE, bet / E.BET_SCALE / 20);
    });
    assert.strictEqual(E.BET_SCALE, 10); assert.strictEqual(E.SCORE_SCALE, 200); assert.strictEqual(E.betTicks(4), 80);
});
check('关闭自然百搭不影响中奖金牌原地变百搭', function () {
    var p = profile([1, 2, 3, 4, 5], 0, 0), g = grid(30); cell(g, 1, 1, 107);
    E.eliminateAndDrop(E.compile(p), function () { return 0.1; }, false, [{ positions: [[1, 1]] }], g);
    assert.strictEqual(g[1][E.BUF_TOP[1] + 1], 20);
});
check('免费第3轴全金，2/4轴仍按金色概率生成', function () {
    var p = profile([1, 2, 3, 4, 5], 0, 0); p.goldChance = 100;
    var g = E.generateGrid(E.compile(p), function () { return 0.1; }, true);
    for (var c = 0; c < 5; c++) g[c].forEach(function (v) { assert.strictEqual(v, c >= 1 && c <= 3 ? 101 + c : 1 + c); });
    p.goldChance = 0; g = E.generateGrid(E.compile(p), function () { return 0.1; }, true);
    for (var col = 0; col < 5; col++) g[col].forEach(function (v) { assert.strictEqual(v, col === 2 ? 101 + col : 1 + col); });
});
check('至尊允许首尾轴，只有自然百搭限制2至4轴', function () {
    var p = E.defaults(); p.weights.n[E.IDX_SCATTER][0] = 1; p.weights.f[E.IDX_SCATTER][4] = 1;
    assert.deepStrictEqual(E.validate(p), []); p.weights.n[E.IDX_WILD][0] = 1; assert(E.validate(p).length > 0);
});
check('初始与再次触发均按3/4/5胡送10/12/14，旧次数配置无效', function () {
    var p = profile([1, 2, 3, 4, 5], 1000, 1000), values = [];
    p.retrigger = false; p.retriggerAward = 1; p.retriggerLimit = 1; p.freeLimit = 14;
    pushGrid(values, false, 3, 0); pushGrid(values, true, 4, 0);
    for (var i = 1; i < 22; i++) pushGrid(values, true, 0, 0);
    var o = E.generateRound(E.compile(p), stream(values), 20 * E.BET_SCALE, false);
    assert.strictEqual(o.trig.freeWon, 10); assert.strictEqual(o.chain[0].freeWon, 12); assert.strictEqual(o.chain.length, 22);
    assert.strictEqual(E.initialFree(null, 5), 14); assert.strictEqual(E.initialFree(null, 23), 50);
});
check('每次旋转独立5000倍，付费封顶后仍完整发放10次免费', function () {
    var p = profile([8, 8, 8, 8, 8], 1000, 0), values = []; pushGrid(values, false, 3, 4);
    var o = E.generateRound(E.compile(p), stream(values), 20 * E.BET_SCALE, false);
    assert(o.trig.capped); assert.strictEqual(o.trig.freeWon, 10); assert.strictEqual(o.chain.length, 10);
    assert(o.chain.every(function (s) { return s.capped && s.totalWin === 100000 * E.SCORE_SCALE; }));
    assert.strictEqual(o.total, 1100000 * E.SCORE_SCALE); assert(o.capped); assert.strictEqual(o.limited, 0);
});
check('超过200轮的有效连消继续结算到单spin封顶', function () {
    var p = profile([1, 1, 1, 2, 3], 0, 0), c = E.compile(p);
    var g = E.generateGrid(c, function () { return 0.1; }, false);
    var s = E.spinGrid(c, function () { return 0.1; }, 20 * E.BET_SCALE, false, 100000 * E.SCORE_SCALE, g, false);
    assert(s.roundCount > 200); assert.strictEqual(s.totalWin, 100000 * E.SCORE_SCALE); assert(s.capped);
});
check('小额与20倍档逐局线性一致，抽牌、免费与封顶口径不变', function () {
    var p = E.compile(E.defaults());
    [1, 4, 5, 10, 19, 20, 40, 100, 200, 400, 1000].forEach(function (bet) {
        var small = E.mulberry32(214), baseline = E.mulberry32(214);
        for (var i = 0; i < 80; i++) {
            var a = E.generateRound(p, small, bet, true), b = E.generateRound(p, baseline, 20 * E.BET_SCALE, true);
            assert.strictEqual(a.total * 20 * E.BET_SCALE, b.total * bet);
            assert.strictEqual(a.chain.length, b.chain.length);
            assert.strictEqual(a.trig.scatterMax, b.trig.scatterMax);
            assert.deepStrictEqual(a.trig.rounds.map(function (r) { return r.grid; }), b.trig.rounds.map(function (r) { return r.grid; }));
        }
    });
});
check('模拟RTP分母使用押注ticks，不会因精度放大20倍', function () {
    var p = profile([8, 8, 8, 8, 8], 0, 0), called = false;
    E.sample(p, 3, 214, {}, function (err, result) {
        assert.ifError(err); called = true;
        assert.strictEqual(result.normal, 5000); assert.strictEqual(result.free, 0); assert.strictEqual(result.total, 5000);
    });
    assert(called);
});
check('实际后台页面校验接受0.4分和0.1步长，拒绝多位小数及超200档', function () {
    var page = fs.readFileSync(path.join(__dirname, '../../TTY.Web/Areas/Game/Views/GameConfig/ConfigEditor.cshtml'), 'utf8');
    var body = page.match(/function gcMjhlLadderError\(minBet, maxBet, step\) \{[\s\S]*?\n    \}/);
    assert(body, '页面必须提供实际押注校验函数');
    var checkBet = vm.runInNewContext('(' + body[0] + ')');
    [[0.4, 20, 0.1], [0.1, 20, 0.1], [1, 200, 1], [0.4, 5, 0.1], [0.5, 20, 0.5]].forEach(function (a) { assert.strictEqual(checkBet.apply(null, a), ''); });
    [[0.1, 20.1, 0.1], [0, 20, 1], [0.45, 20, 0.1], [1, 20, 0.05], [1, 20, 0], [NaN, 20, 1], [0.4, Infinity, 1]].forEach(function (a) { assert.notStrictEqual(checkBet.apply(null, a), ''); });
});
check('麻将胡了0.1加分幅度不会被前端整数规则归一化或拒绝', function () {
    var page = fs.readFileSync(path.join(__dirname, '../../TTY.Web/Areas/Game/Views/GameConfig/ConfigEditor.cshtml'), 'utf8');
    var normBody = page.match(/function gcNormSs\(val, type\) \{[\s\S]*?\n    \}/);
    assert(normBody, '页面必须提供加分幅度归一化函数');
    var normMjhl = vm.runInNewContext('(' + normBody[0] + ')', { gcIsMjhl: function () { return true; } });
    var normOther = vm.runInNewContext('(' + normBody[0] + ')', { gcIsMjhl: function () { return false; } });
    assert.strictEqual(normMjhl(0.1, 3), 0.1, '麻将胡了0.1必须保留');
    assert.strictEqual(normMjhl(0.4, 3), 0.4, '麻将胡了0.4必须保留');
    assert.strictEqual(normOther(0.1, 3), 1, '其它参数类型3仍必须保持整数规则');

    var applyBody = page.match(/function gcApplyType\(\) \{[\s\S]*?\n    \}/);
    assert(applyBody && applyBody[0].indexOf('type === 3 && gcIsMjhl()') >= 0,
        '类型切换必须按游戏54区分麻将胡了小数步长');
    assert(applyBody[0].indexOf("attr('step', gcSsDecimal ? '0.1' : '1')") >= 0,
        '麻将胡了步长控件必须允许0.1');

    var saveBody = page.match(/function gcSave\(\) \{[\s\S]*?\n    \}/);
    assert(saveBody && saveBody[0].indexOf('type === 3 && gcIsMjhl()') >= 0,
        '保存校验必须绕过麻将胡了的整数步长限制');
});
check('至尊解析、同步和自动候选使用全部23格', function () {
    var p = profile([1, 2, 3, 4, 5], 1000, 1000), q = 0.1;
    var expected = 1 - Math.pow(1 - q, 23) - 23 * q * Math.pow(1 - q, 22) - 253 * q * q * Math.pow(1 - q, 21);
    assert(Math.abs(E.binomialTail(p) - expected) < 1e-12);
    p = E.syncScatter(E.defaults()); assert(p.weights.n[E.IDX_SCATTER][0] > 0); assert(p.weights.f[E.IDX_SCATTER][4] > 0);
    assert(Math.abs(E.binomialTail(p) - p.targetScatter / 100) < 0.001);
    p = E.candidate(E.defaults(), 0.5, 2.5, 0.35); assert(p.weights.n[E.IDX_SCATTER][0] > 0); assert(p.weights.f[E.IDX_SCATTER][4] > 0);
});
check('旧协议字段归一为true/0/0/0', function () {
    var p = E.defaults(); p.retrigger = false; p.retriggerAward = 9; p.retriggerLimit = 2; p.freeLimit = 14;
    E.normalize(p); assert.deepStrictEqual([p.retrigger, p.retriggerAward, p.retriggerLimit, p.freeLimit], [true, 0, 0, 0]);
});
check('必不终止的免费链拒绝整个模拟，不输出部分结果', function () {
    var p = profile([1, 2, 3, 4, 5], 10000, 10000), called = false;
    assert.throws(function () { E.generateRound(E.compile(p), function () { return 0.5; }, 20, false); }, function (e) { return e.code === 'MJHL_GENERATION_LIMIT'; });
    E.sample(p, 100, 1, {}, function (err, result) { called = true; assert.strictEqual(err.code, 'MJHL_GENERATION_LIMIT'); assert.strictEqual(result, undefined); });
    assert(called);
});
console.log('ALL PASSED: ' + checks + ' rule groups, ' + ((Date.now() - started) / 1000).toFixed(3) + 's');
