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
        public const int AgentDisableAuditOpt = 24;
        public const int AgentEnableAuditOpt = 25;
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

        /// <summary>
        /// 返回当前账号可以查询/管理的会员所属代理集合。
        /// 直属管理只包含自己的会员；整线管理才包含所有下级代理的会员。
        /// </summary>
        public List<string> GetManagedPlayerAgencyAccounts(GameDbContext ef, M_LoginUser loginUser)
        {
            if (ef == null || loginUser == null || string.IsNullOrWhiteSpace(loginUser.Accounts))
                return new List<string>();
            if (loginUser.UserPriv == 0)
            {
                List<string> playerAgencies = ef.Users.Select(c => c.AGENCY)
                    .Where(c => c != null && c != "").ToList();
                List<string> agentAccounts = ef.Admins.Select(c => c.ID)
                    .Where(c => c != null && c != "").ToList();
                return playerAgencies.Concat(agentAccounts).Distinct().ToList();
            }
            if (loginUser.ManageScope == 2)
                return GetAgencyLineAccounts(ef, loginUser.Accounts);
            return new List<string> { loginUser.Accounts };
        }

        /// <summary>
        /// 返回指定代理节点下、且仍在查看者权限内的会员所属代理集合。
        /// 直属范围不能借由下级代理节点查看更深层会员；整线范围返回该节点整棵子树。
        /// </summary>
        public List<string> GetManagedPlayerAgencyAccounts(GameDbContext ef, M_LoginUser loginUser, string anchorAgency, bool includeDescendants = false)
        {
            List<string> allowed = GetManagedPlayerAgencyAccounts(ef, loginUser);
            if (string.IsNullOrWhiteSpace(anchorAgency))
                return allowed;

            string anchor = anchorAgency.Trim();
            if (!allowed.Any(c => string.Equals(c, anchor, StringComparison.OrdinalIgnoreCase)))
                return new List<string>();
            if (!includeDescendants)
                return new List<string> { anchor };
            if (loginUser.UserPriv != 0 && loginUser.ManageScope != 2)
                return string.Equals(anchor, loginUser.Accounts, StringComparison.OrdinalIgnoreCase)
                    ? new List<string> { loginUser.Accounts }
                    : new List<string>();

            HashSet<string> allowedSet = new HashSet<string>(allowed, StringComparer.OrdinalIgnoreCase);
            return GetAgencyLineAccounts(ef, anchor).Where(allowedSet.Contains).ToList();
        }

        public bool CanManageAgent(GameDbContext ef, M_LoginUser loginUser, string targetAgent, bool allowSelf = false)
        {
            if (ef == null || loginUser == null || string.IsNullOrWhiteSpace(targetAgent))
                return false;
            if (!allowSelf && string.Equals(loginUser.Accounts, targetAgent.Trim(), StringComparison.OrdinalIgnoreCase))
                return false;
            return loginUser.UserPriv == 0 || GetManagedAgencyAccounts(ef, loginUser)
                .Any(c => string.Equals(c, targetAgent.Trim(), StringComparison.OrdinalIgnoreCase));
        }

        public bool CanManagePlayer(GameDbContext ef, M_LoginUser loginUser, string playerAgency)
        {
            if (ef == null || loginUser == null || string.IsNullOrWhiteSpace(playerAgency))
                return false;
            return loginUser.UserPriv == 0 || GetManagedPlayerAgencyAccounts(ef, loginUser)
                .Any(c => string.Equals(c, playerAgency.Trim(), StringComparison.OrdinalIgnoreCase));
        }

        /// <summary>
        /// 判断代理账号是否在当前登录代理的管理范围内。
        /// </summary>
        public bool IsAgencyInManagedScope(GameDbContext ef, M_LoginUser loginUser, string agencyAccount)
        {
            if (ef == null || loginUser == null || string.IsNullOrWhiteSpace(agencyAccount))
                return false;
            if (loginUser.UserPriv == 0)
                return true;

            return GetManagedAgencyAccounts(ef, loginUser)
                .Any(c => string.Equals(c, agencyAccount, StringComparison.OrdinalIgnoreCase));
        }

        /// <summary>
        /// 判断玩家是否在当前登录代理的管理范围内。
        /// </summary>
        public bool IsUserInManagedScope(GameDbContext ef, M_LoginUser loginUser, string userId)
        {
            if (ef == null || loginUser == null || string.IsNullOrWhiteSpace(userId))
                return false;

            string agencyAccount = ef.Users
                .Where(c => c.ID == userId)
                .Select(c => c.AGENCY)
                .FirstOrDefault();
            return IsAgencyInManagedScope(ef, loginUser, agencyAccount);
        }

        /// <summary>
        /// 判断目标代理是否在当前登录代理的管理范围内，且不能操作自己。
        /// </summary>
        public bool IsTargetAgencyInManagedScope(GameDbContext ef, M_LoginUser loginUser, string agencyId)
        {
            if (ef == null || loginUser == null || string.IsNullOrWhiteSpace(agencyId)
                || string.Equals(loginUser.Accounts, agencyId, StringComparison.OrdinalIgnoreCase))
                return false;
            if (loginUser.UserPriv == 0)
                return ef.Admins.Any(c => c.ID == agencyId);

            return GetManagedAgencyAccounts(ef, loginUser)
                .Any(c => string.Equals(c, agencyId, StringComparison.OrdinalIgnoreCase));
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
      

        /// <summary>
        /// 只改启用状态，不写审计日志也不做权限校验。界面（含桌面端启用/禁用）一律走
        /// <see cref="SetAgentEnabledWithAudit"/>，否则封禁记录没有操作人、且能绕过封禁记录归属口径。
        /// </summary>
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

        #region 手机端扩展（封禁代理列表 / 禁用记录）
        /// <summary>
        /// 手机端：封禁中的代理分页（RE_ENABLE = 0 即禁止登录）。
        /// 可见口径：总台全部；特级代理限自己整条线内；其余代理只能看自己封的（见 CanAccessBanRecord）。
        /// </summary>
        public M_EasyuiGridData<M_Admin> GetBannedAgenciesList(M_Page mPage, M_LoginUser loginUser)
        {
            M_EasyuiGridData<M_Admin> list = new M_EasyuiGridData<M_Admin>();
            List<M_Admin> rows = new List<M_Admin>();
            using (var ef = new GameDbContext())
            {
                if (loginUser != null)
                {
                    var rst = ef.Admins.Where(c => c.RE_ENABLE == 0 && !c.ID.Equals(loginUser.Accounts));
                    int priv = loginUser.UserPriv ?? -1;
                    if (priv == AgencyRules.SuperAdminPriv)
                    {
                        rows = rst.OrderBy(c => c.ID).ToList();
                    }
                    else if (priv == AgencyRules.TopAgentPriv)
                    {
                        List<string> line = GetAgencyLineAccounts(ef, loginUser.Accounts);
                        rows = line.Count > 0
                            ? rst.Where(c => line.Contains(c.ID)).OrderBy(c => c.ID).ToList()
                            : new List<M_Admin>();
                    }
                    else
                    {
                        // 只有最近一次禁用操作是自己做的才可见；查不到操作人的记录（操作日志已过期）不返回
                        List<M_Admin> banned = rst.OrderBy(c => c.ID).ToList();
                        Dictionary<string, string> operators = GetLatestBanOperators(ef, banned.Select(c => c.ID), AgentDisableAuditOpt);
                        rows = banned.Where(c =>
                        {
                            string op;
                            return operators.TryGetValue(c.ID, out op)
                                && string.Equals(op, loginUser.Accounts, StringComparison.OrdinalIgnoreCase);
                        }).ToList();
                    }
                }

                if (mPage != null)
                {
                    mPage.SetTotalCount(rows.Count);
                    list.rows = rows.Skip(mPage.PageSize * (mPage.PageIndex - 1)).Take(mPage.PageSize).ToList();
                    list.total = mPage.TotalCount;
                }
                else
                {
                    list.rows = rows;
                    list.total = rows.Count;
                }
            }
            return list;
        }

        /// <summary>
        /// 手机端：代理禁用/恢复记录分页（OPT 24=禁用 25=恢复，禁用代理页据此展示封号提示与时间）。
        /// 与禁用列表同口径：总台全部；特级代理限自己整条线；其余只返回自己操作的记录。
        /// </summary>
        public M_EasyuiGridData<M_AgencyOptLog> GetBlacklistRecords(M_Page mPage, M_LoginUser loginUser)
        {
            M_EasyuiGridData<M_AgencyOptLog> list = new M_EasyuiGridData<M_AgencyOptLog>();
            using (var ef = new GameDbContext())
            {
                DateTime cutoff = B_Records_MySQL.GetRetentionCutoff();
                var rst = ef.AgencyOptLogs.Where(c => c.REC_TIME >= cutoff &&
                    (c.OPT == AgentDisableAuditOpt || c.OPT == AgentEnableAuditOpt));
                if (loginUser != null && (loginUser.UserPriv ?? -1) != AgencyRules.SuperAdminPriv)
                {
                    if ((loginUser.UserPriv ?? -1) == AgencyRules.TopAgentPriv)
                    {
                        List<string> line = GetAgencyLineAccounts(ef, loginUser.Accounts);
                        if (line.Count < 1)
                            return list;
                        rst = rst.Where(c => line.Contains(c.ID));
                    }
                    else
                    {
                        string me = loginUser.Accounts;
                        rst = rst.Where(c => c.OptID == me);
                    }
                }

                mPage.SetTotalCount(rst.Count());
                list.rows = rst.OrderByDescending(c => c.LID)
                    .Skip(mPage.PageSize * (mPage.PageIndex - 1)).Take(mPage.PageSize)
                    .ToList();
                list.total = mPage.TotalCount;
            }
            return list;
        }

        /// <summary>
        /// 代理封禁/解除的资格判定：封禁按管理范围校验；解除「已处于禁用态」的账号按封禁记录归属
        /// （操作人本人、特级代理本线内、总台）；本就未禁用的重复解除仍按管理范围。
        /// </summary>
        public bool CanOperateAgentEnabled(GameDbContext ef, M_LoginUser loginUser, string targetId, long enabled)
        {
            if (ef == null || loginUser == null || string.IsNullOrWhiteSpace(targetId))
                return false;

            M_Admin target = ef.Admins.FirstOrDefault(a => a.ID == targetId.Trim());
            return target != null && CanOperateAgentEnabled(ef, loginUser, target, enabled);
        }

        public bool CanOperateAgentEnabled(GameDbContext ef, M_LoginUser loginUser, M_Admin target, long enabled)
        {
            if (ef == null || loginUser == null || target == null || string.IsNullOrWhiteSpace(target.ID))
                return false;
            if (enabled != 0 && target.RE_ENABLE == 0)
                return CanAccessBanRecord(ef, loginUser, target.ID, AgentDisableAuditOpt);
            return CanManageAgent(ef, loginUser, target.ID);
        }

        /// <summary>
        /// 封禁/冻结记录（opt=24 代理禁用 / 26 玩家冻结）的查看与解除口径。
        /// targetAccount 传被封的代理账号，或玩家所属代理账号。
        /// </summary>
        public bool CanAccessBanRecord(GameDbContext ef, M_LoginUser loginUser, string targetAccount, int opt)
        {
            if (ef == null || loginUser == null || string.IsNullOrWhiteSpace(targetAccount))
                return false;

            int priv = loginUser.UserPriv ?? -1;
            if (priv == AgencyRules.SuperAdminPriv)
                return true;

            string target = targetAccount.Trim();
            string operatorAccount = GetLatestBanOperator(ef, target, opt);
            bool targetInLine = priv == AgencyRules.TopAgentPriv
                && IsInAgencyLine(ef, loginUser.Accounts, target);
            return AgencyRules.CanAccessBanRecord(loginUser.UserPriv, loginUser.Accounts, operatorAccount, targetInLine);
        }

        /// <summary>目标账号最近一次封禁类操作（opt）的操作人账号；查不到（含日志已过期）返回空串。</summary>
        public string GetLatestBanOperator(GameDbContext ef, string targetId, int opt)
        {
            if (ef == null || string.IsNullOrWhiteSpace(targetId))
                return string.Empty;

            string account = targetId.Trim();
            M_AgencyOptLog latest = ef.AgencyOptLogs
                .Where(c => c.ID == account && c.OPT == opt)
                .OrderByDescending(c => c.REC_TIME)
                .ThenByDescending(c => c.LID)
                .FirstOrDefault();
            return latest == null || latest.OptID == null ? string.Empty : latest.OptID.Trim();
        }

        /// <summary>
        /// 批量取各目标账号最近一次封禁类操作（opt）的操作人账号。
        /// 只传当前处于封禁/冻结态的目标（量级很小），非特权账号据此筛出"自己操作的"记录。
        /// </summary>
        public static Dictionary<string, string> GetLatestBanOperators(GameDbContext ef, IEnumerable<string> targetIds, int opt)
        {
            Dictionary<string, string> result = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
            if (ef == null)
                return result;

            List<string> ids = (targetIds ?? Enumerable.Empty<string>())
                .Where(c => !string.IsNullOrWhiteSpace(c))
                .Select(c => c.Trim())
                .Distinct(StringComparer.OrdinalIgnoreCase)
                .ToList();
            if (ids.Count < 1)
                return result;

            // 分块查询，避免 IN 参数过长（投影用匿名类型：EF6 不允许在查询里构造映射实体）
            List<M_AgencyOptLog> logs = new List<M_AgencyOptLog>();
            for (int i = 0; i < ids.Count; i += 300)
            {
                List<string> chunk = ids.Skip(i).Take(300).ToList();
                var rows = ef.AgencyOptLogs
                    .Where(c => chunk.Contains(c.ID) && c.OPT == opt)
                    .Select(c => new { c.ID, c.OptID, c.REC_TIME, c.LID })
                    .ToList();
                foreach (var row in rows)
                {
                    logs.Add(new M_AgencyOptLog
                    {
                        ID = row.ID,
                        OptID = row.OptID,
                        REC_TIME = row.REC_TIME,
                        LID = row.LID
                    });
                }
            }

            foreach (M_AgencyOptLog log in logs.OrderByDescending(c => c.REC_TIME).ThenByDescending(c => c.LID))
            {
                if (!result.ContainsKey(log.ID))
                    result[log.ID] = log.OptID == null ? string.Empty : log.OptID.Trim();
            }
            return result;
        }

        /// <summary>
        /// 返回"最近一次封禁类操作（opt）由 opAccount 执行"的目标账号集合；
        /// 非特权账号的可见范围即由此产生（只看得见自己封的）。
        /// </summary>
        public List<string> GetBanTargetsOwnedBy(GameDbContext ef, string opAccount, int opt)
        {
            List<string> owned = new List<string>();
            if (ef == null || string.IsNullOrWhiteSpace(opAccount))
                return owned;

            string owner = opAccount.Trim();
            List<string> candidates = ef.AgencyOptLogs
                .Where(c => c.OptID == owner && c.OPT == opt)
                .Select(c => c.ID)
                .Distinct()
                .ToList();
            if (candidates.Count < 1)
                return owned;

            Dictionary<string, string> latest = GetLatestBanOperators(ef, candidates, opt);
            foreach (string id in candidates)
            {
                string op;
                if (latest.TryGetValue(id, out op) && string.Equals(op, owner, StringComparison.OrdinalIgnoreCase))
                    owned.Add(id);
            }
            return owned;
        }

        /// <summary>
        /// 在同一事务中更新代理登录状态并写入审计日志。
        /// 返回 -1 表示越权，0 表示目标不存在，1 表示操作完成（包括状态本来就一致）。
        /// </summary>
        public int SetAgentEnabledWithAudit(M_LoginUser loginUser, string targetId, long enabled, string reason)
        {
            if (loginUser == null || string.IsNullOrWhiteSpace(targetId))
                return -1;

            targetId = targetId.Trim();
            using (var ef = new GameDbContext())
            {
                M_Admin target = ef.Admins.FirstOrDefault(a => a.ID == targetId);
                if (target == null)
                    return 0;
                if (!CanOperateAgentEnabled(ef, loginUser, target, enabled))
                    return -1;

                using (var transaction = ef.Database.BeginTransaction())
                {
                    try
                    {
                        long beforeEnabled = target.RE_ENABLE == 0 ? 0 : 1;
                        target.RE_ENABLE = enabled == 0 ? 0 : 1;
                        DateTime now = DateTime.Now;
                        ef.AgencyOptLogs.Add(new M_AgencyOptLog
                        {
                            OptID = loginUser.Accounts,
                            SrcUserTitle = loginUser.Accounts,
                            ID = targetId,
                            DestUserTitle = string.IsNullOrWhiteSpace(reason)
                                ? (enabled == 0 ? "该账号已被禁用" : "禁用已解除")
                                : reason.Trim(),
                            OPT = enabled == 0 ? AgentDisableAuditOpt : AgentEnableAuditOpt,
                            COINS = 0,
                            BEF_COINS = beforeEnabled,
                            AFT_COINS = enabled == 0 ? 0 : 1,
                            REC_TIME = now,
                            WEEK = now.WeekOfYear()
                        });
                        ef.SaveChanges();
                        transaction.Commit();
                        return 1;
                    }
                    catch (Exception ex)
                    {
                        transaction.Rollback();
                        LogHelper.WriteLog(typeof(B_Admin), ex);
                        return 0;
                    }
                }
            }
        }
        #endregion

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
                        if (playerId != "atmadmin")
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
                        if (playerId != "atmadmin")
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
                var scoped = loginUser.UserPriv == 0
                    ? from c in ef.Admins where c.PRIV > 0 || c.ID == loginUser.Accounts select c
                    : from c in ef.Admins where c.PRIV > 0 select c;
                if (loginUser.UserPriv != 0)
                {
                    List<string> permissions = GetManagedAgencyAccounts(ef, loginUser);
                    // 没有任何代理查询权限
                    if (permissions == null || permissions.Count < 1)
                        return list;
                    // 查询权限范围内的代理
                    scoped = scoped.Where(c => permissions.Contains(c.ID));
                }

                // 直属下级数量以“权限范围内的全部代理”为基准统计，而不是当前筛选后的行集：
                // 否则下钻到某一层时，该层的下级不在结果集里，“下级代理”会整列显示 0 个。
                // 代理表数据量很小（几十行），一次性取出上下级关系即可，避免逐个账号调用递归存储过程。
                List<AgencyRules.AgencyLink> links = scoped
                    .Select(c => new { c.ID, c.AGENCY })
                    .ToList()
                    .Select(a => new AgencyRules.AgencyLink(a.ID, a.AGENCY))
                    .ToList();
                Dictionary<string, int> childCounts = AgencyRules.BuildDirectChildCounts(links);

                var rst = scoped;
                // AGENCY 是下级下钻的父节点导航，保持精确；ID 是账号搜索，统一模糊匹配（LIKE '%kw%'）
                if (!string.IsNullOrWhiteSpace(entity.AGENCY))
                    rst = rst.Where(c => c.AGENCY.Equals(entity.AGENCY));
                if (!string.IsNullOrWhiteSpace(entity.ID))
                    rst = rst.Where(c => c.ID.Contains(entity.ID));

                // 加权限查询
                // 代理列表不展示当前登录账号本身，避免把自身误认为可操作的下级代理。
                rst = rst.Where(c => !c.ID.Equals(loginUser.Accounts));

                // 分页
                if (rst != null)
                {
                    var orderedUsers = BuildAgencyTreeRows(rst.ToList(), loginUser, childCounts);
                    mPage.SetTotalCount(orderedUsers.Count);
                    list.rows = orderedUsers
                        .Skip(mPage.PageSize * (mPage.PageIndex - 1)).Take(mPage.PageSize)
                        .ToList();
                    list.total = mPage.TotalCount;
                }
            }
            return list;
        }

        private List<M_Admin> BuildAgencyTreeRows(List<M_Admin> agencies, M_LoginUser loginUser, Dictionary<string, int> childCounts)
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
                AppendAgencyTree(root, children, visited, ordered, groupIndex, 0, childCounts);
                groupIndex++;
            }

            foreach (M_Admin agency in agencies.OrderBy(a => a.PRIV ?? 0).ThenBy(a => a.AGENCY).ThenBy(a => a.ID))
            {
                if (visited.Contains(agency.ID))
                    continue;
                AppendAgencyTree(agency, children, visited, ordered, groupIndex, 0, childCounts);
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
            int depth,
            Dictionary<string, int> childCounts)
        {
            if (agency == null || string.IsNullOrWhiteSpace(agency.ID) || visited.Contains(agency.ID))
                return;

            visited.Add(agency.ID);
            agency.AgencyGroupIndex = groupIndex;
            agency.AgencyTreeDepth = depth;
            agency.HasChildAgency = children.ContainsKey(agency.ID) && children[agency.ID].Any(c => !visited.Contains(c.ID));
            // 下级代理数量只统计直属下级，不含更深层级；基准是权限范围内的全表，下钻后不会归零。
            int childCount;
            agency.SubAgencyCount = childCounts.TryGetValue(agency.ID, out childCount)
                ? childCount
                : (children.ContainsKey(agency.ID) ? children[agency.ID].Count : 0);
            agency.CanCreateChildAgent = AgencyRules.CanCreateChild(agency.PRIV ?? -1, agency.AGENCY_LIMIT, agency.IsCreateAgent);
            ordered.Add(agency);

            List<M_Admin> childRows;
            if (!children.TryGetValue(agency.ID, out childRows))
                return;

            foreach (M_Admin child in childRows)
                AppendAgencyTree(child, children, visited, ordered, groupIndex, depth + 1, childCounts);
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
        /// 解析玩家所属代理的客服链接：仅取直属代理配置的链接，未配置则返回空串，不做向上回退。
        /// </summary>
        public string ResolveCustomerServiceUrl(string agencyId)
        {
            using (var ef = new GameDbContext())
            {
                if (string.IsNullOrWhiteSpace(agencyId))
                    return string.Empty;

                M_Admin admin = ef.Admins.FirstOrDefault(c => c.ID.Equals(agencyId));
                return admin != null && !string.IsNullOrWhiteSpace(admin.CustomerServiceUrl)
                    ? admin.CustomerServiceUrl
                    : string.Empty;
            }
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

                ApplyNewAgencyDefaultPermissions(entity);

                entity.COINS = entity.COINS ?? 0;
                entity.COINS_BACK = entity.COINS_BACK ?? 0;
                entity.COINS_BUY = entity.COINS_BUY ?? 0;
                entity.EXCHANGE = entity.EXCHANGE ?? 0;
                entity.PRIV = entity.PRIV ?? -1;
                entity.RECHARGE = entity.RECHARGE ?? 0;
                entity.RE_ENABLE = entity.RE_ENABLE ?? 1;
                entity.AGENCY_LIMIT = entity.AGENCY_LIMIT ?? 0;
                entity.IsFrozen = entity.IsFrozen ?? 1;
                entity.IsProbability = entity.IsProbability ?? 0;
                entity.IsKicking = entity.IsKicking ?? 0;
                entity.IsDelete = entity.IsDelete ?? 0;
                entity.IsUpDown = entity.IsUpDown ?? 1;
                entity.KickScope = entity.KickScope ?? 2;
                entity.IsGift = entity.IsGift ?? 0;
                entity.IsCreateAgent = entity.IsCreateAgent ?? 1;
                entity.IsViewPwd = entity.IsViewPwd ?? 0;
                entity.IsModifyPwd = entity.IsModifyPwd ?? 0;
                entity.IsResetSafePwd = entity.IsResetSafePwd ?? 0;
                entity.IsKill = entity.IsKill ?? 1;
                entity.IsRelease = entity.IsRelease ?? 0;
                entity.IsViewSafePwd = entity.IsViewSafePwd ?? 0;
                entity.IsModifySafePwd = entity.IsModifySafePwd ?? 0;
                entity.ManageScope = entity.ManageScope ?? 2;
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

        private static void ApplyNewAgencyDefaultPermissions(M_Admin entity)
        {
            entity.IsFrozen = 1;
            entity.IsKill = 1;
            entity.IsUpDown = 1;
            entity.IsKicking = 1;
            entity.ManageScope = 2;
            entity.KickScope = entity.ManageScope;

            entity.IsProbability = 0;
            entity.IsRelease = 0;
            entity.IsDelete = 0;
            entity.IsGift = 0;
            // IsCreateAgent 不在这里硬编码：调用方（AddAgencyInfo 控制器）已按请求值透传，AddAgencyInfo 的 ?? 1 负责缺省开启
            entity.IsViewPwd = 0;
            entity.IsModifyPwd = 0;
            entity.IsResetSafePwd = 0;
            entity.IsViewSafePwd = 0;
            entity.IsModifySafePwd = 0;
            entity.IsDeleteAgent = 0;
            entity.IsViewAgentPwd = 0;
            entity.IsModifyAgentPwd = 0;
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
                    // 留空表示清除邀请码，跳过格式与去重校验
                    if (!string.IsNullOrWhiteSpace(entity.InviteCode))
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
                    }


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
                    // KickScope 仅作为历史兼容字段，实际范围统一由 ManageScope 决定。
                    long manageScope = entity.ManageScope ?? admin.ManageScope ?? 1;
                    bool changed = false;
                    if (admin.ManageScope != manageScope)
                    {
                        admin.ManageScope = manageScope;
                        changed = true;
                    }
                    if (admin.KickScope != manageScope)
                    {
                        admin.KickScope = manageScope;
                        changed = true;
                    }
                    if (!changed)
                        return 1;
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
                    bool changed = false;
                    if (admin.ManageScope != entity.ManageScope)
                    {
                        admin.ManageScope = entity.ManageScope;
                        changed = true;
                    }
                    // 踢人范围已统一跟随管理范围，保留字段仅用于兼容旧数据。
                    if (admin.KickScope != entity.ManageScope)
                    {
                        admin.KickScope = entity.ManageScope;
                        changed = true;
                    }
                    if (!changed)
                        return 1;
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

        public int SetDeleteAgentPermission(M_Admin entity)
        {
            using (var ef = new GameDbContext())
            {
                var admin = ef.Admins.FirstOrDefault(t => t.ID == entity.ID);
                if (admin != null)
                {
                    if (admin.IsDeleteAgent == entity.IsDeleteAgent)
                        return 1;
                    admin.IsDeleteAgent = entity.IsDeleteAgent;
                    admin.UpdateTime = DateTime.Now;
                    return ef.SaveChanges();
                }
            }
            return 0;
        }

        public int SetViewAgentPwdPermission(M_Admin entity)
        {
            using (var ef = new GameDbContext())
            {
                var admin = ef.Admins.FirstOrDefault(t => t.ID == entity.ID);
                if (admin != null)
                {
                    if (admin.IsViewAgentPwd == entity.IsViewAgentPwd)
                        return 1;
                    admin.IsViewAgentPwd = entity.IsViewAgentPwd;
                    admin.UpdateTime = DateTime.Now;
                    return ef.SaveChanges();
                }
            }
            return 0;
        }

        public int SetModifyAgentPwdPermission(M_Admin entity)
        {
            using (var ef = new GameDbContext())
            {
                var admin = ef.Admins.FirstOrDefault(t => t.ID == entity.ID);
                if (admin != null)
                {
                    if (admin.IsModifyAgentPwd == entity.IsModifyAgentPwd)
                        return 1;
                    admin.IsModifyAgentPwd = entity.IsModifyAgentPwd;
                    admin.UpdateTime = DateTime.Now;
                    return ef.SaveChanges();
                }
            }
            return 0;
        }
    }
}
