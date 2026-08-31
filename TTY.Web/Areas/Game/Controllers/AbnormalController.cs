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
        private sealed class FrozenAccountRow
        {
            public string ID { get; set; }
            public string Type { get; set; }
            public string Reason { get; set; }
            public string IP { get; set; }
            public string Time { get; set; }
        }

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
                List<FrozenAccountRow> rows = new List<FrozenAccountRow>();
                using (var ef = new GameDbContext())
                {
                    // 真实冻结状态：玩家 FROZEN=1，代理 RE_ENABLE=0。
                    rows.AddRange(ef.Users.Where(c => c.FROZEN == 1).Select(c => new FrozenAccountRow
                    {
                        ID = c.ID,
                        Type = "玩家",
                        Reason = "账号已冻结"
                    }).ToList());
                    rows.AddRange(ef.Admins.Where(c => c.RE_ENABLE == 0).Select(c => new FrozenAccountRow
                    {
                        ID = c.ID,
                        Type = "代理",
                        Reason = "账号已禁用"
                    }).ToList());
                }

                // 异常登录锁定也属于冻结明细；同一账号只保留一行并合并原因。
                foreach (M_LoginMissRecord record in records)
                {
                    FrozenAccountRow row = rows.FirstOrDefault(c => string.Equals(c.ID, record.ID, StringComparison.OrdinalIgnoreCase));
                    if (row == null)
                    {
                        row = new FrozenAccountRow
                        {
                            ID = record.ID,
                            Type = "未知",
                            Reason = string.Empty
                        };
                        rows.Add(row);
                    }
                    row.Reason = string.IsNullOrWhiteSpace(row.Reason)
                        ? "连续登录失败 " + record.MissCount + " 次"
                        : row.Reason + "；连续登录失败 " + record.MissCount + " 次";
                    row.IP = record.IPAddr;
                    row.Time = record.LoginTime.ToString("yyyy-MM-dd HH:mm:ss");
                }

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

                bool changed = new B_LoginMissRecord().Unblock(id);
                using (var ef = new GameDbContext())
                {
                    var user = ef.Users.FirstOrDefault(c => c.ID.Equals(id));
                    if (user != null && user.FROZEN == 1)
                    {
                        user.FROZEN = 0;
                        changed = true;
                    }
                    var admin = ef.Admins.FirstOrDefault(c => c.ID.Equals(id));
                    if (admin != null && admin.RE_ENABLE == 0)
                    {
                        admin.RE_ENABLE = 1;
                        changed = true;
                    }
                    if (changed)
                        ef.SaveChanges();
                }
                if (changed)
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
