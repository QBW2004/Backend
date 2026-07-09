using YYT.Entity;

namespace YYT.BLL.EF
{
    public class ReChargeFactory
    {
        public M_Admin ReChargeUser { get; set; }
        public M_Recharge ReChargeTarget { get; set; }

        public ReChargeFactory(M_Admin rechargeUser, M_Recharge rechargeTarget)
        {
            this.ReChargeUser = rechargeUser;
            this.ReChargeTarget = rechargeTarget;
        }

        public ReChargeBase GetReCharge()
        {
            if (this.ReChargeUser.PRIV == 0)// 超级管理
                return new B_SuperAdminReCharge(this.ReChargeUser, this.ReChargeTarget);

            else if (this.ReChargeUser.PRIV == 1)// 总代理
                return new B_SuperAgencyReCharge(this.ReChargeUser, this.ReChargeTarget);

            else if (this.ReChargeUser.PRIV > 1 && this.ReChargeUser.PRIV < 9)// 一般代理
                return new B_GeneralAgencyReCharge(this.ReChargeUser, this.ReChargeTarget);

            else if (this.ReChargeUser.PRIV == 9)// 副管理
                return new B_ViceAdminReCharge(this.ReChargeUser, this.ReChargeTarget);

            else
                return new B_OtherReCharge(this.ReChargeUser, this.ReChargeTarget);// 其它类型账户
        }
    }
}
