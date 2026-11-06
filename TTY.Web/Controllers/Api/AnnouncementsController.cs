using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Web.Http;
using YYT.BLL.EF;
using YYT.BLL.Services.GameServer;
using YYT.Common;

namespace YYT.Web.Controllers.Api
{
    [RoutePrefix("api/Announcements")]
    public class AnnouncementsController : ApiController
    {
        readonly Func<int, List<OnlinePlayerInfo>> mOnlinePlayers;

        public AnnouncementsController() : this(game => new PipeGameServerClient().QueryAnnouncementOccupants(game)) { }

        public AnnouncementsController(Func<int, List<OnlinePlayerInfo>> onlinePlayers)
        {
            mOnlinePlayers = onlinePlayers ?? throw new ArgumentNullException(nameof(onlinePlayers));
        }
        public sealed class ValidateRequest
        {
            public string Account { get; set; }
            public string Content { get; set; }
        }

        /// <summary>每条大奖在出队播放前查询；仅返回是否播放和正文，不返回玩家、座位或控制信息。</summary>
        [HttpPost, Route("Validate")]
        public IHttpActionResult Validate([FromBody] ValidateRequest request)
        {
            var decision = new AnnouncementRules.Decision { Content = "" };
            if (request == null || string.IsNullOrWhiteSpace(request.Account) || string.IsNullOrEmpty(request.Content)
                || request.Account.Length > 100 || request.Content.Length > 1024) return Reply(decision);
            try
            {
                using (var db = new GameDbContext())
                {
                    string account = request.Account.Trim();
                    if (!db.Users.AsNoTracking().Any(u => u.ID == account)) return Reply(decision);
                    string line = LineScopeRules.ResolveLineOfPlayer(db, account);
                    // 只查最近五分钟的已提交大奖；前缀比较兼容传输端截断，随后按实际 UTF-8 正文严格匹配。
                    var rows = db.Database.SqlQuery<AnnouncementRules.Record>(
                        "SELECT p.GameId,p.GameType,p.RoomId,p.TableId,IFNULL(p.LineAgent,'') AS LineAgent," +
                        "o.BroadcastText AS Text,TIMESTAMPDIFF(SECOND,o.CreatedAt,NOW()) AS AgeSeconds," +
                        "IF(p.IsManualControl=2 OR EXISTS(SELECT 1 FROM userrobot r WHERE BINARY r.UserName=BINARY p.UserID),1,0) AS IsRobot " +
                        "FROM prizebroadcastoutbox o INNER JOIN gameprizerecord p ON p.EventId=o.EventId AND p.GameId=o.GameId " +
                        "INNER JOIN games g ON g.GameId=p.GameId AND g.Enable=1 " +
                        "WHERE o.CreatedAt>=DATE_SUB(NOW(),INTERVAL 300 SECOND) AND p.IsBroadcast=1 " +
                        "AND BINARY LEFT(o.BroadcastText,CHAR_LENGTH(@p0))=BINARY @p0 ORDER BY o.ID DESC LIMIT 2", request.Content).ToList();
                    var record = rows.FirstOrDefault(r => string.Equals(AnnouncementRules.WireText(r.Text), request.Content, StringComparison.Ordinal));
                    var playable = LineScopeRules.GetLinePlayableGames(db, line);
                    if (record == null || (playable != null && !playable.Contains(record.GameId))) return Reply(decision);
                    var tables = TableDisplayMap.Load(db, new[] { record.GameId });
                    var players = record.IsRobot != 0 ? mOnlinePlayers(record.GameId) : null;
                    decision = AnnouncementRules.Check(record, tables, line, players);
                }
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(AnnouncementsController), ex);
            }
            return Reply(decision);
        }

        IHttpActionResult Reply(AnnouncementRules.Decision decision)
        {
            var response = Request.CreateResponse(HttpStatusCode.OK, decision);
            response.Headers.CacheControl = new CacheControlHeaderValue { NoStore = true, NoCache = true, MustRevalidate = true };
            return ResponseMessage(response);
        }
    }
}
