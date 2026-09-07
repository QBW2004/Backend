/* ============================================================
   代理流水页（展示单个代理的资金流入流出记录）
   数据源：/Game/AgencyRecord/GetAgencyRecords
   交互：日期筛选、分页浏览
   ============================================================ */
(function (window, $, M) {
    'use strict';

    var currentPage = 1;
    var pageSize = 20;
    var totalPages = 0;
    var agentId = '';

    /* ---------------- 数据 ---------------- */

    function fetchAgentFlow(params) {
        return M.post('/Game/AgencyRecord/GetAgencyRecords', $.extend({
            ID: agentId,
            OPT: -1,
            TIME: new Date(),
            page: currentPage,
            rows: pageSize
        }, params || {}));
    }

    function fetchAgentInfo() {
        if (!agentId) return $.Deferred().reject().promise();
        return M.post('/Game/AgencyInfo/GetAgencyDetail', { ID: agentId });
    }

    /* ---------------- 渲染 ---------------- */

    function renderAgentInfo(agentData) {
        if (!agentData) return;
        $('#agentAccount').text(M.esc(agentData.ID || '--'));
        $('#agentCoins').text(M.gold(agentData.COINS));
        $('#agentInfoCard').show();
    }

    function getFlowDirection(opt, coins) {
        // OPT: 0=充值(流入), 1=兑换(流出), 2=登录, 3=退出
        if (opt === 0) {
            return '<span class="flow-direction in">流入 ↓</span>';
        } else if (opt === 1) {
            return '<span class="flow-direction out">流出 ↑</span>';
        } else {
            return '<span class="flow-direction" style="background:#f0f0f0;color:#666;">--</span>';
        }
    }

    function getFlowNote(rowData) {
        switch (rowData.OPT) {
            case 0:
                return rowData.SrcUserTitle + '账号[' + M.esc(rowData.OptID) + ']给' +
                       rowData.DestUserTitle + '账号[' + M.esc(rowData.ID) + ']充值';
            case 1:
                return rowData.SrcUserTitle + '账号[' + M.esc(rowData.OptID) + ']给' +
                       rowData.DestUserTitle + '账号[' + M.esc(rowData.ID) + ']兑换';
            case 2:
                return '账号[' + M.esc(rowData.OptID) + ']登录';
            case 3:
                return '账号[' + M.esc(rowData.OptID) + ']退出';
            default:
                return '--';
        }
    }

    function renderRows(rows) {
        var $body = $('#flowTableBody');
        if (!rows || !rows.length) {
            $body.empty();
            $('#noData').show();
            return;
        }
        $('#noData').hide();
        $body.html(rows.map(function (r) {
            var isTransfer = (r.OPT === 0 || r.OPT === 1);
            var transferAmount = isTransfer ? Math.abs(Number(r.COINS || 0)) : 0;
            var beforeCoins = Number(r.BEF_COINS || 0);
            var afterCoins = Number(r.AFT_COINS || 0);

            return '<tr>' +
                '<td class="time">' + M.fmtTime(r.REC_TIME) + '</td>' +
                '<td>' + M.esc(r.OptID || '--') + '</td>' +
                '<td class="amount ' + (r.OPT === 0 ? 'positive' : r.OPT === 1 ? 'negative' : '') + '">' +
                    (isTransfer ? M.gold(transferAmount) : '--') + '</td>' +
                '<td>' + M.gold(afterCoins) + '</td>' +
                '<td>' + getFlowDirection(r.OPT, r.COINS) + '</td>' +
                '<td style="max-width:200px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;">' +
                    M.esc(getFlowNote(r)) + '</td>' +
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

        var startDate = $('#startDate').val();
        var endDate = $('#endDate').val();

        var queryTime = new Date();
        if (startDate) {
            queryTime = new Date(startDate);
        }

        fetchAgentFlow({ TIME: queryTime, page: currentPage })
            .always(function() {
                if (showLoading !== false) {
                    M.hideLoading();
                }
            })
            .then(function (res) {
                var rows = (res && res.rows) ? res.rows : [];
                var total = res ? Number(res.total || 0) : 0;

                // 根据日期范围筛选
                if (startDate && endDate) {
                    var start = new Date(startDate).getTime();
                    var end = new Date(endDate + ' 23:59:59').getTime();
                    rows = rows.filter(function(r) {
                        var recTime = new Date(r.REC_TIME).getTime();
                        return recTime >= start && recTime <= end;
                    });
                    total = rows.length;
                }

                renderRows(rows);
                renderPagination(total);

                if (res && res.notice) {
                    M.toast(res.notice, 'warning');
                }
            }, function() {
                M.toast('加载失败，请重试', 'error');
            });
    }

    /* ---------------- 初始化 ---------------- */

    function initPage() {
        agentId = (window.MPagePreset && window.MPagePreset.agentId) || '';

        if (!agentId) {
            M.alert('缺少代理账号参数', false, '提示');
            return;
        }

        // 加载代理信息
        fetchAgentInfo().then(function(res) {
            var r = M.result(res);
            if (r.ok && r.datas) {
                renderAgentInfo(r.datas);
            }
        });

        // 加载流水数据
        loadData();

        // 筛选按钮
        $('#filterBtn').on('click', function() {
            currentPage = 1;
            loadData();
        });

        // 分页
        $('#prevBtn').on('click', function() {
            if (currentPage > 1) {
                currentPage--;
                loadData();
            }
        });

        $('#nextBtn').on('click', function() {
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
