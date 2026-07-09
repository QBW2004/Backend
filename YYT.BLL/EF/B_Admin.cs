using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using YYT.Common;
using YYT.Entity;

namespace YYT.BLL.EF
{
    public class B_Admin
    {
        public M_Admin GetSingle(M_Admin model)
        {
            using (var ef = new GameDbContext())
            {
                return ef.Admins.Where(c => c.ID.Equals(model.ID)).First();
            }
        }

        public M_Admin GetSingleOrDefault(M_Admin model)
        {
            using (var ef = new GameDbContext())
            {
                return ef.Admins.FirstOrDefault(c => c.ID.Equals(model.ID));
            }
        }

        public List<M_Admin> GetAgencies(M_LoginUser loginUser)
        {
            using (var ef = new GameDbContext())
            {
                return ef.Admins.Where(c => c.AGENCY.Equals(loginUser.Accounts)).ToList();
            }
        }

        public List<M_Admin> GetAgenciesWithPermission(M_LoginUser loginUser, M_Agency entity)
        {
            AgencyFactory agencyFactory = new AgencyFactory((EAdminType)loginUser.UserPriv);
            IAgencyQuery agencyQuery = agencyFactory.agencyQuery;
            return agencyQuery.GetAgencies(entity);
        }

        public List<string> GetAgenciesWithPermission(GameDbContext ef, string account)
        {
            return ef.Database.SqlQuery<string>("CALL findOrgList({0})", account).ToList();// 递归
            //List<string> list = ef.Admins.Where(c => c.AGENCY.Equals(account)).Select(c => c.ID).ToList();// 直属
            //list.Add(account);
            //return list;
        }

        public List<string> GetAgencyLineAccounts(GameDbContext ef, string account)
        {
            List<string> accounts = GetAgenciesWithPermission(ef, account) ?? new List<string>();
            if (!accounts.Contains(account))
                accounts.Add(account);
            return accounts;
        }

        public List<string> GetManagedAgencyAccounts(GameDbContext ef, M_LoginUser loginUser)
        {
            if (loginUser == null)
                return new List<string>();

            List<string> directAccounts = ef.Admins
                .Where(c => c.AGENCY.Equals(loginUser.Accounts))
                .Select(c => c.ID)
                .ToList();
            List<string> lineAccounts = GetAgenciesWithPermission(ef, loginUser.Accounts) ?? new List<string>();

            return AgencyRules.GetManagedAgencyIds(loginUser.Accounts, loginUser.ManageScope, directAccounts, lineAccounts);
        }

        public bool IsInAgencyLine(GameDbContext ef, string ownerAccount, string targetAgency)
        {
            if (string.IsNullOrWhiteSpace(ownerAccount) || string.IsNullOrWhiteSpace(targetAgency))
                return false;
            return GetAgencyLineAccounts(ef, ownerAccount).Contains(targetAgency);
        }

        public List<string> GetOnlinePlayerAccountsInLine(string account)
        {
            using (var ef = new GameDbContext())
            {
                List<string> agencies = GetAgencyLineAccounts(ef, account);
                return ef.Users
                    .Where(u => u.INHALL && agencies.Contains(u.AGENCY))
                    .Select(u => u.ID)
                    .ToList();
            }
        }

        public List<string> GetOnlinePlayerAccountsByAgency(string account)
        {
            using (var ef = new GameDbContext())
            {
                return ef.Users
                    .Where(u => u.INHALL && u.AGENCY == account)
                    .Select(u => u.ID)
                    .ToList();
            }
        }
      

