(function () {
    var t, flag = false;
    function showMsg(msg) {
        var msgBox = $('#alert-msg');
        msgBox.removeClass('hidden')
        if ($.trim(msgBox.text()).length == 0 || $.trim(msgBox.text()) != msg) {
            msgBox.text(msg);
        }
        if (t == null) {
            t = setTimeout(function () {
                msgBox.text('').addClass('hidden');
                clearTimeout(t);
                t = null;
            }, 3000);
        }
    }
    function checkInput() {
        if ($.trim($('#uname').val()) == '') {
            showMsg('请输入帐号！')
            return false;
        }
        if ($.trim($('#upwd').val()) == '') {
            showMsg('请输入密码！')
            return false;
        }
        //if ($.trim($('#code').val()) == '') {
        //    showMsg('请输入验证码！')
        //    return false;
        //}
        flag = true;
        return true;
    }
    function submitForm() {
        if (checkInput()) {
            document.forms[0].submit();
        }
    }
    $(function () {
        //$('#uname,#upwd,#code').keydown(function (e) {
        //    if (e.keyCode == 13) {
        //        submitForm();
        //    }
        //});
        $('#uname,#upwd').keydown(function (e) {
            if (e.keyCode == 13) {
                submitForm();
            }
        });
        $('#btnSubmit').click(function () {
            submitForm();
        });
        $('#imgChg,#lnkChg').click(function () {
            $('#imgChg').attr('src', '/Validator/ValidateImage?' + Math.random());
        });
        $("[data-toggle='tooltip']").tooltip();
        if (_msg && _msg.length > 0 && flag == false) {
            showMsg(_msg);
        }
    });
})();