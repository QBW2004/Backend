/* ============================================================
   会员盈亏页（原型 huiyuanyingkui：我的会员输赢详情）
   数据源：
     - /Game/UserInfo/GetMemberWinLoss  会员分页（今日输赢 + 总盈亏，支持排序）
     - /Game/UserInfo/GetTodayWinLoss   今日总输赢合计
   ============================================================ */
(function (window, $, M) {
    'use strict';

    var PAGE_SIZE = 20;
    var pageIndex = 1;
    var totalCount = 0;
    var sort = 'win-most';

    function load(page, append) {
        return M.post('/Game/UserInfo/GetMemberWinLoss', {
            srch_ID: '', srch_Agency: '',
            sort: sort, page: page, rows: PAGE_SIZE
        }).then(function (list) {
            var rows = (list && list.rows) ? list.rows : [];
            totalCount = list ? Number(list.total || 0) : 0;
            pageIndex = page;

            var $body = $('#memberList');
            var html = rows.map(function (u) {
                var today = Number(u.TodayWinLoss || 0);
                var profit = Number(u.Profit || 0);
                return '<tr>' +
                    '<td class="account">' + M.esc(u.ID) + '</td>' +
                    '<td>' + M.esc(u.NAME || '--') + '</td>' +
                    '<td>' + M.esc(u.AGENCY || '--') + '</td>' +
                    '<td class="' + (today >= 0 ? 'positive' : 'negative') + '">' + (today >= 0 ? '+' : '') + M.gold(today) + '</td>' +
                    '<td class="' + (profit >= 0 ? 'positive' : 'negative') + '">' + (profit >= 0 ? '+' : '') + M.gold(profit) + '</td>' +
                    '<td>' + M.gold(u.COINS) + '</td>' +
                    '</tr>';
            }).join('');
            if (!append) $body.html(html);
            else $body.append(html);

            $('#noData').toggle(!rows.length && page === 1);
            var loaded = (page - 1) * PAGE_SIZE + rows.length;
            var noMore = loaded >= totalCount;
            $('#loadMoreBtn').toggleClass('disabled', noMore).prop('disabled', noMore);
            $('#noMoreData').toggle(noMore && totalCount > 0);
            $('#totalMembers').text(totalCount);
        });
    }

    function loadStats() {
        return M.post('/Game/UserInfo/GetTodayWinLoss', {}).then(function (res) {
            var total = res && res.datas ? Number(res.datas.total || 0) : 0;
            var $el = $('#totalTodayWinLoss');
            $el.text((total > 0 ? '+' : '') + M.gold(total));
            $el.removeClass('positive negative').css('color', '');
            if (total > 0) $el.css('color', '#34c759');
            else if (total < 0) $el.css('color', '#ff3b30');
        });
    }

    function initPage() {
        $('.sort-option').on('click', function () {
            var v = $(this).data('sort');
            if (v === sort) return;
            $('.sort-option').removeClass('active');
            $(this).addClass('active');
            sort = v;
            load(1, false);
        });

        $('#loadMoreBtn').on('click', function () {
            if ($(this).hasClass('disabled')) return;
            load(pageIndex + 1, true);
        });

        M.onRefresh(function () {
            M.runRefresh(function () {
                return $.when(loadStats(), load(1, false));
            });
        });

        loadStats();
        load(1, false);
    }

    // 脚本在 body 末尾加载，DOM 已就绪；不依赖 jQuery ready
    //（部分 WebView 中 ready 之后注册的回调不会被执行）
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', initPage);
    } else {
        initPage();
    }

})(window, jQuery, window.MApp);