        public int SetRecharge(M_Admin entity)
        {
            using (var ef = new GameDbContext())
            {
                var agenciy = ef.Admins.Where(c => c.ID.Equals(entity.ID)).First();
                if (agenciy != null)
                {
                    if (agenciy.RE_ENABLE == entity.RE_ENABLE)
                        return 1;
                    agenciy.RE_ENABLE = entity.RE_ENABLE;
                    return ef.SaveChanges();
                }
            }
            return 0;
        }
        public int DeleteAdmin(M_Admin entity)
        {
            using (var ef = new GameDbContext())
            {
                var agenciy = ef.Admins.FirstOrDefault(c => c.ID.Equals(entity.ID));
                if (agenciy == null)
                    return 0;

                List<string> agencyIds = GetAgencyLineAccounts(ef, entity.ID);
                var users = ef.Users.Where(c => agencyIds.Contains(c.AGENCY)).ToList();
                var admins = ef.Admins.Where(c => agencyIds.Contains(c.ID)).ToList();
                ef.Users.RemoveRange(users);
                ef.Admins.RemoveRange(admins);
                return ef.SaveChanges();
            }
        }
      

        public int SetFrozen(M_Admin entity)
        {
            using (var ef = new GameDbContext())
            {
                var agenciy = ef.Admins.Where(c => c.ID.Equals(entity.ID)).First();
                if (agenciy != null)
                {
                    if (agenciy.IsFrozen == entity.IsFrozen)
                        return 1;
                    agenciy.IsFrozen = entity.IsFrozen;
                    return ef.SaveChanges();
                }
            }
            return 0;
        }

        public int SetProbability(M_Admin entity)
        {
            using (var ef = new GameDbContext())
            {
                var agenciy = ef.Admins.Where(c => c.ID.Equals(entity.ID)).First();
                if (agenciy != null)
                {
                    if (agenciy.IsProbability == entity.IsProbability)
                        return 1;
                    agenciy.IsProbability = entity.IsProbability;
                    return ef.SaveChanges();
                }
            }
            return 0;
        }

        public int SetKicking(M_Admin entity)
        {
            using (var ef = new GameDbContext())
            {
                var agenciy = ef.Admins.Where(c => c.ID.Equals(entity.ID)).First();
                if (agenciy != null)
                {
                    if (agenciy.IsKicking == entity.IsKicking)
                        return 1;
                    agenciy.IsKicking = entity.IsKicking;
                    return ef.SaveChanges();
                }
            }
            return 0;
        }
        public int SetDelete(M_Admin entity)
        {
            using (var ef = new GameDbContext())
            {
                var agenciy = ef.Admins.Where(c => c.ID.Equals(entity.ID)).First();
                if (agenciy != null)
                {
                    if (agenciy.IsDelete == entity.IsDelete)
                        return 1;
                    agenciy.IsDelete = entity.IsDelete;
                    return ef.SaveChanges();
                }
            }
            return 0;
        }

        public int ExChangeCoin(string playerId, long? coin)
        {
            int val = 0;
            using (var ef = new GameDbContext())
            {
                try
                {
                    var rst = ef.Admins.Where(c => c.ID.Equals(playerId)).SingleOrDefault();
                    if (rst != null)
                    {
                        if (playerId != "admin")
                        {
                            rst.COINS = rst.COINS + coin;//代理余额=余额+兑换金币
                        }
                        rst.EXCHANGE = rst.EXCHANGE + coin;//代理总兑换=总兑换+兑换金币
                        val = ef.SaveChanges();
                    }
                }
                catch (Exception ex)
                {
                    LogHelper.WriteLog(typeof(YYT.BLL.EF.B_Admin), ex);
                }
            }
            return val;

        }
        public int ExChangeCoinEx(string playerId, long? coin)
        {
            int val = 0;
            using (var ef = new GameDbContext())
            {
                try
                {
                    var rst = ef.Admins.Where(c => c.ID.Equals(playerId)).SingleOrDefault();
                    if (rst != null)
                    {
                        if (playerId != "admin")
                        {
                            rst.COINS = rst.COINS - coin;//代理余额=余额+兑换金币
                        }
                        rst.EXCHANGE = rst.EXCHANGE - coin;//代理总兑换=总兑换+兑换金币
                        val = ef.SaveChanges();
                    }
                }
                catch (Exception ex)
                {
                    LogHelper.WriteLog(typeof(YYT.BLL.EF.B_Admin), ex);
                }
            }
            return val;

        }

