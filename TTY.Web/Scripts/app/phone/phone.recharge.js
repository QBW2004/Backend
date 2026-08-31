/* ============================================================
   玩家充退页（1:1 复刻参考站 chongzhi）
   数据源：
     - /Game/UserInfo/GetVisibleUserRows  玩家余额/分数查询
     - /Game/AgencyInfo/GetAgencies       代理余额查询
     - /Game/Recharge/SaveCoin            充值 / 退分提交
   ============================================================ */
(function (window, $, M) {
    'use strict';

    var role = 'agent';       // agent=下级代理(targetType 2)  player=玩家(targetType -2)
    var payType = 'recharge'; // recharge=充值(0) withdraw=退分(1)
    var queriedAccount = '';

    function targetType() { return role === 'player' ? -2 : 2; }
    function payTypeCode() { return payType === 'withdraw' ? 1 : 0; }

    function refreshAmountUi() {
        var payLabel = payType === 'withdraw' ? '退分' : '充值';
        $('#amountLabel').text(payLabel + '金币');
        $('#amountInput').attr('placeholder', '请输入' + payLabel + '金币数量');
        $('#submitBtn').text(payLabel);
    }

    function resetQuery() {
        queriedAccount = '';
        $('#accountInfo').removeClass('show');
        $('#submitBtn').prop('disabled', true);
    }

    /* ---------------- 历史账号 ---------------- */

    function renderHistory() {
        var list = M.history.get();
        var $box = $('#historyList');
        if (!list.length) {
            $box.html('<div class="history-item" style="text-align:center;color:#999;">暂无历史记录</div>');
            return;
        }
        var html = list.map(function (acc) {
            return '<div class="history-item" data-acc="' + M.esc(acc) + '">' +
                '<span class="history-text">' + M.esc(acc) + '</span>' +
                '<span class="history-delete" data-del="' + M.esc(acc) + '">&times;</span></div>';
        }).join('');
        html += '<div class="history-clear" id="historyClear">清空历史</div>';
        $box.html(html);
    }

    /* ---------------- 查询账号 ---------------- */

    function queryAccount() {
        var acc = $.trim($('#accountInput').val());
        if (!acc) { M.toast('请输入账号', 'error'); return; }

        M.loading('查询中...');
        var dfd;
        if (role === 'player') {
            dfd = M.post('/Game/UserInfo/GetVisibleUserRows', { UserIDs: JSON.stringify([acc]) })
                .then(function (res) {
                    var row = (res && res.datas && res.datas.length) ? res.datas[0] : null;
                    return row ? { coins: Number(row.COINS || 0), score: Number(row.GAME_SCORE || 0) } : null;
                });
        } else {
            dfd = M.post('/Game/AgencyInfo/GetAgencies', { ID: acc, Agency: '', page: 1, rows: 5 })
                .then(function (list) {
                    var row = (list && list.rows && list.rows.length) ? list.rows[0] : null;
                    return row ? { coins: Number(row.COINS || 0), score: null } : null;
                });
        }

        dfd.always(M.hideLoading).then(function (info) {
            if (!info) {
                resetQuery();
                M.alert('未查询到该账号，请确认账号是否正确', false, '查询失败');
                return;
            }
            queriedAccount = acc;
            M.history.add(acc);
            $('#accountDiamond').text(M.gold(info.coins));
            $('#accountScore').text(info.score === null ? '--' : M.num(info.score));
            $('#accountInfo').addClass('show');
            $('#submitBtn').prop('disabled', false);
        });
    }

    /* ---------------- 提交 ---------------- */

    function submit() {
        var coin = $.trim($('#amountInput').val());
        if (!queriedAccount) { M.toast('请先查询账号信息', 'error'); return; }
        if (!coin || Number(coin) <= 0) { M.toast('金额不正确，不能为0', 'error'); return; }

        var payLabel = payType === 'withdraw' ? '退分' : '充值';
        M.confirm('确定要给 ' + queriedAccount + ' ' + payLabel + ' ' + M.gold(coin) + ' 金币吗？', payLabel + '确认').then(function (ok) {
            if (!ok) return;
            M.loading('处理中...');
            M.post('/Game/Recharge/SaveCoin', {
                coin: coin,
                id: queriedAccount,
                idType: 0,
                payType: payTypeCode(),
                targetType: targetType()
            }).always(M.hideLoading).then(function (res) {
                var r = M.result(res);
                M.alert(r.text, r.ok, r.ok ? '操作成功' : '操作失败').then(function () {
                    if (r.ok) {
                        $('#amountInput').val('');
                        resetQuery();
                        window.location.reload();
                    }
                });
            });
        });
    }

    /* ---------------- 初始化 ---------------- */

    function initPage() {
        refreshAmountUi();
        renderHistory();

        // 预填（从玩家列表跳转过来）
        var preset = window.MPagePreset || {};
        if (preset.role === 'agent' || preset.role === 'player') {
            role = preset.role;
            $('#roleTypeGroup .option-item').removeClass('active');
            $('#roleTypeGroup .option-item[data-value="' + role + '"]').addClass('active')
                .find('input').prop('checked', true);
        }
        if (preset.pay === '1') {
            payType = 'withdraw';
            $('#operationTypeGroup .option-item').removeClass('active');
            $('#operationTypeGroup .option-item[data-value="withdraw"]').addClass('active')
                .find('input').prop('checked', true);
            refreshAmountUi();
        }
        if (preset.account) {
            $('#accountInput').val(preset.account);
            queryAccount();
        }

        // 角色类型切换
        $('#roleTypeGroup .option-item').on('click', function () {
            var v = $(this).data('value');
            if (v === role) return;
            $('#roleTypeGroup .option-item').removeClass('active');
            $(this).addClass('active').find('input').prop('checked', true);
            role = v;
            resetQuery();
        });

        // 操作类型切换
        $('#operationTypeGroup .option-item').on('click', function () {
            var v = $(this).data('value');
            if (v === payType) return;
            $('#operationTypeGroup .option-item').removeClass('active');
            $(this).addClass('active').find('input').prop('checked', true);
            payType = v;
            refreshAmountUi();
        });

        // 历史下拉
        M.bindAccountAutocomplete({
            input: '#accountInput',
            suggest: '#accountSuggest',
            kind: function () { return role === 'player' ? 'player' : 'agent'; },
            onInput: function () { $('#historyList').removeClass('show'); },
            onSelect: function (row) {
                $('#historyList').removeClass('show');
                $('#accountInput').val(row.ID);
                queryAccount();
            }
        });
        $('#accountInput').on('focus', function () {
            renderHistory();
            $('#historyList').addClass('show');
        });
        $(document).on('click', function (e) {
            if (!$(e.target).closest('.history-dropdown').length) {
                $('#historyList').removeClass('show');
            }
        });
        $('#historyList').on('click', '.history-item', function (e) {
            if ($(e.target).hasClass('history-delete')) return;
            var acc = $(this).data('acc');
            if (!acc) return;
            $('#accountInput').val(String(acc));
            $('#historyList').removeClass('show');
        });
        $('#historyList').on('click', '.history-delete', function (e) {
            e.stopPropagation();
            M.history.remove(String($(this).data('del')));
            renderHistory();
        });
        $('#historyList').on('click', '.history-clear', function () {
            M.history.clear();
            renderHistory();
        });

        $('#queryBtn').on('click', queryAccount);
        $('#accountInput').on('keydown', function (e) {
            if (e.keyCode === 13) { e.preventDefault(); queryAccount(); }
        });
        $('#submitBtn').on('click', submit);
    }

    // 脚本在 body 末尾加载，DOM 已就绪；不依赖 jQuery ready
    //（部分 WebView 中 ready 之后注册的回调不会被执行）
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', initPage);
    } else {
        initPage();
    }

})(window, jQuery, window.MApp);
