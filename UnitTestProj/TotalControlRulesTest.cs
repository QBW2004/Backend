using System.Collections.Generic;
using System.Linq;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using YYT.BLL.EF;
using YYT.Entity;

namespace UnitTestProj
{
    [TestClass]
    public class TotalControlRulesTest
    {
        private static M_UserControlStatus_DTO Row(string userId, int id, int mode)
        {
            return new M_UserControlStatus_DTO { UserID = userId, ID = id, ControlMode = mode };
        }

        private static List<int> PickedModes(List<M_UserControlStatus_DTO> rows)
        {
            return TotalControlRules.PickDisplayControls(rows).Select(r => r.ControlMode).ToList();
        }

        [TestMethod]
        public void KillAndReleaseReplaceEachOtherCardOnlyReplacesCard()
        {
            // 吃分/放水互斥：后下的覆盖先下的，两个方向都把对方的执行中记录置为过期
            CollectionAssert.AreEquivalent(new[] { 4, 5 }, TotalControlRules.ModesReplacedBy(4));
            CollectionAssert.AreEquivalent(new[] { 4, 5 }, TotalControlRules.ModesReplacedBy(5));
            // 控牌只替换旧控牌，与吃分/放水共存
            CollectionAssert.AreEquivalent(new[] { 6 }, TotalControlRules.ModesReplacedBy(6));
        }

        [TestMethod]
        public void CardControlHidesKillWhenBothActive()
        {
            List<M_UserControlStatus_DTO> picked = TotalControlRules.PickDisplayControls(new[]
            {
                Row("p1", 10, 4),
                Row("p1", 11, 6),
            });

            Assert.AreEqual(1, picked.Count);
            Assert.AreEqual(6, picked[0].ControlMode);
        }

        [TestMethod]
        public void CardControlWinsEvenWithSmallerId()
        {
            // 控牌优先与 ID 大小无关：控牌 ID 小于吃分也仍只显示控牌
            List<M_UserControlStatus_DTO> picked = TotalControlRules.PickDisplayControls(new[]
            {
                Row("p1", 12, 4),
                Row("p1", 11, 6),
            });

            Assert.AreEqual(1, picked.Count);
            Assert.AreEqual(6, picked[0].ControlMode);
        }

        [TestMethod]
        public void CardControlHidesReleaseWhenBothActive()
        {
            List<M_UserControlStatus_DTO> picked = TotalControlRules.PickDisplayControls(new[]
            {
                Row("p1", 10, 5),
                Row("p1", 11, 6),
            });

            Assert.AreEqual(1, picked.Count);
            Assert.AreEqual(6, picked[0].ControlMode);
        }

        [TestMethod]
        public void OnlyKillShowsKill()
        {
            List<M_UserControlStatus_DTO> picked = TotalControlRules.PickDisplayControls(new[]
            {
                Row("p1", 10, 4),
            });

            Assert.AreEqual(1, picked.Count);
            Assert.AreEqual(4, picked[0].ControlMode);
        }

        [TestMethod]
        public void DirtyKillAndReleasePairShowsLatestRelease()
        {
            // 历史脏数据：同一玩家吃分/放水两条同时执行中，显示 ID 最大的（后下的）那条
            List<M_UserControlStatus_DTO> picked = TotalControlRules.PickDisplayControls(new[]
            {
                Row("p1", 10, 4),
                Row("p1", 12, 5),
            });

            Assert.AreEqual(1, picked.Count);
            Assert.AreEqual(5, picked[0].ControlMode);
            Assert.AreEqual(12, picked[0].ID);
        }

        [TestMethod]
        public void MultiplePlayersEachPickTheirOwnRow()
        {
            List<M_UserControlStatus_DTO> picked = TotalControlRules.PickDisplayControls(new[]
            {
                Row("p1", 10, 4),
                Row("p1", 11, 6),
                Row("p2", 20, 5),
                Row("p3", 30, 4),
                Row("p3", 31, 5),
            });

            Assert.AreEqual(3, picked.Count);
            Assert.AreEqual(6, picked.Single(r => r.UserID == "p1").ControlMode);
            Assert.AreEqual(5, picked.Single(r => r.UserID == "p2").ControlMode);
            Assert.AreEqual(31, picked.Single(r => r.UserID == "p3").ID);
        }

        [TestMethod]
        public void NullAndEmptyInputsReturnEmptyWithoutThrowing()
        {
            Assert.AreEqual(0, TotalControlRules.PickDisplayControls(null).Count);
            Assert.AreEqual(0, TotalControlRules.PickDisplayControls(new List<M_UserControlStatus_DTO>()).Count);

            // 列表里混 null 元素：跳过 null，其余正常收敛
            List<M_UserControlStatus_DTO> picked = TotalControlRules.PickDisplayControls(new List<M_UserControlStatus_DTO>
            {
                null,
                Row("p1", 10, 4),
            });
            Assert.AreEqual(1, picked.Count);
            Assert.AreEqual(4, picked[0].ControlMode);
        }
    }
}
