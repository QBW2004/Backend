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
        /// 大厅中奖历史：所有真人和机器人共用时间序列，游戏关闭后连同历史一起隐藏。
        /// 仅返回展示字段，不能把中奖日志里的玩家账号、控牌信息等直接暴露给客户端。
        /// </summary>
        [HttpGet, Route("History")]
        public IHttpActionResult History(int gameId = 0)
        {
            if (gameId < 0) return BadRequest("游戏编号无效");
            try
            {
                using (var ef = new GameDbContext())
                {
                    var games = ef.Games.AsNoTracking().Where(g => g.Enable == 1)
                        .OrderBy(g => g.GameId).Select(g => new { g.GameId, g.Name }).ToList();
                    var enabledIds = games.Select(g => g.GameId).ToList();
                    // 独立的 30 槽记录不受后台明细七天清理影响。开关在查询内过滤，
                    // 同秒按环形写入时更新的 ID 排序；游戏编号使用参数绑定。
                    var records = ef.Database.SqlQuery<HistoryRow>(
                        "SELECT h.GameId,h.UserID,h.CardType,h.Score,h.RecTime FROM gamerankhistory h " +
                        "INNER JOIN games g ON g.GameId=h.GameId AND g.Enable=1 " +
                        "WHERE h.Score>0 AND (@p0=0 OR h.GameId=@p0) " +
                        "ORDER BY h.RecTime DESC,h.ID DESC LIMIT 30", gameId)
                        .ToList().Where(r => enabledIds.Contains(r.GameId)).ToList();
                    var userIds = records.Select(r => r.UserID).Distinct().ToList();
                    var players = ef.Users.AsNoTracking().Where(u => userIds.Contains(u.ID))
                        .Select(u => new { u.ID, u.NAME }).ToDictionary(u => u.ID, u => u.NAME);
                    var robots = ef.userRobots.AsNoTracking().Where(u => userIds.Contains(u.UserName))
                        .Select(u => new { u.UserName, u.UserNick }).ToList()
                        .GroupBy(u => u.UserName).ToDictionary(g => g.Key, g => g.First().UserNick);
                    var names = games.ToDictionary(g => g.GameId, g => g.Name);
                    var rows = records.Select(r => new
                    {
                        r.GameId,
                        GameName = names[r.GameId],
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

        public class HistoryRow
        {
            public int GameId { get; set; }
            public string UserID { get; set; }
            public string CardType { get; set; }
            public long Score { get; set; }
            public DateTime RecTime { get; set; }
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
