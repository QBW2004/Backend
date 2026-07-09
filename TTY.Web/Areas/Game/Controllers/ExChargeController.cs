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
    public class ExChargeController : Controller
    {
        // GET: Game/ExCharge
        public ActionResult Index()
        {
            return View();
        }
        [MemberAuthorize]
        [AjaxOnly]
        [HttpPost]
        public ActionResult GetExCharge(FormCollection form)
        {
            M_EasyuiGridData<M_ExChange> list = new M_EasyuiGridData<M_ExChange>();
            try
            {
                string UserId = form.Q<string>("UserId");
                string AGENCY = form.Q<string>("AGENCY");
                int pageIndex = form.Q<int>("page", 1);
                int pageSize = form.Q<int>("rows", 10);
                M_Page mPage = new M_Page(pageIndex, pageSize);
                M_ExChange entity = new M_ExChange
                {
                    PLAYER_ID = UserId,
                    AGENCY= AGENCY
                };
                M_LoginUser loginUser = WebHelper.GetLoginInfo();
                if (loginUser == null)
                    return Json(list);
                list = new B_ExChange().getExChange(mPage, entity, loginUser);
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.ExChargeController), ex);
            }
            return Json(list);
        }
    }
}