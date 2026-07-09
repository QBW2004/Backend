using System;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.Linq;
using System.Text;
using System.Web.Mvc;
using YYT.BLL;
using YYT.BLL.EF;
using YYT.Common;
using YYT.Entity;
using YYT.Web.Filters;

namespace YYT.Web.Controllers
{
    /// <summary>
    /// 框架控制器
    /// </summary>
    //[MemberAuthorize]
    [Localization]
    public class MgrController : BaseController
    {
        #region 框架页
        /// <summary>
        /// 框架页
        /// </summary>
        /// <returns></returns>
        [MemberAuthorize]
        public ActionResult Index()
        {
            M_LoginUser loginUser = WebHelper.GetLoginInfo();
            return View(loginUser);
        }

        /// <summary>
        /// 首页面
        /// </summary>
        /// <returns></returns>
        [MemberAuthorize]
        public ActionResult Home()
        {
            try
            {

                M_LoginUser loginUser = WebHelper.GetLoginInfo();
                if (loginUser != null && loginUser.UserID > 0)
                {
                    ViewBag.WebHost = ConfigHelper.Get("WebHost");
                    ViewBag.LoginData = new B_Admin().GetSingle(new M_Admin { ID = loginUser.Accounts});
                    //ViewBag.Info = null;// new B_SystemInfo().GetHomePageInfo(loginUser.Accounts);
                }
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(MgrController), ex);
            }
            return View();
        }

        #endregion

