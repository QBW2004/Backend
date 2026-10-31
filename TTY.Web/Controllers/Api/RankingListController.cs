using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Web.Http;
using YYT.BLL.EF;
using YYT.Entity;
using YYT.Common;
using System.Globalization;

namespace YYT.Web.Controllers.Api
{
    [RoutePrefix("api/RankingList")]
    public class RankingListController : ApiController
    {
        /// <summary>
        /// 大厅中奖历史：仅展示已开放的牌机和拉霸，麻将胡了单独排除；真人和机器人共用时间序列。
        /// 玩家账号在服务端按鱼机规则匿名，只返回展示字段，不下发完整账号或控牌信息。
        /// </summary>
        [HttpGet, Route("History")]
        public IHttpActionResult History(int gameId = 0, string account = null)
        {
            if (gameId < 0) return BadRequest("游戏编号无效");
            try
            {
                using (var ef = new GameDbContext())
                {
                    // 新包带上玩家账号：只看本线与公共(LineAgent='')的记录，且只限本线可玩游戏；不带账号（老包）口径不变
                    bool scoped = !string.IsNullOrWhiteSpace(account);
                    string line = scoped ? LineScopeRules.ResolveLineOfPlayer(ef, account.Trim()) : string.Empty;
                    List<int> playable = scoped ? LineScopeRules.GetLinePlayableGames(ef, line) : null;
                    var games = ef.Games.AsNoTracking().Where(g => g.Enable == 1
                        && (g.GameType == 1 || g.GameType == 3) && g.GameId != 54)
                        .OrderBy(g => g.GameId).Select(g => new { g.GameId, g.Name, g.GameType }).ToList();
                    if (playable != null)
                        games = games.Where(g => playable.Contains(g.GameId)).ToList();
                    var enabledIds = games.Select(g => g.GameId).ToList();
                    // 分类与记录共用已过滤的整数编号，必须在 LIMIT 前过滤，避免隐藏游戏挤占最新 30 条。
                    string gamesSql = enabledIds.Count == 0 ? " AND 1=0"
                        : " AND h.GameId IN (" + string.Join(",", enabledIds) + ")";
                    // 独立的 30 槽记录不受后台明细七天清理影响；同秒按环形写入时更新的 ID 排序。
                    string scopeSql = !scoped ? string.Empty
                        : " AND (h.LineAgent='' OR h.LineAgent=@p1)";
                    var records = ef.Database.SqlQuery<HistoryRow>(
                        "SELECT h.GameId,h.UserID,h.CardType,h.Score,h.RecTime,p.RoomId,p.TableId FROM gamerankhistory h " +
                        "INNER JOIN games g ON g.GameId=h.GameId AND g.Enable=1 " +
                        "LEFT JOIN gameprizerecord p ON p.EventId=h.EventId AND p.GameId=h.GameId " +
                        "WHERE h.Score>0 AND (@p0=0 OR h.GameId=@p0)" + gamesSql + scopeSql + " " +
                        "ORDER BY h.RecTime DESC,h.ID DESC LIMIT 30", gameId, line)
                        .ToList().Where(r => enabledIds.Contains(r.GameId)).ToList();
                    var userIds = records.Select(r => r.UserID).Distinct().ToList();
                    var players = ef.Users.AsNoTracking().Where(u => userIds.Contains(u.ID))
                        .Select(u => new { u.ID, u.NAME }).ToDictionary(u => u.ID, u => u.NAME);
                    var robots = ef.userRobots.AsNoTracking().Where(u => userIds.Contains(u.UserName))
                        .Select(u => new { u.UserName, u.UserNick }).ToList()
                        .GroupBy(u => u.UserName).ToDictionary(g => g.Key, g => g.First().UserNick);
                    var names = games.ToDictionary(g => g.GameId, g => g.Name);
                    var types = games.ToDictionary(g => g.GameId, g => g.GameType);
                    var rows = records.Select(r => new
                    {
                        r.GameId,
                        GameName = names[r.GameId],
                        PlayerAccount = DisplayAccount(r.UserID),
                        Machine = DisplayMachine(types[r.GameId], r.RoomId, r.TableId),
                        Nickname = DisplayNickname(players.ContainsKey(r.UserID) ? players[r.UserID]
                            : robots.ContainsKey(r.UserID) ? robots[r.UserID] : null),
                        Prize = r.CardType ?? "中奖",
                        // 分数字符串避免客户端 JSON 转 double 丢失 Int64 精度。
                        Score = DisplayScore(r.GameId, r.Score),
                        Time = r.RecTime.ToString("yyyy-MM-dd HH:mm:ss", CultureInfo.InvariantCulture)
                    }).ToList();
                    var response = Request.CreateResponse(HttpStatusCode.OK, new { Games = games, Rows = rows, Limit = 30 });
                    response.Headers.CacheControl = new CacheControlHeaderValue { NoStore = true, NoCache = true, MustRevalidate = true };
                    return ResponseMessage(response);
                }
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(RankingListController), ex);
                return InternalServerError();
            }
        }

