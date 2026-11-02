'use strict';
// 补牌热路径优化的无损对拍：默认以内嵌 R4 原函数为基准，不依赖交付目录或本地数据库。
// --reference=<冻结引擎绝对路径> 可对拍完整冻结引擎；--benchmark 另跑 10万/50万完整付费回合。
// 性能数字只表示当前机器耗时；这里只证明输出与随机数消耗一致，不把这些样本称为 RTP 精度验证。
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const Module = require('node:module');
const crypto = require('node:crypto');
const { performance } = require('node:perf_hooks');
const enginePath = path.resolve(__dirname, '../TTY.Web/Scripts/app/mjhl.engine.js');
const source = fs.readFileSync(enginePath, 'utf8');
const referenceArg = process.argv.slice(2).find(x => x.indexOf('--reference=') === 0);
const referencePath = referenceArg ? path.resolve(referenceArg.substring('--reference='.length)) : null;
const legacySubstitute = `    function visibleHas(g, col, s) {
        for (var r = 0; r < LOGICAL[col]; r++) {
            var v = g[col][BUF_TOP[col] + r];
            if (v === s || v === GOLD + s || v === WILD) return true;
        }
        return false;
    }
    function substitute(c, r, free, g) {
        for (var col = 0; col < COLS; col++) {
            for (var i = 0; i < COL_LEN[col]; i++) {
                if (g[col][i] !== BLANK) continue;
                var cand = [], s;
                for (s = 1; s <= 9; s++) {
                    if (!c.enabled[s - 1]) continue;
                    var safe = col === 0 ? (!visibleHas(g, 1, s) || !visibleHas(g, 2, s)) : !visibleHas(g, 0, s);
                    if (safe) cand.push(s);
                }
                if (col >= 2 && cand.length) {
                    var strong = [];
                    for (var j = 0; j < cand.length; j++) if (!visibleHas(g, 1, cand[j])) strong.push(cand[j]);
                    if (strong.length) cand = strong;
                }
                if (!cand.length) for (s = 1; s <= 9; s++) if (c.enabled[s - 1]) cand.push(s);
                var pick = Math.floor(r() * cand.length);
                if (pick >= cand.length) pick = cand.length - 1;
                s = cand[pick];
                g[col][i] = (free && col === 2) ? GOLD + s : s;
            }
        }
    }
`;
const substituteRange = /    function visible(?:Mask|Has)\(g, col(?:, s)?\) \{[\s\S]*?(?=    function generateGrid\()/;
assert(substituteRange.test(source), '未找到补牌函数边界，禁止跳过对拍');
const referenceSource = referencePath ? fs.readFileSync(referencePath, 'utf8') : source.replace(substituteRange, legacySubstitute);
function load(text, name) {
    const hook = 'blankWeights: blankWeights,';
    assert(text.includes(hook), '未找到仅测试用的私有补牌函数导出位置');
    const m = new Module(name, module);
    m.filename = name;
    m.paths = module.paths;
    m._compile(text.replace(hook, '_substitute: substitute, ' + hook), name);
    return m.exports;
}
const E = load(source, enginePath + '.speed-current.js');
const R = load(referenceSource, enginePath + '.speed-reference.js');
const copy = x => JSON.parse(JSON.stringify(x));
const seed = [0x12345678, 0x31415926, 0x27182818, 0x13572468];
function checkedRandom(engine, words) { return engine.xoshiro128ss(words || seed); }
function compareGrid(grid, enabled, free, makeRandom) {
    const next = copy(grid), old = copy(grid);
    const nr = makeRandom ? makeRandom() : checkedRandom(E), rr = makeRandom ? makeRandom() : checkedRandom(R);
    E._substitute({ enabled }, nr, free, next);
    R._substitute({ enabled }, rr, free, old);
    assert.deepEqual(next, old, '补牌结果不同');
    assert.equal(nr.drawCount(), rr.drawCount(), '补牌随机数消耗不同');
    assert.equal(nr.drawCount(), grid.reduce((sum, col) => sum + col.filter(v => v === -2).length, 0));
}
const allEnabled = Array(11).fill(true);
const cells = [-2, -2, -2, -1, 1, 2, 3, 4, 5, 6, 7, 8, 9, 20, 30, 101, 102, 103, 104, 105, 106, 107, 108, 109];
const fixtureRandom = checkedRandom(E, [10, 20, 30, 40]);
for (let i = 0; i < 2000; i++) {
    const grid = E.COL_LEN.map(n => Array.from({ length: n }, () => cells[Math.floor(fixtureRandom() * cells.length)]));
    const enabled = allEnabled.map(() => fixtureRandom() > .4);
    enabled[i % 9] = true;
    compareGrid(grid, enabled, false);
    compareGrid(grid, enabled, true);
}
// 全补牌、百搭占满可见格时退回普通牌、只在缓冲格有牌、稀疏启用及随机值1的历史夹紧行为。
for (const kind of ['allBlank', 'visibleWild', 'bufferWild', 'goldVisible']) {
    const grid = E.COL_LEN.map((n, col) => Array.from({ length: n }, (_, i) => {
        const visible = i >= E.BUF_TOP[col] && i < E.BUF_TOP[col] + E.LOGICAL[col];
        if (kind === 'visibleWild' && visible && col < 3) return 20;
        if (kind === 'bufferWild' && !visible) return 20;
        if (kind === 'goldVisible' && visible && col < 3) return 101 + (i % 9);
        return -2;
    }));
    for (const enabled of [allEnabled, [true, false, true, false, true, false, false, false, false, false, false]]) {
        for (const free of [false, true]) {
            compareGrid(grid, enabled, free);
            compareGrid(grid, enabled, free, () => { let count = 0; const r = () => { count++; return 1; }; r.drawCount = () => count; return r; });
        }
    }
}
const profiles = [];
function add(name, change) { const p = E.defaults(); if (change) change(p); assert.deepEqual(E.validate(p), []); profiles.push({ name, p }); }
add('普通与免费默认权重');
add('金牌为0', p => { p.goldChance = 0; });
add('金牌为100', p => { p.goldChance = 100; });
add('至尊关闭', p => { p.enabled[10] = false; });
add('免费至尊为0', p => { p.weights.f[10] = [0, 0, 0, 0, 0]; });
add('部分普通牌关闭', p => { for (const i of [1, 3, 6]) p.enabled[i] = false; });
add('普通全补牌', p => { for (let i = 0; i < 11; i++) p.weights.n[i] = [0, 0, 0, 0, 0]; });
add('免费全补牌', p => { for (let i = 0; i < 11; i++) p.weights.f[i] = [0, 0, 0, 0, 0]; });
profiles.push({ name: '小奖为主候选', p: E.scaleOrdinary(E.smallWinProfile(E.defaults()), 1.0757591877956105, null, true) });
let paid = 0, free = 0, cascades = 0, retriggers = 0;
for (let pi = 0; pi < profiles.length; pi++) {
    const { name, p } = profiles[pi], nc = E.compile(p), rc = R.compile(p);
    const words = seed.map((x, i) => (x + pi * (i + 1)) >>> 0), nr = checkedRandom(E, words), rr = checkedRandom(R, words);
    for (let round = 0; round < 1000; round++) {
        const bet = [4, 60, 200, 600][round % 4];
        const next = E.generateRound(nc, nr, bet, true), old = R.generateRound(rc, rr, bet, true);
        assert.deepEqual(next, old, name + '第' + round + '完整付费回合不同');
        assert.equal(nr.drawCount(), rr.drawCount(), name + '第' + round + '随机数消耗不同');
        paid++; free += next.chain.length; cascades += next.trig.roundCount;
        for (const fr of next.chain) { cascades += fr.roundCount; if (fr.freeWon) retriggers++; }
    }
}
assert(free > 0 && retriggers > 0, '必须覆盖完整免费链与免费再触发');
console.log(JSON.stringify({ pass: '逐格补牌、完整逐局轨迹、随机数消耗', reference: referencePath || 'embedded R4 substitute',
    referenceSha256: crypto.createHash('sha256').update(referenceSource).digest('hex'), craftedGrids: 4032, paid, free, cascades, retriggers }));

function timed(engine, p, count) {
    const c = engine.compile(p), r = checkedRandom(engine), stats = { total: 0, free: 0, cascades: 0, capped: 0 };
    const start = performance.now();
    for (let i = 0; i < count; i++) {
        const out = engine.generateRound(c, r, 60, false);
        stats.total += out.total; stats.free += out.chain.length; stats.cascades += out.trig.roundCount;
        if (out.capped) stats.capped++;
        for (const fr of out.chain) stats.cascades += fr.roundCount;
    }
    return { ms: performance.now() - start, draws: r.drawCount(), stats };
}
if (process.argv.includes('--benchmark')) {
    const p = profiles[profiles.length - 1].p;
    timed(R, p, 10000); timed(E, p, 10000);
    for (const count of [100000, 500000]) {
        const old = timed(R, p, count), next = timed(E, p, count);
        assert.deepEqual(next.stats, old.stats); assert.equal(next.draws, old.draws);
        console.log(JSON.stringify({ benchmark: '完整付费回合（包括所有免费）', count, referenceMs: old.ms, currentMs: next.ms,
            speedup: old.ms / next.ms, currentRoundsPerSecond: count * 1000 / next.ms, draws: next.draws, stats: next.stats }));
    }
}
