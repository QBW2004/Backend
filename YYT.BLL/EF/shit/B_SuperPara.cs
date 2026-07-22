using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using YYT.BLL.Services.GameServer;
using YYT.Common;
using YYT.Entity;
using YYT.Remote;

namespace YYT.BLL.EF
{
    public class B_SuperPara
    {
        public Msg msg { get; set; }

        public B_SuperPara()
        {
            this.msg = new Msg(0, "操作失败！");
        }

        protected Msg PushHotUpdate(int gameId, EGameType eGameType, object machine)
        {
            Msg result = new Msg(0, "保存失败！");

            // 关键：必须在入箱 RP 之前同步 paragame.ROOM_MAX = 当前房间数。
            // 服务端收到 RP 后按 ROOM_MAX 决定加载几张桌(TableIndex 0..ROOM_MAX-1)，
            // 若此刻 ROOM_MAX 仍是旧值，新增桌台的 TableIndex 超出区间会被忽略，
            // 表现为"新增桌台热更失败"。先写好 ROOM_MAX 再入箱 RP 才能让新桌可见。
            SyncRoomMaxToRoomCount(eGameType, gameId);

            // 热更新命令改为写入 outbox，由后台定时器异步重试发送(RP 让服务端全量
            // 重读房间/桌台配置)，避免请求线程被命名管道 RPC 阻塞导致页面卡顿。
            TableHotUpdateOutbox.EnqueueRoomRefresh(gameId);

            result.code = 1;
            result.datas = true;
            result.content = "保存成功，热更新已排队，约1分钟内生效。";
            return result;
        }

        /// <summary>
        /// 发送 TC(桌台配置) 二进制命令给 center：把单张桌台的桌名/开关/踢出/坐席
        /// 写入 roomtableconfig 表并全量重推给子游戏服。DB 已 commit 后调用，
        /// 失败仅提示不影响保存结果（与 PushHotUpdate 一致策略）。
        /// 索引映射(扁平模型)：roomIndex=0，tableIndex=tableId%1000。
        /// </summary>
        protected Msg PushTableConfig(int tableId, int gameId, int gameType,
                                      string tableName, bool enabled,
                                      int idleFireTimeoutSec, bool idleFireKickEnabled,
                                      int maxSeats, SConnect.TcBetExt betExt = null,
                                      SConnect.TcTableExt tableExt = null)
        {
            Msg result = new Msg(1, string.Empty);
            try
            {
                // tableIndex 由 EnqueueTableConfig 内部按 tableId%1000 计算。
                // maxSeats 上限 8(MAX_PHYSICAL_SEATS)，防御性夹断。
                if (maxSeats < 0) maxSeats = 0;
                if (maxSeats > 8) maxSeats = 8;
                if (idleFireTimeoutSec < 0) idleFireTimeoutSec = 0;

                // TC 命令改为写入 outbox，由后台定时器异步重试发送，避免请求线程阻塞。
                TableHotUpdateOutbox.EnqueueTableConfig(
                    tableId, gameId, tableName, enabled,
                    idleFireTimeoutSec, idleFireKickEnabled, maxSeats, betExt, tableExt);

                result.code = 1;
                result.datas = true;
                result.content = "桌名热更新已排队。";
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(B_SuperPara), ex);
                result.code = 0;
                result.datas = true;
                result.content = "保存成功，但桌名热更新异常：" + ex.Message;
            }
            return result;
        }

        /// <summary>
        /// 合并 RP/PA 热更新结果(hot)与 TC 桌名热更新结果(tc)：
        /// - hot 决定主状态码(已落库即视为成功)；
        /// - tc 失败仅追加提示，不覆盖 hot 的成功状态；
        /// - 任一已落库则 datas=true(前端据此刷新列表)。
        /// </summary>
        protected static Msg MergeHotUpdateAndTc(Msg hot, Msg tc)
        {
            if (hot == null) hot = new Msg(0, "保存失败！");
            if (tc == null) tc = new Msg(1, string.Empty);
            Msg merged = new Msg(hot.code, hot.content);
            merged.datas = hot.datas;
            if (!string.IsNullOrEmpty(tc.content))
            {
                merged.content = string.IsNullOrEmpty(merged.content) ? tc.content : (merged.content + " " + tc.content);
            }
            // TC 失败时标记已落库，保证前端能刷新列表(与 PushHotUpdate 的 datas=true 约定一致)。
            if (tc.code != 1)
                merged.datas = true;
            return merged;
        }

        public void NotifyServer(EGameType eGameType, EScMsgType eScMsgType, dynamic entity)
        {
            try
            {
                Msg tmpMsg = new Msg(1, "无需发送到服务器！");
                if (eScMsgType == EScMsgType.PA)// 机台参数
                    tmpMsg = SendDeskPara(eGameType, entity);
                else if (eScMsgType == EScMsgType.PR)// 房间参数
                    tmpMsg = SendRoomPara(eGameType, entity);

                if (tmpMsg.code != 1)
                {
                    this.msg.content += $"{tmpMsg.content}({tmpMsg.datas})";
                    LogHelper.WriteLog(typeof(YYT.BLL.EF.B_SuperPara), this.msg.content);
                }
            }
            catch (Exception ex)
            {
                this.msg.content += "\n服务器推送出错，请联系管理员。";
                LogHelper.WriteLog(typeof(YYT.BLL.EF.B_CardGamePara), ex);
            }
        }

