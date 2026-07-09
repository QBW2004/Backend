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
    public enum ERechargeType
    {
        Recharge = 0,
        Exchange
    }
    public class ReChargeCommon
    {
        public M_Admin SrcUsr { get; private set; }
        public M_Recharge DstUsr { get; private set; }
        public EAdminType AdminType { get; private set; }


        public ReChargeCommon(EAdminType eAdminType)
        {
            this.AdminType = eAdminType;
        }

        /// <summary>
        /// 设置充值账户
        /// </summary>
        /// <param name="priv">代理层级</param>
        /// <param name="account">账号</param>
        public void SetChargeSrcUsr(int priv, string account)
        {
            this.SrcUsr = new M_Admin { ID = account, PRIV = priv };
        }
        /// <summary>
        /// 设置被充、兑换账户
        /// </summary>
        /// <param name="account">账号</param>
        /// <param name="coins">充值、兑换金币数量</param>
        /// <param name="rechargeType">充值类型</param>
        public void SetRechargeDstUsr(string account, int coins, ERechargeType rechargeType)
        {
            this.DstUsr = new M_Recharge { ID = account, Coin = coins, RechargeType = (int)rechargeType, AdminType = this.AdminType };
        }

        public dynamic GetDstUsr()
        {
            if (this.AdminType == EAdminType.None)
                return new B_Users().GetSingle(new M_Users { ID = this.DstUsr.ID });
            else
                return new B_Admin().GetSingle(new M_Admin { ID = this.DstUsr.ID });
        }

        /// <summary>
        /// 验证结果
        /// </summary>
        public void Valid(Action<long?, long?, long?, Msg> action = null)
        {
            // 充前
            dynamic prevModel = GetDstUsr();

            // 充值、兑换
            B_ReChargeBase bll = new B_ReChargeBase(this.SrcUsr, this.DstUsr);

            Msg msg = null;
            if (this.AdminType == EAdminType.None)
                msg = bll.PlayerReCharge();
            else
                msg = bll.AgencyReCharge();

            // 充后
            dynamic afterModel = GetDstUsr();

            long? coins = this.DstUsr.RechargeType == 0 ? prevModel.COINS + this.DstUsr.Coin : prevModel.COINS - this.DstUsr.Coin;
            if (action == null)
                // 结果校验
                Assert.AreEqual(coins, afterModel.COINS);
            else
                action(prevModel.COINS, afterModel.COINS, coins,  msg);
        }
    }
}
