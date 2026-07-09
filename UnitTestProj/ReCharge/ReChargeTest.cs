using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using YYT.BLL.EF;
using YYT.Entity;

namespace UnitTestProj.ReCharge
{
    /// <summary>
    /// 超级充值、兑换
    /// </summary>
    [TestClass]
    public class SuperAdminReChargeTest
    {
        /// <summary>
        /// 【充值】  超级管理 ==》 总代
        /// </summary>
        [TestMethod]
        public void Recharge_Test_1()
        {
            // 充值数量
            int coins = 10;

            ReChargeCommon reCharge = new ReChargeCommon(EAdminType.One);
            reCharge.SetChargeSrcUsr(0, "admin");
            reCharge.SetRechargeDstUsr("aaaaaa", coins, ERechargeType.Recharge);
            reCharge.Valid();
        }

        /// <summary>
        /// 【兑换】  超级管理 ==》 总代
        /// </summary>
        [TestMethod]
        public void Exchange_Test_2()
        {
            // 兑币数量
            int coins = 5;

            ReChargeCommon reCharge = new ReChargeCommon(EAdminType.One);
            reCharge.SetChargeSrcUsr(0, "admin");
            reCharge.SetRechargeDstUsr("aaaaaa", coins, ERechargeType.Exchange);
            reCharge.Valid();
        }

        /// <summary>
        /// 【充值】  超级管理 ==》 二级代理
        /// </summary>
        [TestMethod]
        public void Recharge_Test_3()
        {
            // 充值数量
            int coins = 10;

            ReChargeCommon reCharge = new ReChargeCommon(EAdminType.General);
            reCharge.SetChargeSrcUsr(0, "admin");
            reCharge.SetRechargeDstUsr("bbbbbb", coins, ERechargeType.Recharge);
            reCharge.Valid();
        }
        /// <summary>
        /// 【兑换】  超级管理 ==》 二级代理
        /// </summary>
        [TestMethod]
        public void Recharge_Test_4()
        {
            // 充值数量
            int coins = 5;

            ReChargeCommon reCharge = new ReChargeCommon(EAdminType.General);
            reCharge.SetChargeSrcUsr(0, "admin");
            reCharge.SetRechargeDstUsr("bbbbbb", coins, ERechargeType.Exchange);
            reCharge.Valid();
        }

        /// <summary>
        /// 【充值】  超级管理 ==》 玩家
        /// </summary>
        [TestMethod]
        public void Recharge_Test_5()
        {
            // 充值数量
            int coins = 10;

            ReChargeCommon reCharge = new ReChargeCommon(EAdminType.None);
            reCharge.SetChargeSrcUsr(0, "admin");
            reCharge.SetRechargeDstUsr("123456", coins, ERechargeType.Recharge);
            reCharge.Valid();
        }

        /// <summary>
        /// 【兑换】  超级管理 ==》 玩家
        /// </summary>
        [TestMethod]
        public void Recharge_Test_6()
        {
            // 充值数量
            int coins = 5;

            ReChargeCommon reCharge = new ReChargeCommon(EAdminType.None);
            reCharge.SetChargeSrcUsr(0, "admin");
            reCharge.SetRechargeDstUsr("123456", coins, ERechargeType.Exchange);
            reCharge.Valid();
        }
    }

    /// <summary>
    /// 代理充值、兑换
    /// </summary>
    [TestClass]
    public class GeneralAdminReChargeTest
    {
        /// <summary>
        /// 【充值】  总代 ==》 总代
        /// </summary>
        [TestMethod]
        public void Recharge_Test_1()
        {
            // 充值数量
            int coins = 10;

            ReChargeCommon reCharge = new ReChargeCommon(EAdminType.One);
            reCharge.SetChargeSrcUsr(1, "aaaaaa");
            reCharge.SetRechargeDstUsr("aaaaaa", coins, ERechargeType.Recharge);
            reCharge.Valid((prevCoins, afterCoins, calcCoins, msg) =>
            {
                Assert.AreEqual(prevCoins, afterCoins);
                Assert.AreEqual(msg.content.Contains("不在你的权限范围内"), true);
            });
        }

