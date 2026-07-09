using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.Mvc;
using YYT.BLL.EF;
using YYT.Common;
using YYT.Entity;
using YYT.Web;
using YYT.Web.Controllers;
using YYT.Remote;

namespace YYT.Web.Areas.Game.Controllers
{
    [MemberAuthorize]
    public class GameConfigController : BaseController
    {
        public ActionResult Index()
        {
            return View("ConfigEditor");
        }

        [AjaxOnly]
        [HttpPost]
        public ActionResult GetGameList(FormCollection form)
        {
            List<object> list = new List<object>();
            try
            {
                using (var ef = new GameDbContext())
                {
                    var games = ef.Games
                        .Where(c => c.Enable == 1 && (c.GameType == 0 || c.GameType == 1 || c.GameType == 2 || c.GameType == 3))
                        .OrderBy(c => c.GameType)
                        .ThenBy(c => c.GameId)
                        .ToList();
                    foreach (var g in games)
                    {
                        list.Add(new { id = g.GameId, text = g.Name, gameType = g.GameType });
                    }
                }
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(GameConfigController), ex);
            }
            return Json(list);
        }

        [AjaxOnly]
        [HttpPost]
        public ActionResult GetTableConfig(FormCollection form)
        {
            Msg msg = new Msg(0, "获取失败！");
            try
            {
                int gameId = form.Q<int>("GAME_ID", -1);
                int gameType = form.Q<int>("GAME_TYPE", -1);
                if (gameId < 0)
                {
                    msg.content = "请选择游戏！";
                    return Json(msg);
                }
                using (var ef = new GameDbContext())
                {
                    List<object> rows = new List<object>();
                    if (gameType == 0)
                    {
                        List<M_ParaBetRoom> betRooms = ef.ParaBetRooms
                            .Where(c => c.GAME_ID == gameId)
                            .OrderBy(c => c.ID)
                            .ToList();
                        List<M_ParaBet> bets = ef.ParaBets
                            .Where(c => c.GAME_ID == gameId)
                            .ToList();
                        int bidx = 0;
                        foreach (M_ParaBetRoom r in betRooms)
                        {
                            bidx++;
                            M_ParaBet m = bets.FirstOrDefault(c => c.ID == r.ID);
                            rows.Add(new
                            {
                                id = r.ID,
                                num = r.NUM,
                                tableName = string.IsNullOrWhiteSpace(r.TableName) ? ("桌台" + bidx) : r.TableName,
                                minBet = r.BET_MIN,
                                maxBet = r.BET_MAX,
                                exCoin = r.EX_COIN,
                                coinSc = r.COIN_SC,
                                coinNeed = r.COIN_NEED,
                                gameMo = r.Game_Mo,
                                maxSeats = r.MaxSeats <= 0 ? 6 : r.MaxSeats,
                                idleFireTimeoutSec = r.IdleFireTimeoutSec,
                                idleFireKickEnabled = r.IdleFireKickEnabled ? 1 : 0,
                                enabled = r.Enabled ? 1 : 0,
                                betTime = r.BET_TIME,
                                betMinVice = r.BET_MIN_VICE,
                                betMaxVice = r.BET_MAX_VICE,
                                betMinDraw = r.BET_MIN_DRAW,
                                betMaxDraw = r.BET_MAX_DRAW,
                                bankerScNeed = r.BANKER_SC_NEED,
                                scLimitSing = r.SC_LIMIT_SING,
                                scLimitAll = r.SC_LIMIT_ALL,
                                betScores = r.BetScores ?? string.Empty,
                                dif = m == null ? 0 : m.DIF,
                                har = m == null ? 0 : m.HAR,
                                siteType = m == null ? 0 : m.SITE_TYPE,
                                bankerDif = m == null ? 0 : m.BANKER_DIF,
                                bankerHar = m == null ? 0 : m.BANKER_HAR,
                                bankerSiteType = m == null ? 0 : m.BANKER_SITE_TYPE,
                                bankerPer = m == null ? 0 : m.BANKER_PER
                            });
                        }
                    }
                    else if (gameType == 1)
                    {
                        List<M_ParaRoom> rooms = ef.ParaRoom
                            .Where(c => c.GAME_ID == gameId)
                            .OrderBy(c => c.ID)
                            .ToList();
                        List<M_ParaCard> cards = ef.ParaCards
                            .Where(c => c.GAME_ID == gameId)
                            .ToList();
                        int idx = 0;
                        foreach (M_ParaRoom r in rooms)
                        {
                            idx++;
                            M_ParaCard m = cards.FirstOrDefault(c => c.ID == r.ID);
                            rows.Add(new
                            {
                                id = r.ID,
                                num = r.NUM,
                                tableName = string.IsNullOrWhiteSpace(r.TableName) ? ("桌台" + idx) : r.TableName,
                                minBet = r.BET_MIN,
                                maxBet = r.BET_MAX,
                                exCoin = r.EX_COIN,
                                coinSc = r.COIN_SC,
                                coinNeed = r.COIN_NEED,
                                gameMo = r.Game_Mo,
                                maxSeats = r.MaxSeats <= 0 ? 6 : r.MaxSeats,
                                idleFireTimeoutSec = r.IdleFireTimeoutSec,
                                idleFireKickEnabled = r.IdleFireKickEnabled ? 1 : 0,
                                enabled = r.Enabled ? 1 : 0,
                                cardDif = m == null ? string.Empty : (m.DIF ?? string.Empty),
                                hypeType = m == null ? 0 : m.HYPE_TYPE
                            });
                        }
                    }
                    else if (gameType == 2)
                    {
                        List<M_ParaRoom> rooms = ef.ParaRoom
                            .Where(c => c.GAME_ID == gameId)
                            .OrderBy(c => c.ID)
                            .ToList();
                        List<M_ParaFish> fishes = ef.ParaFishes
                            .Where(c => c.GAME_ID == gameId)
                            .ToList();
                        int idx = 0;
                        foreach (M_ParaRoom r in rooms)
                        {
                            idx++;
                            M_ParaFish m = fishes.FirstOrDefault(c => c.ID == r.ID);
                            rows.Add(new
                            {
                                id = r.ID,
                                num = r.NUM,
                                tableName = string.IsNullOrWhiteSpace(r.TableName) ? ("桌台" + idx) : r.TableName,
                                minBet = r.BET_MIN,
                                maxBet = r.BET_MAX,
                                exCoin = r.EX_COIN,
                                coinSc = r.COIN_SC,
                                coinNeed = r.COIN_NEED,
                                gameMo = r.Game_Mo,
                                maxSeats = r.MaxSeats <= 0 ? 6 : r.MaxSeats,
                                idleFireTimeoutSec = r.IdleFireTimeoutSec,
                                idleFireKickEnabled = r.IdleFireKickEnabled ? 1 : 0,
                                enabled = r.Enabled ? 1 : 0,
                                fishDif = m == null ? 0 : m.DIF,
                                fishSiteType = m == null ? 0 : m.SITE_TYPE
                            });
                        }
                    }
                    else
                    {
                        string gameName = ef.Games.Where(c => c.GameId == gameId).Select(c => c.Name).FirstOrDefault() ?? ("游戏" + gameId);
                        var labaBL = new B_LabaGamePara();
                        var tableList = labaBL.GetTableList(gameId);
                        if (tableList.Count == 0) tableList.Add(0);
                        foreach (int tIdx in tableList)
                        {
                            int tid = gameId * 1000 + tIdx;
                            List<M_GameConfigLaba> labas = ef.GameConfigLabas.Where(c => c.GameId == gameId && c.TableIndex == tIdx).ToList();
                            int winRate = 0, exchangeRate = 0;
                            foreach (M_GameConfigLaba l in labas)
                            {
                                if (l.OptKey == "ExchangeScore") exchangeRate = l.OptValue;
                                else if (l.OptKey == "AIWinLuckyAtA2" || l.OptKey == "PlayerWin") winRate = l.OptValue;
                            }
                            string labaTableName = ef.Database.SqlQuery<string>(
                                "SELECT TableName FROM roomtableconfig WHERE GAME_ID={0} AND RoomIndex=0 AND TableIndex={1} LIMIT 1", gameId, tIdx)
                                .FirstOrDefault();
                            rows.Add(new
                            {
                                id = tid,
                                tableName = string.IsNullOrWhiteSpace(labaTableName) ? (gameName + (tIdx > 0 ? tIdx.ToString() : "")) : labaTableName,
                                enabled = 1,
                                winRate = winRate,
                                exchangeRate = exchangeRate
                            });
                        }
                    }
                    msg.code = 1;
                    msg.content = "获取成功！";
                    msg.datas = rows;
                }
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(GameConfigController), ex);
                msg.content = "获取失败：" + ex.Message;
            }
            return Json(msg);
        }

        [AjaxOnly]
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult DeleteTableConfig(FormCollection form)
        {
            Msg msg = new Msg(0, "删除失败！");
            try
            {
                M_LoginUser loginUser = WebHelper.GetLoginInfo();
                if (loginUser == null)
                {
                    msg.code = -1;
                    msg.content = "登录已过期，请重新登录！";
                    return Json(msg);
                }

                int gameType = form.Q<int>("GAME_TYPE", -1);
                int tableId = form.Q<int>("ID", -1);
                if (tableId < 0)
                {
                    msg.content = "未选择有效桌台！";
                    return Json(msg);
                }

                string roomTbl, machTbl;
                if (gameType == 0) { roomTbl = "ParaBetRoom"; machTbl = "ParaBet"; }
                else if (gameType == 1) { roomTbl = "ParaRoom"; machTbl = "ParaCard"; }
			else if (gameType == 3)
			{
				msg = new B_LabaGamePara().DeleteTable(tableId, tableId / 1000);
				return Json(msg);
			}

                else if (gameType == 2) { roomTbl = "ParaRoom"; machTbl = "ParaFish"; }
                else
                {
                    msg.content = "该类型不支持删除桌台！";
                    return Json(msg);
                }

                int gameId = -1;
                using (var ef = new GameDbContext())
                {
                    // 先解析该桌台所属游戏 ID（房间表与机台表均以 ID = 游戏ID*1000+序号 关联）。
                    gameId = ef.Database.SqlQuery<int>(
                        "SELECT GAME_ID FROM " + roomTbl + " WHERE ID={0}", tableId).FirstOrDefault();
                    if (gameId <= 0)
                    {
                        // 房间在库中已不存在，视为已删除成功，前端照常刷新即可。
                        msg.code = 1;
                        msg.datas = true;
                        msg.content = "该桌台已不存在（可能已被删除）。";
                        return Json(msg);
                    }

                    using (var tx = ef.Database.BeginTransaction())
                    {
                        try
                        {
                            // 1) 物理删除选中桌台（房间 + 其对应机台）。
                            ef.Database.ExecuteSqlCommand("DELETE FROM " + roomTbl + " WHERE ID={0}", tableId);
                            ef.Database.ExecuteSqlCommand("DELETE FROM " + machTbl + " WHERE ID={0}", tableId);

                            // 2) 把剩余房间重排为连续 id（游戏ID*1000+0..k-1），同步机台、NUM 及
                            //    paragame.ROOM_MAX。否则服务端会按 ROOM_MAX 把缺失的低位房间自动补建，
                            //    导致已删除的“桌台N”反复复活。
                            RepackRoomsAfterDelete(ef, roomTbl, machTbl, gameId);

                            tx.Commit();
                        }
                        catch
                        {
                            tx.Rollback();
                            throw;
                        }
                    }
                }

                // 数据库删除已成功提交：先标记为成功，确保前端能立即刷新桌台列表。
                // 服务端热更新属非关键步骤，其失败/异常仅作提示，绝不影响删除结果。
                msg.code = 1;
                msg.datas = true;
                msg.content = "彻底删除成功！";

                if (gameId > 0)
                {
                    try
                    {
                        var srv = new SConnect();
                        Msg rp = srv.SendReadString(EScMsgType.RP, gameId);
                        if (rp != null && rp.code == 1)
                        {
                            msg.content = "彻底删除成功，且服务端已即时热更新桌台列表！";
                        }
                        else
                        {
                            msg.content = "彻底删除成功，但服务端房间热更新失败：" + (rp == null ? "服务端无响应" : rp.content);
                        }
                    }
                    catch (Exception exRp)
                    {
                        LogHelper.WriteLog(typeof(GameConfigController), exRp);
                        msg.content = "彻底删除成功，但服务端房间热更新异常：" + exRp.Message;
                    }
                }
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(GameConfigController), ex);
                msg.content = "删除失败：" + ex.Message;
            }
            return Json(msg);
        }

        [AjaxOnly]
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult SaveTableConfig(FormCollection form)
        {
            Msg msg = new Msg(0, "保存失败！");
            try
            {
                M_LoginUser loginUser = WebHelper.GetLoginInfo();
                if (loginUser == null)
                {
                    msg.code = -1;
                    msg.content = "登录已过期，请重新登录！";
                    return Json(msg);
                }

                int gameType = form.Q<int>("GAME_TYPE", -1);
                int gameId = form.Q<int>("GAME_ID", -1);
                int tableId = form.Q<int>("ID", -1);
                if (gameId < 0)
                {
                    msg.content = "请选择需要配置的游戏！";
                    return Json(msg);
                }
                if (gameType != 0 && gameType != 1 && gameType != 2 && gameType != 3)
                {
                    msg.content = "未知的游戏类型！";
                    return Json(msg);
                }

                if (gameType == 3)
                {
                    if (tableId < 0) tableId = AllocTableId(3, gameId);
                    int winRate = form.Q<int>("WinRate", -1);
                    int exchangeRate = form.Q<int>("ExchangeRate", -1);
                    string labaTableName = (form.Q<string>("TableName", string.Empty) ?? string.Empty).Trim();
                    List<M_GameConfigLaba> labaList = new List<M_GameConfigLaba>();
                    labaList.Add(new M_GameConfigLaba { GameId = gameId, OptKey = "ExchangeScore", OptValue = exchangeRate, TIME = DateTime.Now, Type = string.Empty });
                    string winKey = gameId == 39 ? "AIWinLuckyAtA2" : ((gameId == 40 || gameId == 41) ? "PlayerWin" : string.Empty);
                    if (!string.IsNullOrEmpty(winKey))
                        labaList.Add(new M_GameConfigLaba { GameId = gameId, OptKey = winKey, OptValue = winRate, TIME = DateTime.Now, Type = string.Empty });
                    msg = new B_LabaGamePara().SaveTableFull(tableId, gameId, labaList, labaTableName);
                    return Json(msg);
                }
                bool isNew = tableId < 0;
                if (isNew)
                    tableId = AllocTableId(gameType, gameId);

                int maxSeats = gameType == 2 ? 6 : (gameType == 1 ? 0 : 8);

                int idleTimeout = form.Q<int>("IdleFireTimeoutSec", 0);
                if (idleTimeout < 0)
                {
                    msg.content = "无发炮踢出时间不能为负数！";
                    return Json(msg);
                }

                decimal minBetDisplay = form.Q<decimal>("MinBet", 0m);
                decimal maxBetDisplay = form.Q<decimal>("MaxBet", 0m);
                if (minBetDisplay < 0m || maxBetDisplay < 0m)
                {
                    msg.content = "下注值不能为负数！";
                    return Json(msg);
                }
                if (maxBetDisplay > 0m && minBetDisplay > maxBetDisplay)
                {
                    msg.content = "最小下注不能大于最大下注！";
                    return Json(msg);
                }

                int betMin = (int)Math.Round(minBetDisplay, MidpointRounding.AwayFromZero);
                int betMax = (int)Math.Round(maxBetDisplay, MidpointRounding.AwayFromZero);
                string tableName = (form.Q<string>("TableName", string.Empty) ?? string.Empty).Trim();
                bool idleKick = form.Q<int>("IdleFireKickEnabled", 1) == 1;
                bool enabled = form.Q<int>("Enabled", 1) == 1;
                int num = 0;
                int exCoin = form.Q<int>("EX_COIN", 1);
                int coinSc = form.Q<int>("COIN_SC", 1);
                int coinNeed = form.Q<int>("COIN_NEED", 0);
                int gameMo = form.Q<int>("Game_Mo", 0);

                if (gameType == 0)
                {
                    M_ParaBetRoom room = new M_ParaBetRoom();
                    room.ID = tableId;
                    room.GAME_ID = gameId;
                    room.BET_TIME = form.Q<int>("BET_TIME", 0);
                    room.NUM = num;
                    room.BET_MIN = betMin;
                    room.BET_MAX = betMax;
                    room.BET_MIN_VICE = form.Q<int>("BET_MIN_VICE", 0);
                    room.BET_MAX_VICE = form.Q<int>("BET_MAX_VICE", 0);
                    room.BET_MIN_DRAW = form.Q<int>("BET_MIN_DRAW", 0);
                    room.BET_MAX_DRAW = form.Q<int>("BET_MAX_DRAW", 0);
                    room.EX_COIN = exCoin;
                    room.COIN_SC = coinSc;
                    room.COIN_NEED = coinNeed;
                    room.BANKER_SC_NEED = form.Q<int>("BANKER_SC_NEED", 0);
                    room.SC_LIMIT_SING = form.Q<int>("SC_LIMIT_SING", 0);
                    room.SC_LIMIT_ALL = form.Q<int>("SC_LIMIT_ALL", 0);
                    room.Game_Mo = gameMo;
                    room.BetScores = (form.Q<string>("BetScores", string.Empty) ?? string.Empty).Trim();
                    room.DefaultBetIndex = 0;
                    room.TableName = tableName;
                    room.MaxSeats = maxSeats;
                    room.IdleFireTimeoutSec = idleTimeout;
                    room.IdleFireKickEnabled = idleKick;
                    room.Enabled = enabled;

                    M_ParaBet machine = new M_ParaBet();
                    machine.ID = tableId;
                    machine.GAME_ID = gameId;
                    machine.DIF = form.Q<int>("DIF", 0);
                    machine.HAR = form.Q<int>("HAR", 0);
                    machine.SITE_TYPE = form.Q<int>("SITE_TYPE", 0);
                    machine.BANKER_DIF = form.Q<int>("BANKER_DIF", 0);
                    machine.BANKER_HAR = form.Q<int>("BANKER_HAR", 0);
                    machine.BANKER_SITE_TYPE = form.Q<int>("BANKER_SITE_TYPE", 0);
                    machine.BANKER_PER = form.Q<int>("BANKER_PER", 0);

                    msg = new B_BetGamePara().SaveTableFull(room, machine);
                }
                else if (gameType == 1)
                {
                    M_ParaRoom room = BuildParaRoom(tableId, gameId, num, betMin, betMax, exCoin, coinSc, coinNeed, gameMo, tableName, maxSeats, idleTimeout, idleKick, enabled);

                    M_ParaCard machine = new M_ParaCard();
                    machine.ID = tableId;
                    machine.GAME_ID = gameId;
                    string cardDif = (form.Q<string>("CardDIF", string.Empty) ?? string.Empty).Trim();
                    machine.DIF = cardDif.Length == 16 ? cardDif : "0000000000000000";
                    machine.HYPE_TYPE = form.Q<int>("HYPE_TYPE", 0);

                    msg = new B_CardGamePara().SaveTableFull(room, machine);
                }
                else
                {
                    M_ParaRoom room = BuildParaRoom(tableId, gameId, num, betMin, betMax, exCoin, coinSc, coinNeed, gameMo, tableName, maxSeats, idleTimeout, idleKick, enabled);

                    M_ParaFish machine = new M_ParaFish();
                    machine.ID = tableId;
                    machine.GAME_ID = gameId;
                    machine.DIF = form.Q<int>("FishDIF", 0);
                    machine.SITE_TYPE = form.Q<int>("FishSITE_TYPE", 0);

                    msg = new B_FishGamePara().SaveTableFull(room, machine);
                }

                // ROOM_MAX 同步已下沉到 B_SuperPara.PushHotUpdate 内(在发 RP 之前执行)，
                // 此处不再事后补调——那时服务端已按旧 ROOM_MAX 重载完毕，补调为时已晚。
                // 注：SyncRoomMaxToRoomCount 方法保留供本控制器其它路径(如删除)复用。
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(GameConfigController), ex);
                msg.code = 0;
                msg.content = "保存失败：" + ex.Message;
            }
            return Json(msg);
        }

        private static M_ParaRoom BuildParaRoom(int tableId, int gameId, int num, int betMin, int betMax, int exCoin, int coinSc, int coinNeed, int gameMo, string tableName, int maxSeats, int idleTimeout, bool idleKick, bool enabled)
        {
            M_ParaRoom room = new M_ParaRoom();
            room.ID = tableId;
            room.GAME_ID = gameId;
            room.NUM = num;
            room.BET_MIN = betMin;
            room.BET_MAX = betMax;
            room.MinBetUnits = betMin * 10;
            room.MaxBetUnits = betMax * 10;
            room.EX_COIN = exCoin;
            room.COIN_SC = coinSc;
            room.COIN_NEED = coinNeed;
            room.scoreSwitch = betMin;
            room.Game_Mo = gameMo;
            room.TableName = tableName;
            room.MaxSeats = maxSeats;
            room.IdleFireTimeoutSec = idleTimeout;
            room.IdleFireKickEnabled = idleKick;
            room.Enabled = enabled;
            return room;
        }

        // 删除桌台后：把该游戏剩余房间重排为连续 id（游戏ID*1000+0..k-1），
        // 同步对应机台行，并把房间 NUM 与 paragame.ROOM_MAX 都设为剩余桌台数 k。
        // 采用“负数临时 id”两段式重排，彻底避免主键碰撞；并清理目标区间内可能残留的孤儿机台。
        private static void RepackRoomsAfterDelete(GameDbContext ef, string roomTbl, string machTbl, int gameId)
        {
            int baseId = gameId * 1000;
            List<int> ids = ef.Database.SqlQuery<int>(
                "SELECT ID FROM " + roomTbl + " WHERE GAME_ID={0} ORDER BY ID ASC", gameId).ToList();
            int k = ids.Count;

            // 第一段：把所有剩余房间与其机台移到唯一负数临时 id，腾空正数目标区间。
            for (int i = 0; i < k; i++)
            {
                int cur = ids[i];
                int tmp = -(baseId + i + 1);
                ef.Database.ExecuteSqlCommand("UPDATE " + roomTbl + " SET ID={0} WHERE ID={1}", tmp, cur);
                ef.Database.ExecuteSqlCommand("UPDATE " + machTbl + " SET ID={0} WHERE ID={1}", tmp, cur);
            }

            // 清理目标区间内可能残留的“孤儿机台”（无对应房间），避免第二段回填时主键冲突。
            if (k > 0)
            {
                ef.Database.ExecuteSqlCommand(
                    "DELETE FROM " + machTbl + " WHERE GAME_ID={0} AND ID BETWEEN {1} AND {2}", gameId, baseId, baseId + k - 1);
            }

            // 第二段：把负数临时 id 回填为连续正数 id。
            for (int i = 0; i < k; i++)
            {
                int tmp = -(baseId + i + 1);
                int dst = baseId + i;
                ef.Database.ExecuteSqlCommand("UPDATE " + roomTbl + " SET ID={0} WHERE ID={1}", dst, tmp);
                ef.Database.ExecuteSqlCommand("UPDATE " + machTbl + " SET ID={0} WHERE ID={1}", dst, tmp);
            }

            // 房间 NUM = 剩余桌台数，与保存逻辑保持一致。
            ef.Database.ExecuteSqlCommand("UPDATE " + roomTbl + " SET NUM={0} WHERE GAME_ID={1}", k, gameId);

            // 同步 paragame.ROOM_MAX = 剩余桌台数（服务端按它决定加载/补建几张桌）。
            int affected = ef.Database.ExecuteSqlCommand("UPDATE ParaGame SET ROOM_MAX={0} WHERE ID={1}", k, gameId);
            if (affected == 0)
                ef.Database.ExecuteSqlCommand("INSERT INTO ParaGame(ID,ROOM_MAX,PLY_MAX) VALUES({0},{1},{2})", gameId, k, 1000);
        }

        // 新建/保存桌台后：把 paragame.ROOM_MAX 同步为该游戏当前房间总数，
        // 否则新建的桌台 id 超过旧 ROOM_MAX 时，服务端不会加载它（新桌对服务端不可见）。
        private static void SyncRoomMaxToRoomCount(int gameType, int gameId)
        {
            if (gameId <= 0) return;
            string roomTbl;
            if (gameType == 0) roomTbl = "ParaBetRoom";
            else if (gameType == 1 || gameType == 2) roomTbl = "ParaRoom";
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
                }
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(GameConfigController), ex);
            }
        }

        private static int AllocTableId(int gameType, int gameId)
        {
            int baseId = gameId * 1000;
            using (var ef = new GameDbContext())
            {
		if (gameType == 3)
		{
			var maxTbl = ef.GameConfigLabas.Where(c => c.GameId == gameId)
				.Select(c => (int?)c.TableIndex).Max() ?? -1;
			return baseId + maxTbl + 1;
		}
		                List<int> ids;
                if (gameType == 0)
                    ids = ef.ParaBetRooms.Where(c => c.GAME_ID == gameId).Select(c => c.ID).ToList();
                else
                    ids = ef.ParaRoom.Where(c => c.GAME_ID == gameId).Select(c => c.ID).ToList();

                int next = baseId;
                if (ids.Count > 0)
                    next = ids.Max() + 1;
                return next;
            }
        }
    }
}
