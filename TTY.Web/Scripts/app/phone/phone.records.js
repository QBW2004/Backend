/* ============================================================
   充退记录页（1:1 复刻参考站 chongzhilist）
   数据源：/Game/Recharge/GetReChargeRecordsForPhone
   ============================================================ */
(function (window, $, M) {
    'use strict';

    var PAGE_SIZE = 20;
    var pageIndex = 1;
    var totalCount = 0;
    var typeFlag = 0; // 0 全部 1 充值 2 退分

    function fmtDateInput(v) {
        return v || '';
    }

    function load() {
        var start = fmtDateInput($('#startDate').val());
        var end = fmtDateInput($('#endDate').val());
        if (end) {
            var d = new Date(end);
            d.setDate(d.getDate() + 1);
            end = d.getFullYear() + '-' + M.pad2(d.getMonth() + 1) + '-' + M.pad2(d.getDate());
        }

        M.loading('加载数据中...');
        return M.post('/Game/Recharge/GetReChargeRecordsForPhone', {
            ID: $.trim($('#playerAccount').val()),
            Operator: $.trim($('#operatorAccount').val()),
            TypeFlag: typeFlag,
            srch_StartTime: start,
            srch_EndTime: end,
            page: pageIndex,
            rows: PAGE_SIZE
        }).always(M.hideLoading).then(function (res) {
            var rows = (res && res.rows) ? res.rows : [];
            totalCount = res ? Number(res.total || 0) : 0;

            var $body = $('#recordsTableBody');
            if (!rows.length) {
                $body.empty();
                $('#noData').show();
            } else {
                $('#noData').hide();
                $body.html(rows.map(function (r) {
                    var coin = Number(r.Coin || 0);
                    var isOut = Number(r.RechargeType) === 21 || Number(r.RechargeType) === 23 ||
                        (Number(r.RechargeType) === 31 && Number(r.Processed) === 1);
                    var remark = r.TypeName || '';
                    if (Number(r.Processed) === 0) remark += '（未处理）';
                    else if (Number(r.Processed) === 2) remark += '（已拒绝）';
                    return '<tr>' +
                        '<td>' + M.esc(r.Operator || '--') + '</td>' +
                        '<td>' + M.esc(r.GameID || '--') + '</td>' +
                        '<td>' + M.esc(r.UserName || '--') + '</td>' +
                        '<td class="amount ' + (isOut ? 'negative' : 'positive') + '">' + (isOut ? '-' : '+') + M.gold(coin) + '</td>' +
                        '<td class="amount">' + M.gold(r.BEF_COINS) + '</td>' +
                        '<td class="amount">' + M.gold(r.AFT_COINS) + '</td>' +
                        '<td class="time">' + M.fmtTime(r.CreateTime, true) + '</td>' +
                        '<td>' + M.esc(remark || '--') + '</td>' +
                        '</tr>';
                }).join(''));
            }

            $('#totalRecharge').text(M.gold(res ? Number(res.sumRecharge || 0) : 0));
            $('#totalWithdraw').text('-' + M.gold(res ? Number(res.sumWithdraw || 0) : 0));

            var totalPages = Math.max(1, Math.ceil(totalCount / PAGE_SIZE));
            $('#paginationInfo').text('第 ' + pageIndex + ' 页 / 共 ' + totalPages + ' 页');
            $('#prevBtn').prop('disabled', pageIndex <= 1);
            $('#nextBtn').prop('disabled', pageIndex >= totalPages);
        });
    }

    function applyFilter() {
        pageIndex = 1;
        load();
    }

    function initPage() {
        var preset = window.MPagePreset || {};
        if (preset.account) $('#playerAccount').val(preset.account);
        M.bindAccountAutocomplete({
            input: '#playerAccount',
            suggest: '#recordPlayerSuggest'
        });
        M.bindAccountAutocomplete({
            input: '#operatorAccount',
            suggest: '#recordOperatorSuggest',
            kind: 'agent'
        });
        // 类型选择
        $('.record-type-btn').on('click', function () {
            var type = $(this).data('type');
            $('.record-type-btn').removeClass('active');
            $(this).addClass('active');
            typeFlag = type === 'recharge' ? 1 : (type === 'withdraw' ? 2 : 0);
            applyFilter();
        });

        $('#filterBtn').on('click', applyFilter);
        $('#prevBtn').on('click', function () {
            if (pageIndex > 1) { pageIndex--; load(); }
        });
        $('#nextBtn').on('click', function () {
            if (pageIndex < Math.ceil(totalCount / PAGE_SIZE)) { pageIndex++; load(); }
        });

        M.onRefresh(function () {
            M.runRefresh(applyFilter);
        });

        load();
    }

    // 脚本在 body 末尾加载，DOM 已就绪；不依赖 jQuery ready
    //（部分 WebView 中 ready 之后注册的回调不会被执行）
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', initPage);
    } else {
        initPage();
    }

})(window, jQuery, window.MApp);
