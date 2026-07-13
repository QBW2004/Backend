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
    /// 鱼机和玩家控制（金币上限/放水/点杀）
    /// </summary>
    [MemberAuthorize]
    public class FishUserCtrlController : BaseController
    {
        // GET: Game/FishUserCtrl
        public ActionResult Index()
        {
            return View();
        }

        /// <summary>
        /// 鱼机下拉数据
        /// </summary>
        [AjaxOnly]
        [HttpPost]
        public ActionResult GetFishGames()
        {
            List<object> rows = new List<object> { new { GameId = 0, Name = "全部鱼机" } };
            try
            {
                using (var ef = new GameDbContext())
                {
                    var games = ef.Games
                        .Where(g => g.GameType == 2 && g.Enable == 1)
                        .OrderBy(g => g.GameId)
                        .ToList();
                    foreach (var g in games)
                        rows.Add(new { g.GameId, g.Name });
                }
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(FishUserCtrlController), ex);
            }
            return Json(rows);
        }

        /// <summary>
        /// 应用控制规则
        /// </summary>
        [AjaxOnly]
        [HttpPost]
        public ActionResult ApplyControl(FormCollection form)
        {
            Msg msg = new Msg(0, "设置失败！");
            try
            {
                M_LoginUser loginUser = WebHelper.GetLoginInfo();
                int scope = form.Q<int>("Scope", 0);             // 1=进入鱼机的所有玩家 2=精确到用户
                int gameId = form.Q<int>("GameId", 0);
                string userId = form.Q<string>("UserID");

                var rules = new List<KeyValuePair<int, long>>();
                if (form.Q<int>("EnableLimit", 0) == 1)
                    rules.Add(new KeyValuePair<int, long>((int)EControlMode.Limit, form.Q<long>("LimitVal", 0)));
                if (form.Q<int>("EnableRelease", 0) == 1)
                    rules.Add(new KeyValuePair<int, long>((int)EControlMode.Release, form.Q<long>("ReleaseVal", 0)));
                if (form.Q<int>("EnableKill", 0) == 1)
                    rules.Add(new KeyValuePair<int, long>((int)EControlMode.Kill, form.Q<long>("KillVal", 0)));

                msg = new B_UserControl().ApplyControls(loginUser, scope, gameId, userId, rules);
            }
            catch (Exception ex)
            {
                msg.content = "服务器内部错误。";
                LogHelper.WriteLog(typeof(FishUserCtrlController), ex);
            }
            return Json(msg);
        }

        /// <summary>
        /// 控制记录列表
        /// </summary>
        [AjaxOnly]
        [HttpPost]
        public ActionResult GetControls(FormCollection form)
        {
            var list = new M_EasyuiGridData<M_UserControlStatus_DTO>();
            try
            {
                string userId = form.Q<string>("UserID");
                int status = form.Q<int>("Status", -1);
                int pageIndex = form.Q<int>("page", 1);
                int pageSize = form.Q<int>("rows", 20);

                M_LoginUser loginUser = WebHelper.GetLoginInfo();
                if (loginUser == null)
                    return Json(list);

                list = new B_UserControl().GetControls(new M_Page(pageIndex, pageSize), userId, status, loginUser);
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(FishUserCtrlController), ex);
            }
            return Json(list);
        }

        /// <summary>
        /// 关闭一条执行中的控制
        /// </summary>
        [AjaxOnly]
        [HttpPost]
        public ActionResult CloseControl(FormCollection form)
        {
            Msg msg = new Msg(0, "关闭失败！");
            try
            {
                int id = form.Q<int>("ID", 0);
                M_LoginUser loginUser = WebHelper.GetLoginInfo();
                msg = new B_UserControl().CloseControl(loginUser, id);
            }
            catch (Exception ex)
            {
                msg.content = "服务器内部错误。";
                LogHelper.WriteLog(typeof(FishUserCtrlController), ex);
            }
            return Json(msg);
        }
    }
}
