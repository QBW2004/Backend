$(function () {
    pluginInit();
    $('#btnSave').click(function () {
        var para = $('#form1').serializeObject();
        request('/Login/ResetPwd', para, function (data) {
            showMsg(data);
            if (data.code == 1) {
                confirm('修改成功，需要重新登录！', function () {
                    window.location.href = '/Login/LoginOut';
                });
            }
        });
    });
    easyloader.load(['textbox'], function () {
        onLoaded();
        $('ul.simple').addClass('animated fadeInDown');
    });
});