        private Msg SendRoomPara(EGameType eGameType, dynamic entity)
        {
            var srv = new SConnect();
            Msg tmpMsg = null;
            if (eGameType == EGameType.Fish)
            {
                List<M_ParaRoom> paraList = entity;

                StringBuilder sb = new StringBuilder();
                int gameId = -1;
                paraList.ForEach((c) =>
                {
                    if (gameId == -1)
                        gameId = c.GAME_ID;
                    int scoreSwitchValue = (int)Math.Round(c.scoreSwitch == 0 ? 1 : c.scoreSwitch * 10, MidpointRounding.AwayFromZero);
                    foreach (byte item in BitConverter.GetBytes(scoreSwitchValue))
                        sb.Append(item.ToString("X2"));
                });
                if (gameId > -1)
                {
                    // 鱼机房间指令： PR + 游戏ID(不足两位在前补零) +  4字节串(16进制Hex字符) +  4字节串(16进制Hex字符) +  4字节串(16进制Hex字符) ......(有多少房间拼接多少个4字节字符串)
                    tmpMsg = srv.SendReadString(EScMsgType.PR,
                        gameId.ToString().PadLeft(2, '0'),
                        sb.ToString());
                }
                else
                {
                    srv.Close();
                }
            }
            return tmpMsg;
        }

        private Msg SendDeskPara(EGameType eGameType, dynamic entity)
        {
            var srv = new SConnect();
            Msg tmpMsg = null;
            if (eGameType == EGameType.Card || eGameType == EGameType.Fish)
            {
                // 鱼机、牌机指令： PA + 游戏ID(不足两位在前补零) +  机台索引(不足三位在前面补零) + 牌机难度 + (牌机_炒场类型/鱼机_场地类型)
                tmpMsg = srv.SendReadString(EScMsgType.PA,
                    entity.GAME_ID.ToString().PadLeft(2, '0'),
                    (entity.ID % 1000).ToString().PadLeft(3, '0'),
                    entity.DIF,
                    (eGameType == EGameType.Card ? entity.HYPE_TYPE : entity.SITE_TYPE));
            }
            else
            {
                // 押注机指令： PA + 游戏ID(2位) + 桌台ID(3位) + DIF(3位0-100) + HAR(3位) + SITE(1位) + BANKER_DIF(3位) + BANKER_HAR(3位) + BANKER_SITE(1位) + BANKER_PER(3位)
                tmpMsg = srv.SendReadString(EScMsgType.PA,
                    entity.GAME_ID.ToString().PadLeft(2, '0'),
                    (entity.ID % 1000).ToString().PadLeft(3, '0'),
                    entity.DIF.ToString().PadLeft(3, '0'),
                    entity.HAR.ToString().PadLeft(3, '0'),
                    entity.SITE_TYPE,
                    entity.BANKER_DIF.ToString().PadLeft(3, '0'),
                    entity.BANKER_HAR.ToString().PadLeft(3, '0'),
                    entity.BANKER_SITE_TYPE,
                    entity.BANKER_PER.ToString().PadLeft(3, '0')
                    );
            }

            return tmpMsg;
        }

        /// <summary>
        /// 把 paragame.ROOM_MAX 同步为该游戏当前房间总数。必须在发 RP 之前调用，
        /// 否则服务端会按旧 ROOM_MAX 加载，新增桌台因 TableIndex 越界而不可见。
        /// 同时同步鱼机 pararoom.NUM = roomtableconfig 条数，保证旧房间参数口径
        /// 与新按桌配置一致（服务端 AA01 头部 roomInfo[].num 仍读 pararoom.NUM）。
        /// 与 GameConfigController.SyncRoomMaxToRoomCount 逻辑一致，集中到此处确保
        /// 所有 SaveTableFull 路径(Bet/Card/Fish)在热更前 ROOM_MAX 已就绪。
        /// </summary>
        private static void SyncRoomMaxToRoomCount(EGameType eGameType, int gameId)
        {
            if (gameId <= 0) return;
            // 鱼机桌台实际存于 roomtableconfig(而非 pararoom)，ROOM_MAX 须以 roomtableconfig
            // 计数为准，否则新桌 TableIndex 超出 ROOM_MAX 区间会被服务端忽略，表现为新桌不可见。
            // 押注/牌机仍用各自房间表计数。
            string roomTbl;
            if (eGameType == EGameType.Bet) roomTbl = "ParaBetRoom";
            else if (eGameType == EGameType.Card) roomTbl = "ParaRoom";
            else if (eGameType == EGameType.Fish) roomTbl = "roomtableconfig";
            else return;
            try
            {
                using (var ef = new GameDbContext())
                {
                    int cnt = ef.Database.SqlQuery<int>(
                        "SELECT COUNT(*) FROM " + roomTbl + " WHERE GAME_ID={0}", gameId).FirstOrDefault();
                    if (cnt <= 0) return;
                    int affected = ef.Database.ExecuteSqlCommand("UPDATE ParaGame SET ROOM_MAX={0} WHERE ID={1}", cnt, gameId);
                    if (affected == 0)
                        ef.Database.ExecuteSqlCommand("INSERT INTO ParaGame(ID,ROOM_MAX,PLY_MAX) VALUES({0},{1},{2})", gameId, cnt, 1000);

                    // 鱼机额外同步 pararoom.NUM = roomtableconfig 条数
                    if (eGameType == EGameType.Fish)
                    {
                        ef.Database.ExecuteSqlCommand(
                            "UPDATE ParaRoom SET NUM=" + cnt + " WHERE GAME_ID=" + gameId + " AND ID=" + (gameId * 1000));
                    }
                }
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(B_SuperPara), ex);
            }
        }
    }
}
