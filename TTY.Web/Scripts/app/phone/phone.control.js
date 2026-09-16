/* ============================================================
   控制管理页（吃分 / 放水 / 控牌，对齐电脑端总控窗口）
   页面框架对齐参考站送奖管理：账号查询 → 统计卡 → 控制类型 → 动态参数 →
   应用控制。房间锁定 1 个，无场次。
   数据源：
     - /Game/UserInfo/GetVisibleUserRows    查询玩家
     - /Game/UserInfo/GetTotalControlStatus 当前执行中的总控（含阈值进度/控牌次数）
     - /Game/UserInfo/ApplyTotalControl     应用控制（Mode=4 吃分 / 5 放水 / 6 控牌）
     - /Game/UserInfo/CloseTotalControl     移除当前控制
   权限：服务端渲染控制类型下拉（吃分需 IsKill、放水需 IsProbability、控牌需 IsRelease）。
   记录行参数解析：GameId=控牌游戏(cardAction)、LimitCoins=控牌值(cardValue)/强度、
   TargetCoins=控牌次数(cardNumber)/金币阈值。
   ============================================================ */
(function (window, $, M) {
    'use strict';

    var current = null; // 当前查询的玩家
    var submitting = false;

    /* ---------------- 控牌参数 ---------------- */
    /* 牌型表与命名（M.CARD_ACTIONS / M.cardActionName / M.cardTypeData / M.cardControlText）
       已移到 phone.core.js，与玩家列表卡片共用同一份，避免两个页面各维护一份倍率表。 */

    function fillSelect($sel, rows, keepValue) {
        var prev = keepValue ? $sel.val() : null;
        $sel.html(rows.map(function (r) {
            return '<option value="' + M.esc(r.id) + '">' + M.esc(r.text) + '</option>';
        }).join(''));
        if (prev != null && $sel.find('option[value="' + $.escapeSelector(String(prev)) + '"]').length) {
            $sel.val(prev);
        }
        // 换成向上展开浮层的字段（控制牌型）在选项重建后同步按钮文案
        if (M.upwardSelectRefresh) M.upwardSelectRefresh($sel);
    }

    function modeName(mode) {
        mode = parseInt(mode, 10);
        return mode == 4 ? '吃分' : (mode == 5 ? '放水' : (mode == 6 ? '控牌' : ''));
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
        $('#stBet').text(M.gold(row.CurrentBetCoins || 0)).removeClass('positive negative');
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
            $el.attr('class', 'info-value').empty();
            return;
        }
        var items = rows.map(function (r) {
            return ctrlParamText(r.ControlMode, r.GameId, r.LimitCoins, r.TargetCoins, r.CardNumber, r.CardTotal) +
                (Number(r.ControlMode) == 6 ? '' : ' 已' + (Number(r.ControlMode) == 5 ? '放' : '吃') + '分 ' + M.gold(Number(r.ControlMode) == 5 ? r.GrantedCoins : r.ConsumedCoins));
        });
        $el.attr('class', 'info-value ctrl-status-list')
            .html(items.map(function (t) { return '<span class="ctrl-status-item">' + M.esc(t) + '</span>'; }).join(''));
    }

    /** 当前控制参数文案：吃分/放水显示目标；控牌显示游戏、牌型和固定 1/5 规则。 */
    function ctrlParamText(mode, gameId, killRatio, targetCoins, cardNumber, cardTotal) {
        mode = parseInt(mode, 10);
        if (mode == 6) {
            // 与玩家列表卡片同一份文案（含 GameId<5 的历史数据回退）
            return M.cardControlText(gameId, killRatio);
        }
        return '目标 ' + M.gold(targetCoins);
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
        $('#rowGold').toggle(!isCard);
        $('#rowCardAction, #rowCardValue').toggle(isCard);
        if (isCard) {
            fillSelect($('#ctrlCardAction'), M.CARD_ACTIONS, true);
            fillSelect($('#ctrlCardValue'), M.cardTypeData(parseInt($('#ctrlCardAction').val(), 10)), false);
        }
    }

    /* ---------------- 应用 / 关闭 ---------------- */

    function applyControl() {
        if (!current) { M.toast('请先查询玩家信息', 'error'); return; }
        var mode = currentMode();
        var para = { ID: current.ID, Mode: mode, MobileRequest: 1 };

        if (mode == 6) {
            // 控牌按次数控制，不需要金币阈值
            para.GoldThreshold = 0;
            para.CardAction = parseInt($('#ctrlCardAction').val(), 10);
            para.CardValue = parseInt($('#ctrlCardValue').val(), 10);
            // 需求固定为控制 1 次，且必须在 5 把之内；不再让客户端选择次数。
            para.CardNumber = 1;
            para.CardTotal = 5;
        } else {
            // 吃分/放水无需再选择开关，默认按开启状态提交。
            para.Strength = 3;
            var gold = $.trim($('#ctrlGold').val());
            if (!gold || parseInt(gold, 10) <= 0) {
                M.toast('请填写大于 0 的目标', 'error');
                return;
            }
            para.GoldThreshold = parseInt(gold, 10);
        }

        var desc = mode == 6
            ? '对玩家 ' + current.ID + ' 执行 控牌（' + M.cardActionName(para.CardAction) +
              ' ' + M.cardTypeName(para.CardAction, para.CardValue) + '，1 次（5 把之内））？'
            : '对玩家 ' + current.ID + ' 执行 ' + modeName(mode) + '（目标 ' + M.gold(para.GoldThreshold) + '）？';

        M.confirm(desc, '控制确认').then(function (ok) {
            if (!ok) return;
            if (submitting) return;
            submitting = true;
            $('#applyBtn, #closeCtrlBtn').prop('disabled', true);
            M.loading('下发中...');
            M.post('/Game/UserInfo/ApplyTotalControl', para).always(M.hideLoading).then(function (res) {
                var r = M.result(res);
                M.alert(r.ok ? (r.text || '操作成功') : r.text, r.ok, r.ok ? '操作成功' : '操作失败').then(function () {
                    if (r.ok) {
                        refreshCtrlStatus();
                    }
                });
            }, function () {
                M.toast('操作失败，请稍后重试', 'error');
            }).always(function () {
                submitting = false;
                $('#applyBtn, #closeCtrlBtn').prop('disabled', false);
            });
        });
    }

    function closeControl() {
        if (!current) { M.toast('请先查询玩家信息', 'error'); return; }
        var mode = currentMode();
        M.confirm('确认移除该玩家的' + modeName(mode) + '？', '移除控制').then(function (ok) {
            if (!ok) return;
            if (submitting) return;
            submitting = true;
            $('#applyBtn, #closeCtrlBtn').prop('disabled', true);
            M.loading('处理中...');
            M.post('/Game/UserInfo/CloseTotalControl', { ID: current.ID, Mode: mode, MobileRequest: 1 }).always(M.hideLoading).then(function (res) {
                var r = M.result(res);
                M.alert(r.ok ? (r.text || '移除成功') : r.text, r.ok, r.ok ? '移除成功' : '操作失败').then(function () {
                    if (r.ok) {
                        refreshCtrlStatus();
                    }
                });
            }, function () {
                M.toast('操作失败，请稍后重试', 'error');
            }).always(function () {
                submitting = false;
                $('#applyBtn, #closeCtrlBtn').prop('disabled', false);
            });
        });
    }

    /* ---------------- 初始化 ---------------- */

    function initPage() {
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
            fillSelect($('#ctrlCardValue'), M.cardTypeData(parseInt($(this).val(), 10)), false);
        });
        $('#applyBtn').on('click', applyControl);
        $('#closeCtrlBtn').on('click', closeControl);

        // 控制牌型在页面底部：原生 select 的列表只能向下弹、会被屏幕裁掉，换成默认向上展开的浮层
        //（牌机 11 项、水浒传 35 项都要能点到；原生 select 仍作为取值来源）
        M.upwardSelect($('#ctrlCardValue'));

        bindMode();
    }

    // 脚本在 body 末尾加载，DOM 已就绪；不依赖 jQuery ready
    //（部分 WebView 中 ready 之后注册的回调不会被执行）
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', initPage);
    } else {
        initPage();
    }

})(window, jQuery, window.MApp);
