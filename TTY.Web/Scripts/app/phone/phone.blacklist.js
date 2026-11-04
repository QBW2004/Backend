/* ============================================================
   黑名单管理页（吃分，2026-11-04 从操作管理拆出，对齐参考站 heimingdang）
   数据源（与操作管理同一套电脑端总控接口）：
     - /Game/UserInfo/GetTotalControlStatus 当前控制（吃分与放水互斥，下发前要看得到）
     - /Game/UserInfo/ApplyTotalControl     确定：Mode=4 吃分，GoldThreshold=吃分金额（钻）
     - /Game/UserInfo/CloseTotalControl     移除黑名单：移除执行中的吃分（Mode=4）
   权限：服务端 HomeController.Blacklist 已按 IsKill 拦截，接口侧同样校验吃分权限。
   ============================================================ */
(function (window, $, M) {
    'use strict';

    var submitting = false;
    var statusSeq = 0;

    function setBusy(busy) {
        submitting = busy;
        // 2026-11-04：“移除黑名单”始终可点（不按当前是否有吃分置灰），只在请求进行中防连点
        $('#blApplyBtn, #blRemoveBtn').prop('disabled', busy);
    }

    function account() {
        var acc = $.trim($('#blAccount').val());
        if (!acc) M.toast('请输入玩家账号', 'error');
        return acc;
    }

    function statusText(r) {
        var m = Number(r.ControlMode);
        if (m === 6) return '送奖 ' + M.cardControlText(r.GameId, r.LimitCoins);
        if (m === 5) return '放水 目标 ' + M.diamonds(r.TargetCoins) + '钻 已放钻 ' + M.diamonds(r.GrantedCoins);
        return '吃分 目标 ' + M.diamonds(r.TargetCoins) + '钻 已吃钻 ' + M.diamonds(r.ConsumedCoins);
    }

    /** 读取并显示玩家当前控制；有放水时提示“确定会替换放水”（服务端吃分/放水互斥） */
    function loadStatus() {
        var acc = $.trim($('#blAccount').val());
        var seq = ++statusSeq;
        $('#blHint').empty();
        if (!acc) { $('#blStatus').attr('class', 'bl-status-value none').text('--'); setBusy(submitting); return; }
        $('#blStatus').attr('class', 'bl-status-value none').text('查询中...');
        setBusy(submitting);
        M.post('/Game/UserInfo/GetTotalControlStatus', { ID: acc }, { silent: true }).then(function (res) {
            if (seq !== statusSeq) return;
            var r = M.result(res);
            var rows = r.ok && r.datas ? r.datas : [];
            if (!rows.length) {
                $('#blStatus').attr('class', 'bl-status-value none').text(r.ok ? '无' : '--');
            } else {
                $('#blStatus').attr('class', 'bl-status-value').text(rows.map(statusText).join('；'));
            }
            if ($.grep(rows, function (x) { return Number(x.ControlMode) === 5; }).length)
                $('#blHint').text('确定后会替换该玩家执行中的放水');
            setBusy(submitting);
        }, function () {
            if (seq === statusSeq) $('#blStatus').attr('class', 'bl-status-value none').text('--');
        });
    }

    /** 确定：下发吃分（与操作管理原吃分口径一致：强度 3、目标=吃分金额、达到即自动结束） */
    function applyKill() {
        if (submitting) return;
        var acc = account();
        if (!acc) return;
        var gold = $.trim($('#blGold').val());
        if (!/^[1-9][0-9]*$/.test(gold) || Number(gold) > 9007199254740991) {
            M.toast('请填写大于 0 的整数吃分金额', 'error');
            return;
        }
        // 不显示“下发中”过程提示，成功直接弹“操作成功”（与操作管理一致，2026-11-04）
        setBusy(true);
        M.post('/Game/UserInfo/ApplyTotalControl', { ID: acc, Mode: 4, MobileRequest: 1, Strength: 3, GoldThreshold: parseInt(gold, 10) })
            .then(function (res) {
                var r = M.result(res);
                M.alert(r.ok ? '操作成功' : r.text, r.ok, r.ok ? '操作成功' : '操作失败');
            }, function () { })
            .always(function () { setBusy(false); loadStatus(); });
    }

    /** 移除黑名单：移除该玩家执行中的吃分 */
    function removeKill() {
        if (submitting) return;
        var acc = account();
        if (!acc) return;
        setBusy(true);
        M.post('/Game/UserInfo/CloseTotalControl', { ID: acc, Mode: 4, MobileRequest: 1 })
            .then(function (res) {
                var r = M.result(res);
                M.alert(r.ok ? '移除成功' : (r.text || '移除失败'), r.ok, r.ok ? '移除成功' : '移除失败');
            }, function () { })
            .always(function () { setBusy(false); loadStatus(); });
    }

    function initPage() {
        var preset = window.MPagePreset || {};
        if (preset.account) $('#blAccount').val(preset.account);
        $('#blApplyBtn').on('click', applyKill);
        $('#blRemoveBtn').on('click', removeKill);
        // 改账号后（失焦/回车）重查当前控制
        $('#blAccount').on('change', loadStatus).on('keydown', function (e) { if (e.keyCode === 13) loadStatus(); });
        loadStatus();
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', initPage);
    } else {
        initPage();
    }

})(window, jQuery, window.MApp);
