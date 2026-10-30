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
