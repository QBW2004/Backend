/* ============================================================
   玩家详细信息页（独立页面，替代原玩家弹窗里的详情浮层）
   数据源：
     - /Game/UserInfo/GetUserDetail     详情（基础+今日/累计充退+总控状态+邀请码）
     - /Game/UserInfo/ChgPwd            修改玩家密码（需 IsModifyPwd 权限）
     - /Game/UserRecord/GetUserRecords  当日游戏记录（中奖历史 / 游戏轨迹）
   ============================================================ */
(function (window, $, M) {
    'use strict';

    var account = (window.MPagePreset && window.MPagePreset.account) || '';
    var detail = null;

    function todayStr() {
        var d = new Date();
        return d.getFullYear() + '-' + M.pad2(d.getMonth() + 1) + '-' + M.pad2(d.getDate());
    }

    /* ---------------- 渲染 ---------------- */

    function setMoney(sel, v) {
        $(sel).text(M.gold(v));
    }

    function setSigned(sel, v) {
        var n = Number(v || 0);
        $(sel).html('<span class="' + (n >= 0 ? 'positive' : 'negative') + '">' + (n > 0 ? '+' : '') + M.gold(n) + '</span>');
    }

    function renderCtrlStatus(rows) {
        var $el = $('#dControl');
        if (!rows || !rows.length) {
            $el.attr('class', 'd-value muted').text('无');
            return;
        }
        var items = rows.map(function (r) {
            var mode = Number(r.ControlMode);
            if (mode == 6) {
                return '控牌（控牌值 ' + M.esc(r.LimitCoins) + '） 次数 ' + M.esc(r.CardNumber) + '/' + M.esc(r.CardTotal);
            }
            var isRelease = (mode == 5);
            var progress = isRelease ? Number(r.GrantedCoins || 0) : -Number(r.ConsumedCoins || 0);
            var name = mode == 4 ? '吃分' : '放水';
            return name + '（强度 ' + M.esc(r.LimitCoins) + '） 阈值 ' + M.esc(r.TargetCoins) +
                ' 已' + (isRelease ? '放' : '吃') + '分 ' + M.gold(progress);
        });
        $el.attr('class', 'd-value ctrl-status-list')
            .html(items.map(function (t) { return '<span class="ctrl-status-item">' + M.esc(t) + '</span>'; }).join(''));
    }

    function render(d) {
        detail = d;
        $('#dCreateTime').text(M.fmtTime(d.CreateTime, true));
        $('#dLastLogin').text(M.fmtTime(d.LastLoginTime, true));
        $('#dAccount').text(d.ID || '--');
        $('#dName').text(d.NAME || '--');
        $('#dAgency').text(d.AGENCY || '--');
        $('#dInviteCode').text(d.InviteCode || '--');

        // 密码：无权查看时显示 --（后端按权限置空），有权则展示+复制
        var $pwd = $('#dPwd');
        var $copy = $('#btnCopyPwd');
        if (d.PWD) {
            $pwd.text(String(d.PWD)).removeClass('muted');
            $copy.show();
        } else {
            $pwd.text('--').addClass('muted');
            $copy.hide();
        }

        $('#dScore').text(M.num(d.GAME_SCORE) + '分');
        setMoney('#dCoins', d.COINS);
        setMoney('#dTodayBuy', d.TodayBuy);
        setMoney('#dTodayBack', d.TodayBack);
        setSigned('#dTodayWinLoss', d.TodayWinLoss);
        setMoney('#dTotalBuy', d.COINS_BUY);
        setMoney('#dTotalBack', d.COINS_BACK);
        // 总盈亏口径与列表页一致：总充值 - 总退分
        setSigned('#dTotalWinLoss', Number(d.COINS_BUY || 0) - Number(d.COINS_BACK || 0));

        renderCtrlStatus(d.Controls);

        $('#btnRecharge, #btnPrizeHistory, #btnGameTrack').prop('disabled', false);
        if (d.ID) {
            document.title = '玩家详细信息';
            var $sub = $('.header .subtitle');
            if ($sub.length) $sub.text(d.NAME || d.ID);
        }
    }

    /* ---------------- 数据加载 ---------------- */

    function load() {
        if (!account) {
            M.toast('缺少玩家账号参数', 'error');
            return;
        }
        M.loading('加载玩家信息...');
        return M.post('/Game/UserInfo/GetUserDetail', { ID: account })
            .always(M.hideLoading)
            .then(function (res) {
                var r = M.result(res);
                if (!r.ok || !r.datas) {
                    M.alert(r.text, false, '加载失败').then(function () {
                        window.location.href = '/Mobile/Home/Index';
                    });
                    return;
                }
                render(r.datas);
            });
    }

    /* ---------------- 操作 ---------------- */

    function copyText(text) {
        // 非安全上下文（HTTP）下 navigator.clipboard 不可用，回退 execCommand
        var done = function () { M.toast('已复制', 'success', 1500); };
        if (navigator.clipboard && window.isSecureContext) {
            navigator.clipboard.writeText(text).then(done, function () { fallbackCopy(text, done); });
        } else {
            fallbackCopy(text, done);
        }
    }

    function fallbackCopy(text, done) {
        var ta = document.createElement('textarea');
        ta.value = text;
        ta.style.position = 'fixed';
        ta.style.opacity = '0';
        document.body.appendChild(ta);
        ta.select();
        try { document.execCommand('copy'); done(); } catch (e) { M.toast('复制失败，请手动复制', 'error'); }
        document.body.removeChild(ta);
    }

    function changePwd() {
        if (!detail) return;
        M.promptInput({
            title: '修改玩家密码（' + detail.ID + '）',
            label: '新密码',
            placeholder: '请输入新密码（至少 6 位）',
            type: 'password',
            confirmText: '确认修改',
            emptyMsg: '请输入新密码'
        }).then(function (v) {
            if (v == null) return;
            if (v.length < 6) { M.toast('密码至少 6 位', 'error'); return; }
            M.loading('修改中...');
            M.post('/Game/UserInfo/ChgPwd', { ID: detail.ID, PWD: v }).always(M.hideLoading).then(function (res) {
                var r = M.result(res);
                M.alert(r.text, r.ok, r.ok ? '操作成功' : '操作失败').then(function () {
                    if (r.ok) load();
                });
            });
        });
    }

    /** 玩家当日游戏记录（中奖历史 / 游戏轨迹共用） */
    function loadPlayerRecords(acc) {
        return M.post('/Game/UserRecord/GetUserRecords', { ID: acc, TIME: todayStr(), page: 1, rows: 20 })
            .then(function (list) {
                return (list && list.rows) ? list.rows : [];
            }, function () {
                return [];
            });
    }

    function showPrizeHistory() {
        if (!detail) return;
        M.loading('查询中...');
        loadPlayerRecords(detail.ID).always(M.hideLoading).then(function (rows) {
            var body;
            if (!rows.length) {
                body = '<div class="modal-message" style="margin-bottom:0;">今日暂无记录</div>';
            } else {
                var trs = rows.map(function (r) {
                    var score = Number(r.SCORE || 0);
                    return '<tr>' +
                        '<td>' + M.fmtTime(r.REC_TIME) + '</td>' +
                        '<td>' + M.esc(r.GameName || M.gameName(r.GAME_TYPE)) + '</td>' +
                        '<td class="' + (score >= 0 ? 'positive' : 'negative') + '">' + (score >= 0 ? '+' : '') + M.gold(score) + '</td>' +
                        '</tr>';
                }).join('');
                body = '<div style="width:100%; max-height:320px; overflow-y:auto;">' +
                    '<table class="table-container" style="box-shadow:none; margin-bottom:0; border:1px solid #eaeaea; border-radius:8px;">' +
                    '<thead><tr><th>时间</th><th>游戏</th><th>输赢</th></tr></thead>' +
                    '<tbody>' + trs + '</tbody></table></div>';
            }
            M.modal({
                title: '中奖历史',
                bodyHTML: body,
                buttons: [{ label: '关闭', value: null, type: 'confirm' }]
            });
        });
    }

    function showGameTrack() {
        if (!detail) return;
        M.loading('查询中...');
        loadPlayerRecords(detail.ID).always(M.hideLoading).then(function (rows) {
            var body;
            if (!rows.length) {
                body = '<div class="modal-message" style="margin-bottom:0;">今日暂无记录</div>';
            } else {
                var lines = rows.map(function (r) {
                    return '<div>' + M.fmtTime(r.REC_TIME) + ' - ' + M.esc(r.GameName || M.gameName(r.GAME_TYPE)) +
                        ' 机台 ' + M.esc(r.TABLE_ID != null ? r.TABLE_ID : '--') +
                        ' 押注 ' + M.gold(r.OPT_COINS) +
                        ' 输赢 <span class="' + (Number(r.SCORE || 0) >= 0 ? 'positive' : 'negative') + '">' + M.gold(r.SCORE) + '</span></div>';
                }).join('');
                body = '<div style="width:100%; font-family:ui-monospace,monospace; background:#f8f9fa; padding:12px; border-radius:8px; border-left:4px solid #5856D6; font-size:13px; line-height:1.7; max-height:320px; overflow-y:auto; text-align:left;">' +
                    '账号 ' + M.esc(detail.ID) + ' 的今日游戏轨迹:' + lines + '</div>';
            }
            M.modal({
                title: '游戏轨迹',
                bodyHTML: body,
                buttons: [{ label: '关闭', value: null, type: 'confirm' }]
            });
        });
    }

    /* ---------------- 初始化 ---------------- */

    function initPage() {
        $('#btnCopyPwd').on('click', function () {
            if (detail && detail.PWD) copyText(String(detail.PWD));
        });
        $('#btnChgPwd').on('click', changePwd);
        $('#btnControl').on('click', function () {
            if (detail) window.location.href = '/Mobile/Home/Control?id=' + encodeURIComponent(detail.ID);
        });
        $('#btnRecharge').on('click', function () {
            if (detail) window.location.href = '/Mobile/Home/Recharge?id=' + encodeURIComponent(detail.ID) + '&pay=0&role=player';
        });
        $('#btnPrizeHistory').on('click', showPrizeHistory);
        $('#btnGameTrack').on('click', showGameTrack);

        M.onRefresh(function () {
            M.runRefresh(function () { return load(); });
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
