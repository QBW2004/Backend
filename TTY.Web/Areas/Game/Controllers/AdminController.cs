using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using YYT.BLL.EF;
using YYT.Common;
using YYT.Entity;
using YYT.Web.Controllers;

namespace YYT.Web.Areas.Game.Controllers
{
    [MemberAuthorize]
    public class AdminController : BaseController
    {
        // GET: Game/Admin
        public ActionResult Index()
        {
            return View();
        }
        static readonly string REG_TOKEN = "yyt_reg_token";
        public bool LogSwitch { get; }

        public AdminController()
        {
            LogSwitch = (ConfigHelper.GetInt("logSwitch") == 1);
        }

        private bool IsSuperAdmin(M_LoginUser loginUser)
        {
            return loginUser != null && loginUser.UserPriv == 0;
        }

        private bool CanManagePermissionTarget(M_LoginUser loginUser, string id, Msg msg)
        {
            if (loginUser == null || string.IsNullOrWhiteSpace(id))
                return false;

            if (loginUser.Accounts.Equals(id))
            {
                msg.content = "不能对自己设置！！！";
                return false;
            }

            if (IsSuperAdmin(loginUser))
                return true;

            using (var ef = new GameDbContext())
            {
                List<string> managedAgencies = new B_Admin().GetManagedAgencyAccounts(ef, loginUser);
                M_Admin target = ef.Admins.FirstOrDefault(a => a.ID == id);
                if (target == null || !managedAgencies.Contains(id))
                {
                    msg.content = "只能设置自己管理范围内的下级代理！";
                    return false;
                }
            }

            return true;
        }

        protected override void OnActionExecuting(ActionExecutingContext filterContext)
        {
            string actionName = filterContext.ActionDescriptor.ActionName;
            if (!string.Equals(actionName, "Index", StringComparison.OrdinalIgnoreCase))
            {
                M_LoginUser loginUser = WebHelper.GetLoginInfo();
                if (loginUser == null)
                {
                    filterContext.Result = Json(new Msg(-1, "登录已超时，请重新登录！"));
                    return;
                }
            }
            base.OnActionExecuting(filterContext);
        }


