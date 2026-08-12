/* ============================================================
   手机端 - 充退记录
   数据：/Game/AgencyRecord/GetAgencyRecords（ID / OPT / TIME / page / rows）
   OPT: -1 全部 / 0 充值 / 1 兑换 / 2 登录 / 3 退出
   ============================================================ */
(function (window, $) {
    'use strict';

    var M = window.MApp;

    var PAGE_SIZE = 20;

    var state = {
        opt: '-1',
        page: 1,
        total: 0,
        loading: false
    };

    /**
     * AgencyOptLog.OPT 的实际取值（见 B_Recharge.AddAgentOptLog：OPT = RechargeType + 20）：
     *   2 登录、3 退出、20 充值、21 兑换、22 赠送、23 扣币
     * 0 / 1 是历史遗留数据，一并兼容。
     */
    var OPT_TEXT = { '0': '充值', '1': '兑换', '2': '登录', '3': '退出', '20': '充值', '21': '兑换', '22': '赠送', '23': '扣币' };
    var OPT_CLASS = { '0': 'ok', '1': 'remove', '2': 'info', '3': 'warn', '20': 'ok', '21': 'remove', '22': 'ok', '23': 'remove' };
    // 进账（对方金币增加）
    var OPT_IN = { '0': 1, '20': 1, '22': 1 };
    // 出账（对方金币减少）
    var OPT_OUT = { '1': 1, '21': 1, '23': 1 };

    function optTag(opt) {
        var key = String(opt);
        var text = OPT_TEXT[key] || '--';
        var cls = OPT_CLASS[key] || 'info';
        return '<span class="m-row-btn ' + cls + '">' + text + '</span>';
    }

    function row(r) {
        var key = String(Number(r.OPT));
        var isIn = OPT_IN[key] === 1;
        var isOut = OPT_OUT[key] === 1;
        var isMoney = isIn || isOut;
        var amount = Number(r.COINS || 0);
        var amountHtml = isMoney
            ? '<span class="m-amount ' + (isIn ? 'positive' : 'negative') + '">' +
                  (isIn ? '+' : '-') + M.gold(amount) + '</span>'
            : '<span class="m-muted">--</span>';

        return '<tr>' +
            '<td class="m-muted">' + M.esc(M.fmtTime(r.REC_TIME_Str || r.REC_TIME, true)) + '</td>' +
            '<td>' + optTag(r.OPT) + '</td>' +
            '<td>' + M.esc(r.OptID || '--') + '<div class="m-info-label">' + M.esc(r.SrcUserTitle || '') + '</div></td>' +
            '<td>' + M.esc(r.ID || '--') + '<div class="m-info-label">' + M.esc(r.DestUserTitle || '') + '</div></td>' +
            '<td>' + amountHtml + '</td>' +
            '<td class="m-amount">' + M.gold(r.BEF_COINS) + '</td>' +
            '<td class="m-amount">' + (isMoney ? M.gold(r.AFT_COINS) : '<span class="m-muted">--</span>') + '</td>' +
            '</tr>';
    }

    function render(rows) {
        var $body = $('#mRecBody');
        if (!rows.length) {
            $body.html('<tr><td colspan="7" class="m-empty">当天没有符合条件的记录</td></tr>');
        } else {
            var html = [];
            var sumIn = 0, sumOut = 0;
            for (var i = 0; i < rows.length; i++) {
                html.push(row(rows[i]));
                var key = String(Number(rows[i].OPT));
                if (OPT_IN[key] === 1) sumIn += Number(rows[i].COINS || 0);
                else if (OPT_OUT[key] === 1) sumOut += Number(rows[i].COINS || 0);
            }
            $body.html(html.join(''));
            $('#mRecSumIn').text('+' + M.gold(sumIn));
            $('#mRecSumOut').text('-' + M.gold(sumOut));
        }
        if (!rows.length) {
            $('#mRecSumIn').text('0');
            $('#mRecSumOut').text('0');
        }

        var totalPages = Math.max(1, Math.ceil(state.total / PAGE_SIZE));
        $('#mRecTotal').text(state.total);
        $('#mRecPageInfo').text('第 ' + state.page + ' 页 / 共 ' + totalPages + ' 页');
        $('#mRecPrev').prop('disabled', state.page <= 1);
        $('#mRecNext').prop('disabled', state.page >= totalPages);
    }

    function load() {
        if (state.loading) return $.Deferred().resolve().promise();
        state.loading = true;

        var date = $('#mRecDate').val();
        if (!date) {
            date = M.fmtDate(new Date());
            $('#mRecDate').val(date);
        }

        return M.post('/Game/AgencyRecord/GetAgencyRecords', {
            ID: $.trim($('#mRecId').val()),
            OPT: state.opt,
            TIME: date,
            page: state.page,
            rows: PAGE_SIZE
        }).then(function (res) {
            state.total = Number(res && res.total ? res.total : 0);
            render((res && res.rows) ? res.rows : []);
        }, function () {
            render([]);
        }).always(function () {
            state.loading = false;
        });
    }

    $(function () {
        $('.m-chips').on('click', '.m-chip', function () {
            var $c = $(this);
            $('.m-chips .m-chip').removeClass('active');
            $c.addClass('active');
            state.opt = String($c.data('opt'));
            state.page = 1;
            load();
        });

        $('#mRecQuery').on('click', function () {
            state.page = 1;
            load();
        });

        $('#mRecPrev').on('click', function () {
            if (state.page > 1) { state.page--; load(); }
        });

        $('#mRecNext').on('click', function () {
            state.page++;
            load();
        });

        $('#mRefreshBtn').on('click', function () {
            M.runRefresh(load);
        });

        load();
    });

})(window, jQuery);
