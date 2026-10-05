# -*- coding: utf-8 -*-
# 一次性补丁：离线玩家列表改「手动刷新 + localStorage 缓存」（phone.players.js，CRLF 文件）。
import io, sys

PATH = r'TTY.Web/Scripts/app/phone/phone.players.js'
NL = '\r\n'

with io.open(PATH, 'r', encoding='utf-8', newline='') as f:
    src = f.read()

def rep(old, new):
    global src
    old_n = old.replace('\n', NL)
    new_n = new.replace('\n', NL)
    if src.count(old_n) != 1:
        print('NOT-UNIQUE-OR-MISSING:')
        print(old_n[:120])
        sys.exit(1)
    src = src.replace(old_n, new_n, 1)

# ---- 1) 离线玩家区块：缓存读写 + 列表渲染/分页器抽出 + loadOffline 改写 ----
rep(
"""    /* ---------------- 离线玩家 ---------------- */

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
    }""",
"""    /* ---------------- 离线玩家 ---------------- */

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
    }""")

# ---- 2) 切页签：离线页签先吃缓存，没有才回源 ----
rep(
"""            if (tab === 'offline' && !offlineLoaded) {
                loadOffline(1, false);
            }""",
"""            if (tab === 'offline' && !offlineLoaded) {
                if (!restoreOfflineFromCache()) loadOffline(1, false);
            }""")

# ---- 3) 初始加载：离线不再自动拉，改还原缓存（无缓存才拉一次） ----
rep(
"""        // 初始加载(离线列表一并拉取:徽标进页即显示离线总数,切到离线页签无需再等待)
        loadTotalWinLoss();
        loadOnline();
        loadOffline(1, false);""",
"""        // 初始加载：在线数据实时拉取；离线列表不自动刷新——还原上次手动刷新留下的
        // 本地缓存（徽标即缓存里的总数），没有可用缓存才拉一次保证首访有数据。
        loadTotalWinLoss();
        loadOnline();
        if (!restoreOfflineFromCache()) loadOffline(1, false);""")

with io.open(PATH, 'w', encoding='utf-8', newline='') as f:
    f.write(src)
print('OK')
