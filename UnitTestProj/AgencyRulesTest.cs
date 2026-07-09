using System.Collections.Generic;
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
