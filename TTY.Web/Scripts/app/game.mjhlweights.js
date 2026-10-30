/* 麻将胡了出货率（权重）面板：依赖 mjhl.engine.js（与游戏服同算法）。
 * 由 ConfigEditor 的 gcApplyType/gcFill 调用 window.mjhlWeightsClear / window.mjhlWeightsLoad。 */
(function ($) {
    'use strict';
    var E = window.MjhlEngine, MODES = ['n', 'f'], ROWS = E.DISPLAY_ORDER.concat([11]);
    var FIELDS = {
        mwTargetRtp: 'targetRtp', mwTargetScatter: 'targetScatter', mwGoldChance: 'goldChance', mwSpinCount: 'spinCount',
        mwCalibration: 'calibrationSamples', mwWeightTotal: 'weightTotal'
    };
    var RESULTS = ['mwNormal', 'mwFree', 'mwTotal', 'mwHit', 'mwMiss', 'mwScatter', 'mwCap'];
    var state = null, scope = null, generation = 0, busy = false, cancelled = false, lastSim = '';

    function pct(n) { return (n * 100).toFixed(2) + '%'; }
    function pp(n) { return (n * 100).toFixed(2) + '个百分点'; }
    function token() { return $('#gcForm [name="__RequestVerificationToken"]').val(); }
    function send(url, data, done) {
        $.ajax({ url: url, type: 'POST', data: data, dataType: 'json', timeout: 15000 })
            .done(done).fail(function () { done({ code: 0, content: '请求未完成，请检查连接后重试；保存超时时请点“载入已保存权重”确认是否已落库。' }); });
    }
    function report(errors) { $('#mwError').text(errors.join('\n')).toggle(errors.length > 0); }
    function status(text) { $('#mwStatus').text(text); }
    function badge(configured) {
        $('#mwBadge').text(configured ? '本桌已启用出货率' : '本桌未配置（原分档算法）').toggleClass('mw-on', !!configured).toggleClass('mw-off', !configured);
    }
    function stale() { RESULTS.forEach(function (id) { $('#' + id).text('待重算'); }); lastSim = ''; status('参数已修改，请重新模拟；之前的统计不再对应当前权重。修改尚未保存。'); }
    function isLocked(idx, col) { return idx === E.IDX_WILD && (col === 0 || col === 4); }
    function name(idx) { return idx === 11 ? '杂牌（降低连线）' : E.NAMES[idx]; }

    function paintTable() {
        var html = ROWS.map(function (idx) {
            var pay = idx < 9 ? E.PAY[idx + 1].join(' / ') : '—';
            var cells = [0, 1, 2, 3, 4].map(function (c) {
                return '<td>' + MODES.map(function (m) {
                    var id = 'mw-w-' + idx + '-' + m + '-' + c, ro = idx === 11 || isLocked(idx, c);
                    return '<div class="mw-pair"><label for="' + id + '">' + (m === 'n' ? '普通' : '免费') + '</label>' +
                        '<input id="' + id + '" class="mw-weight" data-i="' + idx + '" data-m="' + m + '" data-c="' + c + '" type="number" min="0" max="1000000" step="1"' +
                        ' aria-label="' + name(idx) + (m === 'n' ? '普通' : '免费') + '轴' + (c + 1) + '权重"' + (ro ? ' readonly' : '') + ' />' +
                        '<span id="mw-p-' + idx + '-' + m + '-' + c + '" class="mw-prob">—</span></div>';
                }).join('') + '</td>';
            }).join('');
            var en = idx === 11 ? '自动' : '<input type="checkbox" class="mw-enabled" data-i="' + idx + '" aria-label="启用' + name(idx) + '" />';
            return '<tr><td class="mw-symbol">' + name(idx) + (idx === 11 ? '<span class="mw-subpay">自动补足</span>' : '') + '</td><td>' + pay + '</td>' + cells + '<td>' + en + '</td></tr>';
        }).join('');
        $('#mwTable').html(html);
    }
    function paintValues() {
        var blank = { n: E.blankWeights(state, 'n'), f: E.blankWeights(state, 'f') };
        ROWS.forEach(function (idx) {
            MODES.forEach(function (m) {
                for (var c = 0; c < 5; c++)
                    $('#mw-w-' + idx + '-' + m + '-' + c).val(idx === 11 ? blank[m][c] : state.weights[m][idx][c]);
            });
            if (idx < 11) $('.mw-enabled[data-i="' + idx + '"]').prop('checked', !!state.enabled[idx]);
        });
        Object.keys(FIELDS).forEach(function (id) {
            var v = state[FIELDS[id]];
            $('#' + id).val(v);
        });
        syncDisplay();
    }
    function syncDisplay() {
        var total = Number(state.weightTotal);
        MODES.forEach(function (m) {
            var blank = E.blankWeights(state, m);
            for (var c = 0; c < 5; c++) {
                $('#mw-w-11-' + m + '-' + c).val(blank[c]);
                var others = 0;
                for (var s = 0; s < 11; s++) {
                    var w = state.weights[m][s][c], v = state.enabled[s] ? w : 0;
                    if (state.enabled[s]) others += w;
                    $('#mw-p-' + s + '-' + m + '-' + c).text(total > 0 && isFinite(v) ? pct(v / total) : '—');
                }
                $('#mw-p-11-' + m + '-' + c).text(total > 0 ? pct(blank[c] / total) : '—');
                var sum = others + blank[c], valid = isFinite(sum) && sum === total && others <= total;
                $('#mwSum-' + m + '-' + c).html('<strong>' + (isFinite(sum) ? sum.toLocaleString() : '数值无效') + ' / ' + (isFinite(total) ? total.toLocaleString() : '—') + '</strong>' +
                    '<span class="mw-subpay">其它牌 ' + (isFinite(others) ? others.toLocaleString() : '—') + ' ＋ 杂牌 ' + blank[c].toLocaleString() + '</span>' +
                    '<span style="color:' + (valid ? '#168052' : '#a33d3d') + '">' + (valid ? '合计100%' : (isFinite(others) && others > total ? '超出 ' + (others - total).toLocaleString() + '，请降低其它权重' : '请检查输入')) + '</span>');
            }
        });
    }
    function check() { var errors = state ? E.validate(state) : ['尚未载入配置。']; report(errors); return !errors.length; }
    function setBusy(on) {
        busy = on; cancelled = false;
        $('#mjhlWeights').find('input,select,button').each(function () {
            if (this.id === 'mwCancel') return;
            var locked = $(this).is('[readonly]');
            if (!locked) $(this).prop('disabled', on);
        });
        $('#mwCancel').prop('disabled', !on);
    }
    function display(s, label) {
        var map = { mwNormal: s.normal, mwFree: s.free, mwTotal: s.total, mwHit: s.hit, mwMiss: s.miss, mwScatter: s.scatter, mwCap: s.cap };
        Object.keys(map).forEach(function (id) { $('#' + id).text(pct(map[id])); });
        lastSim = 'RTP ' + pct(s.total) + ' / ' + s.count + '局 / 至尊 ' + pct(s.scatter);
        status(label + '\n完成' + s.count.toLocaleString() + '个完整付费回合；普通贡献' + pct(s.normal) + '＋免费贡献' + pct(s.free) + '＝总RTP ' + pct(s.total) + '。' +
            '\nRTP粗略95%正态近似范围 ' + pct(Math.max(0, s.total - s.half95)) + '～' + pct(s.total + s.half95) + '；稀有大奖可能使区间不可靠。' +
            '\n每次旋转独立按5000倍封顶，已获得的免费次数照常完成。' +
            '\n此为局内完整回合RTP，包含小数分奖金；不包含玩家离开游戏时不足1分余额的舍弃。' +
            '\n修改尚未保存时，游戏里仍是已保存的配置。');
    }
    function sampleP(profile, count, seed, prefix) {
        var g = generation;   // 切桌/重新载入后旧计算立即停止
        return new Promise(function (resolve, reject) {
            E.sample(profile, count, seed, {
                cancelled: function () { return cancelled || g !== generation; },
                onProgress: function (i, n) { if (prefix) status(prefix + '（' + i.toLocaleString() + '/' + n.toLocaleString() + '）'); }
            }, function (err, res) { if (err) reject(err); else resolve(res); });
        });
    }

    function run() {
        if (busy || !check()) return;
        var snapshot;
        try { snapshot = E.syncScatter(state); } catch (e) { report([e.message]); return; }
        state = snapshot; paintValues(); stale(); setBusy(true); report([]);
        var gen = generation, precision = Number(snapshot.calibrationSamples), trial;
        sampleP(E.copy(snapshot), precision, E.freshSeed(), '已同步至尊权重和杂牌余额，正在按手动权重试算')
            .then(function (t) { trial = t; return sampleP(E.copy(snapshot), Number(snapshot.spinCount), E.freshSeed(), '试算完成，正在独立模拟完整付费回合'); })
            .then(function (m) {
                if (gen !== generation) return;
                display(m, '当前模拟完成：其它牌型手动权重和开关未改动；至尊已按目标同步，杂牌自动补余量。' +
                    '\n目标至尊率' + Number(snapshot.targetScatter).toFixed(2) + '%，初盘解析触发概率' + pct(E.binomialTail(snapshot)) + '；普通金色概率' + Number(snapshot.goldChance).toFixed(2) + '%。' +
                    '\n试算' + precision.toLocaleString() + '局：RTP ' + pct(trial.total) + '，至尊触发率' + pct(trial.scatter) + '。' +
                    '\n以下统计来自另一次完整回合模拟，RTP不是目标值强制套入。');
            })
            .catch(function (e) { if (gen === generation) report([e.message]); })
            .then(function () { if (gen === generation) setBusy(false); });
    }

    function auto() {
        if (busy || !check()) return;
        var base = E.copy(state), target = Number(base.targetRtp) / 100, trialCount = Number(base.calibrationSamples);
        var gen = generation, seed = 0x3891b24d, best = null, maxMeasured = 0, attempts = 0, rejected = 0, seen = {};
        setBusy(true); report([]);
        function evaluate(occupancy, power, freeFactor) {
            var k = [occupancy.toFixed(6), power, freeFactor].join('/');
            if (seen[k]) return Promise.resolve(seen[k]);
            var proposed = E.candidate(base, occupancy, power, freeFactor);
            return sampleP(proposed, trialCount, seed, null).then(function (result) {
                attempts++; maxMeasured = Math.max(maxMeasured, result.total);
                var x = { proposed: proposed, result: result, error: Math.abs(result.total - target), occupancy: occupancy };
                seen[k] = x;
                if (!best || x.error < best.error) best = x;
                status('正在分配：已试算' + attempts + '组合法权重；本组RTP ' + pct(result.total) + '；最佳目标差' + pp(best.error) + '。');
                return x;
            }, function (err) {
                if (!err || err.code !== 'MJHL_GENERATION_LIMIT') throw err;
                rejected++;
                var invalid = { proposed: proposed, result: null, occupancy: occupancy };
                seen[k] = invalid;
                status('已跳过' + rejected + '组无法完整结束的权重；继续搜索可完成的配置。');
                return invalid;
            });
        }
        function bisect(a, b, power, freeFactor) {
            if (!a.result || !b.result) return Promise.resolve();
            if ((a.result.total - target) * (b.result.total - target) > 0) return Promise.resolve();
            var lo = a.occupancy, hi = b.occupancy, j = 0;
            function step() {
                if (j++ >= 6) return Promise.resolve();
                var mid = (lo + hi) / 2;
                return evaluate(mid, power, freeFactor).then(function (x) { if (!x.result) return; if (x.result.total > target) hi = mid; else lo = mid; return step(); });
            }
            return step();
        }
        var chain = Promise.resolve();
        [0.5, 1.25, 2.5, 4, 6, 9].forEach(function (power) {
            chain = chain.then(function () {
                var coarse = [], p = Promise.resolve();
                [0, 0.2, 0.4, 0.6, 0.8, 1].forEach(function (o) { p = p.then(function () { return evaluate(o, power, 0.35).then(function (x) { coarse.push(x); }); }); });
                return p.then(function () {
                    var q = Promise.resolve();
                    for (var i = 0; i < coarse.length - 1; i++) (function (a, b) { q = q.then(function () { return bisect(a, b, power, 0.35); }); })(coarse[i], coarse[i + 1]);
                    return q;
                });
            });
        });
        chain.then(function () {
            if (!best) throw new Error('没有可完整结束的候选权重，请降低至尊触发率或调整权重后重试。');
            if (gen !== generation) return null;
            state = best.proposed; paintValues(); stale(); status('校准结束，使用独立随机序列复测…');
            return sampleP(E.copy(state), Number(state.spinCount), E.freshSeed(), '校准结束，使用独立随机序列复测');
        }).then(function (measured) {
            if (!measured || gen !== generation) return;
            var differs = Math.abs(measured.total - target);
            display(measured, '自动分配完成；固定赔率未变。' +
                '\n校准样本' + trialCount.toLocaleString() + '局，RTP ' + pct(best.result.total) + '；至尊目标' + Number(base.targetScatter).toFixed(2) + '%；初盘解析触发概率' + pct(E.binomialTail(state)) + '。' +
                '\n独立复测距目标' + pp(differs) + '。' + (differs > 0.03 ? '未达到目标容差，请查看样本波动或增加校准/复测局数。' : '本次复测接近目标，非每批局数保证。') +
                (maxMeasured < target ? '\n搜索范围内最高试算RTP低于目标，当前搜索未找到达标方案；这不证明所有可能权重都不可达。' : '') +
                (rejected ? '\n已跳过' + rejected + '组无法完整结束的候选，未把部分回合计入RTP。' : '') +
                (!state.enabled[E.IDX_SCATTER] ? '\n至尊已关闭，所填触发目标不生效。' : ''));
        }).catch(function (e) { if (gen === generation) report([e.message]); })
            .then(function () { if (gen === generation) setBusy(false); });
    }

    function load(showStatus) {
        if (!scope) return;
        var gen = ++generation, my = scope;
        cancelled = true; setBusy(false); report([]); badge(false); $('#mwBadge').text('读取中');
        send(MJHL_WEIGHTS_URLS.get, { gameId: my.gameId, tableIndex: my.tableIndex }, function (data) {
            if (gen !== generation || scope !== my) return;
            if (!data || data.code !== 1) { report([(data && data.content) || '读取失败。']); state = E.defaults(); paintValues(); badge(false); return; }
            state = E.normalize(data.configured ? data.config : E.defaults());
            state.version = 1;
            paintValues(); badge(data.configured);
            RESULTS.forEach(function (id) { $('#' + id).text('—'); });
            $('#mwStatusTop').text(data.configured ? '下方是本桌已保存的权重。规则修正后请重新模拟，旧RTP统计不再适用；修改后需保存才会生效。' : '本桌还没有出货率配置，下方是旧示例权重（未保存）；请先重新模拟或自动分配，再保存启用。');
            status(showStatus || '已载入。可直接点“当前模拟”查看这组权重的实际RTP。');
        });
    }
    function save() {
        if (busy || !scope || !check()) return;
        if (!window.confirm('保存后本桌下一局起按这组权重开奖' + (lastSim ? '（最近一次模拟：' + lastSim + '）' : '（尚未模拟这组权重）') + '，确定保存？')) return;
        var gen = generation, my = scope; setBusy(true);
        send(MJHL_WEIGHTS_URLS.save, { gameId: my.gameId, tableIndex: my.tableIndex, configJson: JSON.stringify(state), simulated: lastSim, __RequestVerificationToken: token() }, function (data) {
            if (gen !== generation) return;
            setBusy(false);
            if (data && data.code === 1) { badge(true); $('#mwStatusTop').text('下方是本桌已保存的配置。'); status(data.content); report(data.hotReload ? [] : [data.content]); }
            else report([(data && data.content) || '保存失败。']);
        });
    }
    function del() {
        if (busy || !scope) return;
        if (!window.confirm('删除后本桌恢复原分档算法（约96%），确定删除本桌出货率配置？')) return;
        var gen = generation, my = scope; setBusy(true);
        send(MJHL_WEIGHTS_URLS.del, { gameId: my.gameId, tableIndex: my.tableIndex, __RequestVerificationToken: token() }, function (data) {
            if (gen !== generation) return;
            setBusy(false);
            if (data && data.code === 1) load(data.content);
            else report([(data && data.content) || '删除失败。']);
        });
    }

    window.mjhlWeightsClear = function () {
        generation++; cancelled = true; busy = false; scope = null; state = null;
        $('#mjhlWeights').hide();
    };
    window.mjhlWeightsLoad = function () {
        window.mjhlWeightsClear();
        var game = parseInt($('#gcGameId').val(), 10), id = parseInt($('#gcId').val(), 10);
        if (game !== 54 || !(id >= 0)) return;
        scope = { gameId: game, tableIndex: id % 1000 };
        $('#mjhlWeights').show();
        load();
    };

    $(function () {
        paintTable();
        $('#mjhlWeights').on('input', '.mw-weight', function () {
            if (busy || !state || Number($(this).data('i')) > 10) return;
            var v = this.value === '' ? NaN : Number(this.value);
            state.weights[$(this).data('m')][Number($(this).data('i'))][Number($(this).data('c'))] = v;
            syncDisplay(); stale(); check();
        }).on('change', '.mw-enabled', function () {
            if (busy || !state) return;
            state.enabled[Number($(this).data('i'))] = this.checked;
            syncDisplay(); stale(); check();
        }).on('input change', '#mwTargetRtp,#mwTargetScatter,#mwGoldChance,#mwSpinCount,#mwCalibration,#mwWeightTotal', function () {
            if (busy || !state) return;
            var key = FIELDS[this.id];
            state[key] = this.value === '' ? NaN : Number(this.value);
            if (this.id === 'mwWeightTotal') syncDisplay();
            stale();
        });
        $('#mwSimulate').on('click', run);
        $('#mwAuto').on('click', auto);
        $('#mwSave').on('click', save);
        $('#mwLoad').on('click', function () { if (!busy) load('已重新载入本桌已保存的配置（未保存的修改已丢弃）。'); });
        $('#mwReset').on('click', function () { if (busy || !state) return; state = E.defaults(); paintValues(); report([]); stale(); status('已恢复旧示例权重（未保存）；规则修正后请重新模拟或自动分配，旧RTP统计不再适用。'); });
        $('#mwDelete').on('click', del);
        $('#mwCancel').on('click', function () { cancelled = true; status('正在停止计算…'); });
    });
})(jQuery);
