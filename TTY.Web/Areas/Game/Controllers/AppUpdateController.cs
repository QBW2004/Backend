using System;
using System.Collections.Generic;
using System.Web.Mvc;
using YYT.BLL.EF;
using YYT.Common;
using YYT.Entity;
using YYT.Web;
using YYT.Web.Controllers;

namespace YYT.Web.Areas.Game.Controllers
{
    [MemberAuthorize]
    public class AppUpdateController : BaseController
    {
        // GET: Game/AppUpdate
        public ActionResult Index()
        {
            List<M_UpdateAddr> list = new List<M_UpdateAddr>();
            try
            {
                list = new B_UpdateAddr().GetSettings();
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.AppUpdateController), ex);
            }
            return View(list);
        }

        [AjaxOnly]
        [HttpPost]
        public ActionResult SaveConfig(FormCollection form)
        {
            Msg msg = new Msg(0, "保存失败！");
            try
            {
                M_UpdateAddr entity = new M_UpdateAddr();
                if (TryUpdateModel<M_UpdateAddr>(entity) && ModelState.IsValid)
                {
                    msg = new B_UpdateAddr().SaveConfig(entity);
                }
                else
                {
                    msg.content = ModelState.Values.GetErrMsg();
                }

            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.AppUpdateController), ex);
            }
            return Json(msg);
        }
    }
}