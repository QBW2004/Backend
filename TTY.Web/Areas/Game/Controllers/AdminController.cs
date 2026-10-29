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
                M_Admin target = ef.Admins.FirstOrDefault(a => a.ID == id);
                if (target == null || !new B_Admin().IsTargetAgencyInManagedScope(ef, loginUser, id))
                {
                    msg.content = "只能设置自己管理范围内的下级代理！";
                    return false;
                }
            }

            return true;
        }

        /// <summary>
        /// 授权持有校验：授权值不得超过调用者自身持有的权限值，否则拒绝（防"子代权限超父代"）。
        /// 收权/降权永远放行——父代必须能随时收回子代权限（newValue 不大于自身值即可）。
        /// 调用者权限位以数据库当前值为准，不用会话快照（上级收权后旧会话不能继续授权）。
        /// 超管视为持有全部权限。oldValue 输出目标修改前的权限值，供审计记录。
        /// </summary>
        private bool CallerHoldsPermission(M_LoginUser loginUser, string targetId, long newValue,
            Func<M_Admin, long?> permissionSelector, string flagName, Msg msg, out long oldValue)
        {
            oldValue = 0;
            using (var ef = new GameDbContext())
            {
                M_Admin target = ef.Admins.FirstOrDefault(a => a.ID == targetId);
                if (target != null)
                    oldValue = permissionSelector(target) ?? 0;

                if (IsSuperAdmin(loginUser))
                    return true;

                M_Admin caller = ef.Admins.FirstOrDefault(a => a.ID == loginUser.Accounts);
                long heldValue = caller == null ? 0 : permissionSelector(caller) ?? 0;
                if (newValue <= heldValue)
                    return true;

                msg.content = "你自身没有该权限，无法授予！";
                AuditPermissionChange(loginUser, targetId, flagName, oldValue, newValue, false);
                return false;
            }
        }

        /// <summary>
        /// 授权操作审计：授权与越权尝试一律落 log4net 文件日志（代理无法触及或删除）。
        /// 记录 操作人/目标/权限位/旧值/新值/来源IP。
        /// </summary>
        private void AuditPermissionChange(M_LoginUser loginUser, string targetId, string flagName,
            long oldValue, long newValue, bool granted)
        {
            LogHelper.WriteLog(typeof(AdminController),
                string.Format("[PERM-{0}] operator={1} target={2} flag={3} old={4} new={5} ip={6}",
                    granted ? "GRANT" : "DENY",
                    loginUser == null ? string.Empty : loginUser.Accounts,
                    targetId, flagName, oldValue, newValue, WebHelper.GetClientIP()));
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

                    long oldValue;
                    if (!CallerHoldsPermission(m_LoginUser, id, re_enable, a => a.IsFrozen, "IsFrozen", msg, out oldValue))
                        return Json(msg);

                    M_Admin mUsers = new M_Admin { ID = id, IsFrozen = re_enable };
                    int val = new B_Admin().SetFrozen(mUsers);
                    if (val > 0)
                    {
                        msg.code = 1;
                        msg.content = "设置成功！";
                        AuditPermissionChange(m_LoginUser, id, "IsFrozen", oldValue, re_enable, true);
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

                    long oldValue;
                    if (!CallerHoldsPermission(m_LoginUser, id, re_enable, a => a.IsProbability, "IsProbability", msg, out oldValue))
                        return Json(msg);

                    M_Admin mUsers = new M_Admin { ID = id, IsProbability = re_enable };
                    int val = new B_Admin().SetProbability(mUsers);
                    if (val > 0)
                    {
                        msg.code = 1;
                        msg.content = "放水权限设置成功！";
                        AuditPermissionChange(m_LoginUser, id, "IsProbability", oldValue, re_enable, true);
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

                    long oldValue;
                    if (!CallerHoldsPermission(m_LoginUser, id, re_enable, a => a.IsKicking, "IsKicking", msg, out oldValue))
                        return Json(msg);

                    M_Admin mUsers = new M_Admin { ID = id, IsKicking = re_enable };
                    int val = new B_Admin().SetKicking(mUsers);
                    if (val > 0)
                    {
                        msg.code = 1;
                        msg.content = "设置成功！";
                        AuditPermissionChange(m_LoginUser, id, "IsKicking", oldValue, re_enable, true);
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

                    long oldValue;
                    if (!CallerHoldsPermission(m_LoginUser, id, re_enable, a => a.IsDelete, "IsDelete", msg, out oldValue))
                        return Json(msg);

                    M_Admin mUsers = new M_Admin { ID = id, IsDelete = re_enable };
                    int val = new B_Admin().SetDelete(mUsers);
                    if (val > 0)
                    {
                        msg.code = 1;
                        msg.content = "设置成功！";
                        AuditPermissionChange(m_LoginUser, id, "IsDelete", oldValue, re_enable, true);
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

                    long oldValue;
                    if (!CallerHoldsPermission(m_LoginUser, id, isUpDown, a => a.IsUpDown, "IsUpDown", msg, out oldValue))
                        return Json(msg);

                    M_Admin mUsers = new M_Admin { ID = id, IsUpDown = isUpDown };
                    int val = new B_Admin().SetUpDown(mUsers);
                    if (val > 0)
                    {
                        msg.code = 1;
                        msg.content = "上下分权限设置成功！";
                        AuditPermissionChange(m_LoginUser, id, "IsUpDown", oldValue, isUpDown, true);
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
        /// 兼容旧客户端的踢人范围接口（实际同步设置管理范围）
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

                    long oldValue;
                    if (!CallerHoldsPermission(m_LoginUser, id, kickScope, a => a.ManageScope ?? 1, "KickScope", msg, out oldValue))
                        return Json(msg);

                    // 兼容旧客户端：踢人范围不再独立保存，统一写入管理范围。
                    M_Admin mUsers = new M_Admin { ID = id, ManageScope = kickScope };
                    int val = new B_Admin().SetKickScope(mUsers);
                    if (val > 0)
                    {
                        msg.code = 1;
                        msg.content = "管理范围设置成功，踢人范围已同步！";
                        AuditPermissionChange(m_LoginUser, id, "KickScope", oldValue, kickScope, true);
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

                    long oldValue;
                    if (!CallerHoldsPermission(m_LoginUser, id, isGift, a => a.IsGift, "IsGift", msg, out oldValue))
                        return Json(msg);

                    M_Admin mUsers = new M_Admin { ID = id, IsGift = isGift };
                    int val = new B_Admin().SetGiftPermission(mUsers);
                    if (val > 0)
                    {
                        msg.code = 1;
                        msg.content = "赠送权限设置成功！";
                        AuditPermissionChange(m_LoginUser, id, "IsGift", oldValue, isGift, true);
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

                    long oldValue;
                    if (!CallerHoldsPermission(m_LoginUser, id, isCreateAgent, a => a.IsCreateAgent, "IsCreateAgent", msg, out oldValue))
                        return Json(msg);

                    M_Admin mUsers = new M_Admin { ID = id, IsCreateAgent = isCreateAgent };
                    int val = new B_Admin().SetCreateAgentPermission(mUsers);
                    if (val > 0)
                    {
                        msg.code = 1;
                        msg.content = "保存成功";
                        AuditPermissionChange(m_LoginUser, id, "IsCreateAgent", oldValue, isCreateAgent, true);
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

                    long oldValue;
                    if (!CallerHoldsPermission(m_LoginUser, id, isViewPwd, a => a.IsViewPwd, "IsViewPwd", msg, out oldValue))
                        return Json(msg);

                    M_Admin mUsers = new M_Admin { ID = id, IsViewPwd = isViewPwd };
                    int val = new B_Admin().SetViewPwdPermission(mUsers);
                    if (val > 0)
                    {
                        msg.code = 1;
                        msg.content = "查看密码权限设置成功！";
                        AuditPermissionChange(m_LoginUser, id, "IsViewPwd", oldValue, isViewPwd, true);
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

                    long oldValue;
                    if (!CallerHoldsPermission(m_LoginUser, id, isModifyPwd, a => a.IsModifyPwd, "IsModifyPwd", msg, out oldValue))
                        return Json(msg);

                    M_Admin mUsers = new M_Admin { ID = id, IsModifyPwd = isModifyPwd };
                    int val = new B_Admin().SetModifyPwdPermission(mUsers);
                    if (val > 0)
                    {
                        msg.code = 1;
                        msg.content = "修改密码权限设置成功！";
                        AuditPermissionChange(m_LoginUser, id, "IsModifyPwd", oldValue, isModifyPwd, true);
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

                    long oldValue;
                    if (!CallerHoldsPermission(m_LoginUser, id, isResetSafePwd, a => a.IsResetSafePwd, "IsResetSafePwd", msg, out oldValue))
                        return Json(msg);

                    M_Admin mUsers = new M_Admin { ID = id, IsResetSafePwd = isResetSafePwd };
                    int val = new B_Admin().SetResetSafePwdPermission(mUsers);
                    if (val > 0)
                    {
                        msg.code = 1;
                        msg.content = "重置保险密码权限设置成功！";
                        AuditPermissionChange(m_LoginUser, id, "IsResetSafePwd", oldValue, isResetSafePwd, true);
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

                    long oldValue;
                    if (!CallerHoldsPermission(m_LoginUser, id, manageScope, a => a.ManageScope ?? 1, "ManageScope", msg, out oldValue))
                        return Json(msg);

                    M_Admin mUsers = new M_Admin { ID = id, ManageScope = manageScope };
                    int val = new B_Admin().SetManageScope(mUsers);
                    if (val > 0)
                    {
                        msg.code = 1;
                        msg.content = "管理范围设置成功！";
                        AuditPermissionChange(m_LoginUser, id, "ManageScope", oldValue, manageScope, true);
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

                    long oldValue;
                    if (!CallerHoldsPermission(m_LoginUser, id, isKill, a => a.IsKill, "IsKill", msg, out oldValue))
                        return Json(msg);

                    M_Admin mUsers = new M_Admin { ID = id, IsKill = isKill };
                    int val = new B_Admin().SetKillPermission(mUsers);
                    if (val > 0)
                    {
                        msg.code = 1;
                        msg.content = "点杀权限设置成功！";
                        AuditPermissionChange(m_LoginUser, id, "IsKill", oldValue, isKill, true);
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

                    long oldValue;
                    if (!CallerHoldsPermission(m_LoginUser, id, isRelease, a => a.IsRelease, "IsRelease", msg, out oldValue))
                        return Json(msg);

                    M_Admin mUsers = new M_Admin { ID = id, IsRelease = isRelease };
                    int val = new B_Admin().SetReleasePermission(mUsers);
                    if (val > 0)
                    {
                        msg.code = 1;
                        msg.content = "牌机权限设置成功！";
                        AuditPermissionChange(m_LoginUser, id, "IsRelease", oldValue, isRelease, true);
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

                    long oldValue;
                    if (!CallerHoldsPermission(m_LoginUser, id, isViewSafePwd, a => a.IsViewSafePwd, "IsViewSafePwd", msg, out oldValue))
                        return Json(msg);

                    M_Admin mUsers = new M_Admin { ID = id, IsViewSafePwd = isViewSafePwd };
                    int val = new B_Admin().SetViewSafePwdPermission(mUsers);
                    if (val > 0)
                    {
                        msg.code = 1;
                        msg.content = "查看保险柜密码权限设置成功！";
                        AuditPermissionChange(m_LoginUser, id, "IsViewSafePwd", oldValue, isViewSafePwd, true);
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

                    long oldValue;
                    if (!CallerHoldsPermission(m_LoginUser, id, isModifySafePwd, a => a.IsModifySafePwd, "IsModifySafePwd", msg, out oldValue))
                        return Json(msg);

                    M_Admin mUsers = new M_Admin { ID = id, IsModifySafePwd = isModifySafePwd };
                    int val = new B_Admin().SetModifySafePwdPermission(mUsers);
                    if (val > 0)
                    {
                        msg.code = 1;
                        msg.content = "修改保险柜密码权限设置成功！";
                        AuditPermissionChange(m_LoginUser, id, "IsModifySafePwd", oldValue, isModifySafePwd, true);
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
        /// 设置删除代理权限
        /// </summary>
        [AjaxOnly]
        [HttpPost]
        public ActionResult SetIsDeleteAgent(FormCollection form)
        {
            Msg msg = new Msg(0, "设置失败！");
            try
            {
                string id = form.Q<string>("ID");
                int isDeleteAgent = form.Q<int>("IsDeleteAgent", 0);
                M_LoginUser m_LoginUser = WebHelper.GetLoginInfo();

                if (m_LoginUser != null && !string.IsNullOrWhiteSpace(id))
                {
                    if (!CanManagePermissionTarget(m_LoginUser, id, msg))
                        return Json(msg);

                    long oldValue;
                    if (!CallerHoldsPermission(m_LoginUser, id, isDeleteAgent, a => a.IsDeleteAgent, "IsDeleteAgent", msg, out oldValue))
                        return Json(msg);

                    M_Admin mUsers = new M_Admin { ID = id, IsDeleteAgent = isDeleteAgent };
                    int val = new B_Admin().SetDeleteAgentPermission(mUsers);
                    if (val > 0)
                    {
                        msg.code = 1;
                        msg.content = "删除代理权限设置成功！";
                        AuditPermissionChange(m_LoginUser, id, "IsDeleteAgent", oldValue, isDeleteAgent, true);
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
        /// 设置查看代理密码权限（仅直属代理）
        /// </summary>
        [AjaxOnly]
        [HttpPost]
        public ActionResult SetIsViewAgentPwd(FormCollection form)
        {
            Msg msg = new Msg(0, "设置失败！");
            try
            {
                string id = form.Q<string>("ID");
                int isViewAgentPwd = form.Q<int>("IsViewAgentPwd", 0);
                M_LoginUser m_LoginUser = WebHelper.GetLoginInfo();

                if (m_LoginUser != null && !string.IsNullOrWhiteSpace(id))
                {
                    if (!CanManagePermissionTarget(m_LoginUser, id, msg))
                        return Json(msg);

                    long oldValue;
                    if (!CallerHoldsPermission(m_LoginUser, id, isViewAgentPwd, a => a.IsViewAgentPwd, "IsViewAgentPwd", msg, out oldValue))
                        return Json(msg);

                    M_Admin mUsers = new M_Admin { ID = id, IsViewAgentPwd = isViewAgentPwd };
                    int val = new B_Admin().SetViewAgentPwdPermission(mUsers);
                    if (val > 0)
                    {
                        msg.code = 1;
                        msg.content = "查看代理密码权限设置成功！";
                        AuditPermissionChange(m_LoginUser, id, "IsViewAgentPwd", oldValue, isViewAgentPwd, true);
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
        /// 设置修改代理密码权限（仅直属代理）
        /// </summary>
        [AjaxOnly]
        [HttpPost]
        public ActionResult SetIsModifyAgentPwd(FormCollection form)
        {
            Msg msg = new Msg(0, "设置失败！");
            try
            {
                string id = form.Q<string>("ID");
                int isModifyAgentPwd = form.Q<int>("IsModifyAgentPwd", 0);
                M_LoginUser m_LoginUser = WebHelper.GetLoginInfo();

                if (m_LoginUser != null && !string.IsNullOrWhiteSpace(id))
                {
                    if (!CanManagePermissionTarget(m_LoginUser, id, msg))
                        return Json(msg);

                    long oldValue;
                    if (!CallerHoldsPermission(m_LoginUser, id, isModifyAgentPwd, a => a.IsModifyAgentPwd, "IsModifyAgentPwd", msg, out oldValue))
                        return Json(msg);

                    M_Admin mUsers = new M_Admin { ID = id, IsModifyAgentPwd = isModifyAgentPwd };
                    int val = new B_Admin().SetModifyAgentPwdPermission(mUsers);
                    if (val > 0)
                    {
                        msg.code = 1;
                        msg.content = "修改代理密码权限设置成功！";
                        AuditPermissionChange(m_LoginUser, id, "IsModifyAgentPwd", oldValue, isModifyAgentPwd, true);
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
