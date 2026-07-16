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
    /// 鱼机类参数
    /// </summary>
    public class B_FishGamePara : B_SuperPara, IGamePara
    {
        public B_FishGamePara() : base() { }

        public Msg SaveTableFull(M_ParaRoom room, M_ParaFish machine)
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
                        M_ParaRoom rst = ef.ParaRoom.Where(c => c.ID == room.ID).FirstOrDefault();
                        if (rst == null)
                        {
                            M_ParaRoom sib = ef.ParaRoom.Where(c => c.GAME_ID == room.GAME_ID).FirstOrDefault();
                            if (sib != null) room.MaxSeats = sib.MaxSeats;
                            ef.ParaRoom.Add(room);
                        }
                        else
                        {
                            rst.GAME_ID = room.GAME_ID;
                            rst.BET_MIN = room.BET_MIN;
                            rst.BET_MAX = room.BET_MAX;
                            rst.MinBetUnits = room.MinBetUnits;
                            rst.MaxBetUnits = room.MaxBetUnits;
                            rst.EX_COIN = room.EX_COIN;
                            rst.COIN_SC = room.COIN_SC;
                            rst.COIN_NEED = room.COIN_NEED;
                            rst.scoreSwitch = room.scoreSwitch;
                            rst.Game_Mo = room.Game_Mo;
                            rst.TableName = room.TableName;
                            rst.IdleFireTimeoutSec = room.IdleFireTimeoutSec;
                            rst.IdleFireKickEnabled = room.IdleFireKickEnabled;
                            rst.Enabled = room.Enabled;
                            ef.Entry(rst).State = EntityState.Modified;
                        }

                        M_ParaFish mrst = ef.ParaFishes.Where(c => c.ID == machine.ID).FirstOrDefault();
                        if (mrst == null)
                        {
                            ef.ParaFishes.Add(machine);
                        }
                        else
                        {
                            mrst.GAME_ID = machine.GAME_ID;
                            mrst.DIF = machine.DIF;
                            mrst.SITE_TYPE = machine.SITE_TYPE;
                            ef.Entry(mrst).State = EntityState.Modified;
                        }

                        ef.SaveChanges();
                        // 优先以 roomtableconfig 条数为准（新按桌模型），回退旧 pararoom 行数
                        int cfgCnt = ef.Database.SqlQuery<int>(
                            "SELECT COUNT(*) FROM roomtableconfig WHERE GAME_ID=" + room.GAME_ID).FirstOrDefault();
                        int cnt = cfgCnt > 0 ? cfgCnt : ef.ParaRoom.Where(c => c.GAME_ID == room.GAME_ID).Count();
                        foreach (M_ParaRoom r in ef.ParaRoom.Where(c => c.GAME_ID == room.GAME_ID).ToList())
                        {
                            if (r.NUM != cnt)
                            {
                                r.NUM = cnt;
                                ef.Entry(r).State = EntityState.Modified;
                            }
                        }
                        ef.SaveChanges();
                        trans.Commit();
                    }
                    catch (Exception ex)
                    {
                        trans.Rollback();
                        LogHelper.WriteLog(typeof(B_FishGamePara), ex);
                        result.code = 0;
                        result.content = "保存失败：" + ex.Message;
                        return result;
                    }
                }
            }
            Msg hot = PushHotUpdate(room.GAME_ID, EGameType.Fish, machine);
            Msg tc = PushTableConfig(room.ID, room.GAME_ID, (int)EGameType.Fish,
                room.TableName, room.Enabled, room.IdleFireTimeoutSec, room.IdleFireKickEnabled, room.MaxSeats);
            return MergeHotUpdateAndTc(hot, tc);
        }

        public Dictionary<string, dynamic> GetGameParams(int gameId)
        {
            Dictionary<string, dynamic> kv = new Dictionary<string, dynamic>();
            using (var ef = new GameDbContext())
            {
                // 房间参数
                var roomParas = ef.ParaRoom.Where(c => c.GAME_ID == gameId).ToList();
                if (roomParas != null && roomParas.Count > 0)
                    kv.Add("1", roomParas);
                else
                    kv.Add("1", new List<M_ParaFish>());

                // 机台参数
                var paraFishes = ef.ParaFishes.Where(c => c.GAME_ID == gameId).ToList();
                if (paraFishes != null && paraFishes.Count > 0)
                    kv.Add("2", paraFishes);
                else
                    kv.Add("2", new List<M_ParaFish>());

            }
            return kv;
        }

        public List<M_GameRoomDeskPara> GetGameRoomDeskPara(int gameId)
        {
            using (var ef = new GameDbContext())
            {
                return ef.ParaRoom.Where(c => c.GAME_ID == gameId).Select(c => new M_GameRoomDeskPara { RoomIndex = c.ID % (1000 * gameId), DeskCount = c.NUM }).ToList<M_GameRoomDeskPara>();
            }
        }

        public Msg SaveDeskPara<T>(T t)
        {
            using (var ef = new GameDbContext())
            {
                M_ParaFish entity = t as M_ParaFish;
                var rst = ef.ParaFishes.Where(c => c.ID == entity.ID).SingleOrDefault();
                if (rst != null)
                {
                    rst.ID = entity.ID;
                    rst.GAME_ID = entity.GAME_ID;
                    rst.DIF = entity.DIF;
                    rst.SITE_TYPE = entity.SITE_TYPE;

                    ef.Entry(rst).State = EntityState.Modified;
                }
                else
                {
                    ef.ParaFishes.Add(entity);
                }
                int val = ef.SaveChanges();
                if (val > 0)
                {
                    this.msg.code = 1;
                    this.msg.content = "保存成功！";
                    // 通知服务器
                    this.NotifyServer(EGameType.Fish, EScMsgType.PA, entity);
                }
            }
            return msg;
        }

        public Msg SaveRoomPara<T>(T t)
        {
            Msg msg = new Msg(0, "保存失败！");
            using (var ef = new GameDbContext())
            {
                using (var trans = ef.Database.BeginTransaction())
                {
                    try
                    {
                        List<M_ParaRoom> list = t as List<M_ParaRoom>;
                        M_ParaRoom rst = null;
                        int deskCnt = 0;
                        foreach (M_ParaRoom entity in list)
                        {
                            entity.scoreSwitch = entity.scoreSwitch == 0 ? entity.BET_MIN : entity.scoreSwitch;
                            //entity.BET_MIN = entity.BetMinValLimit > 0 && entity.BET_MIN > entity.BetMinValLimit ? entity.BetMinValLimit : entity.BET_MIN;
                            //entity.BET_MAX = entity.BetMaxValLimit > 0 && entity.BET_MAX > entity.BetMaxValLimit ? entity.BetMaxValLimit : entity.BET_MAX;

                            rst = ef.ParaRoom.Where(c => c.ID == entity.ID).SingleOrDefault();
                            if (rst != null)
                            {
                                rst.ID = entity.ID;
                                rst.GAME_ID = entity.GAME_ID;
                                rst.NUM = entity.NUM;
                                rst.BET_MIN = entity.BET_MIN;
                                rst.BET_MAX = entity.BET_MAX;
                                rst.EX_COIN = entity.EX_COIN;
                                rst.COIN_SC = entity.COIN_SC;
                                rst.COIN_NEED = entity.COIN_NEED;
                                rst.scoreSwitch = entity.scoreSwitch;
                                rst.Game_Mo = entity.Game_Mo;
                                ef.Entry(rst).State = EntityState.Modified;
                            }
                            else
                            {
                                ef.ParaRoom.Add(entity);
                                deskCnt += entity.NUM;
                            }
                            if (deskCnt > 0)
                            {
                                // 添加默认的鱼机机台参数
                                int game_id = list[0].GAME_ID;
                                ef.Database.ExecuteSqlCommand("DELETE FROM ParaFish WHERE GAME_ID={0}", game_id);
                                StringBuilder paras = new StringBuilder();
                                for (int i = 0; i < deskCnt; i++)
                                    paras.AppendFormat("({0},{1},2,0,1){2}", game_id * 1000 + i, game_id, (i < deskCnt - 1 ? "," : ""));
                                ef.Database.ExecuteSqlCommand($"INSERT INTO ParaFish VALUES {paras.ToString()}");
                            }
                        }
                        int val = ef.SaveChanges();
                        if (val > 0)
                        {
                            //msg.code = 1;
                            //msg.content = "保存成功！";
                            //var srv = new SConnect();
                            //var tmpMsg = srv.SendReadString(EScMsgType.RP, rst.GAME_ID);

                            var srv = new SConnect();
                            var tmpMsg = srv.SendReadString(EScMsgType.RP, rst.GAME_ID);
                            msg.code = tmpMsg.code;
                            msg.content = tmpMsg.content;
                            // 通知服务器
                            //this.NotifyServer(EGameType.Fish, EScMsgType.PR, list);
                        }

                        trans.Commit();
                    }
                    catch (Exception ex)
                    {
                        trans.Rollback();
                        LogHelper.WriteLog(typeof(YYT.BLL.EF.B_FishGamePara), ex);
                    }
                }
            }
            return msg;
        }
    }
}
