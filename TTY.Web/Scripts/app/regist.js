$.extend($.fn.validatebox.defaults.rules, {
    confirm_pwd: {
        validator: function (value, param) {
            return $('#txtPWD').val() == value;
        },
        message: '两次输入的密码不一致'
    },
    minLength: {
        validator: function (value, param) {
            return value.length >= param[0];
        },
        message: '长度不能小于 {0} 字符'
    },
    maxLength: {
        validator: function (value, param) {
            return value.length <= param[0];
        },
        message: '长度不能大于 {0} 字符'
    },
    safeChar: {
        validator: function (value, param) {
            return /^[a-zA-Z0-9]+$/.test(value);
        },
        message: '只能输入英文字母或者数字'
    },
    safeNickname: {
        validator: function (value, param) {
            return /^[\u4e00-\u9fa5_a-zA-Z0-9]+$/.test(value);
        },
        message: '只能输入汉字、英文字母或者数字'
    }
});

function submitForm() {
    $('#ff').form('submit', {
        url: '/Game/UserInfo/Register',
        onSubmit: function () {
            return $(this).form('enableValidation').form('validate');
        },
        success: function (data) {
            var msg;
            try {
                msg = JSON.parse(data);
                if (msg && msg.content)
                    alert(msg.content);
            } catch (e) {
                alert('获取消息失败！');
            }
        }
    });
}
function clearForm() {
    $('#ff').form('clear');
}
function getParam(name) {
    var reg = new RegExp("(^|&)" + name + "=([^&]*)(&|$)", "i");
    var r = window.location.search.substr(1).match(reg);
    if (r != null)
        return unescape(r[2]);
    return "";
}
$(function () {
    $('#hfAgency').val(getParam('agency'));
})