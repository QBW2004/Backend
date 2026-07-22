using Newtonsoft.Json;
using System;
using YYT.BLL.EF;
using YYT.Common;
using YYT.Remote;

namespace YYT.BLL.Services.GameServer
{
    /// <summary>
    /// 桌台热更新命令的 Outbox 入箱辅助类。
    /// 保存/删除桌台时，DB 提交后调用本类把 RP(房间重载)/TC(桌台配置)命令写入
    /// gamecommandoutbox 表，请求线程立即返回；由 GameCommandOutboxRetryService
    /// 后台定时重试发送，避免请求线程被命名管道 RPC 阻塞导致页面卡顿。
    /// </summary>
    public static class TableHotUpdateOutbox
    {
        // CommandType 约定（与 GameCommandOutboxRetryService.Retry 的 switch 对齐）
        private const string CmdRoomRefresh = "RP";
        private const string CmdTableConfig = "TC";

        /// <summary>
        /// 入箱一条 RP(房间参数重载) 命令。Center 收到 RP 后按 paragame.ROOM_MAX
        /// 全量重读房间/桌台配置，是让新增/修改桌台对前台可见的关键命令。
        /// 调用前必须确保 ROOM_MAX 已同步(B_SuperPara.SyncRoomMaxToRoomCount)。
        /// </summary>
        public static void EnqueueRoomRefresh(int gameId)
        {
            if (gameId <= 0) return;
            try
            {
                var payload = new { GameId = gameId };
                new B_GameCommandOutbox().Create(CmdRoomRefresh, gameId.ToString(), payload);
            }
            catch (Exception ex)
            {
                // 入箱失败不影响保存主流程(与现状 RPC 失败仍 datas=true 语义一致)，
                // 仅记日志；极端情况下热更新不触发，需人工补发。
                LogHelper.WriteLog(typeof(TableHotUpdateOutbox), "EnqueueRoomRefresh failed: " + ex.Message);
            }
        }

        /// <summary>
        /// 入箱一条 TC(桌台配置热更新) 二进制命令。Payload 以 JSON 存全部 TC 参数
        /// (含可选的 TcBetExt/TcTableExt 扩展字段)，重试时据重组包发送。
        /// </summary>
        public static void EnqueueTableConfig(int tableId, int gameId,
            string tableName, bool enabled, int idleFireTimeoutSec, bool idleFireKickEnabled,
            int maxSeats, SConnect.TcBetExt betExt = null, SConnect.TcTableExt tableExt = null)
        {
            if (gameId <= 0) return;
            int tableIndex = tableId % 1000;
            try
            {
                var payload = new
                {
                    GameId = gameId,
                    TableIndex = tableIndex,
                    TableName = tableName ?? string.Empty,
                    Enabled = enabled,
                    IdleFireTimeoutSec = idleFireTimeoutSec,
                    IdleFireKickEnabled = idleFireKickEnabled,
                    MaxSeats = maxSeats,
                    // 扩展字段：null 时不写入，重试时据此判断是否组包追加
                    TableExt = tableExt == null ? null : new
                    {
                        tableExt.BetMin, tableExt.BetMax, tableExt.OneCoinScore, tableExt.CoinsNeed
                    },
                    BetExt = betExt == null ? null : new
                    {
                        betExt.BetTime, betExt.BetMin, betExt.BetMax, betExt.BankerScoreNeed,
                        betExt.ItemSingleScoreLimit, betExt.ItemAllScoreLimit, betExt.CoinsNeed,
                        betExt.OneCoinScore, betExt.BetScores, betExt.DefaultBetIndex,
                        betExt.IncludeViceDraw, betExt.BetMinVice, betExt.BetMaxVice,
                        betExt.BetMinDraw, betExt.BetMaxDraw
                    }
                };
                new B_GameCommandOutbox().Create(CmdTableConfig, gameId.ToString(), payload);
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(TableHotUpdateOutbox), "EnqueueTableConfig failed: " + ex.Message);
            }
        }
    }
}
