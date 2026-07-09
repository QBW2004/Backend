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
            long limit = agencyLimit ?? UnlimitedAgencyLimit;
            if (limit <= 0)
                return true;
            if (createAgentPermission != 1)
                return false;
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
    }
}