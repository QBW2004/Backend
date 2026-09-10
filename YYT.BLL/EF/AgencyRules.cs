using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.RegularExpressions;

namespace YYT.BLL.EF
{
    public static class AgencyRules
    {
        public const int UnlimitedAgencyLimit = 0;
        public const string InviteCodeEmptyMessage = "邀请码不能为空！";
        public const string InviteCodeFormatMessage = "邀请码必须是4-8位纯数字！";
        public const string InviteCodeMatchesAccountMessage = "邀请码不能和代理账号相同，请更换邀请码";
        public const string InviteCodeDuplicateMessage = "该邀请码已被使用！";

        public static bool CanCreateChild(int currentLevel, long? agencyLimit)
        {
            return CanCreateChild(currentLevel, agencyLimit, 1);
        }

        public static bool CanCreateChild(int currentLevel, long? agencyLimit, long? createAgentPermission)
        {
            if (currentLevel < 0)
                return false;
            if (createAgentPermission != 1)
                return false;
            long limit = agencyLimit ?? UnlimitedAgencyLimit;
            if (limit <= 0)
                return true;
            return limit >= 0;
        }

        public static bool CanCreateChild(int currentLevel, long? agencyLimit, long? createAgentPermission, int currentDirectChildCount)
        {
            if (!CanCreateChild(currentLevel, agencyLimit, createAgentPermission))
                return false;

            long limit = agencyLimit ?? UnlimitedAgencyLimit;
            if (limit <= 0)
                return true;

            return currentDirectChildCount < limit;
        }

        public static int GetChildLevel(int currentLevel)
        {
            return currentLevel + 1;
        }

        public static long ResolveChildAgencyLimit(long? parentAgencyLimit)
        {
            long limit = parentAgencyLimit ?? UnlimitedAgencyLimit;
            if (limit <= 0)
                return UnlimitedAgencyLimit;
            return limit - 1;
        }

        public static long ResolveChildCreateAgentPermission(long? parentCreateAgentPermission)
        {
            return ResolveChildCreateAgentPermission(parentCreateAgentPermission, UnlimitedAgencyLimit);
        }

        public static long ResolveChildCreateAgentPermission(long? parentCreateAgentPermission, long? parentAgencyLimit)
        {
            long limit = parentAgencyLimit ?? UnlimitedAgencyLimit;
            if (limit == 1)
                return 0;
            return parentCreateAgentPermission == 1 ? 1 : 0;
        }

        public static List<string> GetManagedAgencyIds(string selfAccount, long? manageScope, IEnumerable<string> directAgencyIds, IEnumerable<string> lineAgencyIds)
        {
            IEnumerable<string> source = (manageScope ?? 1) == 2
                ? lineAgencyIds
                : directAgencyIds;

            HashSet<string> agencyIds = new HashSet<string>(source ?? Enumerable.Empty<string>());
            if (!string.IsNullOrWhiteSpace(selfAccount))
                agencyIds.Add(selfAccount);

            return agencyIds.ToList();
        }

        /// <summary>
        /// 统计每个代理名下整条继承链的下级代理数量（不含自身）。
        /// 传入的 links 必须覆盖同一权限范围内的全部代理，否则深层下级会被漏算。
        /// </summary>
        public static Dictionary<string, int> BuildDescendantCounts(IEnumerable<AgencyLink> links)
        {
            Dictionary<string, List<string>> children = BuildChildrenMap(links);
            Dictionary<string, int> counts = new Dictionary<string, int>(StringComparer.OrdinalIgnoreCase);
            foreach (string agencyId in children.Keys)
                CountDescendants(agencyId, children, counts, new HashSet<string>(StringComparer.OrdinalIgnoreCase));
            return counts;
        }

        /// <summary>
        /// 收集某个代理名下整条继承链的代理账号（不含自身），用于下钻展示整棵子树。
        /// </summary>
        public static HashSet<string> CollectDescendants(IEnumerable<AgencyLink> links, string rootAgencyId)
        {
            HashSet<string> descendants = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
            if (string.IsNullOrWhiteSpace(rootAgencyId))
                return descendants;

            Dictionary<string, List<string>> children = BuildChildrenMap(links);
            CollectDescendants(rootAgencyId.Trim(), children, descendants, new HashSet<string>(StringComparer.OrdinalIgnoreCase));
            descendants.Remove(rootAgencyId.Trim());
            return descendants;
        }

        private static Dictionary<string, List<string>> BuildChildrenMap(IEnumerable<AgencyLink> links)
        {
            Dictionary<string, List<string>> children = new Dictionary<string, List<string>>(StringComparer.OrdinalIgnoreCase);
            foreach (AgencyLink link in links ?? Enumerable.Empty<AgencyLink>())
            {
                if (link == null || string.IsNullOrWhiteSpace(link.AgencyId))
                    continue;
                if (!children.ContainsKey(link.AgencyId))
                    children[link.AgencyId] = new List<string>();
            }

            foreach (AgencyLink link in links ?? Enumerable.Empty<AgencyLink>())
            {
                if (link == null || string.IsNullOrWhiteSpace(link.AgencyId))
                    continue;
                string parent = link.ParentAgencyId == null ? string.Empty : link.ParentAgencyId.Trim();
                if (parent.Length == 0 || string.Equals(parent, link.AgencyId, StringComparison.OrdinalIgnoreCase))
                    continue;
                if (!children.ContainsKey(parent))
                    continue;
                children[parent].Add(link.AgencyId);
            }

            return children;
        }

