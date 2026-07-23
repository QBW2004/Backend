using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;
using System.Text;
using YYT.Common;
using YYT.Entity;
using YYT.Remote;

namespace YYT.BLL.EF
{
    /// <summary>
    /// 下注类（押分）参数
    /// </summary>
    public class B_BetGamePara : B_SuperPara, IGamePara
    {
        public B_BetGamePara() : base() { }

        public Msg SaveTableFull(M_ParaBetRoom room, M_ParaBet machine)
        {
            Msg result = new Msg(0, "保存失败！");
            if (room == null || machine == null)
            {
                result.content = "提交的桌台数据为空！";
                return result;
            }
            using (var ef = new GameDbContext())
            {
                using (var trans = ef.Database.BeginTransaction())
                {
                    try
                    {
                        // 一房N桌模型：parabetroom 只保留 1 行 base 行(ID=gameId*1000)，
                        // 存所有桌共享的专有参数(押注时长/限红/庄闲和限红/投注档位/EX_COIN/Game_Mo 等)。
                        // room.ID = gameId*1000+tableIndex(控制器传入)，base 行 ID = room.GAME_ID*1000。
                        int baseId = room.GAME_ID * 1000;
                        M_ParaBetRoom rst = ef.ParaBetRooms.Where(c => c.ID == baseId).FirstOrDefault();
                        if (rst == null)
                        {
                            // 首次建游戏：插入 base 行，NUM 先占 1，后续由 SyncRoomMaxToRoomCount 同步为桌数
                            M_ParaBetRoom baseRoom = new M_ParaBetRoom();
                            baseRoom.ID = baseId;
                            baseRoom.GAME_ID = room.GAME_ID;
                            baseRoom.BET_TIME = room.BET_TIME;
                            baseRoom.NUM = 1;
                            baseRoom.BET_MIN = room.BET_MIN;
                            baseRoom.BET_MAX = room.BET_MAX;
                            baseRoom.BET_MIN_VICE = room.BET_MIN_VICE;
                            baseRoom.BET_MAX_VICE = room.BET_MAX_VICE;
                            baseRoom.BET_MIN_DRAW = room.BET_MIN_DRAW;
                            baseRoom.BET_MAX_DRAW = room.BET_MAX_DRAW;
                            baseRoom.EX_COIN = room.EX_COIN;
                            baseRoom.COIN_SC = room.COIN_SC;
                            baseRoom.COIN_NEED = room.COIN_NEED;
                            baseRoom.BANKER_SC_NEED = room.BANKER_SC_NEED;
                            baseRoom.SC_LIMIT_SING = room.SC_LIMIT_SING;
                            baseRoom.SC_LIMIT_ALL = room.SC_LIMIT_ALL;
                            baseRoom.Game_Mo = room.Game_Mo;
                            baseRoom.BetScores = room.BetScores ?? string.Empty;
                            baseRoom.DefaultBetIndex = room.DefaultBetIndex ?? 0;
                            baseRoom.TableName = room.TableName;
                            baseRoom.MaxSeats = room.MaxSeats;
                            baseRoom.IdleFireTimeoutSec = room.IdleFireTimeoutSec;
                            baseRoom.IdleFireKickEnabled = room.IdleFireKickEnabled;
                            baseRoom.Enabled = room.Enabled;
                            ef.ParaBetRooms.Add(baseRoom);
                        }
                        else
                        {
                            // 已有 base 行：更新专有参数(每桌保存时都会刷新 base 行，以最后一次为准)
                            rst.GAME_ID = room.GAME_ID;
                            rst.BET_TIME = room.BET_TIME;
                            rst.BET_MIN = room.BET_MIN;
                            rst.BET_MAX = room.BET_MAX;
                            rst.BET_MIN_VICE = room.BET_MIN_VICE;
                            rst.BET_MAX_VICE = room.BET_MAX_VICE;
                            rst.BET_MIN_DRAW = room.BET_MIN_DRAW;
                            rst.BET_MAX_DRAW = room.BET_MAX_DRAW;
                            rst.EX_COIN = room.EX_COIN;
                            rst.COIN_SC = room.COIN_SC;
                            rst.COIN_NEED = room.COIN_NEED;
                            rst.BANKER_SC_NEED = room.BANKER_SC_NEED;
                            rst.SC_LIMIT_SING = room.SC_LIMIT_SING;
                            rst.SC_LIMIT_ALL = room.SC_LIMIT_ALL;
                            rst.Game_Mo = room.Game_Mo;
                            rst.BetScores = room.BetScores;
                            rst.DefaultBetIndex = room.DefaultBetIndex;
                            rst.TableName = room.TableName;
                            rst.IdleFireTimeoutSec = room.IdleFireTimeoutSec;
                            rst.IdleFireKickEnabled = room.IdleFireKickEnabled;
                            rst.Enabled = room.Enabled;
                            ef.Entry(rst).State = EntityState.Modified;
                        }

                        // 机台难度按桌 upsert(ID = gameId*1000+tableIndex)，保持不变
                        M_ParaBet mrst = ef.ParaBets.Where(c => c.ID == machine.ID).FirstOrDefault();
                        if (mrst == null)
                        {
                            ef.ParaBets.Add(machine);
                        }
                        else
                        {
                            mrst.GAME_ID = machine.GAME_ID;
                            mrst.DIF = machine.DIF;
                            mrst.HAR = machine.HAR;
                            mrst.SITE_TYPE = machine.SITE_TYPE;
                            mrst.BANKER_DIF = machine.BANKER_DIF;
                            mrst.BANKER_HAR = machine.BANKER_HAR;
                            mrst.BANKER_SITE_TYPE = machine.BANKER_SITE_TYPE;
                            mrst.BANKER_PER = machine.BANKER_PER;
                            ef.Entry(mrst).State = EntityState.Modified;
                        }

                        ef.SaveChanges();

                        // NUM 同步：base 行 NUM = roomtableconfig 条数(桌台数)
                        int cfgCnt = ef.Database.SqlQuery<int>(
                            "SELECT COUNT(*) FROM roomtableconfig WHERE GAME_ID={0}", room.GAME_ID).FirstOrDefault();
                        // roomtableconfig 尚未写入(本次保存的新桌)，cfgCnt 暂时少 1，下方先写 roomtableconfig 再补 NUM
                        // 此处先不更新 NUM，留给 PushHotUpdate->SyncRoomMaxToRoomCount 统一同步

                        // 按桌配置直接落库：roomtableconfig 以数据库为准，
                        // 不依赖 center 在线时的 TC 热更写入（center 掉线也不丢配置）。
                        int tIdx = room.ID % 1000;
                        ef.Database.ExecuteSqlCommand(
                            "DELETE FROM roomtableconfig WHERE GAME_ID={0} AND TableIndex={1}", room.GAME_ID, tIdx);
                        ef.Database.ExecuteSqlCommand(
                            "INSERT INTO roomtableconfig (GAME_ID, RoomIndex, TableIndex, TableName, Enabled, OneCoinScore, BetMin, BetMax, CoinsNeed, IdleFireTimeoutSec, IdleFireKickEnabled, MaxSeats) VALUES ({0},0,{1},{2},{3},{4},{5},{6},{7},{8},{9},{10})",
                            room.GAME_ID, tIdx, room.TableName ?? string.Empty, room.Enabled ? 1 : 0,
                            room.COIN_SC, room.BET_MIN, room.BET_MAX, room.COIN_NEED,
                            room.IdleFireTimeoutSec, room.IdleFireKickEnabled ? 1 : 0, room.MaxSeats);

                        trans.Commit();
                    }
                    catch (Exception ex)
                    {
                        trans.Rollback();
                        LogHelper.WriteLog(typeof(B_BetGamePara), ex);
                        result.code = 0;
                        result.content = "保存失败：" + ex.Message;
                        return result;
                    }
                }
            }
            Msg hot = PushHotUpdate(room.GAME_ID, EGameType.Bet, machine);
            // 押分扩展：随 TC 一并下发按桌押分参数，center 写入 roomtableconfig_bet 并全量重推。
            // 字段顺序须与 center 的 TC 押分扩展解析一致；GAME_ID=10(幸运六狮)为 layoutTag==1，
            // 需追加庄闲/和 4 个副游戏限红字段。
            // 专有参数从 base 行取(所有桌共享)，room 此处携带的是本次提交的桌台值。
            var betExt = new SConnect.TcBetExt
            {
                BetTime = (byte)room.BET_TIME,
                BetMin = (uint)room.BET_MIN,
                BetMax = (uint)room.BET_MAX,
                BankerScoreNeed = (uint)room.BANKER_SC_NEED,
                ItemSingleScoreLimit = (uint)room.SC_LIMIT_SING,
                ItemAllScoreLimit = (uint)room.SC_LIMIT_ALL,
                CoinsNeed = (uint)room.COIN_NEED,
                OneCoinScore = (uint)room.COIN_SC,
                BetScores = room.BetScores ?? string.Empty,
                DefaultBetIndex = (byte)(room.DefaultBetIndex ?? 0),
                IncludeViceDraw = room.GAME_ID == 10,
                BetMinVice = (uint)room.BET_MIN_VICE,
                BetMaxVice = (uint)room.BET_MAX_VICE,
                BetMinDraw = (uint)room.BET_MIN_DRAW,
                BetMaxDraw = (uint)room.BET_MAX_DRAW
            };
            Msg tc = PushTableConfig(room.ID, room.GAME_ID, (int)EGameType.Bet,
                room.TableName, room.Enabled, room.IdleFireTimeoutSec, room.IdleFireKickEnabled, room.MaxSeats, betExt);
            return MergeHotUpdateAndTc(hot, tc);
        }

