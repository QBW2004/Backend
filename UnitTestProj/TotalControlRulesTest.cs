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
        [TestMethod]
        public void MahjongControlRejectsUnknownAwardBeforeDatabaseWrite()
        {
            var loginUser = new M_LoginUser { UserPriv = 0, Accounts = "contract-test" };
            var control = new B_UserControl();
            foreach (int value in new[] { -1, 0, 7, 10, 99 })
            {
                var result = control.ApplyTotalControl(loginUser, "test-player", 6, 0, 0, 19, value, 1, 5, true);
                Assert.AreEqual(0, result.code);
                Assert.AreEqual("无效的麻将胡了送奖牌型！", result.content);
            }
            var platformGameId = control.ApplyTotalControl(loginUser, "test-player", 6, 0, 0, 54, 1, 1, 5, true);
            Assert.AreEqual("无效的控牌类型！", platformGameId.content);
            var reservedAction = control.ApplyTotalControl(loginUser, "test-player", 6, 0, 0, 18, 1, 1, 5, true);
            Assert.AreEqual("无效的控牌类型！", reservedAction.content);
        }

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
        public void TotalControlCapabilityMatchesOpenGameProtocols()
        {
            int[] openGames = { 2, 3, 5, 10, 13, 15, 16, 25, 37, 40, 44, 53, 54, 55 };
            int[] killGames = { 2, 3, 5, 10, 13, 15, 16, 25, 37, 40, 44, 53, 54, 55 };
            int[] releaseGames = { 2, 3, 5, 10, 13, 15, 16, 25, 37, 40, 44, 53, 54, 55 };

            foreach (int gameId in openGames)
            {
                Assert.AreEqual(killGames.Contains(gameId),
                    TotalControlRules.IsModeSupportedForGame((int)EControlMode.TotalKill, gameId),
                    "总吃分能力矩阵错误: " + gameId);
                Assert.AreEqual(releaseGames.Contains(gameId),
                    TotalControlRules.IsModeSupportedForGame((int)EControlMode.TotalRelease, gameId),
                    "总放水能力矩阵错误: " + gameId);
            }
            Assert.IsFalse(TotalControlRules.IsModeSupportedForGame((int)EControlMode.TotalRelease, 999));
            Assert.AreEqual("当前游戏暂不支持总放水！",
                TotalControlRules.UnsupportedModeMessage((int)EControlMode.TotalRelease, 999));
        }

        [TestMethod]
        public void CenterUcErrorUsesRawProtocolKeyWhileUcNotLoggedInRemainsPending()
        {
            var rejected = new Msg(0, "服务器内部错误") { datas = "UCER" };
            var pending = new Msg(0, "玩家下次登陆后生效") { datas = "UCNL" };

            Assert.IsTrue(TotalControlRules.IsServerCapabilityRejected(rejected));
            Assert.IsFalse(TotalControlRules.IsServerCapabilityRejected(pending));
            Assert.IsFalse(TotalControlRules.IsServerCapabilityRejected(new Msg(0, "管道失败")));
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
