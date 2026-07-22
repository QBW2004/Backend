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

            // 关键：必须在发 RP 之前同步 paragame.ROOM_MAX = 当前房间数。
            // 服务端收到 RP 后按 ROOM_MAX 决定加载几张桌(TableIndex 0..ROOM_MAX-1)，
            // 若此刻 ROOM_MAX 仍是旧值，新增桌台的 TableIndex 超出区间会被忽略，
            // 表现为"新增桌台热更失败"。先写好 ROOM_MAX 再发 RP 才能让新桌可见。
            SyncRoomMaxToRoomCount(eGameType, gameId);

            var srv = new SConnect();
            Msg rp = srv.SendReadString(EScMsgType.RP, gameId);
            bool rpOk = rp != null && rp.code == 1;

            this.msg = new Msg(1, string.Empty);
            this.NotifyServer(eGameType, EScMsgType.PA, machine);
            bool paOk = this.msg.code == 1 && string.IsNullOrEmpty(this.msg.content);

            if (rpOk && paOk)
            {
                result.code = 1;
                result.content = "保存成功，服务端已即时热更新！";
            }
            else if (rpOk)
            {
                result.code = 1;
                result.content = "保存成功，房间已热更新；机台难度推送提示：" + this.msg.content;
            }
            else
            {
                result.code = 0;
                result.datas = true;
                result.content = "保存成功，但服务端房间热更新失败：" + (rp == null ? "服务端无响应，请检查中心服是否在线。" : rp.content);
            }
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
                // roomIndex 恒为 0(后台已废弃初/中/高级多房间模型，扁平桌台列表)；
                // tableIndex = 桌台在游戏内的全局偏移(ID = gameId*1000 + 偏移)。
                // 拉霸单桌台传 tableId=gameId，偏移为 0。
                ushort roomIndex = 0;
                ushort tableIndex = (ushort)(tableId % 1000);
                // maxSeats 上限 8(MAX_PHYSICAL_SEATS)，防御性夹断。
                if (maxSeats < 0) maxSeats = 0;
                if (maxSeats > 8) maxSeats = 8;
                if (idleFireTimeoutSec < 0) idleFireTimeoutSec = 0;

                var srv = new SConnect();
                Msg tc = srv.SendTcCommand(
                    (ushort)gameId, roomIndex, tableIndex,
                    tableName ?? string.Empty,
                    (byte)(enabled ? 1 : 0),
                    (uint)idleFireTimeoutSec,
                    (byte)(idleFireKickEnabled ? 1 : 0),
                    (ushort)maxSeats, betExt, tableExt);

                if (tc != null && tc.code == 1)
                {
                    result.code = 1;
                    result.content = "桌名已热更新。";
                }
                else
                {
                    // DB 已落库，TC 失败仅提示，不回滚。
                    result.code = 0;
                    result.datas = true;
                    result.content = "保存成功，但桌名热更新失败：" + (tc == null ? "服务端无响应。" : tc.content);
                }
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
            string roomTbl;
            if (eGameType == EGameType.Bet) roomTbl = "ParaBetRoom";
            else if (eGameType == EGameType.Card || eGameType == EGameType.Fish) roomTbl = "ParaRoom";
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
                        int cfgCnt = ef.Database.SqlQuery<int>(
                            "SELECT COUNT(*) FROM roomtableconfig WHERE GAME_ID=" + gameId).FirstOrDefault();
                        if (cfgCnt > 0)
                        {
                            ef.Database.ExecuteSqlCommand(
                                "UPDATE ParaRoom SET NUM=" + cfgCnt + " WHERE GAME_ID=" + gameId + " AND ID=" + (gameId * 1000));
                        }
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
