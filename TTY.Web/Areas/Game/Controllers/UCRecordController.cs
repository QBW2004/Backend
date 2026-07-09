using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using YYT.BLL.EF;
using YYT.Common;
using YYT.Entity;
using YYT.Remote;
using YYT.Web.Controllers;

namespace YYT.Web.Areas.Game.Controllers
{
    [MemberAuthorize]
    public class UCRecordController : BaseController
    {
        // GET: Game/UCRecord
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
                int result = new B_ManagerOpt().ClearRecords(loginUser);
                if (result > 0)
                    return Json(new { code = 1, msg = "清理成功" });
                return Json(new { code = 0, msg = "清理失败" });
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(UCRecordController), ex);
                return Json(new { code = 0, msg = "操作异常" });
            }
        }

        [AjaxOnly]
        [HttpPost]
        public ActionResult GetUCRecords(FormCollection form)
        {
            M_EasyuiGridData<View_ManagerOpt_DTO> list = new M_EasyuiGridData<View_ManagerOpt_DTO>();
            try
            {
                string id = form.Q<string>("ID");
                string agency = form.Q<string>("Agency");
                int pageIndex = form.Q<int>("page", 1);
                int pageSize = form.Q<int>("rows", 10);
                M_LoginUser loginUser = WebHelper.GetLoginInfo();
                if (loginUser == null)
                    return Json(list);

                M_Page mPage = new M_Page(pageIndex, pageSize);
                M_Users mUsers = new M_Users { ID = id, AGENCY = agency };

                list = new B_ManagerOpt().GetUsersListWithPermission(mPage, mUsers, loginUser);
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.UserInfoController), ex);
            }

            return Json(list);
        }

        [AjaxOnly]
        [HttpPost]
        public ActionResult CloseUserKill(FormCollection form)
        {
            Msg msg = new Msg(0, "关闭点杀失败！");
            try
            {
                string userId = form.Q<string>("UserID");
                M_LoginUser loginUser = WebHelper.GetLoginInfo();
                if (loginUser == null || string.IsNullOrWhiteSpace(userId))
                    return Json(msg);

                using (var ef = new GameDbContext())
                {
                    var user = ef.Users.FirstOrDefault(u => u.ID == userId);
                    if (user == null)
                    {
                        msg.content = "玩家不存在！";
                        return Json(msg);
                    }

                    if (loginUser.UserPriv > 0 && !new B_Admin().IsInAgencyLine(ef, loginUser.Accounts, user.AGENCY))
                    {
                        msg.content = "只能关闭自己代理线内玩家的点杀！";
                        return Json(msg);
                    }
                }

                var srv = new SConnect();
                srv.SendReadString(EScMsgType.UC, "01", "00", 0, userId);
                srv.SendReadString(EScMsgType.UC, "03", "00", 0, userId);
                new B_ManagerOpt().RemoveKillRecord(userId);
                msg.code = 1;
                msg.content = "关闭点杀成功！";
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(UCRecordController), ex);
            }
            return Json(msg);
        }
    }
}
