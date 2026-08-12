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
                        // 按桌读取 betgamecfg（开奖权重与奖励等玩法扩展配置 JSON）
                        var betGameCfgRows = ef.Database.SqlQuery<BetGameCfgRow>(
                            "SELECT TableIndex, CfgJson FROM betgamecfg WHERE GAME_ID={0} ORDER BY TableIndex", gameId).ToList();
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
                                betPayout = betPayout,
                                betGameCfg = betGameCfgRows.FirstOrDefault(c => c.TableIndex == btIdx)?.CfgJson ?? string.Empty
                            });
                        }
                    }
                    else if (gameType == 1)
                    {
                        // 牌机一房N桌：桌台列表以 roomtableconfig 为准(按桌)，牌机专属参数从 roomtableconfig_card 取，
                        // 共享参数(ExCoin/GameMo/ScoreSwitch)从 pararoom base 行取，难度从 paracard 按 ID=gameId*1000+TableIndex 关联，
                        // 赔率从 cardpayoutprofile 按 TableId 关联。
                        M_ParaRoom baseRoom = ef.ParaRoom.FirstOrDefault(c => c.GAME_ID == gameId);
                        // 房间级入场金币(未配置桌的兜底值)：取 pararoom base 行 COIN_NEED，供表单"房间入场金币"框回显
                        int roomCoinNeed = baseRoom == null ? 0 : baseRoom.COIN_NEED;
                        List<M_ParaCard> cards = ef.ParaCards
                            .Where(c => c.GAME_ID == gameId)
                            .ToList();
                        List<CardPayoutRowDto> payoutRows = ef.Database.SqlQuery<CardPayoutRowDto>(
                            "SELECT TableId, HandType, PayoutMultiplier, ProbabilityBasis, Enabled FROM cardpayoutprofile WHERE GAME_ID={0}", gameId).ToList();
                        List<CardTableCfgRow> cfgRows = ef.Database.SqlQuery<CardTableCfgRow>(
                            "SELECT TableIndex, TableName, Enabled, BetMin, BetMax, CoinsNeed, OneCoinScore, MaxSeats, IdleFireTimeoutSec, IdleFireKickEnabled, MinBetUnits FROM roomtableconfig WHERE GAME_ID={0} ORDER BY TableIndex", gameId).ToList();
                        List<CardTableCfgCardRow> cardCfgRows = ef.Database.SqlQuery<CardTableCfgCardRow>(
                            "SELECT TableIndex, ExCoin, ScoreSwitch, GameMo, MaxBetUnits FROM roomtableconfig_card WHERE GAME_ID={0} ORDER BY TableIndex", gameId).ToList();
                        int idx = 0;
                        foreach (CardTableCfgRow cfg in cfgRows)
                        {
                            idx++;
                            int tIdx = cfg.TableIndex;
                            int tableIdFull = gameId * 1000 + tIdx;
                            M_ParaCard m = cards.FirstOrDefault(c => c.ID == tableIdFull);
                            List<CardPayoutRowDto> pr = payoutRows.Where(c => c.TableId == tIdx).ToList();
                            CardTableCfgCardRow cardCfg = cardCfgRows.FirstOrDefault(c => c.TableIndex == tIdx);
                            Dictionary<string, int> payout = new Dictionary<string, int>();
                            // 鬼牌三段概率哨兵行：HandType 201/202/203 = 1/2/3 王万分比(ProbabilityBasis)
                            int jokerOn = 0, jk1 = 0, jk2 = 0, jk3 = 0;
                            foreach (CardPayoutRowDto p in pr)
                            {
                                if (p.HandType >= 201 && p.HandType <= 203)
                                {
                                    if (p.HandType == 201) jk1 = p.ProbabilityBasis;
                                    else if (p.HandType == 202) jk2 = p.ProbabilityBasis;
                                    else jk3 = p.ProbabilityBasis;
                                    if (p.Enabled == 1) jokerOn = 1;
                                    continue;
                                }
                                payout["p" + p.HandType] = p.ProbabilityBasis;
                                payout["e" + p.HandType] = p.Enabled;
                            }
                            int cardMaxBetUnits = cardCfg != null ? cardCfg.MaxBetUnits : 0;
                            rows.Add(new
                            {
                                id = tableIdFull,
                                num = baseRoom == null ? 1 : baseRoom.NUM,
                                tableName = string.IsNullOrWhiteSpace(cfg.TableName) ? ("桌台" + idx) : cfg.TableName,
                                minBet = cfg.MinBetUnits > 0 ? cfg.MinBetUnits / 10m : cfg.BetMin,
                                maxBet = cardMaxBetUnits > 0 ? cardMaxBetUnits / 10m : cfg.BetMax,
                                exCoin = cardCfg != null ? cardCfg.ExCoin : (baseRoom == null ? 10000 : baseRoom.EX_COIN),
                                coinSc = cfg.OneCoinScore,
                                coinNeed = cfg.CoinsNeed,
                                roomCoinNeed = roomCoinNeed,
                                gameMo = cardCfg != null ? cardCfg.GameMo : (baseRoom == null ? 0 : baseRoom.Game_Mo),
                                scoreSwitch = cardCfg != null ? cardCfg.ScoreSwitch : (baseRoom == null ? 0 : baseRoom.scoreSwitch),
                                maxSeats = cfg.MaxSeats <= 0 ? 6 : cfg.MaxSeats,
                                idleFireTimeoutSec = cfg.IdleFireTimeoutSec,
                                idleFireKickEnabled = cfg.IdleFireKickEnabled,
                                enabled = cfg.Enabled,
                                cardDif = m == null ? string.Empty : (m.DIF ?? string.Empty),
                                hypeType = m == null ? 0 : m.HYPE_TYPE,
                                payoutOn = pr.Any(c => c.HandType < 100 && c.Enabled == 1) ? 1 : 0,
                                payout = payout,
                                jokerOn = jokerOn,
                                jk1 = jk1,
                                jk2 = jk2,
                                jk3 = jk3
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
                        // 按桌加炮幅度(roomtableconfig.GunPowerStep 存显示值×10，0=未配置回退房间)，
                        // 一房多桌：每张桌独立读取，与服务端 GetRoomTableConfigs 逐行口径一致。
                        var cfgGunSteps = ef.Database.SqlQuery<int>(
                            "SELECT IFNULL(GunPowerStep,0) FROM roomtableconfig WHERE GAME_ID=" + gameId + " ORDER BY TableIndex").ToList();
                        // 房间加炮幅度(pararoom.scoreSwitch 存显示值×10)：仅当某桌 GunPowerStep=0(未配置)时兜底回显；
                        // 用 SqlQuery 直读标量：EF 实体映射 pararoom 会因 Game_Mo 等 NULL 列抛异常
                        int fishScoreSwRaw = ef.Database.SqlQuery<int>(
                            "SELECT IFNULL(scoreSwitch,0) FROM pararoom WHERE GAME_ID=" + gameId + " LIMIT 1").FirstOrDefault();
                        decimal fishScoreSwitch = fishScoreSwRaw <= 0 ? 0.1m : fishScoreSwRaw / 10m;
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
                                fishSiteType = i < cfgFishSites.Count ? cfgFishSites[i] : 0,
                                scoreSwitch = (i < cfgGunSteps.Count && cfgGunSteps[i] > 0) ? cfgGunSteps[i] / 10m : fishScoreSwitch
                            });
                        }
                    }
                    else  // gameType == 3 拉霸
                    {
                        int subType = GetLabaSubType(gameId);
                        string gameName = ef.Games.Where(c => c.GameId == gameId).Select(c => c.Name).FirstOrDefault() ?? ("游戏" + gameId);
                        // 明星97(GameId=16) RTP/Combo 配置为游戏级（存 TableIndex=0），
                        // 先一次性读入，供每桌行回显（服务端 GetGameConfigParams 按 GameId 全量合并）。
                        Dictionary<string, int> mx97Rtp = null;
                        if (subType == 1)
                        {
                            mx97Rtp = ef.GameConfigLabas
                                .Where(c => c.GameId == gameId && (c.OptKey.StartsWith("Rtp") || c.OptKey.StartsWith("Combo")))
                                .AsEnumerable()
                                .GroupBy(c => c.OptKey)
                                .ToDictionary(g => g.Key, g => g.First().OptValue);
                        }
                        // 从 roomtableconfig 获取桌台列表（对齐一房N桌模型）
                        var tableIdxs = ef.Database.SqlQuery<int>(
                            "SELECT TableIndex FROM roomtableconfig WHERE GAME_ID=" + gameId + " ORDER BY TableIndex").ToList();
                        if (tableIdxs.Count == 0) tableIdxs.Add(0);
                        foreach (int tIdx in tableIdxs)
                        {
                            int tid = gameId * 1000 + tIdx;
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

                            // 优先从 paralaba 读取，降级到 gameconfiglaba（兼容迁移中数据）
                            var labaPara = ef.Database.SqlQuery<M_ParaLaba>(
                                "SELECT * FROM paralaba WHERE GAME_ID={0} AND TableIndex={1} LIMIT 1", gameId, tIdx).FirstOrDefault();
                            if (labaPara != null)
                            {
                                row["dif"] = labaPara.DIF;
                                row["har"] = labaPara.HAR;
                                int symMax = subType == 2 ? 7 : (subType == 1 || subType == 3 ? 8 : -1);
                                for (int p = 0; p <= symMax; p++)
                                {
                                    row["payout" + p] = GetLabaParaField(labaPara, "Payout" + p);
                                    row["prob" + p] = GetLabaParaField(labaPara, "Prob" + p);
                                }
                                if (subType == 2)
                                {
                                    for (int w = 0; w < 24; w++)
                                        row["wheelProb" + w] = GetLabaParaField(labaPara, "WheelProb" + w);
                                }
                                row["minBet"] = labaPara.BetMin > 0 ? (object)(labaPara.BetMin / 10m) : 0m;
                                row["maxBet"] = labaPara.BetMax > 0 ? (object)(labaPara.BetMax / 10m) : 0m;
                                row["coinNeed"] = labaPara.CoinsNeed;
                                row["defaultBetIndex"] = labaPara.DefaultBetIndex;
                                row["exCoin"] = labaPara.ExCoin > 0 ? labaPara.ExCoin : 1;
                                row["coinSc"] = labaPara.CoinSc > 0 ? labaPara.CoinSc : 1;
                                row["gameMo"] = labaPara.GameMo > 0 ? labaPara.GameMo : 1;
                                row["scoreSwitch"] = labaPara.ScoreSwitchX10 > 0 ? labaPara.ScoreSwitchX10 / 10m : 0.1m;
                            }
                            else
                            {
                                // 降级：从 gameconfiglaba 读取（兼容迁移过渡期）
                                List<M_GameConfigLaba> labas = ef.GameConfigLabas.Where(c => c.GameId == gameId && c.TableIndex == tIdx).ToList();
                                if (subType == 3)
                                {
                                    var paraBet = ef.ParaBets.Where(c => c.GAME_ID == gameId && c.ID == tid).FirstOrDefault();
                                    row["dif"] = paraBet?.DIF ?? 0;
                                    row["har"] = paraBet?.HAR ?? 0;
                                }
                                else
                                {
                                    row["dif"] = 0;
                                    row["har"] = 0;
                                }
                                int symMax = subType == 2 ? 7 : (subType == 1 || subType == 3 ? 8 : -1);
                                for (int p = 0; p <= symMax; p++)
                                {
                                    row["payout" + p] = GetLabaOptValue(labas, "Payout" + p);
                                    row["prob" + p] = GetLabaOptValue(labas, "Prob" + p);
                                }
                                if (subType == 2)
                                {
                                    for (int w = 0; w < 24; w++)
                                        row["wheelProb" + w] = GetLabaOptValue(labas, "WheelProb" + w);
                                }
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
                            }
                            row["idleFireTimeoutSec"] = 0;

                            // 明星97：追加 RTP/Combo 配置回显（游戏级，仅 subType==1 有）
                            if (subType == 1 && mx97Rtp != null)
                                AddMx97RtpRowFields(row, mx97Rtp);

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

                // 押注类(gameType==0)与鱼机(gameType==2)已在上方 early return 处理；
                // 牌机(gameType==1)亦改为一房N桌早返回删除(对齐鱼机/押注类)。
                if (gameType == 1)
                {
                    // 牌机一房N桌删除：按桌删 roomtableconfig/roomtableconfig_card/paracard/cardpayoutprofile，
                    // 压实剩余桌台索引为 0..k-1，同步 base 行 NUM 与 ROOM_MAX。
                    int cardGid = tableId / 1000;
                    int delIdx = tableId % 1000;
                    using (var efCard = new GameDbContext())
                    {
                        efCard.Database.ExecuteSqlCommand("DELETE FROM roomtableconfig WHERE GAME_ID=" + cardGid + " AND TableIndex=" + delIdx);
                        efCard.Database.ExecuteSqlCommand("DELETE FROM roomtableconfig_card WHERE GAME_ID=" + cardGid + " AND TableIndex=" + delIdx);
                        efCard.Database.ExecuteSqlCommand("DELETE FROM paracard WHERE GAME_ID=" + cardGid + " AND ID=" + (cardGid * 1000 + delIdx));
                        efCard.Database.ExecuteSqlCommand("DELETE FROM cardpayoutprofile WHERE GAME_ID=" + cardGid + " AND TableId=" + delIdx);
                        // 压实 roomtableconfig.TableIndex 为 0..k-1
                        CompactFishTableIndexes(efCard, cardGid);
                        // 压实 roomtableconfig_card.TableIndex 高位左移(与 cardpayoutprofile 同思路)
                        efCard.Database.ExecuteSqlCommand(
                            "UPDATE roomtableconfig_card SET TableIndex=TableIndex-1 WHERE GAME_ID=" + cardGid + " AND TableIndex>" + delIdx);
                        // 压实 paracard ID 为 gameId*1000+0..k-1，与 roomtableconfig 保持同构
                        CompactCardParaIds(efCard, cardGid);
                        // 压实 cardpayoutprofile.TableId 高位左移
                        efCard.Database.ExecuteSqlCommand(
                            "UPDATE cardpayoutprofile SET TableId=TableId-1 WHERE GAME_ID=" + cardGid + " AND TableId>" + delIdx);
                        // 同步 base 行 NUM = 剩余桌台数 + ROOM_MAX=1
                        SyncCardTableNum(efCard, cardGid);
                    }
                    var srvCard = new SConnect();
                    Msg rpCard = srvCard.SendReadString(EScMsgType.RP, cardGid);
                    msg.code = 1;
                    msg.content = (rpCard != null && rpCard.code == 1)
                        ? "删除成功，服务端已即时热更新！"
                        : "删除成功，但服务端热更新失败：" + (rpCard == null ? "服务端无响应" : rpCard.content);
                    return Json(msg);
                }
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
							efBet.Database.ExecuteSqlCommand("DELETE FROM betgamecfg WHERE GAME_ID=" + betGid + " AND TableIndex=" + delIdx);
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
							// 压实 betgamecfg.TableIndex 高位左移
							efBet.Database.ExecuteSqlCommand(
								"UPDATE betgamecfg SET TableIndex=TableIndex-1 WHERE GAME_ID=" + betGid + " AND TableIndex>" + delIdx);
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
                if (tableId >= 0 && tableId / 1000 != gameId)
                {
                    msg.content = "桌台不属于当前游戏，请刷新页面后重试！";
                    return Json(msg);
                }

                if (gameType == 3)
                {
                    if (tableId < 0) tableId = AllocTableId(3, gameId);
                    int subType = GetLabaSubType(gameId);
                    string labaTableName = (form.Q<string>("TableName", string.Empty) ?? string.Empty).Trim();
                    int labaEnabled = form.Q<int>("Enabled", 1);

                    // ── 构建 gameconfiglaba 参数列表（保留写兼容）──
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

                    int[] wheelProbs = new int[24];
                    if (subType == 2)  // 水果拉霸：大转盘 24 面板位指向概率
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
                                wheelProbs[w] = wp;
                                labaList.Add(new M_GameConfigLaba { GameId = gameId, OptKey = "WheelProb" + w, OptValue = wp, TIME = DateTime.Now, Type = "Payout" });
                            }
                        }
                        if (wheelSum > 10000)
                        {
                            msg.content = "大转盘指向概率合计不能超过 10000！";
                            return Json(msg);
                        }
                    }

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

                    // ── 构建 paralaba 结构化参数（新表）──
                    int labaDif = form.Q<int>("DIF", 0);
                    int labaHar = form.Q<int>("HAR", 0);
                    M_ParaLaba labaPara = new M_ParaLaba();
                    labaPara.ID = tableId;
                    labaPara.GAME_ID = gameId;
                    labaPara.TableIndex = tableId % 1000;
                    labaPara.SubType = subType;
                    labaPara.DIF = (subType == 3) ? labaDif : 0;   // 水浒传有独立 DIF/HAR
                    labaPara.HAR = (subType == 3) ? labaHar : 0;
                    // 符号赔率
                    for (int p = 0; p <= labaSymMax; p++)
                    {
                        int pv = form.Q<int>("Payout" + p, 0);
                        typeof(M_ParaLaba).GetProperty("Payout" + p)?.SetValue(labaPara, pv);
                        int pr = form.Q<int>("Prob" + p, 0);
                        typeof(M_ParaLaba).GetProperty("Prob" + p)?.SetValue(labaPara, pr);
                    }
                    // 大转盘
                    for (int w = 0; w < 24; w++)
                        typeof(M_ParaLaba).GetProperty("WheelProb" + w)?.SetValue(labaPara, wheelProbs[w]);
                    // 押分与兑换
                    labaPara.BetMin = labaBetMinD >= 0 ? (int)Math.Round(labaBetMinD * 10m) : 1000;
                    labaPara.BetMax = labaBetMaxD >= 0 ? (int)Math.Round(labaBetMaxD * 10m) : 10000;
                    labaPara.CoinsNeed = labaCoinsNeed >= 0 ? labaCoinsNeed : 10000;
                    labaPara.ExCoin = labaExCoin > 0 ? labaExCoin : 10000;
                    labaPara.CoinSc = labaCoinSc > 0 ? labaCoinSc : 1;
                    labaPara.GameMo = labaGameMo > 0 ? labaGameMo : 100;
                    labaPara.ScoreSwitchX10 = labaScoreSw >= 0 ? (int)Math.Round(labaScoreSw * 10m) : 1;
                    labaPara.DefaultBetIndex = labaDefaultBetIdx >= 0 ? labaDefaultBetIdx : 0;

                    int rtTableIndex = tableId % 1000;
                    int rtBetMin = labaBetMinD >= 0 ? (int)Math.Round(labaBetMinD) : 100;
                    int rtBetMax = labaBetMaxD >= 0 ? (int)Math.Round(labaBetMaxD) : 10000;
                    int rtCoinsNeed = labaCoinsNeed >= 0 ? labaCoinsNeed : 0;
                    // 按桌加炮幅度×10：与 ScoreSwitchX10 同口径(拉霸表单 scoreSwitch 为显示值)
                    int rtGunStep = labaScoreSw >= 0 ? (int)Math.Round(labaScoreSw * 10m) : 1;
                    using (var efRt = new GameDbContext())
                    {
                        efRt.Database.ExecuteSqlCommand(
                            "DELETE FROM roomtableconfig WHERE GAME_ID=" + gameId + " AND RoomIndex=0 AND TableIndex=" + rtTableIndex);
                        efRt.Database.ExecuteSqlCommand(
                            "INSERT INTO roomtableconfig (GAME_ID, RoomIndex, TableIndex, TableName, Enabled, MaxSeats, OneCoinScore, BetMin, BetMax, CoinsNeed, IdleFireTimeoutSec, IdleFireKickEnabled, GunPowerStep) VALUES (" +
                            gameId + ",0," + rtTableIndex + ",'" + labaTableName.Replace("'", "''") + "'," + labaEnabled + ",6,1," +
                            rtBetMin + "," + rtBetMax + "," + rtCoinsNeed + ",0,0," + rtGunStep + ")");
                    }

                    // ── 明星97(GameId=16) RTP 控制配置：游戏级参数写 GameConfigLaba(TableIndex=0)，
                    // 留空即删除该 OptKey（服务端整包先清空再套用，缺项回内置默认）。
                    // 校验/落库失败则中断本次保存，避免桌台已存而 RTP 未生效的观感问题。
                    if (subType == 1)
                    {
                        Msg rtpMsg = SaveMx97RtpConfig(form, gameId);
                        if (rtpMsg.code != 1)
                        {
                            return Json(rtpMsg);
                        }
                    }

                    msg = new B_LabaGamePara().SaveTableFull(tableId, gameId, labaList, labaPara, labaTableName, labaEnabled);

                    // ── 明星97 保存成功后补发 PC 热更：center UpdateGameConfig → SendExtendedPara，
                    // 游戏服 ResetConfig + ApplyProfile，下一局立即生效（无需重启）。
                    if (subType == 1 && msg.code == 1)
                    {
                        try
                        {
                            var srvPc = new SConnect();
                            var pcMsg = srvPc.SendPcCommand((ushort)gameId);
                            if (pcMsg.code == 1)
                                msg.content = (msg.content ?? "") + "；RTP 配置已触发游戏服热更，下一局生效";
                            else
                                msg.content = (msg.content ?? "") + "；RTP 配置热更指令发送失败：" + pcMsg.content;
                        }
                        catch (Exception exPc)
                        {
                            LogHelper.WriteLog(typeof(GameConfigController), exPc);
                            msg.content = (msg.content ?? "") + "；RTP 配置热更指令发送异常：" + exPc.Message;
                        }
                    }
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

                // gcScoreSwitchRule: 加芬幅度禁止为 0 —— 鱼机(2) 最小 0.1, 牌机(1)/拉霸(3) 最小 1 且必须整数
                if (gameType == 2)
                {
                    if (scoreSwitch < 0.1m)
                    {
                        msg.content = "加芬幅度必须大于 0，鱼机最小 0.1!";
                        return Json(msg);
                    }
                }
                else if (gameType == 1 || gameType == 3)
                {
                    if (scoreSwitch < 1m || scoreSwitch != decimal.Truncate(scoreSwitch))
                    {
                        msg.content = "加芬幅度必须为大于等于 1 的整数!";
                        return Json(msg);
                    }
                }

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
                    // 押注玩法设置：倒计时/单门限红/全台限红/抢庄门槛（页面对应字段，缺省沿用 base 行旧值）
                    room.BET_TIME = form.Q<int>("BET_TIME", oldRoom == null ? 10 : oldRoom.BET_TIME);
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
                    room.BANKER_SC_NEED = form.Q<int>("BANKER_SC_NEED", oldRoom == null ? 500000 : oldRoom.BANKER_SC_NEED);
                    room.SC_LIMIT_SING = form.Q<int>("SC_LIMIT_SING", oldRoom == null ? 3000 : oldRoom.SC_LIMIT_SING);
                    room.SC_LIMIT_ALL = form.Q<int>("SC_LIMIT_ALL", oldRoom == null ? 10000 : oldRoom.SC_LIMIT_ALL);
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

                    // 押注类玩法扩展配置（开奖权重与奖励等 JSON，按桌）：
                    // 页面按 GAME_ID 渲染的 spec + doors 整包序列化，由 SaveTableFull 事务内 upsert 到 betgamecfg。
                    // 服务端当前使用内置倍率，doors 段仅作 RTP 核算展示与预留存储，
                    // spec 段（特殊奖励/庄闲和/彩金奖池）由服务端参数化生效。
                    // CfgJson 为 VARCHAR(16000)（Poco 1.9.1 MySQL 驱动对 LONGTEXT 提取会崩溃），长度上限 15000。
                    string betGameCfg = (form.Q<string>("BetGameCfg", string.Empty) ?? string.Empty).Trim();
                    if (betGameCfg.Length > 15000)
                    {
                        msg.content = "玩法配置内容过长，请检查后重试！";
                        return Json(msg);
                    }

                    msg = new B_BetGamePara().SaveTableFull(room, machine, betGameCfg);
                }
                else if (gameType == 1)
                {
                    // 牌机改一房N桌(对齐鱼机/押注)：
                    // - 通用桌台参数(桌名/限红/开关/坐席/踢出/兑换/带入/MinBetUnits) -> roomtableconfig
                    // - 牌机专属按桌参数(ExCoin/ScoreSwitch/GameMo/MaxBetUnits) -> roomtableconfig_card
                    // - 机台难度(DIF/HYPE_TYPE) -> paracard
                    // - 牌型赔率 -> cardpayoutprofile
                    // pararoom 仅保留 1 行 base 行(ID=gameId*1000)，num=桌总数；paragame.ROOM_MAX 恒 1。
                    int tIdx = tableId % 1000;
                    string tName = (form.Q<string>("TableName", string.Empty) ?? "").Trim();
                    int tblEnabled = form.Q<int>("Enabled", 1);
                    int idleSec = form.Q<int>("IdleFireTimeoutSec", 0);
                    int tblIdleKick = form.Q<int>("IdleFireKickEnabled", 1);
                    int tblMaxSeats = form.Q<int>("MaxSeats", 6);
                    // 牌机难度(按桌)：16 位 DIF 串 + 炒场类型，与服务端 GetCardPara 的 id=gameId*1000+i 对齐。
                    string cardDif = (form.Q<string>("CardDIF", string.Empty) ?? string.Empty).Trim();
                    cardDif = cardDif.Length == 16 ? cardDif : "0000000000000000";
                    int hypeType = form.Q<int>("HYPE_TYPE", 0);
                    int tableIdFull = gameId * 1000 + tIdx;
                    // 牌机专属按桌参数(扩展表)
                    int cardExCoin = form.Q<int>("EX_COIN", 10000);
                    if (scoreSwitch != decimal.Truncate(scoreSwitch))
                    {
                        msg.content = "牌机加芬幅度必须为整数!";
                        return Json(msg);
                    }
                    int cardScoreSwitch = (int)Math.Round(scoreSwitch, MidpointRounding.AwayFromZero);
                    if (cardScoreSwitch < 1)
                    {
                        msg.content = "牌机加芬幅度必须为大于等于 1 的整数!";
                        return Json(msg);
                    }
                    int cardGameMo = gameMo;
                    int cardMaxBetUnits = (int)Math.Round(maxBetDisplay * 10m, MidpointRounding.AwayFromZero);
                    int cardMinBetUnits = (int)Math.Round(minBetDisplay * 10m, MidpointRounding.AwayFromZero);

                    // 牌型概率(万分比)/启用：HandType 与服务端 te_CardsType 枚举(0..12)逐一对齐。
                    // 倍数以客户端 Blueeboard.cs 为唯一权威，后台既不接收也不保存。
                    // 大字板(gameId=15)五鬼已下线：不保存五鬼(12)行，与服务端 AlgProb 封死一致（DELETE 全删后不再 INSERT，DB 残留随下次保存自动清理）
                    List<int> payoutHandTypes = new List<int>();
                    for (int ht = 0; ht <= 12; ht++)
                    {
                        if (gameId == 15 && ht == 12) continue;
                        payoutHandTypes.Add(ht);
                    }
                    int payoutOn = form.Q<int>("PayoutOn", 0) == 1 ? 1 : 0;
                    List<int[]> payoutProfiles = new List<int[]>();
                    int probSum = 0;
                    foreach (int ht in payoutHandTypes)
                    {
                        int prob = (int)Math.Round(form.Q<decimal>("hp" + ht, 0m), MidpointRounding.AwayFromZero);
                        if (prob < 0 || prob > 10000)
                        {
                            msg.content = "牌型概率须在 0-10000（万分比）之间！";
                            return Json(msg);
                        }
                        // 逐牌型启用：he{ht}（缺省 1）；杂牌行始终启用
                        int rowOn = (ht == 0 || form.Q<int>("he" + ht, 1) == 1) ? 1 : 0;
                        if (ht != 0 && rowOn == 1) probSum += prob;
                        payoutProfiles.Add(new[] { ht, prob, rowOn });
                    }
                    if (payoutOn == 1 && probSum > 10000)
                    {
                        msg.content = "中奖牌型概率合计 " + probSum + " 超过 10000（万分比），请调低后再保存！";
                        return Json(msg);
                    }

                    // 鬼牌三段概率（万分比）：哨兵行 HandType 201/202/203，服务端 AlgAddJoker 可变分支消费
                    int jokerOn = form.Q<int>("JokerOn", 0) == 1 ? 1 : 0;
                    int[] jokerProbs = new int[3];
                    int jokerSum = 0;
                    for (int j = 0; j < 3; j++)
                    {
                        jokerProbs[j] = (int)Math.Round(form.Q<decimal>("jk" + (j + 1), 0m), MidpointRounding.AwayFromZero);
                        if (jokerProbs[j] < 0 || jokerProbs[j] > 10000)
                        {
                            msg.content = "鬼牌概率须在 0-10000（万分比）之间！";
                            return Json(msg);
                        }
                        jokerSum += jokerProbs[j];
                    }
                    if (jokerOn == 1 && jokerSum > 10000)
                    {
                        msg.content = "鬼牌 1/2/3 王概率合计 " + jokerSum + " 超过 10000（万分比），请调低后再保存！";
                        return Json(msg);
                    }

                    using (var ef = new GameDbContext())
                    {
                        // 牌型概率/启用(按桌)：cardpayoutprofile；PayoutMultiplier 使用数据库默认值 0，后台不写倍率。
                        using (var txP = ef.Database.BeginTransaction())
                        {
                            try
                            {
                                ef.Database.ExecuteSqlCommand(
                                    "DELETE FROM cardpayoutprofile WHERE GAME_ID={0} AND TableId={1}", gameId, tIdx);
                                foreach (int[] p in payoutProfiles)
                                {
                                    int rowEnabled = (payoutOn == 1 && p[2] == 1) ? 1 : 0;
                                    ef.Database.ExecuteSqlCommand(
                                        "INSERT INTO cardpayoutprofile (GAME_ID, TableId, HandType, ProbabilityBasis, StockLimit, StockRemain, Enabled) VALUES ({0},{1},{2},{3},0,0,{4})",
                                        gameId, tIdx, p[0], p[1], rowEnabled);
                                }
                                // 鬼牌哨兵行：201/202/203 = 1/2/3 王万分比，服务端 GetCardPayoutSnapshot 按 HandType>=CARDS_TYPE_MAX 跳过，不影响牌型赔付
                                for (int j = 0; j < 3; j++)
                                    ef.Database.ExecuteSqlCommand(
                                        "INSERT INTO cardpayoutprofile (GAME_ID, TableId, HandType, ProbabilityBasis, StockLimit, StockRemain, Enabled) VALUES ({0},{1},{2},{3},0,0,{4})",
                                        gameId, tIdx, 201 + j, jokerProbs[j], jokerOn);
                                txP.Commit();
                            }
                            catch
                            {
                                txP.Rollback();
                                throw;
                            }
                        }

                        // 通用桌台参数(按桌)：roomtableconfig，与服务端 TC 的 ApplyCardTableSnap 对齐
                        ef.Database.ExecuteSqlCommand(
                            "DELETE FROM roomtableconfig WHERE GAME_ID=" + gameId + " AND TableIndex=" + tIdx);
                        ef.Database.ExecuteSqlCommand(
                            "INSERT INTO roomtableconfig (GAME_ID, RoomIndex, TableIndex, TableName, Enabled, OneCoinScore, BetMin, BetMax, CoinsNeed, IdleFireTimeoutSec, IdleFireKickEnabled, MaxSeats, MinBetUnits, GunPowerStep) VALUES (" +
                            gameId + ",0," + tIdx + ",'" + tName.Replace("'", "''") + "'," + tblEnabled + "," + coinSc + "," + betMin + "," + betMax + "," + coinNeed + "," + idleSec + "," + tblIdleKick + "," + tblMaxSeats + "," + cardMinBetUnits + "," + (cardScoreSwitch * 10) + ")");
                        // 牌机专属按桌参数：roomtableconfig_card
                        ef.Database.ExecuteSqlCommand(
                            "DELETE FROM roomtableconfig_card WHERE GAME_ID=" + gameId + " AND TableIndex=" + tIdx);
                        ef.Database.ExecuteSqlCommand(
                            "INSERT INTO roomtableconfig_card (GAME_ID, RoomIndex, TableIndex, ExCoin, ScoreSwitch, GameMo, MaxBetUnits) VALUES (" +
                            gameId + ",0," + tIdx + "," + cardExCoin + "," + cardScoreSwitch + "," + cardGameMo + "," + cardMaxBetUnits + ")");
                        // 机台难度(按桌)：paracard，供中心服 GetCardPara 读取后下发 tablePara 块
                        ef.Database.ExecuteSqlCommand(
                            "DELETE FROM paracard WHERE ID=" + tableIdFull);
                        ef.Database.ExecuteSqlCommand(
                            "INSERT INTO paracard (ID,GAME_ID,DIF,HYPE_TYPE) VALUES (" +
                            tableIdFull + "," + gameId + ",'" + cardDif.Replace("'", "''") + "'," + hypeType + ")");
                        // 同步 pararoom base 行的共享参数(EX_COIN/COIN_SC/Game_Mo/scoreSwitch/BET_MIN/BET_MAX)，
                        // 服务端 GetCardPara 按 roomMax=1 只读 base 行(ID=gameId*1000)的这些字段，
                        // 必须与本次提交值一致，否则服务端读到的是旧值或自动补建的默认值。
                        // 注意：COIN_NEED 不再随单桌保存同步——入场金币按桌存 roomtableconfig.CoinsNeed，
                        // 0 值由服务端回退房间级兜底值；房间级兜底仅当表单显式提交 ROOM_COIN_NEED 时更新，
                        // 避免"保存某张桌导致全部桌子的入场金币变成该桌的值"。
                        int baseIdCard = gameId * 1000;
                        int affBase = ef.Database.ExecuteSqlCommand(
                            "UPDATE ParaRoom SET EX_COIN=" + cardExCoin + ",COIN_SC=" + coinSc +
                            ",Game_Mo=" + cardGameMo + ",scoreSwitch=" + cardScoreSwitch +
                            ",BET_MIN=" + betMin + ",BET_MAX=" + betMax +
                            ",MinBetUnits=" + cardMinBetUnits + ",MaxBetUnits=" + cardMaxBetUnits +
                            ",MaxSeats=" + tblMaxSeats + ",IdleFireTimeoutSec=" + idleSec +
                            ",IdleFireKickEnabled=" + (tblIdleKick != 0 ? 1 : 0) + ",Enabled=" + (tblEnabled != 0 ? 1 : 0) +
                            ",TableName='" + tName.Replace("'", "''") + "' WHERE GAME_ID=" + gameId + " AND ID=" + baseIdCard);
                        // 房间级入场金币(未配置桌的兜底值)：仅显式提交 ROOM_COIN_NEED 时更新，
                        // base 行不存在(首张桌台)时由 SyncCardTableNum 自动 INSERT(COIN_NEED 默认 10000)
                        int roomCoinNeed = form.Q<int>("ROOM_COIN_NEED", -1);
                        if (roomCoinNeed >= 0)
                        {
                            ef.Database.ExecuteSqlCommand(
                                "UPDATE ParaRoom SET COIN_NEED=" + roomCoinNeed +
                                " WHERE GAME_ID=" + gameId + " AND ID=" + baseIdCard);
                        }
                        if (affBase == 0)
                        {
                            // base 行不存在(首张桌台)时由 SyncCardTableNum 自动 INSERT，此处无需重复
                        }
                        // 同步 pararoom base 行 num=桌总数 + paragame.ROOM_MAX=1(一房N桌)
                        SyncCardTableNum(ef, gameId);
                    }
                    // 热更：RP(重载) + TC(桌台配置) + PA(机台难度)
                    var srv = new SConnect();
                    msg = srv.SendReadString(EScMsgType.RP, gameId);
                    if (msg.code == 1)
                    {
                        var srvTc = new SConnect();
                        srvTc.SendTcCommand((ushort)gameId, 0, (ushort)tIdx, tName, (byte)(tblEnabled != 0 ? 1 : 0), (uint)idleSec, (byte)(tblIdleKick != 0 ? 1 : 0), (ushort)tblMaxSeats);
                        // 牌机难度热更：PA + gameID(2位) + tableIndex(3位) + DIF(16位串) + HYPE_TYPE。
                        // 中心服 SetTablePara 逐字符转字节下发 COM_TABLE_SET，子游戏服 AlgDifSet 即时生效。
                        try
                        {
                            var srvPa = new SConnect();
                            srvPa.SendReadString(EScMsgType.PA,
                                gameId.ToString().PadLeft(2, '0'),
                                tIdx.ToString().PadLeft(3, '0'),
                                cardDif,
                                hypeType);
                        }
                        catch (Exception exPa)
                        {
                            LogHelper.WriteLog(typeof(GameConfigController), exPa);
                        }
                    }
                    // 写库成功即标记已落库：即使 RP/TC/PA 热更管道失败也刷新前端列表，
                    // 避免"DB 已写、Web 列表不刷新"（对齐 B_SuperPara.PushHotUpdate 的 datas=true 约定）。
                    msg.datas = true;
                    // 回显本次落库的按桌关键值，便于核对表单提交与库中数据是否一致
                    msg.content = (msg.content ?? "") + " [桌" + tIdx + " 已写入: BetMin=" + betMin + ", BetMax=" + betMax + ", CoinSc=" + coinSc + ", CoinNeed=" + coinNeed + ", CardDif=" + cardDif + ", HypeType=" + hypeType + "]";
                }
                else
                {
                    int tIdx = tableId % 1000;
                    string tName = (form.Q<string>("TableName", string.Empty) ?? "").Trim();
                    int tblEnabled = form.Q<int>("Enabled", 1);
                    int idleSec = form.Q<int>("IdleFireTimeoutSec", 0);
                    int tblIdleKick = form.Q<int>("IdleFireKickEnabled", 1);
                    int tblMaxSeats = form.Q<int>("MaxSeats", 6);
                    // 鱼机难度（机台设定）：0-9级，对应可击杀倍率上限 {0=不限,1=1000,2=300,3=200,4=100,5=40,6=30,7=25,8=20,9=18}；
                    // 概率固定为小放水档N=3（小鱼10%/中鱼1.67%/Boss0.33%），难度仅控制倍率上限。HAR 复用 DIF 值；场地类型 0-3。
                    int fishDif = form.Q<int>("FishDIF", 0);
                    int fishSiteType = form.Q<int>("FishSITE_TYPE", 1);
	                    int tableIdFull = gameId * 1000 + tIdx;
	                    int rtBetMinSave = betMin, rtBetMaxSave = betMax; // 提至 using 外，供后续 TC tableExt 使用
	                    // 按桌加炮幅度×10(提至 using 外，供保存回显)：表单 scoreSwitch 为显示值(鱼机≥0.1)，客户端 GunPowerStep 同口径(0=未配置回退房间)
	                    int rtGunStep = (int)Math.Round(scoreSwitch * 10m, MidpointRounding.AwayFromZero);
	                    using (var ef = new GameDbContext())
	                    {
		                        ef.Database.ExecuteSqlCommand(
		                            "DELETE FROM roomtableconfig WHERE GAME_ID=" + gameId + " AND TableIndex=" + tIdx);
		                        if (IsDecimalBetFish(gameId)) // fish servers: internal unit = 0.1 credit
		                        {
		                            rtBetMinSave = (int)Math.Round(minBetDisplay * 10m, MidpointRounding.AwayFromZero);
		                            rtBetMaxSave = (int)Math.Round(maxBetDisplay * 10m, MidpointRounding.AwayFromZero);
		                        }
		                        // 按桌加炮幅度×10：表单 scoreSwitch 为显示值(鱼机≥0.1)，客户端 GunPowerStep 同口径(0=未配置回退房间)
		                        ef.Database.ExecuteSqlCommand(
	                            "INSERT INTO roomtableconfig (GAME_ID, RoomIndex, TableIndex, TableName, Enabled, OneCoinScore, BetMin, BetMax, CoinsNeed, IdleFireTimeoutSec, IdleFireKickEnabled, MaxSeats, GunPowerStep) VALUES (" +
	                            gameId + ",0," + tIdx + ",'" + tName.Replace("'", "''") + "'," + tblEnabled + "," + coinSc + "," + rtBetMinSave + "," + rtBetMaxSave + "," + coinNeed + "," + idleSec + "," + tblIdleKick + "," + tblMaxSeats + "," + rtGunStep + ")");
                        // 同步写 parafish（按桌维度难度）：DIF/HAR/SITE_TYPE 落库，供中心服 GetFishPara 读取后下发 tablePara 块。
                        // HAR 复用 DIF（鱼机历史数据 HAR 基本等于 DIF，前端仅暴露 FishDIF 一个控件）。
                        ef.Database.ExecuteSqlCommand(
                            "DELETE FROM parafish WHERE ID=" + tableIdFull);
                        ef.Database.ExecuteSqlCommand(
                            "INSERT INTO parafish (ID,GAME_ID,TableIndex,TableName,DIF,HAR,SITE_TYPE) VALUES (" +
                            tableIdFull + "," + gameId + "," + tIdx + ",'" + tName.Replace("'", "''") + "'," + fishDif + "," + fishDif + "," + fishSiteType + ")");
                        // 一房N桌模型：服务端 GetFishPara 按 roomMax=1 只读 base 行(ID=gameId*1000)，
                        // 房间级公共参数(底注/兑换/入场)必须同步 base 行，否则新建/编辑桌台后
                        // 子游戏收到的房间底注仍是旧值(如内部 2-1000 而非 10-1000)，需重启才刷新。
                        // decimal 鱼机存 Units(显示值×10)，非 decimal 鱼机存原始 BET_MIN/BET_MAX。
                        try
                        {
                            // 兼容旧多房间模型：按桌行(存在时)仍写一份
                            // 注意：单桌保存不再写 pararoom.scoreSwitch——一房多桌下它是房间级兜底值，
                            // 若随某张桌一起改，会导致未配置(GunPowerStep=0)的桌回退值被这张桌污染。
                            if (IsDecimalBetFish(gameId))
                            {
                                ef.Database.ExecuteSqlCommand(
                                    "UPDATE ParaRoom SET BET_MIN=" + betMin + ",BET_MAX=" + betMax + ",MinBetUnits=" + rtBetMinSave + ",MaxBetUnits=" + rtBetMaxSave + ",COIN_SC=" + coinSc + ",COIN_NEED=" + coinNeed + " WHERE GAME_ID=" + gameId + " AND ID=" + (gameId * 1000 + tIdx));
                            }
                            string baseRowSql = IsDecimalBetFish(gameId)
                                ? ("UPDATE ParaRoom SET BET_MIN=" + betMin + ",BET_MAX=" + betMax + ",MinBetUnits=" + rtBetMinSave + ",MaxBetUnits=" + rtBetMaxSave + ",EX_COIN=" + exCoin + ",COIN_SC=" + coinSc + ",COIN_NEED=" + coinNeed + " WHERE GAME_ID=" + gameId + " AND ID=" + (gameId * 1000))
                                : ("UPDATE ParaRoom SET BET_MIN=" + betMin + ",BET_MAX=" + betMax + ",EX_COIN=" + exCoin + ",COIN_SC=" + coinSc + ",COIN_NEED=" + coinNeed + " WHERE GAME_ID=" + gameId + " AND ID=" + (gameId * 1000));
                            ef.Database.ExecuteSqlCommand(baseRowSql);
                        }
                        catch (Exception exRoom)
                        {
                            LogHelper.WriteLog(typeof(GameConfigController), exRoom);
                        }
                        // 同步 pararoom.NUM = roomtableconfig 条数，保证旧房间参数口径与新按桌配置一致
                        SyncFishTableNum(ef, gameId);
                    }
                    var srv = new SConnect();   // RP/TC/PA 共用同一连接，减少管道竞争
                    msg = srv.SendReadString(EScMsgType.RP, gameId);
                    if (msg.code == 1)
                    {
                        // TC 热更（桌台基础配置 + tableExt 押注参数）
                        // 鱼机补传 tableExt(BetMin/BetMax/OneCoinScore/CoinsNeed),使押注参数有单条热更通道,
                        // 不再仅依赖 RP 全量重载(避免新建桌台后未重启时押注对不上)。
                        if (IsDecimalBetFish(gameId))
                        {
                            var tExt = new SConnect.TcTableExt
                            {
                                BetMin = (uint)rtBetMinSave,
                                BetMax = (uint)rtBetMaxSave,
                                OneCoinScore = (uint)coinSc,
                                CoinsNeed = (uint)coinNeed
                            };
                            srv.SendTcCommand((ushort)gameId, 0, (ushort)tIdx, tName, (byte)(tblEnabled != 0 ? 1 : 0), (uint)idleSec, (byte)(tblIdleKick != 0 ? 1 : 0), (ushort)tblMaxSeats, null, tExt);
                        }
                        else
                        {
                            srv.SendTcCommand((ushort)gameId, 0, (ushort)tIdx, tName, (byte)(tblEnabled != 0 ? 1 : 0), (uint)idleSec, (byte)(tblIdleKick != 0 ? 1 : 0), (ushort)tblMaxSeats);
                        }
                        // 鱼机难度热更：PA + gameID(2位) + tableIndex(3位) + DIF + SITE_TYPE。
                        // 中心服 PA 分支调 SetTablePara 下发 COM_TABLE_SET 给子游戏实时生效（AlgPlayerReset_DIF），
                        // 同时 SetTablePara 鱼机分支会调 UpsertFishTablePara 落库，保证 RP 全量重载与重启后一致。
                        try
                        {
                            var paMsg = srv.SendReadString(EScMsgType.PA,
                                gameId.ToString().PadLeft(2, '0'),
                                tIdx.ToString().PadLeft(3, '0'),
                                fishDif, fishSiteType);
                            if (paMsg.code != 1)
                            {
                                LogHelper.WriteLog(typeof(GameConfigController), "鱼机难度热更失败：" + (paMsg.content ?? ""));
                            }
                        }
                        catch (Exception exPa)
                        {
                            LogHelper.WriteLog(typeof(GameConfigController), exPa);
                        }
                    }
                    // 写库成功即标记已落库：即使 RP/TC/PA 热更管道失败也刷新前端列表，
                    // 避免"DB 已写、Web 列表不刷新"（对齐 B_SuperPara.PushHotUpdate 的 datas=true 约定）。
                    msg.datas = true;
                    // 回显本次落库的按桌关键值，便于核对表单提交与库中数据是否一致
                    msg.content = (msg.content ?? "") + " [桌" + tIdx + " 已写入: CoinsNeed=" + coinNeed + ", BetMin=" + betMin + ", BetMax=" + betMax + ", CoinSc=" + coinSc + ", FishDif=" + fishDif + ", FishSite=" + fishSiteType + ", GunStep=" + rtGunStep + "]";
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
        // 牌机/押注类改一房N桌后 ROOM_MAX 恒为 1，此处保留供删除路径复用。
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
                    // 牌机/押注类一房N桌：ROOM_MAX 恒为 1(单房间)，桌台数由 roomtableconfig 行数表达。
                    if (gameType == 0 || gameType == 1)
                    {
                        int affected = ef.Database.ExecuteSqlCommand("UPDATE ParaGame SET ROOM_MAX=1 WHERE ID={0}", gameId);
                        if (affected == 0)
                            ef.Database.ExecuteSqlCommand("INSERT INTO ParaGame(ID,ROOM_MAX,PLY_MAX) VALUES({0},1,1000)", gameId);
                        return;
                    }
                    int cnt = ef.Database.SqlQuery<int>(
                        "SELECT COUNT(*) FROM " + roomTbl + " WHERE GAME_ID={0}", gameId).FirstOrDefault();
                    if (cnt <= 0) return;
                    int aff = ef.Database.ExecuteSqlCommand("UPDATE ParaGame SET ROOM_MAX={0} WHERE ID={1}", cnt, gameId);
                    if (aff == 0)
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
        /// 同步牌机 pararoom base 行 NUM = roomtableconfig 条数，并强制 paragame.ROOM_MAX=1。
        /// 牌机改一房N桌后：ROOM_MAX 恒1，桌台数由 roomtableconfig 行数表达，
        /// 服务端 GetCardPara 按 roomMax=1 循环1次读 base 行(num=N)，tableMax=N 读 paracard[0..N-1]。
        /// </summary>
        /// <summary>
        /// 同步牌机 pararoom base 行 NUM = roomtableconfig 条数，并强制 paragame.ROOM_MAX=1。
        /// 牌机改一房N桌后：ROOM_MAX 恒1，桌台数由 roomtableconfig 行数表达，
        /// 服务端 GetCardPara 按 roomMax=1 循环1次读 base 行(num=N)，tableMax=N 读 paracard[0..N-1]。
        /// base 行不存在时自动 INSERT(保存首张桌台/历史数据缺失场景)，避免服务端 GetCardPara
        /// 读不到 base 行而自动补建默认值(覆盖后台配置)。
        /// </summary>
        private static void SyncCardTableNum(GameDbContext ef, int gameId)
        {
            try
            {
                int cfgCount = ef.Database.SqlQuery<int>(
                    "SELECT COUNT(*) FROM roomtableconfig WHERE GAME_ID=" + gameId).FirstOrDefault();
                if (cfgCount <= 0) return;
                int baseId = gameId * 1000;
                // base 行不存在则 INSERT(含服务端 GetCardPara 读取的必要字段)，存在则 UPDATE num
                int affected = ef.Database.ExecuteSqlCommand(
                    "UPDATE ParaRoom SET NUM=" + cfgCount + " WHERE GAME_ID=" + gameId + " AND ID=" + baseId);
                if (affected == 0)
                {
                    ef.Database.ExecuteSqlCommand(
                        "INSERT INTO ParaRoom(ID,GAME_ID,NUM,BET_MIN,BET_MAX,EX_COIN,COIN_SC,COIN_NEED,scoreSwitch,Game_Mo,TableName,MaxSeats,IdleFireTimeoutSec,IdleFireKickEnabled,Enabled,MinBetUnits,MaxBetUnits) VALUES(" +
                        baseId + "," + gameId + "," + cfgCount + ",1,100,10000,1,10000,0,0,'',6,0,1,1,10,1000)");
                }
                // ROOM_MAX 强制1
                int aff = ef.Database.ExecuteSqlCommand(
                    "UPDATE ParaGame SET ROOM_MAX=1 WHERE ID=" + gameId);
                if (aff == 0)
                    ef.Database.ExecuteSqlCommand(
                        "INSERT INTO ParaGame(ID,ROOM_MAX,PLY_MAX) VALUES(" + gameId + ",1,1000)");
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(GameConfigController), ex);
            }
        }

        /// <summary>
        /// 删除牌机桌台后，把 paracard 剩余行重排为连续 ID(gameId*1000+0..k-1)，
        /// 与 roomtableconfig(经 CompactFishTableIndexes 压实后) 保持同构。
        /// 否则中心服 GetCardPara 按 ID=gameId*1000+i 逐桌读 paracard 会与 roomtableconfig 错位。
        /// 采用"负数临时 id"两段式重排，彻底避免主键碰撞（与 CompactFishParaFishIds 同思路）。
        /// 注：paracard 只有 ID/GAME_ID/DIF/HYPE_TYPE，无 TableIndex 列，压实只需重排 ID。
        /// </summary>
        private static void CompactCardParaIds(GameDbContext ef, int gameId)
        {
            try
            {
                int baseId = gameId * 1000;
                // 按 ID 升序取剩余行
                var ids = ef.Database.SqlQuery<int>(
                    "SELECT ID FROM paracard WHERE GAME_ID=" + gameId + " ORDER BY ID").ToList();
                int k = ids.Count;
                // 第一段：移到唯一负数临时 id，腾空正数目标区间
                for (int i = 0; i < k; i++)
                {
                    int tmp = -(baseId + i + 1);
                    ef.Database.ExecuteSqlCommand("UPDATE paracard SET ID={0} WHERE ID={1}", tmp, ids[i]);
                }
                // 第二段：回填为连续正数 id
                for (int i = 0; i < k; i++)
                {
                    int tmp = -(baseId + i + 1);
                    int dst = baseId + i;
                    ef.Database.ExecuteSqlCommand("UPDATE paracard SET ID={0} WHERE ID={1}", dst, tmp);
                }
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
					// 一房N桌：拉霸桌台索引从 roomtableconfig 取 MAX(TableIndex)+1，对齐鱼机/牌机/押注类
					var labaMax = ef.Database.SqlQuery<int?>("SELECT MAX(TableIndex) FROM roomtableconfig WHERE GAME_ID=" + gameId).FirstOrDefault() ?? -1;
					return baseId + labaMax + 1;
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

			else if (gameType == 1)
			{
				// 一房N桌：牌机桌台索引从 roomtableconfig 取 MAX(TableIndex)+1，与鱼机/押注类同思路
				var cardMax = ef.Database.SqlQuery<int?>("SELECT MAX(TableIndex) FROM roomtableconfig WHERE GAME_ID=" + gameId).FirstOrDefault() ?? -1;
				return baseId + cardMax + 1;
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

        /// <summary>
        /// 从 paralaba 实体按属性名取值（反射辅助 GetTableConfig 回显）
        /// </summary>
        private static int GetLabaParaField(M_ParaLaba laba, string fieldName)
        {
            var prop = typeof(M_ParaLaba).GetProperty(fieldName);
            if (prop == null) return 0;
            var val = prop.GetValue(laba);
            return val != null ? (int)val : 0;
        }

        // ── 明星97(GameId=16) RTP 控制配置（游戏级，存 GameConfigLaba TableIndex=0）──
        // 见《明星97-RTP控制-后台对接文档》：OptValue 为 int，小数用整数放大表示；
        // 服务端收到整包配置先清空再套用，后台删掉某 OptKey 即回内置默认值。
        private static readonly string[] Mx97RtpKeys =
        {
            "RtpTargetX100", "RtpKp", "RtpDeadband", "RtpDeltaMax",
            "RtpStockThreshold", "UseOutcomeFirst", "RtpWindow"
        };
        private static readonly string[] Mx97RtpLabels =
        {
            "目标返奖率", "闭环比例系数", "死区", "单步偏置上限",
            "大奖库存阈值", "结果优先生成开关", "RTP 统计窗口"
        };
        private static readonly string[] Mx97RtpRanges =
        {
            "5000-12000（9000=90.00%）", "1-500（越大回调越快、波动越大）", "0-200（±0.10% 内不干预）", "1-200（单局最多拉动 0.40）",
            "≥1（赔率≥该值视为大奖）", "0/1（0=回退旧开奖逻辑）", "≥100000（累计下注量）"
        };

        /// <summary>
        /// 保存明星97 RTP 控制配置：校验 + 写 GameConfigLaba(GameId=16, TableIndex=0)。
        /// 留空的 RTP/Combo 项删除对应 OptKey（回内置默认/不限）；
        /// UseOutcomeFirst=0（回退旧逻辑）、ComboStock=0（当天禁出）为合法显式值。
        /// </summary>
        private static Msg SaveMx97RtpConfig(FormCollection form, int gameId)
        {
            Msg msg = new Msg(1, "RTP 配置保存成功！");
            List<M_GameConfigLaba> toWrite = new List<M_GameConfigLaba>();

            // RTP 闭环参数（7 项）：留空(-1)删除；UseOutcomeFirst 开关恒有值(0/1)
            for (int i = 0; i < Mx97RtpKeys.Length; i++)
            {
                string key = Mx97RtpKeys[i];
                int v = form.Q<int>(key, -1);
                if (key == "UseOutcomeFirst")
                {
                    if (v != 0 && v != 1)
                    {
                        msg.code = 0;
                        msg.content = "「结果优先生成开关」取值不合法（0=回退旧开奖逻辑 / 1=结果优先生成）！";
                        return msg;
                    }
                    toWrite.Add(new M_GameConfigLaba { GameId = gameId, OptKey = key, OptValue = v, Type = "RTP" });
                    continue;
                }
                if (v < 0) continue;   // 留空：删除该 OptKey，回内置默认
                bool ok = true;
                switch (key)
                {
                    case "RtpTargetX100": ok = v >= 5000 && v <= 12000; break;
                    case "RtpKp": ok = v >= 1 && v <= 500; break;
                    case "RtpDeadband": ok = v >= 0 && v <= 200; break;
                    case "RtpDeltaMax": ok = v >= 1 && v <= 200; break;
                    case "RtpStockThreshold": ok = v >= 1; break;
                    case "RtpWindow": ok = v >= 100000; break;
                }
                if (!ok)
                {
                    msg.code = 0;
                    msg.content = "RTP 参数「" + Mx97RtpLabels[i] + "」取值不合法，应为 " + Mx97RtpRanges[i] + "！";
                    return msg;
                }
                toWrite.Add(new M_GameConfigLaba { GameId = gameId, OptKey = key, OptValue = v, Type = "RTP" });
            }

            // 组合结果配置（300-359）：Combo<code> 赔率>0 / ComboProb<code> 出现率1-10000 / ComboStock<code> 库存≥0
            for (int code = 300; code <= 359; code++)
            {
                int pay = form.Q<int>("Combo" + code, -1);
                int prob = form.Q<int>("ComboProb" + code, -1);
                int stock = form.Q<int>("ComboStock" + code, -1);
                if (pay > 0)
                    toWrite.Add(new M_GameConfigLaba { GameId = gameId, OptKey = "Combo" + code, OptValue = pay, Type = "Combo" });
                else if (pay != -1)
                {
                    msg.code = 0;
                    msg.content = "结果类 " + code + " 赔率必须大于 0（留空表示用内置默认赔率）！";
                    return msg;
                }
                if (prob > 0 && prob <= 10000)
                    toWrite.Add(new M_GameConfigLaba { GameId = gameId, OptKey = "ComboProb" + code, OptValue = prob, Type = "Combo" });
                else if (prob != -1)
                {
                    msg.code = 0;
                    msg.content = "结果类 " + code + " 目标出现率须在 1-10000（万分比），留空表示用内置默认出现率！";
                    return msg;
                }
                if (stock >= 0)   // 0=当天禁出，合法
                    toWrite.Add(new M_GameConfigLaba { GameId = gameId, OptKey = "ComboStock" + code, OptValue = stock, Type = "Combo" });
            }

            // 落库：删除该游戏全部被管理 OptKey（含历史遗留的其它 TableIndex 行），
            // 再按本次配置写入 TableIndex=0（服务端按 GameId 合并读取，TableIndex 不影响语义）。
            // 被管理命名空间为 Rtp*/Combo*（明星97 专用），LIKE 前缀匹配避免大 IN 参数列表。
            using (var ef = new GameDbContext())
            {
                List<M_GameConfigLaba> olds = ef.GameConfigLabas
                    .Where(c => c.GameId == gameId && (c.OptKey.StartsWith("Rtp") || c.OptKey.StartsWith("Combo")))
                    .ToList();
                ef.GameConfigLabas.RemoveRange(olds);
                foreach (M_GameConfigLaba row in toWrite)
                {
                    row.GameId = gameId;
                    row.TableIndex = 0;
                    row.TIME = DateTime.Now;
                    ef.GameConfigLabas.Add(row);
                }
                ef.SaveChanges();
            }
            return msg;
        }

        /// <summary>
        /// 把明星97 RTP/Combo 配置回显到桌台行（键名供 ConfigEditor 的 gcFillMx97 读取）
        /// </summary>
        private static void AddMx97RtpRowFields(Dictionary<string, object> row, Dictionary<string, int> cfg)
        {
            string[] rtpRowKeys = { "rtpTargetX100", "rtpKp", "rtpDeadband", "rtpDeltaMax", "rtpStockThreshold", "useOutcomeFirst", "rtpWindow" };
            for (int i = 0; i < Mx97RtpKeys.Length; i++)
            {
                int v;
                row[rtpRowKeys[i]] = cfg.TryGetValue(Mx97RtpKeys[i], out v) ? (int?)v : null;
            }
            for (int code = 300; code <= 359; code++)
            {
                int v;
                row["combo" + code] = cfg.TryGetValue("Combo" + code, out v) ? (int?)v : null;
                row["comboProb" + code] = cfg.TryGetValue("ComboProb" + code, out v) ? (int?)v : null;
                row["comboStock" + code] = cfg.TryGetValue("ComboStock" + code, out v) ? (int?)v : null;
            }
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

        // betgamecfg 押注类玩法扩展配置行映射（原生 SQL 查询用）
        public class BetGameCfgRow
        {
            public int TableIndex { get; set; }
            public string CfgJson { get; set; }
        }

        // roomtableconfig 牌机类桌台行映射（原生 SQL 查询用）
        public class CardTableCfgRow
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
            public int MinBetUnits { get; set; }
        }

        // roomtableconfig_card 牌机类桌台扩展参数行映射（原生 SQL 查询用）
        public class CardTableCfgCardRow
        {
            public int TableIndex { get; set; }
            public int ExCoin { get; set; }
            public int ScoreSwitch { get; set; }
            public int GameMo { get; set; }
            public int MaxBetUnits { get; set; }
        }

}
}
