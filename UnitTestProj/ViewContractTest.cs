using System;
using System.IO;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace UnitTestProj
{
    [TestClass]
    public class ViewContractTest
    {
        private static DirectoryInfo FindRepoRoot()
        {
            DirectoryInfo dir = new DirectoryInfo(AppDomain.CurrentDomain.BaseDirectory);
            while (dir != null && !File.Exists(Path.Combine(dir.FullName, "MTH_Mgr_MySQL.sln")))
                dir = dir.Parent;

            Assert.IsNotNull(dir, "Cannot locate repository root.");
            return dir;
        }

        private static string ReadRepoFile(string relativePath)
        {
            DirectoryInfo dir = FindRepoRoot();
            return File.ReadAllText(Path.Combine(dir.FullName, relativePath));
        }

        [TestMethod]
        public void AdminPermissionViewExposesVisiblePermissionSwitches()
        {
            string view = ReadRepoFile(@"TTY.Web\Areas\Game\Views\Admin\Index.cshtml");
            string controller = ReadRepoFile(@"TTY.Web\Areas\Game\Controllers\AdminController.cs");
            string adminBll = ReadRepoFile(@"YYT.BLL\EF\B_Admin.cs");

            StringAssert.Contains(view, "showAdminToast");
            StringAssert.Contains(view, "showAdminResult");
            StringAssert.Contains(view, "setFrozen");
            StringAssert.Contains(view, "/Game/Admin/SetFrozen");
            StringAssert.Contains(view, "setProbability");
            StringAssert.Contains(view, "/Game/Admin/SetIsProbability");
            StringAssert.Contains(view, "setIsKicking");
            StringAssert.Contains(view, "/Game/Admin/SetIsKicking");
            StringAssert.Contains(view, "setIsKill");
            StringAssert.Contains(view, "/Game/Admin/SetIsKill");
            StringAssert.Contains(view, "setIsRelease");
            StringAssert.Contains(view, "/Game/Admin/SetIsRelease");
            StringAssert.Contains(view, "setIsUpDown");
            StringAssert.Contains(view, "/Game/Admin/SetIsUpDown");
            StringAssert.Contains(view, "setIsDelete");
            StringAssert.Contains(view, "/Game/Admin/SetIsDelete");
            StringAssert.Contains(view, "setIsModifyPwd");
            StringAssert.Contains(view, "/Game/Admin/SetIsModifyPwd");
            StringAssert.Contains(view, "setIsDeleteAgent");
            StringAssert.Contains(view, "/Game/Admin/SetIsDeleteAgent");
            StringAssert.Contains(view, "setIsViewPwd");
            StringAssert.Contains(view, "/Game/Admin/SetIsViewPwd");
            StringAssert.Contains(view, "setIsViewAgentPwd");
            StringAssert.Contains(view, "/Game/Admin/SetIsViewAgentPwd");
            StringAssert.Contains(view, "setIsModifyAgentPwd");
            StringAssert.Contains(view, "/Game/Admin/SetIsModifyAgentPwd");
            StringAssert.Contains(view, "踢人范围:跟随管理范围");
            StringAssert.Contains(view, "setManageScope");
            StringAssert.Contains(view, "/Game/Admin/SetManageScope");
            StringAssert.Contains(view, "启用删除用户");
            StringAssert.Contains(view, "禁用删除用户");
            StringAssert.Contains(view, "启用修改密码");
            StringAssert.Contains(view, "禁用修改密码");
            StringAssert.Contains(view, "启用删除代理");
            StringAssert.Contains(view, "禁用删除代理");
            StringAssert.Contains(view, "启用查看用户密码");
            StringAssert.Contains(view, "禁用查看用户密码");
            StringAssert.Contains(view, "启用查看代理密码");
            StringAssert.Contains(view, "禁用查看代理密码");
            StringAssert.Contains(view, "启用修改代理密码");
            StringAssert.Contains(view, "禁用修改代理密码");
            Assert.IsFalse(view.Contains("field=\"IsDeleteAgent\""));
            Assert.IsFalse(view.Contains("field=\"IsViewPwd\""));
            Assert.IsFalse(view.Contains("field=\"IsViewAgentPwd\""));
            Assert.IsFalse(view.Contains("field=\"IsModifyAgentPwd\""));
            Assert.IsFalse(view.Contains("showMsg(data);"));
            Assert.IsFalse(view.Contains("启用重置保险"));
            Assert.IsFalse(view.Contains("启用赠送"));
            Assert.IsFalse(view.Contains("启用开代理"));
            Assert.IsFalse(view.Contains("showLimitWin"));
            Assert.IsFalse(view.Contains("SaveAgencyLimit"));
            Assert.IsFalse(view.Contains("保险柜密码"));

            Assert.IsFalse(view.Contains("setIsModifySafePwd"));
            Assert.IsFalse(view.Contains("启用保险柜"));
            Assert.IsFalse(view.Contains("setIsViewSafePwd"));
            Assert.IsTrue(view.IndexOf("setIsUpDown", StringComparison.Ordinal) < view.IndexOf("setIsDelete", StringComparison.Ordinal));
            Assert.IsTrue(view.IndexOf("setIsDelete", StringComparison.Ordinal) < view.IndexOf("setIsDeleteAgent", StringComparison.Ordinal));
            Assert.IsTrue(view.IndexOf("setIsDeleteAgent", StringComparison.Ordinal) < view.IndexOf("setIsModifyPwd", StringComparison.Ordinal));
            Assert.IsTrue(view.IndexOf("setIsModifyPwd", StringComparison.Ordinal) < view.IndexOf("setIsViewPwd", StringComparison.Ordinal));
            Assert.IsTrue(view.IndexOf("setIsViewPwd", StringComparison.Ordinal) < view.IndexOf("setIsViewAgentPwd", StringComparison.Ordinal));
            Assert.IsTrue(view.IndexOf("setIsViewAgentPwd", StringComparison.Ordinal) < view.IndexOf("setIsModifyAgentPwd", StringComparison.Ordinal));

            StringAssert.Contains(controller, "public ActionResult SetFrozen");
            StringAssert.Contains(controller, "public ActionResult SetIsProbability");
            StringAssert.Contains(controller, "public ActionResult SetIsKicking");
            StringAssert.Contains(controller, "public ActionResult SetIsDelete");
            StringAssert.Contains(controller, "public ActionResult SetIsKill");
            StringAssert.Contains(controller, "public ActionResult SetIsRelease");
            StringAssert.Contains(controller, "public ActionResult SetIsModifyPwd");
            StringAssert.Contains(controller, "public ActionResult SetIsModifySafePwd");
            StringAssert.Contains(controller, "public ActionResult SetIsUpDown");
            StringAssert.Contains(controller, "public ActionResult SetIsDeleteAgent");
            StringAssert.Contains(controller, "public ActionResult SetIsViewPwd");
            StringAssert.Contains(controller, "public ActionResult SetIsViewAgentPwd");
            StringAssert.Contains(controller, "public ActionResult SetIsModifyAgentPwd");
            StringAssert.Contains(controller, "public ActionResult SetKickScope");
            StringAssert.Contains(controller, "public ActionResult SetManageScope");
            StringAssert.Contains(adminBll, "public int SetFrozen");
            StringAssert.Contains(adminBll, "public int SetProbability");
            StringAssert.Contains(adminBll, "public int SetKicking");
            StringAssert.Contains(adminBll, "public int SetDelete");
            StringAssert.Contains(adminBll, "public int SetKillPermission");
            StringAssert.Contains(adminBll, "public int SetReleasePermission");
            StringAssert.Contains(adminBll, "public int SetModifyPwdPermission");
            StringAssert.Contains(adminBll, "public int SetModifySafePwdPermission");
            StringAssert.Contains(adminBll, "public int SetDeleteAgentPermission");
            StringAssert.Contains(adminBll, "public int SetViewAgentPwdPermission");
            StringAssert.Contains(adminBll, "public int SetModifyAgentPwdPermission");
            StringAssert.Contains(adminBll, "public int SetUpDown");
            StringAssert.Contains(adminBll, "public int SetKickScope");
            StringAssert.Contains(adminBll, "public int SetManageScope");
        }

        [TestMethod]
        public void AdminPermissionActionsRequireManagedAgencyRangeAndModifyPasswordUsesExistingPermission()
        {
            string controller = ReadRepoFile(@"TTY.Web\Areas\Game\Controllers\AdminController.cs");

            StringAssert.Contains(controller, "private bool CanManagePermissionTarget");
            StringAssert.Contains(controller, "IsTargetAgencyInManagedScope(ef, loginUser, id)");
            StringAssert.Contains(controller, "只能设置自己管理范围内的下级代理");
            StringAssert.Contains(controller, "if (!CanManagePermissionTarget(m_LoginUser, id, msg))");
            StringAssert.Contains(controller, "M_Admin mUsers = new M_Admin { ID = id, IsModifyPwd = isModifyPwd };");
            StringAssert.Contains(controller, "new B_Admin().SetModifyPwdPermission(mUsers)");
        }

        [TestMethod]
        public void AgencyCreationDefaultsEnableRequestedOperationalPermissionsOnly()
        {
            string controller = ReadRepoFile(@"TTY.Web\Areas\Game\Controllers\AgencyInfoController.cs");
            string adminBll = ReadRepoFile(@"YYT.BLL\EF\B_Admin.cs");

            StringAssert.Contains(controller, "ApplyDefaultAgencyPermissions(entity);");
            StringAssert.Contains(controller, "entity.IsCreateAgent = createAgentPermission;");
            StringAssert.Contains(controller, "form.Q<long>(\"IsCreateAgent\", 1)");
            // 1.0.23 权限设计：BLL 新建代理默认权限不得清零 IsCreateAgent，请求值须透传并由 ?? 1 兜底缺省
            StringAssert.Contains(adminBll, "entity.IsCreateAgent = entity.IsCreateAgent ?? 1;");
            Assert.IsFalse(adminBll.Contains("entity.IsCreateAgent = 0;"));
        }

        [TestMethod]
        public void AgentPasswordAndDeletePermissionsAreScopedToDirectSubordinates()
        {
            string adminView = ReadRepoFile(@"TTY.Web\Areas\Game\Views\Admin\Index.cshtml");
            string agencyView = ReadRepoFile(@"TTY.Web\Areas\Game\Views\AgencyInfo\Index.cshtml");
            string agencyController = ReadRepoFile(@"TTY.Web\Areas\Game\Controllers\AgencyInfoController.cs");
            string adminEntity = ReadRepoFile(@"YYT.Entity\EF\M_Admin.cs");
            string loginUserEntity = ReadRepoFile(@"YYT.Entity\Sys\M_LoginUser.cs");
            string sqlUpdate = ReadRepoFile(@"mth_update_agent_permissions.sql");

            StringAssert.Contains(adminEntity, "public long? IsDeleteAgent { get; set; }");
            StringAssert.Contains(adminEntity, "public long? IsViewAgentPwd { get; set; }");
            StringAssert.Contains(adminEntity, "public long? IsModifyAgentPwd { get; set; }");
            StringAssert.Contains(loginUserEntity, "IsViewAgentPwd");
            StringAssert.Contains(loginUserEntity, "IsModifyAgentPwd");

            // 代理管理页：按权限显示删除/改密入口，目标范围跟随管理范围
            StringAssert.Contains(agencyView, "canDeleteAgent");
            StringAssert.Contains(agencyView, "canModifyAgentPwd");
            StringAssert.Contains(agencyView, "loginUser?.IsDeleteAgent == 1");
            StringAssert.Contains(agencyView, "loginUser?.IsModifyAgentPwd == 1");
            StringAssert.Contains(agencyView, "if (canModifyAgentPwd)");
            StringAssert.Contains(agencyView, "if (canDeleteAgent)");
            StringAssert.Contains(agencyView, "loginUser?.IsViewAgentPwd == 1");

            // 服务端：查看代理密码按 IsViewAgentPwd + 管理范围双重校验；删除代理仅超管；
            // 改代理密码走统一 CanManageAgent/管理范围（手机端权限体系）
            StringAssert.Contains(agencyController, "IsViewAgentPwd != 1");
            StringAssert.Contains(agencyController, "IsTargetAgencyInManagedScope(ef, loginUser, item.ID)");
            StringAssert.Contains(agencyController, "item.PWD = null");
            StringAssert.Contains(agencyController, "只有超级管理员可以删除代理！");
            StringAssert.Contains(agencyController, "CanManageAgent(ef, loginUser");
            StringAssert.Contains(agencyController, "IsModifyPwd != 1");

            // 数据库脚本包含新增字段
            StringAssert.Contains(sqlUpdate, "IsDeleteAgent");
            StringAssert.Contains(sqlUpdate, "IsViewAgentPwd");
            StringAssert.Contains(sqlUpdate, "IsModifyAgentPwd");
        }

        [TestMethod]
        public void OnlineUsersListIsScopedToManagedAgencies()
        {
            string userInfoController = ReadRepoFile(@"TTY.Web\Areas\Game\Controllers\UserInfoController.cs");

            StringAssert.Contains(userInfoController, "public ActionResult GetOnlineUsers()");
            StringAssert.Contains(userInfoController, "GetManagedPlayerAgencyAccounts(ef, loginUser)");
            StringAssert.Contains(userInfoController, "visibleIds.Contains(c.ID)");
            Assert.IsFalse(userInfoController.Contains("FillPlayerLastLogin(players)"));
        }

        [TestMethod]
        public void TableRecordsMenuShowsOnlyForSuperAdmin()
        {
            string view = ReadRepoFile(@"TTY.Web\Views\Mgr\Index.cshtml");

            StringAssert.Contains(view, "href=\"/Game/GameRecord/TableRecords\"");
            StringAssert.Contains(view, "Resources.Language.String18");
            Assert.IsTrue(view.IndexOf("@if (loginUser?.UserPriv == 0)", StringComparison.Ordinal) < view.IndexOf("href=\"/Game/GameRecord/TableRecords\"", StringComparison.Ordinal));
            Assert.IsFalse(view.Contains("桌子账目按代理需求隐藏"));
        }

        [TestMethod]
        public void OnlinePlayersKickActionPostsToExistingKickEndpoints()
        {
            string view = ReadRepoFile(@"TTY.Web\Areas\Game\Views\UserInfo\OnlinePlayers.cshtml");

            StringAssert.Contains(view, "request(_url, { UserID: id }");
            StringAssert.Contains(view, "/Game/UserInfo/KickAllPlayer");
            StringAssert.Contains(view, "/Game/UserInfo/KickPlayer");
        }

        [TestMethod]
        public void UserInfoViewShowsLineKickEntryForFirstLevelAgentWithKickPermission()
        {
            string view = ReadRepoFile(@"TTY.Web\Areas\Game\Views\UserInfo\Index.cshtml");

            StringAssert.Contains(view, "loginUser?.UserPriv == 1 && loginUser?.IsKicking == 1");
            StringAssert.Contains(view, "剔除整条线在线玩家");
            StringAssert.Contains(view, "kickPlayer();");
        }

        [TestMethod]
        public void UserInfoKickActionDoesNotEmbedRazorExpressionInsideJavascriptIf()
        {
            string view = ReadRepoFile(@"TTY.Web\Areas\Game\Views\UserInfo\Index.cshtml");

            StringAssert.Contains(view, "var canKickWholeLine =");
            Assert.IsFalse(view.Contains("if (@("));
        }

        [TestMethod]
        public void UserInfoViewHidesCurrentGameStateColumns()
        {
            string view = ReadRepoFile(@"TTY.Web\Areas\Game\Views\UserInfo\Index.cshtml");

            StringAssert.Contains(view, "field=\"CurrentGameName\" width=\"120\" hidden=\"true\"");
            StringAssert.Contains(view, "field=\"CurrentRoomId\" width=\"80\" hidden=\"true\"");
            StringAssert.Contains(view, "field=\"CurrentTableId\" width=\"80\" hidden=\"true\"");
            StringAssert.Contains(view, "field=\"CurrentSeatId\" width=\"80\" hidden=\"true\"");
            StringAssert.Contains(view, "field=\"CurrentBetCoins\" width=\"90\" formatter=\"fmtCoins\" hidden=\"true\"");
            StringAssert.Contains(view, "field=\"CurrentWinLose\" width=\"90\" formatter=\"fmtCoins\" hidden=\"true\"");
        }

        [TestMethod]
        public void UserInfoViewUsesDefaultDeleteAndToastResultMessages()
        {
            string view = ReadRepoFile(@"TTY.Web\Areas\Game\Views\UserInfo\Index.cshtml");
            string controller = ReadRepoFile(@"TTY.Web\Areas\Game\Controllers\UserInfoController.cs");

            StringAssert.Contains(view, "showUserToast");
            StringAssert.Contains(view, "showUserResult");
            StringAssert.Contains(view, ".delay(5000)");
            StringAssert.Contains(view, "@Html.Raw(\"arr.push('<a href=\\\"javascript:void(0)\\\" class=\\\"blue Lpd5\\\" onclick=\\\"deleteUser");
            StringAssert.Contains(view, "loginUser.UserPriv == 0 || (loginUser.IsViewPwd == 1 && loginUser.IsModifyPwd == 1)");
            StringAssert.Contains(view, "function showChgSafePwdWin");
            Assert.IsFalse(view.Contains("showMsg(data);"));
            Assert.IsFalse(view.Contains("class=\\\"red Lpd5\\\""));
            Assert.IsFalse(view.Contains("class=\\\"green Lpd5\\\""));
            StringAssert.Contains(view, "field=\"PWD\"");
            Assert.IsFalse(view.Contains("field=\"GRADE\""));
            Assert.IsFalse(view.Contains("ResetSafePwd"));
            Assert.IsFalse(view.Contains("重置保险柜密码"));
            StringAssert.Contains(view, "loginUser.UserPriv == 0 || loginUser.IsDelete == 1");
            Assert.IsFalse(view.Contains("\n                arr.push('<a href=\"javascript:void(0)\" class=\"red Lpd5\" onclick=\"deleteUser"));
            StringAssert.Contains(controller, "loginUser.UserPriv > 0 && loginUser.IsDelete != 1");
            StringAssert.Contains(controller, "没有删除用户权限");
        }

        [TestMethod]
        public void UserInfoViewAutoRefreshesGridWithoutRefreshScoreAction()
        {
            string view = ReadRepoFile(@"TTY.Web\Areas\Game\Views\UserInfo\Index.cshtml");
            string controller = ReadRepoFile(@"TTY.Web\Areas\Game\Controllers\UserInfoController.cs");
            string msgDefine = ReadRepoFile(@"TTY.Web\Config\MsgDefine.config");
            string msgType = ReadRepoFile(@"YYT.Remote\EScMsgType.cs");

            StringAssert.Contains(view, "startUserInfoAutoRefresh");
            StringAssert.Contains(view, "datagrid('reload')");
            Assert.IsFalse(view.Contains("刷新游戏分数"));
            Assert.IsFalse(view.Contains("RefreshScore("));
            Assert.IsFalse(view.Contains("/Game/UserInfo/RefreshScore"));
            Assert.IsFalse(controller.Contains("ActionResult RefreshScore"));
            Assert.IsFalse(controller.Contains("private Msg RefreshScore"));
            Assert.IsFalse(msgDefine.Contains("刷新游戏分数"));
            Assert.IsFalse(msgDefine.Contains("key=\"RU\""));
            Assert.IsFalse(msgType.Contains("RU,"));
        }

        [TestMethod]
        public void AgencyInfoOperationColumnKeepsLimitActionAndRemovesQuickQueryAction()
        {
            string view = ReadRepoFile(@"TTY.Web\Areas\Game\Views\AgencyInfo\Index.cshtml");
            string adminView = ReadRepoFile(@"TTY.Web\Areas\Game\Views\Admin\Index.cshtml");
            string controller = ReadRepoFile(@"TTY.Web\Areas\Game\Controllers\AgencyInfoController.cs");
            string adminBll = ReadRepoFile(@"YYT.BLL\EF\B_Admin.cs");
            string adminEntity = ReadRepoFile(@"YYT.Entity\EF\M_Admin.cs");

            StringAssert.Contains(view, "field=\"OPT\"");
            StringAssert.Contains(view, "width=\"520\"");
            StringAssert.Contains(view, "formatter=\"fmtOpt\"");
            StringAssert.Contains(adminView, "field=\"PWD\" width=\"520\" formatter=\"fmtOpt\"");
            StringAssert.Contains(view, "canShowAgencyLimit");
            StringAssert.Contains(view, "fmtID");
            StringAssert.Contains(view, "onclick=\"quickQuery");
            StringAssert.Contains(view, "showLimitWin");
            StringAssert.Contains(adminView, "canShowAgencyLimit");
            StringAssert.Contains(adminView, "fmtID");
            StringAssert.Contains(adminView, "onclick=\"quickQuery");
            Assert.IsFalse(adminView.Contains("showLimitWin"));
            StringAssert.Contains(controller, "AgencyRules.CanCreateChild(loginUser.UserPriv ?? -1, parentAdmin.AGENCY_LIMIT, parentAdmin.IsCreateAgent, directChildCount)");
            StringAssert.Contains(controller, "ViewBag.CanCreateChildAgent");
            StringAssert.Contains(adminBll, "FirstOrDefault");
            StringAssert.Contains(controller, "directChildCount");
            StringAssert.Contains(controller, "当前代理创建已达上限，请联系上级代理！");
            StringAssert.Contains(view, "showAgencyLimitToast");
            StringAssert.Contains(view, "showAgencyResult");
            StringAssert.Contains(view, "showAgencyToast");
            StringAssert.Contains(view, "同步删除整条下级代理线及相关玩家数据");
            StringAssert.Contains(controller, "public ActionResult CanAddAgency");
            StringAssert.Contains(view, "/Game/AgencyInfo/CanAddAgency");
            StringAssert.Contains(view, ".delay(5000)");
            StringAssert.Contains(view, "$('#form3').form('reset');");
            StringAssert.Contains(view, "for (var i = 8; i < 31; i++)");
            Assert.IsFalse(adminView.Contains("for (var i = 8; i < 31; i++)"));
            StringAssert.Contains(controller, "entity.AGENCY_LIMIT = entity.AGENCY_LIMIT ?? AgencyRules.UnlimitedAgencyLimit");
            StringAssert.Contains(controller, "GetManagedAgencyAccounts(ef, loginUser)");
            StringAssert.Contains(adminBll, "GetAgencyLineAccounts(ef, entity.ID)");
            StringAssert.Contains(adminBll, "ef.Users.RemoveRange(users)");
            StringAssert.Contains(adminBll, "ef.Admins.RemoveRange(admins)");
            StringAssert.Contains(view, "closest('tr.datagrid-row').attr('datagrid-row-index')");
            StringAssert.Contains(adminView, "closest('tr.datagrid-row').attr('datagrid-row-index')");
            Assert.IsFalse(controller.Contains("loginUser.UserPriv > 0 && loginUser.IsCreateAgent != 1"));
            Assert.IsFalse(controller.Contains("target.IsCreateAgent != 1"));
            Assert.IsFalse(controller.Contains("new B_Admin().GetSingle(new M_Admin { ID = loginUser.Accounts })"));
            StringAssert.Contains(adminBll, "BuildAgencyTreeRows");
            StringAssert.Contains(adminBll, "usr.IsCreateAgent = 1");
            StringAssert.Contains(adminEntity, "CanCreateChildAgent");
            StringAssert.Contains(view, "toggleAgencyChildren");
            StringAssert.Contains(adminView, "toggleAgencyChildren");
            StringAssert.Contains(view, "rowStyler: agencyRowStyler");
            StringAssert.Contains(adminView, "rowStyler: agencyRowStyler");
            Assert.IsFalse(view.Contains("rowData.PRIV > 0 && rowData.PRIV < 3"));
            Assert.IsFalse(view.Contains("parseInt($(this).text(), 10) - 1"));
            Assert.IsFalse(adminView.Contains("parseInt($(this).text(), 10) - 1"));
            Assert.IsFalse(view.Contains(">查看分代</a>"));
            Assert.IsFalse(adminView.Contains(">查看分代</a>"));
            Assert.IsFalse(controller.Contains("只有总台可以设置分代上限"));
            Assert.IsFalse(view.Contains("field=\"PWD\" width=\"250\" formatter=\"fmtOpt\""));
            Assert.IsFalse(adminView.Contains("<!-- width="));
            Assert.IsFalse(view.Contains("showMsg(data);"));
            Assert.IsFalse(view.Contains("alert('账号ID不能少于3个字符！'"));
        }

        [TestMethod]
        public void UpDownPermissionControlsRechargeAndDeductEntriesAndPosts()
        {
            string userInfoView = ReadRepoFile(@"TTY.Web\Areas\Game\Views\UserInfo\Index.cshtml");
            string rechargeView = ReadRepoFile(@"TTY.Web\Areas\Game\Views\Recharge\Index.cshtml");
            string userInfoController = ReadRepoFile(@"TTY.Web\Areas\Game\Controllers\UserInfoController.cs");
            string rechargeController = ReadRepoFile(@"TTY.Web\Areas\Game\Controllers\RechargeController.cs");

            StringAssert.Contains(userInfoView, "loginUser.UserPriv == 0 || loginUser.IsUpDown == 1");
            StringAssert.Contains(rechargeView, "loginUser.UserPriv == 0 || loginUser.IsUpDown == 1");
            StringAssert.Contains(userInfoController, "loginUser.UserPriv > 0 && loginUser.IsUpDown != 1");
            StringAssert.Contains(rechargeController, "loginUser.UserPriv > 0 && loginUser.IsUpDown != 1");
            StringAssert.Contains(userInfoController, "没有上下分权限");
            StringAssert.Contains(rechargeController, "没有上下分权限");
        }

        [TestMethod]
        public void RechargePageSkipsMissingFormWidgetsAndDoesNotPreloadAgencies()
        {
            string rechargeView = ReadRepoFile(@"TTY.Web\Areas\Game\Views\Recharge\Index.cshtml");

            StringAssert.Contains(rechargeView, "function hasRechargeForm()");
            StringAssert.Contains(rechargeView, "if (!hasRechargeForm())");
            StringAssert.Contains(rechargeView, "function ensureAgencyOptionsLoaded(targetPriv)");
            Assert.IsFalse(rechargeView.Contains("getAgencies(node.id);"));
        }

        [TestMethod]
        public void MobileAddAgentUsesSinglePasswordWithoutConfirmationBackfill()
        {
            string view = ReadRepoFile(@"TTY.Web\Areas\Mobile\Views\Home\AddAgent.cshtml");
            string script = ReadRepoFile(@"TTY.Web\Scripts\app\phone\phone.addagent.js");
            string controller = ReadRepoFile(@"TTY.Web\Areas\Game\Controllers\AgencyInfoController.cs");

            Assert.IsFalse(view.Contains("agentPassword2"));
            Assert.IsFalse(script.Contains("password2"));
            Assert.IsFalse(script.Contains("RE_PWD:"));
            // 1.0.28 起后端已去除 RE_PWD 补值逻辑（实体不再 [Compare] 校验），保持无补值
            Assert.IsFalse(controller.Contains("form.Set(\"RE_PWD\""));
        }

        [TestMethod]
        public void FirstLevelAgentKickAllUsesManageScopeForVisibleUserRange()
        {
            string userInfoView = ReadRepoFile(@"TTY.Web\Areas\Game\Views\UserInfo\Index.cshtml");
            string userInfoController = ReadRepoFile(@"TTY.Web\Areas\Game\Controllers\UserInfoController.cs");

            StringAssert.Contains(userInfoView, "loginUser?.ManageScope == 2");
            StringAssert.Contains(userInfoController, "GetManagedPlayerAgencyAccounts(ef, loginUser)");
            Assert.IsFalse(userInfoController.Contains("(loginUser.KickScope ?? 1) == 2"));
        }

        [TestMethod]
        public void RechargeAgencyOptionsFollowManageScope()
        {
            string agencyApi = ReadRepoFile(@"TTY.Web\Controllers\Api\AgencyController.cs");
            string rechargeView = ReadRepoFile(@"TTY.Web\Areas\Game\Views\Recharge\Index.cshtml");
            string rechargeBll = ReadRepoFile(@"YYT.BLL\EF\B_Recharge.cs");

            StringAssert.Contains(agencyApi, "GetManagedAgencyAccounts(ef, loginUser)");
            StringAssert.Contains(agencyApi, "c.ID != loginUser.Accounts");
            Assert.IsFalse(agencyApi.Contains("GetAgenciesWithPermission(loginUser, entity)"));
            StringAssert.Contains(rechargeView, "$('body').data('sel_agency_db_' + targetPriv)");
            StringAssert.Contains(rechargeBll, "GetManagedAgencyAccounts(ef, this.SrcUser.ToLoginUser())");
            Assert.IsFalse(rechargeBll.Contains("GetTree(adminList, list2, this.SrcUser.ID)"));
        }

        [TestMethod]
        public void RechargeQueryCoinsUsesMessageBoxInsteadOfDialog()
        {
            string rechargeView = ReadRepoFile(@"TTY.Web\Areas\Game\Views\Recharge\Index.cshtml");

            StringAssert.Contains(rechargeView, "function showRechargeToast(message, type)");
            StringAssert.Contains(rechargeView, "function showRechargeResult(data, dangerOnSuccess, overrideMessage)");
            StringAssert.Contains(rechargeView, "position: 'fixed'");
            StringAssert.Contains(rechargeView, "left: '50%'");
            StringAssert.Contains(rechargeView, "transform: 'translateX(-50%)'");
            StringAssert.Contains(rechargeView, "color = '#d9534f';");
            StringAssert.Contains(rechargeView, ".delay(5000)");
            StringAssert.Contains(rechargeView, "该账号不存在，请重新输入!");
            StringAssert.Contains(rechargeView, "showRechargeResult(data, false, '该账号不存在，请重新输入!');");
            StringAssert.Contains(rechargeView, "showRechargeResult(data);");
            Assert.IsFalse(rechargeView.Contains("'messager'"));
            Assert.IsFalse(rechargeView.Contains("$.messager.show({"));
            Assert.IsFalse(rechargeView.Contains("showRechargeMessageBox(data);"));
            Assert.IsTrue(rechargeView.IndexOf("request('/Game/Recharge/QueryCoins'", StringComparison.Ordinal) < rechargeView.IndexOf("showRechargeResult(data, false, '该账号不存在，请重新输入!');", StringComparison.Ordinal));
        }

        [TestMethod]
        public void RechargeMenuAndRouteUseAccountRechargeName()
        {
            string rechargeView = ReadRepoFile(@"TTY.Web\Areas\Game\Views\Recharge\Index.cshtml");
            string language = ReadRepoFile(@"TTY.Web\App_GlobalResources\Language.resx");
            string resource = ReadRepoFile(@"TTY.Web\Resources\Resource1.resx");

            StringAssert.Contains(rechargeView, "ViewBag.RouteMap = \"账户充值\"");
            StringAssert.Contains(language, "<value>账户充值</value>");
            StringAssert.Contains(resource, "<value>账户充值</value>");
        }

        [TestMethod]
        public void AdminPermissionMenuUsesAgencyPermissionName()
        {
            string adminView = ReadRepoFile(@"TTY.Web\Areas\Game\Views\Admin\Index.cshtml");
            string language = ReadRepoFile(@"TTY.Web\App_GlobalResources\Language.resx");
            string resource = ReadRepoFile(@"TTY.Web\Resources\Resource1.resx");

            StringAssert.Contains(adminView, "ViewBag.RouteMap = \"代理权限设置\"");
            StringAssert.Contains(language, "<value>代理权限设置</value>");
            StringAssert.Contains(resource, "<value>代理权限设置</value>");
            Assert.IsFalse(language.Contains("<value>代理/推广权限设置</value>"));
            Assert.IsFalse(resource.Contains("<value>代理/推广权限设置</value>"));
        }

        [TestMethod]
        public void AllBackendTablesUseAdaptiveColumnWidthsWithoutChangingHeightSizing()
        {
            string common = ReadRepoFile(@"TTY.Web\Scripts\app\common.js");
            string agencyView = ReadRepoFile(@"TTY.Web\Areas\Game\Views\AgencyInfo\Index.cshtml");
            string adminView = ReadRepoFile(@"TTY.Web\Areas\Game\Views\Admin\Index.cshtml");
            DirectoryInfo dir = FindRepoRoot();

            StringAssert.Contains(common, "$.fn.datagrid.defaults.fitColumns = true;");
            StringAssert.Contains(common, "$.fn.treegrid.defaults.fitColumns = true;");
            StringAssert.Contains(common, "function applyAdaptiveGridColumns(id)");
            StringAssert.Contains(common, "grid.datagrid('options').fitColumns !== true");
            StringAssert.Contains(common, "grid.datagrid('fitColumns');");
            StringAssert.Contains(common, "height: h");

            // 需要底部左右滑动条的代理页面显式关闭 fitColumns，并按内容自适应列宽
            StringAssert.Contains(agencyView, "fitColumns: false");
            StringAssert.Contains(adminView, "fitColumns: false");
            StringAssert.Contains(agencyView, "autoFitAgencyColumns()");
            StringAssert.Contains(adminView, "autoFitAgencyColumns()");

            // 其余页面仍不允许私自关闭 fitColumns
            foreach (string relativeDir in new[] { @"TTY.Web\Areas", @"TTY.Web\Views", @"TTY.Web\Scripts\app", @"TTY.Web\Scripts\game" })
            {
                string sourceDir = Path.Combine(dir.FullName, relativeDir);
                foreach (string file in Directory.EnumerateFiles(sourceDir, "*.*", SearchOption.AllDirectories))
                {
                    string extension = Path.GetExtension(file);
                    if (extension != ".cshtml" && extension != ".js")
                        continue;

                    if (file.EndsWith(@"AgencyInfo\Index.cshtml", StringComparison.OrdinalIgnoreCase) ||
                        file.EndsWith(@"Admin\Index.cshtml", StringComparison.OrdinalIgnoreCase))
                        continue;
                    Assert.IsFalse(File.ReadAllText(file).Contains("fitColumns: false"), file);
                }
            }
        }

        [TestMethod]
        public void PasswordPermissionsHideLoginAndResetEntries()
        {
            string userInfoView = ReadRepoFile(@"TTY.Web\Areas\Game\Views\UserInfo\Index.cshtml");
            string userInfoController = ReadRepoFile(@"TTY.Web\Areas\Game\Controllers\UserInfoController.cs");

            StringAssert.Contains(userInfoView, "SAFE_PWD");
            StringAssert.Contains(userInfoView, "field=\"PWD\"");
            Assert.IsFalse(userInfoView.Contains("field=\"SAFE_PWD\""));
            Assert.IsFalse(userInfoView.Contains("field=\"GRADE\""));
            Assert.IsFalse(userInfoView.Contains("field=\"UserID\""));
            StringAssert.Contains(userInfoView, "loginUser.IsViewPwd == 1 && loginUser.IsModifyPwd == 1");
            Assert.IsFalse(userInfoView.Contains("ResetSafePwd"));
            Assert.IsFalse(userInfoView.Contains("重置保险柜密码"));
            StringAssert.Contains(userInfoController, "loginUser.IsResetSafePwd != 1");
            Assert.IsFalse(userInfoController.Contains("loginUser.IsViewSafePwd != 1 && loginUser.IsResetSafePwd != 1"));
        }

        [TestMethod]
        public void ModifySafePasswordPermissionHasDedicatedEntryAndPost()
        {
            string userInfoView = ReadRepoFile(@"TTY.Web\Areas\Game\Views\UserInfo\Index.cshtml");
            string userInfoController = ReadRepoFile(@"TTY.Web\Areas\Game\Controllers\UserInfoController.cs");
            string usersBll = ReadRepoFile(@"YYT.BLL\EF\B_Users.cs");

            StringAssert.Contains(userInfoView, "function showChgSafePwdWin");
            StringAssert.Contains(userInfoView, "/Game/UserInfo/ChgSafePwd");
            StringAssert.Contains(userInfoController, "public ActionResult ChgSafePwd");
            StringAssert.Contains(userInfoController, "loginUser.IsModifySafePwd != 1");
            StringAssert.Contains(usersBll, "public int ChgSafePwd");
            StringAssert.Contains(usersBll, "usr.SAFE_PWD = entity.SAFE_PWD");
        }

        [TestMethod]
        public void SensitivePlayerFieldsAreScrubbedServerSide()
        {
            string usersBll = ReadRepoFile(@"YYT.BLL\EF\B_Users.cs");

            StringAssert.Contains(usersBll, "ApplySensitiveFieldPermissions");
            StringAssert.Contains(usersBll, "loginUser.IsViewPwd != 1");
            StringAssert.Contains(usersBll, "user.PWD = null");
            StringAssert.Contains(usersBll, "loginUser.IsViewSafePwd != 1");
            StringAssert.Contains(usersBll, "user.SAFE_PWD = null");
        }

        [TestMethod]
        public void MobileBackendSeptemberRequirementsRemainWiredEndToEnd()
        {
            string controlView = ReadRepoFile(@"TTY.Web\Areas\Mobile\Views\Home\Control.cshtml");
            string memberView = ReadRepoFile(@"TTY.Web\Areas\Mobile\Views\Home\Huiyuan.cshtml");
            string playerDetailView = ReadRepoFile(@"TTY.Web\Areas\Mobile\Views\Home\PlayerDetail.cshtml");
            string prizeView = ReadRepoFile(@"TTY.Web\Areas\Mobile\Views\Home\PrizeHistory.cshtml");
            string addAgentView = ReadRepoFile(@"TTY.Web\Areas\Mobile\Views\Home\AddAgent.cshtml");
            string prizeScript = ReadRepoFile(@"TTY.Web\Scripts\app\phone\phone.prizehistory.js");
            string addAgentScript = ReadRepoFile(@"TTY.Web\Scripts\app\phone\phone.addagent.js");
            string userView = ReadRepoFile(@"TTY.Web\Areas\Game\Views\UserInfo\Index.cshtml");
            string userController = ReadRepoFile(@"TTY.Web\Areas\Game\Controllers\UserInfoController.cs");
            string recordsBll = ReadRepoFile(@"YYT.BLL\EF\B_Records_MySQL.cs");
            string adminBll = ReadRepoFile(@"YYT.BLL\EF\B_Admin.cs");

            foreach (string id in new[] { "stBet", "stToday", "stTotal" })
                StringAssert.Contains(controlView, "id=\"" + id + "\"");
            Assert.IsFalse(controlView.Contains("id=\"stScore\""));
            Assert.IsFalse(controlView.Contains("id=\"stCoins\""));
            StringAssert.Contains(controlView, "flex-wrap: nowrap");
            foreach (string header in new[] { "今日盈亏", "今日充值", "今日退币", "所属代理" })
                StringAssert.Contains(memberView, header);
            Assert.IsFalse(playerDetailView.Contains("id=\"btnControl\""));
            Assert.IsFalse(prizeView.Contains("historyNext"));
            StringAssert.Contains(prizeScript, "fetchRemaining");
            StringAssert.Contains(addAgentView, "id=\"agentCreateAgent\" checked");
            StringAssert.Contains(addAgentScript, "IsCreateAgent:");
            StringAssert.Contains(userView, "loginUser.IsViewPwd == 1");
            StringAssert.Contains(userController, "loginUser.IsViewPwd != 1 || loginUser.IsModifyPwd != 1");
            StringAssert.Contains(recordsBll, "DELETE FROM `gameprizerecord`");
            StringAssert.Contains(adminBll, "SetAgentEnabledWithAudit");
        }

        [TestMethod]
        public void PrizeHistoryExcludesConfiguredGamesFromListAndRecords()
        {
            string userRecordController = ReadRepoFile(@"TTY.Web\Areas\Game\Controllers\UserRecordController.cs");

            // 游戏 42 不再出现在中奖记录的卡片与记录里；且不得靠改 games.Enable 实现
            //（该字段同时控制游戏配置、游戏记录、鱼机控制等页面）。
            StringAssert.Contains(userRecordController, "PrizeHistoryExcludedGameIds = { 42 }");
            StringAssert.Contains(userRecordController, "!PrizeHistoryExcludedGameIds.Contains(g.GameId)");
        }

        [TestMethod]
        public void PrizeHistoryShowsMachineNumberAndHeaderTotal()
        {
            string userRecordController = ReadRepoFile(@"TTY.Web\Areas\Game\Controllers\UserRecordController.cs");
            string mobileHomeController = ReadRepoFile(@"TTY.Web\Areas\Mobile\Controllers\HomeController.cs");
            string prizeScript = ReadRepoFile(@"TTY.Web\Scripts\app\phone\phone.prizehistory.js");

            // 「机台号」列显示哪台机子出的奖：roomtableconfig.TableName 优先（运营在桌台
            // 配置里给机台起的名字），无配置回退 "N号机"。TableId 口径按 GameType 换算
            // TableIndex：牌机/鱼机是房间内 1 基桌台号（-1），拉霸等其它类是 0 基机台下标（原值）。
            StringAssert.Contains(userRecordController, "FROM roomtableconfig");
            StringAssert.Contains(userRecordController, "item.GameType == 3 ? (int)item.TableId : (int)item.TableId - 1");
            StringAssert.Contains(userRecordController, "item.TableLabel = tname;");
            StringAssert.Contains(userRecordController, "(configIndex + 1) + \"号机\"");
            StringAssert.Contains(prizeScript, "<th>机台号</th>");
            StringAssert.Contains(prizeScript, "esc(r.TableLabel || '--')");
            // 不能再回退成直接显示 RoomId（服务端下发 0 基房间号，真人恒为 0，全部显示 --）
            Assert.IsFalse(prizeScript.Contains("esc(r.RoomId"));

            // 头部副标题统计当前查询的中奖总数量（运营要求顶栏直接可见）
            StringAssert.Contains(mobileHomeController, "ViewBag.MSubtitleHtml = \"中奖总数 <span id=");
            StringAssert.Contains(mobileHomeController, "prizeTotalCount");
            StringAssert.Contains(prizeScript, "$('#prizeTotalCount').text(totalCount)");
        }

        [TestMethod]
        public void CoinOperationsRejectNonPositiveAmountsAndQueryRequiresUpDownPermission()
        {
            string userInfoController = ReadRepoFile(@"TTY.Web\Areas\Game\Controllers\UserInfoController.cs");
            string rechargeController = ReadRepoFile(@"TTY.Web\Areas\Game\Controllers\RechargeController.cs");
            string rechargeBll = ReadRepoFile(@"YYT.BLL\EF\B_Recharge.cs");

            StringAssert.Contains(userInfoController, "coin <= 0");
            StringAssert.Contains(userInfoController, "loginUser.UserPriv > 0 && loginUser.IsUpDown != 1");
            StringAssert.Contains(rechargeController, "coin <= 0");
            StringAssert.Contains(rechargeController, "rechargeTarget.AdminType ==");
            StringAssert.Contains(rechargeBll, "this.ReChargeDataEntity.Coin <= 0");
            StringAssert.Contains(rechargeBll, "this.OptType == 1 || this.OptType == 3");
        }

        [TestMethod]
        public void RemainingPermissionAndInputRisksAreGuarded()
        {
            string userInfoController = ReadRepoFile(@"TTY.Web\Areas\Game\Controllers\UserInfoController.cs");
            string agencyInfoController = ReadRepoFile(@"TTY.Web\Areas\Game\Controllers\AgencyInfoController.cs");
            string usersBll = ReadRepoFile(@"YYT.BLL\EF\B_Users.cs");
            string adminBll = ReadRepoFile(@"YYT.BLL\EF\B_Admin.cs");

            StringAssert.Contains(userInfoController, "string.IsNullOrWhiteSpace(tmpId)");
            Assert.IsFalse(userInfoController.Contains("tmpId.Trim()"));
            StringAssert.Contains(agencyInfoController, "loginUser == null || loginUser.UserPriv != 0");
            StringAssert.Contains(usersBll, "coins <= 0");
            StringAssert.Contains(usersBll, "string.Equals(usr.SAFE_PWD, entity.SAFE_PWD)");
            StringAssert.Contains(usersBll, "string.Equals(usr.PWD, entity.PWD)");
            StringAssert.Contains(adminBll, "string.Equals(usr.PWD, entity.PWD)");
        }

        [TestMethod]
        public void MobileFastPathAndEffectiveRechargeContractsRemainWired()
        {
            string playersScript = ReadRepoFile(@"TTY.Web\Scripts\app\phone\phone.players.js");
            string detailScript = ReadRepoFile(@"TTY.Web\Scripts\app\phone\phone.playerdetail.js");
            string controlScript = ReadRepoFile(@"TTY.Web\Scripts\app\phone\phone.control.js");
            string rechargeScript = ReadRepoFile(@"TTY.Web\Scripts\app\phone\phone.recharge.js");
            string rechargeController = ReadRepoFile(@"TTY.Web\Areas\Game\Controllers\RechargeController.cs");
            string rechargeView = ReadRepoFile(@"TTY.Web\Areas\Mobile\Views\Home\Recharge.cshtml");
            string recordsView = ReadRepoFile(@"TTY.Web\Areas\Mobile\Views\Home\Records.cshtml");
            string rechargeBll = ReadRepoFile(@"YYT.BLL\EF\B_ReChargeRecords.cs");
            string rechargeBase = ReadRepoFile(@"YYT.BLL\EF\B_Recharge.cs");
            string userController = ReadRepoFile(@"TTY.Web\Areas\Game\Controllers\UserInfoController.cs");
            string controlBll = ReadRepoFile(@"YYT.BLL\EF\B_UserControl.cs");
            string indexSql = ReadRepoFile(@"Docs\sql\性能索引.sql");

            StringAssert.Contains(playersScript, "立即渲染基础卡片，不等待控制状态");
            StringAssert.Contains(playersScript, "attachActiveControls");
            // 玩家列表卡片不再展示冻结状态（冻结账号只在冻结明细/冻结账号页查看）
            Assert.IsFalse(playersScript.Contains("冻结中"));
            // 列表里的控制状态带"吃分中/放水中/控牌中"执行中前缀，明细与控制管理页同口径
            StringAssert.Contains(playersScript, "'吃分中... 目标 ' + M.gold(control.TargetCoins)");
            StringAssert.Contains(playersScript, "'放水中... 目标 ' + M.gold(control.TargetCoins)");
            StringAssert.Contains(playersScript, "'控牌中... ' + M.cardControlText(control.GameId, control.LimitCoins)");
            StringAssert.Contains(playersScript, "已吃分 ");
            StringAssert.Contains(playersScript, "已放分 ");
            // 玩家详情页控制状态文案：吃分/放水必须闭合「（目标 N 已吃分/已放分 N）」
            StringAssert.Contains(detailScript, "分 ' + M.gold(progress) + '）'");
            StringAssert.Contains(controlScript, "MobileRequest: 1");
            // 手机端控制指令也改为直发：只入发件箱排队要等定时重试（间隔 60s）才生效
            Assert.IsFalse(controlBll.Contains("QueueTotalUcCommand"));
            StringAssert.Contains(controlBll, "SendTotalUcCommand(mode, strength, cardAction, cardValue, cardNumber, cardTotal, loginUser, target);");
            StringAssert.Contains(controlScript, "r.text || '操作成功'");
            Assert.IsFalse(controlScript.Contains("已受理"));
            Assert.IsFalse(controlBll.Contains("已受理"));
            StringAssert.Contains(rechargeScript, "成功！已向");
            StringAssert.Contains(rechargeScript, "币。");
            Assert.IsFalse(rechargeView.Contains("💎"));
            Assert.IsFalse(recordsView.Contains("<th>备注</th>"));
            StringAssert.Contains(rechargeBll, "c.Processed == 1");
            StringAssert.Contains(userController, "visibleRows");
            StringAssert.Contains(userController, "loginUser, false");
            StringAssert.Contains(indexSql, "idx_rechargerecords_processed_time_game");
            StringAssert.Contains(rechargeScript, "MobileRequest: 1");
            // 手机端充退的 LK/UL 不再是"只入发件箱等定时重试"（会让充退延迟最长 60s 才在游戏内生效）
            Assert.IsFalse(rechargeBase.Contains("QueueLockPlayer"));
            Assert.IsFalse(rechargeBase.Contains("QueueUnlockPlayer"));
            StringAssert.Contains(rechargeBase, "this.GameServerClient.LockPlayer(this.DestUser.ID);");
            StringAssert.Contains(rechargeBase, "srvCode = this.GameServerClient.UnlockPlayer(type, val, this.ReChargeDataEntity.Coin, this.DestUser.ID);");
            StringAssert.Contains(rechargeController, "new B_ReChargeBase(rechargeUser, rechargeTarget, mobileRequest)");
        }

        [TestMethod]
        public void CardControlNamingIsSharedBetweenControlAndPlayerList()
        {
            string phoneCore = ReadRepoFile(@"TTY.Web\Scripts\app\phone\phone.core.js");
            string playersScript = ReadRepoFile(@"TTY.Web\Scripts\app\phone\phone.players.js");
            string controlScript = ReadRepoFile(@"TTY.Web\Scripts\app\phone\phone.control.js");
            string detailScript = ReadRepoFile(@"TTY.Web\Scripts\app\phone\phone.playerdetail.js");

            // 牌型/倍率表只在 phone.core.js 存一份，控制页与玩家列表共用
            StringAssert.Contains(phoneCore, "M.CARD_ACTIONS = [");
            StringAssert.Contains(phoneCore, "M.cardActionName = function (action)");
            StringAssert.Contains(phoneCore, "M.cardTypeName = function (action, value)");
            StringAssert.Contains(phoneCore, "M.cardTypeData = function (action)");
            StringAssert.Contains(phoneCore, "M.cardControlParams = function (gameId, cardValue)");
            StringAssert.Contains(phoneCore, "M.cardControlText = function (gameId, cardValue)");
            // 大字版控制同花顺 = 150 倍（dazhi 档），与控制页下拉同源
            StringAssert.Contains(phoneCore, "dazhi:  [0, 1, 2, 3, 5, 7, 15, 65, 65, 150, 350, 250, 350]");

            // 控制页不再自带一份牌型表，改用共享 API
            Assert.IsFalse(controlScript.Contains("var CARD_ACTIONS = ["));
            Assert.IsFalse(controlScript.Contains("var TC_CARD_TYPES = ["));
            Assert.IsFalse(controlScript.Contains("var TC_MAG_TAB = {"));
            StringAssert.Contains(controlScript, "M.cardControlText(gameId, killRatio)");
            StringAssert.Contains(controlScript, "M.CARD_ACTIONS");

            // 玩家列表控牌状态用同一份命名，不再显示裸控牌值
            Assert.IsFalse(playersScript.Contains("'控牌中... 控牌值 '"));
            StringAssert.Contains(playersScript, "M.cardControlText(control.GameId, control.LimitCoins)");

            // 玩家详情页同样不再显示裸控牌值
            Assert.IsFalse(detailScript.Contains("'控牌（控牌值 '"));
            StringAssert.Contains(detailScript, "M.cardControlParams(r.GameId, r.LimitCoins)");
        }

        [TestMethod]
        public void CardControlOptionsHideZeroPairAndJackpotsOverTwoThousand()
        {
            string phoneCore = ReadRepoFile(@"TTY.Web\Scripts\app\phone\phone.core.js");
            string indexView = ReadRepoFile(@"TTY.Web\Areas\Game\Views\UserInfo\Index.cshtml");
            string onlineView = ReadRepoFile(@"TTY.Web\Areas\Game\Views\UserInfo\OnlineUsers.cshtml");

            // 牌机（5-14）：所有游戏都不再提供 0 倍杂牌；五鬼(12)与电脑端一致一律隐藏；大四梅(8)仅火凤凰(14)保留
            StringAssert.Contains(phoneCore, "if (t.ht == 0 || t.ht == 12) continue;");
            StringAssert.Contains(phoneCore, "if (t.ht == 8 && action != 14) continue;");
            foreach (string view in new[] { indexView, onlineView })
            {
                StringAssert.Contains(view, "if (t.ht == 0 || t.ht == 12) continue;");
                StringAssert.Contains(view, "if (t.ht == 8 && cardAction != 14) continue;");
            }
            // 含"杂牌(0倍)/大四梅(65倍)"的旧牌型表（valSelDataPAIJI2/3 死代码）已删除，防止再被接回下拉
            foreach (string file in new[] { phoneCore, indexView, onlineView })
            {
                Assert.IsFalse(file.Contains("杂牌(0倍)"));
                Assert.IsFalse(file.Contains("valSelDataPAIJI2"));
            }

            // 拉霸牌型补全：水浒传按结果类 code（三连/四连/五连/纯万能线/全屏/混合），手机端与电脑端同列表
            foreach (string code in new[] { "400", "407", "410", "417", "420", "427", "430", "431", "432",
                                            "444", "445", "446", "447", "448", "450", "451" })
            {
                StringAssert.Contains(indexView, "id: " + code + ",");
                StringAssert.Contains(onlineView, "id: " + code + ",");
                StringAssert.Contains(phoneCore, "id: " + code + ",");
            }
            // 赔率超过 2000 倍的全屏水浒项（440 14000倍 / 441 11500倍 / 442 4600倍 / 443 2300倍）不下发
            foreach (string code in new[] { "440", "441", "442", "443" })
            {
                Assert.IsFalse(indexView.Contains("id: " + code + ","), "水浒传控牌不应提供 " + code);
                Assert.IsFalse(onlineView.Contains("id: " + code + ","), "水浒传控牌不应提供 " + code);
                Assert.IsFalse(phoneCore.Contains("id: " + code + ","), "水浒传控牌不应提供 " + code);
            }
            // 明星97 结果类同手机端补齐（旧版只有 0-8 符号值）；旧值仅保留在回显回退表里
            foreach (string code in new[] { "300", "308", "312", "329", "330", "340", "347", "350" })
                StringAssert.Contains(phoneCore, "id: " + code + ",");
            StringAssert.Contains(phoneCore, "var SHZ_LEGACY = [");
            StringAssert.Contains(phoneCore, "var MX97_LEGACY = [");
            StringAssert.Contains(phoneCore, "if (action == 15 && value >= 0 && value <= 7) return SHZ_LEGACY[value];");
            StringAssert.Contains(phoneCore, "if (action == 16 && value >= 0 && value <= 8) return MX97_LEGACY[value];");

            // 拉霸文案按「名称(倍数)」简化：不再出现"50+180倍"这类叠加写法和"按忠义堂"说明，水果拉霸不带"面板X"前缀
            foreach (string file in new[] { phoneCore, indexView, onlineView })
            {
                Assert.IsFalse(file.Contains("+180倍"));
                Assert.IsFalse(file.Contains("+360倍"));
                Assert.IsFalse(file.Contains("按忠义堂"));
                Assert.IsFalse(file.Contains("'面板' + i + ' · '"));
                // 水果拉霸面板位 9/21 是两个不同的送灯位，描述要带免费局次数（与机台设定面板表同名），不能都写"送灯位(免费局)"
                StringAssert.Contains(file, "送灯位·免费局 1~3 次");
                StringAssert.Contains(file, "送灯位·免费局 3~6 次");
                Assert.IsFalse(file.Contains("送灯位(免费局)"));
            }
        }

        [TestMethod]
        public void MobileCardTypeSelectOpensUpwardAboveTheField()
        {
            string phoneCore = ReadRepoFile(@"TTY.Web\Scripts\app\phone\phone.core.js");
            string controlScript = ReadRepoFile(@"TTY.Web\Scripts\app\phone\phone.control.js");
            string phoneCss = ReadRepoFile(@"TTY.Web\Content\css\phone.css");

            // 控制页的「控制牌型」在页面底部：原生 select 的弹出列表只能向下，长列表会被屏幕裁掉，
            // 后面的牌型点不到。改成按钮 + 页面内浮层，默认向上展开（上方不够才向下），原生 select 仅隐藏取值。
            StringAssert.Contains(phoneCore, "M.upwardSelect = function ($sel)");
            StringAssert.Contains(phoneCore, "M.upwardSelectRefresh = function ($sel)");
            StringAssert.Contains(phoneCore, "var up = !(roomAbove < 160 && roomBelow > roomAbove);");
            StringAssert.Contains(phoneCore, "Math.min(room, window.innerHeight * 0.6)");
            StringAssert.Contains(phoneCore, "$sel.val(v).trigger('change');");

            // 只用于「控制牌型」；选项重建（fillSelect）后要同步按钮文案
            StringAssert.Contains(controlScript, "M.upwardSelect($('#ctrlCardValue'));");
            StringAssert.Contains(controlScript, "if (M.upwardSelectRefresh) M.upwardSelectRefresh($sel);");

            // 样式：向上定位、原生 select 隐藏、浮层独立合成层（老安卓命中测试）
            StringAssert.Contains(ExtractCssBlock(phoneCss, ".upsel-panel.up"), "bottom: calc(100% + 6px);");
            StringAssert.Contains(ExtractCssBlock(phoneCss, ".upsel-panel.down"), "top: calc(100% + 6px);");
            StringAssert.Contains(ExtractCssBlock(phoneCss, ".upsel-native"), "display: none;");
            StringAssert.Contains(ExtractCssBlock(phoneCss, ".upsel-panel"), "overflow-y: auto;");
            StringAssert.Contains(ExtractCssBlock(phoneCss, ".upsel-panel"), "translateZ(0);");
        }

        [TestMethod]
        public void AgentFlowShowsCounterpartyAccountWithRolePrefixAndNavigation()
        {
            string flowScript = ReadRepoFile(@"TTY.Web\Scripts\app\phone\phone.agentflow.js");
            string flowView = ReadRepoFile(@"TTY.Web\Areas\Mobile\Views\Home\AgentFlow.cshtml");
            string agentsScript = ReadRepoFile(@"TTY.Web\Scripts\app\phone\phone.agents.js");
            string phoneCore = ReadRepoFile(@"TTY.Web\Scripts\app\phone\phone.core.js");
            string phoneCss = ReadRepoFile(@"TTY.Web\Content\css\phone.css");
            string recordsBll = ReadRepoFile(@"YYT.BLL\EF\B_Records_MySQL.cs");
            string recordEntity = ReadRepoFile(@"YYT.Entity\EF\M_Record.cs");

            // 流向列展示“代 账号 / 玩 账号”，不再出现“流入/流出”字样
            Assert.IsFalse(flowScript.Contains("流入"));
            Assert.IsFalse(flowScript.Contains("流出"));
            StringAssert.Contains(flowScript, "PREFIX_AGENT = '代 '");
            StringAssert.Contains(flowScript, "PREFIX_PLAYER = '玩 '");
            // 来源列只显示账号，不拼职务后缀
            Assert.IsFalse(flowScript.Contains("SrcUserTitle"));
            Assert.IsFalse(flowScript.Contains("DestUserTitle]"));
            // 玩家账号跳玩家详情页，代理账号走弹窗
            StringAssert.Contains(flowScript, "/Mobile/Home/PlayerDetail?id=' +");
            StringAssert.Contains(flowScript, "flow-account-link agent");
            StringAssert.Contains(flowScript, "M.showAgentDetail(");
            StringAssert.Contains(flowView, ".flow-account-link.player");

            // 玩家/代理由服务端按账号归属判定（users/admin 主键存在性），前端不猜文案
            StringAssert.Contains(recordEntity, "public bool DestIsPlayer { get; set; }");
            StringAssert.Contains(recordsBll, "DestIsPlayer = ef.Users.Any(u => u.ID == a.ID)");
            StringAssert.Contains(flowScript, "rowData.DestIsPlayer");

            // 代理详情弹窗由 phone.core.js 提供，代理页与流水页共用同一实现
            StringAssert.Contains(phoneCore, "M.showAgentDetail = function (id)");
            StringAssert.Contains(phoneCore, "/Game/AgencyInfo/GetAgencyDetail");
            StringAssert.Contains(phoneCore, "/Game/Admin/SetIsCreateAgent");
            StringAssert.Contains(phoneCore, "'/Mobile/Home/AgentFlow?id='");
            StringAssert.Contains(phoneCore, "'/Mobile/Home/Recharge?id='");
            StringAssert.Contains(agentsScript, "M.showAgentDetail(id)");
            // 弹窗内「流水 / 充值」并排一行，样式由 phone.css 提供
            StringAssert.Contains(phoneCore, "actionsInline: true");
            StringAssert.Contains(phoneCss, ".modal-actions.inline {");
            // 弹窗样式已收敛到 phone.css，页面不得再各自复制一份
            StringAssert.Contains(phoneCss, ".agent-detail-modal");
            StringAssert.Contains(phoneCss, ".m-switch input:checked + span");
            // 流水页自身不再重复定义弹窗样式
            Assert.IsFalse(flowView.Contains(".agent-detail-modal {"));
        }

        [TestMethod]
        public void AgentFlowOnlyShowsRecordsWithMoneyMovement()
        {
            string flowScript = ReadRepoFile(@"TTY.Web\Scripts\app\phone\phone.agentflow.js");
            string controller = ReadRepoFile(@"TTY.Web\Areas\Game\Controllers\AgencyRecordController.cs");
            string recordsBll = ReadRepoFile(@"YYT.BLL\EF\B_Records_MySQL.cs");
            string recordEntity = ReadRepoFile(@"YYT.Entity\EF\M_Record.cs");

            // 「代理流水」只要资金变动记录：请求带 MONEY_ONLY=1，过滤在服务端做（total/分页才对得上）
            StringAssert.Contains(flowScript, "MONEY_ONLY: 1");
            StringAssert.Contains(recordEntity, "public bool MONEY_ONLY { get; set; }");
            StringAssert.Contains(controller, "form.Q<int>(\"MONEY_ONLY\")");
            StringAssert.Contains(controller, "MONEY_ONLY = moneyOnly");
            // 白名单：充值/兑换/赠送/扣币（0/1 为历史遗留数据），登录退出(2/3)与封禁审计(24-27)不在内
            StringAssert.Contains(recordsBll, "if (queryPara.MONEY_ONLY)");
            StringAssert.Contains(recordsBll, "int?[] moneyOpts = { 0, 1, 20, 21, 22, 23 };");
            StringAssert.Contains(recordsBll, "rst = rst.Where(c => moneyOpts.Contains(c.OPT));");
            // 桌面「代理记录」要展示登录/退出明细，不能跟着一起过滤
            string desktopView = ReadRepoFile(@"TTY.Web\Areas\Game\Views\AgencyRecord\Index.cshtml");
            Assert.IsFalse(desktopView.Contains("MONEY_ONLY"));
        }

        [TestMethod]
        public void MobileAgentListShowsDirectChildrenOnly()
        {
            string agentsScript = ReadRepoFile(@"TTY.Web\Scripts\app\phone\phone.agents.js");
            string agentsView = ReadRepoFile(@"TTY.Web\Areas\Mobile\Views\Home\Agents.cshtml");
            string controller = ReadRepoFile(@"TTY.Web\Areas\Game\Controllers\AgencyInfoController.cs");
            string adminBll = ReadRepoFile(@"YYT.BLL\EF\B_Admin.cs");
            string rules = ReadRepoFile(@"YYT.BLL\EF\AgencyRules.cs");

            // 手机端下钻只看直属下级，不带整条链参数
            Assert.IsFalse(agentsScript.Contains("IncludeDescendants"));
            Assert.IsFalse(controller.Contains("IncludeDescendants"));
            StringAssert.Contains(adminBll, "rst.Where(c => c.AGENCY.Equals(entity.AGENCY));");

            // “下级代理”数量只统计直属下级，不含更深层级
            StringAssert.Contains(rules, "BuildDirectChildCounts(IEnumerable<AgencyLink> links)");
            StringAssert.Contains(adminBll, "AgencyRules.BuildDirectChildCounts(links)");
            StringAssert.Contains(adminBll, "childCounts.TryGetValue(agency.ID, out childCount)");

            // 数量基准是权限范围内的全量代理，避免下钻后该层下级不在结果集里而整列显示 0 个
            StringAssert.Contains(adminBll, "var scoped = loginUser.UserPriv == 0");
            StringAssert.Contains(adminBll, "List<AgencyRules.AgencyLink> links = scoped");

            // 账号列不再做树状缩进
            Assert.IsFalse(agentsScript.Contains("agent-tree-branch"));
            Assert.IsFalse(agentsScript.Contains("AgencyTreeDepth"));
            Assert.IsFalse(agentsView.Contains(".agent-tree-branch"));

            // 页面按节点逐级浏览：根节点 = 登录账号自己，每个节点只列该节点的直属代理；
            // 代理的**权限范围**仍是整条代理线（下钻到哪里才看哪一层），所以"下级代理 N 个"
            // 仍是真实的下属数量、可以继续点进去，不会因为列表收窄而整列显示 0。
            StringAssert.Contains(agentsScript, "var OWN_ACCOUNT = (MConfig.user && MConfig.user.accounts)");
            StringAssert.Contains(agentsScript, "var crumbs = [{ id: OWN_ACCOUNT, name: '所有代理' }];");
            StringAssert.Contains(agentsScript, "loadNode(OWN_ACCOUNT, '所有代理');");
            // 权限范围不许在代理侧被收窄（ManageScope 语义保持：1 仅直属 / 2 全部下级）
            StringAssert.Contains(adminBll, "AgencyRules.GetManagedAgencyIds(loginUser.Accounts, loginUser.ManageScope");
        }

        [TestMethod]
        public void MobileLevelNamesAndLogoutStayOnMobileLogin()
        {
            string phoneCore = ReadRepoFile(@"TTY.Web\Scripts\app\phone\phone.core.js");
            string legacyMobileCore = ReadRepoFile(@"TTY.Web\Scripts\app\mobile\mobile.core.js");
            string loginController = ReadRepoFile(@"TTY.Web\Controllers\LoginController.cs");
            string desktopView = ReadRepoFile(@"TTY.Web\Views\Mgr\Index.cshtml");

            StringAssert.Contains(phoneCore, "if (p === 1) return '特级代理';");
            StringAssert.Contains(phoneCore, "if (p > 1) return (p - 1) + '级代理';");
            StringAssert.Contains(legacyMobileCore, "if (p === 1) return '特级代理';");
            StringAssert.Contains(phoneCore, "/Login/LoginOut?view=mobile");
            StringAssert.Contains(legacyMobileCore, "/Login/LoginOut?view=mobile");
            StringAssert.Contains(loginController, "[WithoutLocalization]");
            StringAssert.Contains(loginController, "Request.QueryString[\"view\"]");
            StringAssert.Contains(loginController, "if (mobile)");
            StringAssert.Contains(loginController, "RedirectToAction(\"Mobile\", \"Login\")");
            StringAssert.Contains(loginController, "return View(\"Index\")");
            StringAssert.Contains(desktopView, "Url.Action(\"LoginOut\",\"Login\")");
        }

        [TestMethod]
        public void MobileGameRecordOpensDedicatedPageInsteadOfModal()
        {
            string playersScript = ReadRepoFile(@"TTY.Web\Scripts\app\phone\phone.players.js");
            string detailScript = ReadRepoFile(@"TTY.Web\Scripts\app\phone\phone.playerdetail.js");
            string recordScript = ReadRepoFile(@"TTY.Web\Scripts\app\phone\phone.gamerecord.js");
            string recordView = ReadRepoFile(@"TTY.Web\Areas\Mobile\Views\Home\GameRecord.cshtml");
            string controller = ReadRepoFile(@"TTY.Web\Areas\Mobile\Controllers\HomeController.cs");
            string csproj = ReadRepoFile(@"TTY.Web\YYT.Web.csproj");

            // 玩家列表弹窗与玩家详情页的入口都改为跳转独立页面，不再弹窗展示记录
            StringAssert.Contains(playersScript, "function showGameRecord()");
            StringAssert.Contains(playersScript, "'/Mobile/Home/GameRecord?id=' + encodeURIComponent(current.ID)");
            StringAssert.Contains(detailScript, "function showGameRecord()");
            StringAssert.Contains(detailScript, "'/Mobile/Home/GameRecord?id=' + encodeURIComponent(detail.ID)");
            Assert.IsFalse(playersScript.Contains("showGameTrack"));
            Assert.IsFalse(detailScript.Contains("showGameTrack"));
            // 记录浮层下线后，两个页面不再内联拼记录内容/弹窗标题
            Assert.IsFalse(playersScript.Contains("的今日游戏记录:"));
            Assert.IsFalse(detailScript.Contains("的今日游戏轨迹:"));
            Assert.IsFalse(playersScript.Contains("loadPlayerRecords"));
            Assert.IsFalse(detailScript.Contains("loadPlayerRecords"));

            // 独立页面外壳：日期筛选 + 表格 + 分页，数据仍走电脑端同款接口
            StringAssert.Contains(controller, "public ActionResult GameRecord()");
            StringAssert.Contains(controller, "ViewBag.Today = DateTime.Now.ToString(\"yyyy-MM-dd\")");
            StringAssert.Contains(recordView, "id=\"recordDate\"");
            StringAssert.Contains(recordView, "id=\"recordTableBody\"");
            StringAssert.Contains(recordView, "id=\"prevBtn\"");
            StringAssert.Contains(recordView, "id=\"nextBtn\"");
            StringAssert.Contains(recordScript, "'/Game/UserRecord/GetUserRecords'");
            // 列口径与电脑端"玩家记录"页一致：桌台号/位置号按 +1 展示，得分只取离开记录
            StringAssert.Contains(recordScript, "(Number(rowData.TABLE_ID) + 1) + '号桌子'");
            StringAssert.Contains(recordScript, "(Number(rowData.SEAT_ID) + 1) + '号位置'");
            StringAssert.Contains(recordScript, "Number(rowData.LeaveCoins || 0) - Number(rowData.EnterCoins || 0)");

            // 新增文件必须登记进老式 csproj，否则部署产物缺文件
            StringAssert.Contains(csproj, @"Areas\Mobile\Views\Home\GameRecord.cshtml");
            StringAssert.Contains(csproj, @"Scripts\app\phone\phone.gamerecord.js");
        }

        [TestMethod]
        public void MobileWinLossAlwaysRendersGreenWhenWinningRedWhenLosing()
        {
            string phoneCss = ReadRepoFile(@"TTY.Web\Content\css\phone.css");
            string controlView = ReadRepoFile(@"TTY.Web\Areas\Mobile\Views\Home\Control.cshtml");
            string playersView = ReadRepoFile(@"TTY.Web\Areas\Mobile\Views\Home\Index.cshtml");
            string huiyuanView = ReadRepoFile(@"TTY.Web\Areas\Mobile\Views\Home\Huiyuan.cshtml");
            string detailScript = ReadRepoFile(@"TTY.Web\Scripts\app\phone\phone.playerdetail.js");

            // phone.css 先于各视图 head 里的 <style> 加载，而数值单元格常写成
            // .member-table td{color:#333} / .info-value{color:#1d1d1f}，
            // 不加 !important 盈亏会被覆盖成普通文字色（会员盈亏列表、玩家列表都中过招）
            StringAssert.Contains(phoneCss, ".positive {\r\n    color: #34c759 !important;");
            StringAssert.Contains(phoneCss, ".negative {\r\n    color: #ff3b30 !important;");

            // 亏一律红色：不得残留把"输/亏"画成橙色的旧配色
            Assert.IsFalse(controlView.Contains(".stat-value.negative {\r\n        color: #ff9500;"));
            Assert.IsFalse(playersView.Contains(".total-win-loss.negative {\r\n        color: #ff9500;"));
            StringAssert.Contains(controlView, ".stat-value.negative {");
            StringAssert.Contains(playersView, ".total-win-loss.negative {");
            // 页面自定义的着色规则必须落在 .positive/.negative 上，才能被上面的全站约定接管
            StringAssert.Contains(huiyuanView, ".profit-stats-value.positive {");
            StringAssert.Contains(huiyuanView, ".profit-stats-value.negative {");
            // 玩家详情页 0 不上色（曾把 0 当成赢画成绿色），与列表页 M.signClass 同源
            StringAssert.Contains(detailScript, "M.signClass(n)");
        }

        [TestMethod]
        public void MobileBanPagesDoNotRepeatTitleBelowHeader()
        {
            string banPlayerView = ReadRepoFile(@"TTY.Web\Areas\Mobile\Views\Home\BanPlayer.cshtml");
            string banAgentView = ReadRepoFile(@"TTY.Web\Areas\Mobile\Views\Home\BanAgent.cshtml");
            string controller = ReadRepoFile(@"TTY.Web\Areas\Mobile\Controllers\HomeController.cs");

            // 页面标题只在蓝色头部出现一次（_MobileLayout 的 h1 取 ViewBag.MTitle），内容区不再重复一行同名标题
            StringAssert.Contains(controller, "ViewBag.MTitle = \"冻结账号\";");
            StringAssert.Contains(controller, "ViewBag.MTitle = \"禁用代理\";");
            Assert.IsFalse(banPlayerView.Contains("class=\"section-title\">冻结账号"));
            Assert.IsFalse(banAgentView.Contains("class=\"section-title\">禁用代理"));

            // 页面级 .section-title 覆盖只服务于那行重复标题，删标题时一并删除，别留死代码
            Assert.IsFalse(banPlayerView.Contains(".section-title"));
            Assert.IsFalse(banAgentView.Contains(".section-title"));
        }

        [TestMethod]
        public void MobilePlayerListRefreshesAfterReturningFromSubPages()
        {
            string phoneCore = ReadRepoFile(@"TTY.Web\Scripts\app\phone\phone.core.js");
            string playersScript = ReadRepoFile(@"TTY.Web\Scripts\app\phone\phone.players.js");
            string controller = ReadRepoFile(@"TTY.Web\Areas\Mobile\Controllers\HomeController.cs");
            string layout = ReadRepoFile(@"TTY.Web\Views\Shared\Layout\_MobileLayout.cshtml");

            // 标记名单的键必须是各页真实的 ViewBag.MPage（布局注入 MConfig.page 后由 core 比对）
            StringAssert.Contains(layout, "page: '@Html.Raw(mPage)',");
            StringAssert.Contains(controller, "ViewBag.MPage = \"agents\";");
            StringAssert.Contains(controller, "ViewBag.MPage = \"huiyuan\";");
            StringAssert.Contains(controller, "ViewBag.MPage = \"recharge\";");
            StringAssert.Contains(phoneCore, "var PLAYERS_STALE_PAGES = { agents: true, huiyuan: true, recharge: true };");

            // 我的代理/我的会员/充值管理会改余额与输赢，进入这些页面时就给玩家列表留标记：
            // 返回多为 bfcache 恢复，页面不重新加载，页面内变量传不过去，只能用存储传递
            StringAssert.Contains(phoneCore, "function isPlayersStalePage() {");
            StringAssert.Contains(phoneCore, "if (isPlayersStalePage()) M.markPlayersStale();");
            // 标记不能放在 pagehide：实测（Chromium）返回导航里恢复页面的 pageshow 早于
            // 离开页面的 pagehide，标记会晚一步写入、列表页看不到；所以是"进入 + 点返回"两处
            StringAssert.Contains(phoneCore, "// 补一次标记：本页若是 bfcache 恢复的，进入时那次标记已被列表页消费掉");
            StringAssert.Contains(phoneCore, "M.consumePlayersStale = function ()");

            // 玩家列表页消费标记：缓存恢复时重拉在线数据；整页新加载时数据本来就是新的，只清标记
            StringAssert.Contains(playersScript, "$(window).on('pageshow', function () {");
            StringAssert.Contains(playersScript, "if (!M.consumePlayersStale()) return;");
            StringAssert.Contains(playersScript, "runRefresh(reloadOnline, true);");
            StringAssert.Contains(playersScript, "M.consumePlayersStale(); // 整页新加载");
            // 抽屉只有列表页有，bfcache 恢复会原样保留展开状态：从抽屉点进子页面再返回时，
            // 菜单会一直盖在列表上（遮罩还吃掉列表点击），所以 pageshow 里统一收起
            StringAssert.Contains(phoneCore, "$backBtn.removeClass('navigating');\r\n            M.closeDrawer();");
            // 返回时只补在线数据：离线列表可能已翻到第 N 页，整体重拉会把列表打回第一页
            StringAssert.Contains(playersScript, "function reloadOnline() {");
            StringAssert.Contains(playersScript, "return $.when(loadTotalWinLoss(), loadOnline());");
            // 在线人数角标在空列表时也要归零（原写法在 return 之后，人数会停在上一次的值）
            StringAssert.Contains(playersScript, "$('#onlinePlayerCount').text(onlinePlayers.length);");
        }

        [TestMethod]
        public void BanAndFreezeRecordsVisibleToOperatorTopAgentAndSuperAdminOnly()
        {
            string rules = ReadRepoFile(@"YYT.BLL\EF\AgencyRules.cs");
            string adminBll = ReadRepoFile(@"YYT.BLL\EF\B_Admin.cs");
            string usersBll = ReadRepoFile(@"YYT.BLL\EF\B_Users.cs");
            string agencyController = ReadRepoFile(@"TTY.Web\Areas\Game\Controllers\AgencyInfoController.cs");
            string abnormalController = ReadRepoFile(@"TTY.Web\Areas\Game\Controllers\AbnormalController.cs");

            // 口径只允许一处实现：AgencyRules.CanAccessBanRecord
            StringAssert.Contains(rules, "public static bool CanAccessBanRecord(int? viewerPriv, string viewerAccount, string operatorAccount, bool targetInViewerLine)");
            StringAssert.Contains(rules, "return priv == TopAgentPriv && targetInViewerLine;");

            // 代理禁用列表/记录：总台全量、特级限本线、其余按"最近一次禁用操作人 = 自己"过滤
            StringAssert.Contains(adminBll, "operators.TryGetValue(c.ID, out op)");
            StringAssert.Contains(adminBll, "rst.Where(c => c.OptID == me);");
            StringAssert.Contains(adminBll, "if (loginUser != null && (loginUser.UserPriv ?? -1) != AgencyRules.SuperAdminPriv)");
            StringAssert.Contains(adminBll, "if (enabled != 0 && target.RE_ENABLE == 0)");
            StringAssert.Contains(adminBll, "return CanAccessBanRecord(ef, loginUser, target.ID, AgentDisableAuditOpt);");

            // 玩家冻结列表/解冻：同一口径（冻结本身仍按管理范围）
            StringAssert.Contains(usersBll, "adminBll.GetBanTargetsOwnedBy(ef, loginUser.Accounts, PlayerFreezeAuditOpt);");
            StringAssert.Contains(usersBll, "if (frozen == 0 && target.FROZEN == 1)");
            StringAssert.Contains(usersBll, "return CanAccessPlayerFreezeRecord(ef, loginUser, target.AGENCY);");

            // 冻结明细：冻结/禁用行按新口径，连续登录失败行保持管理范围
            StringAssert.Contains(abnormalController, "GetBanTargetsOwnedBy(ef, loginUser.Accounts, B_Users.PlayerFreezeAuditOpt)");
            StringAssert.Contains(abnormalController, "GetBanTargetsOwnedBy(ef, loginUser.Accounts, B_Admin.AgentDisableAuditOpt)");
            StringAssert.Contains(abnormalController, "userBll.CanOperatePlayerFreeze(ef, loginUser, user, 0)");

            // 桌面端「启用/禁用」必须走带审计的同一入口：否则记录无操作人（谁都看不到）且能绕过解除口径
            StringAssert.Contains(agencyController, "SetAgentEnabledWithAudit(m_LoginUser, id, enabled,");
            Assert.IsFalse(agencyController.Contains("new B_Admin().SetRecharge(mUsers)"));
        }

        /// <summary>取出 CSS 中某个选择器的声明块（选择器独占一行、以 " {" 结尾）</summary>
        private static string ExtractCssBlock(string css, string selector)
        {
            int start = css.IndexOf(selector + " {", StringComparison.Ordinal);
            Assert.IsTrue(start >= 0, selector + " not found in phone.css");
            int end = css.IndexOf('}', start);
            Assert.IsTrue(end > start, selector + " block is not closed");
            return css.Substring(start, end - start);
        }

        [TestMethod]
        public void MobileModalLocksPageScrollSoDialogButtonsStayTappable()
        {
            string phoneCore = ReadRepoFile(@"TTY.Web\Scripts\app\phone\phone.core.js");
            string phoneCss = ReadRepoFile(@"TTY.Web\Content\css\phone.css");

            // 老安卓内核给 position:fixed 弹窗做命中测试时按文档坐标算：页面滚到中下部再打开弹窗，
            // 点确定/取消没有反应，必须把页面滚回顶部才点得中。修复=弹窗打开期间锁住背景滚动并让
            // 文档滚动量归零（命中区与视觉位置一致），关闭时还原滚动位置。
            StringAssert.Contains(phoneCore, "function lockPageScroll() {");
            StringAssert.Contains(phoneCore, "if (scrollLockCount++ > 0) return;");
            StringAssert.Contains(phoneCore, "s.position = 'fixed';");
            StringAssert.Contains(phoneCore, "if (y) window.scrollTo(0, 0);");
            StringAssert.Contains(phoneCore, "function unlockPageScroll() {");
            StringAssert.Contains(phoneCore, "if (scrollLockCount === 0 || --scrollLockCount > 0) return;");
            StringAssert.Contains(phoneCore, "if (y) window.scrollTo(0, y);");
            // 弹窗会叠加（充值确认 → 结果提示），计数配对，最后一个关闭才解锁
            StringAssert.Contains(phoneCore, "lockPageScroll();");
            StringAssert.Contains(phoneCore, "unlockPageScroll();");

            // 遮罩自身也加固：独立合成层（命中测试走屏幕坐标）+ 超长弹窗可滚动
            string overlayBlock = ExtractCssBlock(phoneCss, ".modal-overlay");
            StringAssert.Contains(overlayBlock, "position: fixed;");
            StringAssert.Contains(overlayBlock, "overflow-y: auto;");
            StringAssert.Contains(overlayBlock, "translateZ(0);");
            // 超高时从头显示（align-items:center 会把顶部裁掉且滚不到）
            StringAssert.Contains(ExtractCssBlock(phoneCss, ".modal-content"), "margin: auto;");
        }

        [TestMethod]
        public void PlayerLookupQueryNeverProjectsEntityTypes()
        {
            string usersBll = ReadRepoFile(@"YYT.BLL\EF\B_Users.cs");

            // EF6 禁止在 LINQ to Entities 里 new 实体类型，写成 Select(c => new M_UserOptLog{...})
            // 会抛 NotSupportedException：在线玩家一进列表，整块查询就失败 ——
            // 手机端点玩家"未获取到玩家信息"、电脑端用户管理/在线玩家列表整页变空（且只在有玩家在线时复现）。
            // 回表投影必须用匿名类型，实体对象留到内存里再组装。
            Assert.IsFalse(usersBll.Contains(".Where(c => latestIds.Contains(c.LID))\r\n                .Select(c => new M_UserOptLog"),
                "FillCurrentPlayInfo 的回表投影不能直接构造实体类型（EF6 不支持，会在有玩家在线时整页查询失败）");
            StringAssert.Contains(usersBll, ".Select(c => new\r\n                {\r\n                    c.LID,\r\n                    c.UserID,");
            StringAssert.Contains(usersBll, ".Select(c => new M_UserOptLog\r\n                {\r\n                    LID = c.LID,");
        }

        [TestMethod]
        public void MobilePlayerCardShowsRealWinLossDecimalBetAndOneBasedPosition()
        {
            string players = ReadRepoFile(@"TTY.Web\Scripts\app\phone\phone.players.js");
            string phoneCore = ReadRepoFile(@"TTY.Web\Scripts\app\phone\phone.core.js");
            string onlineUsers = ReadRepoFile(@"TTY.Web\Areas\Game\Views\UserInfo\OnlineUsers.cshtml");

            // 押注：0.1 分炮鱼机内部单位是 0.1 分，必须 ÷10 保留 1 位小数（否则 0.1 显示成 1）
            StringAssert.Contains(players, "M.betGold(p.CurBet, p.GameID)");
            StringAssert.Contains(phoneCore, "M.betGold = function (v, gameId) {");
            StringAssert.Contains(phoneCore, "n = n / 10;");

            // 鱼机列表必须与电脑端在线用户页同口径（改一处必须同步另一处）
            const string fishIds = "3, 6, 13, 19, 21, 22, 32, 33, 42, 49, 51";
            StringAssert.Contains(phoneCore, "M.DECIMAL_BET_FISH_IDS = [" + fishIds + "];");
            StringAssert.Contains(onlineUsers, "var _decimalBetFishIds = [" + fishIds + "];");

            // 场次/机台号：服务端下发 0 基下标，端上 +1 显示（电脑端桌号即 TableId+1）
            StringAssert.Contains(players, "(Number(p.RoomId) + 1) + '场'");
            StringAssert.Contains(players, "(Number(p.TableId) + 1)");

            // 总输赢取后台口径（user_daily_winloss 累计），不能优先取游戏服 QA 的 TotalWinLoss：
            // 后者是本局/本次在线口径，会让同一玩家在线与离线看到两个不同的数
            StringAssert.Contains(players, "Number(p.Profit != null ? p.Profit : (p.TotalWinLoss || 0))");

            // 控制状态进度原样展示：ConsumedCoins 是净口径、可能为负，取反会把"已吃分 2608"显示成 -2608
            Assert.IsFalse(players.Contains("M.gold(-Number(control.ConsumedCoins"),
                "在线卡片的已吃分不能取反（与电脑端在线用户/用户管理页不一致）");
            StringAssert.Contains(players, "' 已吃分 ' + M.gold(control.ConsumedCoins)");
        }

        [TestMethod]
        public void MobileControlProgressIsNotNegated()
        {
            string control = ReadRepoFile(@"TTY.Web\Scripts\app\phone\phone.control.js");
            string detail = ReadRepoFile(@"TTY.Web\Scripts\app\phone\phone.playerdetail.js");

            // 控制管理页 / 玩家详情页的"已吃分"同样不能取反（曾经三处一起取反，
            // 有吃分进度时会显示负数，与电脑端显示相反）
            Assert.IsFalse(control.Contains(": -r.ConsumedCoins"), "控制页已吃分进度不能取反");
            Assert.IsFalse(detail.Contains(": -Number(r.ConsumedCoins || 0)"), "玩家详情页已吃分进度不能取反");
            StringAssert.Contains(control, "M.gold(Number(r.ControlMode) == 5 ? r.GrantedCoins : r.ConsumedCoins)");
            StringAssert.Contains(detail, "Number(r.ConsumedCoins || 0)");
        }

        [TestMethod]
        public void MobileListsUseGameWinLossProfitAndExcludeAgentRecharges()
        {
            string usersBll = ReadRepoFile(@"YYT.BLL\EF\B_Users.cs");
            string controller = ReadRepoFile(@"TTY.Web\Areas\Game\Controllers\UserInfoController.cs");

            // 离线玩家列表的总盈亏也要走"实际游戏输赢"口径（与在线列表、会员盈亏、电脑端总盈亏一致），
            // 不能再被控制器按充退差额覆盖
            StringAssert.Contains(usersBll, "QueryUsersPaged(mPage, entity, loginUser, true, false, sort, false, false, true);");
            StringAssert.Contains(controller, "list = new B_Users().GetOfflineUsersList(mPage, mUsers, loginUser, sort);");
            StringAssert.Contains(controller, "总盈亏(Profit) = 实际游戏输赢");

            // 会员盈亏（统计卡 + 列表充退列）只统计目标为玩家的流水：
            // 总台给代理充值同样是 rechargerecords 记录（GameID=代理账号），必须排除
            StringAssert.Contains(usersBll, "AND NOT EXISTS (SELECT 1 FROM admin ra WHERE ra.ID = x.GameID)");
            StringAssert.Contains(usersBll, "AND NOT EXISTS (SELECT 1 FROM admin ra WHERE ra.ID = r.GameID)");
            StringAssert.Contains(usersBll, "AND NOT EXISTS (SELECT 1 FROM admin ra WHERE ra.ID = rechargerecords.GameID)");

            // 代理维度的盈亏聚合：user_daily_winloss.UserID 是玩家账号，必须直接连 users.ID。
            // 连 userrelations（其 UserID 是数字平台 ID）与账号串恒不相等，聚合恒为 0（今日总输赢/会员盈亏统计卡曾全为 0）。
            Assert.IsFalse(usersBll.Contains("r.UserID = w.UserID"), "盈亏聚合不能连 userrelations.UserID");
            StringAssert.Contains(usersBll, "INNER JOIN Users u ON u.ID = w.UserID");
        }

        [TestMethod]
        public void MobileRechargeSendsLockUnlockImmediately()
        {
            string rechargeBll = ReadRepoFile(@"YYT.BLL\EF\B_Recharge.cs");

            // 手机端充退不能只把 LK/UL 记入发件箱等定时重试（间隔 60s），否则充退要等一会儿才在游戏内生效；
            // 统一直发，失败由发件箱 + 重试服务兜底
            Assert.IsFalse(rechargeBll.Contains("QueueLockPlayer"), "手机端充值不应只入发件箱排队");
            Assert.IsFalse(rechargeBll.Contains("QueueUnlockPlayer"), "手机端充退解锁不应只入发件箱排队");
            StringAssert.Contains(rechargeBll, "this.GameServerClient.LockPlayer(this.DestUser.ID);");
            StringAssert.Contains(rechargeBll, "srvCode = this.GameServerClient.UnlockPlayer(type, val, this.ReChargeDataEntity.Coin, this.DestUser.ID);");
        }

        [TestMethod]
        public void AgentPasswordVisibilityFollowsPermission()
        {
            string controller = ReadRepoFile(@"TTY.Web\Areas\Game\Controllers\AgencyInfoController.cs");

            // 代理列表曾在权限判定前无条件清空密码，导致总台和持有 IsViewAgentPwd 的代理都看不到代理密码。
            // GetAgencies 里第一处清空必须落在权限分支里（禁用代理列表里另有独立的一处，不在此列）。
            int permIndex = controller.IndexOf("IsViewAgentPwd != 1", StringComparison.Ordinal);
            int pwdIndex = controller.IndexOf("item.PWD = null;", StringComparison.Ordinal);
            Assert.IsTrue(permIndex > 0 && pwdIndex > permIndex,
                "代理密码必须在权限判定之后才清空（曾无条件清空，总台也看不到密码）");
            Assert.IsTrue(controller.Substring(Math.Max(0, pwdIndex - 300), 300).Contains("IsViewAgentPwd != 1"),
                "清空点必须是带权限判断的脱敏分支");
            StringAssert.Contains(controller, "new B_Admin().IsTargetAgencyInManagedScope(ef, loginUser, item.ID)");
        }

        [TestMethod]
        public void MobileMemberPageDefaultsToWholeLine()
        {
            string huiyuan = ReadRepoFile(@"TTY.Web\Scripts\app\phone\phone.huiyuan.js");

            // "我的代理-我的会员-查看"进来默认看该代理整条线的会员（代理权限范围本就是整线），
            // 需要收窄时点"仅看直属"；不能默认只出直属会员，否则非直属会员看不到
            StringAssert.Contains(huiyuan, "var includeDescendants = true;");
            StringAssert.Contains(huiyuan, "includeDescendants = true;");
            StringAssert.Contains(huiyuan, "includeDescendants ? '（全部会员）' : '（直属会员）'");
            StringAssert.Contains(huiyuan, "includeDescendants ? '仅看直属' : '查看全部'");
        }

        [TestMethod]
        public void MobileRechargeQueryFillsAgentScoreFromRemainingScore()
        {
            string rechargeScript = ReadRepoFile(@"TTY.Web\Scripts\app\phone\phone.recharge.js");
            string agencyController = ReadRepoFile(@"TTY.Web\Areas\Game\Controllers\AgencyInfoController.cs");

            // 充值页查询代理时「剩余分数」曾是硬编码 null，页面上永远显示 "--"（运营反馈）。
            // 口径：代理的剩余分 = 直属玩家 GAME_SCORE 合计（列表接口的 RemainingScore，
            // 与代理详细信息弹窗一致）；玩家仍取 users.GAME_SCORE。
            StringAssert.Contains(rechargeScript, "score: Number(row.RemainingScore || 0)");
            StringAssert.Contains(rechargeScript, "score: Number(row.GAME_SCORE || 0)");
            Assert.IsFalse(rechargeScript.Contains("score: null"),
                "代理分支不得再返回 null，否则剩余分数又变回 '--'");
            Assert.IsFalse(rechargeScript.Contains("info.score === null"),
                "渲染不得再保留只给代理走的 '--' 分支");
            StringAssert.Contains(agencyController, "item.RemainingScore = scoreMap.TryGetValue(item.ID, out score) ? score : 0;");
        }

        [TestMethod]
        public void MobilePlayerDetailTotalWinLossIsGameWinLoss()
        {
            string detailScript = ReadRepoFile(@"TTY.Web\Scripts\app\phone\phone.playerdetail.js");
            string usersBll = ReadRepoFile(@"YYT.BLL\EF\B_Users.cs");
            string controller = ReadRepoFile(@"TTY.Web\Areas\Game\Controllers\UserInfoController.cs");

            // 玩家详情页的"总盈亏"曾在前端按「总充值 - 总退分」算，运营看到 a1403 充 30000 退 2000
            // 就显示 +28000，而实际游戏输赢是 -4000。口径统一为 SUM(user_daily_winloss)：
            // 只有玩过游戏才有盈亏，没玩过就是 0，与在线/离线卡片、会员盈亏、电脑端"总盈亏"一致。
            Assert.IsFalse(detailScript.Contains("Number(d.COINS_BUY || 0) - Number(d.COINS_BACK || 0)"),
                "总盈亏不得再用充退差额，必须取服务端下发的 TotalWinLoss");
            StringAssert.Contains(detailScript, "setSigned('#dTotalWinLoss', d.TotalWinLoss);");

            // 服务端要真的算出来：GetUserPhoneDetail 的 SQL 补 SUM(user_daily_winloss) 子查询，
            // 实体带字段，控制器下发（缺任一段前端都只会拿到 undefined、显示 0）
            StringAssert.Contains(usersBll, "SELECT IFNULL(SUM(w2.WINLOSS),0) FROM user_daily_winloss w2 WHERE w2.UserID = c.ID) AS TotalWinLoss");
            string entityFile = ReadRepoFile(@"YYT.Entity\EF\M_Users.cs");
            int detailClass = entityFile.IndexOf("class M_UserPhoneDetail", StringComparison.Ordinal);
            Assert.IsTrue(detailClass > 0 && entityFile.Substring(detailClass).Contains("public long? TotalWinLoss { get; set; }"),
                "M_UserPhoneDetail 需要 TotalWinLoss 字段，否则 SQL 列别名映射不上");
            StringAssert.Contains(controller, "detail.TotalWinLoss,");
        }

        [TestMethod]
        public void OnlinePlayersQueryFailsFastWhenGameServerIsUnreachable()
        {
            string client = ReadRepoFile(@"YYT.BLL\Services\GameServer\PipeGameServerClient.cs");
            string pipe = ReadRepoFile(@"YYT.Remote\SConnect.cs");
            string playersScript = ReadRepoFile(@"TTY.Web\Scripts\app\phone\phone.players.js");
            string global = ReadRepoFile(@"TTY.Web\Global.asax.cs");

            // QA（查询在线玩家）是玩家列表页首屏/刷新按钮的关键路径：游戏服不可达时若沿用
            // 默认的 5s 连接 + 10s 读超时，请求线程会被占 10 秒（线上 IIS 日志实测 GetOnlineUsers
            // 卡 9-11 秒，同一秒内静态文件也卡 10 秒 = 线程池饥饿），必须快速失败。
            StringAssert.Contains(client, "private const int OnlineQueryConnectTimeoutMs = 1000;");
            StringAssert.Contains(client, "private const int OnlineQueryReadTimeoutMs = 3000;");
            StringAssert.Contains(client, "SendRawWithTimeouts(EScMsgType.QA, OnlineQueryConnectTimeoutMs, OnlineQueryReadTimeoutMs)");

            // 超时要真的生效：管道流不支持 ReadTimeout（CanTimeout=false，赋值直接抛异常，
            // 老代码的 if(CanTimeout) 分支是死代码 → 读没有任何超时，游戏服卡住时线程永久挂住），
            // 所以上限用"异步读 + 限时等待"实现。
            StringAssert.Contains(pipe, "public SConnect(int connectTimeoutMs, int readTimeoutMs)");
            StringAssert.Contains(pipe, "this.Connect(this.connectTimeoutMs);");
            StringAssert.Contains(pipe, "private string ReadLineWithTimeout(StreamReader sr)");
            StringAssert.Contains(pipe, "if (!readTask.Wait(this.readTimeoutMs))");
            Assert.IsFalse(pipe.Contains("this.PipeClient.ReadTimeout = "),
                "NamedPipeClientStream 不支持 ReadTimeout，赋值会抛异常；上限必须走 ReadLineWithTimeout");
            // 其它指令保持历史默认值，避免扩大影响面
            StringAssert.Contains(pipe, "public SConnect() : this(5000, 10000)");

            // 失败态要能透到端上：管道失败返回 null（不是空列表），控制器回 code=0，
            // 否则"游戏服没响应"和"确实没人在线"在前端长得一模一样（都显示"暂无在线玩家"）
            StringAssert.Contains(client, "QA transport failure: \" + raw);\r\n                    return null;");
            string controller = ReadRepoFile(@"TTY.Web\Areas\Game\Controllers\UserInfoController.cs");
            StringAssert.Contains(controller, "msg.content = \"游戏服暂无响应，请稍后重试！\";");
            Assert.IsFalse(controller.Contains("if (players == null)\r\n                    players = new List<OnlinePlayerInfo>();"),
                "游戏服不可达不能再被吞成空列表");

            // 前端：超时与后端同口径收短；请求失败（网络失败或 code!=1）时保留上次列表，
            // 不能清空成"暂无在线玩家"
            StringAssert.Contains(playersScript, "{ timeoutMs: 6000 }");
            Assert.IsFalse(playersScript.Contains("{ timeoutMs: 12000 }"),
                "在线玩家请求超时应与后端短超时对齐，不再等 12 秒");
            StringAssert.Contains(playersScript, "if (res && Number(res.code) === 1 && res.datas) {");
            StringAssert.Contains(playersScript, "游戏服暂无响应，请稍后重试");
            StringAssert.Contains(playersScript, "M.toast('游戏服暂无响应，列表为上次结果', 'warning', 2000);");
            int failBranch = playersScript.IndexOf("if (!ok) {", StringComparison.Ordinal);
            Assert.IsTrue(failBranch > 0
                && playersScript.Substring(failBranch, 900).Contains("return;")
                && !playersScript.Substring(failBranch, 900).Contains("onlinePlayers = [];"),
                "失败分支不得把 onlinePlayers 清空，否则列表会显示成没有在线玩家");

            // 兜底：抬高线程池最小线程数，个别阻塞指令不再连带整个站点排队
            StringAssert.Contains(global, "ThreadPool.SetMinThreads(Math.Max(minWorker, 200), Math.Max(minIo, 200));");
        }

        [TestMethod]
        public void PlayerLastLoginComesFromLoginRecordWithUserOptLogFallback()
        {
            string sqlPatch = ReadRepoFile(@"Docs\sql\玩家登录时间-20260918.sql");
            string controller = ReadRepoFile(@"TTY.Web\Areas\Game\Controllers\UserInfoController.cs");
            string usersBll = ReadRepoFile(@"YYT.BLL\EF\B_Users.cs");
            string playersScript = ReadRepoFile(@"TTY.Web\Scripts\app\phone\phone.players.js");

            // 运营反馈「玩家登录的时候后台登录时间不更新，只有离线玩家才显示登录时间」的根因：
            // 「最后登录」一直取 useroptlog 的 MAX(REC_TIME)，而游戏服只往这张表写
            // 进入/离开桌台(7/8)、充值兑换(0-6)、回退分数(99)，从来没有登录事件
            // （ServerCenterRun.cpp 的 SaveUserLog 调用点可查）。于是在线玩家显示的是
            // 「最后一次进桌台的时间」，大厅挂机/新号则显示上局旧时间或兜底 2000-01-01。
            // 修法：玩家上线（users.INHALL 0→1）由库内触发器记进 userloginrecord，
            // 后台优先读它，没有记录的账号回退 useroptlog 旧口径。
            StringAssert.Contains(sqlPatch, "CREATE TABLE IF NOT EXISTS `userloginrecord`");
            StringAssert.Contains(sqlPatch, "AFTER UPDATE ON `users`");
            StringAssert.Contains(sqlPatch, "IF NEW.INHALL = b'1' AND (OLD.INHALL IS NULL OR OLD.INHALL = b'0') THEN");
            // users 是游戏服热表（余额/分数都写它），触发器必须自带兜底：
            // 内部任何异常都吞掉，绝不能让游戏服的写入失败。
            StringAssert.Contains(sqlPatch, "DECLARE CONTINUE HANDLER FOR SQLEXCEPTION BEGIN END;");

            // 在线卡片已撤下「最后登录」列（2026-09-29，运营口径：在线玩家看实时游戏状态，不看登录时间），
            // GetOnlineUsers 的两轮 userloginrecord/UserOptLog 补查随之删除——桌面在线页与手机端都没有消费方，留着只是每次刷新白跑。
            Assert.IsFalse(controller.Contains("FROM userloginrecord WHERE UserID IN ("));
            Assert.IsFalse(controller.Contains("FROM UserOptLog WHERE UserID IN ("));

            // 离线列表：COALESCE(登录记录, useroptlog)，排序必须用同一个表达式，
            // 否则"按最后登录时间"排出来的顺序和列上显示的时间对不上。
            StringAssert.Contains(usersBll, "COALESCE(lr.LastLoginTime, l.LastLoginTime) AS LastLoginTime");
            StringAssert.Contains(usersBll, "ORDER BY COALESCE(lr.LastLoginTime, l.LastLoginTime) DESC, r.UserID DESC");
            StringAssert.Contains(usersBll, "LEFT JOIN (SELECT UserID, MAX(LoginTime) AS LastLoginTime FROM userloginrecord GROUP BY UserID) lr ON lr.UserID = c.ID");

            // 玩家详情页（最后登入）与列表同口径
            int detailSql = usersBll.IndexOf("const string detailSql", StringComparison.Ordinal);
            Assert.IsTrue(detailSql > 0
                && usersBll.Substring(detailSql, 2000).Contains("COALESCE(lr.LastLoginTime, l.LastLoginTime) AS LastLoginTime"),
                "GetUserPhoneDetail 的「最后登入」也要优先取登录记录");

            // 「最后登录」行只在离线卡片输出：loginRow 先置空，再在 if (!isOnline) 内赋值（2026-09-29 起在线卡片不再展示该列）。
            // 在线卡片没有 .login-time-row 锚点，控制状态行须兜底 append 到 .player-info（applyActiveControls 的 else 分支），不得删除。
            int loginInit = playersScript.IndexOf("var loginRow = '';", StringComparison.Ordinal);
            int loginGuard = playersScript.IndexOf("if (!isOnline) {", StringComparison.Ordinal);
            int loginAssign = playersScript.IndexOf("loginRow = '<div class=\"info-row login-time-row\">", StringComparison.Ordinal);
            Assert.IsTrue(loginInit > 0 && loginGuard > loginInit
                && loginAssign > loginGuard && loginAssign - loginGuard < 400,
                "「最后登录」行必须只在离线卡片输出：loginRow 先置空，再在 if (!isOnline) 内赋值");
            StringAssert.Contains(playersScript, "$card.find('.player-info').append(controlHTML);");
            StringAssert.Contains(playersScript, "var loginTimeText = p.LastLoginTime ? M.fmtTime(p.LastLoginTime) : '2000-01-01';");
            StringAssert.Contains(playersScript, "'<span class=\"info-label\">最后登录</span><span class=\"info-value\">' + loginTimeText + '</span></div></div>'");
        }

        [TestMethod]
        public void PlayerInviteCodeComesFromAgentWithRegistrationCodeFirst()
        {
            string api = ReadRepoFile(@"TTY.Web\Controllers\Api\AgencyInviteCodeController.cs");
            string usersBll = ReadRepoFile(@"YYT.BLL\EF\B_Users.cs");
            string csproj = ReadRepoFile(@"TTY.Web\YYT.Web.csproj");

            // 客户端个人面板的「邀请码」曾经填的是玩家自己的 ID，那是错的：邀请码是代理的属性
            // （admin.InviteCode），服务端注册时按它反查归属代理（游戏服 Database.cpp 的
            // SELECT ID FROM Admin WHERE InviteCode=?），玩家 ID 填进注册页只会被判为邀请码错误。
            // 现在改由后台接口下发，且必须与手机端玩家详情页同口径：先取注册时用过的码，
            // 取不到再回退所属代理的邀请码（两步缺一不可，否则客户端与运营端会显示两个不同的码）。
            StringAssert.Contains(usersBll, "public string GetPlayerInviteCode(string playerId)");
            StringAssert.Contains(usersBll, "SELECT ic.InviteCode FROM invite_codes ic WHERE ic.UsedBy = {0} AND ic.IsUsed = 1 ORDER BY ic.ID DESC LIMIT 1");
            StringAssert.Contains(usersBll, "ef.Admins.Where(a => a.ID == agency).Select(a => a.InviteCode).FirstOrDefault()");

            // 接口只回邀请码，不回代理账号（代理账号属后台体系，客户端拿不到也没用）
            StringAssert.Contains(api, "public string InviteCode { get; set; }");
            StringAssert.Contains(api, "InviteCode = new B_Users().GetPlayerInviteCode(playerId)");

            // 老式 csproj 不登记就会漏编译，接口在线上是不存在的
            StringAssert.Contains(csproj, @"<Compile Include=""Controllers\Api\AgencyInviteCodeController.cs"" />");
        }
        [TestMethod]
        public void NoticePageEditsSingleNoticeWithFontSizeAndClientPreview()
        {
            string view = ReadRepoFile(@"TTY.Web\Areas\Game\Views\Notice\Index.cshtml");
            string controller = ReadRepoFile(@"TTY.Web\Areas\Game\Controllers\NoticeController.cs");
            string bll = ReadRepoFile(@"YYT.BLL\EF\B_Notice.cs");
            string entity = ReadRepoFile(@"YYT.Entity\EF\M_Notice.cs");
            string sqlPatch = ReadRepoFile(@"Docs\sql\公告唯一化与字号-20260923.sql");
            string csproj = ReadRepoFile(@"TTY.Web\YYT.Web.csproj");

            // 客户端只展示一条公告，后台「全屏公告」页也就没有列表/新增/删除可做了：
            // 进入即编辑唯一那一条，保存即全量覆盖（页面不得再出现这些入口）。
            Assert.IsFalse(view.Contains("添加公告"), "公告页不应再有「添加公告」按钮");
            Assert.IsFalse(view.Contains("showAddNotice"), "公告页不应再有新增公告弹窗");
            Assert.IsFalse(view.Contains("/Game/Notice/AddNotice"), "公告页不应再调新增接口");
            Assert.IsFalse(view.Contains("/Game/Notice/delNotice"), "公告页不应再有删除入口");
            Assert.IsFalse(view.Contains("/Game/Notice/updateNotic"), "公告页不应再调旧的修改接口");
            Assert.IsFalse(view.Contains("datagrid"), "公告页不再有列表表格，进入即编辑");
            StringAssert.Contains(view, "/Game/Notice/GetNotice");
            StringAssert.Contains(view, "/Game/Notice/SaveNotice");

            // 唯一公告 + 字号：控制器只暴露“读一条/存一条”，新增与删除接口一并去掉
            StringAssert.Contains(controller, "public ActionResult GetNotice(FormCollection form)");
            StringAssert.Contains(controller, "public ActionResult SaveNotice(FormCollection form)");
            Assert.IsFalse(controller.Contains("AddNotice"), "新增公告接口应删除");
            Assert.IsFalse(controller.Contains("delNotice"), "删除公告接口应删除");
            Assert.IsFalse(controller.Contains("updateNotic"), "旧的修改接口应删除");
            StringAssert.Contains(controller, "form.Q<int>(\"FONTSIZE\")");
            StringAssert.Contains(controller, "notice.Length > 200");

            // BLL：单条读写（保存时清掉历史多出来的行）+ 字号标记组装/解析
            StringAssert.Contains(bll, "public M_Notice GetSingleNotice()");
            StringAssert.Contains(bll, "public Msg SaveSingleNotice(M_Notice entity)");
            StringAssert.Contains(bll, "ef.Notices.Remove(rows[i])");
            StringAssert.Contains(bll, "public static string ComposeSizeTag(string notice, int fontSize)");
            StringAssert.Contains(bll, "public static string SplitSizeTag(string notice, out int size)");
            // 默认字号不写标记：老客户端（不认标记）在运营没改字号时看不到任何变化
            StringAssert.Contains(bll, "if (fontSize == NoticeFontSize.Default) return text;");
            StringAssert.Contains(bll, "\"[SIZE=\" + NoticeFontSize.Normalize(fontSize) + \"]\" + text");

            // 实体：字号列 + 与客户端 Label 设计值一致的三条边界（默认 41 / 12-120）
            StringAssert.Contains(entity, "public int FONTSIZE { get; set; }");
            StringAssert.Contains(entity, "public const int Default = 41;");
            StringAssert.Contains(entity, "public const int Min = 12;");
            StringAssert.Contains(entity, "public const int Max = 120;");

            // 页面预览必须与客户端 Notice/Scroll View 1:1：
            // 可视区 648×310、正文列宽 624、默认字号 41、居中、客户端字色/描边/字距/行高
            StringAssert.Contains(view, "int clientViewWidth = 648;");
            StringAssert.Contains(view, "int clientViewHeight = 310;");
            StringAssert.Contains(view, "int clientTextWidth = 624;");
            StringAssert.Contains(view, "int clientFontSize = NoticeFontSize.Default;");
            StringAssert.Contains(view, "text-align: center;");
            StringAssert.Contains(view, "letter-spacing: 2px;");
            StringAssert.Contains(view, "lineHeight: size + 'px'");
            StringAssert.Contains(view, "NC_VIEW_W + 'px', height: NC_VIEW_H + 'px'");
            StringAssert.Contains(view, "NC_TEXT_W + 'px', marginTop: NC_TEXT_TOP + 'px'");
            // 预览用客户端同一份字体（NowarSans-CN-Bold 随站点部署，且必须登记进 csproj）
            StringAssert.Contains(view, "Content/fonts/NowarSans-CN-Bold.otf");
            StringAssert.Contains(csproj, @"<Content Include=""Content\fonts\NowarSans-CN-Bold.otf"" />");
            Assert.IsTrue(File.Exists(Path.Combine(FindRepoRoot().FullName, @"TTY.Web\Content\fonts\NowarSans-CN-Bold.otf")),
                "公告预览用的客户端字体没有随站点一起提交");

            // SQL 补丁：加字号列（列不存在时后台读取会报 Unknown column）+ 清掉历史多余公告行
            StringAssert.Contains(sqlPatch, "ADD COLUMN `FONTSIZE` int(11) NOT NULL DEFAULT 41");
            StringAssert.Contains(sqlPatch, "DELETE n1 FROM `notice` n1");
            StringAssert.Contains(sqlPatch, "JOIN `notice` n2 ON n1.ID < n2.ID");
        }

        [TestMethod]
        public void LuckyLionViceDrawMinBetFollowsTableMinBet()
        {
            string controller = ReadRepoFile(@"TTY.Web\Areas\Game\Controllers\GameConfigController.cs");

            // 幸运六狮(GameId=10) 的庄闲/和不单独配最小值：最小押分取本桌"最低压分"，与主门同一个值；
            // 最大押分仍用页面上的庄/闲单门最高押分与和单门最高押分。
            int start = controller.IndexOf("else if (gameId == 10)");
            Assert.IsTrue(start > 0, "未找到幸运六狮押注参数分支");
            int end = controller.IndexOf("else", start + 10);
            Assert.IsTrue(end > start, "幸运六狮押注参数分支未闭合");
            string block = controller.Substring(start, end - start);

            StringAssert.Contains(block, "room.BET_MIN_VICE = betMin;");
            StringAssert.Contains(block, "room.BET_MIN_DRAW = betMin;");
            StringAssert.Contains(block, "room.BET_MAX_VICE = form.Q<int>(\"BET_MAX_VICE\"");
            StringAssert.Contains(block, "room.BET_MAX_DRAW = form.Q<int>(\"BET_MAX_DRAW\"");
            // 不能再沿用 base 行旧值，否则运营改"最低压分"后庄闲/和的最小值不会跟着变
            Assert.IsFalse(block.Contains("oldRoom.BET_MIN_VICE"), "庄闲最小押分不应再沿用 base 行旧值");
            Assert.IsFalse(block.Contains("oldRoom.BET_MIN_DRAW"), "和最小押分不应再沿用 base 行旧值");

            // 最小值跟随最低压分后必须挡住"最高 < 最低"的组合，否则该门任何押注都会被服务端判超限
            StringAssert.Contains(controller, "庄/闲单门最高押分不能小于最低压分");
            StringAssert.Contains(controller, "和单门最高押分不能小于最低压分");
        }

        [TestMethod]
        public void TotalControlDisplayPicksCardFirstAndKillReleaseAreExclusive()
        {
            string controlBll = ReadRepoFile(@"YYT.BLL\EF\B_UserControl.cs");

            // 互斥口径收敛到 TotalControlRules.ModesReplacedBy：吃分/放水互斥，控牌只替换旧控牌
            StringAssert.Contains(controlBll, "TotalControlRules.ModesReplacedBy(mode)");
            // 展示口径"每人一条、控牌优先"在两个接口都收口到 PickDisplayControls
            // （GetTotalControlStatus + GetActiveTotalControls）
            Assert.IsTrue(controlBll.Split(new[] { "TotalControlRules.PickDisplayControls(" }, StringSplitOptions.None).Length - 1 >= 2,
                "GetTotalControlStatus 与 GetActiveTotalControls 都应调用 TotalControlRules.PickDisplayControls");
            // 旧口径"同一玩家同时只允许一个总控"已废弃，不允许回退
            Assert.IsFalse(controlBll.Contains("同一玩家同时只允许一个总控"));
        }

        [TestMethod]
        public void DelUserPurgesAllAccountKeyedDataAndListJoinsDedupeRelations()
        {
            string usersBll = ReadRepoFile(@"YYT.BLL\EF\B_Users.cs");
            string controller = ReadRepoFile(@"TTY.Web\Areas\Game\Controllers\UserInfoController.cs");
            string relBll = ReadRepoFile(@"YYT.BLL\EF\B_UserRelations.cs");

            // 删除玩家必须清掉全部账号串口径的关联表：这些表不随 users 行删除，
            // 不清的话重注册同名账号会继承旧账号的盈亏/流水/登录/控制记录。
            // （2026-10-02 运营实测：删号重注册后总盈亏仍显示旧值、列表出现两行。）
            StringAssert.Contains(usersBll, "\"user_daily_winloss\"] = \"UserID = {0}\"");
            StringAssert.Contains(usersBll, "\"useroptlog\"] = \"UserID = {0}\"");
            StringAssert.Contains(usersBll, "\"userloginrecord\"] = \"UserID = {0}\"");
            StringAssert.Contains(usersBll, "\"usercontrolstatus\"] = \"UserID = {0}\"");
            // 充退流水只删玩家行：GameID 同名命中代理账号(admin)的流水不能动
            StringAssert.Contains(usersBll, "GameID = {0} AND AccountType = 0");
            // 不能再回到"只删 users+userrelations 一行"的旧实现
            Assert.IsFalse(usersBll.Contains("ef.UserRelations.Remove(rst)"),
                "DelUser 不能只删一行 userrelations（重复映射行会残留，列表仍出多行）");

            // 删除前必须先踢在线玩家（DelUser 只清库，中心服不感知删号，
            // 不踢的话在线幽灵会话会继续往已清空的账号写记录）
            StringAssert.Contains(controller, "Msg kickMsg = KickPlayer(id);");

            // userrelations 的 ID 列无唯一约束（中心服 Register 无条件 INSERT），
            // 所有按账号 join 都必须先去重，否则列表行数/合计被重复行放大
            StringAssert.Contains(usersBll, "RelationsDedupSql");
            Assert.IsFalse(usersBll.Contains("INNER JOIN userrelations r ON r.ID = c.ID"),
                "users join userrelations 必须走 RelationsDedupSql 去重子查询");
            Assert.IsFalse(usersBll.Contains("join r in ef.UserRelations on c.ID equals r.ID"),
                "LINQ join userrelations 必须先去重（GroupBy ID 取 MIN(UserID)）");

            // 账号→UserID 反查遇重复行不能抛异常：取最小 UserID，与中心服读到的第一行一致
            Assert.IsFalse(relBll.Contains("c.ID.Equals(account)).Select(c => c.UserID).SingleOrDefault()"),
                "GetSingle(account) 不能用 SingleOrDefault（重复映射行会直接抛异常）");

            // 中心服 Register 已改 INSERT IGNORE（配合 userrelations.ID 唯一索引真正去重）。
            // 服务端仓库与后台同级（MTH/MTH-Server）时钉住防回退；不在此布局则跳过。
            string serverDb = Path.Combine(FindRepoRoot().Parent.FullName,
                @"MTH-Server\ServerCenterNew\Database.cpp");
            if (File.Exists(serverDb))
            {
                StringAssert.Contains(File.ReadAllText(serverDb),
                    "\"INSERT IGNORE INTO userrelations VALUES(?,?)\"");
            }
        }

        [TestMethod]
        public void PlayerControlStatusVisibleOnlyToOwnerAgentTopAgentAndSuperAdmin()
        {
            string rules = ReadRepoFile(@"YYT.BLL\EF\AgencyRules.cs");
            string adminBll = ReadRepoFile(@"YYT.BLL\EF\B_Admin.cs");
            string controlBll = ReadRepoFile(@"YYT.BLL\EF\B_UserControl.cs");
            string managerOptBll = ReadRepoFile(@"YYT.BLL\EF\B_ManagerOpt.cs");
            string controller = ReadRepoFile(@"TTY.Web\Areas\Game\Controllers\UserInfoController.cs");

            // 玩家控制状态可见口径收敛到 AgencyRules.CanViewPlayerControl：
            // 所属代理本人、特级代理(限本线)、总台；其余代理即便玩家在管理范围内也看不到
            StringAssert.Contains(rules,
                "CanViewPlayerControl(int? viewerPriv, string viewerAccount, string playerAgency, bool targetInViewerLine)");
            StringAssert.Contains(adminBll,
                "CanViewPlayerControl(GameDbContext ef, M_LoginUser loginUser, string playerAgency)");

            // 列表类出口统一走 GetControlVisibleAgencies（总台返回 null 不过滤）：
            // GetControls(鱼机记录) / GetTotalControlRecords(总控记录) / GetActiveTotalControls(在线列表批量)
            Assert.IsTrue(controlBll.Split(new[] { "GetControlVisibleAgencies(ef, loginUser)" }, StringSplitOptions.None).Length - 1 >= 3,
                "GetControls/GetTotalControlRecords/GetActiveTotalControls 都应按 GetControlVisibleAgencies 过滤");
            // 单人状态 GetTotalControlStatus 走 CanViewPlayerControl，无权按"无执行中控制"回包
            StringAssert.Contains(controlBll, "CanViewPlayerControl(ef, loginUser, user.AGENCY)");
            // 不能再回退成管理范围口径（整线代理可见会变成泄露）
            Assert.IsFalse(controlBll.Contains("GetManagedPlayerAgencyAccounts(ef, loginUser)"),
                "控制状态读取不得再用管理范围过滤，应交回所属代理口径");

            // 点杀/控制操作记录页同口径：非特权仅直属玩家、特级限本线
            StringAssert.Contains(managerOptBll, "AgencyRules.TopAgentPriv");
            Assert.IsFalse(managerOptBll.Contains("GetManagedPlayerAgencyAccounts(ef, loginUser)"),
                "控制操作记录不得再用管理范围过滤");

            // 控牌配置回显(GetUserCtrlConfigs)与金币上限回显(GetUserGoldLimit)也不能绕过口径
            Assert.IsTrue(controller.Split(new[] { "CanViewPlayerControl(ef, loginUser, user.AGENCY)" }, StringSplitOptions.None).Length - 1 >= 2,
                "GetUserCtrlConfigs 与 GetUserGoldLimit 都应校验 CanViewPlayerControl");
        }

    }
}
