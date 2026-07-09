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
    public class NoticeController : BaseController
    {
        // GET: Game/Notice
        public ActionResult Index()
        {
            return View();
        }


        [AjaxOnly]
        [HttpPost]
        public ActionResult GetNotices(FormCollection form)
        {
            string TITLE = form.Q<string>("TITLE");
            M_EasyuiGridData<M_Notice> list = new M_EasyuiGridData<M_Notice>();
            try
            {
                M_LoginUser loginUser = WebHelper.GetLoginInfo();

                M_Notice entity = new M_Notice { TITLE = TITLE };

                list = new B_Notice().GetNotices(loginUser, entity);
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.NoticeController), ex);
            }
            return Json(list);
        }

        /// <summary>
        /// 添加公告
        /// </summary>
        /// <returns></returns>
        [AjaxOnly]
        [HttpPost]
        public ActionResult AddNotice(FormCollection form)
        {
            Msg msg = new Msg(0, "公告发布失败！");
            try
            {
                M_LoginUser loginUser = WebHelper.GetLoginInfo();
                if (loginUser == null)
                    return Json(msg);

                M_Notice entity = new M_Notice();

                if (TryUpdateModel<M_Notice>(entity, form) && ModelState.IsValid)
                {
                    if (loginUser.RE_ENABLE != 1)
                    {
                        msg.content = "您不具备此权限";
                        return Json(msg);
                    }
                    msg = new B_Notice().AddNotice(entity);
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
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.NoticeController), ex);
            }
            return Json(msg);
        }
        /// <summary>
        /// 添加公告
        /// </summary>
        /// <returns></returns>
        [AjaxOnly]
        [HttpPost]
        public ActionResult delNotice(FormCollection form)
        {

            Msg msg = new Msg(0, "删除失败！");
            try
            {
                int id = form.Q<int>("ID");
                M_Notice mRobot = new M_Notice { ID = id };
                int val = new B_Notice().DelNotice(mRobot);
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
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.NoticeController), ex);
            }
            return Json(msg);
        }

        /// <summary>
        /// 添加公告
        /// </summary>
        /// <returns></returns>
        [AjaxOnly]
        [HttpPost]
        public ActionResult updateNotic(FormCollection form)
        {
            Msg msg = new Msg(0, "公告修改失败！");
            try
            {
                M_Notice entity = new M_Notice();
                if (TryUpdateModel<M_Notice>(entity, form) && ModelState.IsValid)
                {
                    msg = new B_Notice().updateNotice(entity);
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
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.NoticeController), ex);
            }
            return Json(msg);
        }
    }
}