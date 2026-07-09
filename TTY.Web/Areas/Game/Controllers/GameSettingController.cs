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
    [MemberAuthorize]
    public class GameSettingController : Controller
    {
        // GET: Game/GameSetting
        public ActionResult Index()
        {
            return View();
        }
        // Game/GameSetting/ResetACC
        [AjaxOnly]
        [HttpPost]
        public ActionResult ResetACC()
        {
            return View();
        }
        [MemberAuthorize]
        [AjaxOnly]
        [HttpPost]
        public ActionResult GetGames(FormCollection form)
        {
            M_EasyuiGridData<M_Games> list = new M_EasyuiGridData<M_Games>();
            try
            {
                string Name = form.Q<string>("Name");
                int GameType = form.Q<int>("GameType");
                int pageIndex = form.Q<int>("page", 1);
                int pageSize = form.Q<int>("rows", 10);

                M_LoginUser loginUser = WebHelper.GetLoginInfo();
                if (loginUser == null)
                    return Json(list);

                M_Page mPage = new M_Page(pageIndex, pageSize);
                M_Games entity = new M_Games
                {
                    Name = Name,GameType=GameType
                };

                list = new B_Games().GetGames(mPage, entity);
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.GameSettingController), ex);
            }
            return Json(list);
        }
        [MemberAuthorize]
        [AjaxOnly]
        [HttpPost]
        public ActionResult EnableGames(FormCollection form)
        {
            Msg msg = new Msg(0, "设置失败！");
            try
            {
                string GameId = form.Q<string>("GameId");
                int Enable = form.Q<int>("Enable", 0);
                if (!string.IsNullOrWhiteSpace(GameId))
                {
                    M_Games mGames = new M_Games { GameId = Convert.ToInt32(GameId), Enable = Enable };
                    int val = new B_Games().EnableGames(mGames);
                    if (val > 0)
                    {
                        msg.code = 1;
                        if (Enable == 0)
                        {
                            msg.content = "禁用成功！";
                        }
                        else
                        {
                            msg.content = "启用成功！";
                        }
                        
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
