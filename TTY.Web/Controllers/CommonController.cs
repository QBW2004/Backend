using System.Web.Mvc;

namespace YYT.Web.Controllers
{
    public class CommonController : Controller
    {
        public ActionResult NoAuthorize()
        {
            return View();
        }
    }
}