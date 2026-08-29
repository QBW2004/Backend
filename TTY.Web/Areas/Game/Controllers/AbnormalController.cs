using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.Mvc;
using YYT.BLL.EF;
using YYT.Common;
using YYT.Entity;
using YYT.Web.Controllers;

namespace YYT.Web.Areas.Game.Controllers
{
    /// <summary>
    /// 手机端：异常账号（查看和解封异常登录锁定的账号）
    /// 锁定来源：LoginMissRecord 连续登录失败 5 次及以上。
    /// </summary>
    [MemberAuthorize]
    public class AbnormalController : BaseController
    {
        /// <summary>
        /// 异常账号统计 + 列表（玩家账号 / 代理账号分类计数）
        /// </summary>
        [AjaxOnly]
        [HttpPost]
        public ActionResult GetAbnormalAccounts()
        {
            Msg msg = new Msg(0, "查询失败！");
            try
            {
                M_LoginUser loginUser = WebHelper.GetLoginInfo();
                if (loginUser == null)
                    return Json(msg);

                List<M_LoginMissRecord> records = new B_LoginMissRecord().GetAbnormalList();
                List<string> ids = records.Select(c => c.ID).Distinct().ToList();

                HashSet<string> adminIds;
                HashSet<string> userIds;
                using (var ef = new GameDbContext())
                {
                    adminIds = ef.Admins.Where(c => ids.Contains(c.ID)).Select(c => c.ID).ToHashSet(StringComparer.OrdinalIgnoreCase);
                    userIds = ef.Users.Where(c => ids.Contains(c.ID)).Select(c => c.ID).ToHashSet(StringComparer.OrdinalIgnoreCase);
                }

                var rows = records.Select(c => new
                {
                    ID = c.ID,
                    Type = adminIds.Contains(c.ID) ? "代理" : (userIds.Contains(c.ID) ? "玩家" : "未知"),
                    Reason = "连续登录失败 " + c.MissCount + " 次",
                    IP = c.IPAddr,
                    Time = c.LoginTime.ToString("yyyy-MM-dd HH:mm:ss")
                }).ToList();

                msg.code = 1;
                msg.content = "查询成功！";
                msg.datas = new
                {
                    playerCount = rows.Count(c => c.Type == "玩家"),
                    agencyCount = rows.Count(c => c.Type == "代理"),
                    rows = rows
                };
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.AbnormalController), ex);
            }
            return Json(msg);
        }

        /// <summary>
        /// 解封异常账号（清零失败计数，立即可重新登录）
        /// </summary>
        [AjaxOnly]
        [HttpPost]
        public ActionResult Unblock(FormCollection form)
        {
            Msg msg = new Msg(0, "解封失败！");
            try
            {
                M_LoginUser loginUser = WebHelper.GetLoginInfo();
                if (loginUser == null || loginUser.UserPriv != 0)
                {
                    msg.content = "无权限操作！";
                    return Json(msg);
                }

                string id = form.Q<string>("ID");
                if (string.IsNullOrWhiteSpace(id))
                {
                    msg.content = "账号不能为空！";
                    return Json(msg);
                }

                if (new B_LoginMissRecord().Unblock(id))
                {
                    msg.code = 1;
                    msg.content = "账号已成功解封";
                }
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.AbnormalController), ex);
            }
            return Json(msg);
        }
    }
}
