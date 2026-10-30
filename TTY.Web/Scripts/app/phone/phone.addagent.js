/* ============================================================
   添加代理页（1:1 复刻参考站 kaidaili）
   数据源：/Game/AgencyInfo/CanAddAgency、/Game/AgencyInfo/AddAgencyInfo
   ============================================================ */
(function (window, $, M) {
    'use strict';

    function setSubmitting(on) {
        var $btn = $('#submitBtn');
        $btn.toggleClass('loading', on);
        $btn.prop('disabled', on);
    }

    var ACCOUNT_RE = /^[a-zA-Z0-9]{3,50}$/;
    var PWD_RE = /^[a-zA-Z0-9]{6,50}$/;

    function submitForm() {
        var account = $.trim($('#agentAccount').val());
        var password = $('#agentPassword').val();

        if (!account) { M.toast('请输入代理账号', 'error'); return; }
        if (!ACCOUNT_RE.test(account)) { M.toast('账号需为 3-50 位字母或数字', 'error'); return; }
        if (!password) { M.toast('请输入密码', 'error'); return; }
        if (!PWD_RE.test(password)) { M.toast('密码需为 6-50 位字母或数字', 'error'); return; }
        // 超管创建直属代理必须勾选玩家可玩游戏（页面只对超管渲染勾选框）
        var $playable = $('#agentPlayableGames');
        var playableGames = '';
        if ($playable.length) {
            playableGames = $playable.find('input:checked').map(function () { return this.value; }).get().join(',');
            if (!playableGames) { M.toast('请至少勾选一款玩家可玩游戏', 'error'); return; }
        }
        setSubmitting(true);
        M.post('/Game/AgencyInfo/AddAgencyInfo', {
            FLAG: 0,
            ID: account,
            PWD: password,
            RE_ENABLE: 1,
            IsCreateAgent: $('#agentCreateAgent').is(':checked') ? 1 : 0,
            MobileRequest: 1,
            InviteCode: '',
            PlayableGames: playableGames
        }).always(function () { setSubmitting(false); }).then(function (res) {
            var r = M.result(res);
            M.alert(r.ok ? '操作成功' : r.text, r.ok, r.ok ? '操作成功' : '操作失败').then(function () {
                if (r.ok) {
                    window.location.href = '/Mobile/Home/Agents';
                }
            });
        });
    }

    function initPage() {
        // 页面进入前先确认当前账号是否允许创建代理
        M.post('/Game/AgencyInfo/CanAddAgency', {}).then(function (res) {
            var r = M.result(res);
            if (!r.ok) {
                M.alert('当前账号暂不能创建代理：' + r.text, false, '无法创建').then(function () {
                    window.location.href = '/Mobile/Home/Index';
                });
            }
        });

        if ($('#agentPlayableGames').length) {
            M.post('/Game/AgencyInfo/GetPlayableGames', {}).then(function (res) {
                var r = M.result(res);
                var games = (r.ok && r.datas && r.datas.Games) || [];
                $('#agentPlayableGames').html(games.length ? $.map(games, function (g) {
                    return '<label class="playable-chip"><input type="checkbox" value="' + g.GameId + '" checked><span>' + M.esc(g.Name) + '</span></label>';
                }).join('') : '<span class="playable-hint">' + M.esc(r.ok ? '暂无已开放游戏' : r.text) + '</span>');
            });
        }

        $('#createAgentForm').on('submit', function (e) {
            e.preventDefault();
            submitForm();
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
