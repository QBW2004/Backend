(function ($) {
    'use strict';
    var state = null, generation = 0, previewNumber = 0, timer, saving = false;
    var fruitNames = ['BAR', '77', '星星', '铃铛', '西瓜', '芒果', '橘子', '苹果'];
    function status(message, error) { $('#lwStatus').text(message).css('color', error ? '#b42318' : '#48566d'); }
    function token() { return $('#gcForm [name="__RequestVerificationToken"]').val(); }
    function send(url, data, callback) {
        $.ajax({ url: url, type: 'POST', data: data, dataType: 'json', timeout: 12000 })
            .done(callback).fail(function () { callback({ code: 0, content: '请求未完成，请检查连接后重试；保存请求超时时请重新读取确认是否已落库。' }); });
    }
    function scope() { return parseInt($('#gcId').val(), 10); }
    window.labaWeightsClear = function () {
        generation++; previewNumber++; clearTimeout(timer); state = null;
        $('#labaWeights').hide(); $('#lwEditor').hide(); $('#lwSave').prop('disabled', true);
    };
    var SCALE = 10000; // 当前游戏的主权重口径：明星97/水果机 10000，水浒传 100000（由服务端 scale 下发）
    // 明星97/水浒传第 0 项是“未中奖”：只读，＝10000－中奖奖型合计；水果机没有未中奖项
    function noWinIndex(game, items) { return game !== 40 && items.length && items[0].code === 0 ? 0 : -1; }
    function input(label, index, value, kind, hint, readOnly) {
        var box = $('<label>').css({ display: 'flex', flexDirection: 'column', gap: '3px', padding: '6px' });
        $('<span>').text(label).appendTo(box);
        var max = kind === 'extra' ? (index === 64 ? 512 : 10000) : SCALE;
        var el = $('<input type="number" min="0" step="1">').attr('max', max).val(value).attr('data-' + kind, index).css('width', '130px').appendTo(box);
        if (readOnly) el.prop('readonly', true).attr('data-nowin', '1').css({ background: '#eef2f7', color: '#48566d' });
        if (hint) $('<small>').text(hint).css('color', '#637087').appendTo(box);
        return box;
    }
    // 倍数一律取整显示（按单线注=1 计）；水浒传全盘奖另标总押注倍数（单线注×9），明星97七三连按全盘3个七结算
    function meanHint(game, item) {
        if (item.code === 0) return '＝' + SCALE + ' － 中奖奖型合计（自动计算）';
        var text = Math.round(item.mean) + ' 倍单线注';
        if (game === 53 && item.code >= 440) text += '（＝总押注 ' + Math.round(item.mean / 9) + ' 倍）';
        return text;
    }
    // 中奖奖型合计与未中奖自动值；返回中奖合计（输入不合法时按 0 计，read() 会再报错）
    function syncNoWin() {
        if (!state || state.noWin < 0) return 0;
        var wins = 0;
        $('#lwMain input[data-main]').each(function () {
            if (Number($(this).attr('data-main')) === state.noWin) return;
            var v = $(this).val(); if (/^\d+$/.test(v)) wins += Number(v);
        });
        $('#lwMain input[data-nowin]').val(wins <= SCALE ? SCALE - wins : '');
        $('#lwWinSum').text('中奖奖型合计 ' + wins + ' / ' + SCALE + '，未中奖 ' + (wins <= SCALE ? SCALE - wins : '—'))
            .css('color', wins > SCALE ? '#b42318' : '#48566d');
        return wins;
    }
    function result(r) {
        $('#lwRtp').text('理论 RTP ' + r.totalRtp.toFixed(4) + '%');
        $('#lwParts').text('基础奖 ' + r.baseRtp.toFixed(4) + '% ＋ 额外玩法 ' + r.extraRtp.toFixed(4) + '%');
        $('#lwBasis').text(r.basis);
        $('#lwAreas').text(r.areaRtp ? r.areaRtp.map(function (p, i) { return fruitNames[i] + '：' + p.toFixed(3) + '%'; }).join('　') : '基础盘面中奖率 ' + r.hitRate.toFixed(4) + '%');
    }
    function read() {
        var c = JSON.parse(JSON.stringify(state.config));
        c.enabled = $('#lwEnabled').prop('checked'); c.extra[0] = $('#lwBonus').prop('checked') ? 1 : 0;
        if (state.noWin >= 0 && syncNoWin() > SCALE) throw new Error('中奖奖型权重合计不能超过' + SCALE + '。');
        $('#lwMain input,#lwExtra input').each(function () {
            var value = $(this).val(), main = $(this).attr('data-main'), extra = $(this).attr('data-extra');
            var max = extra === '64' ? 512 : (extra !== undefined ? 10000 : SCALE);
            if (!/^\d+$/.test(value) || Number(value) > max) throw new Error(extra === '64' ? '小玛丽最大回合范围为27至512。' : '权重必须为0至' + max + '的整数。');
            if (main !== undefined) c.main[Number(main)] = Number(value);
            if (extra !== undefined) c.extra[Number(extra)] = Number(value);
        });
        return c;
    }
    function payload(c) { return { gameId: state.gameId, tableIndex: state.tableIndex, weightsJson: JSON.stringify(c), bet: Number($('#lwBet').val()), __RequestVerificationToken: token() }; }
    function preview() {
        if (!state) return;
        var c, p, run = ++previewNumber, gen = generation;
        try { c = read(); p = payload(c); } catch (e) { status(e.message, true); $('#lwRtp').text('配置不合法'); return; }
        status('正在试算；修改尚未保存。', false);
        send(LABA_WEIGHTS_URLS.preview, p, function (data) {
            if (gen !== generation || run !== previewNumber) return;
            if (data && data.code === 1) { result(data.result); status(c.enabled ? '预览通过；修改尚未保存。' : '相对权重尚未启用；以下为试算值。', false); }
            else { status(data && data.content || '试算失败。', true); $('#lwRtp').text('无法计算 RTP'); }
        });
    }
    function extras(game, c) {
        var box = $('#lwExtra').empty(), defs = [];
        if (game === 40) {
            var names = ['小三元', '大三元', '大四喜', '小满贯', '大满贯', '纵横四海', '随机1至5灯', '开火车', '天女散花7灯', '天龙八部8灯', '九莲宝灯9灯'];
            names.forEach(function (name, i) { defs.push([i + 1, name + '权重']); });
            defs.push([12, '吃灯权重', '与11种特殊奖共同抽取；未开启额外玩法时幸运灯按“送1-5个灯或者吃灯”各半。']);
        } else if (game === 16) {
            defs = [];
        } else {
            var outer = ['退出', '鲁智深', '枪', '忠义堂', '斧', '刀', '退出', '宋江', '鲁智深', '枪', '斧', '替天行道', '退出', '林冲', '刀', '斧', '鲁智深', '忠义堂', '退出', '枪', '宋江', '斧', '刀', '替天行道'];
            outer.forEach(function (name, i) { defs.push([40 + i, '外圈' + (i + 1) + '·' + name + '权重']); });
            defs.push([64, '小玛丽最大回合', '27至512；接近上限时强制消耗退出次数。']);
        }
        defs.forEach(function (d) { box.append(input(d[1], d[0], c.extra[d[0]], 'extra', d[2])); });
    }
    window.labaWeightsLoad = function () {
        window.labaWeightsClear();
        var game = parseInt($('#gcGameId').val(), 10), id = scope();
        if ([16, 40, 53].indexOf(game) < 0 || id < 0) return;
        var gen = generation;
        $('#labaWeights').show(); status('加载当前机台权重…', false);
        send(LABA_WEIGHTS_URLS.get, { gameId: game, tableIndex: id % 1000 }, function (data) {
            if (gen !== generation || id !== scope()) return;
            if (!data || data.code !== 1) { status(data && data.content || '加载失败。', true); return; }
            SCALE = data.scale || (game === 53 ? 100000 : 10000);
            state = { config: data.config, gameId: game, tableIndex: id % 1000, noWin: noWinIndex(game, data.items) };
            $('#lwEnabled').prop('checked', data.config.enabled); $('#lwBonus').prop('checked', data.config.extra[0] === 1); $('#lwBet').val(1);
            var main = $('#lwMain').empty();
            if (state.noWin >= 0) main.append($('<div id="lwWinSum">').css({ gridColumn: '1 / -1', padding: '0 6px' }));
            data.items.forEach(function (item, i) { main.append(input(item.name, i, data.config.main[i], 'main', game === 40 ? '' : meanHint(game, item), i === state.noWin)); });
            syncNoWin();
            extras(game, data.config); result(data.result); $('#lwEditor').show(); $('#lwSave').prop('disabled', false);
            if (data.stale) status('开奖规则已更新，本机台原先保存的权重已失效（游戏服当前未使用）；下方为新规则默认值，请确认后勾选启用并保存。', true);
            else if (data.converted) status('原权重已按比例换算为每 ' + SCALE + ' 次（不足 1 次的奖型变为 0，请核对理论 RTP）；保存后才生效。', true);
            else status(data.config.enabled ? '已启用相对权重；下方为已保存配置。' : '当前使用旧配置；下方是新模式默认试算，勾选启用后保存。', false);
        });
    };
    $(function () {
        $('#labaWeights').on('input change', 'input', function () {
            syncNoWin();
            clearTimeout(timer); previewNumber++; $('#lwRtp').text('计算中…');
            status('配置已修改，正在试算；尚未保存。', false); timer = setTimeout(preview, 300);
        });
        $('#lwSave').on('click', function () {
            if (!state || saving) return;
            var c; try { c = read(); } catch (e) { status(e.message, true); return; }
            clearTimeout(timer); previewNumber++;
            var gen = generation; saving = true; $('#labaWeights input,#lwSave').prop('disabled', true);
            send(LABA_WEIGHTS_URLS.save, payload(c), function (data) {
                saving = false;
                if (gen !== generation) return;
                $('#labaWeights input,#lwSave').prop('disabled', false); syncNoWin(); status(data && data.content || '保存失败。', !data || data.code !== 1 || !data.hotReload);
                if (data && data.code === 1) { state.config = c; result(data.result); }
            });
        });
    });
})(jQuery);
