# -*- coding: utf-8 -*-
# 一次性补丁：ViewContractTest 追加「离线列表手动刷新 + 本地缓存」契约用例（CRLF 文件）。
import io, sys

PATH = r'UnitTestProj/ViewContractTest.cs'
NL = '\r\n'

with io.open(PATH, 'r', encoding='utf-8', newline='') as f:
    src = f.read()

anchor = (
    '            // 在线人数角标在空列表时也要归零（原写法在 return 之后，人数会停在上一次的值）' + NL +
    "            StringAssert.Contains(playersScript, \"$('#onlinePlayerCount').text(onlinePlayers.length);\");" + NL +
    '        }' + NL
)
assert src.count(anchor) == 1, 'anchor not unique'

new_test = '''
        [TestMethod]
        public void MobileOfflinePlayerListIsManualRefreshWithLocalCache()
        {
            string playersScript = ReadRepoFile(@"TTY.Web\\Scripts\\app\\phone\\phone.players.js");

            // 离线列表不自动刷新（口径与参考站一致）：进页/切页签只还原 localStorage 缓存
            //（10 分钟 TTL、按登录账号分键防止同设备换号串数据），缓存未命中才回源；
            // 手动刷新/换排序/加载更多成功后回写缓存（含控制状态异步补齐后的二次回写）。
            StringAssert.Contains(playersScript, "var OFFLINE_CACHE_TTL = 10 * 60 * 1000;");
            StringAssert.Contains(playersScript, "function offlineCacheKey()");
            StringAssert.Contains(playersScript, "'m_offline_players_' + acct");
            StringAssert.Contains(playersScript, "function saveOfflineCache()");
            StringAssert.Contains(playersScript, "localStorage.setItem(offlineCacheKey()");
            StringAssert.Contains(playersScript, "function restoreOfflineFromCache()");
            StringAssert.Contains(playersScript, "localStorage.getItem(offlineCacheKey())");
            StringAssert.Contains(playersScript, "localStorage.removeItem(offlineCacheKey())");

            // 进页与首次切到离线页签都是「先吃缓存，没有再拉」，不存在无条件 loadOffline 自动拉取
            Assert.AreEqual(2, Regex.Matches(playersScript,
                Regex.Escape("if (!restoreOfflineFromCache()) loadOffline(1, false);")).Count,
                "进页与切页签都必须先还原缓存、未命中才回源");

            // 每次回源成功后都要回写缓存：loadOffline 主回写 + 控制状态补齐后的二次回写
            Assert.IsTrue(Regex.Matches(playersScript, Regex.Escape("saveOfflineCache();")).Count >= 2,
                "loadOffline 成功后与控制状态补齐后都必须回写缓存");
            StringAssert.Contains(playersScript, "offlineRows = append ? offlineRows.concat(rows) : rows;");
        }
'''

src = src.replace(anchor, anchor + new_test, 1)

with io.open(PATH, 'w', encoding='utf-8', newline='') as f:
    f.write(src)
print('OK')
