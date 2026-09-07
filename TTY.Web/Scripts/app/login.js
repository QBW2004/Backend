(function () {
    var t;

    // 显示错误提示(卡片内红字)
    function showMsg(msg) {
        var msgBox = $('#alert-msg');
        if ($.trim(msgBox.text()).length === 0 || $.trim(msgBox.text()) !== msg) {
            msgBox.text(msg);
        }
        msgBox.addClass('show');
        if (t == null) {
            t = setTimeout(function () {
                msgBox.removeClass('show');
                msgBox.text('');
                clearTimeout(t);
                t = null;
            }, 3000);
        }
    }

    // 前端校验:账号/密码非空
    function checkInput() {
        if ($.trim($('#loginUsername').val()) === '') {
            showMsg('请输入账号！');
            return false;
        }
        if ($.trim($('#loginPassword').val()) === '') {
            showMsg('请输入密码！');
            return false;
        }
        return true;
    }

    // 提交前做校验,通过后按钮进入 loading 并提交表单
    function submitForm() {
        if (!checkInput()) {
            return;
        }
        var btn = $('#loginBtn');
        btn.addClass('loading');
        btn.html('<span class="spinner"></span>登录中...');
        document.forms[0].submit();
    }

    $(function () {
        // 回车提交
        $('#loginUsername,#loginPassword').keydown(function (e) {
            if (e.keyCode === 13) {
                e.preventDefault();
                submitForm();
            }
        });
        // 点击登录按钮
        $('#loginBtn').click(function (e) {
            e.preventDefault();
            submitForm();
        });
        // 密码可见切换
        $('#togglePwd').click(function () {
            var inp = $('#loginPassword')[0];
            var isPwd = inp.type === 'password';
            inp.type = isPwd ? 'text' : 'password';
            $('#togglePwd').text(isPwd ? '隐藏' : '显示');
        });
        // 服务端返回的错误消息(TempData["msg"])
        if (_msg && _msg.length > 0) {
            showMsg(_msg);
        }
    });
})();