        private static int CountDescendants(
            string agencyId,
            Dictionary<string, List<string>> children,
            Dictionary<string, int> counts,
            HashSet<string> visiting)
        {
            int cached;
            if (counts.TryGetValue(agencyId, out cached))
                return cached;

            // 历史脏数据可能出现环形上下级关系，visited 兜底避免递归失控。
            if (!visiting.Add(agencyId))
                return 0;

            int total = 0;
            List<string> childRows;
            if (children.TryGetValue(agencyId, out childRows))
            {
                foreach (string child in childRows)
                    total += 1 + CountDescendants(child, children, counts, visiting);
            }

            visiting.Remove(agencyId);
            counts[agencyId] = total;
            return total;
        }

        private static void CollectDescendants(
            string agencyId,
            Dictionary<string, List<string>> children,
            HashSet<string> descendants,
            HashSet<string> visiting)
        {
            if (!visiting.Add(agencyId))
                return;

            List<string> childRows;
            if (children.TryGetValue(agencyId, out childRows))
            {
                foreach (string child in childRows)
                {
                    if (descendants.Add(child))
                        CollectDescendants(child, children, descendants, visiting);
                }
            }

            visiting.Remove(agencyId);
        }

        public static bool TryValidateInviteCode(
            string inviteCode,
            string currentAgencyId,
            IEnumerable<string> agencyAccounts,
            IEnumerable<string> inviteCodes,
            out string message)
        {
            IEnumerable<InviteCodeOwner> owners = (inviteCodes ?? Enumerable.Empty<string>())
                .Select(code => new InviteCodeOwner(null, code));
            return TryValidateInviteCode(inviteCode, currentAgencyId, agencyAccounts, owners, out message);
        }

        public static bool TryValidateInviteCode(
            string inviteCode,
            string currentAgencyId,
            IEnumerable<string> agencyAccounts,
            IEnumerable<InviteCodeOwner> inviteCodeOwners,
            out string message)
        {
            inviteCode = inviteCode == null ? null : inviteCode.Trim();

            if (string.IsNullOrWhiteSpace(inviteCode))
            {
                message = InviteCodeEmptyMessage;
                return false;
            }

            if (!Regex.IsMatch(inviteCode, @"^\d{4,8}$"))
            {
                message = InviteCodeFormatMessage;
                return false;
            }

            HashSet<string> accounts = new HashSet<string>(agencyAccounts ?? Enumerable.Empty<string>());
            if (!string.IsNullOrWhiteSpace(currentAgencyId))
                accounts.Add(currentAgencyId);
            if (accounts.Contains(inviteCode))
            {
                message = InviteCodeMatchesAccountMessage;
                return false;
            }

            bool duplicate = (inviteCodeOwners ?? Enumerable.Empty<InviteCodeOwner>())
                .Any(owner => owner != null
                    && owner.InviteCode == inviteCode
                    && !string.Equals(owner.AgencyId, currentAgencyId, StringComparison.Ordinal));
            if (duplicate)
            {
                message = InviteCodeDuplicateMessage;
                return false;
            }

            message = string.Empty;
            return true;
        }

        public static string GenerateInviteCode(Func<int, int, IEnumerable<string>> existingCodesByRange, Random random = null)
        {
            return GenerateInviteCode(existingCodesByRange, null, random);
        }

        public static string GenerateInviteCode(
            Func<int, int, IEnumerable<string>> existingCodesByRange,
            Func<int, int, IEnumerable<string>> agencyAccountsByRange,
            Random random = null)
        {
            if (existingCodesByRange == null)
                throw new ArgumentNullException(nameof(existingCodesByRange));

            random = random ?? new Random(Guid.NewGuid().GetHashCode());

            for (int digits = 4; digits <= 8; digits++)
            {
                int min = digits == 4 ? 1000 : (int)Math.Pow(10, digits - 1);
                int max = (int)Math.Pow(10, digits) - 1;
                HashSet<string> unavailable = new HashSet<string>(existingCodesByRange(min, max) ?? Enumerable.Empty<string>());
                if (agencyAccountsByRange != null)
                {
                    foreach (string account in agencyAccountsByRange(min, max) ?? Enumerable.Empty<string>())
                        unavailable.Add(account);
                }

                int capacity = max - min + 1;

                if (unavailable.Count >= capacity)
                    continue;

                for (int i = 0; i < 200; i++)
                {
                    string code = random.Next(min, max + 1).ToString();
                    if (!unavailable.Contains(code))
                        return code;
                }

                for (int value = min; value <= max; value++)
                {
                    string code = value.ToString();
                    if (!unavailable.Contains(code))
                        return code;
                }
            }

            throw new InvalidOperationException("邀请码已无可用号码！");
        }

        public sealed class InviteCodeOwner
        {
            public InviteCodeOwner(string agencyId, string inviteCode)
            {
                AgencyId = agencyId;
                InviteCode = inviteCode;
            }

            public string AgencyId { get; private set; }
            public string InviteCode { get; private set; }
        }

        /// <summary>代理上下级关系：AgencyId 的直接上级账号为 ParentAgencyId。</summary>
        public sealed class AgencyLink
        {
            public AgencyLink(string agencyId, string parentAgencyId)
            {
                AgencyId = agencyId;
                ParentAgencyId = parentAgencyId;
            }

            public string AgencyId { get; private set; }
            public string ParentAgencyId { get; private set; }
        }
    }
}
