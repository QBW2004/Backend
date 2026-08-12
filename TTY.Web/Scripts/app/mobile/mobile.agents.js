/* ============================================================
   手机端 - 我的代理
   列表：/Game/AgencyInfo/GetAgencies（ID / Agency / page / rows）
   操作：SetRecharge（启用禁用）、ChgPwd、DeleteAdmin、SaveAgencyLimit、SetInviteCode
   ============================================================ */
(function (window, $) {
    'use strict';

    var M = window.MApp;
    var P = window.MPage || {};

    var PAGE_SIZE = 15;

    var state = {
        rows: [],
        page: 0,
        total: 0,
        loading: false,
        search: { id: '', agency: '' }
    };

    /* ---------------- 渲染 ---------------- */

    function agentCard(a) {
        var enabled = Number(a.RE_ENABLE) === 1;
        var isSelf = String(a.ID) === String(P.ownAccount);

        return '' +
            '<div class="m-item-card' + (enabled ? ' online' : ' offline') + '" data-account="' + M.esc(a.ID) + '">' +
                '<div class="m-item-head">' +
                    '<span class="m-item-account">' + M.esc(a.ID) + '</span>' +
                    '<span class="m-tag ' + (Number(a.PRIV) === 0 ? 'admin' : 'agent') + '">' + M.esc(M.privName(a.PRIV)) + '</span>' +
                    (isSelf ? '<span class="m-tag disabled">本人</span>' : '') +
                    (enabled ? '' : '<span class="m-tag frozen">已禁用</span>') +
                    '<span class="m-item-badge coins">' + M.gold(a.COINS) + '</span>' +
                '</div>' +
                '<div class="m-item-body">' +
                    '<div class="m-info-row cols-3">' +
                        infoItem('总充值', M.gold(a.RECHARGE)) +
                        infoItem('总兑换', M.gold(a.EXCHANGE)) +
                        infoItem('上级', a.AGENCY || '--') +
                    '</div>' +
                    '<div class="m-info-row money cols-2">' +
                        moneyItem('代理盈亏', a.Profit) +
                        moneyItem('下级余额', a.PlayerBalance, true) +
                    '</div>' +
                    '<div class="m-item-foot">' +
                        M.ICONS.people +
                        '<span>邀请码 ' + M.esc(a.InviteCode || '--') + '</span>' +
                        '<span>·</span>' +
                        '<span>创建 ' + M.esc(M.fmtTime(a.CreateTime)) + '</span>' +
                    '</div>' +
                '</div>' +
            '</div>';
    }

    function infoItem(label, value) {
        return '<div class="m-info-item"><span class="m-info-label">' + M.esc(label) + '</span>' +
            '<span class="m-info-value">' + M.esc(value) + '</span></div>';
    }

    function moneyItem(label, value, plain) {
        var text = plain ? M.gold(value) : M.signed(value);
        var cls = plain ? '' : M.signClass(value);
        return '<div class="m-info-item"><span class="m-info-label">' + M.esc(label) + '</span>' +
            '<span class="m-info-value ' + cls + '">' + text + '</span></div>';
    }

    function render() {
        var $box = $('#mAgList');
        if (!state.rows.length) {
            $box.html('<div class="m-empty">暂无代理数据</div>');
        } else {
            var html = [];
            for (var i = 0; i < state.rows.length; i++) html.push(agentCard(state.rows[i]));
            $box.html(html.join(''));
        }

        var coins = 0, profit = 0;
        for (var j = 0; j < state.rows.length; j++) {
            coins += Number(state.rows[j].COINS || 0);
            profit += Number(state.rows[j].Profit || 0);
        }
        $('#mAgTotal').text(state.total);
        $('#mAgCoins').text(M.gold(coins));
        $('#mAgProfit').text(M.signed(profit)).attr('class', 'm-stat-value ' + M.signClass(profit));

        if (state.rows.length >= state.total) {
            $('#mAgLoadMoreBox').addClass('m-hidden');
            $('#mAgNoMore').toggleClass('m-hidden', state.rows.length === 0);
        } else {
            $('#mAgLoadMoreBox').removeClass('m-hidden');
            $('#mAgNoMore').addClass('m-hidden');
        }
    }

    /* ---------------- 加载 ---------------- */

    function load(reset) {
        if (state.loading) return $.Deferred().resolve().promise();
        state.loading = true;
        if (reset) {
            state.page = 0;
            state.rows = [];
        }
        var next = state.page + 1;
        var $btn = $('#mAgLoadMore').prop('disabled', true).text('加载中...');

        return M.post('/Game/AgencyInfo/GetAgencies', {
            ID: state.search.id,
            Agency: state.search.agency,
            page: next,
            rows: PAGE_SIZE
        }).then(function (res) {
            state.page = next;
            state.total = Number(res && res.total ? res.total : 0);
            state.rows = state.rows.concat((res && res.rows) ? res.rows : []);
            render();
        }).always(function () {
            state.loading = false;
            $btn.prop('disabled', false).text('加载更多');
        });
    }

    /* ---------------- 操作 ---------------- */

    function find(account) {
        for (var i = 0; i < state.rows.length; i++) {
            if (String(state.rows[i].ID) === String(account)) return state.rows[i];
        }
        return null;
    }

    function showActions(account) {
        var a = find(account);
        if (!a) return;
        var enabled = Number(a.RE_ENABLE) === 1;
        var isSelf = String(account) === String(P.ownAccount);
        var actions = [];

        if (P.canUpDown) {
            actions.push({ label: '给该代理充值', type: 'recharge', value: 'recharge' });
            actions.push({ label: '从该代理兑换', type: 'reward', value: 'exchange' });
        }
        actions.push({ label: '代理详情', type: 'details', value: 'detail' });
        actions.push({ label: '修改代理密码', type: 'track', value: 'pwd' });
        if (P.isSuper) {
            actions.push({ label: '设置邀请码', type: 'warn', value: 'invite' });
        }
        if (!isSelf) {
            actions.push({ label: '设置分代上限', type: 'details', value: 'limit' });
            actions.push({
                label: enabled ? '禁用该代理' : '启用该代理',
                type: enabled ? 'danger' : 'reward',
                value: enabled ? 'disable' : 'enable'
            });
            actions.push({ label: '删除该代理', type: 'danger', value: 'delete' });
        }

        M.modal({
            title: '代理账号：' + account,
            subtitle: M.privName(a.PRIV) + (a.AGENCY ? ' · 上级 ' + a.AGENCY : ''),
            actions: actions,
            buttons: [{ label: '取消', value: null }]
        }).then(function (v) {
            if (!v) return;
            if (v === 'recharge') {
                window.location.href = '/Mobile/Home/Recharge?role=agent&pay=0&id=' + encodeURIComponent(account);
            } else if (v === 'exchange') {
                window.location.href = '/Mobile/Home/Recharge?role=agent&pay=1&id=' + encodeURIComponent(account);
            } else if (v === 'detail') {
                showDetail(a);
            } else if (v === 'pwd') {
                changePwd(account);
            } else if (v === 'invite') {
                setInviteCode(a);
            } else if (v === 'limit') {
                setAgencyLimit(a);
            } else if (v === 'enable') {
                setEnable(account, 1);
            } else if (v === 'disable') {
                setEnable(account, 0);
            } else if (v === 'delete') {
                remove(account);
            }
        });
    }

    function kv(k, v) {
        return '<div><span class="k">' + M.esc(k) + '</span><span class="v">' + M.esc(v) + '</span></div>';
    }

    function showDetail(a) {
        var limit = Number(a.AGENCY_LIMIT) === 0 ? '无限制' : a.AGENCY_LIMIT;
        var body = '<div class="m-kv">' +
            kv('账号', a.ID) +
            kv('层级', M.privName(a.PRIV)) +
            kv('上级代理', a.AGENCY || '--') +
            kv('剩余金币', M.gold(a.COINS)) +
            kv('总充值', M.gold(a.RECHARGE)) +
            kv('总兑换', M.gold(a.EXCHANGE)) +
            kv('代理盈亏', M.signed(a.Profit)) +
            kv('下级代理余额', M.gold(a.PlayerBalance)) +
            kv('下级玩家余额', M.gold(a.UserBalance)) +
            kv('邀请码', a.InviteCode || '--') +
            kv('分代上限', limit) +
            kv('佣金比例', a.CommissionRate != null ? a.CommissionRate + '%' : '--') +
            kv('充值状态', Number(a.RE_ENABLE) === 1 ? '已启用' : '已禁用') +
            kv('创建时间', M.fmtTime(a.CreateTime, true)) +
            '</div>';
        M.modal({ title: '代理详情', bodyHTML: body, buttons: [{ label: '关闭', value: null }] });
    }

    function changePwd(account) {
        M.promptInput({
            title: '修改代理密码',
            subtitle: '账号：' + account,
            label: '新密码',
            type: 'password',
            placeholder: '至少 6 位',
            emptyMsg: '请输入新密码'
        }).then(function (pwd) {
            if (!pwd) return;
            if (pwd.length < 6) { M.toast('密码至少 6 位', 'error'); return; }
            M.loading('修改中...');
            M.post('/Game/AgencyInfo/ChgPwd', { ID: account, PWD: pwd })
                .always(M.hideLoading)
                .then(function (res) {
                    var r = M.result(res);
                    M.alert(r.text, r.ok);
                });
        });
    }

    function setInviteCode(a) {
        M.promptInput({
            title: '设置邀请码',
            subtitle: '账号：' + a.ID,
            label: '邀请码（4-8 位数字）',
            type: 'text',
            inputmode: 'numeric',
            value: a.InviteCode || '',
            emptyMsg: '请输入邀请码'
        }).then(function (code) {
            if (!code) return;
            if (!/^\d{4,8}$/.test(code)) { M.toast('邀请码需为 4-8 位数字', 'error'); return; }
            M.loading('设置中...');
            M.post('/Game/AgencyInfo/SetInviteCode', { ID: a.ID, InviteCode: code })
                .always(M.hideLoading)
                .then(function (res) {
                    var r = M.result(res);
                    if (r.ok) {
                        a.InviteCode = code;
                        render();
                    }
                    M.alert(r.text, r.ok);
                });
        });
    }

    function setAgencyLimit(a) {
        M.promptInput({
            title: '设置分代上限',
            subtitle: '账号：' + a.ID,
            label: '可创建的直属下级代理数',
            type: 'number',
            inputmode: 'numeric',
            value: a.AGENCY_LIMIT != null ? a.AGENCY_LIMIT : 0,
            tip: '填 0 表示不限制',
            emptyMsg: '请输入数量'
        }).then(function (val) {
            if (val === null) return;
            var n = parseInt(val, 10);
            if (isNaN(n) || n < 0) { M.toast('请输入不小于 0 的整数', 'error'); return; }
            M.loading('设置中...');
            M.post('/Game/AgencyInfo/SaveAgencyLimit', { ID: a.ID, AGENCY_LIMIT: n })
                .always(M.hideLoading)
                .then(function (res) {
                    var r = M.result(res);
                    if (r.ok) load(true);
                    M.alert(r.text, r.ok);
                });
        });
    }

    function setEnable(account, enable) {
        var word = enable === 1 ? '启用' : '禁用';
        M.confirmDanger('确定要' + word + '代理 ' + account + ' 吗？', word + '代理').then(function (ok) {
            if (!ok) return;
            M.loading('处理中...');
            M.post('/Game/AgencyInfo/SetRecharge', { ID: account, RE_ENABLE: enable })
                .always(M.hideLoading)
                .then(function (res) {
                    var r = M.result(res);
                    if (r.ok) {
                        M.toast(word + '成功', 'success');
                        load(true);
                    } else {
                        M.toast(r.text, 'error');
                    }
                });
        });
    }

    function remove(account) {
        M.confirmDanger('删除后该代理将无法登录，确定删除 ' + account + ' 吗？', '删除代理').then(function (ok) {
            if (!ok) return;
            M.loading('删除中...');
            M.post('/Game/AgencyInfo/DeleteAdmin', { ID: account })
                .always(M.hideLoading)
                .then(function (res) {
                    var r = M.result(res);
                    if (r.ok) load(true);
                    M.alert(r.text, r.ok);
                });
        });
    }

    /* ---------------- 搜索 ---------------- */

    function showSearch() {
        var body =
            '<div class="m-form-group"><label class="m-label">代理账号</label>' +
            '<input type="text" class="m-input" id="mAgSchId" placeholder="支持模糊匹配" value="' + M.esc(state.search.id) + '" autocomplete="off"></div>' +
            '<div class="m-form-group"><label class="m-label">上级代理</label>' +
            '<input type="text" class="m-input" id="mAgSchAgency" placeholder="上级代理账号" value="' + M.esc(state.search.agency) + '" autocomplete="off"></div>';

        var dlg = M.modal({
            title: '搜索代理',
            bodyHTML: body,
            buttons: [
                { label: '重置', value: 'reset' },
                { label: '搜索', value: 'ok', type: 'primary' }
            ]
        });

        var $m = dlg.$modal;
        dlg.then(function (v) {
            if (v === 'reset') {
                state.search = { id: '', agency: '' };
            } else if (v === 'ok') {
                state.search = {
                    id: $.trim($m.find('#mAgSchId').val()),
                    agency: $.trim($m.find('#mAgSchAgency').val())
                };
            } else {
                return;
            }
            renderSearchTip();
            load(true);
        });
    }

    function renderSearchTip() {
        var s = state.search;
        var parts = [];
        if (s.id) parts.push('账号 ' + s.id);
        if (s.agency) parts.push('上级 ' + s.agency);
        var $tip = $('#mAgSearchTip');
        if (!parts.length) {
            $tip.addClass('m-hidden').empty();
            return;
        }
        $tip.removeClass('m-hidden').html(
            '<span class="m-chip active">' + M.esc(parts.join(' / ')) + '</span>' +
            '<button type="button" class="m-chip" id="mAgClearSearch">清除筛选</button>'
        );
    }

    /* ---------------- 绑定 ---------------- */

    $(function () {
        $('#mAgList').on('click', '.m-item-card', function () {
            showActions($(this).data('account'));
        });
        $('#mAgLoadMore').on('click', function () { load(false); });
        $('#mMain').on('click', '#mAgClearSearch', function () {
            state.search = { id: '', agency: '' };
            renderSearchTip();
            load(true);
        });
        $('#mSearchBtn').on('click', showSearch);
        $('#mRefreshBtn').on('click', function () {
            M.runRefresh(function () { return load(true); });
        });

        load(true);
    });

})(window, jQuery);
