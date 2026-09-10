/* ============================================================
   玩家游戏记录页（独立页面，替代玩家弹窗里的记录浮层）
   数据源：/Game/UserRecord/GetUserRecords（ID 玩家账号 + TIME 日期 + page/rows）
   列口径与电脑端"玩家记录"页（Areas/Game/Views/UserRecord/Index.cshtml）一致：
     时间 / 游戏 / 桌台号(TABLE_ID+1) / 位置号(SEAT_ID+1) / 下注(OPT_COINS) /
     得分(离开-进入，玩家赢为正) / 记录内容
   记录内容不再重复输出"本次盈亏"：电脑端该项按运营口径（进入-离开）展示，
   与同为一行内的"得分"（玩家口径）符号相反，同页并列易生歧义，
   只保留进入/离开余额，盈亏以"得分"列为准。

   OPT 取值（B_Records_MySQL.Get_PlayerRecords 返回，非游戏记录一并兼容）：
     0 充值后、1 兑换后；2/8 进入桌台；3/7 离开桌台
   ============================================================ */
(function (window, $, M) {
    'use strict';

    var currentPage = 1;
    var pageSize = 20;
    var totalPages = 0;
    var account = '';

    /* 进入桌台的 OPT：该行没有下注/得分，记录内容为"进入[ 游戏 ]" */
    var OPT_ENTER = { '2': 1, '8': 1 };
    /* 离开桌台的 OPT：带本次盈亏（进入余额与离开余额由服务端配对补充） */
    var OPT_LEAVE = { '3': 1, '7': 1 };

    /* ---------------- 数据 ---------------- */

    function fetchRecords() {
        // 日期必须是 "yyyy-MM-dd" 字符串（服务端按该日 00:00 ~ 次日 00:00 过滤），
        // 传 Date 对象会被 jQuery 序列化成不可解析的日期字符串导致过滤失效。
        return M.post('/Game/UserRecord/GetUserRecords', {
            ID: account,
            TIME: $('#recordDate').val(),
            page: currentPage,
            rows: pageSize
        });
    }

    /* ---------------- 渲染 ---------------- */

    function optKey(rowData) {
        return String(Number(rowData.OPT));
    }

    function isGameRecord(rowData) {
        var opt = optKey(rowData);
        return OPT_ENTER[opt] === 1 || OPT_LEAVE[opt] === 1;
    }

    function renderTableId(rowData) {
        if (!isGameRecord(rowData)) return '--';
        return (Number(rowData.TABLE_ID) + 1) + '号桌子';
    }

    function renderSeatId(rowData) {
        if (!isGameRecord(rowData)) return '--';
        return (Number(rowData.SEAT_ID) + 1) + '号位置';
    }

    function renderBet(rowData) {
        if (!isGameRecord(rowData)) return '--';
        return M.gold(Number(rowData.OPT_COINS || 0));
    }

    /* 得分 = 离开余额 - 进入余额（玩家赢为正）：仅离开记录有进入/离开余额 */
    function renderScore(rowData) {
        if (!isGameRecord(rowData)) return '--';
        if (OPT_ENTER[optKey(rowData)] === 1) return '--';
        var score = Number(rowData.LeaveCoins || 0) - Number(rowData.EnterCoins || 0);
        return '<span class="amount ' + (score > 0 ? 'positive' : (score < 0 ? 'negative' : '')) + '">' +
            (score > 0 ? '+' : '') + M.gold(score) + '</span>';
    }

    function renderContent(rowData) {
        var opt = optKey(rowData);
        var gameName = M.esc(rowData.GameName || M.gameName(rowData.GAME_TYPE) || '--');
        if (OPT_ENTER[opt] === 1) return '进入[ ' + gameName + ' ]';
        if (OPT_LEAVE[opt] === 1) {
            return '进入：' + M.gold(Number(rowData.EnterCoins || 0)) +
                '，离开：' + M.gold(Number(rowData.LeaveCoins || 0));
        }
        if (opt === '0') return '充值后，余额：' + M.gold(Number(rowData.COINS || 0));
        if (opt === '1') return '兑换后，余额：' + M.gold(Number(rowData.COINS || 0));
        return '--';
    }

    function renderRows(rows) {
        var $body = $('#recordTableBody');
        if (!rows || !rows.length) {
            $body.empty();
            $('#noData').show();
            return;
        }
        $('#noData').hide();
        $body.html(rows.map(function (r) {
            return '<tr>' +
                '<td class="time">' + M.esc(M.fmtTime(r.REC_TIME, true)) + '</td>' +
                '<td>' + M.esc(r.GameName || M.gameName(r.GAME_TYPE) || '--') + '</td>' +
                '<td>' + renderTableId(r) + '</td>' +
                '<td>' + renderSeatId(r) + '</td>' +
                '<td class="amount">' + renderBet(r) + '</td>' +
                '<td>' + renderScore(r) + '</td>' +
                '<td class="record-content">' + renderContent(r) + '</td>' +
                '</tr>';
        }).join(''));
    }

    function renderPagination(total) {
        totalPages = Math.ceil(total / pageSize);
        $('#paginationInfo').text('第 ' + currentPage + ' 页 / 共 ' + totalPages + ' 页');
        $('#prevBtn').prop('disabled', currentPage <= 1);
        $('#nextBtn').prop('disabled', currentPage >= totalPages);
    }

    function loadData(showLoading) {
        if (showLoading !== false) {
            M.loading('加载数据中...');
        }

        return fetchRecords()
            .always(function () {
                if (showLoading !== false) {
                    M.hideLoading();
                }
            })
            .then(function (res) {
                var rows = (res && res.rows) ? res.rows : [];
                var total = res ? Number(res.total || 0) : 0;

                renderRows(rows);
                renderPagination(total);
                $('#recordSummary').text('共 ' + total + ' 条记录');

                if (res && res.notice) {
                    M.toast(res.notice, 'warning');
                }
            }, function () {
                M.toast('加载失败，请重试', 'error');
            });
    }

    /* ---------------- 初始化 ---------------- */

    function initPage() {
        account = (window.MPagePreset && window.MPagePreset.account) || '';

        if (!account) {
            M.alert('缺少玩家账号参数', false, '提示');
            return;
        }

        $('#playerAccountLink').text(account).on('click', function () {
            window.location.href = '/Mobile/Home/PlayerDetail?id=' + encodeURIComponent(account);
        });

        loadData();

        // 日期筛选 / 分页
        $('#filterBtn').on('click', function () {
            currentPage = 1;
            loadData();
        });

        $('#prevBtn').on('click', function () {
            if (currentPage > 1) {
                currentPage--;
                loadData();
            }
        });

        $('#nextBtn').on('click', function () {
            if (currentPage < totalPages) {
                currentPage++;
                loadData();
            }
        });

        // 头部刷新
        M.onRefresh(function () {
            M.runRefresh(function () {
                currentPage = 1;
                return loadData(false);
            });
        });
    }

    // 脚本在 body 末尾加载，DOM 已就绪
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', initPage);
    } else {
        initPage();
    }

})(window, jQuery, window.MApp);
