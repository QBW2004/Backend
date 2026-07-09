using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using YYT.BLL.EF;
using YYT.Common;
using YYT.Entity;

namespace YYT.Web.Areas.Game.Controllers
{
    public class SafeCoinsLogController : Controller
    {
        // GET: Game/SafeCoinsLog
        public ActionResult Index()
        {
            return View();
        }

        [MemberAuthorize]
        [AjaxOnly]
        [HttpPost]
        public ActionResult GetSafeCoinsLog(FormCollection form)
        {
            M_EasyuiGridData<M_SafeCoinsLog> list = new M_EasyuiGridData<M_SafeCoinsLog>();
            try
            {
                string UserId = form.Q<string>("UserId");
                int pageIndex = form.Q<int>("page", 1);
                int pageSize = form.Q<int>("rows", 10);
                M_Page mPage = new M_Page(pageIndex, pageSize);
                M_SafeCoinsLog entity = new M_SafeCoinsLog
                {
                    User_Id = UserId
                };

                list = new B_SafeCoinsLog().GetSafeCoinsLog(mPage, entity);
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.SafeCoinsLogController), ex);
            }
            return Json(list);
        }

    }
}