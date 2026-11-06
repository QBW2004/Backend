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
    // 当前玩家执行中的控制类型（4 吃分 / 5 放水 / 6 送奖），来自“当前控制”状态；“移除”按钮据此移除
    var activeModes = [];
    // 奖池余额/我的钻石/送奖明细只在有送奖或放水权限时渲染（Control.cshtml 的 showPool）
    var hasPool = $('#controlRows').length > 0;

    function diamonds(value) {
        var n = Number(value);
        return value == null || !isFinite(n) ? "--" : n.toFixed(8).replace(/\.?0+$/, "");
    }

    function updateButtons() {
        var canApply = !!current && !submitting && (currentMode() == 4 || !!wallet);
        $("#applyBtn").prop("disabled", !canApply);
        // 没有执行中的控制时“移除”置灰：移除只针对当前控制里实际在跑的那几种，不看操作类型下拉
        $("#closeCtrlBtn").prop("disabled", !current || submitting || !activeModes.length);
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
     * 查到玩家后按状态预选操作类型（2026-11-04 调整，吃分已拆到黑名单管理页）：
     * - 在线且正在可送奖（控牌）的游戏里 → 送奖 + 该游戏；
     * - 在线但不在控牌游戏（大厅/鱼机/押注等）→ 放水；
     * - 离线 → 送奖（控牌），不识别所在游戏，游戏类型保持下拉默认项。
     * 没有对应权限时退回下拉第一项（只有一个权限时就只有那一项）。预选后仍可手动修改。
     */
    function presetMode(row, gameId) {
        var online = !!row && row.INHALL === true;
        var action = online ? M.cardActionOfGame(gameId) : 0;
        var playable = action > 0 && $.grep(M.playableCardActions(M.CARD_ACTIONS), function (a) { return a.id == action; }).length > 0;
        var want = !online ? 6 : (playable ? 6 : 5);
        var mode = hasMode(want) ? want : parseInt($('#ctrlMode option:first').val() || '0', 10);
        $('#ctrlMode').val(String(mode));
        bindMode();
        if (mode == 6 && online && playable) {
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
        $('#piOnline').empty();
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
        // 在线状态显示在“送奖账号”标签后面：送奖账号 在线（不带冒号，靠左间距隔开；原“在线状态”一行已去掉）
        $('#piOnline').text(online ? '在线' : '离线').attr('class', 'account-status ' + (online ? 'status-online' : 'status-offline'));
        $('#statCards, #playerMeta').addClass('show');
        $('#ctrlParams').addClass('show');
    }

    /* ---------------- 当前控制状态 ---------------- */

    function renderCtrlStatus(rows) {
        var $el = $('#piControl');
        activeModes = [];
        $.each(rows || [], function (i, r) {
            var m = Number(r.ControlMode);
            // 只收本页能操作的类型（送奖/放水）；吃分 2026-11-04 起在“黑名单管理”页移除
            if (hasMode(m) && activeModes.indexOf(m) < 0) activeModes.push(m);
        });
        updateButtons();
        if (!rows || !rows.length) {
            $el.attr('class', 'info-value').empty();
            return;
        }
        var items = rows.map(function (r) {
            var m = Number(r.ControlMode);
            var text = ctrlParamText(r.ControlMode, r.GameId, r.LimitCoins, r.TargetCoins, r.CardNumber, r.CardTotal) +
                (m == 6 ? '' : ' 已' + (m == 5 ? '放' : '吃') + '钻 ' + diamonds(m == 5 ? r.GrantedCoins : r.ConsumedCoins));
            // 吃分已拆到黑名单管理（2026-11-04）：本页只标明类型，不再提示去黑名单管理（按需求去掉该提示文字）
            if (m == 4) text = '吃分 ' + text;
            return text;
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
        // quiet（静默刷新）失败静默，不弹通用“网络异常”（2026-11-04）
        M.post('/Game/UserInfo/GetTotalControlStatus', { ID: current.ID }, { silent: !!quiet })
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

        // 2026-11-04 需求：点“应用控制”直接下发，不再弹“操作确认”。
        // 送奖仍先核算报价（带上 ExpectedBetDiamonds 供服务端校验押注未变），奖池余额为 0 才拦。
        if (submitting) return;
        submitting = true;
        updateButtons();
        var ready;
        if (mode == 6) {
            // 2026-11-04：不再显示“核算送奖金额/下发中”等过程提示，按钮置灰防连点，结果直接弹“操作成功”
            ready = M.post('/Game/PrizePool/CardQuote', { ID: para.ID, CardAction: para.CardAction, CardValue: para.CardValue })
                .then(function (res) {
                    var r = M.result(res);
                    if (!r.ok) { M.alert(r.text, false); return false; }
                    wallet = r.datas.Wallet;
                    $('#poolBalance').text(diamonds(wallet.Balance)); $('#myDiamonds').text(diamonds(wallet.Diamonds));
                    // 不再要求“送出得分 ≤ 奖池余额”：得分超过余额时开奖扣到 0 为止，奖池不出现负数；余额为 0 才拦
                    if (!(Number(wallet.Balance) > 0)) { M.alert('奖池余额不足，请充值奖池', false); return false; }
                    var quote = r.datas.Quote;
                    if (quote && !quote.NoBet) para.ExpectedBetDiamonds = quote.BetDiamonds;
                    return true;
                }, function () { M.toast('送奖金额读取失败，请重试', 'error'); });
        } else {
            ready = $.Deferred().resolve(true).promise();
        }
        ready.then(function (go) {
            if (!go || !current || current.ID !== para.ID) return;
            return M.post('/Game/UserInfo/ApplyTotalControl', para).then(function (res) {
                var r = M.result(res);
                // 成功统一只提示“操作成功”（服务端“已保存，等待游戏同步”等过程文案不展示）；失败仍显示原因
                M.alert(r.ok ? '操作成功' : r.text, r.ok, r.ok ? '操作成功' : '操作失败').then(function () {
                    if (r.ok) {
                        refreshCtrlStatus();
                        refreshWallet();
                        loadHistory(true);
                    }
                });
            }, function () {
                M.toast('操作失败，请稍后重试', 'error');
            });
        }).always(function () {
            submitting = false;
            updateButtons();
        });
    }

    /**
     * 移除当前控制（2026-11-04）：点“移除”直接移除，不弹确认框，结果弹窗与送奖明细的“移除”一致。
     * 移除的是“当前控制”里实际执行中的控制（可能同时有吃分和送奖，逐个移除），不再按“操作类型”下拉的选中项——
     * 下拉被预选成别的类型时，原写法会移掉代理并不想移的那种控制，或者提示失败而真正在跑的仍在跑。
     */
    function closeControl() {
        if (!current) { M.toast('请先查询玩家信息', 'error'); return; }
        if (!activeModes.length) { M.toast('该玩家当前没有执行中的控制', 'error'); return; }
        var target = current.ID, modes = activeModes.slice();
        if (submitting) return;
        submitting = true;
        $('#applyBtn, #closeCtrlBtn').prop('disabled', true);
        M.loading('处理中...');
        var failText = null, anyOk = false;
        var chain = $.Deferred().resolve().promise();
        $.each(modes, function (i, mode) {
            chain = chain.then(function () {
                return M.post('/Game/UserInfo/CloseTotalControl', { ID: target, Mode: mode, MobileRequest: 1 }).then(function (res) {
                    var r = M.result(res);
                    if (r.ok) anyOk = true; else if (!failText) failText = r.text || '移除失败';
                }, function () {
                    if (!failText) failText = '操作失败，请稍后重试';
                    return $.Deferred().resolve().promise(); // 一种失败不影响移除下一种
                });
            });
        });
        chain.always(function () {
            M.hideLoading();
            if (failText) M.alert(failText, false, '移除失败');
            else M.alert('移除成功', true, '移除成功');
            if (anyOk) {
                refreshCtrlStatus();
                refreshWallet();
                loadHistory(true);
            }
            submitting = false;
            updateButtons();
        });
    }

    /* ---------------- 奖池与送奖记录（服务端分页、真实钻口径） ---------------- */
    /** quiet=true：静默刷新（失败不提示，并保留上次余额，不把“确定”按钮置灰） */
    function refreshWallet(quiet) {
        if (!hasPool) { wallet = null; return $.Deferred().resolve().promise(); }
        var seq = ++walletSeq;
        return M.post('/Game/PrizePool/Wallet', {}, { silent: !!quiet }).then(function (res) {
            var r = M.result(res);
            if (seq !== walletSeq) return;
            wallet = r.ok ? r.datas : null;
            $('#poolBalance').text(wallet ? diamonds(wallet.Balance) : '--');
            $('#myDiamonds').text(wallet ? diamonds(wallet.Diamonds) : '--');
            updateButtons();
        }, function () { if (seq === walletSeq && !quiet) { wallet = null; updateButtons(); } });
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
        // 2026-11-04 对齐参考站：先确认“确定要移除玩家 X 的送奖记录吗？”，确定后移除并弹“移除成功”
        //（服务端回“关闭成功！”等文案不直接展示）
        M.confirm('确定要移除玩家 ' + target + ' 的送奖记录吗？', '移除送奖').then(function (ok) {
            if (!ok || submitting) return;
            submitting = true; updateButtons(); M.loading('处理中...');
            M.post('/Game/PrizePool/RemoveRecord', { ID: target, Mode: mode, ControlId: controlId }).always(M.hideLoading)
                .then(function (res) {
                    var r = M.result(res);
                    M.alert(r.ok ? '移除成功' : (r.text || '移除失败'), r.ok, r.ok ? '移除成功' : '移除失败');
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
     * quiet=true 为静默刷新，不改加载提示，避免数字闪烁。
     */
    function loadHistory(reset, quiet) {
        if (!hasPool) return;
        var start = $('#controlStart').val(), end = $('#controlEnd').val();
        if (!start || !end || start > end) { M.toast('请选择有效的时间范围', 'error'); return; }
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
        // quiet（静默刷新）失败静默并保留现有明细，不弹“网络异常/读取失败”（2026-11-04）
        M.post('/Game/PrizePool/Records', { CardAction: historyCardAction(), StartTime: start, EndTime: end, page: page, rows: 20 }, { silent: !!quiet })
            .then(function (res) {
                if (seq !== historySeq) return;
                if (!res || res.rows == null) { if (quiet) return; $('#sentDiamonds').text('--'); M.toast(M.result(res).text || '送奖明细读取失败', 'error'); return; }
                var html = res.rows.map(recordHtml).join('');
                if (reset) $('#controlRows').html(html || '<tr><td class="empty-row" colspan="8">暂无送奖记录</td></tr>');
                else $('#controlRows').append(html);
                updateButtons();
                $('#sentDiamonds').text(diamonds(res.sentDiamonds));
                $('#controlCount').text('共 ' + res.total + ' 条');
                $('#controlMore').toggle(page * 20 < res.total);
                historyPage = page + 1;
            }, function () { if (seq === historySeq && !quiet) { $('#sentDiamonds').text('--'); M.toast('送奖明细读取失败，请重试', 'error'); } })
            .always(function () { if (seq === historySeq) { historyBusy = false; $('#controlMore').prop('disabled', false); } });
    }

    function requestId() {
        if (window.crypto && window.crypto.randomUUID) return window.crypto.randomUUID();
        return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function (c) { var r = Math.random() * 16 | 0; return (c === 'x' ? r : (r & 3 | 8)).toString(16); });
    }

    /** 金额文本归一：全角数字转半角，再去掉所有非数字字符（金额框只允许输入数字）。 */
    function digitsOnly(text) {
        return String(text == null ? '' : text)
            .replace(/[\uFF10-\uFF19]/g, function (c) { return String.fromCharCode(c.charCodeAt(0) - 0xFEE0); })
            .replace(/[^0-9]/g, '');
    }

    /**
     * 充值奖池弹窗：一个只能输数字的金额框 + 底部“充值”（蓝，我的钻 → 奖池）/“提取”（红，奖池 → 我的钻）两个按钮。
     * 仍走原 Transfer 接口（Withdraw=1 为提取），请求号防重复提交。
     * 2026-11-06：手机数字键盘没有“-”键，取消“负数=扣减”的输入方式，改为两个按钮区分方向（按运营确认）。
     */
    function rechargePool() {
        if (submitting) return;
        if (!wallet) { refreshWallet(); M.toast('请等待奖池余额读取完成', 'error'); return; }
        var amount = 0, withdraw = false, token = requestId();
        // 2026-11-04 需求：标题左右居中、不展示取消按钮（不操作时点遮罩关闭）
        M.modal({ title: '充值奖池', bodyHTML: '<label class="pool-modal-field">金额 (钻石)<input id="poolAmount" class="input-field" type="text" inputmode="numeric" pattern="[0-9]*" autocomplete="off" placeholder="请输入整数钻数"></label><div class="pool-modal-error" id="poolAmountError"></div>',
            buttons: [{label:'充值',type:'confirm pool-in-btn',value:'in'},{label:'提取',type:'pool-out-btn',value:'out'}],
            onRender: function ($modal) {
                $modal.addClass('pool-modal');
                var $input = $modal.find('#poolAmount');
                $input.on('input change', function () {
                    var v = digitsOnly($input.val());
                    if (v !== $input.val()) $input.val(v);
                    $modal.find('#poolAmountError').text('');
                });
            },
            beforeClose: function (value, $modal) {
                if (!value) return true;
                var text = digitsOnly($modal.find('#poolAmount').val());
                var $err = $modal.find('#poolAmountError');
                if (!/^[1-9][0-9]*$/.test(text)) { $err.text('请输入大于 0 的整数钻数'); return false; }
                withdraw = value === 'out';
                amount = Number(text);
                if (amount > 9007199254740991) { $err.text('金额过大'); return false; }
                if (amount > Number(withdraw ? wallet.Balance : wallet.Diamonds)) { $err.text(withdraw ? '奖池余额不足，当前奖池 ' + diamonds(wallet.Balance) + ' 钻' : '我的钻石不足，当前 ' + diamonds(wallet.Diamonds) + ' 钻'); return false; }
                return true;
            }
        }).then(function (choice) {
            if (!choice || submitting) return;
            submitting = true; updateButtons(); M.loading(withdraw ? '提取中...' : '充值中...');
            M.post('/Game/PrizePool/Transfer', {Amount:amount,RequestId:token,Withdraw:withdraw ? 1 : 0}).always(M.hideLoading)
                .then(function (res) { var r = M.result(res); M.alert(r.ok ? (withdraw ? '已从奖池提取 ' + amount + ' 钻到我的钻石' : '奖池充值成功') : r.text, r.ok); refreshWallet(); }, function () { M.toast((withdraw ? '提取' : '充值') + '结果暂未确认，请刷新余额后核对流水', 'error'); refreshWallet(); })
                .always(function () { submitting = false; updateButtons(); });
        });
    }

    /* ---------------- 初始化 ---------------- */

    function initPage() {
        // 默认当天：开始今天 00:00、结束今天 23:59（日期+时分字段，2026-11-04）
        // 先升级字段再赋值：原生 date 框会把带时分的值当非法值清空
        M.dateTimeField($('#controlStart'), '00:00');
        M.dateTimeField($('#controlEnd'), '23:59');
        $('#controlStart').val(M.todayValue() + ' 00:00').trigger('change');
        $('#controlEnd').val(M.todayValue() + ' 23:59').trigger('change');
        $('#controlRefresh').on('click', function () { loadHistory(true); refreshWallet(); refreshCtrlStatus(true); });
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
            $('#piOnline').empty();
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

        // 2026-11-04：去掉每 10 秒自动轮询（对齐参考站）。进度/余额/明细在进页、查询、下发、移除后刷新，
        // 送奖明细的“刷新”按钮同时重拉当前控制状态，需要看最新进度时点一下即可。

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
