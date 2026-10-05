using System.Collections.Generic;
using System.Linq;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using YYT.BLL.EF;

namespace UnitTestProj
{
    [TestClass]
    public class AgencyRulesTest
    {
        [TestMethod]
        public void UnlimitedAgencyLimitAllowsMoreThanEightLevels()
        {
            Assert.IsTrue(AgencyRules.CanCreateChild(8, 0));
            Assert.AreEqual(9, AgencyRules.GetChildLevel(8));
        }

        [TestMethod]
        public void LimitedAgencyLimitStopsAtConfiguredLevel()
        {
            Assert.IsTrue(AgencyRules.CanCreateChild(8, 0, 1));
            Assert.IsTrue(AgencyRules.CanCreateChild(8, 1, 1));
            Assert.IsFalse(AgencyRules.CanCreateChild(8, 0, 0));
            Assert.IsFalse(AgencyRules.CanCreateChild(8, 1, 0));
            Assert.IsTrue(AgencyRules.CanCreateChild(1, 3, 1, 2));
            Assert.IsFalse(AgencyRules.CanCreateChild(1, 3, 1, 3));
        }

        [TestMethod]
        public void ChildAgentInheritsCreatePermissionAndAgencyLimit()
        {
            Assert.AreEqual(1, AgencyRules.ResolveChildCreateAgentPermission(1, 0));
            Assert.AreEqual(1, AgencyRules.ResolveChildCreateAgentPermission(1, 2));
            Assert.AreEqual(0, AgencyRules.ResolveChildCreateAgentPermission(1, 1));
            Assert.AreEqual(0, AgencyRules.ResolveChildCreateAgentPermission(0, 0));
            Assert.AreEqual(0, AgencyRules.ResolveChildAgencyLimit(0));
            Assert.AreEqual(1, AgencyRules.ResolveChildAgencyLimit(2));
            Assert.AreEqual(0, AgencyRules.ResolveChildAgencyLimit(1));
            Assert.AreEqual(0, AgencyRules.ResolveChildAgencyLimit(null));
        }

        [TestMethod]
        public void InviteCodeStartsAtFourDigitsAndSkipsToFiveWhenFourDigitsFull()
        {
            string code = AgencyRules.GenerateInviteCode((min, max) =>
            {
                if (min == 1000 && max == 9999)
                {
                    List<string> used = new List<string>();
                    for (int i = 1000; i <= 9999; i++)
                        used.Add(i.ToString());
                    return used;
                }
                return new string[0];
            }, new System.Random(1));

            Assert.AreEqual(5, code.Length);
            Assert.IsTrue(int.Parse(code) >= 10000);
        }


        [TestMethod]
        public void InviteCodeCannotMatchAnyAgencyAccount()
        {
            string message;

            bool valid = AgencyRules.TryValidateInviteCode(
                "1688",
                "self",
                new[] { "10086", "1688" },
                new string[0],
                out message);

            Assert.IsFalse(valid);
            Assert.AreEqual("邀请码不能和代理账号相同，请更换邀请码", message);
        }


        [TestMethod]
        public void InviteCodeCannotMatchCurrentNewAgencyAccount()
        {
            string message;

            bool valid = AgencyRules.TryValidateInviteCode(
                "1688",
                "1688",
                new string[0],
                new string[0],
                out message);

            Assert.IsFalse(valid);
            Assert.AreEqual("邀请码不能和代理账号相同，请更换邀请码", message);
        }
        [TestMethod]
        public void InviteCodeUniquenessExcludesCurrentAgencyOnly()
        {
            string message;

            bool valid = AgencyRules.TryValidateInviteCode(
                "2583",
                "self",
                new string[0],
                new[] { new AgencyRules.InviteCodeOwner("self", "2583") },
                out message);

            Assert.IsTrue(valid, message);
        }

        [TestMethod]
        public void GeneratedInviteCodeSkipsAgencyAccounts()
        {
            string code = AgencyRules.GenerateInviteCode(
                (min, max) => new[] { "1000", "1001", "1002" },
                (min, max) => new[] { "1003", "1004" },
                new FixedRandom(0, 1, 2, 3, 4, 5));

            Assert.AreEqual("1005", code);
        }
        [TestMethod]
        public void ManageScopeOneAllowsSelfAndDirectChildrenOnly()
        {
            CollectionAssert.AreEquivalent(
                new[] { "agent1", "agent2", "self" },
                AgencyRules.GetManagedAgencyIds("self", 1, new[] { "agent1", "agent2" }, new[] { "agent1", "agent2", "agent3" }));
        }

        [TestMethod]
        public void ManageScopeTwoAllowsSelfAndWholeLine()
        {
            CollectionAssert.AreEquivalent(
                new[] { "agent1", "agent2", "agent3", "self" },
                AgencyRules.GetManagedAgencyIds("self", 2, new[] { "agent1" }, new[] { "agent1", "agent2", "agent3" }));
        }

        [TestMethod]
        public void DirectChildCountsExcludeDeeperLevels()
        {
            // 1688 → a147852 → a1231 → a1232，每个代理只统计自己的直属下级。
            List<AgencyRules.AgencyLink> links = new List<AgencyRules.AgencyLink>
            {
                new AgencyRules.AgencyLink("1688", "atmadmin"),
                new AgencyRules.AgencyLink("10086", "1688"),
                new AgencyRules.AgencyLink("a147852", "1688"),
                new AgencyRules.AgencyLink("a1231", "a147852"),
                new AgencyRules.AgencyLink("a1232", "a1231"),
            };

            Dictionary<string, int> counts = AgencyRules.BuildDirectChildCounts(links);

            // 1688 的直属只有 10086 与 a147852；a147852 的直属只有 a1231（a1232 不算）。
            Assert.AreEqual(2, counts["1688"]);
            Assert.AreEqual(1, counts["a147852"]);
            Assert.AreEqual(1, counts["a1231"]);
            Assert.IsFalse(counts.ContainsKey("a1232"));
        }