        public M_EasyuiGridData<M_Admin> GetAgencyList(M_Page mPage, M_Admin entity, M_LoginUser loginUser)
        {
            M_EasyuiGridData<M_Admin> list = new M_EasyuiGridData<M_Admin>();
            using (var ef = new GameDbContext())
            {
                var rst = loginUser.UserPriv == 0
                    ? from c in ef.Admins where c.PRIV > 0 || c.ID == loginUser.Accounts select c
                    : from c in ef.Admins where c.PRIV > 0 select c;
                if (!string.IsNullOrWhiteSpace(entity.AGENCY))
                    rst = rst.Where(c => c.AGENCY.Equals(entity.AGENCY));
                if (!string.IsNullOrWhiteSpace(entity.ID))
                    rst = rst.Where(c => c.ID.Equals(entity.ID));

                // 加权限查询
                if (loginUser.UserPriv != 0)
                {
                    List<string> permissions = GetManagedAgencyAccounts(ef, loginUser);
                    // 没有任何代理查询权限
                    if (permissions == null || permissions.Count < 1)
                        return list;
                    // 查询权限范围内的代理
                    rst = rst.Where(c => permissions.Contains(c.ID));
                }

                // 分页
                if (rst != null)
                {
                    var orderedUsers = BuildAgencyTreeRows(rst.ToList(), loginUser);
                    mPage.SetTotalCount(orderedUsers.Count);
                    list.rows = orderedUsers
                        .Skip(mPage.PageSize * (mPage.PageIndex - 1)).Take(mPage.PageSize)
                        .ToList();
                    list.total = mPage.TotalCount;
                }
            }
            return list;
        }

        private List<M_Admin> BuildAgencyTreeRows(List<M_Admin> agencies, M_LoginUser loginUser)
        {
            List<M_Admin> ordered = new List<M_Admin>();
            if (agencies == null || agencies.Count == 0)
                return ordered;

            Dictionary<string, List<M_Admin>> children = agencies
                .GroupBy(a => a.AGENCY ?? string.Empty)
                .ToDictionary(g => g.Key, g => g.OrderBy(a => a.PRIV ?? 0).ThenBy(a => a.ID).ToList());

            HashSet<string> visibleIds = new HashSet<string>(agencies.Select(a => a.ID));
            HashSet<string> visited = new HashSet<string>();
            int groupIndex = 0;

            List<M_Admin> roots = agencies
                .Where(a => loginUser.UserPriv == 0
                    ? string.Equals(a.ID, loginUser.Accounts, StringComparison.OrdinalIgnoreCase)
                    : !visibleIds.Contains(a.AGENCY ?? string.Empty))
                .OrderBy(a => a.PRIV ?? 0)
                .ThenBy(a => a.ID)
                .ToList();

            if (loginUser.UserPriv == 0 && roots.Count == 0)
            {
                roots = agencies
                    .Where(a => string.Equals(a.AGENCY, loginUser.Accounts, StringComparison.OrdinalIgnoreCase))
                    .OrderBy(a => a.PRIV ?? 0)
                    .ThenBy(a => a.ID)
                    .ToList();
            }

            foreach (M_Admin root in roots)
            {
                AppendAgencyTree(root, children, visited, ordered, groupIndex, 0);
                groupIndex++;
            }

            foreach (M_Admin agency in agencies.OrderBy(a => a.PRIV ?? 0).ThenBy(a => a.AGENCY).ThenBy(a => a.ID))
            {
                if (visited.Contains(agency.ID))
                    continue;
                AppendAgencyTree(agency, children, visited, ordered, groupIndex, 0);
                groupIndex++;
            }

            return ordered;
        }

