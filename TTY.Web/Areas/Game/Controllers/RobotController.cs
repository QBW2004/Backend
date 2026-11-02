using Google.Protobuf.WellKnownTypes;
using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using Newtonsoft.Json.Linq;
using YYT.BLL.EF;
using YYT.Common;
using YYT.Entity;
using YYT.Remote;

namespace YYT.Web.Areas.Game.Controllers
{
    public class RobotController : Controller
    {
        // A deliberately local name pool keeps batch-created accounts readable
        // without introducing a schema change or a dependency on an external
        // service.  Names are assembled from these Chinese characters at a
        // random length of 2-8 characters and de-duplicated against userrobot.
        private const string RobotNameLibrary =
            "星月云风雨雪晴虹晨露清宁安乐欢喜福瑞吉祥旺财金玉宝贝" +
            "小大春夏秋冬山河湖海江川林森花草竹梅兰菊荷桃柳松柏" +
            "青蓝紫红橙白黑金银天心明光远航飞扬自在如意顺利平安" +
            "灵慧聪敏温柔可爱帅气英俊甜美雅致优雅清新自然热情善良" +
            "笑语知音朋友梦想希望未来成功胜利荣耀幸运快乐开心" +
            "龙凤虎兔马羊猴鸡狗猫鱼鹿鹤蝶燕鸢鹏鲸";
        // Common two-to-four character chunks make the generated nicknames
        // read like names instead of an arbitrary stream of Han characters.
        // The character library above remains the final source of truth for
        // the strict Chinese-character check and provides extra variety.
        private static readonly string[] RobotNamePool =
        {
            "星河", "清风", "明月", "小雨", "晴天", "白云", "晨光", "晚霞", "春风", "秋水",
            "山河", "江南", "海棠", "青竹", "兰心", "桃夭", "柳岸", "松间", "花语", "蝶舞",
            "龙飞", "凤舞", "瑞雪", "福星", "如意", "平安", "安宁", "快乐", "欢喜", "好运",
            "远航", "飞扬", "自在", "梦想", "希望", "未来", "荣耀", "胜利", "知音", "微笑",
            "温柔", "可爱", "帅气", "优雅", "清新", "自然", "灵动", "聪慧", "善良", "热情"
        };
        private static readonly object RobotNameRandomLock = new object();
        private static readonly Random RobotNameRandom = new Random();

        // GET: Game/Robot
        public ActionResult Index()
        {
            return View();
        }

