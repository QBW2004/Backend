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
                        // 一房N桌模型：桌台列表以 roomtableconfig 为准(按桌存)，
                        // 桌级押注参数(BetTime/限红/BetScores/庄闲和)优先从 roomtableconfig_bet 按桌取，
                        // 缺行时回退 parabetroom base 行(所有桌共享)。
                        // EX_COIN/Game_Mo 仅 base 行有(房级共享)，难度从 parabet、赔率从 cardpayoutprofile 关联。
                        M_ParaBetRoom baseRoom = ef.ParaBetRooms.FirstOrDefault(c => c.GAME_ID == gameId);
                        List<M_ParaBet> bets = ef.ParaBets
                            .Where(c => c.GAME_ID == gameId)
                            .ToList();
                        List<CardPayoutRowDto> betPayoutRows = ef.Database.SqlQuery<CardPayoutRowDto>(
                            "SELECT TableId, HandType, PayoutMultiplier, ProbabilityBasis, Enabled FROM cardpayoutprofile WHERE GAME_ID={0}", gameId).ToList();
                        // 按桌读取 roomtableconfig（桌名/启用/限红/MaxSeats/IdleFire 等桌级参数）
                        var cfgRows = ef.Database.SqlQuery<BetTableCfgRow>(
                            "SELECT TableIndex, TableName, Enabled, BetMin, BetMax, CoinsNeed, OneCoinScore, MaxSeats, IdleFireTimeoutSec, IdleFireKickEnabled FROM roomtableconfig WHERE GAME_ID={0} ORDER BY TableIndex", gameId).ToList();
                        // 按桌读取 roomtableconfig_bet（押注时长/庄闲和限红/投注档位等桌级押注参数）
                        var betCfgRows = ef.Database.SqlQuery<BetTableCfgBetRow>(
                            "SELECT TableIndex, BetTime, BetMin, BetMax, BankerScoreNeed, ItemSingleScoreLimit, ItemAllScoreLimit, CoinsNeed, OneCoinScore, BetScores, DefaultBetIndex, BetMinVice, BetMaxVice, BetMinDraw, BetMaxDraw FROM roomtableconfig_bet WHERE GAME_ID={0} ORDER BY TableIndex", gameId).ToList();
                        int bidx = 0;
                        foreach (BetTableCfgRow cfg in cfgRows)
                        {
                            bidx++;
                            int btIdx = cfg.TableIndex;
                            int tableIdFull = gameId * 1000 + btIdx;
                            M_ParaBet m = bets.FirstOrDefault(c => c.ID == tableIdFull);
                            List<CardPayoutRowDto> bpr = betPayoutRows.Where(c => c.TableId == btIdx).ToList();
                            // 按桌押注参数：优先 roomtableconfig_bet，缺则回退 base 行
                            BetTableCfgBetRow bcfg = betCfgRows.FirstOrDefault(c => c.TableIndex == btIdx);
                            int vBetTime       = bcfg != null ? bcfg.BetTime       : (baseRoom == null ? 10 : baseRoom.BET_TIME);
                            int vBetMinVice    = bcfg != null ? bcfg.BetMinVice    : (baseRoom == null ? 0 : baseRoom.BET_MIN_VICE);
                            int vBetMaxVice    = bcfg != null ? bcfg.BetMaxVice    : (baseRoom == null ? 0 : baseRoom.BET_MAX_VICE);
                            int vBetMinDraw    = bcfg != null ? bcfg.BetMinDraw    : (baseRoom == null ? 0 : baseRoom.BET_MIN_DRAW);
                            int vBetMaxDraw    = bcfg != null ? bcfg.BetMaxDraw    : (baseRoom == null ? 0 : baseRoom.BET_MAX_DRAW);
                            int vBankerScNeed  = bcfg != null ? bcfg.BankerScoreNeed : (baseRoom == null ? 0 : baseRoom.BANKER_SC_NEED);
                            int vScLimitSing   = bcfg != null ? bcfg.ItemSingleScoreLimit : (baseRoom == null ? 0 : baseRoom.SC_LIMIT_SING);
                            int vScLimitAll    = bcfg != null ? bcfg.ItemAllScoreLimit : (baseRoom == null ? 0 : baseRoom.SC_LIMIT_ALL);
                            string vBetScores  = bcfg != null ? (bcfg.BetScores ?? string.Empty) : (baseRoom == null ? string.Empty : (baseRoom.BetScores ?? string.Empty));
                            Dictionary<string, int> betPayout = new Dictionary<string, int>();
                            foreach (CardPayoutRowDto p in bpr)
                            {
                                betPayout["p" + p.HandType] = p.ProbabilityBasis;
                                betPayout["m" + p.HandType] = p.PayoutMultiplier;
                            }
                            rows.Add(new
                            {
                                id = tableIdFull,
                                num = baseRoom == null ? 1 : baseRoom.NUM,
                                tableName = string.IsNullOrWhiteSpace(cfg.TableName) ? ("桌台" + bidx) : cfg.TableName,
                                minBet = cfg.BetMin,
                                maxBet = cfg.BetMax,
                                exCoin = baseRoom == null ? 10000 : baseRoom.EX_COIN,
                                coinSc = cfg.OneCoinScore,
                                coinNeed = cfg.CoinsNeed,
                                gameMo = baseRoom == null ? 100 : baseRoom.Game_Mo,
                                maxSeats = cfg.MaxSeats <= 0 ? 6 : cfg.MaxSeats,
                                idleFireTimeoutSec = cfg.IdleFireTimeoutSec,
                                idleFireKickEnabled = cfg.IdleFireKickEnabled,
                                enabled = cfg.Enabled,
                                betTime = vBetTime,
                                betMinVice = vBetMinVice,
                                betMaxVice = vBetMaxVice,
                                betMinDraw = vBetMinDraw,
                                betMaxDraw = vBetMaxDraw,
                                bankerScNeed = vBankerScNeed,
                                scLimitSing = vScLimitSing,
                                scLimitAll = vScLimitAll,
                                betScores = vBetScores,
                                dif = m == null ? 0 : m.DIF,
                                har = m == null ? 0 : m.HAR,
                                siteType = m == null ? 0 : m.SITE_TYPE,
                                bankerDif = m == null ? 0 : m.BANKER_DIF,
                                bankerHar = m == null ? 0 : m.BANKER_HAR,
                                bankerSiteType = m == null ? 0 : m.BANKER_SITE_TYPE,
                                bankerPer = m == null ? 0 : m.BANKER_PER,
                                betPayoutOn = bpr.Any(c => c.Enabled == 1) ? 1 : 0,
                                betPayout = betPayout
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
                        // 先把 TableIndex 压实成 0..k-1：历史删除留下的空洞/重号会导致
                        // 列表位置号与真实 TableIndex 错位(删错桌、删不掉、保存出重复桌)
                        CompactFishTableIndexes(ef, gameId);
                        var cfgIdxs = ef.Database.SqlQuery<int>(
                            "SELECT TableIndex FROM roomtableconfig WHERE GAME_ID=" + gameId + " ORDER BY TableIndex").ToList();
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
                        // 鱼机难度：从 parafish 按 TableIndex 升序读取 DIF/SITE_TYPE，供前端回显真实值。
                        var cfgFishDifs = ef.Database.SqlQuery<int>(
                            "SELECT DIF FROM parafish WHERE GAME_ID=" + gameId + " ORDER BY TableIndex").ToList();
                        var cfgFishSites = ef.Database.SqlQuery<int>(
                            "SELECT SITE_TYPE FROM parafish WHERE GAME_ID=" + gameId + " ORDER BY TableIndex").ToList();
                        for (int i = 0; i < cfgNames.Count; i++)
                        {
                            rows.Add(new
                            {
                                id = gameId * 1000 + (i < cfgIdxs.Count ? cfgIdxs[i] : i),
                                num = 1,
                                tableName = string.IsNullOrWhiteSpace(cfgNames[i]) ? ("机台" + i) : cfgNames[i],
                                minBet = IsDecimalBetFish(gameId) ? (i < cfgBetMins.Count ? cfgBetMins[i] / 10m : 10m) : (i < cfgBetMins.Count ? (decimal)cfgBetMins[i] : 100m),
                                maxBet = IsDecimalBetFish(gameId) ? (i < cfgBetMaxs.Count ? cfgBetMaxs[i] / 10m : 100m) : (i < cfgBetMaxs.Count ? (decimal)cfgBetMaxs[i] : 1000m),
                                exCoin = 10000,
                                coinSc = i < cfgCoinScores.Count ? cfgCoinScores[i] : 1,
                                coinNeed = i < cfgCoinNeeds.Count ? cfgCoinNeeds[i] : 10000,
                                gameMo = 100,
                                maxSeats = 6,
                                idleFireTimeoutSec = 0,
                                idleFireKickEnabled = 1,
                                enabled = i < cfgEnableds.Count ? cfgEnableds[i] : 1,
                                fishDif = i < cfgFishDifs.Count ? cfgFishDifs[i] : 0,
                                fishSiteType = i < cfgFishSites.Count ? cfgFishSites[i] : 0
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
                            if (subType == 2)  // 水果拉霸：大转盘指向概率回显
                            {
                                for (int w = 0; w < 24; w++)
                                    row["wheelProb" + w] = GetLabaOptValue(labas, "WheelProb" + w);
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
                // 押注类(gameType==0)与鱼机(gameType==2)已在上方 early return 处理；
                // 此处仅牌机(gameType==1)走通用 RepackRoomsAfterDelete 路径。
                if (gameType == 1) { roomTbl = "ParaRoom"; machTbl = "ParaCard"; }
			else if (gameType == 3)
			{
				msg = new B_LabaGamePara().DeleteTable(tableId, tableId / 1000);
				return Json(msg);
			}

					else if (gameType == 2)

					{

						int fishGid = tableId / 1000;
						int delTableIdx = tableId % 1000;

						using (var ef2 = new GameDbContext())

						{

							ef2.Database.ExecuteSqlCommand("DELETE FROM roomtableconfig WHERE GAME_ID=" + fishGid + " AND TableIndex=" + delTableIdx);
							// 同步删除 parafish 对应行（按桌维度难度），避免留孤儿行。
							ef2.Database.ExecuteSqlCommand("DELETE FROM parafish WHERE GAME_ID=" + fishGid + " AND TableIndex=" + delTableIdx);
							// 删后把剩余 TableIndex 压实成 0..k-1，保持与游戏服桌号连续对齐
							CompactFishTableIndexes(ef2, fishGid);
							// parafish 同步压实：把剩余行重排为连续 ID(gameId*1000+0..k-1) 与 TableIndex(0..k-1)，
							// 与 roomtableconfig 保持同构，否则中心服 GetFishPara 按 ID=gameId*1000+i 读会错位。
							CompactFishParaFishIds(ef2, fishGid);
							SyncFishTableNum(ef2, fishGid);

						}

						var srv = new SConnect();
						Msg rp = srv.SendReadString(EScMsgType.RP, fishGid);
						msg.code = 1;
						msg.content = (rp != null && rp.code == 1)
							? "删除成功，服务端已即时热更新！"
							: "删除成功，但服务端热更新失败：" + (rp == null ? "服务端无响应" : rp.content);
						return Json(msg);

					}

					else if (gameType == 0)
					{
						// 押注类一房N桌删除：按桌删 roomtableconfig/parabet/cardpayoutprofile/roomtableconfig_bet，
						// 压实剩余桌台索引为 0..k-1，同步 base 行 NUM。
						// 注意：roomtableconfig_bet 由 center 写入，删除桌台时必须同步清理，
						// 否则留下孤儿行导致下次 RP 重载时 center 把残留 TableIndex 也下发给客户端。
						int betGid = tableId / 1000;
						int delIdx = tableId % 1000;
						using (var efBet = new GameDbContext())
						{
							efBet.Database.ExecuteSqlCommand("DELETE FROM roomtableconfig WHERE GAME_ID=" + betGid + " AND TableIndex=" + delIdx);
							efBet.Database.ExecuteSqlCommand("DELETE FROM parabet WHERE GAME_ID=" + betGid + " AND ID=" + (betGid * 1000 + delIdx));
							efBet.Database.ExecuteSqlCommand("DELETE FROM cardpayoutprofile WHERE GAME_ID=" + betGid + " AND TableId=" + delIdx);
							efBet.Database.ExecuteSqlCommand("DELETE FROM roomtableconfig_bet WHERE GAME_ID=" + betGid + " AND TableIndex=" + delIdx);
							// 压实 roomtableconfig.TableIndex 为 0..k-1
							CompactFishTableIndexes(efBet, betGid);
							// 压实 parabet ID 为 gameId*1000+0..k-1，与 roomtableconfig 保持同构
							CompactBetParaIds(efBet, betGid);
							// 压实 cardpayoutprofile.TableId 高位左移
							efBet.Database.ExecuteSqlCommand(
								"UPDATE cardpayoutprofile SET TableId=TableId-1 WHERE GAME_ID=" + betGid + " AND TableId>" + delIdx);
							// 压实 roomtableconfig_bet.TableIndex 高位左移(与 cardpayoutprofile 同思路)
							efBet.Database.ExecuteSqlCommand(
								"UPDATE roomtableconfig_bet SET TableIndex=TableIndex-1 WHERE GAME_ID=" + betGid + " AND TableIndex>" + delIdx);
							// 同步 base 行 NUM = 剩余桌台数
							SyncBetTableNum(efBet, betGid);
						}
						var srvBet = new SConnect();
						Msg rpBet = srvBet.SendReadString(EScMsgType.RP, betGid);
						msg.code = 1;
						msg.content = (rpBet != null && rpBet.code == 1)
							? "删除成功，服务端已即时热更新！"
							: "删除成功，但服务端热更新失败：" + (rpBet == null ? "服务端无响应" : rpBet.content);
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

                    if (subType == 2)  // 水果拉霸：大转盘 24 面板位指向概率（倍率客户端写死不可配）
                    {
                        int wheelSum = 0;
                        for (int w = 0; w < 24; w++)
                        {
                            int wp = form.Q<int>("WheelProb" + w, -1);
                            if (wp > 10000)
                            {
                                msg.content = "面板位" + w + " 指向概率不能超过 10000！";
                                return Json(msg);
                            }
                            if (wp >= 0)
                            {
                                wheelSum += wp;
                                labaList.Add(new M_GameConfigLaba { GameId = gameId, OptKey = "WheelProb" + w, OptValue = wp, TIME = DateTime.Now, Type = "Payout" });
                            }
                        }
                        if (wheelSum > 10000)
                        {
                            msg.content = "大转盘指向概率合计不能超过 10000！";
                            return Json(msg);
                        }
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
                    // 押注玩法旧字段已从页面移除：保存时沿用库内原值，不被表单缺省值清零。
                    // 一房N桌模型：专有参数存 base 行(ID=gameId*1000)，所有桌共享，故从 base 行取旧值。
                    // 首次建游戏(base 行不存在)时，这些参数用服务端 GetBetPara 同款默认值，避免全 0。
                    M_ParaBetRoom oldRoom = null;
                    using (var efOld = new GameDbContext())
                    {
                        oldRoom = efOld.ParaBetRooms.FirstOrDefault(c => c.ID == gameId * 1000);
                    }

                    M_ParaBetRoom room = new M_ParaBetRoom();
                    room.ID = tableId;
                    room.GAME_ID = gameId;
                    room.BET_TIME = 10;
                    room.NUM = num;
                    room.BET_MIN = betMin;
                    room.BET_MAX = betMax;
                    room.BET_MIN_VICE = oldRoom == null ? 10 : oldRoom.BET_MIN_VICE;
                    room.BET_MAX_VICE = oldRoom == null ? 1000 : oldRoom.BET_MAX_VICE;
                    room.BET_MIN_DRAW = oldRoom == null ? 10 : oldRoom.BET_MIN_DRAW;
                    room.BET_MAX_DRAW = oldRoom == null ? 1000 : oldRoom.BET_MAX_DRAW;
                    room.EX_COIN = exCoin;
                    room.COIN_SC = coinSc;
                    room.COIN_NEED = coinNeed;
                    room.BANKER_SC_NEED = oldRoom == null ? 500000 : oldRoom.BANKER_SC_NEED;
                    room.SC_LIMIT_SING = oldRoom == null ? 3000 : oldRoom.SC_LIMIT_SING;
                    room.SC_LIMIT_ALL = oldRoom == null ? 10000 : oldRoom.SC_LIMIT_ALL;
                    room.Game_Mo = gameMo;
                    room.BetScores = (form.Q<string>("BetScores", string.Empty) ?? string.Empty).Trim();
                    if (string.IsNullOrEmpty(room.BetScores)) room.BetScores = oldRoom != null && !string.IsNullOrEmpty(oldRoom.BetScores) ? oldRoom.BetScores : "1,5,10,15,20";
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

                    // 押注赔率（每门：出现率万分比 + 倍数），复用 cardpayoutprofile：
                    // HandType=门索引，PayoutMultiplier=倍率x10，ProbabilityBasis=出现率(万分比)
                    int betItemCount = GetBetItemCount(gameId);
                    if (betItemCount > 0)
                    {
                        int betPayoutOn = form.Q<int>("BetPayoutOn", 0) == 1 ? 1 : 0;
                        List<int[]> betProfiles = new List<int[]>();
                        int betProbSum = 0;
                        for (int bi = 0; bi < betItemCount; bi++)
                        {
                            int prob = (int)Math.Round(form.Q<decimal>("bp" + bi, 0m), MidpointRounding.AwayFromZero);
                            decimal multD = form.Q<decimal>("bm" + bi, 0m);
                            int mult = (int)Math.Round(multD * 10m, MidpointRounding.AwayFromZero);
                            if (prob < 0 || prob > 10000 || mult < 0)
                            {
                                msg.content = "押注门出现率须在 0-10000（万分比）之间且倍数不能为负！";
                                return Json(msg);
                            }
                            betProbSum += prob;
                            betProfiles.Add(new[] { bi, prob, mult });
                        }
                        if (betPayoutOn == 1 && betProbSum > 10000)
                        {
                            msg.content = "押注门出现率合计 " + betProbSum + " 超过 10000（万分比），请调低后再保存！";
                            return Json(msg);
                        }

                        int tIdxBet = tableId % 1000;
                        using (var efP = new GameDbContext())
                        {
                            using (var txP = efP.Database.BeginTransaction())
                            {
                                try
                                {
                                    efP.Database.ExecuteSqlCommand(
                                        "DELETE FROM cardpayoutprofile WHERE GAME_ID={0} AND TableId={1}", gameId, tIdxBet);
                                    foreach (int[] p in betProfiles)
                                    {
                                        efP.Database.ExecuteSqlCommand(
                                            "INSERT INTO cardpayoutprofile (GAME_ID, TableId, HandType, PayoutMultiplier, ProbabilityBasis, StockLimit, StockRemain, Enabled) VALUES ({0},{1},{2},{3},{4},0,0,{5})",
                                            gameId, tIdxBet, p[0], p[2], p[1], betPayoutOn);
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
                    }

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
                    // 鱼机难度（机台设定）：0-9级（满放水~大吃分）；HAR 复用 DIF 值；场地类型 0-3。
                    int fishDif = form.Q<int>("FishDIF", 6);
                    int fishSiteType = form.Q<int>("FishSITE_TYPE", 1);
                    int tableIdFull = gameId * 1000 + tIdx;
                    using (var ef = new GameDbContext())
                    {
                        ef.Database.ExecuteSqlCommand(
                            "DELETE FROM roomtableconfig WHERE GAME_ID=" + gameId + " AND TableIndex=" + tIdx);
                        int rtBetMinSave = betMin;
                        int rtBetMaxSave = betMax;
                        if (IsDecimalBetFish(gameId)) // fish servers: internal unit = 0.1 credit
                        {
                            rtBetMinSave = (int)Math.Round(minBetDisplay * 10m, MidpointRounding.AwayFromZero);
                            rtBetMaxSave = (int)Math.Round(maxBetDisplay * 10m, MidpointRounding.AwayFromZero);
                        }
                        ef.Database.ExecuteSqlCommand(
                            "INSERT INTO roomtableconfig (GAME_ID, RoomIndex, TableIndex, TableName, Enabled, OneCoinScore, BetMin, BetMax, CoinsNeed, IdleFireTimeoutSec, IdleFireKickEnabled, MaxSeats) VALUES (" +
                            gameId + ",0," + tIdx + ",'" + tName.Replace("'", "''") + "'," + tblEnabled + "," + coinSc + "," + rtBetMinSave + "," + rtBetMaxSave + "," + coinNeed + "," + idleSec + "," + tblIdleKick + "," + tblMaxSeats + ")");
                        // 同步写 parafish（按桌维度难度）：DIF/HAR/SITE_TYPE 落库，供中心服 GetFishPara 读取后下发 tablePara 块。
                        // HAR 复用 DIF（鱼机历史数据 HAR 基本等于 DIF，前端仅暴露 FishDIF 一个控件）。
                        ef.Database.ExecuteSqlCommand(
                            "DELETE FROM parafish WHERE ID=" + tableIdFull);
                        ef.Database.ExecuteSqlCommand(
                            "INSERT INTO parafish (ID,GAME_ID,TableIndex,TableName,DIF,HAR,SITE_TYPE) VALUES (" +
                            tableIdFull + "," + gameId + "," + tIdx + ",'" + tName.Replace("'", "''") + "'," + fishDif + "," + fishDif + "," + fishSiteType + ")");
                        if (IsDecimalBetFish(gameId))
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
                        // 同步 pararoom.NUM = roomtableconfig 条数，保证旧房间参数口径与新按桌配置一致
                        SyncFishTableNum(ef, gameId);
                    }
                    var srv = new SConnect();
                    msg = srv.SendReadString(EScMsgType.RP, gameId);
                    if (msg.code == 1)
                    {
                        var srvTc = new SConnect();
                        srvTc.SendTcCommand((ushort)gameId, 0, (ushort)tIdx, tName, (byte)(tblEnabled != 0 ? 1 : 0), (uint)idleSec, (byte)(tblIdleKick != 0 ? 1 : 0), (ushort)tblMaxSeats);
                        // 鱼机难度热更：PA + gameID(2位) + tableIndex(3位) + DIF + SITE_TYPE。
                        // 中心服 PA 分支调 SetTablePara 下发 COM_TABLE_SET 给子游戏实时生效（AlgPlayerReset_DIF），
                        // 同时 SetTablePara 鱼机分支会调 UpsertFishTablePara 落库，保证 RP 全量重载与重启后一致。
                        try
                        {
                            var srvPa = new SConnect();
                            srvPa.SendReadString(EScMsgType.PA,
                                gameId.ToString().PadLeft(2, '0'),
                                tIdx.ToString().PadLeft(3, '0'),
                                fishDif, fishSiteType);
                        }
                        catch (Exception exPa)
                        {
                            LogHelper.WriteLog(typeof(GameConfigController), exPa);
                        }
                    }
                    // 回显本次落库的按桌关键值，便于核对表单提交与库中数据是否一致
                    msg.content = (msg.content ?? "") + " [桌" + tIdx + " 已写入: CoinsNeed=" + coinNeed + ", BetMin=" + betMin + ", BetMax=" + betMax + ", CoinSc=" + coinSc + ", FishDif=" + fishDif + ", FishSite=" + fishSiteType + "]";
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

        // 0.1 分炮鱼机（内部单位 = 0.1 分）：金蟾试点已推广到全部鱼机
        private static readonly int[] DecimalBetFishGameIds = { 3, 6, 13, 19, 21, 22, 32, 33, 42, 49, 51 };
        private static bool IsDecimalBetFish(int gameId)
        {
            return System.Array.IndexOf(DecimalBetFishGameIds, gameId) >= 0;
        }

        // 押注类各游戏投注门数：2=彩金单挑(5) 10=幸运六狮(12) 29=金鲨银鲨(8) 47=奔驰宝马(8)
        private static int GetBetItemCount(int gameId)
        {
            switch (gameId)
            {
                case 2: return 5;
                case 10: return 12;
                case 29: return 8;
                case 47: return 8;
                default: return 0;
            }
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

        /// <summary>
        /// 同步鱼机 pararoom.NUM = roomtableconfig 条数，保证旧房间参数与新按桌配置口径一致。
        /// 鱼机按桌配置以 roomtableconfig 为准，但服务端 AA01 头部 roomInfo[].num 仍读 pararoom.NUM，
        /// 必须同步使两者统一。
        /// </summary>
        /// <summary>
        /// 把鱼机 roomtableconfig 的 TableIndex 重编号为 0..k-1(按 TableIndex,ID 升序)。
        /// 逐行向下搞移，不会与未处理行冲突，重号行也能被分配到独立号。
        /// </summary>
        private static void CompactFishTableIndexes(GameDbContext ef, int gameId)
        {
            try
            {
                var rowIds = ef.Database.SqlQuery<int>(
                    "SELECT ID FROM roomtableconfig WHERE GAME_ID=" + gameId + " ORDER BY TableIndex, ID").ToList();
                for (int i = 0; i < rowIds.Count; i++)
                {
                    ef.Database.ExecuteSqlCommand(
                        "UPDATE roomtableconfig SET TableIndex={0} WHERE ID={1} AND TableIndex<>{0}", i, rowIds[i]);
                }
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(GameConfigController), ex);
            }
        }

        /// <summary>
        /// 删除鱼机桌台后，把 parafish 剩余行重排为连续 ID(gameId*1000+0..k-1) 与 TableIndex(0..k-1)，
        /// 与 roomtableconfig(经 CompactFishTableIndexes 压实后) 保持同构。
        /// 否则中心服 GetFishPara 按 ID=gameId*1000+i 逐桌读 parafish 会与 roomtableconfig 错位。
        /// 采用“负数临时 id”两段式重排，彻底避免主键碰撞（与 RepackRoomsAfterDelete 同思路）。
        /// </summary>
        private static void CompactFishParaFishIds(GameDbContext ef, int gameId)
        {
            try
            {
                int baseId = gameId * 1000;
                // 按 TableIndex 升序取剩余行（删除后剩余的，TableIndex 可能已不连续）
                var ids = ef.Database.SqlQuery<int>(
                    "SELECT ID FROM parafish WHERE GAME_ID=" + gameId + " ORDER BY TableIndex, ID").ToList();
                int k = ids.Count;
                // 第一段：移到唯一负数临时 id，腾空正数目标区间
                for (int i = 0; i < k; i++)
                {
                    int tmp = -(baseId + i + 1);
                    ef.Database.ExecuteSqlCommand("UPDATE parafish SET ID={0} WHERE ID={1}", tmp, ids[i]);
                }
                // 第二段：回填为连续正数 id，同步 TableIndex
                for (int i = 0; i < k; i++)
                {
                    int tmp = -(baseId + i + 1);
                    int dst = baseId + i;
                    ef.Database.ExecuteSqlCommand(
                        "UPDATE parafish SET ID={0}, TableIndex={1} WHERE ID={2}", dst, i, tmp);
                }
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(GameConfigController), ex);
            }
        }

        private static void SyncFishTableNum(GameDbContext ef, int gameId)
        {
            try
            {
                int cfgCount = ef.Database.SqlQuery<int>(
                    "SELECT COUNT(*) FROM roomtableconfig WHERE GAME_ID=" + gameId).FirstOrDefault();
                if (cfgCount <= 0) return;
                ef.Database.ExecuteSqlCommand(
                    "UPDATE ParaRoom SET NUM=" + cfgCount + " WHERE GAME_ID=" + gameId + " AND ID=" + (gameId * 1000));
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(GameConfigController), ex);
            }
        }

        /// <summary>
        /// 删除押注类桌台后，把 parabet 剩余行重排为连续 ID(gameId*1000+0..k-1)，
        /// 与 roomtableconfig(经 CompactFishTableIndexes 压实后) 保持同构。
        /// 否则中心服 GetBetPara 按 ID=gameId*1000+i 逐桌读 parabet 会与 roomtableconfig 错位。
        /// 采用"负数临时 id"两段式重排，彻底避免主键碰撞（与 CompactFishParaFishIds 同思路）。
        /// </summary>
        private static void CompactBetParaIds(GameDbContext ef, int gameId)
        {
            try
            {
                int baseId = gameId * 1000;
                // 按 ID 升序取剩余行（删除后剩余的，ID 可能已不连续）
                var ids = ef.Database.SqlQuery<int>(
                    "SELECT ID FROM parabet WHERE GAME_ID=" + gameId + " ORDER BY ID").ToList();
                int k = ids.Count;
                // 第一段：移到唯一负数临时 id，腾空正数目标区间
                for (int i = 0; i < k; i++)
                {
                    int tmp = -(baseId + i + 1);
                    ef.Database.ExecuteSqlCommand("UPDATE parabet SET ID={0} WHERE ID={1}", tmp, ids[i]);
                }
                // 第二段：回填为连续正数 id
                for (int i = 0; i < k; i++)
                {
                    int tmp = -(baseId + i + 1);
                    int dst = baseId + i;
                    ef.Database.ExecuteSqlCommand(
                        "UPDATE parabet SET ID={0} WHERE ID={1}", dst, tmp);
                }
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(GameConfigController), ex);
            }
        }

        /// <summary>
        /// 同步押注类 parabetroom base 行 NUM = roomtableconfig 条数(桌台数)。
        /// 一房N桌模型下，服务端 GetBetPara 读 1 个房间、tableMax=NUM、按 N 桌循环读 parabet。
        /// </summary>
        private static void SyncBetTableNum(GameDbContext ef, int gameId)
        {
            try
            {
                int cfgCount = ef.Database.SqlQuery<int>(
                    "SELECT COUNT(*) FROM roomtableconfig WHERE GAME_ID=" + gameId).FirstOrDefault();
                if (cfgCount <= 0) cfgCount = 0;
                ef.Database.ExecuteSqlCommand(
                    "UPDATE ParaBetRoom SET NUM=" + cfgCount + " WHERE GAME_ID=" + gameId + " AND ID=" + (gameId * 1000));
                // ROOM_MAX 恒为 1（一房N桌）
                int affected = ef.Database.ExecuteSqlCommand("UPDATE ParaGame SET ROOM_MAX=1 WHERE ID=" + gameId);
                if (affected == 0)
                    ef.Database.ExecuteSqlCommand("INSERT INTO ParaGame(ID,ROOM_MAX,PLY_MAX) VALUES(" + gameId + ",1,1000)");
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
			{
				// 一房N桌：押注类桌台索引从 roomtableconfig 取 MAX(TableIndex)+1，与鱼机同思路
				var betMax = ef.Database.SqlQuery<int?>("SELECT MAX(TableIndex) FROM roomtableconfig WHERE GAME_ID=" + gameId).FirstOrDefault() ?? -1;
				return baseId + betMax + 1;
			}

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

        // roomtableconfig 押注类桌台行映射（原生 SQL 查询用）
        public class BetTableCfgRow
        {
            public int TableIndex { get; set; }
            public string TableName { get; set; }
            public int Enabled { get; set; }
            public int BetMin { get; set; }
            public int BetMax { get; set; }
            public int CoinsNeed { get; set; }
            public int OneCoinScore { get; set; }
            public int MaxSeats { get; set; }
            public int IdleFireTimeoutSec { get; set; }
            public int IdleFireKickEnabled { get; set; }
        }

        // roomtableconfig_bet 押注类桌台押注参数行映射（原生 SQL 查询用）
        public class BetTableCfgBetRow
        {
            public int TableIndex { get; set; }
            public int BetTime { get; set; }
            public int BetMin { get; set; }
            public int BetMax { get; set; }
            public int BankerScoreNeed { get; set; }
            public int ItemSingleScoreLimit { get; set; }
            public int ItemAllScoreLimit { get; set; }
            public int CoinsNeed { get; set; }
            public int OneCoinScore { get; set; }
            public string BetScores { get; set; }
            public int DefaultBetIndex { get; set; }
            public int BetMinVice { get; set; }
            public int BetMaxVice { get; set; }
            public int BetMinDraw { get; set; }
            public int BetMaxDraw { get; set; }
        }

}
}