        public Dictionary<string, dynamic> GetGameParams(int gameId)
        {
            Dictionary<string, dynamic> kv = new Dictionary<string, dynamic>();
            using (var ef = new GameDbContext())
            {
                // 房间参数
                var paraBetRooms = ef.ParaBetRooms.Where(c => c.GAME_ID == gameId).ToList();
                if (paraBetRooms != null && paraBetRooms.Count > 0)
                    kv.Add("1", paraBetRooms);
                else
                    kv.Add("1", new List<M_ParaBetRoom>());

                // 机台参数
                var paraBets = ef.ParaBets.Where(c => c.GAME_ID == gameId).ToList();
                if (paraBets != null && paraBets.Count > 0)
                    kv.Add("2", paraBets);
                else
                    kv.Add("2", new List<M_ParaBet>());
            }
            return kv;
        }

        public M_ParaBetRoom GetSingle(M_ParaBetRoom entity)
        {
            using (var ef = new GameDbContext())
            {
                return ef.ParaBetRooms.Find(entity.ID);
            }
        }

        public List<M_GameRoomDeskPara> GetGameRoomDeskPara(int gameId)
        {
            List<M_GameRoomDeskPara> list = new List<M_GameRoomDeskPara>();
            list.Add(new M_GameRoomDeskPara { RoomIndex = 0, DeskCount = 1 });
            return list;
        }