        [TestMethod]
        public void DirectChildCountsIgnoreRootAndSelfParentedRows()
        {
            List<AgencyRules.AgencyLink> links = new List<AgencyRules.AgencyLink>
            {
                new AgencyRules.AgencyLink("atmadmin", ""),
                new AgencyRules.AgencyLink("selfloop", "selfloop"),
                new AgencyRules.AgencyLink("child", "atmadmin"),
            };

            Dictionary<string, int> counts = AgencyRules.BuildDirectChildCounts(links);

            Assert.AreEqual(1, counts["atmadmin"]);
            // 自己指向自己的脏数据不应把自己算成下级
            Assert.IsFalse(counts.ContainsKey("selfloop"));
        }

        [TestMethod]
        public void BanRecordAccessFollowsOperatorTopAgentAndSuperAdmin()
        {
            // 总台：全部可见
            Assert.IsTrue(AgencyRules.CanAccessBanRecord(0, "atmadmin", "a1231", false));

            // 操作人本人：可见（不看层级，也不要求目标在本线内）
            Assert.IsTrue(AgencyRules.CanAccessBanRecord(3, "a1231", "a1231", false));
            Assert.IsTrue(AgencyRules.CanAccessBanRecord(4, "a1231", "A1231", false));

            // 特级代理（PRIV=1）：只看得见本线内的记录
            Assert.IsTrue(AgencyRules.CanAccessBanRecord(1, "1688", "a147852", true));
            Assert.IsFalse(AgencyRules.CanAccessBanRecord(1, "1688", "a147852", false));

            // 普通代理：不是自己操作的记录一律看不见——含操作人的直接上级、被封账号的直接上级、副管理/运营
            Assert.IsFalse(AgencyRules.CanAccessBanRecord(2, "a147852", "a1231", true));
            Assert.IsFalse(AgencyRules.CanAccessBanRecord(3, "a1231", "a147852", true));
            Assert.IsFalse(AgencyRules.CanAccessBanRecord(9, "fuguan", "a1231", true));
            Assert.IsFalse(AgencyRules.CanAccessBanRecord(10, "yunying", "a1231", true));

            // 查不到操作人（操作日志已过期）时：非特权一律看不见，特级仍限本线内
            Assert.IsFalse(AgencyRules.CanAccessBanRecord(2, "a147852", null, true));
            Assert.IsFalse(AgencyRules.CanAccessBanRecord(2, "a147852", "", true));
            Assert.IsTrue(AgencyRules.CanAccessBanRecord(1, "1688", null, true));
            Assert.IsFalse(AgencyRules.CanAccessBanRecord(1, "1688", "", false));
        }

        [TestMethod]
        public void PlayerControlVisibleOnlyToOwnerAgentTopAgentInLineAndSuperAdmin()
        {
            // 总台：全部可见
            Assert.IsTrue(AgencyRules.CanViewPlayerControl(0, "atmadmin", "a1231", false));

            // 所属代理本人（users.AGENCY 等于查看者账号）：可见，不看层级、大小写不敏感
            Assert.IsTrue(AgencyRules.CanViewPlayerControl(2, "a1231", "a1231", false));
            Assert.IsTrue(AgencyRules.CanViewPlayerControl(3, "a1231", "A1231", false));

            // 特级代理（PRIV=1）：只看得见本线内玩家的控制状态
            Assert.IsTrue(AgencyRules.CanViewPlayerControl(1, "1688", "a147852", true));
            Assert.IsFalse(AgencyRules.CanViewPlayerControl(1, "1688", "a147852", false));
            // 特级代理同时也是所属代理时不依赖线内判定
            Assert.IsTrue(AgencyRules.CanViewPlayerControl(1, "a147852", "a147852", false));

            // 普通代理：非所属一律看不见——含所属代理的直接上级、下级、兄弟代理、副管理/运营
            Assert.IsFalse(AgencyRules.CanViewPlayerControl(2, "a147852", "a1231", true));
            Assert.IsFalse(AgencyRules.CanViewPlayerControl(3, "a9999", "a1231", true));
            Assert.IsFalse(AgencyRules.CanViewPlayerControl(9, "fuguan", "a1231", true));
            Assert.IsFalse(AgencyRules.CanViewPlayerControl(10, "yunying", "a1231", true));

            // 玩家无所属代理（AGENCY 空）：只有总台可见
            Assert.IsFalse(AgencyRules.CanViewPlayerControl(2, "a147852", null, true));
            Assert.IsFalse(AgencyRules.CanViewPlayerControl(2, "a147852", "", true));
            Assert.IsFalse(AgencyRules.CanViewPlayerControl(1, "1688", "", true));
            Assert.IsTrue(AgencyRules.CanViewPlayerControl(0, "atmadmin", null, false));
        }

        private sealed class FixedRandom : System.Random
        {
            private readonly Queue<int> offsets;

            public FixedRandom(params int[] offsets)
            {
                this.offsets = new Queue<int>(offsets);
            }

            public override int Next(int minValue, int maxValue)
            {
                return minValue + offsets.Dequeue();
            }
        }
    }
}
