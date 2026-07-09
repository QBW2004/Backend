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
    /// <summary>
    /// 牌机类参数
    /// </summary>
    public class B_CardGamePara : B_SuperPara, IGamePara
    {
        public B_CardGamePara() : base() { }

        public Msg SaveTableFull(M_ParaRoom room, M_ParaCard machine)
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
                            rst.Game_Mo = room.Game_Mo;
                            rst.TableName = room.TableName;
                            rst.IdleFireTimeoutSec = room.IdleFireTimeoutSec;
                            rst.IdleFireKickEnabled = room.IdleFireKickEnabled;
                            rst.Enabled = room.Enabled;
                            ef.Entry(rst).State = EntityState.Modified;
                        }

                        M_ParaCard mrst = ef.ParaCards.Where(c => c.ID == machine.ID).FirstOrDefault();
                        if (mrst == null)
                        {
                            ef.ParaCards.Add(machine);
                        }
                        else
                        {
                            mrst.GAME_ID = machine.GAME_ID;
                            mrst.DIF = machine.DIF;
                            mrst.HYPE_TYPE = machine.HYPE_TYPE;
                            ef.Entry(mrst).State = EntityState.Modified;
                        }

                        ef.SaveChanges();
                        int cnt = ef.ParaRoom.Where(c => c.GAME_ID == room.GAME_ID).Count();
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
                        LogHelper.WriteLog(typeof(B_CardGamePara), ex);
                        result.code = 0;
                        result.content = "保存失败：" + ex.Message;
                        return result;
                    }
                }
            }
            Msg hot = PushHotUpdate(room.GAME_ID, EGameType.Card, machine);
            Msg tc = PushTableConfig(room.ID, room.GAME_ID, (int)EGameType.Card,
                room.TableName, room.Enabled, room.IdleFireTimeoutSec, room.IdleFireKickEnabled, room.MaxSeats);
            return MergeHotUpdateAndTc(hot, tc);
        }

        public Dictionary<string, dynamic> GetGameParams(int gameId)
        {
            Dictionary<string, dynamic> kv = new Dictionary<string, dynamic>();
            using (var ef = new GameDbContext())
            {
                // 牌机类房间参数
                var paraRooms = ef.ParaRoom.Where(c => c.GAME_ID == gameId).ToList();
                if (paraRooms != null && paraRooms.Count > 0)
                    kv.Add("1", paraRooms);
                else
                    kv.Add("1", new List<M_ParaRoom>());

                // 牌机类机台参数
                var paraCars = ef.ParaCards.Where(c => c.GAME_ID == gameId).ToList();
                if (paraCars != null && paraCars.Count > 0)
                    kv.Add("2", paraCars);
                else
                    kv.Add("2", new List<M_ParaCard>());
            }
            return kv;
        }

        public M_ParaRoom GetSingle(M_ParaRoom entity)
        {
            using (var ef = new GameDbContext())
            {
                return ef.ParaRoom.Find(entity.ID);
            }
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
                M_ParaCard entity = t as M_ParaCard;
                var rst = ef.ParaCards.Where(c => c.ID == entity.ID).SingleOrDefault();
                if (rst != null)
                {
                    rst.ID = entity.ID;
                    rst.GAME_ID = entity.GAME_ID;
                    rst.DIF = entity.DIF;
                    rst.HYPE_TYPE = entity.HYPE_TYPE;

                    ef.Entry(rst).State = EntityState.Modified;
                }
                else
                {
                    ef.ParaCards.Add(entity);
                }
                int val = ef.SaveChanges();
                if (val > 0)
                {
                    this.msg.code = 1;
                    this.msg.content = "保存成功！";
                    // 通知服务器
                    this.NotifyServer(EGameType.Card, EScMsgType.PA, entity);
                }
            }
            return this.msg;
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
                        int val = 0;
                        int deskCnt = 0;
                        foreach (M_ParaRoom entity in list)
                        {
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
                                rst.Game_Mo = entity.Game_Mo;
                                ef.Entry(rst).State = EntityState.Modified;
                            }
                            else
                            {
                                ef.ParaRoom.Add(entity);
                                deskCnt += entity.NUM;
                            }
                            val += ef.SaveChanges();
                        }
                        if (deskCnt > 0)
                        {
                            // 添加默认的牌机机台参数
                            int game_id = list[0].GAME_ID;
                            ef.Database.ExecuteSqlCommand("DELETE FROM ParaCard WHERE GAME_ID={0}", game_id);
                            StringBuilder paras = new StringBuilder();
                            for (int i = 0; i < deskCnt; i++)
                            {
                                paras.AppendFormat("({0},{1},'3434453555777533',0){2}", game_id * 1000 + i, game_id, (i < deskCnt - 1 ? "," : ""));
                            }
                            ef.Database.ExecuteSqlCommand($"INSERT INTO ParaCard(ID,GAME_ID,DIF,HYPE_TYPE) VALUES {paras.ToString()}");
                        }

                        if (val == list.Count)
                        {
                            var srv = new SConnect();
                            var tmpMsg = srv.SendReadString(EScMsgType.RP, list[0].GAME_ID);
                            msg.code = tmpMsg.code;
                            msg.content = tmpMsg.content;
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
