/* ============================================================
   冻结明细页（原"异常账号"，参考站 yichangzhanghu）
   数据源：/Game/Abnormal/GetAbnormalAccounts、/Game/Abnormal/Unblock
   ============================================================ */
(function (window, $, M) {
    'use strict';

    function load() {
        M.loading('加载数据中...');
        return M.post('/Game/Abnormal/GetAbnormalAccounts', {}).always(M.hideLoading).then(function (res) {
            if (!res || Number(res.code) !== 1) {
                M.toast('查询失败', 'error');
                return;
            }
            var datas = res.datas || {};
            var rows = datas.rows || [];

            $('#playerCount').text(Number(datas.playerCount || 0));
            $('#adminCount').text(Number(datas.agencyCount || 0));

            var $body = $('#accountList');
            if (!rows.length) {
                $body.empty();
                $('#noData').show();
                return;
            }
            $('#noData').hide();
            $body.html(rows.map(function (r) {
                var type = String(r.Type || '未知');
                var typeCls = type === '代理' ? 'admin' : (type === '玩家' ? 'player' : '');
                return '<tr>' +
                    '<td>' + M.esc(r.ID) + '</td>' +
                    '<td><span class="account-type ' + typeCls + '">' + M.esc(type) + '</span></td>' +
                    '<td>' + M.esc(String(r.Reason || '').replace(/(\d+)/, '<span class="error-count">$1</span>')) + '</td>' +
                    '<td><button class="unlock-btn" data-id="' + M.esc(r.ID) + '">解冻</button></td>' +
                    '</tr>';
            }).join(''));
        });
    }

    function initPage() {
        $('#accountList').on('click', '.unlock-btn', function () {
            var id = $(this).data('id');
            M.confirm('确定要解冻账号 ' + id + ' 吗？', '解冻账号').then(function (ok) {
                if (!ok) return;
                M.loading('处理中...');
                M.post('/Game/Abnormal/Unblock', { ID: id }).always(M.hideLoading).then(function (res) {
                    var r = M.result(res);
                    M.alert(r.text, r.ok, r.ok ? '操作成功' : '操作失败').then(function () {
                        if (r.ok) load();
                    });
                });
            });
        });

        M.onRefresh(function () {
            M.runRefresh(load);
        });

        load();
    }

    // 脚本在 body 末尾加载，DOM 已就绪；不依赖 jQuery ready
    //（部分 WebView 中 ready 之后注册的回调不会被执行）
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', initPage);
    } else {
        initPage();
    }

})(window, jQuery, window.MApp);
