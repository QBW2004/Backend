using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Cryptography;
using System.Text.RegularExpressions;
using System.Web.Mvc;
using YYT.BLL.EF;
using YYT.Common;
using YYT.Entity;
using YYT.Web;
using YYT.Web.Controllers;

namespace YYT.Web.Areas.Game.Controllers
{
    [MemberAuthorize]
    public class UserRecordController : BaseController
    {
        // GET: Game/UserRecord
        public ActionResult Index()
        {
            return View();
        }

        [AjaxOnly]
        [HttpPost]
        public ActionResult ClearRecords()
        {
            M_LoginUser loginUser = WebHelper.GetLoginInfo();
            if (loginUser == null || loginUser.UserPriv != 0)
                return Json(new { code = 0, msg = "无权限" });
            try
            {
                int result = new B_Records_MySQL().ClearPlayerRecords(loginUser);
                if (result > 0)
                    return Json(new { code = 1, msg = "清理成功" });
                return Json(new { code = 0, msg = "清理失败" });
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(UserRecordController), ex);
                return Json(new { code = 0, msg = "操作异常" });
            }
        }

        [AjaxOnly]
        [HttpPost]
        public ActionResult GetUserRecords(FormCollection form)
        {

            object list = new M_EasyuiGridData<object>();
            try
            {
                string id = form.Q<string>("ID");
                DateTime date = form.Q<DateTime>("TIME", DateTime.Now);
                int pageIndex = form.Q<int>("page", 1);
                int pageSize = form.Q<int>("rows", 10);
                int week = date.WeekOfYear(System.Globalization.CalendarWeekRule.FirstDay, DayOfWeek.Monday);

                M_LoginUser loginUser = WebHelper.GetLoginInfo();
                if (loginUser != null)
                {
                    M_Page mPage = new M_Page(pageIndex, pageSize);
                    M_S_Record entity = new M_S_Record { S_TIME = date, ID = id, E_TIME = date, WEEK = week };
                    list = new B_Records_MySQL().Get_PlayerRecords(loginUser, mPage, entity);
                }
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.UserRecordController), ex);
            }

            return Json(list);
        }

        /// <summary>
        /// 手机端独立中奖历史：牌机展示开奖记录；鱼机/拉霸仅展示触发中奖播报的高倍率记录。
        /// IsManualControl=1 表示该奖项由手动控牌牌型送出。
        /// </summary>
        [AjaxOnly]
        [HttpPost]
        public ActionResult GetPrizeHistory(FormCollection form)
        {
            M_EasyuiGridData<M_GamePrizeRecord> list = new M_EasyuiGridData<M_GamePrizeRecord>();
            List<object> gameMeta = new List<object>();
            try
            {
                M_LoginUser loginUser = WebHelper.GetLoginInfo();
                string userId = form.Q<string>("ID");
                if (loginUser == null || string.IsNullOrWhiteSpace(userId))
                    return Json(list);

                int page = Math.Max(1, form.Q<int>("page", 1));
                int rows = Math.Max(1, Math.Min(100, form.Q<int>("rows", 20)));
                DateTime start = form.Q<DateTime>("StartTime", DateTime.Today.AddDays(-30)).Date;
                DateTime end = form.Q<DateTime>("EndTime", DateTime.Today).Date.AddDays(1);

                using (var ef = new GameDbContext())
                {
                    M_Users user = ef.Users.FirstOrDefault(u => u.ID == userId.Trim());
                    if (user == null)
                        return Json(list);
                    if (loginUser.UserPriv != 0)
                    {
                        List<string> managed = new B_Admin().GetManagedAgencyAccounts(ef, loginUser);
                        if (!managed.Contains(user.AGENCY))
                            return Json(list);
                    }

                    List<M_Games> games = ef.Games.Where(g => g.Enable == 1 && g.GameType != 0)
                        .OrderBy(g => g.GameType).ThenBy(g => g.GameId).ToList();
                    gameMeta = games.Select(g => (object)new { GameId = g.GameId, Name = g.Name, GameType = g.GameType }).ToList();
                    List<int> gameIds = games.Select(g => g.GameId).ToList();
                    List<int> cardGameIds = games.Where(g => g.GameType == 1).Select(g => g.GameId).ToList();
                    IQueryable<M_GamePrizeRecord> query = ef.GamePrizeRecords
                        .Where(r => r.UserID == user.ID && gameIds.Contains(r.GameId)
                            && (cardGameIds.Contains(r.GameId) || r.IsBroadcast == 1)
                            && r.RecTime >= start && r.RecTime < end);
                    int total = query.Count();
                    List<M_GamePrizeRecord> result = query.OrderByDescending(r => r.RecTime)
                        .ThenByDescending(r => r.ID)
                        .Skip((page - 1) * rows).Take(rows).ToList();
                    Dictionary<int, string> names = games.ToDictionary(g => g.GameId, g => g.Name);
                    foreach (M_GamePrizeRecord item in result)
                        item.GameName = names.ContainsKey(item.GameId) ? names[item.GameId] : ("游戏" + item.GameId);
                    list.total = total;
                    list.rows = result;
                }
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(UserRecordController), ex);
            }
            return Json(new { total = list.total, rows = list.rows ?? new List<M_GamePrizeRecord>(), games = gameMeta });
        }


    }
}
