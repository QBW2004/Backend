using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using YYT.BLL.EF;
using YYT.Common;
using YYT.Entity;
using YYT.Remote;

namespace YYT.Web.Areas.Game.Controllers
{
    public class GameMoController : Controller
    {
        // GET: Game/GameMo
        public ActionResult Index()
        {
            return View();
        }

        [MemberAuthorize]
        [AjaxOnly]
        [HttpPost]
        public ActionResult GetGameMo(FormCollection form)
        {
            M_EasyuiGridData<M_GameMo> list = new M_EasyuiGridData<M_GameMo>();
            try
            {
                string UserName = form.Q<string>("UserName");
                int pageIndex = form.Q<int>("page", 1);
                int pageSize = form.Q<int>("rows", 10);

                M_LoginUser loginUser = WebHelper.GetLoginInfo();
                if (loginUser == null)
                    return Json(list);

                M_Page mPage = new M_Page(pageIndex, pageSize);
                M_GameMo entity = new M_GameMo
                {

                };

                list = new B_GameMo().GetGameMo(loginUser, mPage, entity);
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.UserInfoController), ex);
            }
            return Json(list);
        }

        [MemberAuthorize]
        [AjaxOnly]
        [HttpPost]
        public ActionResult EnableGameMoType(FormCollection form)
        {
            Msg msg = new Msg(0, "切换失败！");
            try
            {
                string id = form.Q<string>("ID");
                int GameMoType = form.Q<int>("GameMoType", 0);
                if (!string.IsNullOrWhiteSpace(id))
                {
                    M_GameMo mPlatType = new M_GameMo { ID = Convert.ToInt32(id), GameMoType = Convert.ToBoolean(GameMoType) };
                    int val = new B_GameMo().UpdateGameMoType(mPlatType);
                    if (val > 0)
                    {

                        var srv = new SConnect();
                        var tmpMsg = srv.SendReadString(EScMsgType.GM, GameMoType);
                        msg.code = tmpMsg.code;
                        msg.content = tmpMsg.content;
                    }
                }
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.UserInfoController), ex);
            }
            return Json(msg);
        }
    }
}