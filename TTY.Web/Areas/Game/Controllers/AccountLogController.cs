using Newtonsoft.Json;
using System;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using System.Web.Mvc;
using YYT.BLL.EF;
using YYT.Common;
using YYT.Entity;
using YYT.Remote;
using YYT.Web;
using YYT.Web.Controllers;

namespace YYT.Web.Areas.Game.Controllers
{
    public class AccountLogController : Controller
    {
        // GET: Game/AccountLog
        public ActionResult Index()
        {
            return View();
        }
        public ActionResult TransferLog()
        {
            return View();
        }
        public ActionResult PlatType()
        {
            return View();
        }
        [MemberAuthorize]
        [AjaxOnly]
        [HttpPost]
        public ActionResult GetAccountLog(FormCollection form)
        {
            M_EasyuiGridData<M_AccountLog> list = new M_EasyuiGridData<M_AccountLog>();
            try
            {
                string UserName = form.Q<string>("UserName");
                int pageIndex = form.Q<int>("page", 1);
                int pageSize = form.Q<int>("rows", 10);

                M_LoginUser loginUser = WebHelper.GetLoginInfo();
                if (loginUser == null)
                    return Json(list);

                M_Page mPage = new M_Page(pageIndex, pageSize);
                M_AccountLog entity = new M_AccountLog
                {
                    UserName = UserName
                };

                list = new B_AccountLog().GetAccountLogs(loginUser, mPage, entity);
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
        public ActionResult GetTransferLog(FormCollection form)
        {
            M_EasyuiGridData<M_TransferLog> list = new M_EasyuiGridData<M_TransferLog>();
            try
            {
                string UserName = form.Q<string>("UserName");
                int pageIndex = form.Q<int>("page", 1);
                int pageSize = form.Q<int>("rows", 10);

                M_LoginUser loginUser = WebHelper.GetLoginInfo();
                if (loginUser == null)
                    return Json(list);

                M_Page mPage = new M_Page(pageIndex, pageSize);
                M_TransferLog entity = new M_TransferLog
                {
                    UserName = UserName
                };

                list = new B_TransferLog().GetTransferLogs(loginUser, mPage, entity);
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
        public ActionResult GetPlatType(FormCollection form)
        {
            M_EasyuiGridData<M_PlatType> list = new M_EasyuiGridData<M_PlatType>();
            try
            {
                string Name = form.Q<string>("Name");
                int pageIndex = form.Q<int>("page", 1);
                int pageSize = form.Q<int>("rows", 10);

                M_LoginUser loginUser = WebHelper.GetLoginInfo();
                if (loginUser == null)
                    return Json(list);

                M_Page mPage = new M_Page(pageIndex, pageSize);
                M_PlatType entity = new M_PlatType
                {
                    Name = Name
                };

                list = new B_PlatType().GetPlatType(loginUser, mPage, entity);
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
        public ActionResult EnablePlatType(FormCollection form)
        {
            Msg msg = new Msg(0, "设置失败！");
            try
            {
                string id = form.Q<string>("ID");
                int Enable = form.Q<int>("Enable", 0);
                if (!string.IsNullOrWhiteSpace(id))
                {
                    M_PlatType mPlatType = new M_PlatType { ID = Convert.ToInt32(id), Enable = Convert.ToBoolean(Enable) };
                    int val = new B_PlatType().EnablePlatType(mPlatType);
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