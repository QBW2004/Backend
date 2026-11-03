(function ($) {
    'use strict';
    var state = null, generation = 0, previewNumber = 0, timer, SCALE = 10000;
    var fruitNames = ['BAR', '77', '星星', '铃铛', '西瓜', '芒果', '橘子', '苹果'];
    var poolNames = ['小三元', '大三元', '大四喜', '小满贯', '大满贯', '纵横四海', '随机1至5灯', '开火车', '天女散花7灯', '天龙八部8灯', '九莲宝灯9灯', '吃灯'];
    var maryOuter = ['退出', '鲁智深', '枪', '忠义堂', '斧', '刀', '退出', '宋江', '鲁智深', '枪', '斧', '替天行道', '退出', '林冲', '刀', '斧', '鲁智深', '忠义堂', '退出', '枪', '宋江', '斧', '刀', '替天行道'];
    var maryAwards = { '退出':0, '忠义堂':200, '替天行道':100, '宋江':70, '林冲':50, '鲁智深':20, '刀':10, '枪':5, '斧':2 };
    var maryGroups = ['退出', '忠义堂', '替天行道', '宋江', '林冲', '鲁智深', '刀', '枪', '斧'];
    function status(message, error) { $('#lwStatus').text(message).css('color', error ? '#b42318' : '#48566d'); }
    function token() { return $('#gcForm [name="__RequestVerificationToken"]').val(); }
    function scope() { return parseInt($('#gcId').val(), 10); }
    function supported(game) { return [16, 40, 53].indexOf(game) >= 0; }
    function send(url, data, callback, timeout) {
        $.ajax({ url:url, type:'POST', data:data, dataType:'json', timeout:timeout || 12000 })
            .done(callback).fail(function () { callback({ code:0, content:timeout ? '保存请求未完成，请重新读取桌台确认是否已落库后再重试。' : '请求未完成，请检查连接后重试。' }); });
    }
    window.labaWeightsClear = function () {
        generation++; previewNumber++; clearTimeout(timer); state = null;
        $('#labaWeights,#lwEditor,#lwMary,#lwFruitPools').hide();
        $('#lwMain,#lwExtra,#lwMaryFields').empty(); $('#lwWinSum').text('');
        $('#lwFruitHint,#lwMx97Hint,#lwShzHint,#lwMx97BonusHint,#lwShzBonusHint').hide();
    };
    function weightInput(label, index, value, kind, readOnly) {
        var max = kind === 'extra' ? (index === 64 ? 512 : 10000) : SCALE;
        var el = $('<input type="number" step="1" class="lw-weight">').attr({ min:index === 64 && kind === 'extra' ? 27 : 0, max:max, 'aria-label':label }).val(value).attr('data-' + kind, index);
        if (readOnly) el.prop('readonly', true).attr('data-nowin', '1');
        return el;
    }
    function multiple(value) { return Number(value.toFixed(3)).toString(); }
    function itemName(game, item) {
        if (game === 53 && item.code === 432) return '水浒传（万能图标）5连';
        if (game === 53 && item.code === 450) return '全盘人物（宋江／林冲／鲁智深）';
        if (game === 53 && item.code === 451) return '全盘兵器（刀／枪／斧）';
        if (game === 16 && item.code === 308) return '7三连（按 ALL 3个7 结算）';
        if (game === 16 && item.code >= 322 && item.code <= 329) return 'ALL ' + (item.code - 320) + '个7（全盘计数）';
        return item.name.replace('全屏', '全盘');
    }
    function meanText(game, item) {
        if (game === 40) return item.multiplier > 0 ? multiple(item.multiplier) + ' 倍' : '幸运灯奖池';
        if (item.code === 0) return '自动计算';
        if (game === 53 && item.code >= 440) return multiple(item.mean / 9) + ' 倍总押注';
        return '本类整盘平均 ' + multiple(item.mean) + ' 倍单线注';
    }
    function renderMain(items, c) {
        var game = state.gameId, body = $('#lwMain').empty();
        $('#lwTypeHeading').text(game === 40 ? '灯位／奖型' : '奖型');
        $('#lwWeightHeading').text(game === 40 ? '相对权重（0～10000）' : '出现机会（每 ' + SCALE + ' 次）');
        $('#lwMeanHeading').text(game === 40 ? '固定奖励（对应押区）' : '奖励参考（只读）');
        $('#lwMainNote').text(game === 40 ? '概率按24灯总权重计算，左右幸运灯及奖池各自独立。' : '本类整盘平均含同盘其他中奖线，并非单条线的固定赔率；全盘奖不叠加线奖。');
        $('#lwMainHeading').toggle(game === 53);
        items.forEach(function (item, i) {
            var name = itemName(game, item), row = $('<tr>').appendTo(body);
            $('<td>').text(name).appendTo(row);
            $('<td class="lw-number">').append(weightInput(name + '权重', i, c.main[i], 'main', i === state.noWin)).appendTo(row);
            $('<td class="lw-number">').text(meanText(game, item)).appendTo(row);
            $('<td class="lw-number">').attr('data-main-prob', i).appendTo(row);
        });
    }
    function poolTable(title, start, c) {
        var panel = $('<div>'), table = $('<table class="lw-table">').attr('aria-label', title), body = $('<tbody>');
        $('<div class="lw-pool-title">').text(title).appendTo(panel);
        table.append('<thead><tr><th>奖型</th><th>相对权重</th></tr></thead>').append(body).appendTo(panel);
        poolNames.forEach(function (name, i) {
            var row = $('<tr>').append($('<td>').text(name)).appendTo(body);
            $('<td class="lw-number">').append(weightInput(title + name + '权重', start + i, c.extra[start + i], 'extra')).appendTo(row);
        });
        return panel;
    }
    function maryPosition(i) {
        if (i < 7) return [1, i + 1];
        if (i < 13) return [i - 5, 7];
        if (i < 19) return [7, 19 - i];
        return [25 - i, 1];
    }
    function renderMary(c) {
        var box = $('#lwMaryFields').empty(), layout = $('<div class="lw-mary-layout">').appendTo(box);
        var ringBox = $('<div>').appendTo(layout), ring = $('<div class="lw-mary-ring">').appendTo(ringBox);
        $('<div class="lw-mary-center"><span class="lw-mary-center-title">小玛丽 · 外圈24格</span><p>顺时针 01 → 24</p><p>四个“退出”合计概率</p><strong id="lwMaryExit"></strong><p>继续开奖 <output id="lwMaryPlay"></output><br>外圈总权重 <output id="lwMarySum"></output></p><p>命中退出扣1次剩余次数<br>中奖回合不扣次数，不另扣押注</p></div>').appendTo(ring);
        maryOuter.forEach(function (name, i) {
            var pos = maryPosition(i), cell = $('<label class="lw-mary-stop">').toggleClass('lw-exit', name === '退出').css({ gridRow:String(pos[0]), gridColumn:String(pos[1]) }).appendTo(ring);
            $('<span class="lw-mary-index">').text(('0' + (i + 1)).slice(-2)).appendTo(cell);
            $('<span class="lw-mary-name">').text(name).appendTo(cell);
            cell.append(weightInput('小玛丽外圈' + (i + 1) + '·' + name + '权重', 40 + i, c.extra[40 + i], 'extra'));
            $('<output class="lw-mary-prob">').attr('data-mary-prob', i).appendTo(cell);
        });
        $('<p class="gc-hint">').text('顺时针停位示意 · 红色为退出格 · 格内直接填写权重').appendTo(ringBox);
        var overview = $('<div class="lw-mary-overview">').appendTo(layout);
        $('<div class="lw-pool-title">').text('同图案概率合计').appendTo(overview);
        var groups = $('<table class="lw-mary-groups">').attr('aria-label', '小玛丽图案概率汇总').appendTo(overview), body = $('<tbody>');
        groups.append('<thead><tr><th>图案</th><th>格数</th><th>单张匹配</th><th>合计概率</th></tr></thead>').append(body);
        maryGroups.forEach(function (name) {
            var row = $('<tr>').toggleClass('lw-exit', name === '退出').appendTo(body);
            row.append($('<td>').text(name), $('<td>').text(maryOuter.filter(function (v) { return v === name; }).length), $('<td>').text(name === '退出' ? '扣1次' : maryAwards[name] + '倍'));
            $('<td class="lw-number">').attr('data-mary-group', name).appendTo(row);
        });
        $('<p class="gc-hint">').text('匹配奖励＝单线注×倍数×内圈同图案张数；内圈三同／四同额外奖励另计。').appendTo(overview);
        $('<label class="lw-mary-limit">').text('最大回合数（27～512）').append(weightInput('小玛丽最大回合', 64, c.extra[64], 'extra')).appendTo(overview);
        $('<p class="gc-hint">').text('每次进入的总转灯上限；接近上限会强制退出，直至剩余次数耗尽，不代表赠送次数。').appendTo(overview);
    }
    function renderExtras(c) {
        var game = state.gameId;
        $('#lwExtra,#lwMaryFields').empty();
        $('#lwMary,#lwShzBonusHint').toggle(game === 53);
        $('#lwFruitPools').toggle(game === 40); $('#lwMx97BonusHint').toggle(game === 16);
        if (game === 40) $('#lwExtra').append(poolTable('右侧幸运灯（灯10 / 面板位9）奖池', 1, c), poolTable('左侧幸运灯（灯22 / 面板位21）奖池', 28, c));
        if (game === 53) renderMary(c);
    }
    function syncNoWin() {
        if (!state || state.noWin < 0) { $('#lwWinSum').text(''); return 0; }
        var wins = 0;
        $('#lwMain input[data-main]').each(function () {
            if (Number($(this).attr('data-main')) === state.noWin) return;
            var value = $(this).val(); if (/^\d+$/.test(value)) wins += Number(value);
        });
        $('#lwMain input[data-nowin]').val(wins <= SCALE ? SCALE - wins : '');
        $('#lwWinSum').text('中奖奖型合计 ' + wins + ' / ' + SCALE + '，未中奖 ' + (wins <= SCALE ? SCALE - wins : '—') + '（自动计算）').css('color', wins > SCALE ? '#b42318' : '#48566d');
        return wins;
    }
    function syncProbabilities() {
        if (!state) return;
        var main = [], valid = true, sum = 0;
        $('#lwMain input[data-main]').each(function () {
            var value = $(this).val(); if (!/^\d+$/.test(value)) valid = false;
            main[Number($(this).attr('data-main'))] = Number(value); sum += Number(value);
        });
        $('#lwMain [data-main-prob]').each(function () {
            $(this).text(valid && sum > 0 ? (main[Number($(this).attr('data-main-prob'))] / sum * 100).toFixed(state.gameId === 53 ? 3 : 2) + '%' : '—');
        });
        if (state.gameId !== 53) return;
        var weights = [], total = 0, exits = 0;
        $('#lwMary input[data-extra]').each(function () {
            var index = Number($(this).attr('data-extra')) - 40;
            if (index < 0 || index >= 24) return;
            var value = $(this).val(); weights[index] = /^\d+$/.test(value) ? Number(value) : 0;
            total += weights[index]; if (maryOuter[index] === '退出') exits += weights[index];
        });
        function percent(value) { return total > 0 ? (value / total * 100).toFixed(2) + '%' : '—'; }
        $('#lwMaryExit').text(percent(exits)); $('#lwMaryPlay').text(percent(total - exits)); $('#lwMarySum').text(total);
        $('#lwMary [data-mary-prob]').each(function () { $(this).text(percent(weights[Number($(this).attr('data-mary-prob'))])); });
        $('#lwMary [data-mary-group]').each(function () {
            var name = $(this).attr('data-mary-group'), count = 0;
            maryOuter.forEach(function (v, i) { if (v === name) count += weights[i]; });
            $(this).text(percent(count));
        });
    }
    function result(r) {
        $('#lwRtp').text('理论 RTP ' + r.totalRtp.toFixed(4) + '%');
        $('#lwParts').text('基础奖 ' + r.baseRtp.toFixed(4) + '% ＋ 额外玩法 ' + r.extraRtp.toFixed(4) + '%');
        $('#lwBasis').text(r.basis);
        $('#lwAreas').text(r.areaRtp ? r.areaRtp.map(function (p, i) { return fruitNames[i] + '：' + p.toFixed(3) + '%'; }).join('　') : '基础盘面中奖率 ' + r.hitRate.toFixed(4) + '%');
    }
    function read() {
        var c = JSON.parse(JSON.stringify(state.config)); c.enabled = true;
        if (state.gameId === 40) c.extra[0] = 1;
        if (state.noWin >= 0 && syncNoWin() > SCALE) throw new Error('中奖奖型权重合计不能超过' + SCALE + '。');
        $('#labaWeights input[data-main],#labaWeights input[data-extra]').each(function () {
            var value = $(this).val(), main = $(this).attr('data-main'), extra = $(this).attr('data-extra');
            var max = extra === '64' ? 512 : (extra !== undefined ? 10000 : SCALE);
            if (!/^\d+$/.test(value) || Number(value) > max || (extra === '64' && Number(value) < 27)) throw new Error(extra === '64' ? '小玛丽最大回合范围为27至512。' : '权重必须为0至' + max + '的整数。');
            if (main !== undefined) c.main[Number(main)] = Number(value);
            if (extra !== undefined) c.extra[Number(extra)] = Number(value);
        });
        if (state.gameId === 53 && c.extra.slice(40, 64).reduce(function (a, b) { return a + b; }, 0) === 0) throw new Error('小玛丽外圈至少设置一个权重。');
        if (state.gameId === 40 && c.extra.slice(1, 13).reduce(function (a, b) { return a + b; }, 0) === 0) throw new Error('右侧幸运灯奖池至少设置一个权重；左侧全0时沿用右侧。');
        return c;
    }
    function bet() {
        var value = $('#lwBet').val();
        if (!/^\d+$/.test(value) || Number(value) < 1 || Number(value) > 1000000) throw new Error('试算单线注范围为1至1000000。');
        return Number(value);
    }
    function payload(c) { return { gameId:state.gameId, tableIndex:state.tableIndex, weightsJson:JSON.stringify(c), bet:bet(), __RequestVerificationToken:token() }; }
    function preview() {
        if (!state) return;
        var p, run = ++previewNumber, gen = generation;
        try { p = payload(read()); } catch (e) { status(e.message, true); $('#lwRtp').text('配置不合法'); return; }
        status('正在试算；修改尚未保存。', false);
        send(LABA_WEIGHTS_URLS.preview, p, function (data) {
            if (gen !== generation || run !== previewNumber) return;
            if (data && data.code === 1) { result(data.result); status('试算通过；修改尚未保存。', false); }
            else { status(data && data.content || '试算失败。', true); $('#lwRtp').text('无法计算 RTP'); }
        });
    }
    window.labaWeightsCollect = function () {
        var game = parseInt($('#gcGameId').val(), 10);
        if (!supported(game)) return null;
        if (!state || state.gameId !== game || state.scopeId !== scope()) throw new Error('当前桌台权重尚未载入，请等待载入完成或重新读取后保存。');
        try {
            var c = read(), value = bet(); clearTimeout(timer); previewNumber++;
            return { LabaWeightsJson:JSON.stringify(c), LabaWeightsBet:value };
        } catch (e) { status(e.message, true); throw e; }
    };
    window.labaWeightsSetSaving = function (on) { $('#labaWeights input').prop('disabled', !!on); };
    window.labaWeightsSubmit = function (url, para, callback) { send(url, para, callback, 30000); };
    window.labaWeightsLoad = function () {
        window.labaWeightsClear();
        var game = parseInt($('#gcGameId').val(), 10), id = scope();
        if (!supported(game)) return;
        var gen = generation, isNew = id < 0;
        $('#labaWeights').show(); $('#lwFruitHint').toggle(game === 40);
        $('#lwMx97Hint').toggle(game === 16); $('#lwShzHint').toggle(game === 53); status('加载当前机台权重…', false);
        send(LABA_WEIGHTS_URLS.get, { gameId:game, tableIndex:isNew ? 0 : id % 1000, newTable:isNew }, function (data) {
            if (gen !== generation || id !== scope()) return;
            if (!data || data.code !== 1) { status(data && data.content || '加载失败。', true); return; }
            SCALE = data.scale || (game === 53 ? 100000 : 10000);
            state = { config:data.config, gameId:game, scopeId:id, tableIndex:isNew ? 0 : id % 1000, noWin:game !== 40 && data.items.length && data.items[0].code === 0 ? 0 : -1 };
            $('#lwBet').val(1); renderMain(data.items, data.config); renderExtras(data.config);
            syncNoWin(); syncProbabilities(); if (data.result) result(data.result); else $('#lwRtp').text('配置不合法'); $('#lwEditor').show();
            if (data.validationError) status(data.validationError + ' 请调整权重后保存。', true);
            else if (data.stale) status('开奖规则已更新；下方为新规则默认权重，保存并热更新后生效。', true);
            else if (data.converted) status('原权重已按比例换算为每 ' + SCALE + ' 次，请核对理论 RTP；保存后生效。', true);
            else status(isNew || data.activationPending ? '权重默认开启，保存并热更新后生效。' : '已载入当前机台权重。', false);
        });
    };
    $(function () {
        $('#labaWeights').on('input change', 'input', function () {
            syncNoWin(); syncProbabilities(); clearTimeout(timer); previewNumber++; $('#lwRtp').text('计算中…');
            status('配置已修改，正在试算；尚未保存。', false); timer = setTimeout(preview, 300);
        });
    });
})(jQuery);
