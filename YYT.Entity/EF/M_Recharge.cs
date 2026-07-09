using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace YYT.Entity
{
    /// <summary>
    /// 充值数据实体【后台用】
    /// </summary>
    public class M_Recharge
    {
        /// <summary>
        /// 充值对象类型
        /// </summary>
        public EAdminType AdminType { get; set; }
        /// <summary>
        /// 充值类型
        /// <para>20 充值</para>
        /// <para>21 兑换</para>
        /// <para>22 赠送</para>
        /// <para>23 扣币</para>
        /// <para>24 保险柜存入</para>
        /// <para>25 保险柜取出</para>
        /// <para>26 兑换后 人工拒绝</para>
        /// </summary>
        public int RechargeType { get; set; }
        /// <summary>
        /// 充值对象ID
        /// </summary>
        public string ID { get; set; }
        /// <summary>
        /// 充值时使用的ID类型（默认使用账号充值）
        /// <para>0 用户账号</para>
        /// <para>1 用户ID（平台唯一标识ID）</para>
        /// </summary>
        public EIDType IDType { get; set; }
        /// <summary>
        /// 充值金币数
        /// </summary>
        public long? Coin { get; set; }
        /// <summary>
        /// 职务
        /// </summary>
        public string Title
        {
            get
            {
                return AdminTypeTranslater.TitleTranlate(this.AdminType);
            }
        }
        public override string ToString()
        {
            return JsonConvert.SerializeObject(this);
        }
    }

    /// <summary>
    /// 充值信息
    /// </summary>
    public class M_RechargeInfo
    {
        /// <summary>
        /// 订单编号
        /// </summary>
        public int OrderNo { get; set; }
        /// <summary>
        /// 充值类型
        /// <para>1 支付宝</para>
        /// <para>2 微信</para>
        /// </summary>
        public int RechargeType { get; set; }
        /// <summary>
        /// 充值对象ID
        /// </summary>
        public string ID { get; set; }
        /// <summary>
        /// 充值金额
        /// </summary>
        public long? Coin { get; set; }

        public override string ToString()
        {
            return JsonConvert.SerializeObject(this);
        }
    }
}
