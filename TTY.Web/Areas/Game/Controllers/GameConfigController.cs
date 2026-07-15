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
                        List<CardPayoutRowDto> payoutRows = ef.Database.SqlQuery<CardPayoutRowDto>(
                            "SELECT TableId, HandType, PayoutMultiplier, ProbabilityBasis, Enabled FROM cardpayoutprofile WHERE GAME_ID={0}", gameId).ToList();
                        int idx = 0;
                        foreach (M_ParaRoom r in rooms)
                        {
                            idx++;
                            M_ParaCard m = cards.FirstOrDefault(c => c.ID == r.ID);
                            int tIdx = r.ID % 1000;
                            List<CardPayoutRowDto> pr = payoutRows.Where(c => c.TableId == tIdx).ToList();
                            Dictionary<string, int> payout = new Dictionary<string, int>();
                            foreach (CardPayoutRowDto p in pr)
                            {
                                payout["p" + p.HandType] = p.ProbabilityBasis;
                                payout["m" + p.HandType] = p.PayoutMultiplier;
                            }
                            rows.Add(new
                            {
                                id = r.ID,
                                num = r.NUM,
                                tableName = string.IsNullOrWhiteSpace(r.TableName) ? ("桌台" + idx) : r.TableName,
                                minBet = r.MinBetUnits > 0 ? r.MinBetUnits / 10m : r.BET_MIN,
                                maxBet = r.MaxBetUnits > 0 ? r.MaxBetUnits / 10m : r.BET_MAX,
                                exCoin = r.EX_COIN,
                                coinSc = r.COIN_SC,
                                coinNeed = r.COIN_NEED,
                                gameMo = r.Game_Mo,
                                scoreSwitch = r.scoreSwitch,
                                maxSeats = r.MaxSeats <= 0 ? 6 : r.MaxSeats,
                                idleFireTimeoutSec = r.IdleFireTimeoutSec,
                                idleFireKickEnabled = r.IdleFireKickEnabled ? 1 : 0,
                                enabled = r.Enabled ? 1 : 0,
                                cardDif = m == null ? string.Empty : (m.DIF ?? string.Empty),
                                hypeType = m == null ? 0 : m.HYPE_TYPE,
                                payoutOn = pr.Any(c => c.Enabled == 1) ? 1 : 0,
                                payout = payout
                            });
                        }
                    }
                    else if (gameType == 2)
                    {
                        var cfgNames = ef.Database.SqlQuery<string>(
                            "SELECT TableName FROM roomtableconfig WHERE GAME_ID=" + gameId + " ORDER BY TableIndex").ToList();
                        var cfgBetMins = ef.Database.SqlQuery<int>(
                            "SELECT BetMin FROM roomtableconfig WHERE GAME_ID=" + gameId + " ORDER BY TableIndex").ToList();
                        var cfgBetMaxs = ef.Database.SqlQuery<int>(
                            "SELECT BetMax FROM roomtableconfig WHERE GAME_ID=" + gameId + " ORDER BY TableIndex").ToList();
                        var cfgCoinScores = ef.Database.SqlQuery<int>(
                            "SELECT OneCoinScore FROM roomtableconfig WHERE GAME_ID=" + gameId + " ORDER BY TableIndex").ToList();
                        var cfgCoinNeeds = ef.Database.SqlQuery<int>(
                            "SELECT CoinsNeed FROM roomtableconfig WHERE GAME_ID=" + gameId + " ORDER BY TableIndex").ToList();
                        var cfgEnableds = ef.Database.SqlQuery<int>(
                            "SELECT Enabled FROM roomtableconfig WHERE GAME_ID=" + gameId + " ORDER BY TableIndex").ToList();
                        for (int i = 0; i < cfgNames.Count; i++)
                        {
                            rows.Add(new
                            {
                                id = gameId * 1000 + i,
                                num = 1,
                                tableName = string.IsNullOrWhiteSpace(cfgNames[i]) ? ("机台" + i) : cfgNames[i],
                                minBet = gameId == 3 ? (i < cfgBetMins.Count ? cfgBetMins[i] / 10m : 10m) : (i < cfgBetMins.Count ? (decimal)cfgBetMins[i] : 100m),
                                maxBet = gameId == 3 ? (i < cfgBetMaxs.Count ? cfgBetMaxs[i] / 10m : 100m) : (i < cfgBetMaxs.Count ? (decimal)cfgBetMaxs[i] : 1000m),
                                exCoin = 10000,
                                coinSc = i < cfgCoinScores.Count ? cfgCoinScores[i] : 1,
                                coinNeed = i < cfgCoinNeeds.Count ? cfgCoinNeeds[i] : 10000,
                                gameMo = 100,
                                maxSeats = 6,
                                idleFireTimeoutSec = 0,
                                idleFireKickEnabled = 1,
                                enabled = i < cfgEnableds.Count ? cfgEnableds[i] : 1,
                                fishDif = 0,
                                fishSiteType = 0
                            });
                        }
                    }
                    else  // gameType == 3 拉霸
                    {
                        int subType = GetLabaSubType(gameId);
                        string gameName = ef.Games.Where(c => c.GameId == gameId).Select(c => c.Name).FirstOrDefault() ?? ("游戏" + gameId);
                        var labaBL = new B_LabaGamePara();
                        var tableList = labaBL.GetTableList(gameId);
                        if (tableList.Count == 0) tableList.Add(0);
                        foreach (int tIdx in tableList)
                        {
                            int tid = gameId * 1000 + tIdx;
                            List<M_GameConfigLaba> labas = ef.GameConfigLabas.Where(c => c.GameId == gameId && c.TableIndex == tIdx).ToList();
                            string tableName = ef.Database.SqlQuery<string>(
                                "SELECT TableName FROM roomtableconfig WHERE GAME_ID={0} AND RoomIndex=0 AND TableIndex={1} LIMIT 1", gameId, tIdx)
                                .FirstOrDefault();
                            int enabled = ef.Database.SqlQuery<int?>(
                                "SELECT Enabled FROM roomtableconfig WHERE GAME_ID={0} AND RoomIndex=0 AND TableIndex={1} LIMIT 1", gameId, tIdx)
                                .FirstOrDefault() ?? 1;

                            Dictionary<string, object> row = new Dictionary<string, object>();
                            row["id"] = tid;
                            row["tableName"] = string.IsNullOrWhiteSpace(tableName) ? (gameName + (tIdx > 0 ? tIdx.ToString() : "")) : tableName;
                            row["enabled"] = enabled;
                            row["labaSubType"] = subType;

                            if (subType == 3)  // 水浒传
                            {
                                var paraBet = ef.ParaBets.Where(c => c.GAME_ID == gameId && c.ID == tid).FirstOrDefault();
                                row["dif"] = paraBet?.DIF ?? 0;
                                row["har"] = paraBet?.HAR ?? 0;
                            }
                            int symMax = subType == 2 ? 7 : (subType == 1 || subType == 3 ? 8 : -1);
                            for (int p = 0; p <= symMax; p++)
                            {
                                row["payout" + p] = GetLabaOptValue(labas, "Payout" + p);
                                row["prob" + p] = GetLabaOptValue(labas, "Prob" + p);
                            }

                            // 押分支持一位小数：优先用 X10 键还原，无则回退旧整数键
                            int bMinU = GetLabaOptValue(labas, "betMinX10");
                            int bMaxU = GetLabaOptValue(labas, "betMaxX10");
                            row["minBet"] = bMinU > 0 ? (object)(bMinU / 10m) : GetLabaOptValue(labas, "betMin");
                            row["maxBet"] = bMaxU > 0 ? (object)(bMaxU / 10m) : GetLabaOptValue(labas, "betMax");
                            row["coinNeed"] = GetLabaOptValue(labas, "coinsNeed");
                            row["defaultBetIndex"] = GetLabaOptValue(labas, "defaultBetIndex");
                            int exCoinV = GetLabaOptValue(labas, "exCoin");
                            int coinScV = GetLabaOptValue(labas, "coinSc");
                            int gameMoV = GetLabaOptValue(labas, "gameMo");
                            int scoreSwU = GetLabaOptValue(labas, "scoreSwitchX10");
                            row["exCoin"] = exCoinV > 0 ? exCoinV : 1;
                            row["coinSc"] = coinScV > 0 ? coinScV : 1;
                            row["gameMo"] = gameMoV > 0 ? gameMoV : 1;
                            row["scoreSwitch"] = scoreSwU > 0 ? scoreSwU / 10m : 0.1m;
                            row["idleFireTimeoutSec"] = 0;

                            rows.Add(row);
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

			else if (gameType == 2)

			{

				int fishGid = tableId / 1000;

				int fishTidx = tableId % 1000;

				using (var ef2 = new GameDbContext())

				{

					ef2.Database.ExecuteSqlCommand("DELETE FROM roomtableconfig WHERE GAME_ID=" + fishGid + " AND TableIndex=" + fishTidx);

				}

				msg.code = 1;

				msg.content = "删除成功";

				return Json(msg);

			}

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

                            // 牌机：同步牌型赔付配置的机台号（删除该桌行 + 高位机台号左移，与房间重排保持一致）。
                            if (gameType == 1)
                            {
                                int delIdx = tableId % 1000;
                                ef.Database.ExecuteSqlCommand(
                                    "DELETE FROM cardpayoutprofile WHERE GAME_ID={0} AND TableId={1}", gameId, delIdx);
                                ef.Database.ExecuteSqlCommand(
                                    "UPDATE cardpayoutprofile SET TableId=TableId-1 WHERE GAME_ID={0} AND TableId>{1}", gameId, delIdx);
                            }

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
                    int subType = GetLabaSubType(gameId);
                    string labaTableName = (form.Q<string>("TableName", string.Empty) ?? string.Empty).Trim();
                    int labaEnabled = form.Q<int>("Enabled", 1);

                    List<M_GameConfigLaba> labaList = new List<M_GameConfigLaba>();

                    int labaSymMax = subType == 2 ? 7 : (subType == 1 || subType == 3 ? 8 : -1);
                    for (int p = 0; p <= labaSymMax; p++)
                    {
                        int val = form.Q<int>("Payout" + p, -1);
                        if (val >= 0)
                            labaList.Add(new M_GameConfigLaba { GameId = gameId, OptKey = "Payout" + p, OptValue = val, TIME = DateTime.Now, Type = "Payout" });
                        int prob = form.Q<int>("Prob" + p, -1);
                        if (prob > 10000)
                        {
                            msg.content = "符号" + p + " 出现率不能超过 10000！";
                            return Json(msg);
                        }
                        if (prob >= 0)
                            labaList.Add(new M_GameConfigLaba { GameId = gameId, OptKey = "Prob" + p, OptValue = prob, TIME = DateTime.Now, Type = "Payout" });
                    }

                    // 押分支持一位小数（715 文档最小押分 0.1）：以 X10 键存储，旧 betMin/betMax 键同步存取整供服务端兼容
                    decimal labaBetMinD = form.Q<decimal>("MinBet", -1m);
                    decimal labaBetMaxD = form.Q<decimal>("MaxBet", -1m);
                    int labaCoinsNeed = form.Q<int>("COIN_NEED", -1);
                    int labaDefaultBetIdx = form.Q<int>("defaultBetIndex", -1);
                    int labaExCoin = form.Q<int>("EX_COIN", -1);
                    int labaCoinSc = form.Q<int>("COIN_SC", -1);
                    int labaGameMo = form.Q<int>("Game_Mo", -1);
                    decimal labaScoreSw = form.Q<decimal>("scoreSwitch", -1m);
                    if (labaBetMinD >= 0)
                    {
                        labaList.Add(new M_GameConfigLaba { GameId = gameId, OptKey = "betMinX10", OptValue = (int)Math.Round(labaBetMinD * 10m), TIME = DateTime.Now, Type = "Room" });
                        labaList.Add(new M_GameConfigLaba { GameId = gameId, OptKey = "betMin", OptValue = (int)Math.Round(labaBetMinD), TIME = DateTime.Now, Type = "Room" });
                    }
                    if (labaBetMaxD >= 0)
                    {
                        labaList.Add(new M_GameConfigLaba { GameId = gameId, OptKey = "betMaxX10", OptValue = (int)Math.Round(labaBetMaxD * 10m), TIME = DateTime.Now, Type = "Room" });
                        labaList.Add(new M_GameConfigLaba { GameId = gameId, OptKey = "betMax", OptValue = (int)Math.Round(labaBetMaxD), TIME = DateTime.Now, Type = "Room" });
                    }
                    if (labaCoinsNeed >= 0)
                        labaList.Add(new M_GameConfigLaba { GameId = gameId, OptKey = "coinsNeed", OptValue = labaCoinsNeed, TIME = DateTime.Now, Type = "Room" });
                    if (labaDefaultBetIdx >= 0)
                        labaList.Add(new M_GameConfigLaba { GameId = gameId, OptKey = "defaultBetIndex", OptValue = labaDefaultBetIdx, TIME = DateTime.Now, Type = "Room" });
                    if (labaExCoin > 0)
                        labaList.Add(new M_GameConfigLaba { GameId = gameId, OptKey = "exCoin", OptValue = labaExCoin, TIME = DateTime.Now, Type = "Room" });
                    if (labaCoinSc > 0)
                        labaList.Add(new M_GameConfigLaba { GameId = gameId, OptKey = "coinSc", OptValue = labaCoinSc, TIME = DateTime.Now, Type = "Room" });
                    if (labaGameMo > 0)
                        labaList.Add(new M_GameConfigLaba { GameId = gameId, OptKey = "gameMo", OptValue = labaGameMo, TIME = DateTime.Now, Type = "Room" });
                    if (labaScoreSw >= 0)
                        labaList.Add(new M_GameConfigLaba { GameId = gameId, OptKey = "scoreSwitchX10", OptValue = (int)Math.Round(labaScoreSw * 10m), TIME = DateTime.Now, Type = "Room" });

                    int rtTableIndex = tableId % 1000;
                    int rtBetMin = labaBetMinD >= 0 ? (int)Math.Round(labaBetMinD) : 100;
                    int rtBetMax = labaBetMaxD >= 0 ? (int)Math.Round(labaBetMaxD) : 10000;
                    int rtCoinsNeed = labaCoinsNeed >= 0 ? labaCoinsNeed : 0;
                    using (var efRt = new GameDbContext())
                    {
                        efRt.Database.ExecuteSqlCommand(
                            "DELETE FROM roomtableconfig WHERE GAME_ID=" + gameId + " AND RoomIndex=0 AND TableIndex=" + rtTableIndex);
                        efRt.Database.ExecuteSqlCommand(
                            "INSERT INTO roomtableconfig (GAME_ID, RoomIndex, TableIndex, TableName, Enabled, MaxSeats, OneCoinScore, BetMin, BetMax, CoinsNeed, IdleFireTimeoutSec, IdleFireKickEnabled) VALUES (" +
                            gameId + ",0," + rtTableIndex + ",'" + labaTableName.Replace("'", "''") + "'," + labaEnabled + ",6,1," +
                            rtBetMin + "," + rtBetMax + "," + rtCoinsNeed + ",0,0)");
                    }

                    msg = new B_LabaGamePara().SaveTableFull(tableId, gameId, labaList, labaTableName, labaEnabled);
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
                decimal scoreSwitch = form.Q<decimal>("scoreSwitch", 0m);

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
                    M_ParaRoom room = BuildParaRoom(tableId, gameId, num, minBetDisplay, maxBetDisplay, exCoin, coinSc, coinNeed, gameMo, tableName, maxSeats, idleTimeout, idleKick, enabled, scoreSwitch);

                    M_ParaCard machine = new M_ParaCard();
                    machine.ID = tableId;
                    machine.GAME_ID = gameId;
                    string cardDif = (form.Q<string>("CardDIF", string.Empty) ?? string.Empty).Trim();
                    machine.DIF = cardDif.Length == 16 ? cardDif : "0000000000000000";
                    machine.HYPE_TYPE = form.Q<int>("HYPE_TYPE", 0);

                    // 牌型概率(万分比)/倍数：HandType 与服务端 te_CardsType 对齐；
                    // 四条(7)同时镜像大四条(8)倍数（概率集中在 7）。
                    int[] payoutHandTypes = new int[] { 0, 1, 2, 3, 4, 5, 6, 7, 9, 10, 11 };
                    int payoutOn = form.Q<int>("PayoutOn", 0) == 1 ? 1 : 0;
                    List<int[]> payoutProfiles = new List<int[]>();
                    int probSum = 0;
                    foreach (int ht in payoutHandTypes)
                    {
                        int prob = (int)Math.Round(form.Q<decimal>("hp" + ht, 0m), MidpointRounding.AwayFromZero);
                        int mult = (int)Math.Round(form.Q<decimal>("hm" + ht, 0m), MidpointRounding.AwayFromZero);
                        if (prob < 0 || prob > 10000 || mult < 0)
                        {
                            msg.content = "牌型概率须在 0-10000（万分比）之间且倍数不能为负！";
                            return Json(msg);
                        }
                        if (ht != 0) probSum += prob;
                        payoutProfiles.Add(new[] { ht, prob, mult });
                    }
                    if (payoutOn == 1 && probSum > 10000)
                    {
                        msg.content = "中奖牌型概率合计 " + probSum + " 超过 10000（万分比），请调低后再保存！";
                        return Json(msg);
                    }

                    int tIdxCard = tableId % 1000;
                    using (var efP = new GameDbContext())
                    {
                        using (var txP = efP.Database.BeginTransaction())
                        {
                            try
                            {
                                efP.Database.ExecuteSqlCommand(
                                    "DELETE FROM cardpayoutprofile WHERE GAME_ID={0} AND TableId={1}", gameId, tIdxCard);
                                foreach (int[] p in payoutProfiles)
                                {
                                    efP.Database.ExecuteSqlCommand(
                                        "INSERT INTO cardpayoutprofile (GAME_ID, TableId, HandType, PayoutMultiplier, ProbabilityBasis, StockLimit, StockRemain, Enabled) VALUES ({0},{1},{2},{3},{4},0,0,{5})",
                                        gameId, tIdxCard, p[0], p[2], p[1], payoutOn);
                                    if (p[0] == 7)
                                        efP.Database.ExecuteSqlCommand(
                                            "INSERT INTO cardpayoutprofile (GAME_ID, TableId, HandType, PayoutMultiplier, ProbabilityBasis, StockLimit, StockRemain, Enabled) VALUES ({0},{1},8,{2},0,0,0,{3})",
                                            gameId, tIdxCard, p[2], payoutOn);
                                }
                                txP.Commit();
                            }
                            catch
                            {
                                txP.Rollback();
                                throw;
                            }
                        }
                    }

                    msg = new B_CardGamePara().SaveTableFull(room, machine);
                }
                else
                {
                    int tIdx = tableId % 1000;
                    string tName = (form.Q<string>("TableName", string.Empty) ?? "").Trim();
                    int tblEnabled = form.Q<int>("Enabled", 1);
                    int idleSec = form.Q<int>("IdleFireTimeoutSec", 0);
                    int tblIdleKick = form.Q<int>("IdleFireKickEnabled", 1);
                    int tblMaxSeats = form.Q<int>("MaxSeats", 6);
                    using (var ef = new GameDbContext())
                    {
                        ef.Database.ExecuteSqlCommand(
                            "DELETE FROM roomtableconfig WHERE GAME_ID=" + gameId + " AND TableIndex=" + tIdx);
                        int rtBetMinSave = betMin;
                        int rtBetMaxSave = betMax;
                        if (gameId == 3) // E_FISH_JC pilot: internal unit = 0.1 credit
                        {
                            rtBetMinSave = (int)Math.Round(minBetDisplay * 10m, MidpointRounding.AwayFromZero);
                            rtBetMaxSave = (int)Math.Round(maxBetDisplay * 10m, MidpointRounding.AwayFromZero);
                        }
                        ef.Database.ExecuteSqlCommand(
                            "INSERT INTO roomtableconfig (GAME_ID, RoomIndex, TableIndex, TableName, Enabled, OneCoinScore, BetMin, BetMax, CoinsNeed, IdleFireTimeoutSec, IdleFireKickEnabled, MaxSeats) VALUES (" +
                            gameId + ",0," + tIdx + ",'" + tName.Replace("'", "''") + "'," + tblEnabled + "," + coinSc + "," + rtBetMinSave + "," + rtBetMaxSave + "," + coinNeed + "," + idleSec + "," + tblIdleKick + "," + tblMaxSeats + ")");
                        if (gameId == 3)
                        {
                            try
                            {
                                ef.Database.ExecuteSqlCommand(
                                    "UPDATE ParaRoom SET BET_MIN=" + betMin + ",BET_MAX=" + betMax + ",MinBetUnits=" + rtBetMinSave + ",MaxBetUnits=" + rtBetMaxSave + ",COIN_SC=" + coinSc + ",COIN_NEED=" + coinNeed + " WHERE GAME_ID=" + gameId + " AND ID=" + (gameId * 1000 + tIdx));
                            }
                            catch (Exception exRoom)
                            {
                                LogHelper.WriteLog(typeof(GameConfigController), exRoom);
                            }
                        }
                    }
                    var srv = new SConnect();
                    msg = srv.SendReadString(EScMsgType.RP, gameId);
                    if (msg.code == 1)
                    {
                        var srvTc = new SConnect();
                        srvTc.SendTcCommand((ushort)gameId, 0, (ushort)tIdx, tName, (byte)(tblEnabled != 0 ? 1 : 0), (uint)idleSec, (byte)(tblIdleKick != 0 ? 1 : 0), (ushort)tblMaxSeats);
                    }
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

        private static M_ParaRoom BuildParaRoom(int tableId, int gameId, int num, decimal minBetDisplay, decimal maxBetDisplay, int exCoin, int coinSc, int coinNeed, int gameMo, string tableName, int maxSeats, int idleTimeout, bool idleKick, bool enabled, decimal scoreSwitch = 0m)
        {
            M_ParaRoom room = new M_ParaRoom();
            room.ID = tableId;
            room.GAME_ID = gameId;
            room.NUM = num;
            room.BET_MIN = (int)Math.Round(minBetDisplay, MidpointRounding.AwayFromZero);
            room.BET_MAX = (int)Math.Round(maxBetDisplay, MidpointRounding.AwayFromZero);
            room.MinBetUnits = (int)Math.Round(minBetDisplay * 10m, MidpointRounding.AwayFromZero);
            room.MaxBetUnits = (int)Math.Round(maxBetDisplay * 10m, MidpointRounding.AwayFromZero);
            room.EX_COIN = exCoin;
            room.COIN_SC = coinSc;
            room.COIN_NEED = coinNeed;
            room.scoreSwitch = scoreSwitch > 0 ? scoreSwitch : minBetDisplay;
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

			if (gameType == 2)

			{

				var fishMax = ef.Database.SqlQuery<int?>("SELECT MAX(TableIndex) FROM roomtableconfig WHERE GAME_ID=" + gameId).FirstOrDefault() ?? -1;
				return baseId + fishMax + 1;

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

        private static int GetLabaSubType(int gameId)
        {
            if (gameId == 53) return 3;
            if (gameId == 16) return 1;
            if (gameId == 40) return 2;
            return 0;
        }

        private static int GetLabaOptValue(List<M_GameConfigLaba> labas, string optKey)
        {
            var item = labas.FirstOrDefault(c => c.OptKey == optKey);
            return item != null ? item.OptValue : 0;
    }

        // cardpayoutprofile 行映射（原生 SQL 查询用）
        public class CardPayoutRowDto
        {
            public int TableId { get; set; }
            public int HandType { get; set; }
            public int PayoutMultiplier { get; set; }
            public int ProbabilityBasis { get; set; }
            public int Enabled { get; set; }
        }

}
}
