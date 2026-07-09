using System;
using System.IO;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace UnitTestProj
{
    [TestClass]
    public class ViewContractTest
    {
        private static string ReadRepoFile(string relativePath)
        {
            DirectoryInfo dir = new DirectoryInfo(AppDomain.CurrentDomain.BaseDirectory);
            while (dir != null && !File.Exists(Path.Combine(dir.FullName, "YYT_Game_Mgr_MySQL.sln")))
                dir = dir.Parent;

            Assert.IsNotNull(dir, "Cannot locate repository root.");
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
            StringAssert.Contains(view, "setIsViewSafePwd");
            StringAssert.Contains(view, "/Game/Admin/SetIsViewSafePwd");
            StringAssert.Contains(view, "setIsUpDown");
            StringAssert.Contains(view, "/Game/Admin/SetIsUpDown");
            StringAssert.Contains(view, "setIsDelete");
            StringAssert.Contains(view, "/Game/Admin/SetIsDelete");
            StringAssert.Contains(view, "setIsModifyPwd");
            StringAssert.Contains(view, "/Game/Admin/SetIsModifyPwd");
            StringAssert.Contains(view, "setKickScope");
            StringAssert.Contains(view, "/Game/Admin/SetKickScope");
            StringAssert.Contains(view, "setManageScope");
            StringAssert.Contains(view, "/Game/Admin/SetManageScope");
            StringAssert.Contains(view, "启用删除用户");
            StringAssert.Contains(view, "禁用删除用户");
            StringAssert.Contains(view, "启用修改密码");
            StringAssert.Contains(view, "禁用修改密码");
            StringAssert.Contains(view, "启用保险柜");
            StringAssert.Contains(view, "禁用保险柜");
            Assert.IsFalse(view.Contains("showMsg(data);"));
            Assert.IsFalse(view.Contains("启用查看密码"));
            Assert.IsFalse(view.Contains("启用重置保险"));
            Assert.IsFalse(view.Contains("启用赠送"));
            Assert.IsFalse(view.Contains("启用开代理"));
            Assert.IsFalse(view.Contains("showLimitWin"));
            Assert.IsFalse(view.Contains("SaveAgencyLimit"));
            Assert.IsFalse(view.Contains("保险柜密码"));

            Assert.IsFalse(view.Contains("setIsModifySafePwd"));
            Assert.IsTrue(view.IndexOf("setIsUpDown", StringComparison.Ordinal) < view.IndexOf("setIsViewSafePwd", StringComparison.Ordinal));
            Assert.IsTrue(view.IndexOf("setIsUpDown", StringComparison.Ordinal) < view.IndexOf("setIsDelete", StringComparison.Ordinal));
            Assert.IsTrue(view.IndexOf("setIsDelete", StringComparison.Ordinal) < view.IndexOf("setIsModifyPwd", StringComparison.Ordinal));
            Assert.IsTrue(view.IndexOf("setIsModifyPwd", StringComparison.Ordinal) < view.IndexOf("setIsViewSafePwd", StringComparison.Ordinal));

            StringAssert.Contains(controller, "public ActionResult SetFrozen");
            StringAssert.Contains(controller, "public ActionResult SetIsProbability");
            StringAssert.Contains(controller, "public ActionResult SetIsKicking");
            StringAssert.Contains(controller, "public ActionResult SetIsDelete");
            StringAssert.Contains(controller, "public ActionResult SetIsKill");
            StringAssert.Contains(controller, "public ActionResult SetIsRelease");
            StringAssert.Contains(controller, "public ActionResult SetIsViewSafePwd");
            StringAssert.Contains(controller, "public ActionResult SetIsModifyPwd");
            StringAssert.Contains(controller, "public ActionResult SetIsModifySafePwd");
            StringAssert.Contains(controller, "public ActionResult SetIsUpDown");
            StringAssert.Contains(controller, "public ActionResult SetKickScope");
            StringAssert.Contains(controller, "public ActionResult SetManageScope");
            StringAssert.Contains(adminBll, "public int SetFrozen");
            StringAssert.Contains(adminBll, "public int SetProbability");
            StringAssert.Contains(adminBll, "public int SetKicking");
            StringAssert.Contains(adminBll, "public int SetDelete");
            StringAssert.Contains(adminBll, "public int SetKillPermission");
            StringAssert.Contains(adminBll, "public int SetReleasePermission");
            StringAssert.Contains(adminBll, "public int SetViewSafePwdPermission");
            StringAssert.Contains(adminBll, "public int SetModifyPwdPermission");
            StringAssert.Contains(adminBll, "public int SetModifySafePwdPermission");
            StringAssert.Contains(adminBll, "public int SetUpDown");
            StringAssert.Contains(adminBll, "public int SetKickScope");
            StringAssert.Contains(adminBll, "public int SetManageScope");
        }

        [TestMethod]
        public void AdminPermissionActionsRequireManagedAgencyRangeAndModifyPasswordUsesExistingPermission()
        {
            string controller = ReadRepoFile(@"TTY.Web\Areas\Game\Controllers\AdminController.cs");

            StringAssert.Contains(controller, "private bool CanManagePermissionTarget");
            StringAssert.Contains(controller, "GetManagedAgencyAccounts(ef, loginUser)");
            StringAssert.Contains(controller, "只能设置自己管理范围内的下级代理");
            StringAssert.Contains(controller, "if (!CanManagePermissionTarget(m_LoginUser, id, msg))");
            StringAssert.Contains(controller, "M_Admin mUsers = new M_Admin { ID = id, IsModifyPwd = isModifyPwd };");
            StringAssert.Contains(controller, "new B_Admin().SetModifyPwdPermission(mUsers)");
        }

        [TestMethod]
        public void AgencyCreationDefaultsEnableRequestedOperationalPermissionsOnly()
        {
            string controller = ReadRepoFile(@"TTY.Web\Areas\Game\Controllers\AgencyInfoController.cs");

            StringAssert.Contains(controller, "entity.IsFrozen = form.Q<int>(\"IsFrozen\", 1);");
            StringAssert.Contains(controller, "entity.IsKicking = form.Q<int>(\"IsKicking\", 1);");
            StringAssert.Contains(controller, "entity.IsUpDown = form.Q<int>(\"IsUpDown\", 1);");
            StringAssert.Contains(controller, "entity.KickScope = form.Q<int>(\"KickScope\", 2);");
            StringAssert.Contains(controller, "entity.ManageScope = form.Q<int>(\"ManageScope\", 2);");
            StringAssert.Contains(controller, "entity.IsProbability = form.Q<int>(\"IsProbability\", 0);");
            StringAssert.Contains(controller, "entity.IsRelease = form.Q<int>(\"IsRelease\", 0);");
            StringAssert.Contains(controller, "entity.IsKill = form.Q<int>(\"IsKill\", 0);");
            StringAssert.Contains(controller, "entity.IsViewSafePwd = form.Q<int>(\"IsViewSafePwd\", 0);");
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
            StringAssert.Contains(view, "showChgSafePwdWin");
            StringAssert.Contains(view, "loginUser.UserPriv == 0 || loginUser.IsModifyPwd == 1");
            Assert.IsTrue(view.IndexOf("showChgSafePwdWin", StringComparison.Ordinal) > view.IndexOf("showDeduct", StringComparison.Ordinal));
            Assert.IsTrue(view.IndexOf("showChgSafePwdWin", StringComparison.Ordinal) < view.IndexOf("showChgWin", StringComparison.Ordinal));
            Assert.IsFalse(view.Contains("showMsg(data);"));
            Assert.IsFalse(view.Contains("class=\\\"red Lpd5\\\""));
            Assert.IsFalse(view.Contains("class=\\\"green Lpd5\\\""));
            StringAssert.Contains(view, "field=\"PWD\" width=\"110\">用户密码");
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
            StringAssert.Contains(controller, "GetManagedAgencyAccounts(ef, m_LoginUser)");
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
        public void FirstLevelAgentKickAllUsesManageScopeForVisibleUserRange()
        {
            string userInfoView = ReadRepoFile(@"TTY.Web\Areas\Game\Views\UserInfo\Index.cshtml");
            string userInfoController = ReadRepoFile(@"TTY.Web\Areas\Game\Controllers\UserInfoController.cs");

            StringAssert.Contains(userInfoView, "loginUser?.ManageScope == 2");
            StringAssert.Contains(userInfoController, "(loginUser.ManageScope ?? 1) == 2");
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
            DirectoryInfo dir = new DirectoryInfo(AppDomain.CurrentDomain.BaseDirectory);
            while (dir != null && !File.Exists(Path.Combine(dir.FullName, "YYT_Game_Mgr_MySQL.sln")))
                dir = dir.Parent;

            Assert.IsNotNull(dir, "Cannot locate repository root.");

            StringAssert.Contains(common, "$.fn.datagrid.defaults.fitColumns = true;");
            StringAssert.Contains(common, "$.fn.treegrid.defaults.fitColumns = true;");
            StringAssert.Contains(common, "function applyAdaptiveGridColumns(id)");
            StringAssert.Contains(common, "grid.datagrid('options').fitColumns = true;");
            StringAssert.Contains(common, "grid.datagrid('fitColumns');");
            StringAssert.Contains(common, "height: h");

            foreach (string relativeDir in new[] { @"TTY.Web\Areas", @"TTY.Web\Views", @"TTY.Web\Scripts\app", @"TTY.Web\Scripts\game" })
            {
                string sourceDir = Path.Combine(dir.FullName, relativeDir);
                foreach (string file in Directory.EnumerateFiles(sourceDir, "*.*", SearchOption.AllDirectories))
                {
                    string extension = Path.GetExtension(file);
                    if (extension != ".cshtml" && extension != ".js")
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
            StringAssert.Contains(userInfoView, "field=\"PWD\" width=\"110\">用户密码");
            Assert.IsTrue(userInfoView.IndexOf("field=\"PWD\"", StringComparison.Ordinal) < userInfoView.IndexOf("field=\"SAFE_PWD\"", StringComparison.Ordinal));
            Assert.IsFalse(userInfoView.Contains("field=\"GRADE\""));
            Assert.IsFalse(userInfoView.Contains("field=\"UserID\""));
            Assert.IsFalse(userInfoView.Contains("loginUser.IsViewPwd == 1"));
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

            StringAssert.Contains(userInfoView, "loginUser.IsModifySafePwd == 1");
            StringAssert.Contains(userInfoView, "showChgSafePwdWin");
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
            StringAssert.Contains(usersBll, "loginUser.IsViewPwd != 1 && loginUser.IsViewSafePwd != 1");
            StringAssert.Contains(usersBll, "user.PWD = null");
            StringAssert.Contains(usersBll, "loginUser.IsViewSafePwd != 1");
            StringAssert.Contains(usersBll, "user.SAFE_PWD = null");
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
    }
}
