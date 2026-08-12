/* ============================================================
   手机端 - 玩家列表
   在线玩家：/Game/UserInfo/GetOnlineUsers（一次全量，前端排序/过滤）
   全部玩家：/Game/UserInfo/GetUsers（后端分页）
   ============================================================ */
(function (window, $) {
    'use strict';

    var M = window.MApp;
    var P = window.MPage || {};

    var PAGE_SIZE = 15;

    var state = {
        tab: 'online',
        sort: 'win',
        online: [],
        all: [],
        allPage: 0,
        allTotal: 0,
        allLoading: false,
        search: { id: '', name: '', agency: '' }
    };

    /* ---------------- 渲染：在线玩家卡片 ---------------- */

    function statusText(s) {
        var n = Number(s);
        if (n === 0) return '游戏中';
        if (n === 1) return '在大厅';
        return '在线';
    }

    function onlineCard(p) {
        var seat = (Number(p.TableId) > 0 ? p.TableId : '--') +
            (Number(p.SeatId) > 0 ? ' / ' + p.SeatId : '');
        var today = Number(p.TodayWinLoss || 0);
        var total = Number(p.Profit || 0);

        return '' +
            '<div class="m-item-card online" data-account="' + M.esc(p.ID) + '" data-kind="online">' +
                '<div class="m-item-head">' +
                    '<span class="m-item-account">' + M.esc(p.ID) + '</span>' +
                    '<span class="m-item-name">' + M.esc(p.NAME) + '</span>' +
                    '<span class="m-item-badge coins">' + M.gold(p.Coins) + '</span>' +
                    '<span class="m-item-badge score">' + M.num(p.Score) + '分</span>' +
                '</div>' +
                '<div class="m-item-body">' +
                    '<div class="m-info-row">' +
                        infoItem('游戏', M.gameName(p.GameID)) +
                        infoItem('房间', Number(p.RoomId) > 0 ? p.RoomId : '--') +
                        infoItem('桌/座', seat) +
                        infoItem('押注', Number(p.CurBet) > 0 ? M.num(p.CurBet) : '--') +
                    '</div>' +
                    '<div class="m-info-row money cols-2">' +
                        moneyItem('今日盈亏', today) +
                        moneyItem('总盈亏', total) +
                    '</div>' +
                    '<div class="m-item-foot">' +
                        M.ICONS.clock +
                        '<span>' + statusText(p.Status) + '</span>' +
                        '<span>·</span>' +
                        '<span>代理 ' + M.esc(p.AGENCY || '--') + '</span>' +
                        (Number(p.CurGameScore) !== 0 ? '<span>·</span><span>本局 ' + M.signed(p.CurGameScore) + '</span>' : '') +
                    '</div>' +
                '</div>' +
            '</div>';
    }

    /* ---------------- 渲染：全部玩家卡片 ---------------- */

    function allCard(u) {
        var frozen = Number(u.FROZEN) === 1;
        var online = u.INHALL === true;
        var cls = 'm-item-card ' + (frozen ? 'frozen' : (online ? 'online' : 'offline'));

        var tag;
        if (frozen) tag = '<span class="m-tag frozen">已冻结</span>';
        else if (online) tag = '<span class="m-tag online">在线</span>';
        else tag = '<span class="m-tag offline">离线</span>';

        return '' +
            '<div class="' + cls + '" data-account="' + M.esc(u.ID) + '" data-kind="all">' +
                '<div class="m-item-head">' +
                    '<span class="m-item-account">' + M.esc(u.ID) + '</span>' +
                    '<span class="m-item-name">' + M.esc(u.NAME) + '</span>' +
                    tag +
                    '<span class="m-item-badge coins">' + M.gold(u.COINS) + '</span>' +
                '</div>' +
                '<div class="m-item-body">' +
                    '<div class="m-info-row cols-3">' +
                        infoItem('游戏分数', M.num(u.GAME_SCORE)) +
                        infoItem('总购币', M.gold(u.COINS_BUY)) +
                        infoItem('总兑换', M.gold(u.COINS_BACK)) +
                    '</div>' +
                    '<div class="m-info-row money cols-2">' +
                        moneyItem('总盈亏', u.Profit) +
                        moneyItem('保险柜', u.SAFE_COINS, true) +
                    '</div>' +
                    '<div class="m-item-foot">' +
                        M.ICONS.person +
                        '<span>代理 ' + M.esc(u.AGENCY || '--') + '</span>' +
                        (u.TELEPHONE ? '<span>·</span><span>' + M.esc(u.TELEPHONE) + '</span>' : '') +
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

    /* ---------------- 在线玩家 ---------------- */

    function sortOnline(list) {
        var arr = list.slice();
        if (state.sort === 'win') {
            arr.sort(function (a, b) { return Number(b.TodayWinLoss || 0) - Number(a.TodayWinLoss || 0); });
        } else if (state.sort === 'loss') {
            arr.sort(function (a, b) { return Number(a.TodayWinLoss || 0) - Number(b.TodayWinLoss || 0); });
        } else if (state.sort === 'bet') {
            arr.sort(function (a, b) { return Number(b.CurBet || 0) - Number(a.CurBet || 0); });
        } else {
            arr.sort(function (a, b) { return String(a.ID || '').localeCompare(String(b.ID || '')); });
        }
        return arr;
    }

    function filterOnline(list) {
        var s = state.search;
        if (!s.id && !s.name && !s.agency) return list;
        return $.grep(list, function (p) {
            if (s.id && String(p.ID || '').toLowerCase().indexOf(s.id.toLowerCase()) < 0) return false;
            if (s.name && String(p.NAME || '').toLowerCase().indexOf(s.name.toLowerCase()) < 0) return false;
            if (s.agency && String(p.AGENCY || '').toLowerCase().indexOf(s.agency.toLowerCase()) < 0) return false;
            return true;
        });
    }

    function renderOnline() {
        var list = sortOnline(filterOnline(state.online));
        var $box = $('#mOnlineList');
        if (!list.length) {
            $box.html('<div class="m-empty">暂无在线玩家</div>');
        } else {
            var html = [];
            for (var i = 0; i < list.length; i++) html.push(onlineCard(list[i]));
            $box.html(html.join(''));
        }
        $('#mOnlineCount').text(list.length);
        updateSubtitle();
    }

    function loadOnline() {
        return M.loadGames().then(function () {
            return M.post('/Game/UserInfo/GetOnlineUsers', {});
        }).then(function (res) {
            var r = M.result(res);
            state.online = (r.ok && r.datas) ? r.datas : [];
            if (!r.ok && res && res.content) M.toast(r.text, 'error');
            renderOnline();
        });
    }

    function updateSubtitle() {
        var todaySum = 0;
        for (var i = 0; i < state.online.length; i++) {
            todaySum += Number(state.online[i].TodayWinLoss || 0);
        }
        var cls = todaySum >= 0 ? 'positive' : 'negative';
        $('#mSubtitle').html(
            '<span>在线 ' + state.online.length + ' 人 · 今日盈亏</span>' +
            '<span class="m-strong ' + cls + '">' + M.signed(todaySum) + '</span>'
        );
    }

    /* ---------------- 全部玩家 ---------------- */

    function renderAll() {
        var $box = $('#mAllList');
        if (!state.all.length) {
            $box.html('<div class="m-empty">没有符合条件的玩家</div>');
        } else {
            var html = [];
            for (var i = 0; i < state.all.length; i++) html.push(allCard(state.all[i]));
            $box.html(html.join(''));
        }
        $('#mAllCount').text(state.allTotal);

        var loaded = state.all.length;
        if (loaded >= state.allTotal) {
            $('#mAllLoadMoreBox').addClass('m-hidden');
            $('#mAllNoMore').toggleClass('m-hidden', loaded === 0);
        } else {
            $('#mAllLoadMoreBox').removeClass('m-hidden');
            $('#mAllNoMore').addClass('m-hidden');
        }
    }

    function loadAll(reset) {
        if (state.allLoading) return $.Deferred().resolve().promise();
        state.allLoading = true;
        if (reset) {
            state.allPage = 0;
            state.all = [];
        }
        var next = state.allPage + 1;
        var $btn = $('#mAllLoadMore').prop('disabled', true).text('加载中...');

        return M.post('/Game/UserInfo/GetUsers', {
            srch_ID: state.search.id,
            srch_NAME: state.search.name,
            srch_Agency: state.search.agency,
            page: next,
            rows: PAGE_SIZE
        }).then(function (res) {
            state.allPage = next;
            state.allTotal = Number(res && res.total ? res.total : 0);
            var rows = (res && res.rows) ? res.rows : [];
            state.all = state.all.concat(rows);
            renderAll();
        }).always(function () {
            state.allLoading = false;
            $btn.prop('disabled', false).text('加载更多');
        });
    }

    /* ---------------- 玩家操作 ---------------- */

    function findPlayer(account, kind) {
        var list = kind === 'online' ? state.online : state.all;
        for (var i = 0; i < list.length; i++) {
            if (String(list[i].ID) === String(account)) return list[i];
        }
        return null;
    }

    function showActions(account, kind) {
        var p = findPlayer(account, kind) || { ID: account };
        var isFrozen = Number(p.FROZEN) === 1;
        var actions = [];

        if (P.canUpDown) {
            actions.push({ label: '充值', type: 'recharge', value: 'recharge' });
            actions.push({ label: '兑换（退分）', type: 'reward', value: 'exchange' });
        }
        actions.push({ label: '查询余额', type: 'details', value: 'query' });
        actions.push({ label: '玩家详情', type: 'details', value: 'detail' });
        if (P.canKick) {
            actions.push({ label: '踢下线', type: 'warn', value: 'kick' });
        }
        if (P.canModifyPwd) {
            actions.push({ label: '修改玩家密码', type: 'track', value: 'pwd' });
        }
        if (P.canFrozen) {
            actions.push({
                label: isFrozen ? '解除冻结' : '冻结账号',
                type: isFrozen ? 'reward' : 'danger',
                value: isFrozen ? 'unfreeze' : 'freeze'
            });
        }

        M.modal({
            title: '玩家账号：' + account,
            subtitle: p.NAME ? '昵称：' + p.NAME : '',
            actions: actions,
            buttons: [{ label: '取消', value: null }]
        }).then(function (v) {
            if (!v) return;
            if (v === 'recharge') {
                window.location.href = '/Mobile/Home/Recharge?id=' + encodeURIComponent(account) + '&pay=0';
            } else if (v === 'exchange') {
                window.location.href = '/Mobile/Home/Recharge?id=' + encodeURIComponent(account) + '&pay=1';
            } else if (v === 'query') {
                queryCoins(account);
            } else if (v === 'detail') {
                showDetail(p, kind);
            } else if (v === 'kick') {
                kickPlayer(account);
            } else if (v === 'pwd') {
                changePlayerPwd(account);
            } else if (v === 'freeze') {
                setFrozen(account, 1);
            } else if (v === 'unfreeze') {
                setFrozen(account, 0);
            }
        });
    }

    function queryCoins(account) {
        M.loading('查询中...');
        M.post('/Game/UserInfo/QueryPlayerCoins', { ID: account })
            .always(M.hideLoading)
            .then(function (res) {
                var r = M.result(res);
                if (!r.ok) { M.toast(r.text, 'error'); return; }
                // QueryTargetCoins 返回 { id, title, coins, displayCoins }
                var d = r.datas || {};
                var body = '<div class="m-kv">' +
                    kv('账号', d.id || account) +
                    kv('账号类型', d.title || '玩家') +
                    kv('剩余金币', M.gold(d.coins)) +
                    '</div>';
                M.modal({ title: '余额查询', bodyHTML: body, buttons: [{ label: '关闭', value: null }] });
            });
    }

    function showDetail(p, kind) {
        var body = '<div class="m-kv">';
        body += kv('账号', p.ID);
        body += kv('昵称', p.NAME || '--');
        body += kv('所属代理', p.AGENCY || '--');
        if (kind === 'online') {
            body += kv('剩余金币', M.gold(p.Coins));
            body += kv('剩余分数', M.num(p.Score));
            body += kv('所在游戏', M.gameName(p.GameID));
            body += kv('房间 / 桌 / 座', (p.RoomId || '--') + ' / ' + (p.TableId || '--') + ' / ' + (p.SeatId || '--'));
            body += kv('当前押注', M.num(p.CurBet));
            body += kv('本局输赢', M.signed(p.CurGameScore));
            body += kv('今日盈亏', M.signed(p.TodayWinLoss));
            body += kv('总盈亏', M.signed(p.Profit));
            body += kv('状态', statusText(p.Status));
        } else {
            body += kv('剩余金币', M.gold(p.COINS));
            body += kv('游戏分数', M.num(p.GAME_SCORE));
            body += kv('保险柜', M.gold(p.SAFE_COINS));
            body += kv('总购币', M.gold(p.COINS_BUY));
            body += kv('总兑换', M.gold(p.COINS_BACK));
            body += kv('总盈亏', M.signed(p.Profit));
            body += kv('手机号', p.TELEPHONE || '--');
            body += kv('等级', p.GRADE != null ? p.GRADE : '--');
            body += kv('状态', Number(p.FROZEN) === 1 ? '已冻结' : (p.INHALL ? '在线' : '离线'));
        }
        body += '</div>';
        M.modal({ title: '玩家详情', bodyHTML: body, buttons: [{ label: '关闭', value: null }] });
    }

    function kv(k, v) {
        return '<div><span class="k">' + M.esc(k) + '</span><span class="v">' + M.esc(v) + '</span></div>';
    }

    function kickPlayer(account) {
        M.confirmDanger('确定要将玩家 ' + account + ' 踢下线吗？', '踢下线').then(function (ok) {
            if (!ok) return;
            M.loading('处理中...');
            M.post('/Game/UserInfo/KickPlayer', { UserID: account })
                .always(M.hideLoading)
                .then(function (res) {
                    var r = M.result(res);
                    M.toast(r.text, r.ok ? 'success' : 'error');
                    if (r.ok) refreshActive(true);
                });
        });
    }

    function changePlayerPwd(account) {
        M.promptInput({
            title: '修改玩家密码',
            subtitle: '账号：' + account,
            label: '新密码',
            type: 'password',
            placeholder: '6-50 位字母或数字',
            emptyMsg: '请输入新密码'
        }).then(function (pwd) {
            if (!pwd) return;
            if (pwd.length < 6) { M.toast('密码至少 6 位', 'error'); return; }
            M.loading('修改中...');
            M.post('/Game/UserInfo/ChgPwd', { ID: account, PWD: pwd })
                .always(M.hideLoading)
                .then(function (res) {
                    var r = M.result(res);
                    M.alert(r.text, r.ok);
                });
        });
    }

    function setFrozen(account, frozen) {
        var word = frozen === 1 ? '冻结' : '解除冻结';
        M.confirmDanger('确定要' + word + '账号 ' + account + ' 吗？', word).then(function (ok) {
            if (!ok) return;
            M.loading('处理中...');
            M.post('/Game/UserInfo/FrozenUser', { ID: account, frozen: frozen })
                .always(M.hideLoading)
                .then(function (res) {
                    var r = M.result(res);
                    if (r.ok) {
                        M.toast(word + '成功', 'success');
                        refreshActive(true);
                    } else {
                        M.toast(r.text, 'error');
                    }
                });
        });
    }

    /* ---------------- 搜索 ---------------- */

    function showSearch() {
        var body =
            '<div class="m-form-group"><label class="m-label">玩家账号</label>' +
            '<input type="text" class="m-input" id="mSchId" placeholder="支持模糊匹配" value="' + M.esc(state.search.id) + '" autocomplete="off"></div>' +
            '<div class="m-form-group"><label class="m-label">昵称</label>' +
            '<input type="text" class="m-input" id="mSchName" placeholder="支持模糊匹配" value="' + M.esc(state.search.name) + '" autocomplete="off"></div>' +
            '<div class="m-form-group"><label class="m-label">所属代理</label>' +
            '<input type="text" class="m-input" id="mSchAgency" placeholder="代理账号" value="' + M.esc(state.search.agency) + '" autocomplete="off"></div>';

        var dlg = M.modal({
            title: '搜索玩家',
            bodyHTML: body,
            buttons: [
                { label: '重置', value: 'reset' },
                { label: '搜索', value: 'ok', type: 'primary' }
            ]
        });

        var $m = dlg.$modal;
        dlg.then(function (v) {
            if (v === 'reset') {
                state.search = { id: '', name: '', agency: '' };
            } else if (v === 'ok') {
                state.search = {
                    id: $.trim($m.find('#mSchId').val()),
                    name: $.trim($m.find('#mSchName').val()),
                    agency: $.trim($m.find('#mSchAgency').val())
                };
            } else {
                return;
            }
            renderSearchTip();
            renderOnline();
            loadAll(true);
        });
    }

    function renderSearchTip() {
        var s = state.search;
        var parts = [];
        if (s.id) parts.push('账号 ' + s.id);
        if (s.name) parts.push('昵称 ' + s.name);
        if (s.agency) parts.push('代理 ' + s.agency);
        var $tip = $('#mSearchTip');
        if (!parts.length) {
            $tip.addClass('m-hidden').empty();
            return;
        }
        $tip.removeClass('m-hidden').html(
            '<span class="m-chip active">' + M.esc(parts.join(' / ')) + '</span>' +
            '<button type="button" class="m-chip" id="mClearSearch">清除筛选</button>'
        );
    }

    /* ---------------- Tab / 刷新 ---------------- */

    function switchTab(tab) {
        state.tab = tab;
        $('.m-tab').removeClass('active').filter('[data-tab="' + tab + '"]').addClass('active');
        $('#mPaneOnline').toggleClass('active', tab === 'online');
        $('#mPaneAll').toggleClass('active', tab === 'all');
        if (tab === 'all' && !state.all.length && !state.allLoading) {
            loadAll(true);
        }
    }

    function refreshActive(silent) {
        if (state.tab === 'online') {
            return M.runRefresh(loadOnline, silent);
        }
        return M.runRefresh(function () { return loadAll(true); }, silent);
    }

    /* ---------------- 事件绑定 ---------------- */

    $(function () {
        $('.m-tabs-header').on('click', '.m-tab', function () {
            switchTab($(this).data('tab'));
        });

        $('#mPaneOnline').on('click', '.m-chip', function () {
            var $c = $(this);
            $('#mPaneOnline .m-chip').removeClass('active');
            $c.addClass('active');
            state.sort = $c.data('sort');
            renderOnline();
        });

        $('#mMain').on('click', '.m-item-card', function () {
            showActions($(this).data('account'), $(this).data('kind'));
        });

        $('#mAllLoadMore').on('click', function () { loadAll(false); });

        $('#mMain').on('click', '#mClearSearch', function () {
            state.search = { id: '', name: '', agency: '' };
            renderSearchTip();
            renderOnline();
            loadAll(true);
        });

        $('#mSearchBtn').on('click', showSearch);
        $('#mRefreshBtn').on('click', function () { refreshActive(false); });

        loadOnline();
    });

})(window, jQuery);
