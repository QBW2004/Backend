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
        /// 大厅大奖历史：只展示游戏服同一次判定确认的大奖，真人和机器人共用时间序列。
        /// 玩家展示字段只返回完整昵称，旧 PlayerAccount 字段兼容同一昵称，不下发登录账号或控牌信息。
        /// </summary>
        [HttpGet, Route("History")]
        public IHttpActionResult History(int gameId = 0, string account = null)
        {
            if (gameId < 0) return BadRequest("游戏编号无效");
            if (string.IsNullOrWhiteSpace(account)) return BadRequest("请提供玩家账号");
            try
            {
                using (var ef = new GameDbContext())
                {
                    account = account.Trim();
                    if (!ef.Users.AsNoTracking().Any(u => u.ID == account)) return BadRequest("玩家账号不存在");
                    string line = LineScopeRules.ResolveLineOfPlayer(ef, account);
                    List<int> playable = LineScopeRules.GetLinePlayableGames(ef, line);
                    var games = ef.Games.AsNoTracking().Where(g => g.Enable == 1
                        && (g.GameType == 1 || g.GameType == 3) && g.GameId != 54)
                        .OrderBy(g => g.GameId).Select(g => new { g.GameId, g.Name, g.GameType }).ToList();
                    if (playable != null)
                        games = games.Where(g => playable.Contains(g.GameId)).ToList();
                    var enabledIds = games.Select(g => g.GameId).ToList();
                    var types = games.ToDictionary(g => g.GameId, g => g.GameType);
                    // 分类与记录共用已过滤的整数编号，必须在 LIMIT 前过滤，避免隐藏游戏挤占最新 30 条。
                    string gamesSql = enabledIds.Count == 0 ? " AND 1=0"
                        : " AND h.GameId IN (" + string.Join(",", enabledIds) + ")";
                    // 独立的 30 槽记录不受后台明细七天清理影响；同秒按环形写入时更新的 ID 排序。
                    var tableDisplay = TableDisplayMap.Load(ef, enabledIds);
                    string scopeSql = tableDisplay.HistoryVisibilitySql(line, types);
                    var records = ef.Database.SqlQuery<HistoryRow>(
                        "SELECT h.GameId,h.UserID,h.CardType,h.Score,h.RecTime,h.LineAgent," +
                        "COALESCE(h.RoomId,p.RoomId) AS RoomId,COALESCE(h.TableId,p.TableId) AS TableId FROM gamerankhistory h " +
                        "INNER JOIN games g ON g.GameId=h.GameId AND g.Enable=1 " +
                        "LEFT JOIN gameprizerecord p ON p.EventId=h.EventId AND p.GameId=h.GameId " +
                        "WHERE h.IsBigWin=1 AND h.Score>=0 AND (@p0=0 OR h.GameId=@p0)" + gamesSql + scopeSql + " " +
                        "ORDER BY h.RecTime DESC,h.ID DESC LIMIT 30", gameId, line)
                        .ToList().Where(r => enabledIds.Contains(r.GameId)).ToList();
                    var userIds = records.Select(r => r.UserID).Distinct().ToList();
                    var players = ef.Users.AsNoTracking().Where(u => userIds.Contains(u.ID))
                        .Select(u => new { u.ID, u.NAME }).ToDictionary(u => u.ID, u => u.NAME);
                    var robots = ef.userRobots.AsNoTracking().Where(u => userIds.Contains(u.UserName))
                        .Select(u => new { u.UserName, u.UserNick }).ToList()
                        .GroupBy(u => u.UserName).ToDictionary(g => g.Key, g => g.First().UserNick);
                    var names = games.ToDictionary(g => g.GameId, g => g.Name);
                    var rows = records.Select(r =>
                    {
                        string nickname = DisplayNickname(players.ContainsKey(r.UserID) ? players[r.UserID]
                            : robots.ContainsKey(r.UserID) ? robots[r.UserID] : null);
                        return new
                        {
                            r.GameId,
                            GameName = names[r.GameId],
                            // 旧包固定读此字段，继续回传完整名称，避免旧包显示账号。
                            PlayerAccount = nickname,
                            Machine = tableDisplay.HistoryMachine(r.GameId, types[r.GameId], r.RoomId, r.TableId, r.LineAgent),
                            Nickname = nickname,
                            Prize = r.CardType ?? "中奖",
                            // 分数字符串避免客户端 JSON 转 double 丢失 Int64 精度。
                            Score = DisplayScore(r.GameId, r.Score),
                            Time = r.RecTime.ToString("yyyy-MM-dd HH:mm:ss", CultureInfo.InvariantCulture)
                        };
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
            return string.IsNullOrWhiteSpace(nickname) ? "未知玩家" : nickname;
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
            public string LineAgent { get; set; }
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