        #region 获取菜单
        /// <summary>
        /// 获取菜单
        /// </summary>
        /// <returns></returns>
        [AjaxOnly]
        [HttpPost]
        public ActionResult GetMenu(FormCollection form)
        {
            try
            {
                StringBuilder json = new StringBuilder();
                M_LoginUser loginUser = WebHelper.GetLoginInfo();

                List<M_BaseModule> menuList = new B_SystemInfo().GetMenus(loginUser.UserID);

                json.Append("{");
                json.AppendFormat("\"total\":{0},\"rows\":[", (menuList != null ? menuList.Count : 0));

                M_BaseModule[] rootMenus = menuList.AsEnumerable().Where(m => m.IsMenu == false && m.ParentID == 0).OrderBy(m => m.OrderNo).ToArray();
                for (int i = 0; i < rootMenus.Length; i++)
                {
                    M_BaseModule root = rootMenus[i];
                    json.Append("{");
                    json.AppendFormat("\"id\":\"{0}\"", root.ModuleID);
                    json.AppendFormat(",\"title\":\"{0}\"", root.Title);
                    json.AppendFormat(",\"link\":\"{0}\"", root.Link);
                    json.Append(",\"children\":[");
                    M_BaseModule[] childMenus = menuList.AsEnumerable().Where(m => root.ModuleID == m.ParentID).OrderBy(m => m.OrderNo).ToArray();

                    for (int j = 0; j < childMenus.Length; j++)
                    {
                        M_BaseModule child = childMenus[j];
                        json.Append("{");
                        json.AppendFormat("\"id\":\"{0}\"", child.ModuleID);
                        json.AppendFormat(",\"title\":\"{0}\"", child.Title);
                        json.AppendFormat(",\"link\":\"{0}\"", child.Link);
                        json.Append("}");
                        if (j < childMenus.Length - 1)
                            json.Append(",");
                    }

                    json.Append("]}");
                    if (i < rootMenus.Length - 1)
                        json.Append(",");
                }

                json.Append("]}");

                return Content(json.ToString());
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(MgrController), ex);
            }
            return Content(TipMsg.EMPTY_GRID_DATA);
        }

        /// <summary>
        /// 获取角色菜单
        /// </summary>
        /// <param name="form"></param>
        /// <returns></returns>
        [AjaxOnly]
        [HttpPost]
        public ActionResult GetRoleMenus(FormCollection form)
        {
            try
            {
                int roleID = form.Q<int>("RoleID", 0);
                if (roleID == 0)
                {
                    return Content(TipMsg.EMPTY_GRID_DATA);
                }

                StringBuilder json = new StringBuilder();
                List<M_BaseModule> menuList = new B_SystemInfo().GetRoleMenus<M_BaseModule>(roleID);

                json.Append("{");
                json.AppendFormat("\"total\":{0},\"rows\":[", (menuList != null ? menuList.Count : 0));

                M_BaseModule[] rootMenus = menuList.AsEnumerable().Where(m => m.IsMenu == false && m.ParentID == 0).OrderBy(m => m.OrderNo).ToArray();
                for (int i = 0; i < rootMenus.Length; i++)
                {
                    M_BaseModule root = rootMenus[i];
                    json.Append("{");
                    json.AppendFormat("\"id\":\"{0}\"", root.ModuleID);
                    json.AppendFormat(",\"title\":\"{0}\"", root.Title);
                    json.AppendFormat(",\"link\":\"{0}\"", root.Link);
                    json.Append(",\"children\":[");
                    M_BaseModule[] childMenus = menuList.AsEnumerable().Where(m => root.ModuleID == m.ParentID).OrderBy(m => m.OrderNo).ToArray();

                    for (int j = 0; j < childMenus.Length; j++)
                    {
                        M_BaseModule child = childMenus[j];
                        json.Append("{");
                        json.AppendFormat("\"id\":\"{0}\"", child.ModuleID);
                        json.AppendFormat(",\"title\":\"{0}\"", child.Title);
                        json.AppendFormat(",\"link\":\"{0}\"", child.Link);
                        json.Append("}");
                        if (j < childMenus.Length - 1)
                            json.Append(",");
                    }

                    json.Append("]}");
                    if (i < rootMenus.Length - 1)
                        json.Append(",");
                }

                json.Append("]}");

                return Content(json.ToString());
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(MgrController), ex);
            }
            return Content(TipMsg.EMPTY_GRID_DATA);
        }
        #endregion

        #region 用户管理页
        /// <summary>
        /// 用户管理页
        /// </summary>
        /// <returns></returns>
        [MgrAuthorize]
        public ActionResult UserList()
        {
            return View();
        }
        #endregion

        #region 添加用户
        /// <summary>
        /// 添加用户
        /// </summary>
        /// <returns></returns>
        [HttpPost]
        [AjaxOnly]
        [MgrAuthorize]
        public JsonResult AddUser(FormCollection form)
        {
            int roleID = form.Q<int>("RoleID");
            string uname = form.Q<string>("UName");
            string accouns = form.Q<string>("UAccounts");
            string upwd = form.Q<string>("UPwd");
            string remark = form.Q<string>("Remark");
            int isDel = form.Q<int>("IsDel", 0);

            if (roleID < 1)
                return Json(new Msg(0, "请选择角色"));
            if (String.IsNullOrWhiteSpace(uname))
                return Json(new Msg(0, "请填写用户名"));
            if (String.IsNullOrWhiteSpace(accouns))
                return Json(new Msg(0, "请填写账号"));
            if (String.IsNullOrWhiteSpace(upwd))
                return Json(new Msg(0, "请填写密码"));

            upwd = DESEncrypt.Md5(upwd);

            Msg msg = new Msg(0, "添加失败");
            try
            {
                msg = new B_SystemInfo().AddMgrUser(roleID, uname, accouns, upwd, remark);
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(MgrController), ex);
            }
            return Json(msg);
        }
        #endregion

        #region 修改用户
        /// <summary>
        /// 修改用户
        /// </summary>
        /// <param name="form"></param>
        /// <returns></returns>
        [HttpPost]
        [AjaxOnly]
        [MgrAuthorize]
        public JsonResult EditUser(FormCollection form)
        {
            long userID = form.Q<long>("UserID", 0);
            int roleId = form.Q<int>("RoleID", 0);
            string uname = form.Q<string>("UName");
            string accouns = form.Q<string>("UAccounts");
            string upwd = form.Q<string>("UPwd");
            string remark = form.Q<string>("Remark");
            int isDel = form.Q<int>("IsDel", 0);
            if (userID < 1)
                return Json(new Msg(0, "用户ID不能为空"));
            if (roleId < 1)
                return Json(new Msg(0, "角色不能为空"));
            if (String.IsNullOrWhiteSpace(uname))
                return Json(new Msg(0, "请填写用户名"));
            if (String.IsNullOrWhiteSpace(accouns))
                return Json(new Msg(0, "请填写账号"));

            if (!String.IsNullOrWhiteSpace(upwd))
                upwd = DESEncrypt.Md5(upwd);

            Msg msg = new Msg(0, "修改失败");
            try
            {
                msg = new B_SystemInfo().EditMgrUser(userID, roleId, uname, upwd, isDel, remark);
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(MgrController), ex);
            }
            return Json(msg);
        }
        #endregion

        #region 删除用户
        /// <summary>
        /// 删除用户
        /// </summary>
        /// <returns></returns>
        [HttpPost]
        [AjaxOnly]
        [MgrAuthorize]
        public ActionResult DelUser(FormCollection form)
        {
            long userID = form.Q<long>("UserID", 0);
            if (userID == 1)
                return Json(new Msg { code = 0, content = "系统管理员用户不能删除" });

            Msg msg = new Msg(0, "删除失败");
            try
            {
                msg = new B_SystemInfo().DelMgrUser(userID);
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(MgrController), ex);
            }
            return Json(msg);
        }
        #endregion

        #region 获取用户列表
        /// <summary>
        /// 获取用户列表
        /// </summary>
        /// <returns></returns>
        [HttpPost]
        [AjaxOnly]
        [MgrAuthorize]
        public JsonResult GetUserList(FormCollection form)
        {
            int roleID = form.Q<int>("RoleID", 0);//0表示查询全部
            string usrNameOrAccounts = form.Q<string>("usrNameOrAccounts");//支持用户名字、账号模糊查询

            NameValueCollection kv = new NameValueCollection();
            kv.Add("usrNameOrAccounts", usrNameOrAccounts);
            if (roleID > 0)
                kv.Add("RoleID", roleID.ToString());

            M_EasyuiGridData<M_MgrUsers> list = new M_EasyuiGridData<M_MgrUsers>();
            try
            {
                list = new B_SystemInfo().GetMgrUsersList(kv);
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(MgrController), ex);
            }

            return Json(list);
        }
        #endregion

        #region 添加角色
        /// <summary>
        /// 添加角色
        /// </summary>
        /// <param name="form"></param>
        /// <returns></returns>
        [HttpPost]
        [AjaxOnly]
        [MgrAuthorize]
        public JsonResult AddRole(FormCollection form)
        {
            string roleName = form.Q<string>("RoleName");
            if (String.IsNullOrWhiteSpace(roleName))
                return Json(new Msg { code = 0, content = "角色名称不能为空" });

            Msg msg = new Msg(0, "添加失败");
            try
            {
                msg = new B_SystemInfo().AddRole(roleName);
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(MgrController), ex);
            }
            return Json(msg);
        }
        #endregion

        #region 删除角色
        /// <summary>
        /// 删除角色
        /// </summary>
        /// <param name="form"></param>
        /// <returns></returns>
        [HttpPost]
        [AjaxOnly]
        [MgrAuthorize]
        public JsonResult DelRole(FormCollection form)
        {
            int roleID = form.Q<int>("RoleID");
            if (roleID == 1)
                return Json(new Msg { code = 0, content = "系统管理员角色不能删除" });
            if (roleID < 1)
                return Json(new Msg { code = 0, content = "请选择角色后再删除" });

            Msg msg = new Msg(0, "删除失败");
            try
            {
                msg = new B_SystemInfo().DelRole(roleID);
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(MgrController), ex);
            }
            return Json(msg);
        }
        #endregion

        #region 设置用户角色
        /// <summary>
        /// 设置用户角色
        /// </summary>
        /// <param name="form"></param>
        /// <returns></returns>
        [HttpPost]
        [AjaxOnly]
        [MgrAuthorize]
        public JsonResult SetUserRole(FormCollection form)
        {
            long userId = form.Q<long>("UserID");
            int roleId = form.Q<int>("RoleID");
            if (userId == 1)
                return Json(new Msg { code = 0, content = "系统管理员不能设置，已经拥有最高权限了。" });
            int isSet = form.Q<int>("IsSet", 0);

            Msg msg = new Msg(0, "设置失败");
            try
            {
                msg = new B_SystemInfo().SetUserRole(userId, roleId, isSet);
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(MgrController), ex);
            }
            return Json(msg);
        }
        #endregion

        #region 获取角色列表
        /// <summary>
        /// 获取角色列表
        /// </summary>
        /// <returns></returns>
        [HttpPost]
        [AjaxOnly]
        [MgrAuthorize]
        public JsonResult GetRoleList()
        {
            List<M_Roles> list = new List<M_Roles>();
            try
            {
                list = new B_SystemInfo().GetRoles(new NameValueCollection());
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(MgrController), ex);
            }

            var treeData = new M_Roles_TreeDataModel
            {
                id = 0,
                text = "后台管理系统",
                iconCls = "icon-computer",
                children = new List<M_Roles_TreeDataModel>()
                {
                    new M_Roles_TreeDataModel {
                        id = 1,
                        text = "系统管理员",
                        iconCls = "icon-user_red",
                        children = list.Where(r=>r.RoleID != 1).Select(r=> new M_Roles_TreeDataModel
                        {
                            id = r.RoleID ,
                            text = r.RoleName ,
                            iconCls = "icon-user_suit",
                            children = new List<M_Roles_TreeDataModel>()
                        }).ToList()
                    }
                }
            };

            return Json(treeData);
        }
        #endregion

        #region 角色列表
        /// <summary>
        /// 角色列表
        /// </summary>
        /// <returns></returns>
        [MgrAuthorize]
        public ActionResult RoleList()
        {
            return View();
        }

        [HttpPost]
        [AjaxOnly]
        [MgrAuthorize]
        public JsonResult GetRoleGridList(FormCollection form)
        {
            M_EasyuiGridData<M_Roles> list = new M_EasyuiGridData<M_Roles>();
            try
            {
                NameValueCollection kv = new NameValueCollection();
                kv.Add("RoleName", form.Q<string>("RoleName", ""));

                list = new B_SystemInfo().GetGridRoles(kv);
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(MgrController), ex);
            }

            return Json(list);
        }
        #endregion

        #region 角色菜单权限配置
        /// <summary>
        /// 角色菜单权限配置
        /// </summary>
        /// <returns></returns>
        [MgrAuthorize]
        public ActionResult RoleMenuList()
        {
            return View();
        }
        /// <summary>
        /// 获取所有菜单
        /// </summary>
        /// <returns></returns>
        [HttpPost]
        [AjaxOnly]
        [MgrAuthorize]
        public JsonResult GetAllMenus(FormCollection form)
        {
            string menuTitle = form.Q<string>("MenuTitle");
            int roleID = form.Q<int>("RoleID");

            M_EasyuiGridData<M_RoleMenus> list = new M_EasyuiGridData<M_RoleMenus>();
            try
            {
                List<M_RoleMenus> menuList = new B_SystemInfo().GetRoleMenus<M_RoleMenus>(roleID, menuTitle);
                list.total = menuList.Count;
                list.rows = menuList;
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(MgrController), ex);
            }

            return Json(list);
        }
        /// <summary>
        /// 设置角色菜单
        /// </summary>
        /// <returns></returns>
        [HttpPost]
        [AjaxOnly]
        [MgrAuthorize]
        public JsonResult SetRoleMenu(FormCollection form)
        {
            int roleID = form.Q<int>("RoleID", 0);
            int moduleID = form.Q<int>("ModuleID", 0);
            int isSet = form.Q<int>("IsSet", 0);

            if (roleID == 0)
                return Json(new { code = EServerData.General_Error, msg = "请选择要配置的角色！" });
            if (moduleID == 0)
                return Json(new { code = EServerData.General_Error, msg = "请选择要配置的菜单！" });


            Msg msg = new Msg(0, "设置失败");
            try
            {
                msg = new B_SystemInfo().SetRoleMenus(roleID, moduleID, isSet);
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(MgrController), ex);
            }
            return Json(msg);
        }
        #endregion


    }
}
