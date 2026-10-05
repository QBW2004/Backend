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
    var offlineRows = []; // 已加载的离线行（翻页累积），也是本地缓存的内容
    var onlinePlayers = [];
    var onlineTotalWinLoss = 0;
    var offlineTotalWinLoss = 0;
    var onlineLoaded = false; // 在线数据是否成功拿到过（区分"确实没人在线"与"游戏服无响应"）
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
     * 进度值原样展示（与电脑端在线用户/用户管理页一致）：ConsumedCoins 是净口径进度，
     * 可能回退为负数，不能取反——取反会把"已吃分 2608"显示成"已吃分 -2608"。
     */
    function activeControlText(control) {
        var mode = Number(control.ControlMode);
        if (mode === 4) {
            return '吃分中... 目标 ' + M.gold(control.TargetCoins) +
                ' 已吃分 ' + M.gold(control.ConsumedCoins);
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
        // 场次/机台号与电脑端同一编号口径（服务端下发 0 基下标，端上统一 +1 显示，
        // 例：电脑端在线用户"桌号"= TableId+1）；押注走 M.betGold（鱼机 ÷10 保留 1 位小数）
        var hallText = isOnline ? (p.RoomId != null ? (Number(p.RoomId) + 1) + '场' : '--') : '--';
        var machineText = isOnline ? (p.TableId != null ? (Number(p.TableId) + 1) : '--') : '--';
        var betText = isOnline ? M.betGold(p.CurBet, p.GameID) : '--';

        var today = Number(p.TodayWinLoss || 0);
        // 总输赢统一取后台口径（user_daily_winloss 累计，与电脑端"总盈亏"、手机端会员盈亏同口径）；
        // 不再优先用游戏服 QA 的 TotalWinLoss——那是本局/本次在线口径，同一玩家在线与离线会显示两个数。
        var total = Number(p.Profit != null ? p.Profit : (p.TotalWinLoss || 0));
        var twColor = today > 0 ? 'positive' : (today < 0 ? 'negative' : '');
        var ttColor = total > 0 ? 'positive' : (total < 0 ? 'negative' : '');

        // 「最后登录」行只给离线卡片：在线玩家看实时游戏状态，不看登录时间（2026-09-29 起在线列表也不再下发该字段）；
        // 无记录时兜底 2000-01-01（UserOptLog 仅保留7天，老玩家无数据）。
        var loginRow = '';
        if (!isOnline) {
            var loginTimeText = p.LastLoginTime ? M.fmtTime(p.LastLoginTime) : '2000-01-01';
            loginRow = '<div class="info-row login-time-row"><div class="info-item">' + M.ICONS.clock +
                '<span class="info-label">最后登录</span><span class="info-value">' + loginTimeText + '</span></div></div>';
        }
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
        var ok = false;
        // 【性能优化】超时 12s → 6s：服务端 QA（查询在线玩家）已加短超时（连接 1s + 读 3s），
        // 游戏服不可达时最坏约 4s 就有确定答案，不必再让转圈空等 12 秒。
        return M.post('/Game/UserInfo/GetOnlineUsers', {}, { timeoutMs: 6000 })
            .then(function (res) {
                // code!=1 = 游戏服不可达（服务端 QA 失败/熔断），不能当成空列表
                if (res && Number(res.code) === 1 && res.datas) {
                    onlinePlayers = res.datas;
                    ok = true;
                } else {
                    ok = false;
                }
            }, function () {
                ok = false;
            })
            .then(function () {
                var $sec = $('#onlinePlayersSection');
                if (!ok) {
                    // 游戏服不可达/超时：保留上一次的列表与人数（清空成"暂无在线玩家"会被误读成
                    // "玩家都下线了"）；从没成功加载过才给提示文案。切换页签时总输赢也维持原值。
                    if (!onlineLoaded) {
                        $sec.html('<div class="no-more-data" style="display: block;">游戏服暂无响应，请稍后重试</div>');
                        $('#onlinePlayerCount').text('--');
                    } else {
                        M.toast('游戏服暂无响应，列表为上次结果', 'warning', 2000);
                    }
                    return;
                }
                onlineLoaded = true;
                onlineTotalWinLoss = onlinePlayers.reduce(function (sum, p) {
                    return sum + Number(p.TodayWinLoss || 0);
                }, 0);
                if ($('.tab[data-tab="online"]').hasClass('active')) renderTotalWinLoss(true);
                // 角标先更新：空列表时原写法提前 return，会把上一次的人数留在页面上
                $('#onlinePlayerCount').text(onlinePlayers.length);
                if (!onlinePlayers.length) {
                    $sec.html('<div class="no-more-data" style="display: block;">暂无在线玩家</div>');
                    return;
                }

                // 【性能优化】立即渲染基础卡片，不等待控制状态
                var html = onlinePlayers.map(function (p) { return playerCardHTML(p, true); }).join('');
                $sec.html(html);

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

    // 离线列表不自动刷新（口径与参考站一致：localStorage 缓存 + 10 分钟 TTL）：
    // 进页/切页签只还原上次手动刷新留下的缓存，不发请求；
    // 手动刷新、换排序、加载更多才真正回源——成功后连控制状态一起回写缓存。
    // 缓存按登录账号分键，同设备换账号登录不会看到上一个账号的列表。
    var OFFLINE_CACHE_TTL = 10 * 60 * 1000;

    function offlineCacheKey() {
        var acct = (window.MConfig && MConfig.user && MConfig.user.accounts) ? String(MConfig.user.accounts) : '';
        return 'm_offline_players_' + acct;
    }

    function saveOfflineCache() {
        try {
            localStorage.setItem(offlineCacheKey(), JSON.stringify({
                ts: Date.now(),
                sort: offlineSort,
                total: offlineTotal,
                rows: offlineRows
            }));
        } catch (e) { }
    }

    function updateOfflinePager() {
        var noMore = offlineRows.length >= offlineTotal;
        $('#loadMoreBtn').toggleClass('disabled', noMore).prop('disabled', noMore);
        $('#noMoreData').toggle(noMore && offlineTotal > 0);
    }

    function renderOfflineList() {
        var $sec = $('#offlinePlayersSection');
        if (!offlineRows.length) {
            $sec.html('<div class="no-more-data" style="display: block;">暂无离线玩家</div>');
        } else {
            $sec.html(offlineRows.map(function (p) { return playerCardHTML(p, false); }).join(''));
        }
        $('#offlinePlayerCount').text(offlineTotal);
        updateOfflinePager();
    }

    /**
     * 进页/切页签时还原缓存：命中且未过期返回 true（不发请求）；
     * 未缓存/过期/解析失败返回 false，由调用方决定是否回源。
     * 空结果（上次刷新时确实没有离线玩家）按未缓存处理，下次进页重试。
     */
    function restoreOfflineFromCache() {
        var cached = null;
        try {
            var raw = localStorage.getItem(offlineCacheKey());
            cached = raw ? JSON.parse(raw) : null;
        } catch (e) { cached = null; }
        if (!cached || !cached.rows || !cached.rows.length) return false;
        if (!cached.ts || Date.now() - Number(cached.ts) > OFFLINE_CACHE_TTL) {
            try { localStorage.removeItem(offlineCacheKey()); } catch (e) { }
            return false;
        }

        offlineSort = cached.sort || offlineSort;
        $('.sort-option').removeClass('active');
        $('.sort-option[data-sort="' + offlineSort + '"]').addClass('active');
        offlineRows = cached.rows;
        offlineTotal = Number(cached.total || 0) || offlineRows.length;
        offlinePage = Math.ceil(offlineRows.length / PAGE_SIZE) || 1;
        offlineLoaded = true;
        renderOfflineList();
        return true;
    }

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
            offlineRows = append ? offlineRows.concat(rows) : rows;
            saveOfflineCache();

            var $sec = $('#offlinePlayersSection');
            if (!offlineRows.length) {
                renderOfflineList();
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
            updateOfflinePager();

            // 【性能优化】先渲染基础卡片，控制状态随后异步补齐——
            // 总控（吃分/放水/控牌）记录存在 usercontrolstatus，与玩家是否在线无关，
            // 离线玩家同样可能有正在执行的控，不能整页跳过查询。
            // 每页仅补一次当前页（≤PAGE_SIZE 个 ID）的查询，开销可控，不阻塞首屏。
            if (rows.length) {
                setTimeout(function () {
                    attachActiveControls(rows).then(function () {
                        applyActiveControls($sec, rows);
                        saveOfflineCache(); // 控制状态补齐后再回写一次，缓存与页面显示一致
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
        closePlayerModal();
        window.location.href = '/Mobile/Home/PrizeHistory?id=' + encodeURIComponent(current.ID);
    }

    /** 游戏记录：独立页面展示（原弹窗浮层已下线） */
    function showGameRecord() {
        if (!current) return;
        closePlayerModal();
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

    /* ---------------- 刷新 ---------------- */

    var refreshing = false;

    /** 在线玩家数据（头部总输赢 + 在线卡片） */
    function reloadOnline() {
        return $.when(loadTotalWinLoss(), loadOnline());
    }

    /** 本页全部数据（头部刷新按钮用：离线列表一并回到第一页） */
    function reloadAll() {
        return $.when(loadTotalWinLoss(), loadOnline(), loadOffline(1, false));
    }

    /** 带转圈与防并发的一次刷新；quiet=true 时不弹"正在刷新中"提示 */
    function runRefresh(loader, quiet) {
        if (refreshing) {
            if (!quiet) M.toast('正在刷新中，请稍候...', 'warning', 1500);
            return;
        }
        refreshing = true;
        // 手动刷新/从控制页返回触发的刷新必须绕过控制状态 30s 缓存，
        // 否则刚下的控制或刚跑完的进度要等缓存过期才看得见
        controlStatusCache = {};
        M.runRefresh(loader, true).always(function () { refreshing = false; });
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
                if (!restoreOfflineFromCache()) loadOffline(1, false);
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
            closePlayerModal();
            window.location.href = '/Mobile/Home/Recharge?id=' + encodeURIComponent(current.ID) + '&pay=0&role=player';
        });
        // 控制：跳转控制管理页（吃分/放水/控牌），预填玩家账号
        $('#modalControlBtn').on('click', function () {
            if (!current) return;
            closePlayerModal();
            window.location.href = '/Mobile/Home/Control?id=' + encodeURIComponent(current.ID);
        });
        // 玩家详细：独立页面展示
        $('#modalDetailsBtn').on('click', function () {
            if (!current) return;
            closePlayerModal();
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
        M.onRefresh(function () { runRefresh(reloadAll, false); });
        M.onSearch(function () {
            $('#searchInput').val('');
            $('#searchResults').empty();
            $('#searchModal').addClass('show');
            setTimeout(function () { $('#searchInput').focus(); }, 120);
        });

        // 从"我的代理 / 我的会员 / 充值管理"返回本页：这些页面改过余额、输赢等数据，
        // 而返回多为 bfcache 恢复（页面不重新加载、JS 状态原样保留），显示的还是旧数据，
        // 需主动重拉。标记由 phone.core.js 在离开那几个页面时写入；若返回是整页重新
        // 加载，数据本来就是新的，只清标记不重复请求（见下方初始加载）。
        // 只补在线数据：离线列表可能已翻到第 N 页，重拉会把列表打回第一页。
        // bfcache 恢复会原样还原离开时的 DOM：若弹窗还开着会一直盖在列表上，
        // 这里兜底关掉（操作按钮跳转前也会先关，双保险）。
        $(window).on('pageshow', function () {
            closePlayerModal();
            $('#searchModal').removeClass('show');
            if (!M.consumePlayersStale()) return;
            runRefresh(reloadOnline, true);
        });

        // 初始加载：在线数据实时拉取；离线列表不自动刷新——还原上次手动刷新留下的
        // 本地缓存（徽标即缓存里的总数），没有可用缓存才拉一次保证首访有数据。
        loadTotalWinLoss();
        loadOnline();
        if (!restoreOfflineFromCache()) loadOffline(1, false);
        M.consumePlayersStale(); // 整页新加载：数据已是新的，丢弃上一页留下的标记
    }

    // 脚本在 body 末尾加载，DOM 已就绪；不依赖 jQuery ready
    //（部分 WebView 中 ready 之后注册的回调不会被执行）
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', initPage);
    } else {
        initPage();
    }

})(window, jQuery, window.MApp);
