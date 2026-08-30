/* ============================================================
   控制管理页（吃分 / 送分 / 控牌，对齐电脑端总控窗口）
   页面框架对齐参考站送奖管理：账号查询 → 统计卡 → 控制类型 → 动态参数 →
   应用控制 → 底部控制记录（日期筛选 + 刷新 + 分页）。房间锁定 1 个，无场次。
   数据源：
     - /Game/UserInfo/GetVisibleUserRows    查询玩家
     - /Game/UserInfo/GetTotalControlStatus 当前执行中的总控（含阈值进度/控牌次数）
     - /Game/UserInfo/ApplyTotalControl     应用控制（Mode=4 吃分 / 5 送分 / 6 控牌）
     - /Game/UserInfo/CloseTotalControl     关闭当前功能
     - /Game/UserInfo/GetControlRecords     总控记录分页（含执行中数量）
   权限：服务端渲染控制类型下拉（吃分需 IsKill、送分需 IsProbability、控牌需 IsRelease）。
   记录行参数解析：GameId=控牌游戏(cardAction)、LimitCoins=控牌值(cardValue)/强度、
   TargetCoins=控牌次数(cardNumber)/金币阈值。
   ============================================================ */
(function (window, $, M) {
    'use strict';

    var PAGE_SIZE = 20;
    var recPage = 1;
    var recTotal = 0;
    var current = null; // 当前查询的玩家

    /* ---------------- 控牌参数（移植电脑端 UserInfo/Index.cshtml） ---------------- */

    // 牌机 13 种牌型（与服务端 te_CardsType 枚举 0..12 一致）
    var TC_CARD_TYPES = [
        { ht: 0, name: '杂牌' }, { ht: 1, name: '对子' }, { ht: 2, name: '两对' },
        { ht: 3, name: '三条' }, { ht: 4, name: '杂顺' }, { ht: 5, name: '同花' },
        { ht: 6, name: '葫芦' }, { ht: 7, name: '小四梅' }, { ht: 8, name: '大四梅' },
        { ht: 9, name: '同花顺' }, { ht: 10, name: '五梅' }, { ht: 11, name: '同花大顺' },
        { ht: 12, name: '五鬼' }
    ];
    // 各牌机游戏倍率（与台机设定 GC_MAG_TAB 一致；ATT3 取 middle 档）
    var TC_MAG_TAB = {
        phenix: [0, 1, 2, 3, 5, 7, 10, 40, 80, 120, 250, 500, 1000],
        king3:  [0, 1, 2, 3, 5, 7, 10, 60, 60, 120, 250, 500, 1000],
        dazhi:  [0, 1, 2, 3, 5, 7, 15, 65, 65, 150, 350, 250, 350],
        nba:    [0, 1, 2, 3, 5, 7, 10, 50, 50, 100, 400, 200, 1000],
        att3:   [0, 1, 2, 3, 5, 7, 10, 50, 50, 120, 400, 200, 1000]
    };

    function tcMagKey(action) {
        if (action == 5) return 'dazhi';
        if (action == 7) return 'att3';
        if (action == 12) return 'king3';
        if (action == 13) return 'nba';
        return 'phenix';
    }

    // 牌机型(5-14)牌型下拉：0-12 + 99 关闭控制（大字板五鬼已下线）
    function cardTypeDataForPaiji(action) {
        var mags = TC_MAG_TAB[tcMagKey(action)];
        var arr = [];
        for (var i = 0; i < TC_CARD_TYPES.length; i++) {
            var t = TC_CARD_TYPES[i];
            if (action == 5 && t.ht == 12) continue;
            arr.push({ id: t.ht, text: t.name + '(' + mags[t.ht] + '倍)' });
        }
        arr.push({ id: 99, text: '关闭控制' });
        return arr;
    }

    function cardTypeDataForShz() {
        return [
            { id: 0, text: '双斧(2倍)' }, { id: 1, text: '双枪(3倍)' }, { id: 2, text: '大刀(4倍)' },
            { id: 3, text: '鲁智深(5倍)' }, { id: 4, text: '林冲(8倍)' }, { id: 5, text: '宋江(10倍)' },
            { id: 6, text: '替天行道旗(15倍)' }, { id: 7, text: '忠义堂(20倍)' },
            { id: 8, text: '水浒传龙标·散标(30倍/免费触发)' }, { id: 10, text: '关闭控制' }
        ];
    }

    function cardTypeDataForMx97() {
        return [
            { id: 0, text: '樱桃(10倍)' }, { id: 1, text: '橘子(10倍)' }, { id: 2, text: '蓝莓(14倍)' },
            { id: 3, text: '铃铛(18倍)' }, { id: 4, text: '西瓜(20倍)' }, { id: 5, text: '黄BAR(30倍)' },
            { id: 6, text: '红BAR(50倍)' }, { id: 7, text: '蓝BAR(70倍)' }, { id: 8, text: '七(80倍+)' },
            { id: 10, text: '关闭控制' }
        ];
    }

    // 水果拉霸控牌=强制大转盘指向面板位（与机台设定的 24 面板位一致）；id=30+面板位，10=关闭
    function cardTypeDataForFruit() {
        var panels = [
            '橘子·大(10倍)', '铃铛·大(20倍)', 'BAR·小(50倍)', 'BAR·大(120倍)', '苹果(5倍)', '苹果·小(3倍)',
            '柠檬·大(15倍)', '西瓜·大(20倍)', '西瓜·小(3倍)', '送灯位(免费局)', '苹果(5倍)', '橘子·小(3倍)',
            '橘子·大(10倍)', '铃铛·大(20倍)', '双7·小(3倍)', '双7·大(40倍)', '苹果(5倍)', '柠檬·小(3倍)',
            '柠檬·大(15倍)', '星星·小(3倍)', '星星·大(30倍)', '送灯位(免费局)', '苹果(5倍)', '铃铛·小(3倍)'
        ];
        var arr = [];
        for (var i = 0; i < panels.length; i++)
            arr.push({ id: 30 + i, text: '面板' + i + ' · ' + panels[i] });
        arr.push({ id: 10, text: '关闭控制' });
        return arr;
    }

    var CARD_ACTIONS = [
        { id: 5, text: '大字版控制' }, { id: 7, text: 'ATT3控制' }, { id: 12, text: '金皇冠' },
        { id: 13, text: 'NBA' }, { id: 14, text: '火凤凰' }, { id: 15, text: '水浒传' },
        { id: 16, text: '明星97' }, { id: 17, text: '水果拉霸' }
    ];

    function cardActionName(action) {
        for (var i = 0; i < CARD_ACTIONS.length; i++)
            if (CARD_ACTIONS[i].id == action) return CARD_ACTIONS[i].text;
        return '游戏' + action;
    }

    function cardTypeName(action, value) {
        var rows = cardTypeData(parseInt(action, 10));
        for (var i = 0; i < rows.length; i++)
            if (rows[i].id == value) return rows[i].text;
        return '牌型' + value;
    }

    function fillSelect($sel, rows, keepValue) {
        var prev = keepValue ? $sel.val() : null;
        $sel.html(rows.map(function (r) {
            return '<option value="' + M.esc(r.id) + '">' + M.esc(r.text) + '</option>';
        }).join(''));
        if (prev != null && $sel.find('option[value="' + $.escapeSelector(String(prev)) + '"]').length) {
            $sel.val(prev);
        }
    }

    function cardTypeData(action) {
        if (action == 15) return cardTypeDataForShz();
        if (action == 16) return cardTypeDataForMx97();
        if (action == 17) return cardTypeDataForFruit();
        return cardTypeDataForPaiji(action);
    }

    function modeName(mode) {
        mode = parseInt(mode, 10);
        return mode == 4 ? '吃分' : (mode == 5 ? '送分' : (mode == 6 ? '控牌' : ''));
    }

    /* ---------------- 账号实时模糊联想 ---------------- */

    var acTimer = null;
    var acSeq = 0; // 防止乱序响应覆盖新结果

    function acHide() {
        $('#acSuggest').removeClass('show').empty();
    }

    /** 命中片段高亮（大小写不敏感，逐段转义） */
    function acHighlight(text, kw) {
        var t = String(text == null ? '' : text);
        var k = String(kw || '');
        var idx = k ? t.toLowerCase().indexOf(k.toLowerCase()) : -1;
        if (idx < 0) return M.esc(t);
        return M.esc(t.substring(0, idx)) +
            '<span class="ac-hl">' + M.esc(t.substring(idx, idx + k.length)) + '</span>' +
            M.esc(t.substring(idx + k.length));
    }

    function acRender(rows, kw) {
        var $box = $('#acSuggest');
        if (!rows.length) {
            $box.html('<div class="ac-empty">未找到匹配账号</div>').addClass('show');
            return;
        }
        $box.html(rows.map(function (p) {
            var online = p.INHALL === true;
            return '<div class="ac-item" data-account="' + M.esc(p.ID) + '">' +
                '<span class="ac-account">' + acHighlight(p.ID, kw) + (online ? ' <span class="positive">·在线</span>' : '') + '</span>' +
                '<span class="ac-name">' + M.esc(p.NAME || '') + '</span>' +
                '<span class="ac-coins">' + M.gold(p.COINS) + '币</span>' +
                '</div>';
        }).join('')).addClass('show');
    }

    function acSearch(kw) {
        var seq = ++acSeq;
        M.post('/Game/UserInfo/GetUsers', { srch_ID: kw, srch_NAME: '', srch_Agency: '', page: 1, rows: 8 })
            .then(function (list) {
                if (seq !== acSeq) return; // 已有更新的输入，丢弃旧响应
                acRender((list && list.rows) ? list.rows : [], kw);
            }, function () { });
    }

    /* ---------------- 玩家查询 ---------------- */

    function queryPlayer() {
        var acc = $.trim($('#ctrlAccount').val());
        if (!acc) { M.toast('请输入玩家账号', 'error'); return; }
        acHide();

        M.loading('查询中...');
        M.post('/Game/UserInfo/GetVisibleUserRows', { UserIDs: JSON.stringify([acc]) })
            .always(M.hideLoading)
            .then(function (res) {
                var row = (res && res.datas && res.datas.length) ? res.datas[0] : null;
                if (!row) {
                    current = null;
                    $('#statCards, #playerMeta').removeClass('show');
                    $('#ctrlParams').removeClass('show');
                    $('#applyBtn, #closeCtrlBtn').prop('disabled', true);
                    M.alert('未查询到该玩家，请确认账号是否正确', false, '查询失败');
                    return;
                }
                current = row;
                renderPlayer(row);
                $('#applyBtn, #closeCtrlBtn').prop('disabled', false);
                refreshCtrlStatus();
            });
    }

    function renderPlayer(row) {
        var online = row.INHALL === true;
        $('#stCoins').text(M.gold(row.COINS)).removeClass('positive negative');
        var today = Number(row.TodayWinLoss || 0);
        $('#stToday').text((today > 0 ? '+' : '') + M.gold(today))
            .toggleClass('positive', today > 0).toggleClass('negative', today < 0);
        var total = Number(row.Profit || 0);
        $('#stTotal').text((total > 0 ? '+' : '') + M.gold(total))
            .toggleClass('positive', total > 0).toggleClass('negative', total < 0);
        $('#piOnline').text(online ? '在线' : '离线').attr('class', 'info-value ' + (online ? 'status-online' : 'status-offline'));
        $('#statCards, #playerMeta').addClass('show');
        $('#ctrlParams').addClass('show');
    }

    /* ---------------- 当前控制状态 ---------------- */

    function renderCtrlStatus(rows) {
        var $el = $('#piControl');
        if (!rows || !rows.length) {
            $el.attr('class', 'info-value').html('<span class="ctrl-status-empty">无</span>');
            return;
        }
        var items = rows.map(function (r) {
            return ctrlParamText(r.ControlMode, r.GameId, r.LimitCoins, r.TargetCoins, r.CardNumber, r.CardTotal) +
                (Number(r.ControlMode) == 6 ? '' : ' 已' + (Number(r.ControlMode) == 5 ? '送' : '吃') + '分 ' + M.gold(Number(r.ControlMode) == 5 ? r.GrantedCoins : -r.ConsumedCoins));
        });
        $el.attr('class', 'info-value ctrl-status-list')
            .html(items.map(function (t) { return '<span class="ctrl-status-item">' + M.esc(t) + '</span>'; }).join(''));
    }

    /** 记录/状态的参数文案：吃分/送分 = 强度·目标；控牌 = 游戏·牌型×次数 */
    function ctrlParamText(mode, gameId, killRatio, targetCoins, cardNumber, cardTotal) {
        mode = parseInt(mode, 10);
        if (mode == 6) {
            var n = cardNumber != null ? cardNumber : targetCoins;
            var t = cardTotal ? ' / ' + cardTotal : '';
            // 历史/异常数据可能没有游戏类型（GameId<5），只显示牌型值
            if (parseInt(gameId, 10) >= 5) {
                return cardActionName(gameId) + ' ' + cardTypeName(gameId, killRatio) + ' ×' + n + '次' + t;
            }
            return '控牌值 ' + M.esc(killRatio) + ' ×' + n + '次' + t;
        }
        return '强度 ' + M.esc(killRatio) + ' · 目标 ' + M.gold(targetCoins);
    }

    function refreshCtrlStatus() {
        if (!current) return;
        renderCtrlStatus(null);
        M.post('/Game/UserInfo/GetTotalControlStatus', { ID: current.ID })
            .then(function (res) {
                var r = M.result(res);
                if (r.ok) renderCtrlStatus(r.datas);
            }, function () { });
    }

    /* ---------------- 控制类型切换 ---------------- */

    function currentMode() {
        return parseInt($('#ctrlMode').val() || '0', 10);
    }

    function bindMode() {
        var mode = currentMode();
        var isCard = (mode == 6);
        $('#rowStrength, #rowGold').toggle(!isCard);
        $('#rowCardAction, #rowCardValue, #rowCardNumber, #rowCardTotal').toggle(isCard);
        if (isCard) {
            fillSelect($('#ctrlCardAction'), CARD_ACTIONS, true);
            fillSelect($('#ctrlCardValue'), cardTypeData(parseInt($('#ctrlCardAction').val(), 10)), false);
            if (!$('#ctrlCardNumber').find('option').length) {
                var nums = [];
                for (var i = 1; i <= 10; i++) nums.push({ id: i, text: i });
                fillSelect($('#ctrlCardNumber'), nums, false);
            }
            if (!$('#ctrlCardTotal').find('option').length) {
                fillSelect($('#ctrlCardTotal'), [{ id: 5, text: '五把之内' }, { id: 10, text: '十把之内' }], false);
            }
        }
    }

    /* ---------------- 应用 / 关闭 ---------------- */

    function applyControl() {
        if (!current) { M.toast('请先查询玩家信息', 'error'); return; }
        var mode = currentMode();
        var para = { ID: current.ID, Mode: mode };

        if (mode == 6) {
            // 控牌按次数控制，不需要金币阈值
            para.GoldThreshold = 0;
            para.CardAction = parseInt($('#ctrlCardAction').val(), 10);
            para.CardValue = parseInt($('#ctrlCardValue').val(), 10);
            para.CardNumber = parseInt($('#ctrlCardNumber').val(), 10);
            para.CardTotal = parseInt($('#ctrlCardTotal').val(), 10);
            if (!(para.CardNumber >= 1) || !(para.CardTotal >= 5) || para.CardNumber > para.CardTotal) {
                M.toast('控牌数量/总把数无效（数量≥1，总把数 5-50，数量≤总把数）', 'error');
                return;
            }
        } else {
            para.Strength = parseInt($('#ctrlStrength').val(), 10);
            var gold = $.trim($('#ctrlGold').val());
            if (!gold || parseInt(gold, 10) <= 0) {
                M.toast('请填写大于 0 的目标', 'error');
                return;
            }
            para.GoldThreshold = parseInt(gold, 10);
        }

        var desc = mode == 6
            ? '对玩家 ' + current.ID + ' 执行 控牌（' + cardActionName(para.CardAction) +
              ' ' + cardTypeName(para.CardAction, para.CardValue) + '，次数 ' + para.CardNumber + '/' + para.CardTotal + '）？'
            : '对玩家 ' + current.ID + ' 执行 ' + modeName(mode) + '（目标 ' + M.gold(para.GoldThreshold) + '）？';

        M.confirm(desc, '控制确认').then(function (ok) {
            if (!ok) return;
            M.loading('下发中...');
            M.post('/Game/UserInfo/ApplyTotalControl', para).always(M.hideLoading).then(function (res) {
                var r = M.result(res);
                M.alert(r.text, r.ok, r.ok ? '操作成功' : '操作失败').then(function () {
                    if (r.ok) {
                        refreshCtrlStatus();
                        loadRecords(1);
                    }
                });
            });
        });
    }

    function closeControl() {
        if (!current) { M.toast('请先查询玩家信息', 'error'); return; }
        var mode = currentMode();
        M.confirm('确认关闭该玩家的' + modeName(mode) + '？', '关闭控制').then(function (ok) {
            if (!ok) return;
            M.loading('处理中...');
            M.post('/Game/UserInfo/CloseTotalControl', { ID: current.ID, Mode: mode }).always(M.hideLoading).then(function (res) {
                var r = M.result(res);
                M.alert(r.text, r.ok, r.ok ? '操作成功' : '操作失败').then(function () {
                    if (r.ok) {
                        refreshCtrlStatus();
                        loadRecords(1);
                    }
                });
            });
        });
    }

    /* ---------------- 控制记录（日期筛选 + 分页） ---------------- */

    function pad2(n) { return (n < 10 ? '0' : '') + n; }

    function todayInput() {
        var d = new Date();
        return d.getFullYear() + '-' + pad2(d.getMonth() + 1) + '-' + pad2(d.getDate());
    }

    function loadRecords(page) {
        var start = $.trim($('#recStart').val());
        var end = $.trim($('#recEnd').val());
        M.post('/Game/UserInfo/GetControlRecords', {
            StartTime: start, EndTime: end,
            page: page, rows: PAGE_SIZE
        }).then(function (res) {
            recPage = page;
            recTotal = res ? Number(res.total || 0) : 0;
            $('#recActive').text(res ? Number(res.activeCount || 0) : 0);

            var rows = (res && res.rows) ? res.rows : [];
            var $body = $('#recBody');
            if (!rows.length) {
                $body.empty();
                $('#recNoData').show();
            } else {
                $('#recNoData').hide();
                $body.html(rows.map(function (r) {
                    var active = Number(r.Status) === 0;
                    return '<tr>' +
                        '<td>' + M.esc(r.UserID || '--') + '</td>' +
                        '<td>' + M.esc(modeName(r.ControlMode) || '--') + '</td>' +
                        '<td>' + M.esc(ctrlParamText(r.ControlMode, r.GameId, r.LimitCoins, r.TargetCoins, r.CardNumber, r.CardTotal)) + '</td>' +
                        '<td class="' + (active ? 'positive' : '') + '">' + (active ? '执行中' : '已结束') + '</td>' +
                        '<td>' + M.esc(r.CreatedBy || '--') + '</td>' +
                        '<td class="time">' + M.esc(r.CreatedTime || '--') + '</td>' +
                        '</tr>';
                }).join(''));
            }

            var totalPages = Math.max(1, Math.ceil(recTotal / PAGE_SIZE));
            $('#recPageInfo').text('第 ' + recPage + ' 页 / 共 ' + totalPages + ' 页');
            $('#recPrevBtn').prop('disabled', recPage <= 1);
            $('#recNextBtn').prop('disabled', recPage >= totalPages);
        }, function () { });
    }

    /* ---------------- 初始化 ---------------- */

    function initPage() {
        // 记录区日期默认今天
        $('#recStart').val(todayInput());
        $('#recEnd').val(todayInput());

        var preset = window.MPagePreset || {};
        if (preset.account) {
            $('#ctrlAccount').val(preset.account);
            queryPlayer();
        }

        $('#queryBtn').on('click', queryPlayer);
        $('#ctrlAccount').on('keydown', function (e) {
            if (e.keyCode === 13) {
                acHide();
                queryPlayer();
            }
        });
        // 实时模糊联想：输入防抖 300ms，下拉展示权限范围内的匹配账号，点选即回填并查询
        $('#ctrlAccount').on('input', function () {
            var kw = $.trim($(this).val());
            if (acTimer) { clearTimeout(acTimer); acTimer = null; }
            if (!kw) { acHide(); return; }
            acTimer = setTimeout(function () { acSearch(kw); }, 300);
        });
        $('#ctrlAccount').on('blur', function () { setTimeout(acHide, 180); });
        // mousedown 早于输入框 blur 触发，避免下拉先被隐藏
        $('#acSuggest').on('mousedown', '.ac-item', function (e) {
            e.preventDefault();
            var acc = $(this).data('account');
            if (!acc) return;
            $('#ctrlAccount').val(String(acc));
            acHide();
            queryPlayer();
        });
        $('#ctrlMode').on('change', bindMode);
        $('#ctrlCardAction').on('change', function () {
            fillSelect($('#ctrlCardValue'), cardTypeData(parseInt($(this).val(), 10)), false);
        });
        $('#applyBtn').on('click', applyControl);
        $('#closeCtrlBtn').on('click', closeControl);

        // 记录区
        $('#recRefreshBtn').on('click', function () { loadRecords(1); });
        $('#recPrevBtn').on('click', function () { if (recPage > 1) loadRecords(recPage - 1); });
        $('#recNextBtn').on('click', function () { if (recPage < Math.ceil(recTotal / PAGE_SIZE)) loadRecords(recPage + 1); });

        bindMode();
        loadRecords(1);
    }

    // 脚本在 body 末尾加载，DOM 已就绪；不依赖 jQuery ready
    //（部分 WebView 中 ready 之后注册的回调不会被执行）
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', initPage);
    } else {
        initPage();
    }

})(window, jQuery, window.MApp);
