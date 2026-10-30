/* 麻将胡了出货率引擎（后台模拟用）。
 * 与服务端 MTH-Server/ServerCardMjhl/MjhlWeight.cpp 逐步一致：抽格顺序、随机数消耗顺序、杂牌替换、
 * 消除掉落、封顶与免费局规则改一处必须同步另一处（MTH-Server/tests/mjhl_weight_parity.js 逐局比对）。
 * 只用 ES5，页面与 node 共用：浏览器挂 window.MjhlEngine，node 走 module.exports。 */
(function (root, factory) {
    var api = factory();
    if (typeof module === 'object' && module.exports) module.exports = api;
    else root.MjhlEngine = api;
})(this, function () {
    'use strict';
    var COLS = 5, COL_LEN = [9, 12, 12, 12, 9], BUF_TOP = [4, 6, 6, 6, 4], LOGICAL = [4, 5, 5, 5, 4];
    var WILD = 20, SCATTER = 30, GOLD = 100, EMPTY = -1, BLANK = -2;
    var IDX_WILD = 9, IDX_SCATTER = 10, IDX_BLANK = 11, SYM_IDX = 11;
    var BET_SCALE = 10, SCORE_SCALE = 200, CAP_TIMES = 5000, MAX_ROUNDS = 10000, MAX_FREE_SPINS = 10000, MAX_TOTAL_ROUNDS = 100000;
    var BASE_MULT = [1, 2, 3, 5], FREE_MULT = [2, 4, 6, 10];
    // 押注入口是十分之一原分（4=0.4分）；赢分用 ticks（200 ticks=1原分），精确保留押注/20的奖金。
    var PAY = [null, [1, 3, 6], [1, 3, 6], [3, 5, 12], [3, 5, 12], [5, 10, 15], [6, 15, 30], [8, 20, 40], [10, 25, 50], [2, 4, 10]];
    var NAMES = ['二条', '二筒', '五条', '五筒', '八万', '白板', '红中', '发财', '三筒', '百搭牌', '至尊牌'];
    // 页面展示顺序（与 HTML 控制台一致）：红中、白板、发财、八万、五筒、五条、三筒、二筒、二条、百搭、至尊
    var DISPLAY_ORDER = [6, 5, 7, 4, 3, 2, 8, 1, 0, 9, 10];
    var LIMITS = {
        weightTotal: [100, 1000000, true], targetRtp: [1, 150, false], spinCount: [100, 1000000, true],
        calibrationSamples: [1000, 20000, true], goldChance: [0, 100, false], targetScatter: [0, 100, false]
    };
    var LABELS = {
        weightTotal: '每轴总权重', targetRtp: '目标总RTP（%）', spinCount: '模拟完整付费回合数',
        calibrationSamples: '自动分配试算精度', goldChance: '普通模式金色牌出现概率（%）', targetScatter: '目标至尊触发率（%）'
    };

    function multiplier(k, free) { var i = k < 3 ? k : 3; return free ? FREE_MULT[i] : BASE_MULT[i]; }
    function betTicks(bet) { return bet * (SCORE_SCALE / BET_SCALE); }
    function copy(x) { return JSON.parse(JSON.stringify(x)); }
    function isInt(n) { return typeof n === 'number' && isFinite(n) && Math.floor(n) === n; }
    function normalize(p) {
        // 旧字段保留以兼容存量配置和协议，免费玩法固定遵循客户端规则。
        p.retrigger = true; p.retriggerAward = 0; p.retriggerLimit = 0; p.freeLimit = 0;
        return p;
    }
    function GenerationLimitError() {
        this.name = 'GenerationLimitError'; this.code = 'MJHL_GENERATION_LIMIT';
        this.message = '当前权重产生的连消或免费链无法在计算预算内完整结束，请调整权重后重试；本次未输出部分结果。';
    }
    GenerationLimitError.prototype = Object.create(Error.prototype);
    GenerationLimitError.prototype.constructor = GenerationLimitError;

    function mulberry32(seed) {
        var x = seed >>> 0;
        return function () {
            x = (x + 0x6D2B79F5) >>> 0;
            var t = x;
            t = Math.imul(t ^ (t >>> 15), t | 1);
            t ^= t + Math.imul(t ^ (t >>> 7), t | 61);
            return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
        };
    }
    function freshSeed() {
        try { var a = new Uint32Array(1); (window.crypto || window.msCrypto).getRandomValues(a); return a[0]; }
        catch (e) { return Math.floor(Math.random() * 4294967296) >>> 0; }
    }

    // ---------------- 配置 ----------------
    function scatterProbability(target) {
        if (target <= 0) return 0;
        if (target >= 1) return 1;
        var lo = 0, hi = 1;
        for (var i = 0; i < 60; i++) {
            var m = (lo + hi) / 2;
            var p3 = 1 - Math.pow(1 - m, 23) - 23 * m * Math.pow(1 - m, 22) - 253 * m * m * Math.pow(1 - m, 21);
            if (p3 < target) lo = m; else hi = m;
        }
        return (lo + hi) / 2;
    }
    // 保留旧示例权重便于迁移；规则修正后必须重新模拟或自动分配，旧 RTP 统计不再适用。
    function defaults() {
        var n = [[1561, 1469, 1469, 1469, 1561], [1560, 1469, 1469, 1469, 1560], [656, 618, 618, 618, 656], [656, 617, 617, 617, 656], [496, 467, 467, 467, 496],
            [209, 196, 196, 196, 209], [146, 137, 137, 137, 146], [110, 104, 104, 104, 110], [824, 776, 776, 776, 824], [0, 20, 20, 20, 0], [0, 568, 568, 568, 0]];
        var f = [[546, 514, 514, 514, 546], [546, 514, 514, 514, 546], [230, 216, 216, 216, 230], [230, 216, 216, 216, 230], [174, 164, 164, 164, 174],
            [73, 69, 69, 69, 73], [51, 48, 48, 48, 51], [38, 36, 36, 36, 38], [288, 271, 271, 271, 288], [0, 20, 20, 20, 0], [0, 568, 568, 568, 0]];
        return {
            version: 1, weightTotal: 10000, enabled: [true, true, true, true, true, true, true, true, true, true, true],
            weights: { n: n, f: f }, goldChance: 8, retrigger: true, retriggerAward: 0, retriggerLimit: 0, freeLimit: 0,
            targetRtp: 90, targetScatter: 5, spinCount: 10000, calibrationSamples: 5000
        };
    }

    function validate(p) {
        var errors = [], k;
        if (!p || p.version !== 1) return ['配置版本不正确。'];
        for (k in LIMITS) {
            var lim = LIMITS[k], v = Number(p[k]);
            if (!isFinite(v) || v < lim[0] || v > lim[1] || (lim[2] && !isInt(v)))
                errors.push(LABELS[k] + '：请填写' + lim[0] + '至' + lim[1] + '之间的' + (lim[2] ? '整数' : '数值') + '。');
        }
        if (!p.enabled || p.enabled.length !== SYM_IDX) errors.push('启用标志不完整。');
        var anyRegular = false;
        for (var i = 0; i < 9; i++) if (p.enabled && p.enabled[i]) anyRegular = true;
        if (!anyRegular) errors.push('请至少启用一种普通赔付牌。');
        var modes = ['n', 'f'];
        for (var mi = 0; mi < 2; mi++) {
            var m = modes[mi], rows = p.weights && p.weights[m];
            if (!rows || rows.length !== SYM_IDX) { errors.push('权重表不完整。'); continue; }
            for (var c = 0; c < 5; c++) {
                var used = 0;
                for (var s = 0; s < SYM_IDX; s++) {
                    var w = rows[s] && rows[s][c];
                    if (!isInt(w) || w < 0 || w > 1000000) { errors.push(NAMES[s] + '权重必须为0至1000000的整数。'); continue; }
                    if ((c === 0 || c === 4) && w !== 0 && s === IDX_WILD) errors.push(NAMES[s] + '只能出现在第2–4轴。');
                    if (p.enabled && p.enabled[s]) used += w;
                }
                if (used > Number(p.weightTotal)) errors.push((m === 'n' ? '普通' : '免费') + '轴' + (c + 1) + '：其它牌权重' + used + '超过总量' + p.weightTotal + '，请降低其它权重。');
            }
        }
        var seen = {}, out = [];
        for (var e = 0; e < errors.length; e++) if (!seen[errors[e]]) { seen[errors[e]] = 1; out.push(errors[e]); }
        return out;
    }

    function blankWeights(p, m) {
        var out = [];
        for (var c = 0; c < 5; c++) {
            var used = 0;
            for (var s = 0; s < SYM_IDX; s++) if (p.enabled[s]) used += p.weights[m][s][c];
            out.push(Math.max(0, Number(p.weightTotal) - used));
        }
        return out;
    }

    function compile(p) {
        var errors = validate(p);
        if (errors.length) throw new Error(errors.join('\n'));
        var eff = [[], []], total = [[], []], modes = ['n', 'f'];
        for (var mi = 0; mi < 2; mi++) {
            var blank = blankWeights(p, modes[mi]);
            for (var s = 0; s <= SYM_IDX; s++) {
                eff[mi].push([0, 0, 0, 0, 0]);
                for (var c = 0; c < 5; c++)
                    eff[mi][s][c] = s === IDX_BLANK ? blank[c] : (p.enabled[s] ? p.weights[modes[mi]][s][c] : 0);
            }
            for (var c2 = 0; c2 < 5; c2++) total[mi].push(Number(p.weightTotal));
        }
        return {
            eff: eff, total: total, enabled: p.enabled.slice(0),
            gold: Math.round(Number(p.goldChance) * 100) / 10000,
            retrigger: true, award: 0, limit: 0, freeLimit: 0
        };
    }

    // ---------------- 盘面 ----------------
    function drawCell(c, r, col, free) {
        var m = free ? 1 : 0, x = r() * c.total[m][col], acc = 0, idx = -1, last = -1;
        for (var i = 0; i <= SYM_IDX; i++) {
            var w = c.eff[m][i][col];
            if (w === 0) continue;
            last = i; acc += w;
            if (x < acc) { idx = i; break; }
        }
        if (idx < 0) idx = last;
        if (idx >= 0 && idx < 9) {
            var s = idx + 1;
            if (free && col === 2) return GOLD + s;
            if (col >= 1 && col <= 3 && r() < c.gold) return GOLD + s;
            return s;
        }
        if (idx === IDX_WILD) return WILD;
        if (idx === IDX_SCATTER) return SCATTER;
        return BLANK;
    }
    function visibleHas(g, col, s) {
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
    function generateGrid(c, r, free) {
        var g = [];
        for (var col = 0; col < COLS; col++) {
            var a = [];
            for (var i = 0; i < COL_LEN[col]; i++) a.push(drawCell(c, r, col, free));
            g.push(a);
        }
        substitute(c, r, free, g);
        return g;
    }
    function evaluate(g, bet, mult) {
        var lines = [], total = 0;
        for (var s = 1; s <= 9; s++) {
            var ways = 1, allWild = 1, run = 0;
            for (var col = 0; col < COLS; col++) {
                var n = 0, nw = 0;
                for (var r = 0; r < LOGICAL[col]; r++) {
                    var v = g[col][BUF_TOP[col] + r];
                    if (v === s || v === GOLD + s) n++;
                    else if (v === WILD) { n++; nw++; }
                }
                if (n === 0) break;
                ways *= n; allWild *= nw; run++;
            }
            if (run < 3) continue;
            var eff = ways - allWild;
            if (eff <= 0) continue;
            var win = PAY[s][run - 3] * eff * mult * bet;
            var pos = [];
            for (var col2 = 0; col2 < run; col2++)
                for (var r2 = 0; r2 < LOGICAL[col2]; r2++) {
                    var v2 = g[col2][BUF_TOP[col2] + r2];
                    if (v2 === s || v2 === GOLD + s || v2 === WILD) pos.push([col2, r2]);
                }
            total += win;
            lines.push({ symbol: s, count: run, ways: eff, win: win, positions: pos });
        }
        return { total: total, lines: lines };
    }
    function countScatter(g) {
        var n = 0;
        for (var col = 0; col < COLS; col++)
            for (var r = 0; r < LOGICAL[col]; r++) if (g[col][BUF_TOP[col] + r] === SCATTER) n++;
        return n;
    }
    function eliminateAndDrop(c, r, free, lines, g) {
        var mark = [], col, i;
        for (col = 0; col < COLS; col++) { mark.push([]); for (i = 0; i < COL_LEN[col]; i++) mark[col].push(false); }
        for (var l = 0; l < lines.length; l++)
            for (var p = 0; p < lines[l].positions.length; p++) {
                var pc = lines[l].positions[p][0];
                mark[pc][BUF_TOP[pc] + lines[l].positions[p][1]] = true;
            }
        for (col = 0; col < COLS; col++)
            for (i = 0; i < COL_LEN[col]; i++) {
                if (!mark[col][i]) continue;
                var v = g[col][i];
                if (v >= GOLD) g[col][i] = WILD;
                else if (v !== SCATTER) g[col][i] = EMPTY;
            }
        for (col = 0; col < COLS; col++) {
            var next = [];
            for (i = 0; i < COL_LEN[col]; i++) if (g[col][i] !== EMPTY) next.push(g[col][i]);
            var removed = COL_LEN[col] - next.length, fresh = [];
            for (i = 0; i < removed; i++) fresh.push(drawCell(c, r, col, free));
            g[col] = fresh.concat(next);
        }
        substitute(c, r, free, g);
    }
    function spinGrid(c, r, bet, free, budget, g, record) {
        var res = { totalWin: 0, scatterMax: 0, freeWon: 0, capped: false, hit: false, rounds: record ? [] : null, roundCount: 0 };
        for (var k = 0; ; k++) {
            var mult = multiplier(k, free), ev = evaluate(g, bet, mult), score = ev.total;
            var remain = budget - res.totalWin;
            if (remain < 0) remain = 0;
            if (score > remain) score = remain;
            if (record) res.rounds.push({ grid: copy(g), multiplier: mult, winScore: score, lines: ev.lines.map(function (x) { return [x.symbol, x.count, x.ways, x.win]; }) });
            res.roundCount++;
            if (k === 0) res.hit = ev.lines.length > 0;
            var sc = countScatter(g);
            if (sc > res.scatterMax) res.scatterMax = sc;
            res.totalWin += score;
            if (!ev.lines.length) break;
            eliminateAndDrop(c, r, free, ev.lines, g);
            if (res.totalWin >= budget) {
                res.capped = true;
                if (record) res.rounds.push({ grid: copy(g), multiplier: multiplier(k + 1, free), winScore: 0, lines: [] });
                res.roundCount++;
                sc = countScatter(g);
                if (sc > res.scatterMax) res.scatterMax = sc;
                break;
            }
            if (k + 1 >= MAX_ROUNDS) throw new GenerationLimitError();
        }
        res.freeWon = initialFree(c, res.scatterMax);
        return res;
    }
    function spin(c, r, bet, free, budget, record) { return spinGrid(c, r, bet, free, budget, generateGrid(c, r, free), record); }
    function initialFree(c, n) { return n < 3 ? 0 : 10 + 2 * (n - 3); }
    // 一个付费回合：付费旋转 + 整条免费链（与服务端 GenerateRound 一致）
    function generateRound(c, r, bet, record) {
        var cap = CAP_TIMES * betTicks(bet), trig = spin(c, r, bet, false, cap, record), initial = initialFree(c, trig.scatterMax);
        var total = trig.totalWin, granted = initial, used = 0, chain = [], capped = trig.capped, totalRounds = trig.roundCount;
        while (used < granted) {
            if (used >= MAX_FREE_SPINS) throw new GenerationLimitError();
            used++;
            var fr = spin(c, r, bet, true, cap, record);
            totalRounds += fr.roundCount;
            if (totalRounds > MAX_TOTAL_ROUNDS) throw new GenerationLimitError();
            total += fr.totalWin; granted += fr.freeWon;
            capped = capped || fr.capped;
            chain.push(fr);
        }
        return { trig: trig, chain: chain, total: total, capped: capped, limited: 0 };
    }

    // ---------------- 统计 ----------------
    // 分批跑（每批后让出线程），onDone(err, stats)；cancelled() 返回 true 时中止
    function sample(profile, count, seed, opts, onDone) {
        var c;
        try { c = compile(profile); } catch (e) { onDone(e); return; }
        opts = opts || {};
        var r = mulberry32(seed), bet = 20 * BET_SCALE, i = 0, n = 0, f = 0, h = 0, t = 0, caps = 0, mean = 0, m2 = 0;
        function step() {
            if (opts.cancelled && opts.cancelled()) { onDone(new Error('已停止计算，未输出未完成样本。')); return; }
            var end = Math.min(count, i + 500);
            for (; i < end; i++) {
                var x;
                try { x = generateRound(c, r, bet, false); } catch (err) { onDone(err); return; }
                var tot = x.total / betTicks(bet);
                n += x.trig.totalWin / betTicks(bet); f += (x.total - x.trig.totalWin) / betTicks(bet);
                if (x.trig.hit) h++;
                if (x.trig.scatterMax >= 3) t++;
                if (x.capped) caps++;
                var d = tot - mean; mean += d / (i + 1); m2 += d * (tot - mean);
            }
            if (opts.onProgress) opts.onProgress(i, count);
            if (i < count) { setTimeout(step, 0); return; }
            onDone(null, {
                normal: n / count, free: f / count, total: (n + f) / count, hit: h / count, miss: 1 - h / count,
                scatter: t / count, cap: caps / count, half95: count > 1 ? 1.96 * Math.sqrt(m2 / (count - 1) / count) : 0,
                trunc: 0, freeLimited: 0, count: count
            });
        }
        step();
    }
    // 初盘至尊触发率解析值（全部5轴可见23格独立抽样）；连消补出的至尊另计，实际以模拟为准
    function binomialTail(p) {
        var dist = [1], total = Number(p.weightTotal);
        for (var col = 0; col < COLS; col++) {
            var q = p.enabled[IDX_SCATTER] ? p.weights.n[IDX_SCATTER][col] / total : 0;
            for (var pos = 0; pos < LOGICAL[col]; pos++) {
                var next = [];
                for (var k = 0; k <= dist.length; k++) next.push(0);
                for (var j = 0; j < dist.length; j++) { next[j] += dist[j] * (1 - q); next[j + 1] += dist[j] * q; }
                dist = next;
            }
        }
        var s = 0;
        for (var i = 3; i < dist.length; i++) s += dist[i];
        return s;
    }
    // 按目标至尊率同步至尊权重；余额不足时抛错且不改原配置
    function syncScatter(base) {
        var next = copy(base), target = Number(next.targetScatter) / 100, total = Number(next.weightTotal);
        if (target > 0 && !next.enabled[IDX_SCATTER]) throw new Error('目标至尊触发率大于0，请先启用至尊牌，或把目标改为0。');
        var w = next.enabled[IDX_SCATTER] ? Math.round(scatterProbability(target) * total) : 0, modes = ['n', 'f'];
        for (var mi = 0; mi < 2; mi++) {
            var m = modes[mi];
            next.weights[m][IDX_SCATTER] = [w, w, w, w, w];
            for (var col = 0; col < COLS; col++) {
                var used = 0;
                for (var s = 0; s < SYM_IDX; s++) if (next.enabled[s]) used += next.weights[m][s][col];
                if (used > total) throw new Error((m === 'n' ? '普通' : '免费') + '轴' + (col + 1) + '杂牌余额不足以同步至尊目标：需减少其它权重' + (used - total) + '。当前权重未修改。');
            }
        }
        return next;
    }
    function allocateUnits(ids, shares, amount) {
        var out = []; for (var z = 0; z < SYM_IDX; z++) out.push(0);
        if (!ids.length || amount <= 0) return out;
        var sum = 0, k; for (k = 0; k < shares.length; k++) sum += shares[k];
        var vals = [], used = 0;
        for (k = 0; k < ids.length; k++) { var exact = amount * shares[k] / sum; out[ids[k]] = Math.floor(exact); used += out[ids[k]]; vals.push({ id: ids[k], frac: exact - Math.floor(exact) }); }
        vals.sort(function (a, b) { return b.frac - a.frac; });
        for (k = 0; k < amount - used; k++) out[vals[k % vals.length].id]++;
        return out;
    }
    // 自动分配候选：低价牌偏多、高价牌偏少；至尊按目标率、百搭 0.2%，其余为杂牌
    function candidate(base, occupancy, power, freeFactor) {
        var s = copy(base), total = Number(s.weightTotal), modes = ['n', 'f'];
        var scatterW = s.enabled[IDX_SCATTER] ? Math.round(scatterProbability(Number(s.targetScatter) / 100) * total) : 0;
        var ordinary = [];
        for (var i = 0; i < 9; i++) if (s.enabled[i]) ordinary.push(i);
        if (!ordinary.length) throw new Error('请至少启用一种普通赔付牌，才能自动分配。');
        var shares = ordinary.map(function (i2) { return 1 / Math.pow(PAY[i2 + 1][2], power); });
        for (var mi = 0; mi < 2; mi++)
            for (var col = 0; col < 5; col++) {
                var m = modes[mi];
                for (var k = 0; k < SYM_IDX; k++) s.weights[m][k][col] = 0;
                var inner = col >= 1 && col <= 3;
                var sw = scatterW;
                s.weights[m][IDX_SCATTER][col] = sw;
                var ww = s.enabled[IDX_WILD] && inner ? Math.min(total - sw, Math.round(total * 0.002)) : 0;
                s.weights[m][IDX_WILD][col] = ww;
                var room = total - sw - ww, adj = m === 'f' ? occupancy * freeFactor : occupancy;
                var occupied = Math.floor(Math.min(1, Math.max(0, adj)) * room);
                var units = allocateUnits(ordinary, shares, occupied);
                for (var o = 0; o < ordinary.length; o++) s.weights[m][ordinary[o]][col] = units[ordinary[o]];
            }
        return s;
    }

    return {
        COLS: COLS, COL_LEN: COL_LEN, BUF_TOP: BUF_TOP, LOGICAL: LOGICAL, PAY: PAY, NAMES: NAMES, DISPLAY_ORDER: DISPLAY_ORDER,
        IDX_WILD: IDX_WILD, IDX_SCATTER: IDX_SCATTER, SYM_IDX: SYM_IDX, BET_SCALE: BET_SCALE, SCORE_SCALE: SCORE_SCALE, betTicks: betTicks, CAP_TIMES: CAP_TIMES, MAX_ROUNDS: MAX_ROUNDS, MAX_FREE_SPINS: MAX_FREE_SPINS, MAX_TOTAL_ROUNDS: MAX_TOTAL_ROUNDS,
        mulberry32: mulberry32, freshSeed: freshSeed, defaults: defaults, validate: validate, compile: compile, normalize: normalize,
        blankWeights: blankWeights, generateGrid: generateGrid, evaluate: evaluate, spin: spin, spinGrid: spinGrid, eliminateAndDrop: eliminateAndDrop, initialFree: initialFree, generateRound: generateRound,
        sample: sample, scatterProbability: scatterProbability, binomialTail: binomialTail, syncScatter: syncScatter,
        candidate: candidate, copy: copy, GenerationLimitError: GenerationLimitError
    };
});