        private void AppendAgencyTree(
            M_Admin agency,
            Dictionary<string, List<M_Admin>> children,
            HashSet<string> visited,
            List<M_Admin> ordered,
            int groupIndex,
            int depth)
        {
            if (agency == null || string.IsNullOrWhiteSpace(agency.ID) || visited.Contains(agency.ID))
                return;

            visited.Add(agency.ID);
            agency.AgencyGroupIndex = groupIndex;
            agency.AgencyTreeDepth = depth;
            agency.HasChildAgency = children.ContainsKey(agency.ID) && children[agency.ID].Any(c => !visited.Contains(c.ID));
            agency.CanCreateChildAgent = AgencyRules.CanCreateChild(agency.PRIV ?? -1, agency.AGENCY_LIMIT, agency.IsCreateAgent);
            ordered.Add(agency);

            List<M_Admin> childRows;
            if (!children.TryGetValue(agency.ID, out childRows))
                return;

            foreach (M_Admin child in childRows)
                AppendAgencyTree(child, children, visited, ordered, groupIndex, depth + 1);
        }

        public List<M_AgencyProfit> GetAgencyProfits(M_LoginUser loginUser)
        {
            List<M_AgencyProfit> list = new List<M_AgencyProfit>();
            using (var ef = new GameDbContext())
            {
                list = (from a in ef.Admins
                        group a by a.ID into g
                        select new M_AgencyProfit
                        {
                            Agency = g.Key,
                            PlayerBalance=g.Sum(c=>c.COINS),
                            UserBalance = 0

                        }).ToList();
                
                List<M_AgencyProfit> usersReports = (from a in ef.Users
                                                     group a by a.AGENCY into g
                                                     select new M_AgencyProfit
                                                     {
                                                         Agency = g.Key,
                                                         PlayerBalance = g.Sum(c => c.COINS),
                                                         UserBalance = g.Sum(c => c.COINS)
                                                     }).ToList();
                foreach (var item in list)
                {
                    var tmp = usersReports.Find(c => c.Agency.Equals(item.Agency));
                    item.PlayerBalance += (tmp != null ? tmp.PlayerBalance : 0);
                    item.UserBalance += (tmp != null ? tmp.UserBalance : 0);

                }

            }
            return list;
        }

        public int ChgPwd(M_Admin entity)
        {
            using (var ef = new GameDbContext())
            {
                ef.Configuration.ValidateOnSaveEnabled = false;
                var usr = ef.Admins.Where(c => c.ID.Equals(entity.ID)).First();
                if (usr != null)
                {
                    if (string.Equals(usr.PWD, entity.PWD))
                        return 1;
                    usr.PWD = entity.PWD;
                    return ef.SaveChanges();
                }
            }
            return 0;
        }

        public int ChgCustomerServiceUrl(M_Admin entity)
        {
            using (var ef = new GameDbContext())
            {
                var usr = ef.Admins.Where(c => c.ID.Equals(entity.ID)).First();
                if (usr != null)
                {
                    usr.CustomerServiceUrl = entity.CustomerServiceUrl;
                    return ef.SaveChanges();
                }
            }
            return 0;
        }

        /// <summary>
        /// 解析玩家所属代理的客服链接：自身为空则沿代理层级逐级向上查找；
        /// 整条代理线仍为空时回退到平台默认（最高级管理员 PRIV==0），再退而取任意已配置的链接。
        /// </summary>
        public string ResolveCustomerServiceUrl(string agencyId)
        {
            using (var ef = new GameDbContext())
            {
                string fromChain = ResolveCustomerServiceUrlFromChain(ef, agencyId);
                if (!string.IsNullOrWhiteSpace(fromChain))
                    return fromChain;

                // 回退一：平台默认（最高级管理员）
                M_Admin top = ef.Admins
                    .Where(c => c.PRIV == 0 && c.CustomerServiceUrl != null && c.CustomerServiceUrl != "")
                    .OrderBy(c => c.ID)
                    .FirstOrDefault();
                if (top != null && !string.IsNullOrWhiteSpace(top.CustomerServiceUrl))
                    return top.CustomerServiceUrl;

                // 回退二：任意已配置链接（按层级由高到低）
                M_Admin any = ef.Admins
                    .Where(c => c.CustomerServiceUrl != null && c.CustomerServiceUrl != "")
                    .OrderBy(c => c.PRIV)
                    .FirstOrDefault();
                return any != null ? any.CustomerServiceUrl : string.Empty;
            }
        }