        [AjaxOnly]
        [HttpPost]
        public ActionResult SetFrozen(FormCollection form)
        {    //冻结权限
            Msg msg = new Msg(0, "设置失败！");
            try
            {
                string id = form.Q<string>("ID");
                int re_enable = form.Q<int>("IsFrozen", 0);
                M_LoginUser m_LoginUser = WebHelper.GetLoginInfo();

                if (m_LoginUser != null && !string.IsNullOrWhiteSpace(id))
                {
                    if (!CanManagePermissionTarget(m_LoginUser, id, msg))
                        return Json(msg);

                    M_Admin mUsers = new M_Admin { ID = id, IsFrozen = re_enable };
                    int val = new B_Admin().SetFrozen(mUsers);
                    if (val > 0)
                    {
                        msg.code = 1;
                        msg.content = "设置成功！";
                    }
                }
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.AgencyInfoController), ex);
            }
            return Json(msg);
        }
        [AjaxOnly]
        [HttpPost]
        public ActionResult SetIsProbability(FormCollection form)
        {    //放水控制权限
            Msg msg = new Msg(0, "设置失败！");
            try
            {
                string id = form.Q<string>("ID");
                int re_enable = form.Q<int>("IsProbability", 0);
                M_LoginUser m_LoginUser = WebHelper.GetLoginInfo();

                if (m_LoginUser != null && !string.IsNullOrWhiteSpace(id))
                {
                    if (!CanManagePermissionTarget(m_LoginUser, id, msg))
                        return Json(msg);

                    M_Admin mUsers = new M_Admin { ID = id, IsProbability = re_enable };
                    int val = new B_Admin().SetProbability(mUsers);
                    if (val > 0)
                    {
                        msg.code = 1;
                        msg.content = "放水权限设置成功！";
                    }
                }
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.AgencyInfoController), ex);
            }
            return Json(msg);
        }

        [AjaxOnly]
        [HttpPost]
        public ActionResult SetIsKicking(FormCollection form)
        {    //踢人权限
            Msg msg = new Msg(0, "设置失败！");
            try
            {
                string id = form.Q<string>("ID");
                int re_enable = form.Q<int>("IsKicking", 0);
                M_LoginUser m_LoginUser = WebHelper.GetLoginInfo();

                if (m_LoginUser != null && !string.IsNullOrWhiteSpace(id))
                {
                    if (!CanManagePermissionTarget(m_LoginUser, id, msg))
                        return Json(msg);

                    M_Admin mUsers = new M_Admin { ID = id, IsKicking = re_enable };
                    int val = new B_Admin().SetKicking(mUsers);
                    if (val > 0)
                    {
                        msg.code = 1;
                        msg.content = "设置成功！";
                    }
                }
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.AgencyInfoController), ex);
            }
            return Json(msg);
        }

        [AjaxOnly]
        [HttpPost]
        public ActionResult SetIsDelete(FormCollection form)
        {    //删除权限
            Msg msg = new Msg(0, "设置失败！");
            try
            {
                string id = form.Q<string>("ID");
                int re_enable = form.Q<int>("IsDelete", 0);
                M_LoginUser m_LoginUser = WebHelper.GetLoginInfo();

                if (m_LoginUser != null && !string.IsNullOrWhiteSpace(id))
                {
                    if (!CanManagePermissionTarget(m_LoginUser, id, msg))
                        return Json(msg);

                    M_Admin mUsers = new M_Admin { ID = id, IsDelete = re_enable };
                    int val = new B_Admin().SetDelete(mUsers);
                    if (val > 0)
                    {
                        msg.code = 1;
                        msg.content = "设置成功！";
                    }
                }
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.AgencyInfoController), ex);
            }
            return Json(msg);
        }

        /// <summary>
        /// 设置上下分权限
        /// </summary>
        [AjaxOnly]
        [HttpPost]
        public ActionResult SetIsUpDown(FormCollection form)
        {
            Msg msg = new Msg(0, "设置失败！");
            try
            {
                string id = form.Q<string>("ID");
                int isUpDown = form.Q<int>("IsUpDown", 0);
                M_LoginUser m_LoginUser = WebHelper.GetLoginInfo();

                if (m_LoginUser != null && !string.IsNullOrWhiteSpace(id))
                {
                    if (!CanManagePermissionTarget(m_LoginUser, id, msg))
                        return Json(msg);

                    M_Admin mUsers = new M_Admin { ID = id, IsUpDown = isUpDown };
                    int val = new B_Admin().SetUpDown(mUsers);
                    if (val > 0)
                    {
                        msg.code = 1;
                        msg.content = "上下分权限设置成功！";
                    }
                }
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.AdminController), ex);
            }
            return Json(msg);
        }

        /// <summary>
        /// 设置踢人范围
        /// </summary>
        [AjaxOnly]
        [HttpPost]
        public ActionResult SetKickScope(FormCollection form)
        {
            Msg msg = new Msg(0, "设置失败！");
            try
            {
                string id = form.Q<string>("ID");
                int kickScope = form.Q<int>("KickScope", 1);
                M_LoginUser m_LoginUser = WebHelper.GetLoginInfo();

                if (m_LoginUser != null && !string.IsNullOrWhiteSpace(id))
                {
                    if (!CanManagePermissionTarget(m_LoginUser, id, msg))
                        return Json(msg);

                    M_Admin mUsers = new M_Admin { ID = id, KickScope = kickScope };
                    int val = new B_Admin().SetKickScope(mUsers);
                    if (val > 0)
                    {
                        msg.code = 1;
                        msg.content = "踢人范围设置成功！";
                    }
                }
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.AdminController), ex);
            }
            return Json(msg);
        }

        /// <summary>
        /// 设置赠送权限
        /// </summary>
        [AjaxOnly]
        [HttpPost]
        public ActionResult SetIsGift(FormCollection form)
        {
            Msg msg = new Msg(0, "设置失败！");
            try
            {
                string id = form.Q<string>("ID");
                int isGift = form.Q<int>("IsGift", 0);
                M_LoginUser m_LoginUser = WebHelper.GetLoginInfo();

                if (m_LoginUser != null && !string.IsNullOrWhiteSpace(id))
                {
                    if (!CanManagePermissionTarget(m_LoginUser, id, msg))
                        return Json(msg);

                    M_Admin mUsers = new M_Admin { ID = id, IsGift = isGift };
                    int val = new B_Admin().SetGiftPermission(mUsers);
                    if (val > 0)
                    {
                        msg.code = 1;
                        msg.content = "赠送权限设置成功！";
                    }
                }
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.AdminController), ex);
            }
            return Json(msg);
        }

        /// <summary>
        /// 设置开代理权限
        /// </summary>
        [AjaxOnly]
        [HttpPost]
        public ActionResult SetIsCreateAgent(FormCollection form)
        {
            Msg msg = new Msg(0, "设置失败！");
            try
            {
                string id = form.Q<string>("ID");
                int isCreateAgent = form.Q<int>("IsCreateAgent", 0);
                M_LoginUser m_LoginUser = WebHelper.GetLoginInfo();

                if (m_LoginUser != null && !string.IsNullOrWhiteSpace(id))
                {
                    if (!CanManagePermissionTarget(m_LoginUser, id, msg))
                        return Json(msg);

                    M_Admin mUsers = new M_Admin { ID = id, IsCreateAgent = isCreateAgent };
                    int val = new B_Admin().SetCreateAgentPermission(mUsers);
                    if (val > 0)
                    {
                        msg.code = 1;
                        msg.content = "开代理权限设置成功！";
                    }
                }
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.AdminController), ex);
            }
            return Json(msg);
        }

        /// <summary>
        /// 设置查看密码权限
        /// </summary>
        [AjaxOnly]
        [HttpPost]
        public ActionResult SetIsViewPwd(FormCollection form)
        {
            Msg msg = new Msg(0, "设置失败！");
            try
            {
                string id = form.Q<string>("ID");
                int isViewPwd = form.Q<int>("IsViewPwd", 0);
                M_LoginUser m_LoginUser = WebHelper.GetLoginInfo();

                if (m_LoginUser != null && !string.IsNullOrWhiteSpace(id))
                {
                    if (!CanManagePermissionTarget(m_LoginUser, id, msg))
                        return Json(msg);

                    M_Admin mUsers = new M_Admin { ID = id, IsViewPwd = isViewPwd };
                    int val = new B_Admin().SetViewPwdPermission(mUsers);
                    if (val > 0)
                    {
                        msg.code = 1;
                        msg.content = "查看密码权限设置成功！";
                    }
                }
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.AdminController), ex);
            }
            return Json(msg);
        }

        /// <summary>
        /// 设置修改密码权限
        /// </summary>
        [AjaxOnly]
        [HttpPost]
        public ActionResult SetIsModifyPwd(FormCollection form)
        {
            Msg msg = new Msg(0, "设置失败！");
            try
            {
                string id = form.Q<string>("ID");
                int isModifyPwd = form.Q<int>("IsModifyPwd", 0);
                M_LoginUser m_LoginUser = WebHelper.GetLoginInfo();

                if (m_LoginUser != null && !string.IsNullOrWhiteSpace(id))
                {
                    if (!CanManagePermissionTarget(m_LoginUser, id, msg))
                        return Json(msg);

                    M_Admin mUsers = new M_Admin { ID = id, IsModifyPwd = isModifyPwd };
                    int val = new B_Admin().SetModifyPwdPermission(mUsers);
                    if (val > 0)
                    {
                        msg.code = 1;
                        msg.content = "修改密码权限设置成功！";
                    }
                }
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.AdminController), ex);
            }
            return Json(msg);
        }

        /// <summary>
        /// 设置重置保险密码权限
        /// </summary>
        [AjaxOnly]
        [HttpPost]
        public ActionResult SetIsResetSafePwd(FormCollection form)
        {
            Msg msg = new Msg(0, "设置失败！");
            try
            {
                string id = form.Q<string>("ID");
                int isResetSafePwd = form.Q<int>("IsResetSafePwd", 0);
                M_LoginUser m_LoginUser = WebHelper.GetLoginInfo();

                if (m_LoginUser != null && !string.IsNullOrWhiteSpace(id))
                {
                    if (!CanManagePermissionTarget(m_LoginUser, id, msg))
                        return Json(msg);

                    M_Admin mUsers = new M_Admin { ID = id, IsResetSafePwd = isResetSafePwd };
                    int val = new B_Admin().SetResetSafePwdPermission(mUsers);
                    if (val > 0)
                    {
                        msg.code = 1;
                        msg.content = "重置保险密码权限设置成功！";
                    }
                }
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.AdminController), ex);
            }
            return Json(msg);
        }

        /// <summary>
        /// 设置管理范围
        /// </summary>
        [AjaxOnly]
        [HttpPost]
        public ActionResult SetManageScope(FormCollection form)
        {
            Msg msg = new Msg(0, "设置失败！");
            try
            {
                string id = form.Q<string>("ID");
                int manageScope = form.Q<int>("ManageScope", 1);
                M_LoginUser m_LoginUser = WebHelper.GetLoginInfo();

                if (m_LoginUser != null && !string.IsNullOrWhiteSpace(id))
                {
                    if (!CanManagePermissionTarget(m_LoginUser, id, msg))
                        return Json(msg);

                    M_Admin mUsers = new M_Admin { ID = id, ManageScope = manageScope };
                    int val = new B_Admin().SetManageScope(mUsers);
                    if (val > 0)
                    {
                        msg.code = 1;
                        msg.content = "管理范围设置成功！";
                    }
                }
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.AdminController), ex);
            }
            return Json(msg);
        }

        /// <summary>
        /// 设置点杀控制权限
        /// </summary>
        [AjaxOnly]
        [HttpPost]
        public ActionResult SetIsKill(FormCollection form)
        {
            Msg msg = new Msg(0, "设置失败！");
            try
            {
                string id = form.Q<string>("ID");
                int isKill = form.Q<int>("IsKill", 0);
                M_LoginUser m_LoginUser = WebHelper.GetLoginInfo();

                if (m_LoginUser != null && !string.IsNullOrWhiteSpace(id))
                {
                    if (!CanManagePermissionTarget(m_LoginUser, id, msg))
                        return Json(msg);

                    M_Admin mUsers = new M_Admin { ID = id, IsKill = isKill };
                    int val = new B_Admin().SetKillPermission(mUsers);
                    if (val > 0)
                    {
                        msg.code = 1;
                        msg.content = "点杀权限设置成功！";
                    }
                }
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.AdminController), ex);
            }
            return Json(msg);
        }

        /// <summary>
        /// 设置牌机控制权限
        /// </summary>
        [AjaxOnly]
        [HttpPost]
        public ActionResult SetIsRelease(FormCollection form)
        {
            Msg msg = new Msg(0, "设置失败！");
            try
            {
                string id = form.Q<string>("ID");
                int isRelease = form.Q<int>("IsRelease", 0);
                M_LoginUser m_LoginUser = WebHelper.GetLoginInfo();

                if (m_LoginUser != null && !string.IsNullOrWhiteSpace(id))
                {
                    if (!CanManagePermissionTarget(m_LoginUser, id, msg))
                        return Json(msg);

                    M_Admin mUsers = new M_Admin { ID = id, IsRelease = isRelease };
                    int val = new B_Admin().SetReleasePermission(mUsers);
                    if (val > 0)
                    {
                        msg.code = 1;
                        msg.content = "牌机权限设置成功！";
                    }
                }
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.AdminController), ex);
            }
            return Json(msg);
        }

        /// <summary>
        /// 设置查看保险柜密码权限
        /// </summary>
        [AjaxOnly]
        [HttpPost]
        public ActionResult SetIsViewSafePwd(FormCollection form)
        {
            Msg msg = new Msg(0, "设置失败！");
            try
            {
                string id = form.Q<string>("ID");
                int isViewSafePwd = form.Q<int>("IsViewSafePwd", 0);
                M_LoginUser m_LoginUser = WebHelper.GetLoginInfo();

                if (m_LoginUser != null && !string.IsNullOrWhiteSpace(id))
                {
                    if (!CanManagePermissionTarget(m_LoginUser, id, msg))
                        return Json(msg);

                    M_Admin mUsers = new M_Admin { ID = id, IsViewSafePwd = isViewSafePwd };
                    int val = new B_Admin().SetViewSafePwdPermission(mUsers);
                    if (val > 0)
                    {
                        msg.code = 1;
                        msg.content = "查看保险柜密码权限设置成功！";
                    }
                }
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.AdminController), ex);
            }
            return Json(msg);
        }

        /// <summary>
        /// 设置修改保险柜密码权限
        /// </summary>
        [AjaxOnly]
        [HttpPost]
        public ActionResult SetIsModifySafePwd(FormCollection form)
        {
            Msg msg = new Msg(0, "设置失败！");
            try
            {
                string id = form.Q<string>("ID");
                int isModifySafePwd = form.Q<int>("IsModifySafePwd", 0);
                M_LoginUser m_LoginUser = WebHelper.GetLoginInfo();

                if (m_LoginUser != null && !string.IsNullOrWhiteSpace(id))
                {
                    if (!CanManagePermissionTarget(m_LoginUser, id, msg))
                        return Json(msg);

                    M_Admin mUsers = new M_Admin { ID = id, IsModifySafePwd = isModifySafePwd };
                    int val = new B_Admin().SetModifySafePwdPermission(mUsers);
                    if (val > 0)
                    {
                        msg.code = 1;
                        msg.content = "修改保险柜密码权限设置成功！";
                    }
                }
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.AdminController), ex);
            }
            return Json(msg);
        }


    }
}
