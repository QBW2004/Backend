/* ============================================================
   手机端 - 添加代理
   先 /Game/AgencyInfo/CanAddAgency 校验额度，再 AddAgencyInfo 提交。
   表单字段与桌面端保持一致：FLAG / RE_ENABLE / ID / PWD / RE_PWD
   （InviteCode、IsCreateAgent、IsUpDown 为可选增强项）
   ============================================================ */
(function (window, $) {
    'use strict';

    var M = window.MApp;

    var ACCOUNT_RE = /^[a-zA-Z0-9]{3,50}$/;
    var PWD_RE = /^[a-zA-Z0-9]{6,50}$/;

    /** 把开关状态同步到隐藏字段，便于整表 serialize */
    function bindSwitch(checkboxId, hiddenId) {
        var $cb = $('#' + checkboxId);
        var $hidden = $('#' + hiddenId);
        function sync() {
            $hidden.val($cb.prop('checked') ? '1' : '0');
        }
        $cb.on('change', sync);
        sync();
    }

    function validate() {
        var id = $.trim($('#mAgId').val());
        var pwd = $('#mAgPwd').val();
        var rePwd = $('#mAgRePwd').val();
        var invite = $.trim($('#mAgInvite').val());

        if (!id) return '请输入代理账号';
        if (!ACCOUNT_RE.test(id)) return '账号需为 3-50 位字母或数字';
        if (!pwd) return '请输入密码';
        if (!PWD_RE.test(pwd)) return '密码需为 6-50 位字母或数字';
        if (pwd !== rePwd) return '两次输入的密码不一致';
        if (invite && !/^\d{4,8}$/.test(invite)) return '邀请码需为 4-8 位数字';
        return null;
    }

    function submit() {
        var err = validate();
        if (err) {
            M.toast(err, 'error');
            return;
        }

        var $btn = $('#mAddAgentBtn');
        var para = $('#mAddAgentForm').serialize();

        $btn.prop('disabled', true).text('检查额度...');

        M.post('/Game/AgencyInfo/CanAddAgency', {}).then(function (res) {
            var r = M.result(res);
            if (!r.ok) {
                M.alert(r.text, false, '无法创建');
                return null;
            }
            $btn.text('创建中...');
            M.loading('创建代理中...');
            // 表单已 serialize，追加防伪令牌后直接提交
            return $.ajax({
                url: '/Game/AgencyInfo/AddAgencyInfo',
                type: 'POST',
                data: para + '&__RequestVerificationToken=' + encodeURIComponent(M.token()),
                dataType: 'json',
                cache: false
            }).then(function (addRes) {
                if (addRes && Number(addRes.code) === -1) {
                    M.toast('登录超时，请重新登录', 'error');
                    setTimeout(M.toLogin, 1200);
                    return null;
                }
                var ar = M.result(addRes);
                if (ar.ok) {
                    var account = $.trim($('#mAgId').val());
                    $('#mAddAgentForm')[0].reset();
                    $('#mAgEnable, #mAgCreate, #mAgUpDown').prop('checked', true).trigger('change');
                    if ($('#mFlagGroup').length) {
                        $('#mFlagGroup .m-segment-item').removeClass('active').first().addClass('active');
                        $('#mFlag').val('0');
                    }
                    M.alert('代理 ' + account + ' 创建成功', true);
                } else {
                    M.alert(ar.text, false, '创建失败');
                }
                return null;
            }, function () {
                M.toast('网络异常，请稍后重试', 'error');
                return null;
            });
        }).always(function () {
            M.hideLoading();
            $btn.prop('disabled', false).text('创建代理');
        });
    }

    $(function () {
        bindSwitch('mAgEnable', 'mAgEnableVal');
        bindSwitch('mAgCreate', 'mAgCreateVal');
        bindSwitch('mAgUpDown', 'mAgUpDownVal');

        $('#mFlagGroup').on('click', '.m-segment-item', function () {
            var $i = $(this);
            $('#mFlagGroup .m-segment-item').removeClass('active');
            $i.addClass('active');
            $('#mFlag').val($i.data('val'));
        });

        $('#mAddAgentForm').on('submit', function (e) {
            e.preventDefault();
            submit();
        });
    });

})(window, jQuery);
