using System.Web.Mvc;
using YYT.Web;
using YYT.Web.Controllers;

namespace YYT.Web.Areas.Game.Controllers
{
    [MemberAuthorize]
    public class UserAccountController : BaseController
    {
        // GET: Game/UserAccount
        public ActionResult Index()
        {
            return View();
        }
    }
}