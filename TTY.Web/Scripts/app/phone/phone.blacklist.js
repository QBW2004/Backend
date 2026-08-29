/* ============================================================
   代理拉黑页（1:1 复刻参考站 daililahei）
   数据源：
     - /Game/AgencyInfo/BlacklistAgent    拉黑（封禁整条线 + 按范围冻结名下玩家）
     - /Game/AgencyInfo/UnBlacklistAgent  解除拉黑
     - /Game/AgencyInfo/GetBlacklistRecords 拉黑/解封记录
   ============================================================ */
(function (window, $, M) {
    'use strict';

    function scopeValue() {
        var v = $('#scopeGroup .option-item.active').data('value');
        return Number(v === undefined ? 0 : v);
    }

    function loadList() {
        M.loading('加载数据中...');
        return M.post('/Game/AgencyInfo/GetBlacklistRecords', { page: 1, rows: 200 })
            .always(M.hideLoading)
            .then(function (list) {
                var rows = (list && list.rows) ? list.rows : [];
                var $body = $('#blacklistContainer');
                if (!rows.length) {
                    $body.empty();
                    $('#noData').show();
                    return;
                }
                $('#noData').hide();
                $body.html(rows.map(function (r) {
                    var isBan = Number(r.OPT) === 24;
                    return '<tr>' +
                        '<td>' + M.esc(r.ID) + '</td>' +
                        '<td>' + (isBan
                            ? '<button class="unblack-btn" data-id="' + M.esc(r.ID) + '">解封</button>'
                            : '<span style="color:#34c759;">已解封</span>') + '</td>' +
                        '<td>--</td>' +
                        '<td>' + (isBan ? M.num(r.COINS) : '--') + '</td>' +
                        '<td>' + (isBan ? M.num(r.BEF_COINS) : '--') + '</td>' +
                        '<td>' + M.esc(r.OptID || '--') + '</td>' +
                        '<td>' + M.fmtTime(r.REC_TIME, true) + '</td>' +
                        '</tr>';
                }).join(''));
            });
    }

    function submit() {
        var id = $.trim($('#agentAccountInput').val());
        if (!id) { M.toast('请输入代理账号', 'error'); return; }
        var scope = scopeValue();
        var scopeText = scope === 1 ? '直属玩家' : (scope === 2 ? '非直属玩家' : '所有玩家');

        M.confirm('确定要拉黑代理 ' + id + ' 及其' + scopeText + '吗？拉黑后整条线代理将无法登录，名下玩家将被冻结。', '拉黑确认').then(function (ok) {
            if (!ok) return;
            M.loading('处理中...');
            M.post('/Game/AgencyInfo/BlacklistAgent', { ID: id, BanMsg: '', Scope: scope })
                .always(M.hideLoading)
                .then(function (res) {
                    var r = M.result(res);
                    if (r.ok) {
                        var d = r.datas || {};
                        M.alert('拉黑成功：影响代理 ' + M.num(d.affectedAgents) + ' 个，冻结玩家 ' + M.num(d.affectedPlayers) + ' 个', true, '操作成功').then(function () {
                            $('#agentAccountInput').val('');
                            $('#freeScoreInput').val('');
                            loadList();
                        });
                    } else {
                        M.alert(r.text, false, '操作失败');
                    }
                });
        });
    }

    function initPage() {
        $('#scopeGroup .option-item').on('click', function () {
            $('#scopeGroup .option-item').removeClass('active');
            $(this).addClass('active').find('input').prop('checked', true);
        });

        $('#confirmBtn').on('click', submit);
        $('#agentAccountInput').on('keydown', function (e) {
            if (e.keyCode === 13) submit();
        });

        $('#blacklistContainer').on('click', '.unblack-btn', function () {
            var id = $(this).data('id');
            M.confirm('确定要解除代理 ' + id + ' 的拉黑吗？将恢复整条线登录并解冻玩家。', '解封确认').then(function (ok) {
                if (!ok) return;
                M.loading('处理中...');
                M.post('/Game/AgencyInfo/UnBlacklistAgent', { ID: id }).always(M.hideLoading).then(function (res) {
                    var r = M.result(res);
                    M.alert(r.text, r.ok, r.ok ? '操作成功' : '操作失败').then(function () {
                        if (r.ok) loadList();
                    });
                });
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
