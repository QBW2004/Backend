using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using YYT.BLL.EF;
using YYT.Common;
using YYT.Entity;
using YYT.Web;
using YYT.Web.Controllers;

namespace YYT.Web.Areas.Game.Controllers
{
    [MemberAuthorize]
    public class AgencyInfoController : BaseController
    {
        // GET: Game/AgencyInfo
        public ActionResult Index()
        {
            M_LoginUser loginUser = WebHelper.GetLoginInfo();
            ViewBag.CanCreateChildAgent = false;
            if (loginUser != null)
            {
                if (loginUser.UserPriv == 0)
                {
                    ViewBag.CanCreateChildAgent = true;
                }
                else
                {
                    M_Admin currentAdmin = new B_Admin().GetSingleOrDefault(new M_Admin { ID = loginUser.Accounts });
                    ViewBag.CanCreateChildAgent = currentAdmin != null && AgencyRules.CanCreateChild(loginUser.UserPriv ?? -1, currentAdmin.AGENCY_LIMIT, currentAdmin.IsCreateAgent);
                }
            }
            return View();
        }

        [AjaxOnly]
        [HttpPost]
        public ActionResult GetAgencies(FormCollection form)
        {
            M_EasyuiGridData<M_Admin> list = new M_EasyuiGridData<M_Admin>();
            try
            {
                string id = form.Q<string>("ID");
                string agency = form.Q<string>("Agency");
                int pageIndex = form.Q<int>("page", 1);
                int pageSize = form.Q<int>("rows", 10);
                // 手机端下钻要求看到该代理名下的整条继承链；桌面端“所属代理”仍是精确的直属查询，故由调用方显式声明。
                bool includeDescendants = form.Q<int>("IncludeDescendants", 0) == 1;
                M_LoginUser loginUser = WebHelper.GetLoginInfo();
                if (loginUser == null)
                    return Json(list);

                M_Page mPage = new M_Page(pageIndex, pageSize);
                M_Admin mAdmin = new M_Admin { ID = id, AGENCY = agency };
                //M_Users mUser=
                B_Admin bll = new B_Admin();

                // loginUser.UserPriv
                // 0 超级管理
                // 1 总代
                // 2 ~ 8 一般代理
                // 9 副管理
                // 10 运营
                list = bll.GetAgencyList(mPage, mAdmin, loginUser, includeDescendants);

                if (list != null && list.rows != null)
                {
                    List<M_AgencyProfit> profits = bll.GetAgencyProfits(loginUser);
                    foreach (var item in list.rows)
                    {
                        var tmp = profits.Find(c => c.Agency.Equals(item.ID));
                        item.Profit =  item.RECHARGE-item.EXCHANGE;
                        item.PlayerBalance = (tmp != null ? tmp.PlayerBalance : 0);
                        item.UserBalance = (tmp != null ? tmp.UserBalance : 0);
                        item.PWD = null;
                    }
                    List<string> agencyIds = list.rows.Select(a => a.ID).Where(a => !string.IsNullOrWhiteSpace(a)).ToList();
                    using (var ef = new GameDbContext())
                    {
                        Dictionary<string, long> scoreMap = ef.Users
                            .Where(u => agencyIds.Contains(u.AGENCY))
                            .GroupBy(u => u.AGENCY)
                            .ToDictionary(g => g.Key, g => g.Select(u => (long?)u.GAME_SCORE).Sum() ?? 0);
                        Dictionary<string, DateTime> loginMap = ef.AgencyOptLogs
                            .Where(l => agencyIds.Contains(l.ID) && l.OPT == 2)
                            .GroupBy(l => l.ID)
                            .ToDictionary(g => g.Key, g => g.Max(l => l.REC_TIME));
                        foreach (var item in list.rows)
                        {
                            long score;
                            DateTime login;
                            item.RemainingScore = scoreMap.TryGetValue(item.ID, out score) ? score : 0;
                            item.LastLoginTime = loginMap.TryGetValue(item.ID, out login) ? (DateTime?)login : null;
                        }
                    }

                    // 代理密码脱敏：非超级管理只有拥有查看代理密码权限时可见，且目标必须在管理范围内
                    if (loginUser.UserPriv != 0)
                    {
                        using (var ef = new GameDbContext())
                        {
                            foreach (var item in list.rows)
                            {
                                if (loginUser.IsViewAgentPwd != 1
                                    || !new B_Admin().IsTargetAgencyInManagedScope(ef, loginUser, item.ID))
                                    item.PWD = null;
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.AgencyInfoController), ex);
            }

            return Json(list);
        }

        [AjaxOnly]
        [HttpPost]
        public ActionResult SetRecharge(FormCollection form)
        {
            Msg msg = new Msg(0, "设置失败！");
            try
            {
                string id = form.Q<string>("ID");
                int re_enable = form.Q<int>("RE_ENABLE", 0);
                M_LoginUser m_LoginUser = WebHelper.GetLoginInfo();

                if (m_LoginUser != null && !string.IsNullOrWhiteSpace(id))
                {
                    if (m_LoginUser.Accounts.Equals(id))
                    {
                        msg.content = "不能对自己设置！！！";
                        return Json(msg);
                    }

                    M_Admin mUsers = new M_Admin { ID = id, RE_ENABLE = re_enable };
                    int val = new B_Admin().SetRecharge(mUsers);
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

        #region 手机端扩展（禁用代理）
        /// <summary>
        /// 手机端：代理详情。非超级管理员只能查看自己管理范围内的代理，且不返回代理密码。
        /// </summary>
        [AjaxOnly]
        [HttpPost]
        public ActionResult GetAgencyDetail(FormCollection form)
        {
            Msg msg = new Msg(0, "查询失败！");
            try
            {
                M_LoginUser loginUser = WebHelper.GetLoginInfo();
                string id = form.Q<string>("ID");
                if (loginUser == null || string.IsNullOrWhiteSpace(id))
                {
                    msg.content = "代理账号不能为空！";
                    return Json(msg);
                }

                using (var ef = new GameDbContext())
                {
                    M_Admin agent = ef.Admins.FirstOrDefault(a => a.ID == id.Trim());
                    if (agent == null)
                    {
                        msg.content = "代理账号不存在！";
                        return Json(msg);
                    }
                    B_Admin adminBll = new B_Admin();
                    if (!adminBll.CanManageAgent(ef, loginUser, agent.ID, true))
                    {
                        msg.content = "无权查看该代理！";
                        return Json(msg);
                    }

                    long remainingScore = ef.Users.Where(u => u.AGENCY == agent.ID)
                        .Select(u => (long?)u.GAME_SCORE).Sum() ?? 0;
                    DateTime? lastLogin = ef.AgencyOptLogs
                        .Where(l => l.ID == agent.ID && l.OPT == 2)
                        .OrderByDescending(l => l.REC_TIME)
                        .Select(l => (DateTime?)l.REC_TIME)
                        .FirstOrDefault();

                    msg.code = 1;
                    msg.content = "查询成功！";
                    msg.datas = new
                    {
                        ID = agent.ID,
                        PWD = loginUser.UserPriv == 0 || loginUser.IsViewPwd == 1 ? agent.PWD : null,
                        PRIV = agent.PRIV,
                        AGENCY = agent.AGENCY,
                        COINS = agent.COINS ?? 0,
                        RemainingScore = remainingScore,
                        RECHARGE = agent.RECHARGE ?? 0,
                        EXCHANGE = agent.EXCHANGE ?? 0,
                        RE_ENABLE = agent.RE_ENABLE ?? 0,
                        InviteCode = agent.InviteCode,
                        CreateTime = agent.CreateTime,
                        UpdateTime = agent.UpdateTime,
                        LastLoginTime = lastLogin,
                        IsCreateAgent = agent.IsCreateAgent == 1 ? 1 : 0,
                        CanCreateChildAgent = AgencyRules.CanCreateChild(agent.PRIV ?? -1, agent.AGENCY_LIMIT, agent.IsCreateAgent)
                    };
                }
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.AgencyInfoController), ex);
            }
            return Json(msg);
        }

        /// <summary>
        /// 手机端：禁用中的代理分页（禁用代理页列表）
        /// </summary>
        [AjaxOnly]
        [HttpPost]
        public ActionResult GetBannedAgencies(FormCollection form)
        {
            M_EasyuiGridData<M_Admin> list = new M_EasyuiGridData<M_Admin>();
            try
            {
                M_LoginUser loginUser = WebHelper.GetLoginInfo();
                if (loginUser == null)
                    return Json(list);

                M_Page mPage = new M_Page(form.Q<int>("page", 1), form.Q<int>("rows", 10));
                list = new B_Admin().GetBannedAgenciesList(mPage, loginUser);
                if (list != null && list.rows != null)
                    foreach (M_Admin item in list.rows)
                        item.PWD = null;
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.AgencyInfoController), ex);
            }
            return Json(list);
        }

        /// <summary>
        /// 手机端：代理禁用/恢复记录分页（禁用代理页据此展示封号提示与时间）
        /// </summary>
        [AjaxOnly]
        [HttpPost]
        public ActionResult GetBlacklistRecords(FormCollection form)
        {
            M_EasyuiGridData<M_AgencyOptLog> list = new M_EasyuiGridData<M_AgencyOptLog>();
            try
            {
                M_LoginUser loginUser = WebHelper.GetLoginInfo();
                if (loginUser == null)
                    return Json(list);

                M_Page mPage = new M_Page(form.Q<int>("page", 1), form.Q<int>("rows", 10));
                list = new B_Admin().GetBlacklistRecords(mPage, loginUser);
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.AgencyInfoController), ex);
            }
            return Json(list);
        }
        /// <summary>
        /// 手机端：禁用代理（仅禁用该代理登录，不级联），封号提示记入操作日志，该代理登录时弹出
        /// </summary>
        [AjaxOnly]
        [HttpPost]
        public ActionResult BanAgent(FormCollection form)
        {
            Msg msg = new Msg(0, "禁用失败！");
            try
            {
                M_LoginUser loginUser = WebHelper.GetLoginInfo();
                if (loginUser == null)
                {
                    msg.content = "无权限操作！";
                    return Json(msg);
                }

                string id = form.Q<string>("ID");
                string banMsg = form.Q<string>("BanMsg", "").Trim();
                if (loginUser.Accounts.Equals(id, StringComparison.OrdinalIgnoreCase))
                {
                    msg.content = "不能对自己禁用！";
                    return Json(msg);
                }

                int val = new B_Admin().SetAgentEnabledWithAudit(loginUser, id, 0, banMsg);
                if (val < 0)
                {
                    msg.content = "无权限操作！";
                }
                else if (val == 0)
                {
                    msg.content = "代理账号不存在！";
                }
                else
                {
                    msg.code = 1;
                    msg.content = "操作成功";
                }
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.AgencyInfoController), ex);
            }
            return Json(msg);
        }

        /// <summary>
        /// 手机端：解除代理禁用（恢复登录，不级联解冻玩家）
        /// </summary>
        [AjaxOnly]
        [HttpPost]
        public ActionResult UnbanAgent(FormCollection form)
        {
            Msg msg = new Msg(0, "恢复失败！");
            try
            {
                M_LoginUser loginUser = WebHelper.GetLoginInfo();
                if (loginUser == null)
                {
                    msg.content = "无权限操作！";
                    return Json(msg);
                }

                string id = form.Q<string>("ID");
                int val = new B_Admin().SetAgentEnabledWithAudit(loginUser, id, 1, "禁用已解除");
                if (val < 0)
                {
                    msg.content = "无权限操作！";
                }
                else if (val == 0)
                {
                    msg.content = "代理账号不存在！";
                }
                else
                {
                    msg.code = 1;
                    msg.content = "操作成功";
                }
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.AgencyInfoController), ex);
            }
            return Json(msg);
        }

        #endregion

        [AjaxOnly]
        [HttpPost]
        public ActionResult DeleteAdmin(FormCollection form)
        {
            Msg msg = new Msg(0, "删除失败！");
            try
            {
                string id = form.Q<string>("ID");
                M_LoginUser m_LoginUser = WebHelper.GetLoginInfo();

                if (m_LoginUser != null && !string.IsNullOrWhiteSpace(id))
                {
                    if (m_LoginUser.Accounts.Equals(id))
                    {
                        msg.content = "不能删除自己！！！";
                        return Json(msg);
                    }

                    if (m_LoginUser.UserPriv != 0)
                    {
                        msg.content = "只有超级管理员可以删除代理！";
                        return Json(msg);
                    }

                    M_Admin mUsers = new M_Admin { ID = id};
                    int val = new B_Admin().DeleteAdmin(mUsers);
                    if (val > 0)
                    {
                        msg.code = 1;
                        msg.content = "删除成功！";
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
        public ActionResult ChgPwd(FormCollection form)
        {
            Msg msg = new Msg(0, "密码修改失败！");
            try
            {
                M_LoginUser loginUser = WebHelper.GetLoginInfo();
                string id = form.Q<string>("ID");
                string pwd = form.Q<string>("PWD");

                if (loginUser == null || (loginUser.UserPriv > 0 && loginUser.IsModifyPwd != 1))
                {
                    msg.content = "无权限操作！";
                    return Json(msg);
                }

                if (string.IsNullOrWhiteSpace(id))
                {
                    msg.content = "代理ID不能为空！";
                    return Json(msg);
                }
                if (string.IsNullOrWhiteSpace(pwd))
                {
                    msg.content = "密码不能为空！";
                    return Json(msg);
                }

                using (var ef = new GameDbContext())
                {
                    if (!new B_Admin().CanManageAgent(ef, loginUser, id))
                    {
                        msg.content = "无权限操作！";
                        return Json(msg);
                    }
                }

                M_Admin entity = new M_Admin { ID = id, PWD = pwd };
                int val = new B_Admin().ChgPwd(entity);
                if (val > 0)
                {
                    msg.code = 1;
                    msg.content = "修改成功";
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
        public ActionResult ChgCustomerServiceUrl(FormCollection form)
        {
            Msg msg = new Msg(0, "客服链接修改失败！");
            try
            {
                string id = form.Q<string>("ID");
                string CustomerServiceUrl = form.Q<string>("CustomerServiceUrl");

                if (string.IsNullOrWhiteSpace(id))
                {
                    msg.content = "代理ID不能为空！";
                    return Json(msg);
                }
                // 留空表示清除客服链接
                if (string.IsNullOrWhiteSpace(CustomerServiceUrl))
                    CustomerServiceUrl = null;

                M_Admin entity = new M_Admin { ID = id, CustomerServiceUrl = CustomerServiceUrl };
                int val = new B_Admin().ChgCustomerServiceUrl(entity);
                if (val > 0)
                {
                    msg.code = 1;
                    msg.content = "客服链接修改成功！";
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
        public ActionResult CanAddAgency()
        {
            Msg msg = new Msg(0, "当前代理创建已达上限，请联系上级代理！");
            try
            {
                M_LoginUser loginUser = WebHelper.GetLoginInfo();
                if (loginUser == null)
                    return Json(msg);

                if (loginUser.UserPriv == 0)
                {
                    msg.code = 1;
                    msg.content = "可以添加代理";
                    return Json(msg);
                }

                B_Admin bll = new B_Admin();
                M_Admin parentAdmin = bll.GetSingleOrDefault(new M_Admin { ID = loginUser.Accounts });
                if (parentAdmin == null)
                {
                    msg.content = "当前代理账号不存在！";
                    return Json(msg);
                }

                int directChildCount;
                using (var ef = new GameDbContext())
                {
                    directChildCount = ef.Admins.Count(a => a.AGENCY == loginUser.Accounts);
                }

                if (AgencyRules.CanCreateChild(loginUser.UserPriv ?? -1, parentAdmin.AGENCY_LIMIT, parentAdmin.IsCreateAgent, directChildCount))
                {
                    msg.code = 1;
                    msg.content = "可以添加代理";
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
        public ActionResult AddAgencyInfo(FormCollection form)
        {
            Msg msg = new Msg(0, "代理添加失败！");
            try
            {
                // 添加代理只要求输入一次密码(手机端与桌面弹窗均不提交 RE_PWD)。
                M_Admin entity = new M_Admin();
                if (TryUpdateModel<M_Admin>(entity) && ModelState.IsValid)
                {
                    M_LoginUser loginUser = WebHelper.GetLoginInfo();
                    if (loginUser == null)
                        return Json(msg);

                    int flag = form.Q<int>("FLAG", 0);// 0直属代理  1总代理
                    
                    entity.AGENCY = loginUser.Accounts;

                    if (flag == 0)
                    {
                        // 直属代理，层级+1
                        entity.PRIV = AgencyRules.GetChildLevel(loginUser.UserPriv ?? 0);
                    }
                    else
                    {
                        // 只有超级管理员可以添加总代理
                        if (loginUser.UserPriv == 0)
                        {
                            entity.PRIV = 1;
                        }
                        else
                        {
                            msg.content = "没有添加总代的权限！";
                            return Json(msg);
                        }
                    }

                    // 获取上级代理信息
                    B_Admin bll = new B_Admin();
                    M_Admin parentAdmin = bll.GetSingleOrDefault(new M_Admin { ID = loginUser.Accounts });
                    if (parentAdmin == null)
                    {
                        msg.content = "当前代理账号不存在！";
                        return Json(msg);
                    }
                    entity.AGENCY_LIMIT = entity.AGENCY_LIMIT ?? AgencyRules.UnlimitedAgencyLimit;
                    long createAgentPermission = form.Q<long>("IsCreateAgent", 1) == 0 ? 0 : 1;
                    // 新建普通代理统一使用后台默认权限，不能由客户端伪造权限字段覆盖。
                    ApplyDefaultAgencyPermissions(entity);
                    entity.IsCreateAgent = createAgentPermission;
                    
                    // 检查代理创建数量限制，AGENCY_LIMIT=0 表示无限制；大于0表示当前代理最多可创建几个直属下级代理。
                    if (loginUser.UserPriv > 0)
                    {
                        int directChildCount;
                        using (var ef = new GameDbContext())
                        {
                            directChildCount = ef.Admins.Count(a => a.AGENCY == loginUser.Accounts);
                        }
                        if (!AgencyRules.CanCreateChild(loginUser.UserPriv ?? -1, parentAdmin.AGENCY_LIMIT, parentAdmin.IsCreateAgent, directChildCount))
                        {
                            msg.content = "当前代理创建已达上限，请联系上级代理！";
                            return Json(msg);
                        }
                    }

                    // 生成随机邀请码
                    // 如果是总台添加且提供了自定义邀请码，则使用自定义的
                    if (loginUser.UserPriv == 0 && !string.IsNullOrWhiteSpace(entity.InviteCode))
                    {
                        string inviteCodeMessage;
                        using (var ef = new GameDbContext())
                        {
                            bool isValidInviteCode = AgencyRules.TryValidateInviteCode(
                                entity.InviteCode,
                                entity.ID,
                                ef.Admins.Select(a => a.ID).ToList(),
                                ef.Admins.Select(a => new { a.ID, a.InviteCode }).ToList().Select(a => new AgencyRules.InviteCodeOwner(a.ID, a.InviteCode)).ToList(),
                                out inviteCodeMessage);
                            if (!isValidInviteCode)
                            {
                                msg.content = inviteCodeMessage;
                                return Json(msg);
                            }
                        }
                    }
                    else
                    {
                        // 代理开代理时，默认从1000-9999随机分配；满了自动升到5位，最多8位。
                        entity.InviteCode = GenerateRandomInviteCode();
                    }


                    msg = bll.AddAgencyInfo(entity);
                }
                else
                {
                    msg.content = ModelState.Values.GetErrMsg();
                }
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.AgencyInfoController), ex);
            }
            return Json(msg);
        }

        private static void ApplyDefaultAgencyPermissions(M_Admin entity)
        {
            entity.IsFrozen = 1;
            entity.IsKicking = 0;
            entity.IsProbability = 0;
            entity.IsRelease = 0;
            entity.IsKill = 1;
            entity.IsUpDown = 1;
            entity.IsDelete = 0;
            entity.IsViewPwd = 0;
            entity.IsViewSafePwd = 0;
            entity.IsModifyPwd = 0;
            entity.IsResetSafePwd = 0;
            entity.IsGift = 0;
            entity.IsModifySafePwd = 0;
            entity.IsCreateAgent = 1;
            entity.KickScope = 2;
            entity.ManageScope = 2;
        }
        [AjaxOnly]
        [HttpPost]
        public ActionResult SaveAgencyLimit(FormCollection form)
        {
            Msg msg = new Msg(0, "分代上限设置失败！");
            try
            {
                M_LoginUser loginUser = WebHelper.GetLoginInfo();
                if (loginUser == null)
                    return Json(msg);

                string id = form.Q<string>("ID");
                int agency_limit = form.Q<int>("AGENCY_LIMIT");
                if (loginUser.UserPriv > 0)
                {
                    using (var ef = new GameDbContext())
                    {
                        List<string> managedAgencies = new B_Admin().GetManagedAgencyAccounts(ef, loginUser);
                        M_Admin target = ef.Admins.FirstOrDefault(a => a.ID == id);
                        if (target == null || target.ID == loginUser.Accounts || !managedAgencies.Contains(id))
                        {
                            msg.content = "只能设置自己管理范围内的下级代理！";
                            return Json(msg);
                        }
                    }
                }

                M_Admin entity = new M_Admin { ID = id, AGENCY_LIMIT = agency_limit };
                int val = new B_Admin().SaveAgencyLimit(entity);
                if (val > 0)
                {
                    msg.code = 1;
                    msg.content = "分代上限设置成功！";
                }
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.AgencyInfoController), ex);
            }
            return Json(msg);
        }

        public ActionResult GetAgenciesTreeData()
        {
            List<M_Agency> list = new List<M_Agency>();
            try
            {
                M_LoginUser loginUser = WebHelper.GetLoginInfo();
                if (loginUser == null)
                    return Json(list);

                B_Admin bll = new B_Admin();
                List<M_Admin> rst = bll.GetAgencies(loginUser);
                list = bll.AdminToAgencies(rst);
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.AgencyInfoController), ex);
            }
            return Json(list);
        }

        /// <summary>
        /// 设置邀请码
        /// </summary>
        [AjaxOnly]
        [HttpPost]
        public ActionResult SetInviteCode(FormCollection form)
        {
            Msg msg = new Msg(0, "邀请码设置失败！");
            try
            {
                string id = form.Q<string>("ID");
                string inviteCode = form.Q<string>("InviteCode");
                M_LoginUser loginUser = WebHelper.GetLoginInfo();

                if (string.IsNullOrWhiteSpace(id))
                {
                    msg.content = "代理ID不能为空！";
                    return Json(msg);
                }

                // 留空表示清除邀请码，跳过格式与去重校验
                bool isClearing = string.IsNullOrWhiteSpace(inviteCode);
                if (isClearing)
                    inviteCode = null;

                if (!isClearing)
                {
                    // 验证邀请码格式：4-8位纯数字（总台可自定义）
                    if (loginUser.UserPriv == 0)
                    {
                        // 总台可以设置4-8位纯数字
                        if (!System.Text.RegularExpressions.Regex.IsMatch(inviteCode, @"^\d{4,8}$"))
                        {
                            msg.content = "邀请码必须是4-8位纯数字！";
                            return Json(msg);
                        }
                    }
                    else
                    {
                        // 代理只能使用系统生成的4-5位随机数字
                        msg.content = "代理不能自定义邀请码！";
                        return Json(msg);
                    }

                    string inviteCodeMessage;
                    using (var ef = new GameDbContext())
                    {
                        bool isValidInviteCode = AgencyRules.TryValidateInviteCode(
                            inviteCode,
                            id,
                            ef.Admins.Select(a => a.ID).ToList(),
                            ef.Admins.Select(a => new { a.ID, a.InviteCode }).ToList().Select(a => new AgencyRules.InviteCodeOwner(a.ID, a.InviteCode)).ToList(),
                            out inviteCodeMessage);
                        if (!isValidInviteCode)
                        {
                            msg.content = inviteCodeMessage;
                            return Json(msg);
                        }
                    }
                }


                M_Admin entity = new M_Admin { ID = id, InviteCode = inviteCode };
                int val = new B_Admin().SetInviteCode(entity);
                if (val > 0)
                {
                    msg.code = 1;
                    msg.content = "邀请码设置成功！";
                }
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.AgencyInfoController), ex);
                msg.content = "邀请码设置失败：" + ex.Message;
            }
            return Json(msg);
        }

        /// <summary>
        /// 生成随机邀请码，默认4位1000-9999，满了自动升位。
        /// </summary>
        private string GenerateRandomInviteCode()
        {
            using (var ef = new GameDbContext())
            {
                return AgencyRules.GenerateInviteCode(
                    (min, max) =>
                    {
                        int len = min.ToString().Length;
                        return ef.Admins
                            .Where(a => a.InviteCode != null && a.InviteCode.Length == len)
                            .Select(a => a.InviteCode)
                            .ToList()
                            .Where(code =>
                            {
                                int value;
                                return int.TryParse(code, out value) && value >= min && value <= max;
                            });
                    },
                    (min, max) =>
                    {
                        int len = min.ToString().Length;
                        return ef.Admins
                            .Where(a => a.ID != null && a.ID.Length == len)
                            .Select(a => a.ID)
                            .ToList()
                            .Where(account =>
                            {
                                int value;
                                return int.TryParse(account, out value) && value >= min && value <= max;
                            });
                    });
            }
        }   

        /// <summary>
        /// 设置佣金比例
        /// </summary>
        [AjaxOnly]
        [HttpPost]
        public ActionResult SetCommissionRate(FormCollection form)
        {
            Msg msg = new Msg(0, "佣金比例设置失败！");
            try
            {
                string id = form.Q<string>("ID");
                decimal commissionRate = form.Q<decimal>("CommissionRate", 0);
                M_LoginUser loginUser = WebHelper.GetLoginInfo();
                if (loginUser == null || loginUser.UserPriv != 0)
                {
                    msg.content = "只有总台可以设置佣金比例！";
                    return Json(msg);
                }

                if (string.IsNullOrWhiteSpace(id))
                {
                    msg.content = "代理ID不能为空！";
                    return Json(msg);
                }

                // 验证佣金比例范围：0.01% - 100%
                if (commissionRate < 0.01m || commissionRate > 100m)
                {
                    msg.content = "佣金比例必须在0.01%-100%之间！";
                    return Json(msg);
                }

                M_Admin entity = new M_Admin { ID = id, CommissionRate = commissionRate };
                int val = new B_Admin().SetCommissionRate(entity);
                if (val > 0)
                {
                    msg.code = 1;
                    msg.content = "佣金比例设置成功！";
                }
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.AgencyInfoController), ex);
                msg.content = "佣金比例设置失败：" + ex.Message;
            }
            return Json(msg);
        }


    }
}
