/* ============================================================
   送奖管理页（参考站 songjiang 的简化落地）
   参考站的牌型赔率/奖池/实时押注依赖其游戏服子系统，本项目按
   「带风控的赠送」实现：
     - 玩家必须在线（INHALL）
     - 送奖金额不得超过玩家今日输赢
     - /Game/UserInfo/SaveGive（流水类型：赠送）
   ============================================================ */
(function (window, $, M) {
    'use strict';

    var PAGE_SIZE = 20;
    var pageIndex = 1;
    var totalCount = 0;
    var current = null;

    function queryPlayer() {
        var acc = $.trim($('#giveAccount').val());
        if (!acc) { M.toast('请输入玩家账号', 'error'); return; }

        M.loading('查询中...');
        M.post('/Game/UserInfo/GetVisibleUserRows', { UserIDs: JSON.stringify([acc]) })
            .always(M.hideLoading)
            .then(function (res) {
                var row = (res && res.datas && res.datas.length) ? res.datas[0] : null;
                if (!row) {
                    current = null;
                    $('#playerInfoCard').removeClass('show');
                    $('#giveBtn').prop('disabled', true);
                    M.alert('未查询到该玩家，请确认账号是否正确', false, '查询失败');
                    return;
                }
                current = row;
                var online = row.INHALL === true;
                $('#piName').text(row.NAME || '--');
                $('#piCoins').text(M.gold(row.COINS));
                var today = Number(row.TodayWinLoss || 0);
                $('#piToday').text((today >= 0 ? '+' : '') + M.gold(today)).css('color', today >= 0 ? '#34c759' : '#ff3b30');
                $('#piOnline').text(online ? '在线' : '离线').attr('class', 'info-value ' + (online ? 'status-online' : 'status-offline'));
                $('#playerInfoCard').addClass('show');
                $('#giveBtn').prop('disabled', false);
            });
    }

    function give() {
        if (!current) { M.toast('请先查询玩家信息', 'error'); return; }
        var amount = $.trim($('#giveAmount').val());
        if (!amount || Number(amount) <= 0) { M.toast('金额不正确，不能为0', 'error'); return; }

        var today = Number(current.TodayWinLoss || 0);
        if (current.INHALL !== true) {
            M.alert('玩家不在线，无法送奖！', false, '风控提示');
            return;
        }
        if (Number(amount) > today) {
            M.alert('送奖金额超过玩家今日输赢金额（' + M.gold(today) + '），无法送奖！', false, '风控提示');
            return;
        }

        M.confirm('确定要给玩家 ' + current.ID + ' 送奖 ' + M.gold(amount) + ' 金币吗？', '送奖确认').then(function (ok) {
            if (!ok) return;
            M.loading('处理中...');
            M.post('/Game/UserInfo/SaveGive', { ID4: current.ID, txtE_COINS2: amount })
                .always(M.hideLoading)
                .then(function (res) {
                    var r = M.result(res);
                    M.alert(r.text, r.ok, r.ok ? '操作成功' : '操作失败').then(function () {
                        if (r.ok) {
                            $('#giveAmount').val('');
                            queryPlayer();
                            loadRecords(1);
                        }
                    });
                });
        });
    }

    function loadRecords(page) {
        M.loading('加载数据中...');
        return M.post('/Game/Recharge/GetReChargeRecordsForPhone', {
            ID: '', Operator: '', TypeFlag: 3,
            srch_StartTime: '', srch_EndTime: '',
            page: page, rows: PAGE_SIZE
        }).always(M.hideLoading).then(function (res) {
            var rows = (res && res.rows) ? res.rows : [];
            totalCount = res ? Number(res.total || 0) : 0;
            pageIndex = page;

            var $body = $('#recordBody');
            if (!rows.length) {
                $body.empty();
                $('#noData').show();
            } else {
                $('#noData').hide();
                $body.html(rows.map(function (r) {
                    return '<tr>' +
                        '<td class="time">' + M.fmtTime(r.CreateTime, true) + '</td>' +
                        '<td>' + M.esc(r.GameID || '--') + '</td>' +
                        '<td>' + M.esc(r.UserName || '--') + '</td>' +
                        '<td class="amount positive">+' + M.gold(r.Coin) + '</td>' +
                        '<td>' + M.esc(r.Operator || '--') + '</td>' +
                        '<td>' + (Number(r.Processed) === 1 ? '已完成' : (Number(r.Processed) === 0 ? '未处理' : '已拒绝')) + '</td>' +
                        '</tr>';
                }).join(''));
            }

            var totalPages = Math.max(1, Math.ceil(totalCount / PAGE_SIZE));
            $('#paginationInfo').text('第 ' + pageIndex + ' 页 / 共 ' + totalPages + ' 页');
            $('#prevBtn').prop('disabled', pageIndex <= 1);
            $('#nextBtn').prop('disabled', pageIndex >= totalPages);
        });
    }

    function initPage() {
        var preset = window.MPagePreset || {};
        if (preset.account) {
            $('#giveAccount').val(preset.account);
            queryPlayer();
        }

        $('#queryBtn').on('click', queryPlayer);
        $('#giveAccount').on('keydown', function (e) {
            if (e.keyCode === 13) queryPlayer();
        });
        $('#giveBtn').on('click', give);

        $('#prevBtn').on('click', function () {
            if (pageIndex > 1) loadRecords(pageIndex - 1);
        });
        $('#nextBtn').on('click', function () {
            if (pageIndex < Math.ceil(totalCount / PAGE_SIZE)) loadRecords(pageIndex + 1);
        });

        M.onRefresh(function () {
            M.runRefresh(function () { return loadRecords(1); });
        });

        loadRecords(1);
    }

    // 脚本在 body 末尾加载，DOM 已就绪；不依赖 jQuery ready
    //（部分 WebView 中 ready 之后注册的回调不会被执行）
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', initPage);
    } else {
        initPage();
    }

})(window, jQuery, window.MApp);
