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
            StringAssert.Contains(userInfoController, "FillPlayerLastLogin(players)");
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
            // 列表里的控制状态文案与控制管理页同口径，不再出现"X中..."过程性前缀
            StringAssert.Contains(playersScript, "'目标 ' + M.gold(control.TargetCoins)");
            StringAssert.Contains(playersScript, "已吃分 ");
            StringAssert.Contains(playersScript, "已放分 ");
            Assert.IsFalse(playersScript.Contains("吃分中"));
            Assert.IsFalse(playersScript.Contains("放水中"));
            Assert.IsFalse(playersScript.Contains("控牌中"));
            StringAssert.Contains(controlScript, "MobileRequest: 1");
            StringAssert.Contains(controlBll, "QueueTotalUcCommand");
            StringAssert.Contains(controlScript, "r.text || '操作成功'");
            Assert.IsFalse(controlScript.Contains("已受理"));
            Assert.IsFalse(controlBll.Contains("已受理"));
            StringAssert.Contains(rechargeScript, "成功！已向");
            StringAssert.Contains(rechargeScript, "金币。");
            Assert.IsFalse(rechargeView.Contains("💎"));
            Assert.IsFalse(recordsView.Contains("<th>备注</th>"));
            StringAssert.Contains(rechargeBll, "c.Processed == 1");
            StringAssert.Contains(userController, "visibleRows");
            StringAssert.Contains(userController, "loginUser, false");
            StringAssert.Contains(indexSql, "idx_rechargerecords_processed_time_game");
            StringAssert.Contains(rechargeScript, "MobileRequest: 1");
            StringAssert.Contains(rechargeBase, "QueueLockPlayer");
            StringAssert.Contains(rechargeBase, "QueueUnlockPlayer");
            StringAssert.Contains(rechargeController, "new B_ReChargeBase(rechargeUser, rechargeTarget, mobileRequest)");
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
            // 弹窗样式已收敛到 phone.css，页面不得再各自复制一份
            StringAssert.Contains(phoneCss, ".agent-detail-modal");
            StringAssert.Contains(phoneCss, ".m-switch input:checked + span");
            // 流水页自身不再重复定义弹窗样式
            Assert.IsFalse(flowView.Contains(".agent-detail-modal {"));
        }

        [TestMethod]
        public void MobileAgentListShowsWholeInheritanceChain()
        {
            string agentsScript = ReadRepoFile(@"TTY.Web\Scripts\app\phone\phone.agents.js");
            string agentsView = ReadRepoFile(@"TTY.Web\Areas\Mobile\Views\Home\Agents.cshtml");
            string controller = ReadRepoFile(@"TTY.Web\Areas\Game\Controllers\AgencyInfoController.cs");
            string adminBll = ReadRepoFile(@"YYT.BLL\EF\B_Admin.cs");
            string rules = ReadRepoFile(@"YYT.BLL\EF\AgencyRules.cs");

            // 手机端下钻某个代理时取整条继承链，而不是只看直属一层
            StringAssert.Contains(agentsScript, "IncludeDescendants: 1");
            StringAssert.Contains(controller, "form.Q<int>(\"IncludeDescendants\", 0) == 1");
            StringAssert.Contains(adminBll, "GetAgencyList(M_Page mPage, M_Admin entity, M_LoginUser loginUser, bool includeDescendants)");
            StringAssert.Contains(adminBll, "AgencyRules.CollectDescendants(links, entity.AGENCY)");

            // “下级代理”数量按整条继承链统计，且统计基准是权限范围内的全量代理，
            // 避免下钻后该层下级不在结果集里而整列显示 0 个
            StringAssert.Contains(rules, "BuildDescendantCounts(IEnumerable<AgencyLink> links)");
            StringAssert.Contains(adminBll, "AgencyRules.BuildDescendantCounts(links)");
            StringAssert.Contains(adminBll, "chainCounts.TryGetValue(agency.ID, out chainCount)");

            // 列表按层级内缩，直观体现“谁开的代理挂在谁名下”
            StringAssert.Contains(agentsScript, "a.AgencyTreeDepth");
            StringAssert.Contains(agentsScript, "agent-tree-branch");
            StringAssert.Contains(agentsView, ".agent-tree-branch");
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
    }
}
