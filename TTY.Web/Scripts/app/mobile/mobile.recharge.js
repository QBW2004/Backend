/* ============================================================
   手机端 - 玩家/代理充退
   查询：/Game/Recharge/QueryCoins（id, idType=0, targetType）
   提交：/Game/Recharge/SaveCoin（coin, id, idType=0, payType, targetType）
   两个接口都需要防伪令牌，MApp.post 已自动附带。
   targetType: -2 玩家 / 2 一般代理 / 1 总代；payType: 0 充值 / 1 兑换
   ============================================================ */
(function (window, $) {
    'use strict';

    var M = window.MApp;
    var P = window.MPage || {};

    var state = {
        targetType: P.presetTarget || '-2',
        payType: P.presetPay || '0',
        queried: null,      // { account, coins, score }
        ownCoins: Number(P.ownCoins || 0)
    };

    /* ---------------- 顶栏余额 ---------------- */

    function renderSubtitle() {
        $('#mSubtitle').html('<span>我的金币</span><span class="m-coins">' + M.gold(state.ownCoins) + '</span>');
    }

    /* ---------------- 文案随操作类型变化 ---------------- */

    function isExchange() {
        return state.payType === '1';
    }

    function targetName() {
        if (state.targetType === '-2') return '玩家';
        if (state.targetType === '1') return '总代';
        return '代理';
    }

    function renderTexts() {
        var word = isExchange() ? '兑换' : '充值';
        $('#mRcAmountLabel').text(word + '金额');
        $('#mRcAmount').attr('placeholder', '请输入' + word + '数量');
        $('#mRcSubmit').text(word);
        $('#mRcTip').html('&#9432; 请先查询' + targetName() + '账号信息，确认无误后再' + word + '。');
    }

    /* ---------------- 查询 ---------------- */

    function resetQuery() {
        state.queried = null;
        $('#mRcInfo').removeClass('show');
        $('#mRcSubmit').prop('disabled', true);
    }

    function query() {
        var account = $.trim($('#mRcAccount').val());
        if (!account) {
            M.toast('请输入账号', 'error');
            return;
        }
        M.loading('查询中...');
        M.post('/Game/Recharge/QueryCoins', {
            id: account,
            idType: 0,
            targetType: state.targetType
        }).always(M.hideLoading).then(function (res) {
            var r = M.result(res);
            if (!r.ok) {
                resetQuery();
                M.toast(r.text, 'error');
                return;
            }
            // QueryTargetCoins 返回 { id, title, coins, displayCoins }
            var d = r.datas || {};
            var coins = Number(d.coins || 0);

            state.queried = { account: account, coins: coins, title: d.title || '' };
            $('#mRcInfoAccount').text(d.id || account);
            $('#mRcInfoTitle').text(d.title || targetName());
            $('#mRcInfoCoins').text(M.gold(coins));
            $('#mRcInfo').addClass('show');
            $('#mRcSubmit').prop('disabled', false);
            M.history.add(account);
            M.toast('查询成功', 'success', 1200);
        });
    }

    /* ---------------- 提交 ---------------- */

    function submit() {
        if (!state.queried) {
            M.toast('请先查询账号', 'error');
            return;
        }
        var account = $.trim($('#mRcAccount').val());
        if (account !== state.queried.account) {
            resetQuery();
            M.toast('账号已修改，请重新查询', 'error');
            return;
        }

        var amount = parseInt($('#mRcAmount').val(), 10);
        if (isNaN(amount) || amount <= 0) {
            M.toast('请输入有效金额', 'error');
            return;
        }

        var word = isExchange() ? '兑换' : '充值';
        var confirmText = '确定为' + targetName() + ' ' + account + ' ' + word + ' ' + M.num(amount) + ' 吗？';

        M.confirm(confirmText, word + '确认').then(function (ok) {
            if (!ok) return;
            var $btn = $('#mRcSubmit').prop('disabled', true).text('处理中...');
            M.loading(word + '中...');

            M.post('/Game/Recharge/SaveCoin', {
                coin: amount,
                id: account,
                idType: 0,
                payType: state.payType,
                targetType: state.targetType
            }).always(function () {
                M.hideLoading();
                $btn.prop('disabled', false).text(word);
            }).then(function (res) {
                var r = M.result(res);
                if (!r.ok) {
                    M.alert(r.text, false, word + '失败');
                    return;
                }
                $('#mRcAmount').val('');
                // 本地同步余额，随后再向后端确认一次
                state.ownCoins += isExchange() ? amount : -amount;
                renderSubtitle();
                M.alert(r.text || (word + '成功'), true).then(function () {
                    query();
                });
            });
        });
    }

    /* ---------------- 账号历史 ---------------- */

    function renderHistory() {
        var list = M.history.get();
        var $box = $('#mRcHistory');
        if (!list.length) {
            $box.addClass('m-hidden').empty();
            return;
        }
        var html = [];
        for (var i = 0; i < list.length; i++) {
            html.push('<div class="m-history-item"><span class="m-history-pick" data-account="' + M.esc(list[i]) + '">' +
                M.esc(list[i]) + '</span><button type="button" class="m-history-del" data-account="' + M.esc(list[i]) + '">删除</button></div>');
        }
        html.push('<div class="m-history-clear" id="mRcHistoryClear">清空历史</div>');
        $box.removeClass('m-hidden').html(html.join(''));
    }

    /* ---------------- 绑定 ---------------- */

    $(function () {
        renderSubtitle();
        renderTexts();

        $('#mRoleGroup').on('click', '.m-segment-item', function () {
            var $i = $(this);
            $('#mRoleGroup .m-segment-item').removeClass('active');
            $i.addClass('active');
            state.targetType = String($i.data('val'));
            resetQuery();
            renderTexts();
        });

        $('#mPayGroup').on('click', '.m-segment-item', function () {
            var $i = $(this);
            $('#mPayGroup .m-segment-item').removeClass('active');
            $i.addClass('active');
            state.payType = String($i.data('val'));
            resetQuery();
            renderTexts();
        });

        $('#mRcAccount')
            .on('focus', function () { renderHistory(); })
            .on('blur', function () {
                setTimeout(function () { $('#mRcHistory').addClass('m-hidden'); }, 200);
            })
            .on('input', resetQuery)
            .on('keydown', function (e) {
                if (e.keyCode === 13) { e.preventDefault(); query(); }
            });

        $('#mRcHistory')
            .on('click', '.m-history-pick', function () {
                $('#mRcAccount').val($(this).data('account'));
                $('#mRcHistory').addClass('m-hidden');
                resetQuery();
            })
            .on('click', '.m-history-del', function (e) {
                e.stopPropagation();
                M.history.remove($(this).data('account'));
                renderHistory();
            })
            .on('click', '#mRcHistoryClear', function () {
                M.history.clear();
                renderHistory();
            });

        $('#mRcAmount').on('input', function () {
            this.value = this.value.replace(/[^\d]/g, '');
        });

        $('#mRcQueryBtn').on('click', query);
        $('#mRcSubmit').on('click', submit);

        // 从玩家/代理列表跳转过来时自动查询
        if (P.presetAccount) {
            query();
        }
    });

})(window, jQuery);
