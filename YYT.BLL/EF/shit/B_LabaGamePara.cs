using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using YYT.Common;
using YYT.Entity;
using YYT.Remote;

namespace YYT.BLL.EF
{
    public class B_LabaGamePara : IGamePara
    {
        public Dictionary<string, dynamic> GetGameParams(int gameId)
        {
            Dictionary<string, dynamic> kv = new Dictionary<string, dynamic>();
            using (var ef = new GameDbContext())
            {
                // 房间参数
                var roomParas = ef.GameConfigLabas.Where(c => c.GameId == gameId).ToList();
                if (roomParas != null && roomParas.Count > 0)
                    kv.Add("1", roomParas);
                else
                    kv.Add("1", new List<M_GameConfigLaba>());
                // 机台参数
                kv.Add("2", new List<M_GameConfigLaba>());
            }
            return kv;
        }

        public Msg SaveRoomPara<T>(T t)
        {
            return SaveRoomPara(t, null);
        }

        /// <param name="tableName">拉霸桌名；非空时保存后追加发 TC 命令同步到 roomtableconfig。</param>
        public Msg SaveRoomPara<T>(T t, string tableName)
        {
            Msg msg = new Msg(0, "保存失败！");
            List<M_GameConfigLaba> list = t as List<M_GameConfigLaba>;
            if (list != null && list.Count > 0)
            {
                int gameId = list[0].GameId;
                using (var ef = new GameDbContext())
                {
                    var rst = ef.GameConfigLabas.Where(c => c.GameId == gameId).ToList();
                    if (rst == null || rst.Count == 0)
                    {
                        msg.content = "游戏服务器未对参数进行初始化！";
                        return msg;
                    }
                    else
                    {
                        M_GameConfigLaba tmpObj = null;
                        rst.ForEach((row) =>
                        {
                            if (gameId == 39)
                            {
                                // 玩家赢比例（原来的区域2控制）
                                if (row.OptKey.Equals("AIWinLuckyAtA2"))
                                {
                                    tmpObj = list.Find((_list) => { return _list.OptKey.Equals("AIWinLuckyAtA2"); });
                                    row.OptValue = tmpObj != null && tmpObj.OptValue > -1 ? tmpObj.OptValue : row.OptValue;
                                    ef.Entry(row).State = EntityState.Modified;
                                }
                            }
                            else if (gameId == 40 || gameId == 41)
                            {
                                // 玩家赢比例
                                if (row.OptKey.Equals("PlayerWin"))
                                {
                                    tmpObj = list.Find((_list) => { return _list.OptKey.Equals("PlayerWin"); });
                                    row.OptValue = tmpObj != null && tmpObj.OptValue > -1 ? tmpObj.OptValue : row.OptValue;
                                    ef.Entry(row).State = EntityState.Modified;
                                }
                            }
                            // 金币兑换比例
                            if (row.OptKey.Equals("ExchangeScore"))
                            {
                                tmpObj = list.Find((_list) => { return _list.OptKey.Equals("ExchangeScore"); });
                                row.OptValue = tmpObj != null && tmpObj.OptValue > 0 ? tmpObj.OptValue : row.OptValue;
                                ef.Entry(row).State = EntityState.Modified;
                            }
                        });
                        // 保存更新
                        int val = ef.SaveChanges();
                        if (val > 0)
                        {
                            var srv = new SConnect();
                            var tmpMsg = srv.SendReadString(EScMsgType.RP, gameId);
                            msg.code = tmpMsg.code;
                            msg.content = tmpMsg.content;

                            // 追加发送 TC(桌名) 命令：拉霸单桌台，tableId=gameId(偏移0)，roomIndex=0。
                            // 拉霸无 IdleFire/MaxSeats 概念，传默认值(不开踢出、6座)。

                            if (!string.IsNullOrEmpty(tableName))
                            {
                                try
                                {
                                    var srv2 = new SConnect();
                                    var tc = srv2.SendTcCommand(
                                        (ushort)gameId, 0, 0,
                                        tableName, 1, 0u, 0, 6);
                                    if (tc != null && tc.code == 1)
                                    {
                                        if (!string.IsNullOrEmpty(tc.content))
                                            msg.content = (string.IsNullOrEmpty(msg.content) ? "" : msg.content + " ") + tc.content;
                                    }
                                    else
                                    {
                                        // DB 已落库，TC 失败仅追加提示。
                                        msg.datas = true;
                                        string tcErr = tc == null ? "服务端无响应。" : tc.content;
                                        msg.content = (string.IsNullOrEmpty(msg.content) ? "保存成功" : msg.content) + "，但桌名热更新失败：" + tcErr;
                                    }
                                }
                                catch (Exception exTc)
                                {
                                    LogHelper.WriteLog(typeof(B_LabaGamePara), exTc);
                                    msg.datas = true;
                                    msg.content = (string.IsNullOrEmpty(msg.content) ? "保存成功" : msg.content) + "，但桌名热更新异常：" + exTc.Message;
                                }
                            }
                        }
                    }
                }
            }
            return msg;
        }

