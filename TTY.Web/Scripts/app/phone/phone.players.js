/* ============================================================
   玩家列表页（1:1 复刻参考站 wanjialist）
   数据源：
     - /Game/UserInfo/GetTodayWinLoss   今日玩家总输赢合计
     - /Game/UserInfo/GetOnlineUsers    在线玩家（游戏服实时）
     - /Game/UserInfo/GetOfflineUsers   离线玩家分页（支持排序）
     - /Game/UserInfo/GetUsers          搜索玩家
     - /Game/UserInfo/GetVisibleUserRows  按账号取玩家详情
     - /Game/UserRecord/GetUserRecords  玩家当日游戏记录（中奖历史 / 游戏记录）
   ============================================================ */
(function (window, $, M) {
    'use strict';

    var PAGE_SIZE = 10;
    var offlinePage = 1;
    var offlineTotal = 0;
    var offlineSort = 'last-time';
    var offlineLoaded = false;
    var onlinePlayers = [];
    var current = null; // 当前操作的玩家（含详情）

    function todayStr() {
        var d = new Date();
        return d.getFullYear() + '-' + M.pad2(d.getMonth() + 1) + '-' + M.pad2(d.getDate());
    }

    /* ---------------- 头部总输赢 ---------------- */

    function loadTotalWinLoss() {
        return M.post('/Game/UserInfo/GetTodayWinLoss', {}).then(function (res) {
            var total = res && res.datas ? Number(res.datas.total || 0) : 0;
            var $el = $('#totalWinLoss');
            $el.text(M.gold(total));
            $el.removeClass('positive negative');
            if (total > 0) $el.addClass('positive');
            else if (total < 0) $el.addClass('negative');
        });
    }

    /* ---------------- 在线玩家控制状态 ---------------- */

    function activeControlText(control) {
        var mode = Number(control.ControlMode);
        if (mode === 4) {
            return '吃分中... 吃分目标 ' + M.gold(control.TargetCoins) +
                ' / 已吃 ' + M.gold(-Number(control.ConsumedCoins || 0));
        }
        if (mode === 5) {
            return '放分中... 放分目标 ' + M.gold(control.TargetCoins) +
                ' / 已放 ' + M.gold(control.GrantedCoins);
        }
        if (mode === 6) {
            var total = Number(control.CardTotal || control.TargetCoins || 0);
            var remaining = Number(control.CardNumber || 0);
            if (total <= 0 || remaining <= 0) return '';
            return '控牌中... 控牌值 ' + M.num(control.LimitCoins) +
                ' / 次数 ' + (total - remaining) + ' / ' + total;
        }
        return '';
    }

    function groupActiveControls(rows) {
        var map = {};
        (rows || []).forEach(function (control) {
            var text = activeControlText(control);
            if (!text || !control.UserID) return;
            if (!map[control.UserID]) map[control.UserID] = [];
            map[control.UserID].push(text);
        });
        return map;
    }

    /* ---------------- 卡片渲染 ---------------- */

    function playerCardHTML(p, isOnline) {
        var gameText = isOnline ? (M.gameName(p.GameID) || '--') : '--';
        var hallText = isOnline ? (p.RoomId != null ? p.RoomId + '场' : '--') : '--';
        var machineText = isOnline ? (p.TableId != null ? p.TableId : '--') : '--';
        var betText = isOnline ? (p.CurBet != null ? M.gold(p.CurBet) : '--') : '--';

        var today = Number(p.TodayWinLoss || 0);
        var total = Number(p.TotalWinLoss != null ? p.TotalWinLoss : (p.Profit || 0));
        var twColor = today > 0 ? 'positive' : (today < 0 ? 'negative' : '');
        var ttColor = total > 0 ? 'positive' : (total < 0 ? 'negative' : '');

        var blackBadge = (p.FROZEN === 1) ? '<span class="black-listed">拉黑中</span>' : '';
        var loginRow = (!isOnline && p.LastLoginTime)
            ? '<div class="info-row login-time-row"><div class="info-item">' + M.ICONS.clock +
                '<span class="info-label">最后登录</span><span class="info-value">' + M.fmtTime(p.LastLoginTime) + '</span></div></div>'
            : '';
        var controls = isOnline && p.ActiveControls ? p.ActiveControls : [];
        var controlRow = controls.length
            ? '<div class="active-control-status">' + controls.map(function (text) {
                return '<div class="active-control-status-item">' + M.esc(text) + '</div>';
            }).join('') + '</div>'
            : '';

        return '' +
            '<div class="player-card' + (isOnline ? '' : ' offline') + '" data-account="' + M.esc(p.ID) + '">' +
                '<div class="player-header">' +
                    '<span class="player-account">' + M.esc(p.ID) + '</span>' +
                    '<span class="player-name">' + M.esc(p.NAME || p.ID) + '</span>' +
                    blackBadge +
                    '<span class="agent-line">代理:' + M.esc(p.AGENCY || '--') + '</span>' +
                    '<span class="remaining-score">' + M.num(p.Score != null ? p.Score : (p.GAME_SCORE || 0)) + '分</span>' +
                    '<span class="remaining-diamond">' + M.gold(p.Coins != null ? p.Coins : p.COINS) + '金币</span>' +
                '</div>' +
                '<div class="player-info">' +
                    '<div class="info-row">' +
                        '<div class="info-item"><span class="info-label">游戏</span><span class="info-value">' + M.esc(gameText) + '</span></div>' +
                        '<div class="info-item"><span class="info-label">场次</span><span class="info-value">' + M.esc(hallText) + '</span></div>' +
                        '<div class="info-item"><span class="info-label">机台号</span><span class="info-value">' + M.esc(machineText) + '</span></div>' +
                        '<div class="info-item"><span class="info-label">押注</span><span class="info-value money-value">' + M.esc(betText) + '</span></div>' +
                    '</div>' +
                    '<div class="info-row money-row">' +
                        '<div class="info-item"><span class="info-label">今日输赢(金币)</span><span class="info-value money-value ' + twColor + '">' + (today > 0 ? '+' : '') + M.gold(today) + '</span></div>' +
                        '<div class="info-item"><span class="info-label">总输赢(金币)</span><span class="info-value money-value ' + ttColor + '">' + (total > 0 ? '+' : '') + M.gold(total) + '</span></div>' +
                    '</div>' +
                    loginRow +
                '</div>' +
                controlRow +
            '</div>';
    }

    /* ---------------- 在线玩家 ---------------- */

    function loadOnline() {
        return M.post('/Game/UserInfo/GetOnlineUsers', {}, { timeoutMs: 12000 })
            .then(function (res) {
                onlinePlayers = (res && res.datas) ? res.datas : [];
            }, function () {
                // 游戏服不可达 / 超时：按空列表处理
                onlinePlayers = [];
            })
            .then(function () {
                var ids = onlinePlayers.map(function (p) { return p.ID; }).filter(function (id, index, list) {
                    return id && list.indexOf(id) === index;
                });
                if (!ids.length) return [];
                return M.post('/Game/UserInfo/GetActiveTotalControls', {
                    UserIDs: JSON.stringify(ids)
                }).then(function (res) {
                    return res && res.code === 1 ? (res.datas || []) : [];
                }, function () {
                    return [];
                });
            })
            .then(function (controls) {
                var controlMap = groupActiveControls(controls);
                onlinePlayers.forEach(function (p) {
                    p.ActiveControls = controlMap[p.ID] || [];
                });
            })
            .then(function () {
                var $sec = $('#onlinePlayersSection');
                if (!onlinePlayers.length) {
                    $sec.html('<div class="no-more-data" style="display: block;">暂无在线玩家</div>');
                } else {
                    var html = onlinePlayers.map(function (p) { return playerCardHTML(p, true); }).join('');
                    $sec.html(html);
                }
                $('#onlinePlayerCount').text(onlinePlayers.length);
            });
    }

    /* ---------------- 离线玩家 ---------------- */

    function loadOffline(page, append) {
        return M.post('/Game/UserInfo/GetOfflineUsers', {
            srch_ID: '', srch_NAME: '', srch_Agency: '',
            sort: offlineSort,
            page: page, rows: PAGE_SIZE
        }).then(function (list) {
            var rows = (list && list.rows) ? list.rows : [];
            offlineTotal = list ? Number(list.total || 0) : 0;
            offlinePage = page;
            offlineLoaded = true;

            var $sec = $('#offlinePlayersSection');
            if (!rows.length && page === 1) {
                $sec.html('<div class="no-more-data" style="display: block;">暂无离线玩家</div>');
            } else if (!append) {
                $sec.html(rows.map(function (p) { return playerCardHTML(p, false); }).join(''));
            } else {
                $sec.append(rows.map(function (p) { return playerCardHTML(p, false); }).join(''));
            }
            $('#offlinePlayerCount').text(offlineTotal);

            var loaded = (page - 1) * PAGE_SIZE + rows.length;
            var noMore = loaded >= offlineTotal;
            $('#loadMoreBtn').toggleClass('disabled', noMore).prop('disabled', noMore);
            $('#noMoreData').toggle(noMore && offlineTotal > 0);
        });
    }

    /* ---------------- 玩家操作弹窗 ---------------- */

    function openPlayerModal(account) {
        M.loading('加载玩家信息...');
        M.post('/Game/UserInfo/GetVisibleUserRows', { UserIDs: JSON.stringify([account]) })
            .always(M.hideLoading)
            .then(function (res) {
                var row = (res && res.datas && res.datas.length) ? res.datas[0] : null;
                if (!row) {
                    M.toast('未获取到玩家信息', 'error');
                    return;
                }
                current = row;
                current.INHALL = current.INHALL || false;
                $('#modalPlayerAccount').text('玩家账号:' + row.ID);
                $('#modalPlayerName').text('玩家名称:' + (row.NAME || row.ID));
                $('#playerModal').addClass('show');
            });
    }

    function closePlayerModal() {
        $('#playerModal').removeClass('show');
    }

    /** 玩家当日游戏记录（中奖历史 / 游戏记录共用） */
    function loadPlayerRecords(account) {
        return M.post('/Game/UserRecord/GetUserRecords', { ID: account, TIME: todayStr(), page: 1, rows: 20 })
            .then(function (list) {
                return (list && list.rows) ? list.rows : [];
            }, function () {
                return [];
            });
    }

    function showPrizeHistory() {
        if (!current) return;
        M.loading('查询中...');
        loadPlayerRecords(current.ID).always(M.hideLoading).then(function (rows) {
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
        if (!current) return;
        M.loading('查询中...');
        loadPlayerRecords(current.ID).always(M.hideLoading).then(function (rows) {
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
                    '账号 ' + M.esc(current.ID) + ' 的今日游戏记录:' + lines + '</div>';
            }
            M.modal({
                title: '游戏记录',
                bodyHTML: body,
                buttons: [{ label: '关闭', value: null, type: 'confirm' }]
            });
        });
    }

    /* ---------------- 搜索 ---------------- */

    function runSearch() {
        var kw = $.trim($('#searchInput').val());
        var $box = $('#searchResults');
        if (!kw) {
            $box.html('<div class="no-data" style="padding:20px 0;">请输入玩家账号或昵称</div>');
            return;
        }
        $box.html('<div class="no-data" style="padding:20px 0;">搜索中...</div>');
        M.post('/Game/UserInfo/GetUsers', { srch_ID: kw, srch_NAME: '', srch_Agency: '', page: 1, rows: 20 })
            .then(function (byId) {
                var rows = (byId && byId.rows) ? byId.rows : [];
                if (rows.length) return rows;
                return M.post('/Game/UserInfo/GetUsers', { srch_ID: '', srch_NAME: kw, srch_Agency: '', page: 1, rows: 20 })
                    .then(function (byName) { return (byName && byName.rows) ? byName.rows : []; });
            })
            .then(function (rows) {
                if (!rows.length) {
                    $box.html('<div class="no-data" style="padding:20px 0;">未找到玩家</div>');
                    return;
                }
                $box.html(rows.map(function (p) {
                    var online = p.INHALL === true;
                    return '<div class="search-result-item" data-account="' + M.esc(p.ID) + '">' +
                        '<div class="search-result-header">' +
                            '<span class="search-result-account">' + M.esc(p.ID) + '</span>' +
                            '<span class="search-result-name">' + M.esc(p.NAME || '') + '</span>' +
                            '<span class="search-result-status ' + (online ? 'online' : 'offline') + '">' + (online ? '在线' : '离线') + '</span>' +
                        '</div>' +
                        '<div class="search-result-info">代理: ' + M.esc(p.AGENCY || '--') + ' · 余额: ' + M.gold(p.COINS) + '金币</div>' +
                        '</div>';
                }).join(''));
            });
    }

    /* ---------------- 初始化 ---------------- */

    function initPage() {
        M.loadGames();

        // 页签切换
        $('.tab').on('click', function () {
            var tab = $(this).data('tab');
            $('.tab').removeClass('active');
            $(this).addClass('active');
            $('.tab-pane').removeClass('active');
            $('#' + tab + 'Tab').addClass('active');
            if (tab === 'offline' && !offlineLoaded) {
                loadOffline(1, false);
            }
        });

        // 排序
        $('.sort-option').on('click', function () {
            var sort = $(this).data('sort');
            if (sort === offlineSort) return;
            $('.sort-option').removeClass('active');
            $(this).addClass('active');
            offlineSort = sort;
            loadOffline(1, false);
        });

        // 加载更多
        $('#loadMoreBtn').on('click', function () {
            if ($(this).hasClass('disabled')) return;
            loadOffline(offlinePage + 1, true);
        });

        // 卡片点击 -> 玩家操作弹窗
        $(document).on('click', '.player-card', function () {
            openPlayerModal($(this).data('account'));
        });

        // 玩家操作弹窗按钮
        $('#modalCancelBtn').on('click', closePlayerModal);
        $('#playerModal').on('click', function (e) {
            if (e.target === this) closePlayerModal();
        });
        $('#modalRechargeBtn').on('click', function () {
            if (!current) return;
            window.location.href = '/Mobile/Home/Recharge?id=' + encodeURIComponent(current.ID) + '&pay=0&role=player';
        });
        // 控制：跳转控制管理页（吃分/放水/控牌），预填玩家账号
        $('#modalControlBtn').on('click', function () {
            if (!current) return;
            window.location.href = '/Mobile/Home/Control?id=' + encodeURIComponent(current.ID);
        });
        // 玩家详细：独立页面展示
        $('#modalDetailsBtn').on('click', function () {
            if (!current) return;
            window.location.href = '/Mobile/Home/PlayerDetail?id=' + encodeURIComponent(current.ID);
        });
        $('#modalPrizeHistoryBtn').on('click', showPrizeHistory);
        $('#modalTrackBtn').on('click', showGameTrack);

        // 搜索弹窗
        $('#searchModalCancelBtn').on('click', function () { $('#searchModal').removeClass('show'); });
        $('#searchModal').on('click', function (e) {
            if (e.target === this) $(this).removeClass('show');
        });
        $('#searchSubmitBtn').on('click', runSearch);
        $('#searchInput').on('keydown', function (e) {
            if (e.keyCode === 13) runSearch();
        });
        $(document).on('click', '.search-result-item', function () {
            var acc = $(this).data('account');
            $('#searchModal').removeClass('show');
            openPlayerModal(acc);
        });

        // 头部刷新 / 搜索
        M.onRefresh(function () {
            M.runRefresh(function () {
                return $.when(loadTotalWinLoss(), loadOnline(), loadOffline(1, false));
            });
        });
        M.onSearch(function () {
            $('#searchInput').val('');
            $('#searchResults').empty();
            $('#searchModal').addClass('show');
            setTimeout(function () { $('#searchInput').focus(); }, 120);
        });

        // 初始加载(离线列表一并拉取:徽标进页即显示离线总数,切到离线页签无需再等待)
        loadTotalWinLoss();
        loadOnline();
        loadOffline(1, false);
    }

    // 脚本在 body 末尾加载，DOM 已就绪；不依赖 jQuery ready
    //（部分 WebView 中 ready 之后注册的回调不会被执行）
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', initPage);
    } else {
        initPage();
    }

})(window, jQuery, window.MApp);
