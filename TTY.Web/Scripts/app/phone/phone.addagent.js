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

    function submitForm() {
        var account = $.trim($('#agentAccount').val());
        var password = $('#agentPassword').val();

        if (!account) { M.toast('请输入代理账号', 'error'); return; }
        if (account.length < 6) { M.toast('账号长度不能小于6个字符', 'error'); return; }
        if (!password) { M.toast('请输入密码', 'error'); return; }
        if (password.length < 6) { M.toast('密码长度不能小于6个字符', 'error'); return; }
        if (!/^[a-zA-Z0-9]+$/.test(password)) { M.toast('密码只能是英文字母和数字', 'error'); return; }
        setSubmitting(true);
        M.post('/Game/AgencyInfo/AddAgencyInfo', {
            FLAG: 0,
            ID: account,
            PWD: password,
            RE_ENABLE: 1,
            MobileRequest: 1,
            InviteCode: ''
        }).always(function () { setSubmitting(false); }).then(function (res) {
            var r = M.result(res);
            M.alert(r.ok ? '代理账号创建成功' : r.text, r.ok, r.ok ? '操作成功' : '操作失败').then(function () {
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
