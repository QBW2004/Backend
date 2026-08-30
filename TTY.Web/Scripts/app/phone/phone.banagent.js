/* ============================================================
   禁用代理页（原"代理封号"，参考站 dailifenghao）
   数据源：
     - /Game/AgencyInfo/BanAgent       禁用登录 + 记录封号提示
     - /Game/AgencyInfo/UnbanAgent     恢复登录
     - /Game/AgencyInfo/GetBannedAgencies  禁用列表
     - /Game/AgencyInfo/GetBlacklistRecords 封号提示/时间（操作日志）
   封号提示在该代理登录时于登录页弹窗展示（见 B_UserLogin.Login）。
   ============================================================ */
(function (window, $, M) {
    'use strict';

    function loadList() {
        // M.post resolve 的就是后端 JSON 本体（不是 jqXHR 三元组），$.when 后直接按 .rows 取
        return $.when(
            M.post('/Game/AgencyInfo/GetBannedAgencies', { page: 1, rows: 200 }),
            M.post('/Game/AgencyInfo/GetBlacklistRecords', { page: 1, rows: 500 })
        ).then(function (banned, logs) {
            // 以最近一次禁用日志补充封号提示与时间
            var msgMap = {};
            $.each((logs && logs.rows) || [], function (i, r) {
                if (Number(r.OPT) !== 24) return;
                var id = String(r.ID || '');
                if (!msgMap[id]) msgMap[id] = r;
            });

            var rows = (banned && banned.rows) ? banned.rows : [];
            var $body = $('#blacklistContainer');
            if (!rows.length) {
                $body.empty();
                $('#noData').show();
                return;
            }
            $('#noData').hide();
            $body.html(rows.map(function (a) {
                var log = msgMap[String(a.ID)];
                return '<tr>' +
                    '<td>' + M.esc(a.ID) + '</td>' +
                    '<td class="ban-msg">' + M.esc(log ? (log.DestUserTitle || '--') : '--') + '</td>' +
                    '<td><button class="remove-btn" data-id="' + M.esc(a.ID) + '">恢复</button></td>' +
                    '<td class="ban-time">' + (log ? M.fmtTime(log.REC_TIME, true) : '--') + '</td>' +
                    '</tr>';
            }).join(''));
        });
    }

    function ban() {
        var id = $.trim($('#agentIdInput').val());
        var reason = $.trim($('#reasonInput').val());
        if (!id) { M.toast('请输入代理账号', 'error'); return; }

        M.loading('处理中...');
        M.post('/Game/AgencyInfo/BanAgent', { ID: id, BanMsg: reason }).always(M.hideLoading).then(function (res) {
            var r = M.result(res);
            M.alert(r.ok ? '操作成功' : r.text, r.ok, r.ok ? '操作成功' : '操作失败').then(function () {
                if (r.ok) {
                    $('#agentIdInput').val('');
                    $('#reasonInput').val('');
                    loadList();
                }
            });
        });
    }

    function unban(id) {
        M.loading('处理中...');
        M.post('/Game/AgencyInfo/UnbanAgent', { ID: id }).always(M.hideLoading).then(function (res) {
            var r = M.result(res);
            M.alert(r.text, r.ok, r.ok ? '操作成功' : '操作失败').then(function () {
                if (r.ok) loadList();
            });
        });
    }

    function initPage() {
        $('#blacklistBtn').on('click', ban);
        $('#agentIdInput, #reasonInput').on('keydown', function (e) {
            if (e.keyCode === 13) ban();
        });
        $('#blacklistContainer').on('click', '.remove-btn', function () {
            var id = $(this).data('id');
            M.confirm('确定要恢复代理 ' + id + ' 的登录吗？', '恢复确认').then(function (ok) {
                if (ok) unban(id);
            });
        });

        M.onRefresh(function () {
            M.runRefresh(loadList);
        });

        loadList();
    }

    // 脚本在 body 末尾加载，DOM 已就绪；不依赖 jQuery ready
    //（部分 WebView 中 ready 之后注册的回调不会被执行）
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', initPage);
    } else {
        initPage();
    }

})(window, jQuery, window.MApp);
