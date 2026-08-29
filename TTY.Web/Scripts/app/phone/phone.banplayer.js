/* ============================================================
   玩家封号页（1:1 复刻参考站 fenghao）
   数据源：/Game/UserInfo/FrozenUser、/Game/UserInfo/GetFrozenUsers
   说明：项目无「封禁时间」字段，列表展示账号 + 解封操作；
        封禁时间列展示「--」以保持版式一致。
   ============================================================ */
(function (window, $, M) {
    'use strict';

    function loadList() {
        M.loading('加载数据中...');
        return M.post('/Game/UserInfo/GetFrozenUsers', { srch_ID: '', page: 1, rows: 200 })
            .always(M.hideLoading)
            .then(function (list) {
                var rows = (list && list.rows) ? list.rows : [];
                var $body = $('#banList');
                if (!rows.length) {
                    $body.empty();
                    $('#noData').show();
                    return;
                }
                $('#noData').hide();
                $body.html(rows.map(function (u) {
                    return '<tr>' +
                        '<td>' + M.esc(u.ID) + '</td>' +
                        '<td><button class="unban-btn" data-id="' + M.esc(u.ID) + '">解封</button></td>' +
                        '<td class="ban-time">--</td>' +
                        '</tr>';
                }).join(''));
            });
    }

    function banAccount() {
        var id = $.trim($('#playerIdInput').val());
        if (!id) { M.toast('请输入玩家账号', 'error'); return; }

        M.loading('处理中...');
        M.post('/Game/UserInfo/FrozenUser', { ID: id, frozen: 1 }).always(M.hideLoading).then(function (res) {
            var r = M.result(res);
            M.alert(r.ok ? '操作成功' : r.text, r.ok, r.ok ? '操作成功' : '操作失败').then(function () {
                if (r.ok) {
                    $('#playerIdInput').val('');
                    loadList();
                }
            });
        });
    }

    function unbanAccount(id) {
        M.loading('处理中...');
        M.post('/Game/UserInfo/FrozenUser', { ID: id, frozen: 0 }).always(M.hideLoading).then(function (res) {
            var r = M.result(res);
            M.alert(r.text, r.ok, r.ok ? '操作成功' : '操作失败').then(function () {
                if (r.ok) loadList();
            });
        });
    }

    function initPage() {
        $('#banBtn').on('click', banAccount);
        $('#playerIdInput').on('keydown', function (e) {
            if (e.keyCode === 13) banAccount();
        });
        $('#banList').on('click', '.unban-btn', function () {
            var id = $(this).data('id');
            M.confirm('确定要解封玩家 ' + id + ' 吗？', '解封确认').then(function (ok) {
                if (ok) unbanAccount(id);
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
