/* ============================================================
   玩家列表页（1:1 复刻参考站 wanjialist）
   数据源：
     - /Game/UserInfo/GetTodayWinLoss   离线页签使用的权限范围内今日输赢合计
     - /Game/UserInfo/GetOnlineUsers    在线玩家（游戏服实时）
     - /Game/UserInfo/GetOfflineUsers   离线玩家分页（支持排序）
     - /Game/UserInfo/GetUsers          搜索玩家
     - /Game/UserInfo/GetVisibleUserRows  按账号取玩家详情
   ============================================================ */
(function (window, $, M) {
    'use strict';

    var PAGE_SIZE = 10;
    var offlinePage = 1;
    var offlineTotal = 0;
    var offlineSort = 'last-time';
    var offlineLoaded = false;
    var onlinePlayers = [];
    var onlineTotalWinLoss = 0;
    var offlineTotalWinLoss = 0;
    var current = null; // 当前操作的玩家（含详情）

    // 【性能优化】控制状态缓存，避免重复查询
    var controlStatusCache = {};
    var controlStatusCacheTime = 30000; // 30秒缓存

    /* ---------------- 头部总输赢 ---------------- */

    function renderTotalWinLoss(isOnline) {
        var total = isOnline ? onlineTotalWinLoss : offlineTotalWinLoss;
        $('#totalWinLossLabel').text(isOnline ? '今日在线玩家总输赢（币）' : '今日所有玩家总输赢（币）');
        var $el = $('#totalWinLoss');
        $el.text(M.gold(total));
        $el.removeClass('positive negative');
        if (total > 0) $el.addClass('positive');
        else if (total < 0) $el.addClass('negative');
    }

    function loadTotalWinLoss() {
        return M.post('/Game/UserInfo/GetTodayWinLoss', {}).then(function (res) {
            offlineTotalWinLoss = res && res.datas ? Number(res.datas.total || 0) : 0;
            renderTotalWinLoss($('.tab[data-tab="online"]').hasClass('active'));
        });
    }

    /* ---------------- 在线玩家控制状态 ---------------- */

    /**
     * 控制状态文案：前缀标明控制正在执行（吃分中/放水中/控牌中），
     * 明细部分与控制管理页（phone.control.js）保持同一口径——
     * 吃分/放水为「目标 N 已吃分/已放分 N」，
     * 控牌为「大字版控制 同花顺(150倍)（1次/5把）」
     * （牌型表见 phone.core.js 的 M.cardControlText，与控制页共用）。
     */
    function activeControlText(control) {
        var mode = Number(control.ControlMode);
        if (mode === 4) {
            return '吃分中... 目标 ' + M.gold(control.TargetCoins) +
                ' 已吃分 ' + M.gold(-Number(control.ConsumedCoins || 0));
        }
        if (mode === 5) {
            return '放水中... 目标 ' + M.gold(control.TargetCoins) +
                ' 已放分 ' + M.gold(control.GrantedCoins);
        }
        if (mode === 6) {
            return '控牌中... ' + M.cardControlText(control.GameId, control.LimitCoins);
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

        // 最后登录行常驻显示：无记录时兜底 2000-01-01（UserOptLog 仅保留7天，老玩家无数据）
        var loginTimeText = p.LastLoginTime ? M.fmtTime(p.LastLoginTime) : '2000-01-01';
        var loginRow = '<div class="info-row login-time-row"><div class="info-item">' + M.ICONS.clock +
            '<span class="info-label">最后登录</span><span class="info-value">' + loginTimeText + '</span></div></div>';
        // 冻结状态不在玩家列表展示（冻结账号统一在"冻结明细/冻结账号"页查看）
        var controls = p.ActiveControls || [];
        var controlRow = controls.length
            ? '<div class="active-control-status">' + controls.map(function (text) {
                return '<div class="active-control-status-item">' + M.esc(text) + '</div>';
            }).join('') + '</div>'
            : '';

        return '' +
            '<div class="player-card' + (isOnline ? '' : ' offline') + '" data-account="' + M.esc(p.ID) + '">' +
                '<div class="player-header">' +
                    '<div class="player-identity">' +
                        '<span class="player-account player-account-link" data-account="' + M.esc(p.ID) + '">' + M.esc(p.ID) + '</span>' +
                        '<span class="player-name">' + M.esc(p.NAME || p.ID) + '</span>' +
                        '<span class="agent-line">' + M.esc(p.AGENCY || '--') + '</span>' +
                    '</div>' +
                    '<div class="player-balances">' +
                        '<span class="remaining-score">' + M.num(p.Score != null ? p.Score : (p.GAME_SCORE || 0)) + '分</span>' +
                        '<span class="remaining-diamond">' + M.gold(p.Coins != null ? p.Coins : p.COINS) + '币</span>' +
                    '</div>' +
                '</div>' +
                '<div class="player-info">' +
                    '<div class="info-row">' +
                        '<div class="info-item"><span class="info-label">游戏</span><span class="info-value">' + M.esc(gameText) + '</span></div>' +
                        '<div class="info-item"><span class="info-label">场次</span><span class="info-value">' + M.esc(hallText) + '</span></div>' +
                        '<div class="info-item"><span class="info-label">机台号</span><span class="info-value">' + M.esc(machineText) + '</span></div>' +
                        '<div class="info-item"><span class="info-label">押注</span><span class="info-value money-value">' + M.esc(betText) + '</span></div>' +
                    '</div>' +
                    '<div class="info-row money-row">' +
                        '<div class="info-item"><span class="info-label">今日输赢(币)</span><span class="info-value money-value ' + twColor + '">' + (today > 0 ? '+' : '') + M.gold(today) + '</span></div>' +
                        '<div class="info-item"><span class="info-label">总输赢(币)</span><span class="info-value money-value ' + ttColor + '">' + (total > 0 ? '+' : '') + M.gold(total) + '</span></div>' +
                    '</div>' +
                    controlRow +
                    loginRow +
                '</div>' +
            '</div>';
    }

    /* ---------------- 在线玩家 ---------------- */

    /**
     * 控制状态异步回填：基础卡渲染后，把查到的控制状态行插进对应卡片。
     * 分页追加后 $sec 内含多页卡片，不能用数组下标对应，故按 data-account 遍历定位。
     * ⚠️ 用 attr() 取原始字符串而非 data()：jQuery 的 data() 会把纯数字账号（如 95000066）
     * 自动转成 number，导致与 p.ID（字符串）严格比较恒不相等，控制状态行插不进去。
     */
    function applyActiveControls($sec, players) {
        players = players || [];
        players.forEach(function (p) {
            if (!p || !p.ID || !p.ActiveControls || !p.ActiveControls.length) return;
            var $card = null;
            $sec.find('.player-card').each(function () {
                if (String($(this).attr('data-account')) === String(p.ID)) {
                    $card = $(this);
                    return false;
                }
            });
            if (!$card || $card.find('.active-control-status').length) return;
            var controlHTML = '<div class="active-control-status">' +
                p.ActiveControls.map(function (text) {
                    return '<div class="active-control-status-item">' + M.esc(text) + '</div>';
                }).join('') +
                '</div>';
            var $login = $card.find('.login-time-row').first();
            if ($login.length) {
                $login.before(controlHTML); // 控制状态行应在最后登录行之前
            } else {
                $card.find('.player-info').append(controlHTML);
            }
        });
    }

    function attachActiveControls(players) {
        players = players || [];
        var ids = players.map(function (p) { return p.ID; }).filter(function (id, index, list) {
            return id && list.indexOf(id) === index;
        });
        if (!ids.length) {
            players.forEach(function (p) { p.ActiveControls = []; });
            return $.Deferred().resolve([]).promise();
        }

        // 【性能优化】检查缓存，减少不必要的网络请求
        var now = Date.now();
        var uncachedIds = [];
        var cachedControls = {};

        ids.forEach(function (id) {
            var cached = controlStatusCache[id];
            if (cached && (now - cached.timestamp) < controlStatusCacheTime) {
                cachedControls[id] = cached.controls;
            } else {
                uncachedIds.push(id);
            }
        });

        // 如果全部命中缓存，直接返回
        if (uncachedIds.length === 0) {
            var controlMap = cachedControls;
            players.forEach(function (p) { p.ActiveControls = controlMap[p.ID] || []; });
            return $.Deferred().resolve([]).promise();
        }

        return M.post('/Game/UserInfo/GetActiveTotalControls', {
            UserIDs: JSON.stringify(uncachedIds)
        }).then(function (res) {
            var controls = res && res.code === 1 ? (res.datas || []) : [];
            var controlMap = groupActiveControls(controls);

            // 【性能优化】更新缓存
            uncachedIds.forEach(function (id) {
                controlStatusCache[id] = {
                    controls: controlMap[id] || [],
                    timestamp: now
                };
            });

            // 合并缓存和新数据
            Object.keys(cachedControls).forEach(function (id) {
                if (!controlMap[id]) controlMap[id] = cachedControls[id];
            });

            players.forEach(function (p) { p.ActiveControls = controlMap[p.ID] || []; });
            return controls;
        }, function () {
            players.forEach(function (p) { p.ActiveControls = []; });
            return [];
        });
    }

    function loadOnline() {
        return M.post('/Game/UserInfo/GetOnlineUsers', {}, { timeoutMs: 12000 })
            .then(function (res) {
                onlinePlayers = (res && res.datas) ? res.datas : [];
            }, function () {
                // 游戏服不可达 / 超时：按空列表处理
                onlinePlayers = [];
            })
            .then(function () {
                onlineTotalWinLoss = onlinePlayers.reduce(function (sum, p) {
                    return sum + Number(p.TodayWinLoss || 0);
                }, 0);
                if ($('.tab[data-tab="online"]').hasClass('active')) renderTotalWinLoss(true);
                var $sec = $('#onlinePlayersSection');
                if (!onlinePlayers.length) {
                    $sec.html('<div class="no-more-data" style="display: block;">暂无在线玩家</div>');
                    return;
                }

                // 【性能优化】立即渲染基础卡片，不等待控制状态
                var html = onlinePlayers.map(function (p) { return playerCardHTML(p, true); }).join('');
                $sec.html(html);
                $('#onlinePlayerCount').text(onlinePlayers.length);

                // 【性能优化】异步加载控制状态，不阻塞首屏
                // 使用 setTimeout 确保首屏渲染完全完成后再请求次要数据
                setTimeout(function () {
                    attachActiveControls(onlinePlayers).then(function () {
                        if (!onlinePlayers.length) return;
                        applyActiveControls($sec, onlinePlayers);
                    });
                }, 100);
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
                return;
            }

            // 【性能优化】立即渲染基础卡片
            var html = rows.map(function (p) { return playerCardHTML(p, false); }).join('');
            if (!append) {
                $sec.html(html);
            } else {
                $sec.append(html);
            }
            $('#offlinePlayerCount').text(offlineTotal);

            var loaded = (page - 1) * PAGE_SIZE + rows.length;
            var noMore = loaded >= offlineTotal;
            $('#loadMoreBtn').toggleClass('disabled', noMore).prop('disabled', noMore);
            $('#noMoreData').toggle(noMore && offlineTotal > 0);

            // 【性能优化】先渲染基础卡片，控制状态随后异步补齐——
            // 总控（吃分/放水/控牌）记录存在 usercontrolstatus，与玩家是否在线无关，
            // 离线玩家同样可能有正在执行的控，不能整页跳过查询。
            // 每页仅补一次当前页（≤PAGE_SIZE 个 ID）的查询，开销可控，不阻塞首屏。
            if (rows.length) {
                setTimeout(function () {
                    attachActiveControls(rows).then(function () {
                        applyActiveControls($sec, rows);
                    });
                }, 50);
            }
        });
    }

    /* ---------------- 玩家操作弹窗 ---------------- */

    function openPlayerModal(account) {
        // 纯数字账号经 jQuery data() 会变成 number，先字符串化再入参/入 JSON
        account = String(account == null ? '' : account);
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

    function showPrizeHistory() {
        if (!current) return;
        window.location.href = '/Mobile/Home/PrizeHistory?id=' + encodeURIComponent(current.ID);
    }

    /** 游戏记录：独立页面展示（原弹窗浮层已下线） */
    function showGameRecord() {
        if (!current) return;
        window.location.href = '/Mobile/Home/GameRecord?id=' + encodeURIComponent(current.ID);
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
        var byId = M.post('/Game/UserInfo/GetUsers', { srch_ID: kw, srch_NAME: '', srch_Agency: '', page: 1, rows: 20 })
            .then(function (res) { return (res && res.rows) ? res.rows : []; }, function () { return []; });
        var byName = M.post('/Game/UserInfo/GetUsers', { srch_ID: '', srch_NAME: kw, srch_Agency: '', page: 1, rows: 20 })
            .then(function (res) { return (res && res.rows) ? res.rows : []; }, function () { return []; });
        $.when(byId, byName).then(function (idRows, nameRows) {
                var rows = [];
                (idRows || []).concat(nameRows || []).forEach(function (row) {
                    if (!row || !row.ID || rows.some(function (item) { return item.ID === row.ID; })) return;
                    rows.push(row);
                });
                return rows;
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
                        '<div class="search-result-info">' + M.esc(p.AGENCY || '--') + ' · 余额: ' + M.gold(p.COINS) + '币</div>' +
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
            renderTotalWinLoss(tab === 'online');
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
        $(document).on('click', '.player-account-link', function (e) {
            e.stopPropagation();
            var account = $(this).data('account');
            if (account) window.location.href = '/Mobile/Home/PlayerDetail?id=' + encodeURIComponent(String(account));
        });
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
        $('#modalTrackBtn').on('click', showGameRecord);

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
        // 【性能优化】添加防抖，避免快速点击导致多次并发请求
        var refreshing = false;
        M.onRefresh(function () {
            if (refreshing) {
                M.toast('正在刷新中，请稍候...', 'warning', 1500);
                return;
            }
            refreshing = true;
            M.runRefresh(function () {
                return $.when(loadTotalWinLoss(), loadOnline(), loadOffline(1, false));
            }, true).always(function () {
                refreshing = false;
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
