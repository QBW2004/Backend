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
        public void PrizeHistoryExcludesConfiguredGamesFromListAndRecords()
        {
            string userRecordController = ReadRepoFile(@"TTY.Web\Areas\Game\Controllers\UserRecordController.cs");

            // 游戏 42 不再出现在中奖记录的卡片与记录里；且不得靠改 games.Enable 实现
            //（该字段同时控制游戏配置、游戏记录、鱼机控制等页面）。
            StringAssert.Contains(userRecordController, "PrizeHistoryExcludedGameIds = { 42 }");
            StringAssert.Contains(userRecordController, "!PrizeHistoryExcludedGameIds.Contains(g.GameId)");
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
            StringAssert.Contains(controlBll, "QueueTotalUcCommand");
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
            StringAssert.Contains(rechargeBase, "QueueLockPlayer");
            StringAssert.Contains(rechargeBase, "QueueUnlockPlayer");
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
    }
}