        private string ResolveCustomerServiceUrlFromChain(GameDbContext ef, string agencyId)
        {
            HashSet<string> visited = new HashSet<string>();
            string current = agencyId;
            int guard = 0;
            while (!string.IsNullOrWhiteSpace(current) && guard++ < 64 && visited.Add(current))
            {
                M_Admin admin = ef.Admins.FirstOrDefault(c => c.ID.Equals(current));
                if (admin == null)
                    break;
                if (!string.IsNullOrWhiteSpace(admin.CustomerServiceUrl))
                    return admin.CustomerServiceUrl;
                current = admin.AGENCY;
            }
            return null;
        }

        public Msg AddAgencyInfo(M_Admin entity)
        {
            Msg msg = new Msg(0, "代理添加失败！");
            using (var ef = new GameDbContext())
            {
                if (ef.Admins.Where(c => c.ID.Equals(entity.ID)).Count() > 0)
                {
                    msg.content = "账号重复！添加失败！";
                    return msg;
                }

                string inviteCodeMessage;
                bool isValidInviteCode = AgencyRules.TryValidateInviteCode(
                    entity.InviteCode,
                    entity.ID,
                    ef.Admins.Select(a => a.ID).ToList(),
                    ef.Admins.Select(a => new { a.ID, a.InviteCode }).ToList().Select(a => new AgencyRules.InviteCodeOwner(a.ID, a.InviteCode)).ToList(),
                    out inviteCodeMessage);
                if (!isValidInviteCode)
                {
                    msg.content = inviteCodeMessage;
                    return msg;
                }

                entity.COINS = entity.COINS ?? 0;
                entity.COINS_BACK = entity.COINS_BACK ?? 0;
                entity.COINS_BUY = entity.COINS_BUY ?? 0;
                entity.EXCHANGE = entity.EXCHANGE ?? 0;
                entity.PRIV = entity.PRIV ?? -1;
                entity.RECHARGE = entity.RECHARGE ?? 0;
                entity.RE_ENABLE = entity.RE_ENABLE ?? 1;
                entity.AGENCY_LIMIT = entity.AGENCY_LIMIT ?? 0;
                entity.IsFrozen = entity.IsFrozen ?? 0;
                entity.IsProbability = entity.IsProbability ?? 0;
                entity.IsKicking = entity.IsKicking ?? 0;
                entity.IsDelete = entity.IsDelete ?? 0;
                entity.IsUpDown = entity.IsUpDown ?? 0;
                entity.KickScope = entity.KickScope ?? 1;
                entity.IsGift = entity.IsGift ?? 0;
                entity.IsCreateAgent = entity.IsCreateAgent ?? 0;
                entity.IsViewPwd = entity.IsViewPwd ?? 0;
                entity.IsModifyPwd = entity.IsModifyPwd ?? 0;
                entity.IsResetSafePwd = entity.IsResetSafePwd ?? 0;
                entity.IsKill = entity.IsKill ?? 0;
                entity.IsRelease = entity.IsRelease ?? 0;
                entity.IsViewSafePwd = entity.IsViewSafePwd ?? 0;
                entity.IsModifySafePwd = entity.IsModifySafePwd ?? 0;
                entity.ManageScope = entity.ManageScope ?? 1;
                entity.CommissionRate = entity.CommissionRate ?? 0.00m;
                entity.CreateTime = DateTime.Now;
                entity.UpdateTime = DateTime.Now;

                ef.Admins.Add(entity);
                int val = ef.SaveChanges();
                if (val > 0)
                {
                    msg.code = 1;
                    msg.content = "代理添加成功！";
                }
            }
            return msg;
        }

