/* ============================================================
   我的代理页（1:1 复刻参考站 wodedaili）
   数据源：/Game/AgencyInfo/GetAgencies
   交互：面包屑逐级下钻、按账号/邀请码搜索
   ============================================================ */
(function (window, $, M) {
    'use strict';

    var FETCH_ROWS = 500;
    var crumbs = [{ id: '', name: '所有代理' }];
    var allCache = null; // 权限范围内全量代理（邀请码搜索用）

    /* ---------------- 数据 ---------------- */

    function fetchAgencies(query) {
        return M.post('/Game/AgencyInfo/GetAgencies', $.extend({ ID: '', Agency: '', page: 1, rows: FETCH_ROWS }, query || {}));
    }

    function fetchAllOnce() {
        if (allCache) return $.Deferred().resolve(allCache).promise();
        return fetchAgencies({}).then(function (list) {
            allCache = (list && list.rows) ? list.rows : [];
            return allCache;
        }, function () { return []; });
    }

    /* ---------------- 渲染 ---------------- */

    function renderBreadcrumb() {
        var html = crumbs.map(function (c, i) {
            var last = i === crumbs.length - 1;
            return '<a class="breadcrumb-item' + (last ? ' breadcrumb-current' : '') + '" data-index="' + i + '" data-id="' + M.esc(c.id) + '">' +
                M.esc(c.name) + '</a>' + (last ? '' : '<span class="breadcrumb-separator">/</span>');
        }).join('');
        $('#breadcrumb').html(html);
    }

    function renderRows(rows) {
        var $body = $('#agentList');
        if (!rows.length) {
            $body.empty();
            $('#noData').show();
            return;
        }
        $('#noData').hide();
        $body.html(rows.map(function (a) {
            return '<tr data-id="' + M.esc(a.ID) + '">' +
                '<td class="account-cell">' + M.esc(a.ID) + '</td>' +
                '<td>' + M.gold(a.COINS) + '</td>' +
                '<td>' + (a.HasChildAgency ? '<span class="unban-btn">查看下级</span>' : '0') + '</td>' +
                '<td>' + M.num(a.PlayerBalance != null ? a.PlayerBalance : 0) + '</td>' +
                '<td>' + M.esc(a.InviteCode || '--') + '</td>' +
                '<td class="time-cell">' + M.fmtTime(a.UpdateTime) + '</td>' +
                '<td class="time-cell">' + M.fmtTime(a.CreateTime) + '</td>' +
                '</tr>';
        }).join(''));
    }

    function renderStats(list) {
        var rows = (list && list.rows) ? list.rows : [];
        var totalCoins = 0;
        $.each(rows, function (i, a) { totalCoins += Number(a.COINS || 0); });
        $('#totalAgents').text(list ? Number(list.total || rows.length) : 0);
        $('#totalDiamonds').text(M.gold(totalCoins));
    }

    function loadNode(agencyId, agencyName) {
        M.loading('加载数据中...');
        fetchAgencies({ Agency: agencyId || '' }).always(M.hideLoading).then(function (list) {
            var rows = (list && list.rows) ? list.rows : [];
            renderRows(rows);
            if (agencyId) {
                // 下钻节点：统计显示当前节点范围
                var coins = 0;
                $.each(rows, function (i, a) { coins += Number(a.COINS || 0); });
                $('#totalAgents').text(rows.length);
                $('#totalDiamonds').text(M.gold(coins));
            } else {
                renderStats(list);
            }
        });
    }

    function pushCrumb(id, name) {
        crumbs.push({ id: id, name: name });
        renderBreadcrumb();
        loadNode(id, name);
    }

    /* ---------------- 搜索 ---------------- */

    function runSearch() {
        var kw = $.trim($('#searchInput').val());
        var type = $('input[name="searchType"]:checked').val();
        var $box = $('#searchResults');
        if (!kw) {
            $box.html('<div class="no-data" style="padding:20px 0;">请输入账号或邀请码</div>');
            return;
        }
        $box.html('<div class="no-data" style="padding:20px 0;">搜索中...</div>');

        var dfd;
        if (type === 'account') {
            dfd = fetchAgencies({ ID: kw }).then(function (list) { return (list && list.rows) || []; });
        } else {
            dfd = fetchAllOnce().then(function (rows) {
                return $.grep(rows, function (a) { return String(a.InviteCode || '') === kw; });
            });
        }

        dfd.then(function (rows) {
            if (!rows.length) {
                $box.html('<div class="no-data" style="padding:20px 0;">未找到代理</div>');
                return;
            }
            $box.html(rows.map(function (a) {
                return '<div class="search-result-item" data-id="' + M.esc(a.ID) + '" data-name="' + M.esc(a.ID) + '">' +
                    '<div class="search-result-row"><span class="search-result-label">账号</span><span class="search-result-value">' + M.esc(a.ID) + '</span></div>' +
                    '<div class="search-result-row"><span class="search-result-label">邀请码</span><span class="search-result-value">' + M.esc(a.InviteCode || '--') + '</span></div>' +
                    '<div class="search-result-row"><span class="search-result-label">剩余金币</span><span class="search-result-value">' + M.gold(a.COINS) + '</span></div>' +
                    '<div class="search-result-row"><span class="search-result-label">注册时间</span><span class="search-result-value">' + M.fmtTime(a.CreateTime) + '</span></div>' +
                    '</div>';
            }).join(''));
        });
    }

    /* ---------------- 初始化 ---------------- */

    function initPage() {
        renderBreadcrumb();
        loadNode('', '所有代理');

        // 面包屑回退
        $('#breadcrumb').on('click', '.breadcrumb-item', function () {
            var idx = Number($(this).data('index'));
            if (isNaN(idx)) return;
            crumbs = crumbs.slice(0, idx + 1);
            renderBreadcrumb();
            loadNode(crumbs[crumbs.length - 1].id, crumbs[crumbs.length - 1].name);
        });

        // 行点击下钻
        $('#agentList').on('click', 'tr', function () {
            var id = $(this).data('id');
            if (id) pushCrumb(String(id), String(id));
        });

        // 搜索弹窗
        $('#searchModalClose').on('click', function () { $('#searchModalOverlay').removeClass('show'); });
        $('#searchModalOverlay').on('click', function (e) {
            if (e.target === this) $(this).removeClass('show');
        });
        $('#searchSubmitBtn').on('click', runSearch);
        $('#searchInput').on('keydown', function (e) {
            if (e.keyCode === 13) runSearch();
        });
        $('#searchResults').on('click', '.search-result-item', function () {
            var id = $(this).data('id');
            $('#searchModalOverlay').removeClass('show');
            crumbs = [{ id: '', name: '所有代理' }, { id: String(id), name: String(id) }];
            renderBreadcrumb();
            loadNode(id, id);
        });

        // 头部刷新 / 搜索
        M.onRefresh(function () {
            M.runRefresh(function () {
                allCache = null;
                return loadNode(crumbs[crumbs.length - 1].id, crumbs[crumbs.length - 1].name);
            });
        });
        M.onSearch(function () {
            $('#searchInput').val('');
            $('#searchResults').empty();
            $('#searchModalOverlay').addClass('show');
            setTimeout(function () { $('#searchInput').focus(); }, 120);
        });
    }

    // 脚本在 body 末尾加载，DOM 已就绪；不依赖 jQuery ready
    //（部分 WebView 中 ready 之后注册的回调不会被执行）
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', initPage);
    } else {
        initPage();
    }

})(window, jQuery, window.MApp);