        public Msg SaveDeskPara<T>(T t)
        {
            throw new NotImplementedException();
        }

        public List<M_GameRoomDeskPara> GetGameRoomDeskPara(int gameId)
        {
            throw new NotImplementedException();
        }

        /// <summary>
        /// 获取拉霸桌台索引列表（按 TableIndex 升序）
        /// 改后：读 roomtableconfig 而非 gameconfiglaba（对齐一房N桌模型）
        /// </summary>
        public List<int> GetTableList(int gameId)
        {
            using (var ef = new GameDbContext())
            {
                return ef.Database.SqlQuery<int>(
                    "SELECT TableIndex FROM roomtableconfig WHERE GAME_ID={0} ORDER BY TableIndex", gameId).ToList();
            }
        }

        /// <summary>
        /// 保存拉霸桌台全量参数（写 paralaba + gameconfiglaba，同步一房N桌）
        /// </summary>
        /// <param name="tableId">完整桌ID = gameId*1000+tableIndex</param>
        /// <param name="gameId">游戏ID</param>
        /// <param name="paras">gameconfiglaba 参数列表（保留写入保证 C++ 兼容）</param>
        /// <param name="laba">paralaba 结构化参数（新表）</param>
        /// <param name="tableName">桌名</param>
        /// <param name="enabled">是否启用</param>
        public Msg SaveTableFull(int tableId, int gameId, List<M_GameConfigLaba> paras, M_ParaLaba laba, string tableName, int enabled = 1)
        {
            Msg msg = new Msg(0, "保存失败！");
            int tableIndex = tableId % 1000;
            using (var ef = new GameDbContext())
            {
                using (var trans = ef.Database.BeginTransaction())
                {
                    try
                    {
                        // ── 1. 写 gameconfiglaba（保留兼容）──
                        // 加芬幅度是游戏级全局参数：中心服 GetGameConfigParams 按 GameId 读全表
                        // （不按 TableIndex 过滤、无 ORDER BY），同 OptKey 多行时后写覆盖先写，
                        // 多桌各存一行会互相覆盖导致服务端下发值不可控（改 A 桌被 B 桌旧值覆盖）。
                        // 统一落 TableIndex=0 单行：保存任意桌台时先清除该游戏其它行的 scoreSwitchX10。
                        var swPara = paras.FirstOrDefault(p => p.OptKey == "scoreSwitchX10");
                        if (swPara != null && swPara.OptValue > -1)
                        {
                            ef.Database.ExecuteSqlCommand(
                                "DELETE FROM GameConfigLaba WHERE GameId={0} AND OptKey='scoreSwitchX10'", gameId);
                            ef.GameConfigLabas.Add(new M_GameConfigLaba
                            {
                                GameId = gameId,
                                TableIndex = 0,
                                OptKey = "scoreSwitchX10",
                                OptValue = swPara.OptValue,
                                TIME = DateTime.Now,
                                Type = "Room"
                            });
                        }
                        var rst = ef.GameConfigLabas.Where(c => c.GameId == gameId && c.TableIndex == tableIndex).ToList();
                        foreach (var p in paras)
                        {
                            if (p.OptKey == "scoreSwitchX10") continue;  // 已在上方统一落 TableIndex=0
                            var existing = rst.FirstOrDefault(r => r.OptKey == p.OptKey);
                            if (existing != null && p.OptValue > -1)
                            {
                                existing.OptValue = p.OptValue;
                                ef.Entry(existing).State = EntityState.Modified;
                            }
                            else if (p.OptValue > -1)
                            {
                                p.GameId = gameId;
                                p.TableIndex = tableIndex;
                                ef.GameConfigLabas.Add(p);
                            }
                        }

                        // ── 2. 写 paralaba（新结构化表）──
                        if (laba != null)
                        {
                            ef.Database.ExecuteSqlCommand(
                                "DELETE FROM paralaba WHERE GAME_ID={0} AND TableIndex={1}", gameId, tableIndex);
                            ef.Database.ExecuteSqlCommand(
                                "INSERT INTO paralaba(ID,GAME_ID,TableIndex,SubType,DIF,HAR," +
                                "Payout0,Payout1,Payout2,Payout3,Payout4,Payout5,Payout6,Payout7,Payout8," +
                                "Prob0,Prob1,Prob2,Prob3,Prob4,Prob5,Prob6,Prob7,Prob8," +
                                "WheelProb0,WheelProb1,WheelProb2,WheelProb3,WheelProb4,WheelProb5,WheelProb6,WheelProb7," +
                                "WheelProb8,WheelProb9,WheelProb10,WheelProb11,WheelProb12,WheelProb13,WheelProb14,WheelProb15," +
                                "WheelProb16,WheelProb17,WheelProb18,WheelProb19,WheelProb20,WheelProb21,WheelProb22,WheelProb23," +
                                "BetMin,BetMax,CoinsNeed,ExCoin,CoinSc,GameMo,ScoreSwitchX10,DefaultBetIndex) VALUES(" +
                                tableId + "," + gameId + "," + tableIndex + "," +
                                laba.SubType + "," + laba.DIF + "," + laba.HAR + "," +
                                laba.Payout0 + "," + laba.Payout1 + "," + laba.Payout2 + "," + laba.Payout3 + "," +
                                laba.Payout4 + "," + laba.Payout5 + "," + laba.Payout6 + "," + laba.Payout7 + "," + laba.Payout8 + "," +
                                laba.Prob0 + "," + laba.Prob1 + "," + laba.Prob2 + "," + laba.Prob3 + "," +
                                laba.Prob4 + "," + laba.Prob5 + "," + laba.Prob6 + "," + laba.Prob7 + "," + laba.Prob8 + "," +
                                laba.WheelProb0 + "," + laba.WheelProb1 + "," + laba.WheelProb2 + "," + laba.WheelProb3 + "," +
                                laba.WheelProb4 + "," + laba.WheelProb5 + "," + laba.WheelProb6 + "," + laba.WheelProb7 + "," +
                                laba.WheelProb8 + "," + laba.WheelProb9 + "," + laba.WheelProb10 + "," + laba.WheelProb11 + "," +
                                laba.WheelProb12 + "," + laba.WheelProb13 + "," + laba.WheelProb14 + "," + laba.WheelProb15 + "," +
                                laba.WheelProb16 + "," + laba.WheelProb17 + "," + laba.WheelProb18 + "," + laba.WheelProb19 + "," +
                                laba.WheelProb20 + "," + laba.WheelProb21 + "," + laba.WheelProb22 + "," + laba.WheelProb23 + "," +
                                laba.BetMin + "," + laba.BetMax + "," + laba.CoinsNeed + "," +
                                laba.ExCoin + "," + laba.CoinSc + "," + laba.GameMo + "," +
                                laba.ScoreSwitchX10 + "," + laba.DefaultBetIndex + ")");
                        }

                        // ── 3. 一房N桌同步：pararoom base 行 NUM = roomtableconfig 条数，ROOM_MAX=1 ──
                        int cfgCnt = ef.Database.SqlQuery<int>(
                            "SELECT COUNT(*) FROM roomtableconfig WHERE GAME_ID=" + gameId).FirstOrDefault();
                        int baseId = gameId * 1000;
                        int aff = ef.Database.ExecuteSqlCommand(
                            "UPDATE ParaRoom SET NUM=" + cfgCnt + " WHERE GAME_ID=" + gameId + " AND ID=" + baseId);
                        if (aff == 0)
                        {
                            ef.Database.ExecuteSqlCommand(
                                "INSERT INTO ParaRoom(ID,GAME_ID,NUM,EX_COIN,COIN_SC,COIN_NEED,Game_Mo,scoreSwitch,Enabled,MaxSeats,IdleFireTimeoutSec,IdleFireKickEnabled) VALUES(" +
                                baseId + "," + gameId + "," + cfgCnt + ",1,1,0,1,0,1,6,0,1)");
                        }
                        int aff2 = ef.Database.ExecuteSqlCommand(
                            "UPDATE ParaGame SET ROOM_MAX=1 WHERE ID=" + gameId);
                        if (aff2 == 0)
                            ef.Database.ExecuteSqlCommand(
                                "INSERT INTO ParaGame(ID,ROOM_MAX,PLY_MAX) VALUES(" + gameId + ",1,1000)");

                        ef.SaveChanges();
                        trans.Commit();
                    }
                    catch (Exception ex)
                    {
                        trans.Rollback();
                        LogHelper.WriteLog(typeof(B_LabaGamePara), ex);
                        msg.code = 0;
                        msg.content = "保存失败：" + ex.Message;
                        return msg;
                    }
                }
            }

            // ── 4. 热更 ──
            bool needRp = true;
            if (needRp)
            {
                var srv = new SConnect();
                var tmpMsg = srv.SendReadString(EScMsgType.RP, gameId);
                if (msg.code == 0)
                {
                    msg.code = tmpMsg.code;
                    msg.content = tmpMsg.content;
                }
            }

            if (!string.IsNullOrEmpty(tableName))
            {
                try
                {
                    var srv2 = new SConnect();
                    var tc = srv2.SendTcCommand((ushort)gameId, 0, (ushort)tableIndex,
                        tableName, (byte)enabled, 0u, 0, 6);
                    if (tc != null && tc.code == 1)
                    {
                        if (msg.code == 0)
                        {
                            msg.code = 1;
                            msg.content = "保存成功";
                        }
                    }
                    else
                    {
                        msg.datas = true;
                        msg.content = (string.IsNullOrEmpty(msg.content) ? "保存成功" : msg.content)
                                   + "，但桌名热更新失败：" + (tc == null ? "服务端无响应" : tc.content);
                    }
                }
                catch (Exception exTc)
                {
                    LogHelper.WriteLog(typeof(B_LabaGamePara), exTc);
                    msg.datas = true;
                    msg.content = (string.IsNullOrEmpty(msg.content) ? "保存成功" : msg.content)
                               + "，但桌名热更新异常：" + exTc.Message;
                }
            }

            if (msg.code == 0) msg.code = 1;
            if (string.IsNullOrEmpty(msg.content)) msg.content = "保存成功";
            return msg;
        }