        public Msg SaveDeskPara<T>(T t)
        {
            using (var ef = new GameDbContext())
            {
                M_ParaBet entity = t as M_ParaBet;
                var rst = ef.ParaBets.Where(c => c.ID == entity.ID).SingleOrDefault();
                if (rst != null)
                {
                    rst.ID = entity.ID;
                    rst.GAME_ID = entity.GAME_ID;
                    rst.DIF = entity.DIF;
                    rst.HAR = entity.HAR;
                    rst.SITE_TYPE = entity.SITE_TYPE;
                    rst.BANKER_DIF = entity.BANKER_DIF;
                    rst.BANKER_HAR = entity.BANKER_HAR;
                    rst.BANKER_SITE_TYPE = entity.BANKER_SITE_TYPE;
                    rst.BANKER_PER = entity.BANKER_PER;

                    ef.Entry(rst).State = EntityState.Modified;
                }
                else
                {
                    ef.ParaBets.Add(entity);
                }
                int val = ef.SaveChanges();
                if (val > 0)
                {
                    this.msg.code = 1;
                    this.msg.content = "保存成功！";
                    // 通知服务器
                    this.NotifyServer(EGameType.Bet, EScMsgType.PA, entity);
                }
            }
            return this.msg;
        }

        public Msg SaveRoomPara<T>(T t)
        {
            Msg msg = new Msg(0, "保存失败！");
            using (var ef = new GameDbContext())
            {
                M_ParaBetRoom entity = t as M_ParaBetRoom;
                var rst = ef.ParaBetRooms.Where(c => c.ID == entity.ID).SingleOrDefault();
                if (rst != null)
                {
                    rst.ID = entity.ID;
                    rst.GAME_ID = entity.GAME_ID;
                    rst.BET_TIME = entity.BET_TIME;
                    rst.NUM = entity.NUM;
                    rst.BET_MAX = entity.BET_MAX;
                    rst.BET_MIN = entity.BET_MIN;
                    rst.BET_MAX_VICE = entity.BET_MAX_VICE;
                    rst.BET_MIN_VICE = entity.BET_MIN_VICE;
                    rst.BET_MAX_DRAW = entity.BET_MAX_DRAW;
                    rst.BET_MIN_DRAW = entity.BET_MIN_DRAW;
                    rst.EX_COIN = entity.EX_COIN;
                    rst.COIN_SC = entity.COIN_SC;
                    rst.COIN_NEED = entity.COIN_NEED;
                    rst.BANKER_SC_NEED = entity.BANKER_SC_NEED;
                    rst.SC_LIMIT_SING = entity.SC_LIMIT_SING;
                    rst.SC_LIMIT_ALL = entity.SC_LIMIT_ALL;
                    rst.Game_Mo = entity.Game_Mo;
                    rst.BetScores = entity.BetScores;
                    rst.DefaultBetIndex = entity.DefaultBetIndex;
                    ef.Entry(rst).State = EntityState.Modified;
                }
                else
                {
                    ef.ParaBetRooms.Add(entity);
                }
                int val = ef.SaveChanges();
                if (val > 0)
                {
                    
                    var srv = new SConnect();
                    var tmpMsg = srv.SendReadString(EScMsgType.RP, rst.GAME_ID);
                    msg.code = tmpMsg.code;
                    msg.content = tmpMsg.content;

                }
            }
            return msg;
        }


