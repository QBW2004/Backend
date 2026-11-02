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
        weightTotal: [100, 1000000, true], targetRtp: [0, 1000, false], spinCount: [100, 1000000, true],
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
        try { var a = new Uint32Array(1), host = typeof self !== 'undefined' ? self : typeof window !== 'undefined' ? window : null; (host.crypto || host.msCrypto).getRandomValues(a); return a[0]; }
        catch (e) { return Math.floor(Math.random() * 4294967296) >>> 0; }
    }
    function freshSeed128() {
        var words = [freshSeed(),freshSeed(),freshSeed(),freshSeed()];
        if (!(words[0] | words[1] | words[2] | words[3])) words[3] = 1;
        return words;
    }

    // xoshiro128** 1.1，David Blackman / Sebastiano Vigna，公共领域。
    // 官方算法：https://prng.di.unimi.it/xoshiro128starstar.c
    // 验证专用128位状态（周期2^128-1），避免与搜索的32位mulberry32循环重叠。
    function xoshiro128ss(words) {
        if (!words || words.length!==4) throw new Error('验证随机种子需4个32位整数。');
        var w=[], draws=0;
        for(var i=0;i<4;i++) {if(!isInt(words[i]) || words[i]<0 || words[i]>4294967295) throw new Error('验证随机种子无效。');w.push(words[i]>>>0);}
        if(!(w[0]|w[1]|w[2]|w[3])) throw new Error('验证随机种子不能全零。');
        var a=w[0],b=w[1],c=w[2],d=w[3];
        function rotl(x,k) {return (x<<k)|(x>>>(32-k));}
        function uint32() {
            var result=Math.imul(rotl(Math.imul(b,5),7),9)>>>0, t=b<<9;
            c^=a;d^=b;b^=c;a^=d;c^=t;d=rotl(d,11);draws++;
            return result;
        }
        var next=function(){return uint32()/4294967296;};
        next.uint32=uint32;next.drawCount=function(){return draws;};
        return next;
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
    function visibleMask(g, col) {
        var mask = 0;
        for (var r = 0; r < LOGICAL[col]; r++) {
            var v = g[col][BUF_TOP[col] + r];
            if (v === WILD) return 511;
            if (v >= GOLD) v -= GOLD;
            if (v >= 1 && v <= 9) mask |= 1 << (v - 1);
        }
        return mask;
    }
    function substitute(c, r, free, g) {
        var enabledMask = 0, s;
        for (s = 1; s <= 9; s++) if (c.enabled[s - 1]) enabledMask |= 1 << (s - 1);
        for (var col = 0; col < COLS; col++) {
            // 同一轴的候选只依赖其它轴，补本轴不会改变候选；按轴计算一次，仍逐格消耗同一个随机数。
            // 只统计可见格，缓冲格不参与避奖；金牌视作原牌、百搭同时代表九种普通牌。
            var cand = null;
            for (var i = 0; i < COL_LEN[col]; i++) {
                if (g[col][i] !== BLANK) continue;
                if (cand === null) {
                    var mask = col === 0 ? enabledMask & ~(visibleMask(g, 1) & visibleMask(g, 2)) : enabledMask & ~visibleMask(g, 0);
                    if (col >= 2 && mask) {
                        var strong = mask & ~visibleMask(g, 1);
                        if (strong) mask = strong;
                    }
                    if (!mask) mask = enabledMask;
                    cand = [];
                    // 升序与旧实现相同，不能改变随机下标对应的牌。
                    for (s = 1; s <= 9; s++) if (mask & (1 << (s - 1))) cand.push(s);
                }
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
        var r = typeof opts.random === 'function' ? opts.random : mulberry32(seed), bet = 20 * BET_SCALE, i = 0, n = 0, f = 0, h = 0, t = 0, caps = 0, mean = 0, m2 = 0;
        var distribution = { zero:0, small:0, medium:0, big:0, mega:0, super:0 };
        function step() {
            if (opts.cancelled && opts.cancelled()) { onDone(new Error('已停止计算，未输出未完成样本。')); return; }
            var end = Math.min(count, i + Math.max(100, Math.min(10000, Number(opts.batchSize) || 500)));
            for (; i < end; i++) {
                var x;
                try { x = generateRound(c, r, bet, false); } catch (err) { onDone(err); return; }
                var tot = x.total / betTicks(bet);
                n += x.trig.totalWin / betTicks(bet); f += (x.total - x.trig.totalWin) / betTicks(bet);
                if (x.trig.hit) h++;
                if (x.trig.scatterMax >= 3) t++;
                if (x.capped) caps++;
                distribution[payoutBand(tot)]++;
                var d = tot - mean; mean += d / (i + 1); m2 += d * (tot - mean);
            }
            if (opts.onProgress) opts.onProgress(i, count);
            if (i < count) { setTimeout(step, 0); return; }
            onDone(null, {
                normal: n / count, free: f / count, total: (n + f) / count, hit: h / count, miss: 1 - h / count,
                scatter: t / count, cap: caps / count, half95: count > 1 ? 1.96 * Math.sqrt(m2 / (count - 1) / count) : 0,
                trunc: 0, freeLimited: 0, count: count, m2:m2, mean:mean,
                distribution:distribution, roundHit:1 - distribution.zero / count,
                intervalReliable:m2 > 0, unobservedReturn:distribution.zero === count
            });
        }
        step();
    }

    // 按完整付费回合的总返奖/押注分档，包含全部免费和连消；返奖倍数不是净赢倍数。
    function payoutBand(multiple) {
        return multiple === 0 ? 'zero' : multiple < 5 ? 'small' : multiple < 20 ? 'medium' : multiple < 35 ? 'big' : multiple < 50 ? 'mega' : 'super';
    }
    function mergeSampleStats(acc, part) {
        if (!acc) return copy(part);
        var old = acc.count, n = part.count, total = old + n;
        var oldMean = typeof acc.mean === 'number' ? acc.mean : acc.total;
        var partMean = typeof part.mean === 'number' ? part.mean : part.total;
        var delta = partMean - oldMean;
        acc.m2 += part.m2 + delta * delta * old * n / total;
        acc.mean = oldMean + delta * n / total;
        var keys = ['normal','free','total','hit','miss','scatter','cap'];
        for (var k = 0; k < keys.length; k++) acc[keys[k]] = (acc[keys[k]] * old + part[keys[k]] * n) / total;
        var bands = ['zero','small','medium','big','mega','super'];
        for (k = 0; k < bands.length; k++) acc.distribution[bands[k]] += part.distribution[bands[k]];
        acc.count = total;
        acc.roundHit = 1 - acc.distribution.zero / total;
        acc.intervalReliable = acc.m2 > 0;
        acc.unobservedReturn = acc.distribution.zero === total;
        return acc;
    }
    // 仅证明这一类无奖结构：前两轴没有补牌或有效百搭，普通牌占满且牌种无交集；
    // 普通局任何轴都没有有效至尊，因此不能从第三轴以后另触发免费。绝不改输入权重。
    function proveZeroReturn(profile) {
        if (!profile || !profile.weights || !profile.weights.n || !profile.enabled) return false;
        if (validate(profile).length) return false;
        var rows = profile.weights.n, first = 0, second = 0;
        for (var s = 0; s < 9; s++) if (profile.enabled[s]) {
            if (!rows[s]) return false;
            first += rows[s][0]; second += rows[s][1];
            if (rows[s][0] > 0 && rows[s][1] > 0) return false;
        }
        if (first !== Number(profile.weightTotal) || second !== Number(profile.weightTotal)) return false;
        if (profile.enabled[IDX_SCATTER]) for (var c = 0; c < COLS; c++) if (!rows[IDX_SCATTER] || rows[IDX_SCATTER][c] !== 0) return false;
        return true;
    }
    // 单纯复核最多五次查看；一键校准若预留一次纠偏，则两个候选合计最多十次查看。
    // 两个候选从第一次检查起就按共同次数做 Bonferroni 校正，仍为约95%的正态近似区间。
    function verificationZ(checkCount) {
        return [0,1.95996398454,2.2414027276,2.3939797998,2.4977054744,2.57582930355,
            2.63825727348,2.69010952716,2.73436878653,2.77292129461,2.80703376834][checkCount];
    }
    function verifyRtp(profile, opts, onDone) {
        opts = opts || {};
        var errors = validate(profile);
        if (errors.length) { onDone(new Error(errors.join('\n'))); return; }
        if (opts.cancelled && opts.cancelled()) { var cancelError = new Error('已取消计算，参数未修改。'); cancelError.code = 'MJHL_RTP_CANCELLED'; onDone(cancelError); return; }
        if (proveZeroReturn(profile)) {
            var proven = { normal:0, free:0, total:0, hit:0, miss:1, scatter:0, cap:0, half95:0, trunc:0, freeLimited:0,
                count:0, m2:0, mean:0, distribution:{zero:0,small:0,medium:0,big:0,mega:0,super:0}, roundHit:0,
                intervalReliable:true, unobservedReturn:false, zeroProven:true };
            onDone(null, { stats:proven, exact:true, precisionReached:true,
                targetReached:typeof opts.targetPercent === 'number' ? opts.targetPercent === 0 : null,
                tolerancePercent:0, reason:'普通前两轴由互不相同的普通牌占满，无百搭或补牌；普通所有轴无至尊，因此没有中奖或免费触发。',
                validationSeed128:[], validationRng:'proof', validationDraws:0, validationBatches:[], plannedCheckpoints:[] });
            return;
        }
        var maxCount = Math.max(100, Math.min(50000000, Math.floor(Number(opts.validationCount) || 50000000)));
        var tolerancePercent = Number(opts.tolerancePercent);
        if (!isFinite(tolerancePercent) || tolerancePercent <= 0) tolerancePercent = 0.5;
        var seed = opts.seed === undefined ? freshSeed() : (Number(opts.seed) >>> 0);
        var words = opts.validationSeed128 || [(seed^0x243f6a88)>>>0,(seed^0x85a308d3)>>>0,(seed^0x13198a2e)>>>0,(seed^0x03707344)>>>0];
        var random, frozen;
        try { words = words.slice(0); random = xoshiro128ss(words); frozen = copy(profile); }
        catch (error) { onDone(error); return; }
        // 提前安排检查点；检查次数不增加，不根据中途输赢临时挑选停止时机。
        var proposed = opts.quickCheckpoints ? [250000,1000000,3000000,10000000,maxCount] : [1000000,5000000,10000000,25000000,maxCount], checkpoints = [];
        for (var i = 0; i < proposed.length; i++) if (proposed[i] <= maxCount && checkpoints.indexOf(proposed[i]) < 0) checkpoints.push(proposed[i]);
        checkpoints.sort(function (a,b) { return a-b; });
        var confidenceCheckCount = Math.max(checkpoints.length, Math.min(10, Math.floor(Number(opts.confidenceCheckCount) || checkpoints.length)));
        var z = verificationZ(confidenceCheckCount), checkAt = 0, stats = null, batches = [], finished = false;
        var runSample = opts.sampleRunner || sample, parallelDraws = 0, parallelRng = '';
        var hasTarget = typeof opts.targetPercent === 'number' && isFinite(opts.targetPercent), target = hasTarget ? opts.targetPercent / 100 : 0;
        function done(error, result) { if (!finished) { finished = true; onDone(error, result); } }
        function isCancelled() { return !!(opts.cancelled && opts.cancelled()); }
        function stopIfCancelled() {
            if (!isCancelled()) return false;
            var error = new Error('已取消计算，参数未修改。'); error.code = 'MJHL_RTP_CANCELLED'; done(error); return true;
        }
        function next() {
            if (finished) return;
            if (stopIfCancelled()) return;
            var offset = stats ? stats.count : 0;
            var blockLimit = opts.sampleRunner ? 1000000 : 250000;
            var block = Math.max(100, Math.min(blockLimit, Math.floor(Number(opts.blockCount) || blockLimit)));
            var count = Math.min(block, checkpoints[checkAt] - offset);
            runSample(frozen, count, seed, { random:random, batchSize:10000, cancelled:isCancelled,
                sampleOffset:offset, validationSeed128:words.slice(0), validationCount:maxCount, onProgress:function (n) {
                if (opts.onValidationProgress) opts.onValidationProgress(offset + n, maxCount);
            } }, function (error, part) {
                if (stopIfCancelled()) return;
                if (error) { if (isCancelled()) error.code = 'MJHL_RTP_CANCELLED'; done(error); return; }
                if (opts.sampleRunner) {
                    if (!part || !part.parallelBatches || part.count !== count || !isFinite(part.parallelDraws)) {
                        done(new Error('并行样本不完整，未采用本次计算结果。')); return;
                    }
                    for (var b = 0; b < part.parallelBatches.length; b++) batches.push(part.parallelBatches[b]);
                    parallelDraws += part.parallelDraws; parallelRng = part.parallelRng;
                } else batches.push({ seed128:words.slice(0), offset:offset, count:count });
                stats = mergeSampleStats(stats, part);
                // 分片元数据由结果顶层完整累计，不能让合并函数保留第一片的旧值。
                delete stats.parallelBatches; delete stats.parallelDraws; delete stats.parallelRng; delete stats.parallelWorkers;
                stats.half95 = z * Math.sqrt(stats.m2 / (stats.count - 1) / stats.count);
                stats.intervalZ = z;
                if (stats.count === checkpoints[checkAt]) {
                    var reached = stats.intervalReliable && stats.half95 <= tolerancePercent / 100;
                    var targetReached = !hasTarget || (stats.intervalReliable && Math.abs(stats.total - target) + stats.half95 <= tolerancePercent / 100);
                    var targetMiss = hasTarget && stats.intervalReliable &&
                        (stats.total + stats.half95 < target - tolerancePercent / 100 || stats.total - stats.half95 > target + tolerancePercent / 100);
                    // 首轮已有足够精度但偏在目标区间边缘时，交给一次有界续调，
                    // 避免仅为压缩同一候选的误差而直接等到5000万局；续调必须换全新验证流。
                    var needsCorrection = !!opts.allowTargetCorrection && hasTarget && !targetReached && reached &&
                        stats.half95 <= tolerancePercent / 100 * 0.8 && Math.abs(stats.total-target) > tolerancePercent / 100 * 0.25;
                    if (opts.onCheckpoint) opts.onCheckpoint(stats, reached && targetReached);
                    if (stopIfCancelled()) return;
                    checkAt++;
                    if ((reached && targetReached) || targetMiss || needsCorrection || checkAt === checkpoints.length) {
                        done(null, { stats:stats, precisionReached:reached, targetReached:hasTarget ? targetReached : null,
                            tolerancePercent:tolerancePercent, exact:false, validationSeed128:words.slice(0), validationRng:parallelRng || 'xoshiro128** 1.1',
                            validationDraws:opts.sampleRunner ? parallelDraws : random.drawCount(), validationBatches:batches, plannedCheckpoints:checkpoints.slice(0), confidenceCheckCount:confidenceCheckCount,
                            targetMiss:targetMiss, needsCorrection:needsCorrection, stoppedEarly:(targetMiss || needsCorrection) && checkAt < checkpoints.length });
                        return;
                    }
                }
                // 小块验收可能同步完成，块间让出避免递归堆栈增长，也保留取消机会。
                setTimeout(next, 0);
            });
        }
        next();
    }

    // 按实际模拟结果调节普通牌权重。保留至尊/百搭相对权重，只缩放普通赔付牌，
    // 每轴剩余量仍由空白牌吸收；因此输出仍是服务端可接受的完整权重表。
    function scaleOrdinary(profile, factor, reservedScatter, keepOrdinaryPositive) {
        var next = copy(profile), modes = ['n', 'f'];
        factor = Number(factor);
        if (!isFinite(factor) || factor < 0) throw new Error('权重缩放必须是非负数。');
        for (var mi = 0; mi < modes.length; mi++) {
            var rows = next.weights[modes[mi]];
            for (var col = 0; col < COLS; col++) {
                var ordinary = 0, fixed = 0, s;
                for (s = 0; s < 9; s++) if (next.enabled[s]) ordinary += rows[s][col];
                for (s = 9; s < SYM_IDX; s++) if (next.enabled[s]) fixed += rows[s][col];
                // 关闭至尊只改变本次模拟，不挤占恢复开关时需要的已保存权重空间。
                var reserved = reservedScatter && reservedScatter[modes[mi]] ? Number(reservedScatter[modes[mi]][col]) : 0;
                if (!isFinite(reserved) || reserved < 0 || reserved > Number(next.weightTotal)) throw new Error('至尊保留权重无效。');
                fixed += Math.max(0, reserved - (next.enabled[IDX_SCATTER] ? rows[IDX_SCATTER][col] : 0));
                if (fixed > Number(next.weightTotal)) throw new Error('保留至尊与百搭权重超过每轴总量。');
                var room = Math.max(0, Number(next.weightTotal) - fixed);
                var wanted = Math.min(room, Math.round(ordinary * factor));
                if (keepOrdinaryPositive) {
                    var ids = [], shares = [];
                    for (s = 0; s < 9; s++) if (next.enabled[s]) { ids.push(s); shares.push(Math.max(1, rows[s][col])); }
                    if (room < ids.length) throw new Error('当前百搭和至尊占满该轴，无法保留普通赔付牌，请先调整权重。');
                    wanted = Math.max(ids.length, wanted);
                    var units = allocateUnits(ids, shares, wanted - ids.length);
                    for (s = 0; s < 9; s++) rows[s][col] = next.enabled[s] ? units[s] + 1 : 0;
                    continue;
                }
                if (!ordinary || !wanted) {
                    for (s = 0; s < 9; s++) if (next.enabled[s]) rows[s][col] = 0;
                    continue;
                }
                var used = 0, parts = [], i;
                for (i = 0; i < 9; i++) {
                    if (!next.enabled[i] || rows[i][col] <= 0) continue;
                    var exact = Math.max(0, Number(rows[i][col]) || 0) * wanted / ordinary;
                    var base = Math.floor(exact);
                    rows[i][col] = base; used += base;
                    parts.push({ index: i, frac: exact - base });
                }
                parts.sort(function (a, b) { return b.frac - a.frac || a.index - b.index; });
                for (i = 0; i < wanted - used; i++) rows[parts[i % parts.length].index][col]++;
            }
        }
        return next;
    }

    // 0% 使用可直接证明无奖的牌轴：第一轴二条、第二轴二筒，无百搭/至尊。
    // 不会从第一轴连续命中三轴，因此也不产生连消和免费局。
    function zeroReturnProfile(profile) {
        var p = copy(profile), modes = ['n', 'f'];
        p.enabled[0] = true; p.enabled[1] = true; p.targetRtp = 0;
        for (var m = 0; m < 2; m++) {
            for (var s = 0; s < SYM_IDX; s++) p.weights[modes[m]][s] = [0, 0, 0, 0, 0];
            for (var c = 0; c < COLS; c++) p.weights[modes[m]][c % 2][c] = Number(p.weightTotal);
        }
        return p;
    }

    // 从0%固定牌轴重新调回正常难度时，单纯放大原比例永远不可能连线。
    // 这种结构改用默认普通牌配比；百搭/至尊、金牌概率和关闭模式保留空间不变。
    function hasOrdinaryPayPath(p) {
        for (var s=0;s<9;s++) if (p.enabled[s] && p.weights.n[s][0]>0) {
            var ok=true;
            for (var c=1;c<3;c++) if (!(p.weights.n[s][c]>0 || (p.enabled[IDX_WILD] && p.weights.n[IDX_WILD][c]>0))) ok=false;
            if (ok) return true;
        }
        return false;
    }
    function resetOrdinaryDistribution(profile, reservedScatter) {
        var p=copy(profile), standard=defaults(), modes=['n','f'];
        for (var m=0;m<2;m++) for (var c=0;c<COLS;c++) {
            var mode=modes[m], fixed=0, ids=[], shares=[], amount=0;
            for(var s=9;s<SYM_IDX;s++) if(p.enabled[s]) fixed+=p.weights[mode][s][c];
            var reserved=reservedScatter && reservedScatter[mode] ? Number(reservedScatter[mode][c]) : 0;
            fixed+=Math.max(0,reserved-(p.enabled[IDX_SCATTER]?p.weights[mode][IDX_SCATTER][c]:0));
            for(s=0;s<9;s++) if(p.enabled[s]) {ids.push(s);shares.push(standard.weights[mode][s][c]);amount+=standard.weights[mode][s][c];}
            var units=allocateUnits(ids,shares,Math.min(Math.max(0,p.weightTotal-fixed),amount));
            for(s=0;s<9;s++) p.weights[mode][s][c]=units[s];
        }
        return p;
    }

    // 只供一键校准选候选：低赔付普通牌占比更高，免费普通牌先减半；
    // 真实RTP仍须完整回合搜索并独立复核，不改变出牌算法、赔率或用户金牌/至尊开关。
    function smallWinProfile(profile, reservedScatter) {
        var p = copy(profile), modes = ['n','f'];
        for (var m = 0; m < 2; m++) for (var c = 0; c < COLS; c++) {
            var mode = modes[m], fixed = 0, ordinary = 0, ids = [], shares = [];
            for (var s = 9; s < SYM_IDX; s++) if (p.enabled[s]) fixed += p.weights[mode][s][c];
            var reserved = reservedScatter && reservedScatter[mode] ? Number(reservedScatter[mode][c]) : 0;
            if (!isFinite(reserved) || reserved < 0 || reserved > Number(p.weightTotal)) throw new Error('至尊保留权重无效。');
            fixed += Math.max(0, reserved - (p.enabled[IDX_SCATTER] ? p.weights[mode][IDX_SCATTER][c] : 0));
            for (s = 0; s < 9; s++) if (p.enabled[s]) { ids.push(s); shares.push(1 / Math.pow(PAY[s+1][2],1.5)); ordinary += p.weights[mode][s][c]; }
            var room = Number(p.weightTotal) - fixed;
            if (room < ids.length) throw new Error('当前百搭和至尊占满该轴，无法保留普通赔付牌，请先调整权重。');
            var amount = Math.max(ids.length, Math.min(room, Math.floor(ordinary * (mode === 'f' ? 0.5 : 1))));
            var units = allocateUnits(ids, shares, amount - ids.length);
            for (s = 0; s < 9; s++) p.weights[mode][s][c] = p.enabled[s] ? units[s] + 1 : 0;
        }
        return p;
    }

    // 失败复核只能成为下一候选的训练信息，不能反复抽同一矩阵碰运气。
    // 仅在精度已足够、候选两侧有显著斜率时小步纠偏；窄而不可信的噪声括点不用。
    function correctionFactor(chosenFactor, stats, trainingRecords, target, tolerance, minimumCount) {
        if (!stats || !stats.intervalReliable || !(stats.count > 1) || !isFinite(stats.total) || !isFinite(stats.half95) || stats.half95 < 0 || stats.half95 > tolerance)
            return { reason:'anchor_precision' };
        if (!isFinite(chosenFactor) || !isFinite(target) || !(tolerance > 0)) return { reason:'invalid_anchor' };
        var pair = null;
        for (var a = 0; a < trainingRecords.length; a++) for (var b = 0; b < trainingRecords.length; b++) {
            var lo = trainingRecords[a], hi = trainingRecords[b];
            if (!lo || !hi || lo.invalid || hi.invalid || !(lo.factor < chosenFactor && hi.factor > chosenFactor)) continue;
            var ls = lo.stats, hs = hi.stats;
            if (!ls || !hs || !ls.intervalReliable || !hs.intervalReliable || ls.count < minimumCount || hs.count < minimumCount) continue;
            if (!isFinite(ls.total) || !isFinite(hs.total) || !isFinite(ls.half95) || !isFinite(hs.half95) || ls.half95 < 0 || hs.half95 < 0) continue;
            if (!(ls.total < target && hs.total > target && hs.total-ls.total > 3*(ls.half95+hs.half95))) continue;
            var span = hi.factor-lo.factor;
            if (!isFinite(span) || !(span > 0)) continue;
            if (!pair || span < pair.span) pair = {lo:lo,hi:hi,span:span};
        }
        if (!pair) return { reason:'no_reliable_slope' };
        var slope = (pair.hi.stats.total-pair.lo.stats.total)/pair.span;
        var step = (target-stats.total)/slope, factor = chosenFactor+step;
        if (!isFinite(step) || !isFinite(factor) || !(factor > pair.lo.factor && factor < pair.hi.factor) || Math.abs(step) > pair.span/2)
            return { reason:'outside_bracket' };
        if (Math.abs(step) < 1e-12) return { reason:'unchanged_factor' };
        return { factor:factor, fromFactor:chosenFactor, slope:slope, step:step,
            low:{factor:pair.lo.factor,stats:copy(pair.lo.stats)}, high:{factor:pair.hi.factor,stats:copy(pair.hi.stats)},
            anchorStats:copy(stats) };
    }

    // 搜索共用随机种子减少比较噪声；候选选定后才用另一个种子独立验证。
    // 有限样本只给估计区间，未达精度时不返回可套用的权重。
    function calibrateRtp(profile, targetPercent, opts, onDone) {
        opts = opts || {};
        var percent = Number(targetPercent), target = percent / 100, finished = false;
        var searchCount = Math.max(20000, Math.min(1000000, Math.floor(Number(opts.searchCount || opts.count) || 50000)));
        var refineCount = Math.max(searchCount, Math.min(5000000, Math.floor(Number(opts.refineCount) || 1000000)));
        var validationCount = Math.max(100, Math.min(50000000, Math.floor(Number(opts.validationCount) || 50000000)));
        var iterations = Math.max(4, Math.min(16, Math.floor(Number(opts.iterations) || 10)));
        var maxFactor = Math.max(1, Math.min(64, Number(opts.maxFactor) || 8));
        var seed = opts.seed === undefined ? freshSeed() : (Number(opts.seed) >>> 0);
        var validationSeed = (seed ^ 0x9E3779B9) >>> 0;
        var validationSeed128=opts.validationSeed128 || [(seed^0x243f6a88)>>>0,(seed^0x85a308d3)>>>0,(seed^0x13198a2e)>>>0,(seed^0x03707344)>>>0];
        var tolerancePercent = Math.max(0.01, Number(opts.tolerancePercent) || 0.5);
        var tolerance = tolerancePercent / 100, best = null, records = [], trainingRecords = [], refineSteps = 0;
        var maxCorrections = opts.validationOnly ? 0 : Math.max(0,Math.min(1,Math.floor(Number(opts.maxCorrections)||0)));
        var confidenceCheckCount = maxCorrections ? 10 : opts.confidenceCheckCount;
        var sampleBudget = opts._sampleBudgetState || { used:0, limit:Math.max(100,Math.min(151000000,Math.floor(Number(opts.maxTotalSamples)||151000000))) };
        var validationAttempts = [], correction = null, correctionSkippedReason = '';
        var resetOrdinary=!!opts.resetOrdinary;
        function done(err, result) { if (!finished) { finished = true; onDone(err, result); } }
        function cancelled() { return !!(opts.cancelled && opts.cancelled()); }
        function cancel() { var e = new Error('已取消计算，参数未修改。'); e.code = 'MJHL_RTP_CANCELLED'; done(e); }
        function budgetExceeded() { var e = new Error('已达到本次计算上限，目标尚未通过，参数未修改。'); e.code='MJHL_RTP_BUDGET'; done(e); }
        if (!isFinite(percent) || percent < 0 || percent > 1000) { done(new Error('目标 RTP 必须在 0～1000%。')); return; }
        var errors = validate(profile);
        if (errors.length) { done(new Error(errors.join('\n'))); return; }
        if (cancelled()) { cancel(); return; }
        if (percent === 0 && !opts.validationOnly) {
            done(null, { success:true, exact:true, profile:zeroReturnProfile(profile), actual:0, error:0, samples:0,
                stats:{ total:0, half95:0, count:0 }, tolerancePercent:0, reason:'前两轴固定不同牌，无百搭或至尊，理论 RTP 为 0%。' });
            return;
        }
        try { validationSeed128=validationSeed128.slice(0);xoshiro128ss(validationSeed128); }
        catch(seedError) { done(seedError);return; }
        if (!opts.validationOnly && !hasOrdinaryPayPath(profile)) { profile=resetOrdinaryDistribution(profile,opts.reservedScatter); resetOrdinary=true; }
        if (opts.preferSmallWins && !opts.validationOnly) {
            try { profile = smallWinProfile(profile, opts.reservedScatter); }
            catch (shapeError) { done(shapeError); return; }
        }
        function build(factor) {
            var p = scaleOrdinary(profile, factor, opts.reservedScatter, !!opts.preferSmallWins);
            p.targetRtp = percent; p.spinCount = searchCount; p.calibrationSamples = Math.min(20000, searchCount);
            return p;
        }
        function notify(phase, record) {
            if (opts.onProgress) opts.onProgress(best, record ? record.factor : null, record ? record.stats : null, phase, record ? record.profile : null);
        }
        function measure(factor, count, next) {
            if (cancelled()) { cancel(); return; }
            var p;
            try { p = build(factor); } catch (e) { done(e); return; }
            if (sampleBudget.used+count > sampleBudget.limit) { budgetExceeded(); return; }
            sampleBudget.used += count;
            (opts.sampleRunner || sample)(p, count, seed, { cancelled:cancelled, batchSize:10000, onProgress:function (n,total) {
                if (opts.onMeasureProgress) opts.onMeasureProgress(count === searchCount ? 'search' : 'refine',n,total);
            } }, function (err, stats) {
                if (cancelled()) { cancel(); return; }
                if (err) {
                    if (err.code === 'MJHL_GENERATION_LIMIT') { next({ factor:factor, invalid:true, actual:Infinity }); return; }
                    done(err); return;
                }
                var record = { factor:factor, profile:p, actual:stats.total, stats:stats, distance:Math.abs(stats.total-target), invalid:false };
                trainingRecords.push(record);
                // 不用粗样本偶然接近目标的结果压过精样本。
                if (!best || stats.count > best.stats.count || (stats.count === best.stats.count && record.distance < best.distance)) best = record;
                notify(count === searchCount ? 'search' : 'refine', record); next(record);
            });
        }
        function verify(words) {
            if (cancelled()) { cancel(); return; }
            if (!best) { done(new Error('未找到可以完整结算的权重，参数未修改。')); return; }
            var chosen = best;
            notify('verify', chosen);
            var available = Math.min(validationCount,sampleBudget.limit-sampleBudget.used);
            if (available < 100) { budgetExceeded(); return; }
            var currentWords=words || validationSeed128, currentRound=validationAttempts.length+1;
            verifyRtp(chosen.profile, { validationCount:available, tolerancePercent:tolerancePercent, targetPercent:percent,
                validationSeed128:currentWords, seed:validationSeed, cancelled:cancelled, confidenceCheckCount:confidenceCheckCount,
                sampleRunner:opts.sampleRunner, quickCheckpoints:opts.quickCheckpoints,
                allowTargetCorrection:!!opts.quickCheckpoints && !!maxCorrections && validationAttempts.length === 0,
                onValidationProgress:function (n,total) { if (opts.onValidationProgress) opts.onValidationProgress(n,total,currentRound); },
                onCheckpoint:function (stats) { notify('verify', {factor:chosen.factor,stats:stats,profile:chosen.profile}); }
            }, function (error, verified) {
                if (error) { done(error); return; }
                var stats = verified.stats, actual = stats.total, success = !!verified.targetReached;
                var verifiedWords=(verified.validationSeed128 || []).slice(0), verifiedCheckpoints=(verified.plannedCheckpoints || []).slice(0);
                sampleBudget.used += stats.count;
                validationAttempts.push({factor:chosen.factor,profile:copy(chosen.profile),stats:copy(stats),success:success,
                    validationSeed128:verifiedWords,validationRng:verified.validationRng,validationDraws:verified.validationDraws,
                    validationBatches:copy(verified.validationBatches || []),
                    plannedCheckpoints:verifiedCheckpoints,confidenceCheckCount:verified.confidenceCheckCount || 0});
                if (!success && maxCorrections && validationAttempts.length === 1) {
                    if (cancelled()) { cancel(); return; }
                    var suggestion = correctionFactor(chosen.factor,stats,trainingRecords,target,tolerance,refineCount);
                    correctionSkippedReason = suggestion.reason || '';
                    if (!suggestion.reason) {
                        var corrected, newWords;
                        try { corrected=build(suggestion.factor); newWords=(opts.correctionSeed128 || freshSeed128()).slice(0); xoshiro128ss(newWords); }
                        catch (correctionError) { done(correctionError); return; }
                        if (JSON.stringify(corrected.weights) === JSON.stringify(chosen.profile.weights)) correctionSkippedReason='unchanged_weights';
                        else if (JSON.stringify(newWords) === JSON.stringify(verifiedWords)) correctionSkippedReason='reused_validation_seed';
                        else if (sampleBudget.limit-sampleBudget.used < 100) correctionSkippedReason='sample_budget';
                        else {
                            correction=suggestion; correction.validationSeed128=newWords.slice(0);
                            best={factor:suggestion.factor,profile:corrected,actual:null,stats:null,distance:Infinity};
                            notify('correction',best);
                            if (cancelled()) { cancel(); return; }
                            verify(newWords); return;
                        }
                    }
                }
                var result = { success:success, exact:verified.exact, profile:success ? chosen.profile : null,
                    factor:chosen.factor, actual:actual, error:actual-target, samples:stats.count, stats:stats,
                    precisionReached:verified.precisionReached, tolerancePercent:tolerancePercent,
                    targetMiss:!!verified.targetMiss, stoppedEarly:!!verified.stoppedEarly,
                    validationSeed:validationSeed, validationSeed128:verifiedWords, validationRng:verified.validationRng,
                    validationDraws:verified.validationDraws, validationBatches:verified.validationBatches, plannedCheckpoints:verifiedCheckpoints,
                    searchSeed:seed, resetOrdinary:resetOrdinary, smallWinBias:!!opts.preferSmallWins && !opts.validationOnly,
                    confidenceCheckCount:verified.confidenceCheckCount || 0,validationAttempts:validationAttempts,correction:correction,
                    correctionSkippedReason:correctionSkippedReason,sampleBudget:{used:sampleBudget.used,limit:sampleBudget.limit} };
                if (!success) {
                    var e = new Error('本次试算未达到目标精度，参数未修改。目标 ' + percent.toFixed(2) + '%，独立验证 ' + (actual*100).toFixed(2) + '% ± ' + (stats.half95*100).toFixed(2) + ' 个百分点（约 95% 区间）。');
                    e.code = 'MJHL_RTP_NOT_REACHED'; done(e, result); return;
                }
                done(null, result);
            });
        }
        function refine(low, high) {
            measure(low.factor, refineCount, function (lo) {
                measure(high.factor, refineCount, function (hi) {
                    function step() {
                        if (cancelled()) { cancel(); return; }
                        if (++refineSteps > iterations || hi.factor-lo.factor < 0.00001) { verify(); return; }
                        if (!lo.invalid && !hi.invalid && lo.actual > hi.actual) { verify(); return; }
                        if (!lo.invalid && lo.actual > target) { verify(); return; }
                        if (!hi.invalid && hi.actual < target) { verify(); return; }
                        var share = hi.invalid ? 0.5 : (target-lo.actual)/(hi.actual-lo.actual);
                        share = Math.max(0.2, Math.min(0.8, share));
                        var factor = lo.factor + (hi.factor-lo.factor)*share;
                        measure(factor, refineCount, function (mid) {
                            if (!mid.invalid && mid.distance <= tolerance * (opts.quickCheckpoints ? 0.5 : 0.15)) { verify(); return; }
                            if (mid.invalid || mid.actual >= target) hi = mid; else lo = mid;
                            step();
                        });
                    }
                    step();
                });
            });
        }
        var factors = [0, 0.25, 0.5, 0.75, 1, 1.25, 1.5, 2, 3, 4, 6, 8, 12, 16, 32, 64], index = 0;
        function search() {
            if (cancelled()) { cancel(); return; }
            if (index >= factors.length || factors[index] > maxFactor) {
                if (!resetOrdinary && best && best.actual<target) {
                    var fallbackOpts={}; for(var key in opts) if(Object.prototype.hasOwnProperty.call(opts,key)) fallbackOpts[key]=opts[key];
                    fallbackOpts.resetOrdinary=true;
                    fallbackOpts._sampleBudgetState=sampleBudget;
                    calibrateRtp(resetOrdinaryDistribution(profile,opts.reservedScatter),percent,fallbackOpts,done);
                    return;
                }
                verify(); return;
            }
            measure(factors[index++], searchCount, function (record) {
                records.push(record);
                if (records.length > 1) {
                    var before = records[records.length-2];
                    if (!before.invalid && before.actual <= target && (record.invalid || record.actual >= target)) { refine(before, record); return; }
                }
                if (record.invalid) { verify(); return; }
                search();
            });
        }
        // 验收工具可复用已落盘的完整搜索候选，只重新进行独立验证；
        // 不复用上次的验证统计，也不把输入目标当作试算值。
        if (opts.validationOnly) {
            var candidate=copy(profile); candidate.targetRtp=percent;
            best={ factor:Number(opts.candidateFactor)||1, profile:candidate,
                actual:opts.trainingStats ? opts.trainingStats.total : null,
                stats:opts.trainingStats || {total:null,count:0} };
            verify(); return;
        }
        search();
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
        mulberry32: mulberry32, xoshiro128ss:xoshiro128ss, freshSeed: freshSeed, freshSeed128:freshSeed128, defaults: defaults, validate: validate, compile: compile, normalize: normalize,
        blankWeights: blankWeights, generateGrid: generateGrid, evaluate: evaluate, spin: spin, spinGrid: spinGrid, eliminateAndDrop: eliminateAndDrop, initialFree: initialFree, generateRound: generateRound,
        sample: sample, verifyRtp:verifyRtp, proveZeroReturn:proveZeroReturn, mergeSampleStats:mergeSampleStats, payoutBand:payoutBand, verificationZ:verificationZ,
        scaleOrdinary: scaleOrdinary, smallWinProfile:smallWinProfile, correctionFactor:correctionFactor, calibrateRtp: calibrateRtp, scatterProbability: scatterProbability, binomialTail: binomialTail, syncScatter: syncScatter,
        candidate: candidate, copy: copy, GenerationLimitError: GenerationLimitError
    };
});