        /// <summary>
        /// 【兑换】  总代 ==》 总代
        /// </summary>
        [TestMethod]
        public void Exchange_Test_2()
        {
            // 兑币数量
            int coins = 5;

            ReChargeCommon reCharge = new ReChargeCommon(EAdminType.One);
            reCharge.SetChargeSrcUsr(1, "aaaaaa");
            reCharge.SetRechargeDstUsr("aaaaaa", coins, ERechargeType.Exchange);
            reCharge.Valid((prevCoins, afterCoins, calcCoins, msg) =>
            {
                Assert.AreEqual(prevCoins, afterCoins);
                Assert.AreEqual(msg.content.Contains("不在你的权限范围内"), true);
            });
        }

        /// <summary>
        /// 【充值】  总代 ==》 二级代理
        /// </summary>
        [TestMethod]
        public void Recharge_Test_3()
        {
            // 充值数量
            int coins = 10;

            ReChargeCommon reCharge = new ReChargeCommon(EAdminType.General);
            reCharge.SetChargeSrcUsr(1, "aaaaaa");
            reCharge.SetRechargeDstUsr("bbbbbb", coins, ERechargeType.Recharge);
            reCharge.Valid();
        }
        /// <summary>
        /// 【兑换】  总代 ==》 二级代理
        /// </summary>
        [TestMethod]
        public void Recharge_Test_4()
        {
            // 充值数量
            int coins = 5;

            ReChargeCommon reCharge = new ReChargeCommon(EAdminType.General);
            reCharge.SetChargeSrcUsr(1, "aaaaaa");
            reCharge.SetRechargeDstUsr("bbbbbb", coins, ERechargeType.Exchange);
            reCharge.Valid();
        }




        /// <summary>
        /// 【充值】  总代 ==》 三级代理
        /// </summary>
        [TestMethod]
        public void Recharge_Test_5()
        {
            // 充值数量
            int coins = 10;

            ReChargeCommon reCharge = new ReChargeCommon(EAdminType.General);
            reCharge.SetChargeSrcUsr(1, "aaaaaa");
            reCharge.SetRechargeDstUsr("cccccc", coins, ERechargeType.Recharge);
            reCharge.Valid((prevCoins, afterCoins, calcCoins, msg) =>
            {
                Assert.AreEqual(prevCoins, afterCoins);
                Assert.AreEqual(msg.content.Contains("不在你的权限范围内"), true);
            });
        }
        /// <summary>
        /// 【兑换】  总代 ==》 三级代理
        /// </summary>
        [TestMethod]
        public void Recharge_Test_6()
        {
            // 充值数量
            int coins = 5;

            ReChargeCommon reCharge = new ReChargeCommon(EAdminType.General);
            reCharge.SetChargeSrcUsr(1, "aaaaaa");
            reCharge.SetRechargeDstUsr("cccccc", coins, ERechargeType.Exchange);
            reCharge.Valid((prevCoins, afterCoins, calcCoins, msg) =>
            {
                Assert.AreEqual(prevCoins, afterCoins);
                Assert.AreEqual(msg.content.Contains("不在你的权限范围内"), true);
            });
        }




        /// <summary>
        /// 【充值】  超级管理 ==》 玩家
        /// </summary>
        [TestMethod]
        public void Recharge_Test_7()
        {
            // 充值数量
            int coins = 10;

            ReChargeCommon reCharge = new ReChargeCommon(EAdminType.None);
            reCharge.SetChargeSrcUsr(1, "aaaaaa");
            reCharge.SetRechargeDstUsr("123456", coins, ERechargeType.Recharge);
            reCharge.Valid();
        }

        /// <summary>
        /// 【兑换】  超级管理 ==》 玩家
        /// </summary>
        [TestMethod]
        public void Recharge_Test_8()
        {
            // 充值数量
            int coins = 5;

            ReChargeCommon reCharge = new ReChargeCommon(EAdminType.None);
            reCharge.SetChargeSrcUsr(1, "aaaaaa");
            reCharge.SetRechargeDstUsr("123456", coins, ERechargeType.Exchange);
            reCharge.Valid();
        }
    }

}