        public Msg SaveRoomParaNew<T>(T t)
        {
            Msg msg = new Msg(0, "保存失败！");
            using (var ef = new GameDbContext())
            {
                using (var trans = ef.Database.BeginTransaction())
                {
                    try
                    {
                        List<M_ParaBetRoom> list = t as List<M_ParaBetRoom>;

                        LogHelper.WriteLog(typeof(B_BetGamePara), $"开始保存房间参数，共{list?.Count ?? 0}个房间");
                
                        if (list == null || list.Count == 0)
                        {
                            msg.content = "保存失败：房间参数列表为空！";
                            return msg;
                        }

                        M_ParaBetRoom rst = null;
                        int val = 0;
                        int deskCnt = 0;
                        foreach (M_ParaBetRoom entity in list)
                        {
                             LogHelper.WriteLog(typeof(B_BetGamePara), $"保存房间 ID={entity.ID}, GAME_ID={entity.GAME_ID}, NUM={entity.NUM}, BetScores={entity.BetScores ?? "null"}");

                            rst = ef.ParaBetRooms.Where(c => c.ID == entity.ID).SingleOrDefault();
                            if (rst != null)
                            {
                                rst.ID = entity.ID;
                                rst.GAME_ID = entity.GAME_ID;
                                rst.BET_TIME = entity.BET_TIME;
                                rst.NUM = entity.NUM;
                                rst.BET_MAX = entity.BET_MAX;
                                rst.BET_MIN = entity.BET_MIN;
                                rst.BET_MAX_VICE = entity.BET_MAX_VICE;
                                rst.BET_MIN_VICE = entity.BET_MIN_VICE;
                                rst.BET_MAX_DRAW = entity.BET_MAX_DRAW;
                                rst.BET_MIN_DRAW = entity.BET_MIN_DRAW;
                                rst.EX_COIN = entity.EX_COIN;
                                rst.COIN_SC = entity.COIN_SC;
                                rst.COIN_NEED = entity.COIN_NEED;
                                rst.BANKER_SC_NEED = entity.BANKER_SC_NEED;
                                rst.SC_LIMIT_SING = entity.SC_LIMIT_SING;
                                rst.SC_LIMIT_ALL = entity.SC_LIMIT_ALL;
                                rst.Game_Mo = entity.Game_Mo;
                                rst.BetScores = entity.BetScores;
                                rst.DefaultBetIndex = entity.DefaultBetIndex;
                                ef.Entry(rst).State = EntityState.Modified;
                            }
                            else
                            {
                                ef.ParaBetRooms.Add(entity);
                                deskCnt += entity.NUM;
                            }
                            val += ef.SaveChanges();
                        }
                        if (deskCnt > 0)
                        {
                            // 添加默认的押注类机台参数表
                            int game_id = list[0].GAME_ID;
                            ef.Database.ExecuteSqlCommand("DELETE FROM parabet WHERE GAME_ID={0}", game_id);
                            StringBuilder paras = new StringBuilder();
                            for (int i = 0; i < deskCnt; i++)
                            {
                                paras.AppendFormat("({0},{1},1,2,3,4,5,6,7){2}", game_id * 1000 + i, game_id, (i < deskCnt - 1 ? "," : ""));
                            }
                            ef.Database.ExecuteSqlCommand($"INSERT INTO parabet(ID,GAME_ID,DIF,HAR,SITE_TYPE,BANKER_DIF,BANKER_HAR,BANKER_SITE_TYPE,BANKER_PER) VALUES {paras.ToString()}");
                        }
    
                        trans.Commit();
                        LogHelper.WriteLog(typeof(B_BetGamePara), $"保存成功，共保存{val}个房间");

                        if (val == list.Count)
                        {
                            var srv = new SConnect();
                            var tmpMsg = srv.SendReadString(EScMsgType.RP, rst.GAME_ID);
                            if (tmpMsg.code == 1)
                            {
                                msg.code = 1;
                                msg.content = "保存成功！";
                            }
                            else
                            {
                                msg.code = 1; // 数据已入库，仍算成功
                                msg.content = "保存成功，但通知服务器失败：" + tmpMsg.content;
                            }
                        }
                        else
                        {
                            msg.code = 1;
                            msg.content = "保存成功！";
                        }
                    }
                    catch (Exception ex)
                    {
                        trans.Rollback();
                        msg.code = 0;
                        msg.content = "保存失败：" + ex.Message; // 返回详细错误信息
                        LogHelper.WriteLog(typeof(B_BetGamePara), ex);
                    }
                }
            }
            return msg;
        }
    }
}
