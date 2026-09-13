/* ============================================================
   代理流水页（展示单个代理与对方账号之间的资金变动记录）
   数据源：/Game/AgencyRecord/GetAgencyRecords
   交互：日期筛选、分页浏览；流向列可点击（代账号弹代理详情、玩账号跳玩家详情）
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
    var OPT_IN = { '0': 1, '20': 1, '22': 1 };      // 充值/赠送：被操作账号收到金币
    var OPT_OUT = { '1': 1, '21': 1, '23': 1 };     // 兑换/扣币：金币回到操作人账号

    /* 玩家在日志里的职务文案（M_Admin/EAdminType 翻译结果）；
       服务端 DestIsPlayer 缺失时的兼容判定，正常走服务端字段。 */
    var PLAYER_TITLE = '用户';

    /* 流向账号前缀：后台账号标“代”，玩家账号标“玩” */
    var PREFIX_AGENT = '代 ';
    var PREFIX_PLAYER = '玩 ';

    /* ---------------- 数据 ---------------- */

    function fetchAgentFlow(params) {
        // 日期参数必须是 "yyyy-MM-dd" 字符串（TIME=开始日, END=结束日），
        // 传 Date 对象会被 jQuery 序列化成无法解析的英文日期导致服务端日期过滤失效。
        // MONEY_ONLY=1：本页是「流水」，登录/退出(2/3)与封禁审计(24-27)这类没有金额的记录整条不展示。
        // 过滤放服务端才能让 total 与分页对得上（前端过滤会出现整页空行、页码虚高）。
        return M.post('/Game/AgencyRecord/GetAgencyRecords', $.extend({
            ID: agentId,
            OPT: -1,
            MONEY_ONLY: 1,
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

    /* 来源：本次资金变动的转出方账号（充值/赠送为操作人，兑换/扣币为被操作账号）。
       这里直接显示账号，不拼“总代理/代理”等职务后缀。 */
    function getSourceAccount(rowData) {
        var opt = optKey(rowData);
        if (OPT_IN[opt] === 1) return rowData.OptID;
        if (OPT_OUT[opt] === 1) return rowData.ID;
        return '';
    }

    /* 被操作账号（ID）是否玩家：以服务端 DestIsPlayer 为准，
       字段缺失时退回职务文案判定，保证旧接口响应也能正确显示。 */
    function isPlayerAccount(rowData) {
        if (rowData.DestIsPlayer === true || rowData.DestIsPlayer === 1) return true;
        if (rowData.DestIsPlayer === false || rowData.DestIsPlayer === 0) return false;
        return String(rowData.DestUserTitle || '') === PLAYER_TITLE;
    }

    /* 流向：本次资金变动的接收方账号，代理显示“代 xxx”、玩家显示“玩 xxx”。
       充值/赠送收币的是被操作账号，兑换/扣币收币的是操作人（后台账号，必为代理）。 */
    function getTargetInfo(rowData) {
        var opt = optKey(rowData);
        if (OPT_IN[opt] === 1) {
            return { account: rowData.ID, isPlayer: isPlayerAccount(rowData) };
        }
        if (OPT_OUT[opt] === 1) {
            return { account: rowData.OptID, isPlayer: false };
        }
        return null;
    }

    function renderSource(rowData) {
        var account = getSourceAccount(rowData);
        return account ? M.esc(account) : '--';
    }

    function renderTarget(rowData) {
        var target = getTargetInfo(rowData);
        if (!target || !target.account) return '--';
        var account = String(target.account);
        if (target.isPlayer) {
            // 玩家账号：与超链接一致，点击跳玩家详细信息页
            return '<a class="flow-account-link player" href="/Mobile/Home/PlayerDetail?id=' +
                encodeURIComponent(account) + '">' + PREFIX_PLAYER + M.esc(account) + '</a>';
        }
        return '<span class="flow-account-link agent" data-agent="' + M.esc(account) + '">' +
            PREFIX_AGENT + M.esc(account) + '</span>';
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
            var isMoney = isMoneyRecord(r);
            var isIn = isInRecord(r);
            var amount = isMoney ? Number(r.COINS || 0) : 0;
            // 金币：收币为正、付币为负；剩余金币 = 操作后余额
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
                '<td class="flow-source">' + renderSource(r) + '</td>' +
                '<td class="flow-target">' + renderTarget(r) + '</td>' +
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
        if (!startDate) {
            var d = new Date();
            startDate = d.getFullYear() + '-' + M.pad2(d.getMonth() + 1) + '-' + M.pad2(d.getDate());
        }
        if (!endDate) endDate = startDate;

        // 服务端按 TIME(开始日) ~ END(结束日) 过滤；不传 Date 对象，
        // 避免 jQuery 序列化成不可解析的日期字符串。日期筛选/分页全在服务端完成。
        fetchAgentFlow({
            TIME: startDate,
            END: endDate,
            page: currentPage
        })
            .always(function() {
                if (showLoading !== false) {
                    M.hideLoading();
                }
            })
            .then(function (res) {
                var rows = (res && res.rows) ? res.rows : [];
                var total = res ? Number(res.total || 0) : 0;

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

        // 流向里的代理账号：弹出代理详细信息，可继续查看该代理的流水/充值
        $('#flowTableBody').on('click', '.flow-account-link.agent', function () {
            M.showAgentDetail(String($(this).data('agent') || ''));
        });

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
