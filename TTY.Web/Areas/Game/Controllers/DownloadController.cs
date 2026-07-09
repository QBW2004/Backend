using System;
using System.Web.Mvc;
using YYT.Common;

namespace YYT.Web.Areas.Game.Controllers
{
    public class DownloadController : Controller
    {
        // GET: Game/Download
        public ActionResult Index()
        {
            try
            {
                ViewBag.IOS_Url = ConfigHelper.Get("IOS_Url");
                ViewBag.Andriod_Url = ConfigHelper.Get("Andriod_Url");
                ViewBag.PC_Url = ConfigHelper.Get("PC_Url");
                ViewBag.DownloadTitle = ConfigHelper.Get("DownloadTitle");
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.DownloadController), ex);
            }
            return View();
        }
    }
}