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
    /// 客户端包管理（2026-10-30，仅超管）：登记每套换皮包的口令（AppKey）、启停、是否按真实桌号显示。
    /// 数据与口径见 YYT.BLL.EF.ClientPackages；中心服每次大厅登录实时查库，不需要热更。
    /// </summary>
    [MemberAuthorize]
    [SuperAdminAuthorize]
    public class ClientPackageController : BaseController
    {
        public ActionResult Index()
        {
            return View();
        }

        [AjaxOnly]
        [HttpPost]
        public ActionResult GetPackages()
        {
            try
            {
                using (var ef = new GameDbContext())
                {
                    if (!ClientPackages.TableExists(ef))
                        return Json(new { ready = false, rows = new List<ClientPackages.PackageRow>() });
                    var rows = ClientPackages.List(ef).Select(r => new
                    {
                        r.ID,
                        r.Name,
                        r.AppKey,
                        r.Enabled,
                        r.RealTableIndex,
                        r.Remark,
                        CreateTime = r.CreateTime.HasValue ? r.CreateTime.Value.ToString("yyyy-MM-dd HH:mm:ss") : "",
                        UpdateTime = r.UpdateTime.HasValue ? r.UpdateTime.Value.ToString("yyyy-MM-dd HH:mm:ss") : ""
                    }).ToList();
                    return Json(new { ready = true, rows = rows });
                }
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(ClientPackageController), ex);
                return Json(new { ready = false, rows = new List<ClientPackages.PackageRow>(), error = "查询失败：" + ex.Message });
            }
        }

        [AjaxOnly]
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult SavePackage(FormCollection form)
        {
            Msg msg = new Msg(0, "保存失败！");
            try
            {
                msg = ClientPackages.Save(form.Q<int>("ID", 0), form.Q<string>("Name"), form.Q<string>("AppKey"),
                    form.Q<int>("Enabled", 1), form.Q<int>("RealTableIndex", 0), form.Q<string>("Remark"));
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(ClientPackageController), ex);
                msg.content = "保存失败：" + ex.Message;
            }
            return Json(msg);
        }

        [AjaxOnly]
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult SetEnabled(FormCollection form)
        {
            Msg msg = new Msg(0, "设置失败！");
            try
            {
                msg = ClientPackages.SetEnabled(form.Q<int>("ID", 0), form.Q<int>("Enabled", 1));
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(ClientPackageController), ex);
                msg.content = "设置失败：" + ex.Message;
            }
            return Json(msg);
        }
    }
}