        public static string DisplayNickname(string nickname)
        {
            return string.IsNullOrWhiteSpace(nickname) ? "匿名玩家" : nickname;
        }

        /// <summary>
        /// 与客户端鱼机 PlayerNameFormatter 一致：按文字元素取前两位和后两位，中间固定两个点。
        /// </summary>
        public static string DisplayAccount(string account)
        {
            if (string.IsNullOrEmpty(account)) return "..";
            int[] indexes = StringInfo.ParseCombiningCharacters(account);
            int visible = Math.Min(2, indexes.Length);
            int prefixEnd = visible < indexes.Length ? indexes[visible] : account.Length;
            return account.Substring(0, prefixEnd) + ".." + account.Substring(indexes[indexes.Length - visible]);
        }

        public static string DisplayMachine(int gameType, long? roomId, long? tableId)
        {
            // 中奖记录：牌机/鱼机是 1 基桌台号，拉霸是 0 基下标；旧明细已清理时不能假造 1 号机。
            if (!tableId.HasValue || tableId.Value < 0 || tableId.Value == long.MaxValue) return "--";
            long number = gameType == 1 || gameType == 2 ? tableId.Value : tableId.Value + 1;
            if (number <= 0) return "--";
            string room = roomId.HasValue && roomId.Value > 0 && roomId.Value < long.MaxValue
                ? (roomId.Value + 1).ToString(CultureInfo.InvariantCulture) + "场·" : "";
            return room + number.ToString(CultureInfo.InvariantCulture) + "号机";
        }

        public class HistoryRow
        {
            public int GameId { get; set; }
            public string UserID { get; set; }
            public string CardType { get; set; }
            public long Score { get; set; }
            public DateTime RecTime { get; set; }
            public long? RoomId { get; set; }
            public long? TableId { get; set; }
        }

        public static string DisplayScore(int gameId, long score)
        {
            // 与后台中奖记录一致：0.1 分炮鱼机上报整数刻度，展示时还原为机台分。
            bool tenthPoint = gameId == 3 || gameId == 6 || gameId == 13 || gameId == 19
                || gameId == 21 || gameId == 22 || gameId == 32 || gameId == 33
                || gameId == 42 || gameId == 49 || gameId == 51;
            return (tenthPoint ? score / 10m : score).ToString("0.##########", CultureInfo.InvariantCulture);
        }

        /// <summary>
        /// 游戏类型
        /// </summary>
        /// <returns></returns>
        // GET: api/Games
        public IEnumerable<RankUsersList> Get()
        {
            List<RankUsersList> list = new List<RankUsersList>();
            try
            {
                list = new B_Users().GetRankingUserList();
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(RankingListController), ex);
            }
            return list;
        }
    }
}
