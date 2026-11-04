(function (root) {
    'use strict';
    function weighted(values, weights) {
        if (!values || !weights || !values.length || values.length > 14 || values.length !== weights.length) throw new Error('请至少保留一个有效倍数档。');
        var sum = 0, total = 0, seen = {};
        values.forEach(function (v, i) {
            var w = weights[i];
            if (!Number.isInteger(v) || v < 1 || v > 14 || seen[v]) throw new Error('翻倍档位须为 1～14 的整数，且不能重复。');
            if (!Number.isInteger(w) || w < 0 || w > 2147483647) throw new Error('相对权重须为非负整数。');
            seen[v] = true; sum += w; total += v * w;
        });
        if (sum < 1 || sum > 2147483647) throw new Error('权重合计须在 1～2147483647 之间。');
        return { sum:sum, average:total / sum, probabilities:weights.map(function (w) { return w / sum; }) };
    }
    root.PhenixRtp = { weighted:weighted };
    if (typeof module === 'object' && module.exports) module.exports = root.PhenixRtp;
    if (!root.jQuery) return;
    var $ = root.jQuery, cfg = null, seq = 0, ready = false, saving = false, loadError = '', rtpState = null;
    function copy(v) { return JSON.parse(JSON.stringify(v)); }
    function current() { return $('#gcGameId').val() === '5'; }
    function status(text, bad) { $('#phenixConfigStatus').text(text).css('color', bad ? '#c53f3f' : '#6f8195'); }
    function collect() {
        if (!ready || !cfg) throw new Error(loadError || '正宗大四梅规则尚未载入，请重新载入后保存。');
        var values = [], weights = [];
        $('#pxAuthTable tbody tr').each(function () {
            var v = $(this).find('.px-wv').val(), w = $(this).find('.px-ww').val();
            values.push(v === '' ? NaN : Number(v)); weights.push(w === '' ? NaN : Number(w));
        });
        var model = weighted(values, weights), result = copy(cfg), a = result.specialRules.authentic;
        result.schemaVersion = 1; a.enabled = $('#pxAuthOn').is(':checked'); a.multipliers = {values:values, weights:weights};
        return {config:result, model:model};
    }
    function row(value, weight) {
        var tr = $('<tr><td><input class="px-wv" type="number" min="1" max="14" step="1" aria-label="翻倍档位" /></td><td><input class="px-ww" type="number" min="0" max="2147483647" step="1" aria-label="相对权重" /></td><td class="px-prob">—</td><td class="px-payout">—</td><td class="px-rtp">—</td><td><button type="button" class="px-delete">移除</button></td></tr>');
        tr.find('.px-wv').val(value); tr.find('.px-ww').val(weight); $('#pxAuthTable tbody').append(tr);
    }
    function render() {
        var a = cfg.specialRules.authentic, m = a.multipliers;
        $('#pxAuthOn').prop('checked', a.enabled); $('#pxAuthTable tbody').empty();
        m.values.forEach(function (v, i) { row(v, m.weights[i]); }); refresh();
    }
    function percent(v) { return (v * 100).toFixed(2) + '%'; }
    function refresh() { if (current() && typeof root.gcUpdatePayoutSum === 'function') root.gcUpdatePayoutSum(); }
    root.phenixConfigRtp = function () {
        if (!current()) return null;
        try {
            var c = collect();
            rtpState = { valid:true, enabled:c.config.specialRules.authentic.enabled, average:c.model.average, model:c.model };
        } catch (e) { rtpState = {valid:false, error:e.message}; }
        return rtpState;
    };
    root.phenixConfigDisplayRtp = function (base, total, frequency) {
        var s = rtpState;
        if (!s || !s.valid) {
            $('#pxRtpTotal,#pxRtpBase,#pxRtpExtra,#pxAvgPayout,#pxAuthSum,#pxProbSum,#pxWeightedPayout,#pxAuthRtp,.px-prob,.px-payout,.px-rtp').text('—');
            $('#pxAvgMultiple').text(s ? s.error : '等待载入规则'); return;
        }
        var enabled = s.enabled, avg = enabled ? s.average : 1;
        $('#pxRtpTotal').text(percent(total)); $('#pxRtpBase').text(percent(base));
        $('#pxRtpExtra').text('+' + ((total - base) * 100).toFixed(2) + ' 个百分点');
        $('#pxAvgPayout,#pxWeightedPayout').text((80 * avg).toFixed(2) + ' 倍');
        $('#pxAvgMultiple').text(enabled ? '加权平均翻倍 ×' + avg.toFixed(3) : '已关闭 · 普通大四梅');
        $('#pxAuthSum').text(s.model.sum); $('#pxProbSum').text(enabled ? '100.00%' : '已关闭');
        $('#pxAuthRtp').text(percent(frequency * 80 * avg));
        $('#pxAuthTable tbody tr').each(function (i) {
            var tr = $(this), v = Number(tr.find('.px-wv').val()), p = s.model.probabilities[i];
            tr.find('.px-prob').text(percent(p)); tr.find('.px-payout').text((80 * v) + ' 倍');
            tr.find('.px-rtp').text(enabled ? percent(frequency * p * 80 * v) : '—');
        });
        $('#pxAuthTable').css('opacity', enabled ? 1 : 0.55);
    };
    root.phenixConfigClear = function () {
        ++seq; cfg = null; ready = false; loadError = ''; rtpState = null;
        $('#phenixConfig,#pxRtpSummary').hide(); $('#gcForm').removeClass('gc-phenix-mode');
        $('#gcHp0').prop('readonly', false).removeAttr('title');
        var header = $('#gcPayoutTable th').eq(2);
        if (header.data('px-original')) header.text(header.data('px-original'));
    };
    root.phenixConfigLoad = function () {
        root.phenixConfigClear(); if (!current()) return;
        var version = seq, id = $('#gcId').val();
        $('#gcForm').addClass('gc-phenix-mode'); $('#phenixConfig').show();
        var header = $('#gcPayoutTable th').eq(2);
        if (!header.data('px-original')) header.data('px-original', header.text());
        header.text('奖励倍数（只读）');
        $('#pxRtpSummary').insertBefore($('#gcPayoutTable').prevAll('.gc-section-title').first()).show();
        status('载入正宗大四梅规则…'); refresh();
        function accept(data) {
            if (version !== seq || !current() || id !== $('#gcId').val()) return;
            if (!data || data.code !== 1) { loadError = (data && data.content) || '规则载入失败，请重新载入。'; status(loadError, true); refresh(); return; }
            cfg = data.config; ready = true;
            try { render(); status('当前表单实时试算 · 保存后生效'); } catch (e) { ready = false; loadError = '已存规则无法读取，请检查配置。'; status(loadError, true); refresh(); }
        }
        if (Number(id) < 0) { accept({code:1,config:copy(root.PHENIX_CONFIG_DEFAULTS)}); return; }
        $.post(root.PHENIX_CONFIG_URLS.get, {tableIndex:Number(id) % 1000}, accept, 'json').fail(function () {
            if (version !== seq || !current() || id !== $('#gcId').val()) return;
            loadError = '后台连接失败，请重新载入规则。'; status(loadError, true); refresh();
        });
    };
    root.phenixConfigCollect = function () {
        if (saving) throw new Error('正在保存，请稍候。');
        return { PhenixConfigJson:JSON.stringify(collect().config) };
    };
    root.phenixConfigSetSaving = function (value) { saving = value; $('#phenixConfig input,#phenixConfig button').prop('disabled', value); };
    $(function () {
        $('#phenixConfigLoad').on('click', root.phenixConfigLoad);
        $('#phenixConfig').on('input change', 'input', function () { refresh(); status(rtpState && !rtpState.valid ? rtpState.error : '已修改 · 尚未保存', rtpState && !rtpState.valid); });
        $('#pxAuthAdd').on('click', function () {
            var used = {}; $('#pxAuthTable .px-wv').each(function () { used[Number(this.value)] = true; });
            for (var v = 1; v <= 14; v++) if (!used[v]) { row(v, 0); refresh(); status('已修改 · 尚未保存'); return; }
            status('最多支持 14 个不同的翻倍档位。', true);
        });
        $('#pxAuthTable').on('click', '.px-delete', function () {
            if ($('#pxAuthTable tbody tr').length <= 1) { status('至少保留一个倍数档。', true); return; }
            $(this).closest('tr').remove(); refresh(); status('已修改 · 尚未保存');
        });
    });
})(typeof window === 'object' ? window : globalThis);
