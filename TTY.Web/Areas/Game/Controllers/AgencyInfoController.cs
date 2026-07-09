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
                list = bll.GetAgencyList(mPage, mAdmin, loginUser);

                if (list != null && list.rows != null)
                {
                    List<M_AgencyProfit> profits = bll.GetAgencyProfits(loginUser);
                    foreach (var item in list.rows)
                    {
                        var tmp = profits.Find(c => c.Agency.Equals(item.ID));
                        item.Profit =  item.RECHARGE-item.EXCHANGE;
                        item.PlayerBalance = (tmp != null ? tmp.PlayerBalance : 0);
                        item.UserBalance = (tmp != null ? tmp.UserBalance : 0);
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

                    if (m_LoginUser.UserPriv > 0)
                    {
                        using (var ef = new GameDbContext())
                        {
                            List<string> managedAgencies = new B_Admin().GetManagedAgencyAccounts(ef, m_LoginUser);
                            M_Admin target = ef.Admins.FirstOrDefault(a => a.ID == id);
                            if (target == null || !managedAgencies.Contains(id))
                            {
                                msg.content = "只能删除自己管理范围内的下级代理！";
                                return Json(msg);
                            }
                        }
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
                string id = form.Q<string>("ID");
                string pwd = form.Q<string>("PWD");

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

                M_Admin entity = new M_Admin { ID = id, PWD = pwd };
                int val = new B_Admin().ChgPwd(entity);
                if (val > 0)
                {
                    msg.code = 1;
                    msg.content = "密码修改成功！";
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
                if (string.IsNullOrWhiteSpace(CustomerServiceUrl))
                {
                    msg.content = "客服链接不能为空！";
                    return Json(msg);
                }

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
                    ApplyDefaultAgencyPermissions(entity, form);
                    
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


                    // 设置默认权限
                    // 如果是总台添加，使用表单提交的权限值
                    // 如果是代理添加，使用默认权限
                    if (loginUser.UserPriv > 0)
                    {
                        // 代理添加下级代理的默认权限
                        if (entity.PRIV == 1)
                        {
                            // 一级代理默认权限（总台可编辑）
                            // 这里使用表单提交的值，如果没有则使用默认值
                        }
                        else
                        {
                            // 二级以下代理默认权限
                            entity.IsFrozen = entity.IsFrozen ?? 0;
                            entity.IsUpDown = entity.IsUpDown ?? 0;
                            entity.IsProbability = entity.IsProbability ?? 0;
                            entity.IsRelease = entity.IsRelease ?? 0;
                            entity.IsKill = entity.IsKill ?? 0;
                            entity.IsKicking = entity.IsKicking ?? 0;
                            entity.IsViewSafePwd = entity.IsViewSafePwd ?? 0;
                            entity.KickScope = entity.KickScope ?? 1;  // 默认只能踢直属
                            entity.IsCreateAgent = entity.IsCreateAgent ?? 1;
                            entity.ManageScope = entity.ManageScope ?? 1;  // 默认只管理直属
                        }
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

        private static void ApplyDefaultAgencyPermissions(M_Admin entity, FormCollection form)
        {
            entity.IsFrozen = form.Q<int>("IsFrozen", 1);
            entity.IsKicking = form.Q<int>("IsKicking", 1);
            entity.IsProbability = form.Q<int>("IsProbability", 0);
            entity.IsRelease = form.Q<int>("IsRelease", 0);
            entity.IsKill = form.Q<int>("IsKill", 0);
            entity.IsUpDown = form.Q<int>("IsUpDown", 1);
            entity.IsViewSafePwd = form.Q<int>("IsViewSafePwd", 0);
            entity.KickScope = form.Q<int>("KickScope", 2);
            entity.ManageScope = form.Q<int>("ManageScope", 2);
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
                
                if (string.IsNullOrWhiteSpace(inviteCode))
                {
                    msg.content = "邀请码不能为空！";
                    return Json(msg);
                }

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