        [AjaxOnly]
        [HttpPost]
        public ActionResult GetGamesTreeData(FormCollection form)
        {
            List<M_TreeModel> list = new List<M_TreeModel>();
            try
            {
                int GameType = form.Q<int>("GameType");
                M_Games entity = new M_Games();
                entity.Enable = 1;
                if (GameType > -1)
                    entity.GameType = GameType;

                list = new B_Games().GetGamesTreeData(entity);
                // 麻将胡了没有选桌，也未接入机器人。
                foreach (var node in list)
                    if (node.children != null) node.children = node.children.Where(g => g.id != 54).ToList();
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.RobotController), ex);
            }
            return Json(list);
        }

        /// <summary>添加机器人“代理线”下拉里表示“公共桌台”的值（空串在 easyui combobox 里会被当成未选）。</summary>
        private const string PublicLineKey = B_Robot.PublicLineKey;

        /// <summary>前端提交的代理线 → 归属口径：公共桌台为空串，其余为直属代理账号。</summary>
        private static string NormalizeLine(string raw)
        {
            string line = (raw ?? string.Empty).Trim();
            return line == PublicLineKey ? string.Empty : line;
        }

        /// <summary>
        /// 添加机器人的“代理线”下拉：公共桌台 + 在该游戏有专属桌台的直属代理（专属桌台在「游戏配置」里分配）。
        /// </summary>
        [AjaxOnly]
        [HttpPost]
        public ActionResult GetRobotLineOptions(FormCollection form)
        {
            List<object> lines = new List<object>();
            lines.Add(new { id = PublicLineKey, text = "公共桌台", selected = true });
            try
            {
                int GameId = form.Q<int>("GameId");
                if (GameId > 0)
                {
                    using (var ef = new GameDbContext())
                    {
                        Dictionary<int, string> owners = LineTables.GetOwners(ef, GameId);
                        foreach (string agent in LineScopeRules.GetLineAgents(ef))
                        {
                            int count = owners.Values.Count(v => string.Equals(v, agent, StringComparison.OrdinalIgnoreCase));
                            if (count > 0)
                                lines.Add(new { id = agent, text = agent + "（" + count + "张专属桌台）" });
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.RobotController), ex);
            }
            return Json(lines);
        }

        /// <summary>
        /// 机器人列表“代理线”筛选：全部 + 公共桌台 + 超管全部直属代理 + 已收回。
        /// </summary>
        [AjaxOnly]
        [HttpPost]
        public ActionResult GetRobotLineFilter(FormCollection form)
        {
            List<object> lines = new List<object>();
            lines.Add(new { id = "*", text = "全部", selected = true });
            lines.Add(new { id = PublicLineKey, text = "公共桌台" });
            try
            {
                using (var ef = new GameDbContext())
                {
                    foreach (string agent in LineScopeRules.GetLineAgents(ef))
                        lines.Add(new { id = agent, text = agent });
                }
                lines.Add(new { id = LineScopeRules.RecycledLine, text = "已收回" });
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.RobotController), ex);
            }
            return Json(lines);
        }

        /// <summary>
        /// 桌台名称列表：全游戏类型统一从 roomtableconfig 读取(玩家/机器人已锁定第一房间)，
        /// TableName 为空时保底"桌台"+TableIndex。按代理线过滤：Line 为公共桌台(或不传)只列公共桌台，
        /// 否则只列该直属代理的专属桌台；已收回的桌两边都不列。
        /// </summary>
        /// <param name="form"></param>
        /// <returns></returns>
        [AjaxOnly]
        [HttpPost]
        public ActionResult GetRobotTableList(FormCollection form)
        {
            List<object> tableList = new List<object>();
            try
            {
                int GameId = form.Q<int>("GameId");
                string line = NormalizeLine(form.Q<string>("Line"));
                if (GameId > 0)
                {
                    using (var ef = new GameDbContext())
                    {
                        var rows = ef.Database.SqlQuery<BetTableSelRow>(
                            "SELECT TableIndex, TableName FROM roomtableconfig WHERE GAME_ID={0} AND RoomIndex=0 ORDER BY TableIndex", GameId).ToList();
                        Dictionary<int, string> owners = LineTables.GetOwners(ef, GameId);
                        int idx = 0;
                        foreach (BetTableSelRow r in rows)
                        {
                            if (!LineScopeRules.TableBelongsTo(owners, r.TableIndex, line))
                                continue;
                            tableList.Add(new
                            {
                                id = r.TableIndex,
                                text = string.IsNullOrWhiteSpace(r.TableName) ? ("桌台" + r.TableIndex) : r.TableName,
                                selected = idx == 0
                            });
                            idx++;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.RobotController), ex);
            }
            return Json(tableList);
        }

        [MemberAuthorize]
        [AjaxOnly]
        [HttpPost]
        public ActionResult GetCardRobotCapacity(FormCollection form)
        {
            try
            {
                using (var ef = new GameDbContext())
                {
                    int gameId = form.Q<int>("GameId");
                    string line = NormalizeLine(form.Q<string>("Line"));
                    var game = ef.Games.SingleOrDefault(g => g.GameId == gameId && g.Enable == 1);
                    if (game == null || !B_Robot.IsMachineRobotGame(gameId, game.GameType))
                        return Json(new { code = 0, content = "该游戏不支持按机台设置机器人数量！" });
                    int total = B_Robot.GetCardRobotTables(ef, gameId, line).Count;
                    int current = B_Robot.GetCardRobots(ef, gameId, line).Sum(r => Math.Max(0, r.ROBOT_NO));
                    return Json(new { code = 1, total, current, remaining = Math.Max(0, total - current) });
                }
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(RobotController), ex);
                return Json(new { code = 0, content = "机台数量读取失败，请重新选择游戏和代理线！" });
            }
        }

        /// <summary>
        /// Reads the live ServerRobot snapshot.  robot_seat only stores target counts;
        /// this endpoint intentionally asks ServerRobot for the account that is actually
        /// connected and its current game/table/seat.
        /// </summary>
        [MemberAuthorize]
        [AjaxOnly]
        [HttpPost]
        public ActionResult GetRobotSeats(FormCollection form)
        {
            Msg status = new SConnect().SendRobotStatus();
            if (status.code != 1)
                return Json(status);

            try
            {
                JObject payload = status.datas as JObject ?? JObject.Parse(Convert.ToString(status.datas));
                var robots = payload["robots"] as JArray ?? new JArray();
                using (var ef = new GameDbContext())
                {
                    var allRows = EnrichLiveRobotSeats(ef, robots);
                    // One snapshot for the overview; filters and pagination only affect the table.
                    var summary = new
                    {
                        Total = allRows.Count,
                        Online = allRows.Count(r => r.Connected),
                        Seated = allRows.Count(r => r.Sitting),
                        Idle = allRows.Count(r => !r.Sitting)
                    };
                    int gameId = form.Q<int>("SeatGameId", -1);
                    string line = (form.Q<string>("SeatLine") ?? string.Empty).Trim();
                    string tableFilter = (form.Q<string>("SeatTable") ?? string.Empty).Trim();
                    string accountFilter = (form.Q<string>("SeatAccount") ?? string.Empty).Trim();
                    string statusFilter = (form.Q<string>("SeatStatus") ?? "all").Trim().ToLowerInvariant();
                    if (gameId >= 0)
                        allRows = allRows.Where(r => r.GAME_ID == gameId).ToList();
                    if (!string.IsNullOrWhiteSpace(line) && line != "*")
                    {
                        string expectedLine = line == PublicLineKey ? string.Empty : line;
                        allRows = allRows.Where(r => string.Equals(r.LINE_AGENT ?? string.Empty, expectedLine,
                            StringComparison.OrdinalIgnoreCase)).ToList();
                    }
                    if (!string.IsNullOrWhiteSpace(tableFilter))
                    {
                        int tableId;
                        bool numericTable = int.TryParse(tableFilter, NumberStyles.Integer,
                            CultureInfo.InvariantCulture, out tableId);
                        allRows = allRows.Where(r =>
                            (numericTable && r.TABLE_ID == tableId) ||
                            (r.TABLE_NAME ?? string.Empty).IndexOf(tableFilter, StringComparison.OrdinalIgnoreCase) >= 0).ToList();
                    }
                    if (!string.IsNullOrWhiteSpace(accountFilter))
                    {
                        allRows = allRows.Where(r =>
                            (r.UserName ?? string.Empty).IndexOf(accountFilter, StringComparison.OrdinalIgnoreCase) >= 0 ||
                            (r.UserNick ?? string.Empty).IndexOf(accountFilter, StringComparison.OrdinalIgnoreCase) >= 0).ToList();
                    }
                    if (statusFilter == "seated")
                        allRows = allRows.Where(r => r.Sitting).ToList();
                    else if (statusFilter == "idle")
                        allRows = allRows.Where(r => !r.Sitting).ToList();
                    else if (statusFilter == "offline")
                        allRows = allRows.Where(r => !r.Connected).ToList();
                    // Put idle accounts first in the unfiltered view so they are
                    // visible without paging through all seated robots.
                    allRows = allRows.OrderBy(r => r.Sitting ? 1 : 0)
                        .ThenBy(r => r.Connected ? 0 : 1)
                        .ThenBy(r => r.RobotId).ToList();
                    int page = Math.Max(1, form.Q<int>("page", 1));
                    int pageSize = form.Q<int>("rows", 20);
                    pageSize = Math.Max(1, Math.Min(pageSize, 200));
                    int total = allRows.Count;
                    var rows = allRows.Skip((page - 1) * pageSize).Take(pageSize).ToList();
                    return Json(new { code = 1, rows = rows, total = total, summary = summary });
                }
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(RobotController), ex);
                return Json(new Msg(0, "机器人状态解析失败：" + ex.Message));
            }
        }

        /// <summary>Requests one live robot to leave its current seat.</summary>
        [MemberAuthorize]
        [AjaxOnly]
        [HttpPost]
        [SuperAdminAuthorize]
        public ActionResult RemoveRobotSeat(FormCollection form)
        {
            long robotId = form.Q<long>("RobotId", form.Q<long>("ID"));
            if (robotId <= 0)
                return Json(new Msg(0, "请选择有效的机器人。"));
            return Json(new SConnect().SendRobotAction("REMOVE " + robotId, "REMOVE_OK", "机器人已离开当前座位。"));
        }

        /// <summary>Starts a staggered shuffle; delays are deliberately bounded to 1~5 seconds.</summary>
        [MemberAuthorize]
        [AjaxOnly]
        [HttpPost]
        [SuperAdminAuthorize]
        public ActionResult ShuffleRobots(FormCollection form)
        {
            int minMs = form.Q<int>("minDelayMs", -1);
            int maxMs = form.Q<int>("maxDelayMs", -1);
            if (minMs < 0 || maxMs < 0)
            {
                int minSeconds = form.Q<int>("MinDelaySeconds", 1);
                int maxSeconds = form.Q<int>("MaxDelaySeconds", 5);
                minMs = minSeconds * 1000;
                maxMs = maxSeconds * 1000;
            }
            if (minMs < 1000 || maxMs > 5000 || maxMs < minMs)
                return Json(new Msg(0, "机器人打乱间隔必须在1～5秒内，且最小值不能大于最大值。"));
            return Json(new SConnect().SendRobotAction("SHUFFLE " + minMs + " " + maxMs,
                "SHUFFLE_OK", "已开始打乱机器人，机器人会按随机间隔离开当前座位。"));
        }

        /// <summary>Moves one account to an explicitly selected game/table/seat.</summary>
        [MemberAuthorize]
        [AjaxOnly]
        [HttpPost]
        [SuperAdminAuthorize]
        public ActionResult SetRobotSeat(FormCollection form)
        {
            long robotId = form.Q<long>("RobotId", form.Q<long>("ID"));
            int gameId = form.Q<int>("GameId", -1);
            int roomId = form.Q<int>("RoomId", 0);
            int tableId = form.Q<int>("TableId", form.Q<int>("TABLE_ID", -1));
            int seatId = form.Q<int>("SeatIndex", form.Q<int>("seatId", -1));
            if (robotId <= 0 || gameId < 0 || roomId < 0 || tableId < 0 || seatId < 0)
                return Json(new Msg(0, "机器人、游戏、机台和座位都必须有效。"));

            string line = NormalizeLine(form.Q<string>("Line"));
            int gameType;
            using (var ef = new GameDbContext())
            {
                var game = ef.Games.SingleOrDefault(g => g.GameId == gameId && g.Enable == 1 && g.GameId != 54);
                if (game == null)
                    return Json(new Msg(0, "目标游戏未启用或不支持机器人。"));
                gameType = game.GameType;
                var table = ef.Database.SqlQuery<RobotSeatOptionRow>(
                    "SELECT TableIndex,TableName,MaxSeats FROM roomtableconfig WHERE GAME_ID={0} AND RoomIndex={1} AND TableIndex={2} AND Enabled=1 LIMIT 1",
                    gameId, roomId, tableId).SingleOrDefault();
                if (table == null)
                    return Json(new Msg(0, "目标机台未启用或不存在。"));
                if (seatId >= GetRobotSeatCapacity(game.GameType, table.MaxSeats))
                    return Json(new Msg(0, "座位号超过该机台的实际座位数。"));
                Dictionary<int, string> owners = LineTables.GetOwners(ef, gameId);
                if (!LineScopeRules.TableBelongsTo(owners, tableId, line))
                    return Json(new Msg(0, string.IsNullOrEmpty(line) ? "目标机台不属于公共桌台。" : "目标机台不属于所选代理线。"));
            }

            return Json(new SConnect().SendRobotAction(
                string.Format(CultureInfo.InvariantCulture, "MOVE {0} {1} {2} {3} {4} {5}", robotId, gameId, roomId, tableId, seatId, gameType),
                "MOVE_OK", "机器人已移动到指定座位。"));
        }

        /// <summary>Brings an account that is not currently in ServerRobot online and into a selected seat.</summary>
        [MemberAuthorize]
        [AjaxOnly]
        [HttpPost]
        [SuperAdminAuthorize]
        public ActionResult OnlineRobot(FormCollection form)
        {
            long robotId = form.Q<long>("RobotId", form.Q<long>("ID"));
            int gameId = form.Q<int>("GameId", -1);
            int roomId = form.Q<int>("RoomId", 0);
            int tableId = form.Q<int>("TableId", form.Q<int>("TABLE_ID", -1));
            int seatId = form.Q<int>("SeatIndex", form.Q<int>("seatId", -1));
            if (robotId <= 0 || gameId < 0 || roomId < 0 || tableId < 0 || seatId < 0)
                return Json(new Msg(0, "机器人、游戏、机台和座位都必须有效。"));

            int gameType;
            using (var ef = new GameDbContext())
            {
                var game = ef.Games.SingleOrDefault(g => g.GameId == gameId && g.Enable == 1 && g.GameId != 54);
                if (game == null)
                    return Json(new Msg(0, "目标游戏未启用或不支持机器人。"));
                gameType = game.GameType;
                var table = ef.Database.SqlQuery<RobotSeatOptionRow>(
                    "SELECT TableIndex,TableName,MaxSeats FROM roomtableconfig WHERE GAME_ID={0} AND RoomIndex={1} AND TableIndex={2} AND Enabled=1 LIMIT 1",
                    gameId, roomId, tableId).SingleOrDefault();
                if (table == null)
                    return Json(new Msg(0, "目标机台未启用或不存在。"));
                if (seatId >= GetRobotSeatCapacity(game.GameType, table.MaxSeats))
                    return Json(new Msg(0, "座位号超过该机台的实际座位数。"));
                Dictionary<int, string> owners = LineTables.GetOwners(ef, gameId);
                string line = NormalizeLine(form.Q<string>("Line"));
                if (!LineScopeRules.TableBelongsTo(owners, tableId, line))
                    return Json(new Msg(0, string.IsNullOrEmpty(line) ? "目标机台不属于公共桌台。" : "目标机台不属于所选代理线。"));
                if (!ef.userRobots.Any(r => r.ID == robotId))
                    return Json(new Msg(0, "机器人账号不存在，请先新增或刷新机器人账号。"));
            }

            return Json(new SConnect().SendRobotAction(
                string.Format(CultureInfo.InvariantCulture, "ONLINE {0} {1} {2} {3} {4} {5}", robotId, gameId, roomId, tableId, seatId, gameType),
                "ONLINE_OK", "机器人已上线并入座。"));
        }

        /// <summary>Reloads the ServerRobot account pool after account CRUD on the merged page.</summary>
        [MemberAuthorize]
        [AjaxOnly]
        [HttpPost]
        [SuperAdminAuthorize]
        public ActionResult ReloadRobotAccounts(FormCollection form)
        {
            return Json(new SConnect().SendRobotReload());
        }

        /// <summary>
        /// Loads the selectors used by the live seat dialog.  Tables and seats are read
        /// from roomtableconfig so disabled tables cannot be selected accidentally.
        /// </summary>
        [MemberAuthorize]
        [AjaxOnly]
        [HttpPost]
        public ActionResult GetRobotSeatOptions(FormCollection form)
        {
            try
            {
                int gameId = form.Q<int>("GameId", -1);
                string line = NormalizeLine(form.Q<string>("Line"));
                long robotId = form.Q<long>("RobotId", form.Q<long>("ID"));
                using (var ef = new GameDbContext())
                {
                    var games = ef.Games.Where(g => g.Enable == 1 && g.GameId != 54)
                        .OrderBy(g => g.GameId)
                        .ToList()
                        .Select(g => new { id = g.GameId, text = GameDisplayNames.GetName(g.GameId, g.Name), type = g.GameType })
                        .ToList();

                    var lines = new List<object> { new { id = PublicLineKey, text = "公共桌台" } };
                    foreach (string agent in LineScopeRules.GetLineAgents(ef))
                        lines.Add(new { id = agent, text = agent });

                    var tables = new List<object>();
                    var seats = new List<int>();
                    if (gameId > 0)
                    {
                        var rows = ef.Database.SqlQuery<RobotSeatOptionRow>(
                            "SELECT TableIndex,TableName,MaxSeats FROM roomtableconfig WHERE GAME_ID={0} AND RoomIndex=0 AND Enabled=1 ORDER BY TableIndex", gameId)
                            .ToList();
                        Dictionary<int, string> owners = LineTables.GetOwners(ef, gameId);
                        foreach (var row in rows)
                        {
                            if (!LineScopeRules.TableBelongsTo(owners, row.TableIndex, line))
                                continue;
                            tables.Add(new
                            {
                                id = row.TableIndex,
                                text = string.IsNullOrWhiteSpace(row.TableName) ? "桌台" + row.TableIndex : row.TableName,
                                maxSeats = GetRobotSeatCapacity(ef.Games.Single(g => g.GameId == gameId).GameType, row.MaxSeats)
                            });
                        }
                        int maxSeats = rows.Count == 0 ? 1 : rows.Max(r => GetRobotSeatCapacity(ef.Games.Single(g => g.GameId == gameId).GameType, r.MaxSeats));
                        for (int i = 0; i < maxSeats; i++) seats.Add(i);
                    }

                    object current = null;
                    if (robotId > 0)
                    {
                        Msg status = new SConnect().SendRobotStatus();
                        if (status.code == 1)
                        {
                            JObject payload = status.datas as JObject ?? JObject.Parse(Convert.ToString(status.datas));
                            JToken live = (payload["robots"] as JArray ?? new JArray())
                                .FirstOrDefault(r => (long?)r["id"] == robotId);
                            if (live != null)
                            {
                                bool sitting = (bool?)live["sitting"] ?? false;
                                int liveGame = (int?)live["game"] ?? 0;
                                int liveRoom = (int?)live["room"] ?? 0;
                                int liveTable = (int?)live["table"] ?? -1;
                                int liveSeat = (int?)live["seat"] ?? -1;
                                // A disconnected robot keeps its planned destination in
                                // ServerRobot; use it to prefill the dialog so a manual
                                // move does not silently fall back to the public line.
                                int currentGame = sitting || liveGame > 0 ? liveGame : ((int?)live["planGame"] ?? liveGame);
                                int currentRoom = sitting || liveGame > 0 ? liveRoom : ((int?)live["planRoom"] ?? liveRoom);
                                int currentTable = sitting || liveTable >= 0 ? liveTable : ((int?)live["planTable"] ?? liveTable);
                                int currentSeat = sitting || liveSeat >= 0 ? liveSeat : ((int?)live["planSeat"] ?? liveSeat);
                                string currentLine = PublicLineKey;
                                if (currentGame > 0)
                                {
                                    Dictionary<int, string> owner = LineTables.GetOwners(ef, currentGame);
                                    string ownerName;
                                    if (owner.TryGetValue(currentTable, out ownerName) && !string.IsNullOrWhiteSpace(ownerName))
                                        currentLine = ownerName;
                                }
                                current = new
                                {
                                    RobotId = robotId,
                                    GameId = currentGame,
                                    RoomId = currentRoom,
                                    TableId = currentTable,
                                    SeatIndex = currentSeat,
                                    Line = currentLine
                                };
                            }
                        }
                    }
                    return Json(new { code = 1, games, lines, tables, seats, current });
                }
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(RobotController), ex);
                return Json(new Msg(0, "机器人座位选项读取失败：" + ex.Message));
            }
        }

        [MemberAuthorize]
        [AjaxOnly]
        [HttpPost]
        public ActionResult GetRobotShuffleSchedule(FormCollection form)
        {
            try
            {
                string raw = new SConnect().SendRobotPipeCommand("SCHEDULE_GET", 10000);
                const string prefix = "SCHEDULE_JSON ";
                if (!raw.StartsWith(prefix, StringComparison.OrdinalIgnoreCase))
                    return Json(new Msg(0, "机器人每日打乱时间读取失败：" + raw));
                JObject schedule = JObject.Parse(raw.Substring(prefix.Length).Trim());
                int start = (int?)schedule["startMinute"] ?? 120;
                int end = (int?)schedule["endMinute"] ?? 300;
                return Json(new
                {
                    code = 1,
                    Enabled = ((int?)schedule["enabled"] ?? 0) != 0,
                    StartTime = FormatScheduleMinute(start),
                    EndTime = FormatScheduleMinute(end),
                    DelayMinMs = (int?)schedule["delayMinMs"] ?? 1000,
                    DelayMaxMs = (int?)schedule["delayMaxMs"] ?? 5000,
                    Running = (bool?)schedule["running"] ?? false
                });
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(RobotController), ex);
                return Json(new Msg(0, "机器人每日打乱时间读取失败：" + ex.Message));
            }
        }

        [MemberAuthorize]
        [AjaxOnly]
        [HttpPost]
        [SuperAdminAuthorize]
        public ActionResult SaveRobotShuffleSchedule(FormCollection form)
        {
            bool enabled = form.Q<int>("Enabled", 0) != 0 || string.Equals(form.Q<string>("Enabled"), "true", StringComparison.OrdinalIgnoreCase);
            string start = NormalizeScheduleTime(form.Q<string>("StartTime", form.Q<string>("start")));
            string end = NormalizeScheduleTime(form.Q<string>("EndTime", form.Q<string>("end")));
            int minMs = form.Q<int>("minDelayMs", 1000);
            int maxMs = form.Q<int>("maxDelayMs", 5000);
            if (start == null || end == null)
                return Json(new Msg(0, "每日打乱时间须使用 HH:mm 格式。"));
            if (minMs < 1000 || maxMs > 5000 || maxMs < minMs)
                return Json(new Msg(0, "机器人打乱间隔必须在1～5秒内，且最小值不能大于最大值。"));
            string command = string.Format(CultureInfo.InvariantCulture, "SCHEDULE {0} {1} {2} {3} {4}",
                enabled ? 1 : 0, start, end, minMs, maxMs);
            return Json(new SConnect().SendRobotAction(command, "SCHEDULE_OK", "每日打乱机器人时间已保存。"));
        }

        [MemberAuthorize]
        [AjaxOnly]
        [HttpPost]
        public ActionResult GetRobotPlayTime(FormCollection form)
        {
            try
            {
                string raw = new SConnect().SendRobotPipeCommand("PLAYTIME_GET", 10000);
                const string prefix = "PLAYTIME_JSON ";
                if (!raw.StartsWith(prefix, StringComparison.OrdinalIgnoreCase))
                    return Json(new Msg(0, "机器人游玩时长读取失败，请确认 ServerRobot 已配套更新：" + raw));
                JObject config = JObject.Parse(raw.Substring(prefix.Length).Trim());
                return Json(new
                {
                    code = 1,
                    Enabled = (int)config["enabled"] != 0,
                    MinHours = (decimal)config["minSeconds"] / 3600m,
                    MaxHours = (decimal)config["maxSeconds"] / 3600m
                });
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(RobotController), ex);
                return Json(new Msg(0, "机器人游玩时长读取失败：" + ex.Message));
            }
        }

        [MemberAuthorize]
        [AjaxOnly]
        [HttpPost]
        [SuperAdminAuthorize]
        public ActionResult SaveRobotPlayTime(FormCollection form)
        {
            int minSeconds, maxSeconds;
            if (!TryPlayTimeSeconds(form.Q<string>("MinHours"), out minSeconds) ||
                !TryPlayTimeSeconds(form.Q<string>("MaxHours"), out maxSeconds) || minSeconds > maxSeconds)
                return Json(new Msg(0, "游玩时长须为0.1～720小时，最多一位小数，且最小值不能大于最大值。"));
            string enabled = (form.Q<string>("Enabled") ?? string.Empty).Trim();
            if (enabled != "0" && enabled != "1") return Json(new Msg(0, "请选择是否启用超时换人。"));
            string command = string.Format(CultureInfo.InvariantCulture, "PLAYTIME {0} {1} {2}", enabled, minSeconds, maxSeconds);
            return Json(new SConnect().SendRobotAction(command, "PLAYTIME_OK", "机器人游玩时长已保存，超时后随机等待1～5分钟由空闲机器人接替原座位。"));
        }

        private static bool TryPlayTimeSeconds(string raw, out int seconds)
        {
            seconds = 0;
            decimal hours;
            if (!decimal.TryParse((raw ?? string.Empty).Trim(), NumberStyles.AllowDecimalPoint, CultureInfo.InvariantCulture, out hours) ||
                hours < 0.1m || hours > 720m || decimal.Round(hours, 1) != hours) return false;
            seconds = (int)(hours * 3600m);
            return true;
        }

        private static string NormalizeScheduleTime(string raw)
        {
            TimeSpan value;
            if (!TimeSpan.TryParseExact((raw ?? string.Empty).Trim(), new[] { @"hh\:mm", @"h\:mm" },
                CultureInfo.InvariantCulture, out value) || value.TotalMinutes < 0 || value.TotalMinutes >= 1440)
                return null;
            return value.ToString(@"hh\:mm", CultureInfo.InvariantCulture);
        }

        private static string FormatScheduleMinute(int minute)
        {
            if (minute < 0 || minute >= 1440) minute = 0;
            return (minute / 60).ToString("00", CultureInfo.InvariantCulture) + ":" +
                   (minute % 60).ToString("00", CultureInfo.InvariantCulture);
        }

        private static int GetRobotSeatCapacity(int gameType, int configured)
        {
            if (gameType == 1 || gameType == 3) return 1;
            return configured <= 0 ? 6 : configured;
        }

        private static List<RobotSeatLiveRow> EnrichLiveRobotSeats(GameDbContext ef, JArray robots)
        {
            var users = ef.userRobots.ToList().ToDictionary(u => (long)u.ID, u => u);
            var games = ef.Games.ToList().ToDictionary(g => g.GameId, g => g);
            var tables = ef.Database.SqlQuery<RobotSeatOptionRow>(
                "SELECT GAME_ID,TableIndex,TableName,MaxSeats FROM roomtableconfig WHERE RoomIndex=0").ToList();
            var tableMap = tables.ToDictionary(t => t.GAME_ID + "_" + t.TableIndex, t => t);
            var ownerMap = new Dictionary<string, string>();
            if (LineTables.OwnerTableExists(ef))
            {
                ownerMap = ef.Database.SqlQuery<RobotOwnerLiveRow>(
                    "SELECT GAME_ID,TableIndex,IFNULL(LineAgent,'') AS LineAgent FROM roomtableowner").ToList()
                    .ToDictionary(r => r.GAME_ID + "_" + r.TableIndex, r => r.LineAgent ?? string.Empty);
            }
            var result = new List<RobotSeatLiveRow>();
            var liveIds = new HashSet<long>();
            foreach (JToken token in robots)
            {
                long id = (long?)token["id"] ?? 0;
                if (id > 0) liveIds.Add(id);
                M_UserRobot user;
                users.TryGetValue(id, out user);
                int gameId = (int?)token["game"] ?? 0;
                int tableId = (int?)token["table"] ?? -1;
                RobotSeatOptionRow table;
                tableMap.TryGetValue(gameId + "_" + tableId, out table);
                string gameName = games.ContainsKey(gameId)
                    ? GameDisplayNames.GetName(gameId, games[gameId].Name)
                    : Convert.ToString(token["game"]);
                string ownerKey = gameId + "_" + tableId;
                string line = ownerMap.ContainsKey(ownerKey) ? ownerMap[ownerKey] : string.Empty;
                result.Add(new RobotSeatLiveRow
                {
                    RobotId = id,
                    UserName = user == null ? Convert.ToString(token["name"]) : user.UserName,
                    UserNick = user == null ? (Convert.ToString(token["nick"]) ?? Convert.ToString(token["name"])) : user.UserNick,
                    Ico = user == null ? 0 : user.Ico,
                    Lev = user == null ? 0 : user.Lev,
                    Sex = user == null ? 0 : user.Sex,
                    Gold = user == null ? 0 : user.Gold,
                    GAME_NAME = gameName,
                    GAME_ID = gameId,
                    ROOM_ID = (int?)token["room"] ?? 0,
                    TABLE_ID = tableId,
                    TABLE_NAME = table == null || string.IsNullOrWhiteSpace(table.TableName) ? "桌台" + tableId : table.TableName,
                    LINE_AGENT = line,
                    SeatIndex = (int?)token["seat"] ?? -1,
                    PlanGameId = (int?)token["planGame"] ?? gameId,
                    PlanRoomId = (int?)token["planRoom"] ?? ((int?)token["room"] ?? 0),
                    PlanTableId = (int?)token["planTable"] ?? tableId,
                    PlanSeatIndex = (int?)token["planSeat"] ?? ((int?)token["seat"] ?? -1),
                    Forced = (bool?)token["forced"] ?? false,
                    Status = ((bool?)token["sitting"] ?? false) ? "已入座" : "未入座",
                    Connected = (bool?)token["connected"] ?? false,
                    Sitting = (bool?)token["sitting"] ?? false
                });
            }
            // STATUS only contains accounts currently loaded by ServerRobot. Include
            // the remaining userrobot rows as offline entries so one page can manage
            // every account and offer the ONLINE action for accounts outside the pool.
            foreach (var user in users.Values)
            {
                if (liveIds.Contains((long)user.ID)) continue;
                result.Add(new RobotSeatLiveRow
                {
                    RobotId = user.ID,
                    UserName = user.UserName,
                    UserNick = user.UserNick,
                    Ico = user.Ico,
                    Lev = user.Lev,
                    Sex = user.Sex,
                    Gold = user.Gold,
                    GAME_NAME = "",
                    GAME_ID = -1,
                    ROOM_ID = -1,
                    TABLE_ID = -1,
                    TABLE_NAME = "",
                    LINE_AGENT = "",
                    SeatIndex = -1,
                    PlanGameId = -1,
                    PlanRoomId = -1,
                    PlanTableId = -1,
                    PlanSeatIndex = -1,
                    Forced = false,
                    Status = "未上线",
                    Connected = false,
                    Sitting = false
                });
            }
            return result;
        }

        private sealed class RobotSeatLiveRow
        {
            public long RobotId { get; set; }
            public string UserName { get; set; }
            public string UserNick { get; set; }
            public int Ico { get; set; }
            public int Lev { get; set; }
            public int Sex { get; set; }
            public int Gold { get; set; }
            public string GAME_NAME { get; set; }
            public int GAME_ID { get; set; }
            public int ROOM_ID { get; set; }
            public int TABLE_ID { get; set; }
            public string TABLE_NAME { get; set; }
            public string LINE_AGENT { get; set; }
            public int SeatIndex { get; set; }
            public int PlanGameId { get; set; }
            public int PlanRoomId { get; set; }
            public int PlanTableId { get; set; }
            public int PlanSeatIndex { get; set; }
            public bool Forced { get; set; }
            public string Status { get; set; }
            public bool Connected { get; set; }
            public bool Sitting { get; set; }
        }

        private class RobotSeatOptionRow
        {
            public int GAME_ID { get; set; }
            public int TableIndex { get; set; }
            public string TableName { get; set; }
            public int MaxSeats { get; set; }
        }

        private class RobotOwnerLiveRow
        {
            public int GAME_ID { get; set; }
            public int TableIndex { get; set; }
            public string LineAgent { get; set; }
        }

        // roomtableconfig 桌台选择行映射（机器人页桌台下拉用）
        public class BetTableSelRow
        {
            public int TableIndex { get; set; }
            public string TableName { get; set; }
        }

        /// <summary>
        /// 牌机/鱼机类房间参数(已废弃：机器人页桌台统一走 GetRobotTableList)
        /// </summary>
        /// <param name="form"></param>
        /// <returns></returns>
        [AjaxOnly]
        [HttpPost]
        public ActionResult GetParaRoom(FormCollection form)
        {
            M_ParaRoom user = new M_ParaRoom();
            try
            {
                int GameId = form.Q<int>("GameId");
                int RoomId = form.Q<int>("RoomId");
                string num = "";
                if (GameId > -1)
                    num = GameId.ToString();
                if (RoomId > -1)
                    num = GameId.ToString() + RoomId.ToString().PadLeft(3, '0');
                user = new B_CardGamePara().GetSingle(new M_ParaRoom { ID = Convert.ToInt32(num) });
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.RobotController), ex);
            }
            return Json(user);
        }

        [MemberAuthorize]
        [AjaxOnly]
        [HttpPost]
        public ActionResult GetRobot(FormCollection form)
        {
            try
            {
                int pageIndex = form.Q<int>("page", 1);
                int pageSize = form.Q<int>("rows", 10);
                int gameId = form.Q<int>("GameId", -1);
                string gameName = form.Q<string>("GameName");
                string lineFilter = form.Q<string>("LINE");
                using (var ef = new GameDbContext())
                {
                    var rows = BuildRobotSummaryRows(ef, gameName, lineFilter);
                    if (gameId >= 0) rows = rows.Where(r => r.GAME_ID == gameId).ToList();
                    int total = rows.Count;
                    var pageRows = rows.Skip(Math.Max(0, pageIndex - 1) * Math.Max(1, pageSize))
                        .Take(Math.Max(1, pageSize)).ToList();
                    return Json(new { rows = pageRows, total = total, footer = new object[0] });
                }
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.RobotController), ex);
            }
            return Json(new { rows = new object[0], total = 0, footer = new object[0] });
        }

        /// <summary>
        /// Deletes the complete quota group represented by one summary row.  The old
        /// table displayed one robot_seat row at a time; after aggregation, deleting
        /// only the first row would leave a misleading partial group behind.
        /// </summary>
        [MemberAuthorize]
        [AjaxOnly]
        [HttpPost]
        [SuperAdminAuthorize]
        public ActionResult DeleteRobotSummary(FormCollection form)
        {
            int gameId = form.Q<int>("GameId", -1);
            string line = NormalizeLine(form.Q<string>("Line"));
            if (gameId <= 0)
                return Json(new Msg(0, "请选择有效的游戏。"));
            try
            {
                using (var ef = new GameDbContext())
                using (var tx = ef.Database.BeginTransaction())
                {
                    var game = ef.Games.SingleOrDefault(g => g.GameId == gameId && g.Enable == 1 && g.GameId != 54);
                    if (game == null)
                        return Json(new Msg(0, "游戏未开放或不支持机器人。"));
                    Dictionary<int, string> owners = LineTables.GetOwners(ef, gameId);
                    var rows = ef.Robots.Where(r => r.GAME_ID == gameId).ToList()
                        .Where(r => LineScopeRules.TableBelongsTo(owners, r.TABLE_ID, line)).ToList();
                    if (rows.Count == 0)
                        return Json(new Msg(1, "该游戏和代理线没有机器人配置。"));
                    ef.Robots.RemoveRange(rows);
                    ef.SaveChanges();
                    tx.Commit();
                    Msg msg = new Msg(1, "已清零该游戏/代理线的机器人配置。");
                    RobotReloadAfterChange(ref msg, "已清零机器人配置");
                    return Json(msg);
                }
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.RobotController), ex);
                return Json(new Msg(0, "清零机器人配置失败：" + ex.Message));
            }
        }

        private static List<RobotSummaryRow> BuildRobotSummaryRows(GameDbContext ef, string gameName, string lineFilter)
        {
            var games = ef.Games.Where(g => g.Enable == 1 && g.GameId != 54).ToList()
                .ToDictionary(g => g.GameId, g => g);
            string normalizedLine = NormalizeLine(lineFilter);
            bool filterLine = !string.IsNullOrWhiteSpace(lineFilter) && lineFilter != "*";
            var enabledTables = ef.Database.SqlQuery<RobotSummaryTableRow>(
                "SELECT GAME_ID, TableIndex, MaxSeats FROM roomtableconfig WHERE RoomIndex=0 AND Enabled=1").ToList()
                .GroupBy(t => t.GAME_ID + "_" + t.TableIndex)
                .Select(g => g.First()).ToList();
            var ownersByGame = new Dictionary<int, Dictionary<int, string>>();
            foreach (int gameId in games.Keys)
                ownersByGame[gameId] = LineTables.GetOwners(ef, gameId);

            // The second number in the summary is a live seat count, not the
            // configured quota. Keep the value unavailable when ServerRobot
            // cannot answer so the UI does not turn a communication failure into
            // a misleading zero.
            bool liveStatusAvailable = false;
            List<RobotSeatLiveRow> liveSeats = new List<RobotSeatLiveRow>();
            try
            {
                Msg status = new SConnect().SendRobotStatus();
                if (status.code == 1)
                {
                    JObject payload = status.datas as JObject ?? JObject.Parse(Convert.ToString(status.datas));
                    liveSeats = EnrichLiveRobotSeats(ef, payload["robots"] as JArray ?? new JArray())
                        .Where(r => r.Sitting).ToList();
                    liveStatusAvailable = true;
                }
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(RobotController), ex);
            }

            var groups = new Dictionary<string, RobotSummaryAccumulator>(StringComparer.OrdinalIgnoreCase);
            foreach (var robot in ef.Robots.ToList())
            {
                M_Games game;
                if (!games.TryGetValue(robot.GAME_ID, out game)) continue;
                Dictionary<int, string> owners = ownersByGame[robot.GAME_ID];
                string line;
                string owner;
                line = owners.TryGetValue(robot.TABLE_ID, out owner) ? (owner ?? string.Empty) : string.Empty;
                if (filterLine && !string.Equals(line, normalizedLine, StringComparison.OrdinalIgnoreCase)) continue;
                string displayName = GameDisplayNames.GetName(game.GameId, game.Name);
                if (!string.IsNullOrWhiteSpace(gameName) &&
                    displayName.IndexOf(gameName.Trim(), StringComparison.OrdinalIgnoreCase) < 0 &&
                    (game.Name ?? string.Empty).IndexOf(gameName.Trim(), StringComparison.OrdinalIgnoreCase) < 0) continue;
                string key = game.GameId + "|" + line;
                RobotSummaryAccumulator item;
                if (!groups.TryGetValue(key, out item))
                {
                    item = new RobotSummaryAccumulator
                    {
                        GameId = game.GameId,
                        GameType = game.GameType,
                        GameName = displayName,
                        LineAgent = line,
                        RobotCount = 0
                    };
                    groups.Add(key, item);
                }
                item.RobotCount += Math.Max(0, robot.ROBOT_NO);
            }

            var result = new List<RobotSummaryRow>();
            foreach (RobotSummaryAccumulator item in groups.Values)
            {
                Dictionary<int, string> owners = ownersByGame[item.GameId];
                M_Games summaryGame = games[item.GameId];
                int totalTables = enabledTables.Count(t => t.GAME_ID == item.GameId &&
                    LineScopeRules.TableBelongsTo(owners, t.TableIndex, item.LineAgent));
                int totalSeats = enabledTables.Where(t => t.GAME_ID == item.GameId &&
                    LineScopeRules.TableBelongsTo(owners, t.TableIndex, item.LineAgent))
                    .Sum(t => GetRobotSeatCapacity(summaryGame.GameType, t.MaxSeats));
                int actualRobotCount = -1;
                if (liveStatusAvailable)
                {
                    actualRobotCount = liveSeats.Count(r => r.GAME_ID == item.GameId &&
                        string.Equals(r.LINE_AGENT ?? string.Empty, item.LineAgent ?? string.Empty,
                            StringComparison.OrdinalIgnoreCase));
                }
                result.Add(new RobotSummaryRow
                {
                    ID = 0,
                    GAME_ID = item.GameId,
                    GAME_TYPE = item.GameType,
                    GAME_NAME = item.GameName,
                    LINE_AGENT = item.LineAgent,
                    TOTAL_TABLES = totalTables,
                    TOTAL_SEATS = totalSeats,
                    ROBOT_COUNT = actualRobotCount,
                    ROBOT_NO = actualRobotCount,
                    CONFIGURED_ROBOT_COUNT = item.RobotCount,
                    TABLE_ID = -1
                });
            }
            return result.OrderByDescending(r => r.GAME_ID).ThenBy(r => r.LINE_AGENT).ToList();
        }

        private sealed class RobotSummaryAccumulator
        {
            public int GameId { get; set; }
            public int GameType { get; set; }
            public string GameName { get; set; }
            public string LineAgent { get; set; }
            public int RobotCount { get; set; }
        }

        private sealed class RobotSummaryTableRow
        {
            public int GAME_ID { get; set; }
            public int TableIndex { get; set; }
            public int MaxSeats { get; set; }
        }

        private sealed class RobotSummaryRow
        {
            public long ID { get; set; }
            public int GAME_ID { get; set; }
            public int GAME_TYPE { get; set; }
            public string GAME_NAME { get; set; }
            public string LINE_AGENT { get; set; }
            public int TOTAL_TABLES { get; set; }
            public int TOTAL_SEATS { get; set; }
            public int ROBOT_COUNT { get; set; }
            public int ROBOT_NO { get; set; }
            public int CONFIGURED_ROBOT_COUNT { get; set; }
            public int TABLE_ID { get; set; }
        }

        /// <summary>
        /// Batch-creates userrobot accounts for the merged robot management
        /// page. The account name remains a numeric login identifier (matching
        /// the existing robot protocol); the nickname is a unique random
        /// Chinese name from two to eight characters.
        /// </summary>
        [MemberAuthorize]
        [AjaxOnly]
        [HttpPost]
        [SuperAdminAuthorize]
        public ActionResult BatchCreateRobotAccounts(FormCollection form)
        {
            try
            {
                int count = form.Q<int>("Num", form.Q<int>("Count"));
                int ico = form.Q<int>("Ico", 0);
                int lev = form.Q<int>("Lev", 1);
                int sex = form.Q<int>("Sex", 0);
                int gold = form.Q<int>("Gold", 100000);
                if (count <= 0 || count > 1000)
                    return Json(new { code = 0, content = "批量创建数量须为1~1000。", count = 0 });
                if (lev <= 0)
                    return Json(new { code = 0, content = "最小等级为1！", count = 0 });
                if (gold <= 0)
                    return Json(new { code = 0, content = "钻不能小于等于0！", count = 0 });
                if (sex != 0 && sex != 1) sex = 0;

                var accounts = new List<M_UserRobot>(count);
                var usedAccounts = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
                var usedNames = new HashSet<string>(StringComparer.Ordinal);
                using (var ef = new GameDbContext())
                {
                    foreach (var row in ef.userRobots.Select(r => new { r.UserName, r.UserNick }).ToList())
                    {
                        if (!string.IsNullOrWhiteSpace(row.UserName)) usedAccounts.Add(row.UserName);
                        if (!string.IsNullOrWhiteSpace(row.UserNick)) usedNames.Add(row.UserNick);
                    }
                }
                for (int i = 0; i < count; i++)
                {
                    string userName = NextRobotAccountName(usedAccounts);
                    string nick = NextChineseRobotName(usedNames);
                    accounts.Add(new M_UserRobot
                    {
                        PassW = "123456654321",
                        UserName = userName,
                        UserNick = nick,
                        Ico = ico,
                        Lev = lev,
                        Sex = sex,
                        Gold = gold
                    });
                }

                Msg msg = new B_UserRobot().AddRobots(accounts);
                if (msg.code != 1)
                    return Json(new { code = msg.code, content = msg.content, count = 0 });
                RobotReloadAfterChange(ref msg, "机器人账户创建成功，共" + accounts.Count + "个");
                return Json(new
                {
                    code = msg.code,
                    content = msg.content,
                    count = msg.code == 1 ? accounts.Count : 0,
                    names = accounts.Select(a => a.UserNick).ToList(),
                    accounts = accounts.Select(a => new { UserName = a.UserName, UserNick = a.UserNick }).ToList()
                });
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(RobotController), ex);
                return Json(new { code = 0, content = "机器人账户批量创建失败。", count = 0 });
            }
        }

        /// <summary>Batch-deletes account rows selected in the merged table.</summary>
        [MemberAuthorize]
        [AjaxOnly]
        [HttpPost]
        [SuperAdminAuthorize]
        public ActionResult BatchDeleteRobotAccounts(FormCollection form)
        {
            try
            {
                string raw = form.Q<string>("Ids");
                if (string.IsNullOrWhiteSpace(raw)) raw = form.Q<string>("ids");
                if (string.IsNullOrWhiteSpace(raw)) raw = form.Q<string>("ID");
                var ids = (raw ?? string.Empty).Split(new[] { ',', ';', ' ', '\r', '\n', '\t' }, StringSplitOptions.RemoveEmptyEntries)
                    .Select(s => { long id; return long.TryParse(s, out id) ? id : 0L; })
                    .Where(id => id > 0).Distinct().ToList();
                if (ids.Count == 0)
                    return Json(new { code = 0, content = "请选择要删除的机器人账户。", count = 0 });

                int deleted = new B_UserRobot().DelRobots(ids);
                if (deleted <= 0)
                    return Json(new { code = 0, content = "未找到可删除的机器人账户。", count = 0 });
                Msg msg = new Msg(1, "机器人账户删除成功，共" + deleted + "个");
                RobotReloadAfterChange(ref msg, "机器人账户删除成功，共" + deleted + "个");
                return Json(new { code = msg.code, content = msg.content, count = msg.code == 1 ? deleted : 0 });
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(RobotController), ex);
                return Json(new { code = 0, content = "机器人账户批量删除失败。", count = 0 });
            }
        }

        private static string NextRobotAccountName(HashSet<string> used)
        {
            for (int attempt = 0; attempt < 10000; attempt++)
            {
                int value;
                lock (RobotNameRandomLock) value = RobotNameRandom.Next(100000, 1000000);
                string account = value.ToString(CultureInfo.InvariantCulture);
                if (used.Add(account)) return account;
            }
            throw new InvalidOperationException("无法生成唯一的机器人账户编号。");
        }

        private static string NextChineseRobotName(HashSet<string> used)
        {
            for (int attempt = 0; attempt < 10000; attempt++)
            {
                int length;
                var chars = new char[8];
                lock (RobotNameRandomLock)
                {
                    length = RobotNameRandom.Next(2, 9);
                    int offset = 0;
                    while (offset < length)
                    {
                        string part = RobotNamePool[RobotNameRandom.Next(0, RobotNamePool.Length)];
                        int take = Math.Min(part.Length, length - offset);
                        for (int i = 0; i < take; i++) chars[offset + i] = part[i];
                        offset += take;
                    }
                }
                string name = new string(chars, 0, length);
                if (RobotNameLibrary.Length > 0 && name.All(ch => ch >= '\u4e00' && ch <= '\u9fff') && used.Add(name)) return name;
            }
            throw new InvalidOperationException("名字库无法生成唯一的机器人昵称。");
        }

        [MemberAuthorize]
        [AjaxOnly]
        [HttpPost]
        [SuperAdminAuthorize]
        public ActionResult SaveRobot(FormCollection form)
        {
            Msg msg = new Msg(0, "机器人添加失败！");
            try
            {
                int GameType = form.Q<int>("GameType");
                int GameId = form.Q<int>("GameId");
                int TABLE_ID = form.Q<int>("TABLE_ID");
                int RobotNo = form.Q<int>("RobotNo");
                // 玩家/机器人已锁定只能进入第一房间：ROOM_ID 恒为 0(押注类一房N桌亦为0)
                int RoomId = 0;
                if (GameType == -1)
                {
                    msg.content = "请选择游戏类型！";
                    return Json(msg);
                }
                if (GameId == -1)
                {
                    msg.content = "请选择游戏！";
                    return Json(msg);
                }
                // 代理线：桌子必须属于所选代理线（公共桌台 = 没有归属记录的桌；已收回的桌不能加机器人）
                string line = NormalizeLine(form.Q<string>("Line"));
                M_Games game = new B_Games().GetSingle(new M_Games { GameId = GameId });
                if (game == null || game.Enable != 1 || game.GameType != GameType)
                    return Json(new Msg(0, "游戏或游戏类型无效，请重新选择！"));
                if (B_Robot.IsMachineRobotGame(GameId, game.GameType))
                {
                    // 牌机/拉霸：RobotNo 是本线要设置的机器人总数（0~启用机台数），不是增量
                    msg = new B_Robot().SetCardRobots(GameId, RobotNo, line);
                    if (msg.code == 1) RobotReloadAfterChange(ref msg, "机器人已保存");
                    return Json(msg);
                }
                using (var ef = new GameDbContext())
                {
                    Dictionary<int, string> owners = LineTables.GetOwners(ef, GameId);
                    if (!LineScopeRules.TableBelongsTo(owners, TABLE_ID, line))
                    {
                        msg.content = string.IsNullOrEmpty(line)
                            ? "所选桌子不是公共桌台，请重新选择代理线和桌子！"
                            : "所选桌子不属于代理线 " + line + "，请重新选择！";
                        return Json(msg);
                    }
                }
                string GameName = "";
                // 押注类单房间固定"默认场"；鱼机/牌机锁定第一房间"初级场"。
                string RoomName = GameType == 0 ? "默认场" : "初级场";
                if (game != null)
                {
                    GameName = game.Name;
                }
                M_Robot entity = new M_Robot
                {
                    GAME_TYPE = GameType,
                    GAME_ID = GameId,
                    ROOM_ID = RoomId,
                    GAME_NAME = GameName,
                    ROOM_NAME = RoomName,
                    TABLE_ID = TABLE_ID,
                    ROBOT_NO = RobotNo,
                };
                msg = new B_Robot().AddRobot(entity);
                if (msg.code == 1)
                {
                    RobotReloadAfterChange(ref msg, "机器人已保存");
                }
            }
            catch (Exception ex)
            {
                msg.content = "机器人添加失败。";
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.RobotController), ex);
            }
            return Json(msg);
        }

        [MemberAuthorize]
        [AjaxOnly]
        [HttpPost]
        [SuperAdminAuthorize]
        public ActionResult DelRobot(FormCollection form)
        {
            Msg msg = new Msg(0, "删除失败！");
            try
            {
                string id = form.Q<string>("ID");
                if (!string.IsNullOrWhiteSpace(id))
                {
                    M_Robot mRobot = new M_Robot { ID = Convert.ToInt32(id) };
                    int val = new B_Robot().DelRobot(mRobot);
                    if (val > 0)
                    {
                        msg.code = 1;
                        msg.content = "删除成功！";
                        RobotReloadAfterChange(ref msg, "机器人已删除");
                    }
                }
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.RobotController), ex);
            }
            return Json(msg);
        }

        [MemberAuthorize]
        [AjaxOnly]
        [HttpPost]
        [SuperAdminAuthorize]
        public ActionResult DelAllRobot(FormCollection form)
        {
            Msg msg = new Msg(0, "删除失败！");
            try
            {
                int val = new B_Robot().DelAllRobot();
                if (val >= 0)
                {
                    msg.code = 1;
                    msg.content = "删除成功！";
                    RobotReloadAfterChange(ref msg, "机器人已删除");
                }
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.RobotController), ex);
            }
            return Json(msg);
        }

        /// <summary>
        /// 机器人写库成功后推送 RT 热更命令(ServerRobot 免重启全量重载)，强校验：失败则明确报错。
        /// </summary>
        /// <param name="msg">写库结果(成功时 code=1)，热更失败时改为 code=0 并附原因</param>
        /// <param name="savedDesc">写库成功文案前缀，如"机器人已保存"</param>
        private void RobotReloadAfterChange(ref Msg msg, string savedDesc)
        {
            try
            {
                Msg rt = new SConnect().SendRobotReload();
                if (rt.code != 1)
                {
                    msg.code = 0;
                    msg.content = savedDesc + "，但服务端热更新失败：" + rt.content;
                }
            }
            catch (Exception ex)
            {
                msg.code = 0;
                msg.content = savedDesc + "，但服务端热更新失败：" + ex.Message;
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.RobotController), ex);
            }
        }

    }


}