        public int SaveAgencyLimit(M_Admin entity)
        {
            using (var ef = new GameDbContext())
            {
                var usr = ef.Admins.FirstOrDefault(c => c.ID.Equals(entity.ID));
                if (usr != null)
                {
                    if (usr.AGENCY_LIMIT == entity.AGENCY_LIMIT && usr.IsCreateAgent == 1)
                        return 1;
                    usr.AGENCY_LIMIT = entity.AGENCY_LIMIT;
                    usr.IsCreateAgent = 1;
                    return ef.SaveChanges();
                }
            }
            return 0;
        }

        public List<M_Agency> AdminToAgencies(List<M_Admin> rst)
        {
            List<M_Agency> list = new List<M_Agency>();
            if (rst != null)
            {
                foreach (var item in rst)
                {
                    list.Add(new M_Agency { ID = item.ID, Agency = item.ID });
                }
            }
            return list;
        }

        public int SetUpDown(M_Admin entity)
        {
            using (var ef = new GameDbContext())
            {
                var admin = ef.Admins.FirstOrDefault(t => t.ID == entity.ID);
                if (admin != null)
                {
                    if (admin.IsUpDown == entity.IsUpDown)
                        return 1;
                    admin.IsUpDown = entity.IsUpDown;
                    admin.UpdateTime = DateTime.Now;
                    return ef.SaveChanges();
                }
            }
            return 0;
        }

        public int SetInviteCode(M_Admin entity)
        {
            using (var ef = new GameDbContext())
            {
                var admin = ef.Admins.FirstOrDefault(t => t.ID == entity.ID);
                if (admin != null)
                {
                    string inviteCodeMessage;
                    bool isValidInviteCode = AgencyRules.TryValidateInviteCode(
                        entity.InviteCode,
                        entity.ID,
                        ef.Admins.Select(a => a.ID).ToList(),
                        ef.Admins.Select(a => new { a.ID, a.InviteCode }).ToList().Select(a => new AgencyRules.InviteCodeOwner(a.ID, a.InviteCode)).ToList(),
                        out inviteCodeMessage);
                    if (!isValidInviteCode)
                        throw new InvalidOperationException(inviteCodeMessage);


                    admin.InviteCode = entity.InviteCode;
                    admin.UpdateTime = DateTime.Now;
                    return ef.SaveChanges();
                }
            }
            return 0;
        }

        public int SetCommissionRate(M_Admin entity)
        {
            using (var ef = new GameDbContext())
            {
                var admin = ef.Admins.FirstOrDefault(t => t.ID == entity.ID);
                if (admin != null)
                {
                    admin.CommissionRate = entity.CommissionRate;
                    admin.UpdateTime = DateTime.Now;
                    return ef.SaveChanges();
                }
            }
            return 0;
        }

        public int SetGiftPermission(M_Admin entity)
        {
            using (var ef = new GameDbContext())
            {
                var admin = ef.Admins.FirstOrDefault(t => t.ID == entity.ID);
                if (admin != null)
                {
                    if (admin.IsGift == entity.IsGift)
                        return 1;
                    admin.IsGift = entity.IsGift;
                    admin.UpdateTime = DateTime.Now;
                    return ef.SaveChanges();
                }
            }
            return 0;
        }

        public int SetCreateAgentPermission(M_Admin entity)
        {
            using (var ef = new GameDbContext())
            {
                var admin = ef.Admins.FirstOrDefault(t => t.ID == entity.ID);
                if (admin != null)
                {
                    if (admin.IsCreateAgent == entity.IsCreateAgent)
                        return 1;
                    admin.IsCreateAgent = entity.IsCreateAgent;
                    admin.UpdateTime = DateTime.Now;
                    return ef.SaveChanges();
                }
            }
            return 0;
        }

        public int SetKickScope(M_Admin entity)
        {
            using (var ef = new GameDbContext())
            {
                var admin = ef.Admins.FirstOrDefault(t => t.ID == entity.ID);
                if (admin != null)
                {
                    if (admin.KickScope == entity.KickScope)
                        return 1;
                    admin.KickScope = entity.KickScope;
                    admin.UpdateTime = DateTime.Now;
                    return ef.SaveChanges();
                }
            }
            return 0;
        }