        /// <summary>
        /// 兼容旧接口：无 paralaba 参数时只写 gameconfiglaba（降级）
        /// </summary>
        public Msg SaveTableFull(int tableId, int gameId, List<M_GameConfigLaba> paras, string tableName, int enabled = 1)
        {
            return SaveTableFull(tableId, gameId, paras, null, tableName, enabled);
        }

        /// <summary>
        /// 拉霸游戏级配置键判定（存 gameconfiglaba 且不随桌台删除而删除）：
        /// Rtp* 三类型通用；Combo*/UseOutcomeFirst 明星97；WheelStock* 水果拉霸；ShzRate*/ShzStock* 水浒传。
        /// 与 GameConfigController 的 GetTableConfig / Save*RtpConfig 命名空间保持一致。
        /// </summary>
        private static bool IsGameLevelLabaKey(string optKey)
        {
            if (string.IsNullOrEmpty(optKey)) return false;
            return optKey.StartsWith("Rtp") || optKey.StartsWith("Combo") || optKey == "UseOutcomeFirst"
                || optKey.StartsWith("WheelStock") || optKey.StartsWith("ShzRate") || optKey.StartsWith("ShzStock");
        }

        public Msg DeleteTable(int tableId, int gameId)
        {
            Msg msg = new Msg(0, "删除失败！");
            int tableIndex = tableId % 1000;
            using (var ef = new GameDbContext())
            {
                using (var trans = ef.Database.BeginTransaction())
                {
                    try
                    {
                        // 删 gameconfiglaba（保留兼容）。跳过游戏级 RTP/Combo 配置键：
                        // 拉霸的返奖率/库存/结果类配置存 TableIndex=0 但语义为游戏级（明星97 的 Rtp*/Combo*/UseOutcomeFirst、
                        // 水果拉霸 的 Rtp*/WheelStock*、水浒传 的 Rtp*/ShzRate*/ShzStock*），
                        // 删除桌台（含删到 0 张）不应误删这些配置，否则 RTP 闭环失效且无法恢复。
                        var toDelete = ef.GameConfigLabas
                            .Where(c => c.GameId == gameId && c.TableIndex == tableIndex)
                            .ToList()
                            .Where(c => !IsGameLevelLabaKey(c.OptKey))
                            .ToList();
                        if (toDelete.Count > 0)
                        {
                            ef.GameConfigLabas.RemoveRange(toDelete);
                        }

                        // 删 paralaba
                        ef.Database.ExecuteSqlCommand(
                            "DELETE FROM paralaba WHERE GAME_ID={0} AND TableIndex={1}", gameId, tableIndex);

                        // 删 roomtableconfig
                        ef.Database.ExecuteSqlCommand(
                            "DELETE FROM roomtableconfig WHERE GAME_ID={0} AND RoomIndex=0 AND TableIndex={1}",
                            gameId, tableIndex);

                        // 一房N桌同步：压实剩余 TableIndex 为 0..k-1
                        var remainIds = ef.Database.SqlQuery<int>(
                            "SELECT ID FROM roomtableconfig WHERE GAME_ID=" + gameId + " ORDER BY TableIndex, ID").ToList();
                        for (int i = 0; i < remainIds.Count; i++)
                        {
                            ef.Database.ExecuteSqlCommand(
                                "UPDATE roomtableconfig SET TableIndex={0} WHERE ID={1} AND TableIndex<>{0}", i, remainIds[i]);
                        }
                        // paralaba 同步压实 ID/TableIndex
                        var labaRows = ef.Database.SqlQuery<int>(
                            "SELECT ID FROM paralaba WHERE GAME_ID=" + gameId + " ORDER BY TableIndex, ID").ToList();
                        for (int i = 0; i < labaRows.Count; i++)
                        {
                            int newId = gameId * 1000 + i;
                            ef.Database.ExecuteSqlCommand(
                                "UPDATE paralaba SET ID={0},TableIndex={1} WHERE ID={2} AND ID<>{0}", newId, i, labaRows[i]);
                        }

                        // 同步 pararoom base 行 NUM 与 ROOM_MAX=1
                        int cfgCnt = ef.Database.SqlQuery<int>(
                            "SELECT COUNT(*) FROM roomtableconfig WHERE GAME_ID=" + gameId).FirstOrDefault();
                        if (cfgCnt > 0)
                        {
                            ef.Database.ExecuteSqlCommand(
                                "UPDATE ParaRoom SET NUM=" + cfgCnt + " WHERE GAME_ID=" + gameId + " AND ID=" + (gameId * 1000));
                        }
                        else
                        {
                            // 最后一张桌被删，清空 base 行
                            ef.Database.ExecuteSqlCommand(
                                "DELETE FROM ParaRoom WHERE GAME_ID=" + gameId + " AND ID=" + (gameId * 1000));
                        }
                        ef.Database.ExecuteSqlCommand(
                            "UPDATE ParaGame SET ROOM_MAX=1 WHERE ID=" + gameId);

                        ef.SaveChanges();
                        trans.Commit();
                    }
                    catch (Exception ex)
                    {
                        trans.Rollback();
                        LogHelper.WriteLog(typeof(B_LabaGamePara), ex);
                        msg.content = "删除失败：" + ex.Message;
                        return msg;
                    }
                }
            }

            var srv = new SConnect();
            var tmpMsg = srv.SendReadString(EScMsgType.RP, gameId);
            msg.code = tmpMsg.code;
            msg.content = tmpMsg.content;
            return msg;
        }
    }
}
