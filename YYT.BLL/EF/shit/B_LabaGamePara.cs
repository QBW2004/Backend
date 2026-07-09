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

        public List<int> GetTableList(int gameId)
        {
            using (var ef = new GameDbContext())
            {
                return ef.GameConfigLabas.Where(c => c.GameId == gameId)
                    .Select(c => c.TableIndex).Distinct().OrderBy(t => t).ToList();
            }
        }

        public Msg SaveTableFull(int tableId, int gameId, List<M_GameConfigLaba> paras, string tableName)
        {
            Msg msg = new Msg(0, "保存失败！");
            int tableIndex = tableId % 1000;
            using (var ef = new GameDbContext())
            {
                var rst = ef.GameConfigLabas.Where(c => c.GameId == gameId && c.TableIndex == tableIndex).ToList();
                if (rst == null || rst.Count == 0)
                {
                    foreach (var p in paras)
                    {
                        p.GameId = gameId;
                        p.TableIndex = tableIndex;
                        ef.GameConfigLabas.Add(p);
                    }
                }
                else
                {
                    M_GameConfigLaba tmpObj = null;
                    foreach (var row in rst)
                    {
                        tmpObj = paras.Find((_list) => _list.OptKey == row.OptKey);
                        if (tmpObj != null && tmpObj.OptValue > -1)
                            row.OptValue = tmpObj.OptValue;
                        ef.Entry(row).State = EntityState.Modified;
                    }
                }
                int val = ef.SaveChanges();
                if (val > 0)
                {
                    var srv = new SConnect();
                    var tmpMsg = srv.SendReadString(EScMsgType.RP, gameId);
                    msg.code = tmpMsg.code;
                    msg.content = tmpMsg.content;
                    if (!string.IsNullOrEmpty(tableName))
                    {
                        try
                        {
                            var srv2 = new SConnect();
                            var tc = srv2.SendTcCommand((ushort)gameId, 0, (ushort)tableIndex,
                                tableName, 1, 0u, 0, 6);
                            if (tc == null || tc.code != 1)
                            {
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
            return msg;
        }

        public Msg DeleteTable(int tableId, int gameId)
        {
            Msg msg = new Msg(0, "删除失败！");
            int tableIndex = tableId % 1000;
            using (var ef = new GameDbContext())
            {
                var toDelete = ef.GameConfigLabas.Where(c => c.GameId == gameId && c.TableIndex == tableIndex).ToList();
                if (toDelete.Count == 0)
                {
                    msg.content = "桌台不存在！";
                    return msg;
                }
                ef.GameConfigLabas.RemoveRange(toDelete);
                ef.SaveChanges();
                var srv = new SConnect();
                var tmpMsg = srv.SendReadString(EScMsgType.RP, gameId);
                msg.code = tmpMsg.code;
                msg.content = tmpMsg.content;
            }
            return msg;
        }
    }
}
