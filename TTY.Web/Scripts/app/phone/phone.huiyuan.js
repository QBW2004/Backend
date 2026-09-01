/* ============================================================
   会员盈亏详情页
   数据源：
     - /Game/UserInfo/GetMemberWinLossStats  统计卡（总盈亏/总充值/总退钻、今日盈亏/今日充值/今日退钻）
     - /Game/UserInfo/GetMemberWinLoss       会员分页（按总盈亏排序）
   支持手机端"我的代理-我的会员-查看"跳转：
     ?agency=xxx  仅显示该代理的直属会员（头部副标题同步显示 代理名- 会员总数N）
   ============================================================ */
(function (window, $, M) {
    'use strict';

    var PAGE_SIZE = 20;
    var pageIndex = 1;
    var totalCount = 0;
    var sort = 'profit-desc';
    var agencyFilter = '';

    /* 统计卡单项：退钻类(asNegative)以负数展示；盈亏类(colorBySign)按正负着色 */
    function setStat(sel, value, colorBySign, asNegative) {
        var n = Number(value || 0);
        if (asNegative) n = -n;
        var $el = $(sel);
        $el.text(M.gold(n));
        $el.removeClass('positive negative');
        if (colorBySign) {
            if (n > 0) $el.addClass('positive');
            else if (n < 0) $el.addClass('negative');
        }
    }

    function load(page, append) {
        return M.post('/Game/UserInfo/GetMemberWinLoss', {
            srch_ID: '', srch_Agency: agencyFilter,
            sort: sort, page: page, rows: PAGE_SIZE
        }).then(function (list) {
            var rows = (list && list.rows) ? list.rows : [];
            totalCount = list ? Number(list.total || 0) : 0;
            pageIndex = page;
            $('#memberTotal').text(totalCount);

            var $body = $('#memberList');
            var html = rows.map(function (u) {
                var profit = Number(u.Profit || 0);
                var back = Number(u.COINS_BACK || 0);
                return '<tr>' +
                    '<td class="account"><a href="/Mobile/Home/PlayerDetail?id=' + encodeURIComponent(u.ID) + '">' + M.esc(u.ID) + '</a></td>' +
                    '<td>' + M.gold(u.COINS) + '</td>' +
                    '<td>' + M.num(u.GAME_SCORE) + '</td>' +
                    '<td class="' + M.signClass(profit) + '">' + M.signed(profit) + '</td>' +
                    '<td>' + M.gold(u.COINS_BUY) + '</td>' +
                    '<td>' + (back > 0 ? '-' + M.gold(back) : '0') + '</td>' +
                    '</tr>';
            }).join('');
            if (!append) $body.html(html);
            else $body.append(html);

            $('#noData').toggle(!rows.length && page === 1);
            var loaded = (page - 1) * PAGE_SIZE + rows.length;
            var noMore = loaded >= totalCount;
            $('#loadMoreBtn').toggleClass('disabled', noMore).prop('disabled', noMore);
            $('#noMoreData').toggle(noMore && totalCount > 0);
        });
    }

    function loadStats() {
        return M.post('/Game/UserInfo/GetMemberWinLossStats', { srch_Agency: agencyFilter })
            .then(function (res) {
                if (!res || res.code !== 1 || !res.datas) return;
                setStat('#totalProfit', res.datas.TotalProfit, true, false);
                setStat('#totalBuy', res.datas.TotalBuy, false, false);
                setStat('#totalBack', res.datas.TotalBack, false, true);
                setStat('#todayProfit', res.datas.TodayProfit, true, false);
                setStat('#todayBuy', res.datas.TodayBuy, false, false);
                setStat('#todayBack', res.datas.TodayBack, false, true);
            });
    }

    function initPage() {
        // 从"我的代理-我的会员-查看"跳转过来：按代理过滤直属会员
        try {
            var q = new URLSearchParams(window.location.search);
            agencyFilter = $.trim(q.get('agency') || '');
        } catch (e) {
            agencyFilter = '';
        }
        if (agencyFilter) {
            $('#agencyFilterName').text(agencyFilter);
            $('#agencyFilterBar').addClass('show');
        }
        $('#agencyFilterClear').on('click', function () {
            agencyFilter = '';
            $('#agencyFilterBar').removeClass('show');
            loadStats();
            load(1, false);
        });

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
