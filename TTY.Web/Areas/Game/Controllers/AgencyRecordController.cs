using System;
using System.Collections.Generic;
using System.Text.RegularExpressions;
using System.Web.Mvc;
using YYT.BLL.EF;
using YYT.Common;
using YYT.Entity;
using YYT.Web.Controllers;

namespace YYT.Web.Areas.Game.Controllers
{
    [MemberAuthorize]
    public class AgencyRecordController : BaseController
    {
        // GET: Game/AgencyRecord
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
                int result = new B_Records_MySQL().ClearAgencyRecords(loginUser);
                if (result > 0)
                    return Json(new { code = 1, msg = "清理成功" });
                return Json(new { code = 0, msg = "清理失败" });
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(AgencyRecordController), ex);
                return Json(new { code = 0, msg = "操作异常" });
            }
        }

        [AjaxOnly]
        [HttpPost]
        public ActionResult GetAgencyRecords(FormCollection form)
        {
            M_EasyuiGridData<M_AgencyOptLog> list = new M_EasyuiGridData<M_AgencyOptLog>();
            try
            {
                string id = form.Q<string>("ID");
                string agency = form.Q<string>("AGENCY");
                int opt = form.Q<int>("OPT");
                DateTime date = form.Q<DateTime>("TIME", DateTime.Now);
                // 可选结束日期：手机流水页支持日期区间（同一天时与 TIME 一致，兼容桌面只传 TIME）
                DateTime endDate = form.Q<DateTime>("END", date);
                int pageIndex = form.Q<int>("page", 1);
                int pageSize = form.Q<int>("rows", 10);
                int week = date.WeekOfYear(System.Globalization.CalendarWeekRule.FirstDay, DayOfWeek.Monday);
                // 手机端「代理流水」只要资金变动记录；桌面「代理记录」不传，保持原有全量口径
                bool moneyOnly = form.Q<int>("MONEY_ONLY") == 1;

                M_LoginUser loginUser = WebHelper.GetLoginInfo();
                if (loginUser != null)
                {
                    M_Page mPage = new M_Page(pageIndex, pageSize);
                    M_S_Record entity = new M_S_Record { S_TIME = date, ID = id, E_TIME = endDate, WEEK = week, AGENCY = agency, OPT = opt, MONEY_ONLY = moneyOnly};
                    list = new B_Records_MySQL().Get_AgencyRecords(loginUser, mPage, entity);
                }
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.UserRecordController), ex);
            }

            return Json(list);
        }
    }
}