        public int SetManageScope(M_Admin entity)
        {
            using (var ef = new GameDbContext())
            {
                var admin = ef.Admins.FirstOrDefault(t => t.ID == entity.ID);
                if (admin != null)
                {
                    if (admin.ManageScope == entity.ManageScope)
                        return 1;
                    admin.ManageScope = entity.ManageScope;
                    admin.UpdateTime = DateTime.Now;
                    return ef.SaveChanges();
                }
            }
            return 0;
        }

        public int SetViewPwdPermission(M_Admin entity)
        {
            using (var ef = new GameDbContext())
            {
                var admin = ef.Admins.FirstOrDefault(t => t.ID == entity.ID);
                if (admin != null)
                {
                    if (admin.IsViewPwd == entity.IsViewPwd)
                        return 1;
                    admin.IsViewPwd = entity.IsViewPwd;
                    admin.UpdateTime = DateTime.Now;
                    return ef.SaveChanges();
                }
            }
            return 0;
        }

        public int SetModifyPwdPermission(M_Admin entity)
        {
            using (var ef = new GameDbContext())
            {
                var admin = ef.Admins.FirstOrDefault(t => t.ID == entity.ID);
                if (admin != null)
                {
                    if (admin.IsModifyPwd == entity.IsModifyPwd)
                        return 1;
                    admin.IsModifyPwd = entity.IsModifyPwd;
                    admin.UpdateTime = DateTime.Now;
                    return ef.SaveChanges();
                }
            }
            return 0;
        }

        public int SetResetSafePwdPermission(M_Admin entity)
        {
            using (var ef = new GameDbContext())
            {
                var admin = ef.Admins.FirstOrDefault(t => t.ID == entity.ID);
                if (admin != null)
                {
                    if (admin.IsResetSafePwd == entity.IsResetSafePwd)
                        return 1;
                    admin.IsResetSafePwd = entity.IsResetSafePwd;
                    admin.UpdateTime = DateTime.Now;
                    return ef.SaveChanges();
                }
            }
            return 0;
        }

        public int SetKillPermission(M_Admin entity)
        {
            using (var ef = new GameDbContext())
            {
                var admin = ef.Admins.FirstOrDefault(t => t.ID == entity.ID);
                if (admin != null)
                {
                    if (admin.IsKill == entity.IsKill)
                        return 1;
                    admin.IsKill = entity.IsKill;
                    admin.UpdateTime = DateTime.Now;
                    return ef.SaveChanges();
                }
            }
            return 0;
        }

        public int SetReleasePermission(M_Admin entity)
        {
            using (var ef = new GameDbContext())
            {
                var admin = ef.Admins.FirstOrDefault(t => t.ID == entity.ID);
                if (admin != null)
                {
                    if (admin.IsRelease == entity.IsRelease)
                        return 1;
                    admin.IsRelease = entity.IsRelease;
                    admin.UpdateTime = DateTime.Now;
                    return ef.SaveChanges();
                }
            }
            return 0;
        }

        public int SetViewSafePwdPermission(M_Admin entity)
        {
            using (var ef = new GameDbContext())
            {
                var admin = ef.Admins.FirstOrDefault(t => t.ID == entity.ID);
                if (admin != null)
                {
                    if (admin.IsViewSafePwd == entity.IsViewSafePwd)
                        return 1;
                    admin.IsViewSafePwd = entity.IsViewSafePwd;
                    admin.UpdateTime = DateTime.Now;
                    return ef.SaveChanges();
                }
            }
            return 0;
        }

        public int SetModifySafePwdPermission(M_Admin entity)
        {
            using (var ef = new GameDbContext())
            {
                var admin = ef.Admins.FirstOrDefault(t => t.ID == entity.ID);
                if (admin != null)
                {
                    if (admin.IsModifySafePwd == entity.IsModifySafePwd)
                        return 1;
                    admin.IsModifySafePwd = entity.IsModifySafePwd;
                    admin.UpdateTime = DateTime.Now;
                    return ef.SaveChanges();
                }
            }
            return 0;
        }
    }
}
