using System;
using System.Web.Mvc;
using YYT.BLL.EF;
using YYT.Common;
using YYT.Entity;
using YYT.Remote;
using YYT.Web;
using YYT.Web.Controllers;

namespace YYT.Web.Areas.Game.Controllers
{
    [MemberAuthorize]
    public class ActivityController : BaseController
    {
        // GET: Game/Activity
        public ActionResult Index()
        {
            return View();
        }


        [AjaxOnly]
        [HttpPost]
        public ActionResult GetActivity(FormCollection form)
        {
            string TITLE = form.Q<string>("TITLE");
            M_EasyuiGridData<M_Activity> list = new M_EasyuiGridData<M_Activity>();
            try
            {
                M_LoginUser loginUser = WebHelper.GetLoginInfo();

                M_Activity entity = new M_Activity { TITLE = TITLE };

                list = new B_Activity().GetActivity(loginUser, entity);
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.ActivityController), ex);
            }
            return Json(list);
        }

        /// <summary>
        /// 添加公告
        /// </summary>
        /// <returns></returns>
        [AjaxOnly]
        [HttpPost]
        public ActionResult AddActivity(FormCollection form)
        {
            Msg msg = new Msg(0, "活动发布失败！");
            try
            {
                M_LoginUser loginUser = WebHelper.GetLoginInfo();
                if (loginUser == null)
                    return Json(msg);

                M_Activity entity = new M_Activity();

                if (TryUpdateModel<M_Activity>(entity, form) && ModelState.IsValid)
                {
                    if (loginUser.RE_ENABLE != 1)
                    {
                        msg.content = "您不具备此权限";
                        return Json(msg);
                    }
                    msg = new B_Activity().AddActivity(entity);
                    //if (msg.code == 1)
                    //{
                    //    var srv = new SConnect();
                    //    msg = srv.SendReadString(EScMsgType.RN, entity.NOTICE);
                    //    msg.code = (msg.code == 1 ? 1 : 0);
                    //}
                }
                else
                {
                    msg.content = ModelState.Values.GetErrMsg();
                }
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.ActivityController), ex);
            }
            return Json(msg);
        }
        /// <summary>
        /// 添加公告
        /// </summary>
        /// <returns></returns>
        [AjaxOnly]
        [HttpPost]
        public ActionResult delActivity(FormCollection form)
        {

            Msg msg = new Msg(0, "删除失败！");
            try
            {
                int id = form.Q<int>("ID");
                M_Activity mRobot = new M_Activity { ID = id };
                int val = new B_Activity().DelActivity(mRobot);
                if (val > 0)
                {
                    //var srv = new SConnect();
                    //msg = srv.SendReadString(EScMsgType.RN, "");
                    msg.code =1;
                    msg.content = "删除成功！";
                }
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.ActivityController), ex);
            }
            return Json(msg);
        }

        /// <summary>
        /// 添加活动
        /// </summary>
        /// <returns></returns>
        [AjaxOnly]
        [HttpPost]
        public ActionResult updateActivity(FormCollection form)
        {
            Msg msg = new Msg(0, "活动修改失败！");
            try
            {
                M_Activity entity = new M_Activity();
                if (TryUpdateModel<M_Activity>(entity, form) && ModelState.IsValid)
                {
                    msg = new B_Activity().updateActivity(entity);
                    //if (msg.code == 1)
                    //{
                    //    var srv = new SConnect();
                    //    msg = srv.SendReadString(EScMsgType.RN, entity.NOTICE);
                    //    msg.code = (msg.code == 1 ? 1 : 0);
                    //}
                }
                else
                {
                    msg.content = ModelState.Values.GetErrMsg();
                }
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.ActivityController), ex);
            }
            return Json(msg);
        }
    }
}