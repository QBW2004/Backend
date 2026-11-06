using System.Linq;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using YYT.BLL.EF;
using YYT.Entity;

namespace UnitTestProj
{
    [TestClass]
    public class CardRobotSettingsTest
    {
        [TestMethod]
        public void MultiSeatTotalsAreBalancedAndReserveHumanSeats()
        {
            var tables = new[] { new B_Robot.RobotTableCapacity { TableIndex = 2, MaxSeats = 6 },
                new B_Robot.RobotTableCapacity { TableIndex = 9, MaxSeats = 6 },
                new B_Robot.RobotTableCapacity { TableIndex = 20, MaxSeats = 2 } };
            var plan = B_Robot.PlanMultiSeatRobots(3, 2, tables, 7, 3);
            Assert.AreEqual(7, plan.Values.Sum());
            Assert.AreEqual(3, plan[2]);
            Assert.AreEqual(3, plan[9]);
            Assert.AreEqual(1, plan[20]);
            Assert.IsNull(B_Robot.PlanMultiSeatRobots(3, 2, tables, 8, 3));
            Assert.IsTrue(B_Robot.PlanMultiSeatRobots(3, 2, tables, 0, 3).Values.All(n => n == 0));
            Assert.AreEqual(5, B_Robot.GetMultiSeatRobotLimit(3, 2, 99));
            Assert.AreEqual(7, B_Robot.GetMultiSeatRobotLimit(10, 0, 8));
            Assert.AreEqual(3, B_Robot.GetMultiSeatRobotLimit(47, 0, 99));
        }

        [TestMethod]
        public void MultiSeatPlannerRejectsInvalidAndDuplicateCapacity()
        {
            var table = new B_Robot.RobotTableCapacity { TableIndex = 9, MaxSeats = 6 };
            var tables = new[] { table, table };
            Assert.IsNull(B_Robot.PlanMultiSeatRobots(3, 2, tables, 4, 3));
            foreach (int limit in new[] { -1, 0, 6, int.MaxValue })
                Assert.IsNull(B_Robot.PlanMultiSeatRobots(3, 2, tables, 1, limit));
            Assert.IsNull(B_Robot.PlanMultiSeatRobots(3, 2, tables, -1, 2));
            Assert.IsNull(B_Robot.PlanMultiSeatRobots(5, 1, tables, 1, 1));
            Assert.IsNull(B_Robot.PlanMultiSeatRobots(3, 2, new B_Robot.RobotTableCapacity[0], 1, 1));
        }

        [TestMethod]
        public void MachineRobotCountsSupportCardAndLabaButExcludeMahjongFishAndBet()
        {
            foreach (int id in new[] { 5, 15, 25, 37, 44 }) Assert.IsTrue(B_Robot.IsMachineRobotGame(id, 1));
            foreach (int id in new[] { 16, 40, 53 }) Assert.IsTrue(B_Robot.IsMachineRobotGame(id, 3));
            Assert.IsFalse(B_Robot.IsMachineRobotGame(54, 1));
            Assert.IsFalse(B_Robot.IsMachineRobotGame(3, 2));
            Assert.IsFalse(B_Robot.IsMachineRobotGame(2, 0));
        }

        [TestMethod]
        public void AdditionUsesRemainingMachineCapacityAndKeepsExistingRobots()
        {
            var robots = new[] { new M_Robot { TABLE_ID = 3, ROBOT_NO = 1 } };
            CollectionAssert.AreEqual(new[] { 0, 7 }, B_Robot.PlanCardRobotAddition(new[] { 0, 3, 7 }, robots, 2));
            Assert.IsNull(B_Robot.PlanCardRobotAddition(new[] { 0, 3, 7 }, robots, 3));
        }

        [TestMethod]
        public void AdditionRejectsInvalidCountsAndNoMachines()
        {
            var robots = new M_Robot[0];
            foreach (int count in new[] { -1, 0, int.MaxValue })
                Assert.IsNull(B_Robot.PlanCardRobotAddition(new[] { 0, 1 }, robots, count));
            Assert.IsNull(B_Robot.PlanCardRobotAddition(new int[0], robots, 1));
        }

        [TestMethod]
        public void LegacyCountsAndDisabledMachineQuotasStillCountTowardLimit()
        {
            var robots = new[] { new M_Robot { TABLE_ID = 0, ROBOT_NO = 2 }, new M_Robot { TABLE_ID = 9, ROBOT_NO = 1 } };
            Assert.IsNull(B_Robot.PlanCardRobotAddition(new[] { 0, 1, 2 }, robots, 1));
            Assert.AreEqual(1, B_Robot.PlanCardRobotAddition(new[] { 0, 1, 2, 3 }, robots, 1).Single());
        }

        [TestMethod]
        public void ZeroCountRowsCanBeReusedAndDuplicateTablesDoNotIncreaseCapacity()
        {
            var robots = new[] { new M_Robot { TABLE_ID = 0, ROBOT_NO = 0 } };
            CollectionAssert.AreEqual(new[] { 0, 3 }, B_Robot.PlanCardRobotAddition(new[] { 0, 0, 3 }, robots, 2));
            Assert.IsNull(B_Robot.PlanCardRobotAddition(new[] { 0, 0, 3 }, robots, 3));
        }
    }
}
