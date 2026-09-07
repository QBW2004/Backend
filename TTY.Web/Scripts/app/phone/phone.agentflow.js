/* ============================================================
   代理流水页（展示单个代理的资金流入流出记录）
   数据源：/Game/AgencyRecord/GetAgencyRecords
   交互：日期筛选、分页浏览
   列：日期 / 代理账号 / 金币(COINS) / 剩余金币(AFT_COINS) / 来源 / 流向

   OPT 取值（见 B_Recharge.AddAgentOptLog：OPT = RechargeType + 20）：
     2 登录、3 退出、20 充值、21 兑换、22 赠送、23 扣币
     0 / 1 是历史遗留数据，一并兼容；24/25/26/27 为封禁/解冻审计（无金额）
   ============================================================ */
(function (window, $, M) {
    'use strict';

    var currentPage = 1;
    var pageSize = 20;
    var totalPages = 0;
    var agentId = '';

    /* 资金记录：有金币变动，COINS 为操作金币量 */
    var OPT_IN = { '0': 1, '20': 1, '22': 1 };      // 流入：充值/赠送
    var OPT_OUT = { '1': 1, '21': 1, '23': 1 };     // 流出：兑换/扣币

    /* 操作类型文案（非资金记录也用于“来源”辅助说明） */
    var OPT_TEXT = {
        '0': '充值', '1': '兑换', '2': '登录', '3': '退出',
        '20': '充值', '21': '兑换', '22': '赠送', '23': '扣币',
        '24': '代理禁用', '25': '代理解禁',
        '26': '玩家冻结', '27': '玩家解冻'
    };

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

    function optKey(rowData) {
        return String(Number(rowData.OPT));
    }

    function isMoneyRecord(rowData) {
        return OPT_IN[optKey(rowData)] === 1 || OPT_OUT[optKey(rowData)] === 1;
    }

    function isInRecord(rowData) {
        return OPT_IN[optKey(rowData)] === 1;
    }

    /* 来源：记录中“对方”账号。流入=转出方(OptID)，流出=接收方(ID) */
    function getSource(rowData) {
        var opt = optKey(rowData);
        if (isInRecord(rowData)) {
            return rowData.OptID + '[' + M.esc(rowData.SrcUserTitle) + ']';
        }
        if (OPT_OUT[opt] === 1) {
            return rowData.ID + '[' + M.esc(rowData.DestUserTitle) + ']';
        }
        return '--';
    }

    function getFlowDirection(rowData) {
        var opt = optKey(rowData);
        if (OPT_IN[opt] === 1) {
            return '<span class="flow-direction in">流入 ↓</span>';
        }
        if (OPT_OUT[opt] === 1) {
            return '<span class="flow-direction out">流出 ↑</span>';
        }
        return '<span class="flow-direction" style="background:#f0f0f0;color:#666;">--</span>';
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
            var opt = optKey(r);
            var isMoney = isMoneyRecord(r);
            var isIn = isInRecord(r);
            var amount = isMoney ? Number(r.COINS || 0) : 0;
            // 金币：流入为正、流出为负；剩余金币 = 操作后余额
            var amountHtml = isMoney
                ? '<span class="amount ' + (isIn ? 'positive' : 'negative') + '">' +
                      (isIn ? '+' : '-') + M.gold(Math.abs(amount)) + '</span>'
                : '--';
            var remainHtml = isMoney ? M.gold(Number(r.AFT_COINS || 0)) : '--';

            return '<tr>' +
                '<td class="time">' + M.fmtTime(r.REC_TIME) + '</td>' +
                '<td>' + M.esc(agentId) + '</td>' +
                '<td>' + amountHtml + '</td>' +
                '<td>' + remainHtml + '</td>' +
                '<td>' + M.esc(getSource(r)) + '</td>' +
                '<td>' + getFlowDirection(r) + '</td>' +
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
