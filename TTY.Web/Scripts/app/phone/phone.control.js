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
   TargetCoins=控牌次数(cardNumber)/钻阈值。
   ============================================================ */
(function (window, $, M) {
    'use strict';

    var current = null; // 当前查询的玩家
    var submitting = false;
    var querySeq = 0, historySeq = 0, historyPage = 1, walletSeq = 0;
    var historyBusy = false, wallet = null;

    function diamonds(value) {
        var n = Number(value);
        return value == null || !isFinite(n) ? "--" : n.toFixed(8).replace(/\.?0+$/, "");
    }

    function updateButtons() {
        var canApply = !!current && !submitting && (currentMode() == 4 || !!wallet);
        $("#applyBtn").prop("disabled", !canApply);
        $("#closeCtrlBtn").prop("disabled", !current || submitting);
        $('.record-remove-btn').prop('disabled', submitting);
    }

    /* ---------------- 控牌参数 ---------------- */
    /* 牌型表与命名（M.CARD_ACTIONS / M.cardActionName / M.cardTypeData / M.cardControlText）
       已移到 phone.core.js，与玩家列表卡片共用同一份，避免两个页面各维护一份倍率表。 */

    function fillSelect($sel, rows, keepValue) {
        var prev = keepValue ? $sel.val() : null;
        $sel.html(rows.map(function (r) {
            return '<option value="' + M.esc(r.id) + '">' + M.esc(r.text) + '</option>';
        }).join(''));
        if (prev != null && $sel.find('option').filter(function () { return this.value === String(prev); }).length) {
            $sel.val(prev);
        }
        // 换成向上展开浮层的字段（控制牌型）在选项重建后同步按钮文案
        if (M.upwardSelectRefresh) M.upwardSelectRefresh($sel);
    }

    function modeName(mode) {
        mode = parseInt(mode, 10);
        return mode == 4 ? '吃分' : (mode == 5 ? '放水' : (mode == 6 ? '送奖' : ''));
    }

    function hasMode(mode) {
        return $('#ctrlMode option').filter(function () { return this.value === String(mode); }).length > 0;
    }

    /**
     * 查到玩家后按状态预选操作类型（2026-11-03）：
     * 在线且正在可送奖的游戏里 → 送奖 + 该游戏；其余（离线/大厅/鱼机押注等不支持送奖的游戏）→ 吃分；
     * 没有对应权限时退回下拉第一项（只有一个权限时就只有那一项）。预选后仍可手动修改。
     */
    function presetMode(row, gameId) {
        var action = row && row.INHALL === true ? M.cardActionOfGame(gameId) : 0;
        var playable = action > 0 && $.grep(M.playableCardActions(M.CARD_ACTIONS), function (a) { return a.id == action; }).length > 0;
        var mode = playable && hasMode(6) ? 6 : (hasMode(4) ? 4 : parseInt($('#ctrlMode option:first').val() || '0', 10));
        $('#ctrlMode').val(String(mode));
        bindMode();
        if (mode == 6) {
            $('#ctrlCardAction').val(String(action));
            fillSelect($('#ctrlCardValue'), M.cardTypeData(action), false);
        }
    }

    /* ---------------- 账号实时模糊联想 ---------------- */

    var acTimer = null;
    var acSeq = 0; // 防止乱序响应覆盖新结果

    function acHide() {
        if (acTimer) { clearTimeout(acTimer); acTimer = null; }
        ++acSeq;
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
                '<span class="ac-coins">' + M.gold(p.COINS) + '钻</span>' +
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
        var seq = ++querySeq;
        current = null;
        $('#stBet, #stToday, #stTotal').text('--').removeClass('positive negative');
        $('#playerMeta').removeClass('show');
        updateButtons();

        M.loading('查询中...');
        M.post('/Game/PrizePool/Player', { ID: acc })
            .always(M.hideLoading)
            .then(function (res) {
                if (seq !== querySeq) return;
                var r = M.result(res);
                var row = r.ok && r.datas ? r.datas.Player : null;
                if (!row) {
                    current = null;
                    $('#playerMeta').removeClass('show');
                    loadHistory(true);
                    $('#applyBtn, #closeCtrlBtn').prop('disabled', true);
                    M.alert('未查询到该玩家，请确认账号是否正确', false, '查询失败');
                    return;
                }
                current = row;
                renderPlayer(row, r.datas.CurrentBetDiamonds);
                presetMode(row, r.datas.CurrentGameId);
                updateButtons();
                refreshWallet();
                loadHistory(true);
                refreshCtrlStatus();
            });
    }

    function renderPlayer(row, betDiamonds) {
        var online = row.INHALL === true;
        // 当前押注使用中心服报文中的实际桌台兑换比；旧中心无比率时显示 --，不把机台分标成钻。
        $('#stBet').text(diamonds(betDiamonds)).removeClass('positive negative');
        // 今日/总盈亏只显示整数（四舍五入），与玩家列表同口径
        var today = M.roundInt(row.TodayWinLoss);
        $('#stToday').text((today > 0 ? '+' : '') + today)
            .toggleClass('positive', today > 0).toggleClass('negative', today < 0);
        var total = M.roundInt(row.Profit);
        $('#stTotal').text((total > 0 ? '+' : '') + total)
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
                (Number(r.ControlMode) == 6 ? '' : ' 已' + (Number(r.ControlMode) == 5 ? '放' : '吃') + '钻 ' + diamonds(Number(r.ControlMode) == 5 ? r.GrantedCoins : r.ConsumedCoins));
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
        return '目标 ' + diamonds(targetCoins) + '钻';
    }

    function refreshCtrlStatus(quiet) {
        if (!current) return;
        var seq = querySeq, account = current.ID;
        if (!quiet) renderCtrlStatus(null);
        M.post('/Game/UserInfo/GetTotalControlStatus', { ID: current.ID })
            .then(function (res) {
                var r = M.result(res);
                if (r.ok && seq === querySeq && current && current.ID === account) renderCtrlStatus(r.datas);
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
        updateButtons();
        if (isCard) {
            fillSelect($('#ctrlCardAction'), M.playableCardActions(M.CARD_ACTIONS), true);
            fillSelect($('#ctrlCardValue'), M.cardTypeData(parseInt($('#ctrlCardAction').val(), 10)), false);
        }
    }

    /* ---------------- 应用 / 关闭 ---------------- */

    function applyControl() {
        if (!current) { M.toast('请先查询玩家信息', 'error'); return; }
        var mode = currentMode();
        var para = { ID: current.ID, Mode: mode, MobileRequest: 1 };

        if (mode == 6) {
            // 控牌按次数控制，不需要钻阈值
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
            if (!/^[1-9][0-9]*$/.test(gold) || Number(gold) > 9007199254740991) {
                M.toast('请填写大于 0 的整数钻数', 'error');
                return;
            }
            para.GoldThreshold = parseInt(gold, 10);
        }

        if (mode == 6 && (para.CardValue == 99 || (para.CardAction >= 15 && para.CardAction <= 17 && para.CardValue == 10))) { closeControl(); return; }
        if (mode == 6) {
            if (submitting) return;
            submitting = true; updateButtons(); M.loading('核算送奖金额...');
            M.post('/Game/PrizePool/CardQuote', {ID:para.ID,CardAction:para.CardAction,CardValue:para.CardValue}).always(M.hideLoading)
                .then(function (res) {
                    var r = M.result(res);
                    if (!r.ok) { M.alert(r.text, false); return; }
                    wallet = r.datas.Wallet;
                    $('#poolBalance').text(diamonds(wallet.Balance)); $('#myDiamonds').text(diamonds(wallet.Diamonds));
                    // 不再要求“送出得分 ≤ 奖池余额”：得分超过余额时开奖扣到 0 为止，奖池不出现负数；余额为 0 才拦
                    if (!(Number(wallet.Balance) > 0)) { M.alert('奖池余额不足，请充值奖池', false); return; }
                    confirmApply(para, r.datas.Quote);
                }, function () { M.toast('送奖金额读取失败，请重试', 'error'); })
                .always(function () { submitting = false; updateButtons(); });
            return;
        }
        confirmApply(para, null);
    }

    function confirmApply(para, quote) {
        var mode = para.Mode;
        if (quote && !quote.NoBet) para.ExpectedBetDiamonds = quote.BetDiamonds;
        var desc = mode == 6
            ? '对玩家 ' + para.ID + ' 执行 送奖（' + M.cardActionName(para.CardAction) +
              ' ' + M.cardTypeName(para.CardAction, para.CardValue) + '，1 次（5 把之内））？'
            : '对玩家 ' + para.ID + ' 执行 ' + modeName(mode) + '（目标 ' + diamonds(para.GoldThreshold) + '钻）？';

        if (quote && quote.NoBet) desc += '\n玩家当前未在该游戏押注，开奖时按实际押注 × ' + quote.Multiplier + '倍从奖池扣除';
        else if (quote) desc += '\n' + (quote.Estimated ? '预计送出 ' : '本次送出 ') + diamonds(quote.RequiredDiamonds) + '钻（押注 ' + diamonds(quote.BetDiamonds) + '钻 × ' + quote.Multiplier + '倍）';
        if (quote) desc += '\n奖池余额不足时扣至 0 为止';
        M.confirm(desc, '操作确认').then(function (ok) {
            if (!ok || !current || current.ID !== para.ID) return;
            if (submitting) return;
            submitting = true;
            $('#applyBtn, #closeCtrlBtn').prop('disabled', true);
            M.loading('下发中...');
            M.post('/Game/UserInfo/ApplyTotalControl', para).always(M.hideLoading).then(function (res) {
                var r = M.result(res);
                M.alert(r.ok ? (r.text || '操作成功') : r.text, r.ok, r.ok ? '操作成功' : '操作失败').then(function () {
                    if (r.ok) {
                        refreshCtrlStatus();
                        refreshWallet();
                        loadHistory(true);
                    }
                });
            }, function () {
                M.toast('操作失败，请稍后重试', 'error');
            }).always(function () {
                submitting = false;
                updateButtons();
            });
        });
    }

    function closeControl() {
        if (!current) { M.toast('请先查询玩家信息', 'error'); return; }
        var mode = currentMode();
        var target = current.ID;
        M.confirm('确认移除该玩家的' + modeName(mode) + '？', '移除控制').then(function (ok) {
            if (!ok || !current || current.ID !== target) return;
            if (submitting) return;
            submitting = true;
            $('#applyBtn, #closeCtrlBtn').prop('disabled', true);
            M.loading('处理中...');
            M.post('/Game/UserInfo/CloseTotalControl', { ID: target, Mode: mode, MobileRequest: 1 }).always(M.hideLoading).then(function (res) {
                var r = M.result(res);
                M.alert(r.ok ? (r.text || '移除成功') : r.text, r.ok, r.ok ? '移除成功' : '操作失败').then(function () {
                    if (r.ok) {
                        refreshCtrlStatus();
                        refreshWallet();
                        loadHistory(true);
                    }
                });
            }, function () {
                M.toast('操作失败，请稍后重试', 'error');
            }).always(function () {
                submitting = false;
                updateButtons();
            });
        });
    }

    /* ---------------- 奖池与送奖记录（服务端分页、真实钻口径） ---------------- */
    function refreshWallet() {
        var seq = ++walletSeq;
        return M.post('/Game/PrizePool/Wallet', {}).then(function (res) {
            var r = M.result(res);
            if (seq !== walletSeq) return;
            wallet = r.ok ? r.datas : null;
            $('#poolBalance').text(wallet ? diamonds(wallet.Balance) : '--');
            $('#myDiamonds').text(wallet ? diamonds(wallet.Diamonds) : '--');
            updateButtons();
        }, function () { if (seq === walletSeq) { wallet = null; updateButtons(); } });
    }

    function recordHtml(row) {
        var isCard = Number(row.ControlMode) === 6;
        var opened = row.AwardTime != null;
        var pending = !opened && Number(row.Status) === 0;
        var status = pending
            ? '<button type="button" class="record-remove-btn" data-control-id="' + M.esc(row.ID) +
              '" data-account="' + M.esc(row.UserID) + '" data-mode="' + M.esc(row.ControlMode) + '">移除</button>'
            : '<span class="control-record-status ' + (opened ? 'done' : '') + '">' + (opened ? '已开' : '移除') + '</span>';
        var game = row.GameName || (isCard ? M.cardActionName(row.CardAction) : modeName(row.ControlMode));
        var hand = isCard ? M.cardTypeName(row.CardAction, row.CardValue) : '--';
        var date = opened ? M.fmtTime(row.AwardTime, true) : M.fmtTime(row.CreatedTime, true);
        return '<tr><td>' + M.esc(game) + '</td><td>' + M.esc(row.UserID) + '</td><td>' + status + '</td><td>' +
            M.esc(row.TableId == null ? '--' : row.TableId) + '</td><td>' + M.esc(hand) + '</td><td>' +
            M.esc(isCard ? row.ActualCardType || '--' : '--') + '</td><td>' +
            M.esc(opened ? diamonds(row.AwardDiamonds) : '--') + '</td><td>' + M.esc(date) + '</td></tr>';
    }

    function removeRecord() {
        if (submitting) return;
        var $button = $(this), target = $button.attr('data-account');
        var controlId = Number($button.attr('data-control-id')), mode = Number($button.attr('data-mode'));
        M.confirm('确认移除玩家 ' + target + ' 的这条未开奖送奖？', '移除送奖').then(function (ok) {
            if (!ok || submitting) return;
            submitting = true; updateButtons(); M.loading('处理中...');
            M.post('/Game/PrizePool/RemoveRecord', { ID: target, Mode: mode, ControlId: controlId }).always(M.hideLoading)
                .then(function (res) {
                    var r = M.result(res);
                    M.alert(r.text || (r.ok ? '移除成功' : '移除失败'), r.ok);
                    if (r.ok) {
                        if (current && current.ID === target) refreshCtrlStatus();
                        refreshWallet();
                    }
                    loadHistory(true);
                }, function () { M.toast('移除结果暂未确认，请刷新记录后核对', 'error'); loadHistory(true); })
                .always(function () { submitting = false; updateButtons(); });
        });
    }

    /** 记录筛选的游戏：送奖模式下取“游戏类型”下拉；吃分/放水不分游戏（0 = 全部） */
    function historyCardAction() {
        return currentMode() == 6 ? (parseInt($('#ctrlCardAction').val(), 10) || 0) : 0;
    }

    /**
     * 送奖明细：本代理在所选游戏、所选日期内的全部记录（不按查询的玩家过滤）。
     * 原先按账号框过滤，账号框里残留内容时选日期点刷新看起来“没反应”。
     * quiet=true 为 10 秒轮询，不改加载提示，避免数字闪烁。
     */
    function loadHistory(reset, quiet) {
        var start = $('#controlStart').val(), end = $('#controlEnd').val();
        if (!start || !end || start > end) { M.toast('请选择有效的日期范围', 'error'); return; }
        if (!reset && historyBusy) return;
        if (reset) historyPage = 1;
        var seq = ++historySeq, page = historyPage;
        historyBusy = true;
        $('#controlMore').prop('disabled', true);
        if (reset && !quiet) {
            $('#sentDiamonds').text('加载中...');
            $('#controlCount').text('共 -- 条');
            $('#controlRows').html('<tr><td class="empty-row" colspan="8">加载中...</td></tr>');
        }
        M.post('/Game/PrizePool/Records', { CardAction: historyCardAction(), StartTime: start, EndTime: end, page: page, rows: 20 })
            .then(function (res) {
                if (seq !== historySeq) return;
                if (!res || res.rows == null) { $('#sentDiamonds').text('--'); M.toast(M.result(res).text || '送奖明细读取失败', 'error'); return; }
                var html = res.rows.map(recordHtml).join('');
                if (reset) $('#controlRows').html(html || '<tr><td class="empty-row" colspan="8">暂无送奖记录</td></tr>');
                else $('#controlRows').append(html);
                updateButtons();
                $('#sentDiamonds').text(diamonds(res.sentDiamonds));
                $('#controlCount').text('共 ' + res.total + ' 条');
                $('#controlMore').toggle(page * 20 < res.total);
                historyPage = page + 1;
            }, function () { if (seq === historySeq) { $('#sentDiamonds').text('--'); M.toast('送奖明细读取失败，请重试', 'error'); } })
            .always(function () { if (seq === historySeq) { historyBusy = false; $('#controlMore').prop('disabled', false); } });
    }

    function requestId() {
        if (window.crypto && window.crypto.randomUUID) return window.crypto.randomUUID();
        return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function (c) { var r = Math.random() * 16 | 0; return (c === 'x' ? r : (r & 3 | 8)).toString(16); });
    }

    /**
     * 充值奖池弹窗（对齐参考后台）：只有一个金额框——正数=从我的钻充值到奖池，
     * 前面加“-”=从奖池退回我的钻；仍走原 Transfer 接口（Withdraw=1 为退回），请求号防重复提交。
     */
    function rechargePool() {
        if (submitting) return;
        if (!wallet) { refreshWallet(); M.toast('请等待奖池余额读取完成', 'error'); return; }
        var amount = 0, withdraw = false, token = requestId();
        M.modal({ title: '充值奖池', bodyHTML: '<label class="pool-modal-field">充值金额 (钻石)<input id="poolAmount" class="input-field" type="text" inputmode="numeric" autocomplete="off" placeholder="正数充值，负数扣减奖池"></label><div class="pool-modal-error" id="poolAmountError"></div>',
            buttons: [{label:'取消',value:false},{label:'确认充值',type:'confirm',value:true}],
            beforeClose: function (value, $modal) {
                if (!value) return true;
                var text = $.trim($modal.find('#poolAmount').val());
                var $err = $modal.find('#poolAmountError');
                if (!/^-?[1-9][0-9]*$/.test(text)) { $err.text('请输入非 0 整数，负数表示退回我的钻'); return false; }
                withdraw = text.charAt(0) === '-';
                amount = Number(withdraw ? text.substring(1) : text);
                if (amount > 9007199254740991) { $err.text('金额过大'); return false; }
                if (amount > Number(withdraw ? wallet.Balance : wallet.Diamonds)) { $err.text(withdraw ? '奖池余额不足' : '我的钻石不足'); return false; }
                return true;
            }
        }).then(function (ok) {
            if (!ok || submitting) return;
            submitting = true; updateButtons(); M.loading(withdraw ? '退回中...' : '充值中...');
            M.post('/Game/PrizePool/Transfer', {Amount:amount,RequestId:token,Withdraw:withdraw ? 1 : 0}).always(M.hideLoading)
                .then(function (res) { var r = M.result(res); M.alert(r.ok ? (withdraw ? '已退回 ' + amount + ' 钻到我的钻石' : '奖池充值成功') : r.text, r.ok); refreshWallet(); }, function () { M.toast('充值结果暂未确认，请刷新余额后核对流水', 'error'); refreshWallet(); })
                .always(function () { submitting = false; updateButtons(); });
        });
    }

    /* ---------------- 初始化 ---------------- */

    function initPage() {
        var today = new Date(), first = new Date();
        first.setDate(today.getDate() - 6);
        function dateValue(d) { return d.getFullYear() + '-' + ('0' + (d.getMonth() + 1)).slice(-2) + '-' + ('0' + d.getDate()).slice(-2); }
        $('#controlStart').val(dateValue(first)); $('#controlEnd').val(dateValue(today));
        $('#controlRefresh').on('click', function () { loadHistory(true); refreshWallet(); });
        $('#controlMore').on('click', function () { loadHistory(false); });
        $('#controlRows').on('click', '.record-remove-btn', removeRecord);
        $('#poolRechargeBtn').on('click', rechargePool);
        refreshWallet(); // 送奖明细在 bindMode 填好游戏下拉后再读（见本函数末尾）
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
            ++querySeq; current = null; updateButtons();
            $('#stBet, #stToday, #stTotal').text('--').removeClass('positive negative');
            $('#playerMeta').removeClass('show');
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
        $('#ctrlMode').on('change', function () { bindMode(); loadHistory(true); });
        $('#ctrlCardAction').on('change', function () {
            fillSelect($('#ctrlCardValue'), M.cardTypeData(parseInt($(this).val(), 10)), false);
            loadHistory(true); // 换游戏即按新游戏刷新送奖明细
        });
        $('#applyBtn').on('click', applyControl);
        $('#closeCtrlBtn').on('click', closeControl);

        // 控制牌型在页面底部：原生 select 的列表只能向下弹、会被屏幕裁掉，换成默认向上展开的浮层
        //（牌机 11 项、水浒传 35 项都要能点到；原生 select 仍作为取值来源）
        M.upwardSelect($('#ctrlCardValue'));

        // 控制状态轮询：查询到玩家后每 10s 重拉一次进度（已吃分/剩余次数靠游戏服回写库表，
        // 不轮询就停在下发时的快照）。页面隐藏时暂停（与在线页同一口径）；
        // 独立页面离开即销毁，在途请求由 M.post 在 pagehide 统一中断，无需手动清定时器。
        setInterval(function () { if (!document.hidden) { refreshCtrlStatus(true); refreshWallet(); if (historyPage <= 2 && !historyBusy) loadHistory(true, true); } }, 10000);

        bindMode();
        if (!preset.account) loadHistory(true);
    }

    // 脚本在 body 末尾加载，DOM 已就绪；不依赖 jQuery ready
    //（部分 WebView 中 ready 之后注册的回调不会被执行）
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', initPage);
    } else {
        initPage();
    }

})(window, jQuery, window.MApp);
