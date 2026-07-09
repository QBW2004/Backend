using Newtonsoft.Json;
using System;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace YYT.Entity
{
    /// <summary>
    /// 充值记录
    /// </summary>
    [Table("ReChargeRecords")]
    public class M_ReChargeRecords
    {
        /// <summary>
        /// 订单编号
        /// </summary>
        [Key]
        public string OrderNo { get; set; }
        /// <summary>
        /// 支付类型
        /// <para>1 微信</para>
        /// <para>2 支付宝</para>
        /// <para>20 后台充值</para>
        /// <para>21 后台兑换</para>
        /// <para>22 后台赠送</para>
        /// <para>23 后台扣币</para>
        /// <para>30 前端充值</para>
        /// <para>31 前端提现</para>
        /// </summary>
        public int RechargeType { get; set; }
        /// <summary>
        /// 充值金额
        /// </summary>
        public long? Coin { get; set; }
        /// <summary>
        /// 充值前金币
        /// </summary>
        public long? BEF_COINS { get; set; }
        /// <summary>
        /// 充值后金币
        /// </summary>
        public long? AFT_COINS { get; set; }
        /// <summary>
        /// 游戏账号ID
        /// </summary>
        public string GameID { get; set; }
        /// <summary>
        /// 所属代理
        /// </summary>
        public string Agency { get; set; }
        /// <summary>
        /// 支付宝/微信号
        /// </summary>
        public string PayNo { get; set; }
        /// <summary>
        /// 处理状态
        /// <para>0 未处理</para>
        /// <para>1 已处理</para>
        /// <para>2 拒绝处理</para>
        /// <para>3 拒绝处理并扣币</para>
        /// </summary>
        public int Processed { get; set; }

        /// <summary>
        /// 充值时间
        /// </summary>
        public DateTime CreateTime { get; set; }

     //   public M_ReportsDao dap { get; set; }
        /// <summary>
        /// 充值时间
        /// </summary>
        [NotMapped]
        public string CreateTimeStr
        {
            get
            {
                if (this.Processed == 4)
                {
                    return "";
                }
                else
                {
                    return this.CreateTime.ToString("yyyy-MM-dd HH:mm:ss");
                }

            }
            set
            {
                CreateTimeStr = value;
            }
        }


        public override string ToString()
        {
            return JsonConvert.SerializeObject(this);
        }

    }
    public class M_ReChargeRecordsDao
    {
        /// <summary>
        /// 订单编号
        /// </summary>
        [Key]
        public string OrderNo { get; set; }
        /// <summary>
        /// 支付类型
        /// <para>1 微信</para>
        /// <para>2 支付宝</para>
        /// <para>20 后台充值</para>
        /// <para>21 后台兑换</para>
        /// </summary>
        public int RechargeType { get; set; }
        /// <summary>
        /// 充值金额
        /// </summary>
        public long? Coin { get; set; }
        /// <summary>
        /// 充值前金币
        /// </summary>
        public long? BEF_COINS { get; set; }
        /// <summary>
        /// 充值后金币
        /// </summary>
        public long? AFT_COINS { get; set; }
        /// <summary>
        /// 游戏账号ID
        /// </summary>
        public string GameID { get; set; }
        /// <summary>
        /// 所属代理
        /// </summary>
        public string Agency { get; set; }
        /// <summary>
        /// 支付宝/微信号
        /// </summary>
        public string PayNo { get; set; }
        /// <summary>
        /// 处理状态
        /// <para>0 未处理</para>
        /// <para>1 已处理</para>
        /// </summary>
        public int Processed { get; set; }
        /// <summary>
        /// 充值时间
        /// </summary>
        public DateTime CreateTime { get; set; }
        public string StartTime { get; set; }
        public string EndTime { get; set; }
        /// <summary>
        /// 充值时间
        /// </summary>
        [NotMapped]
        public string CreateTimeStr { 
            get 
            {
                if (this.Processed == 2)
                {
                    return "";
                }
                else
                {
                    return this.CreateTime.ToString("yyyy-MM-dd HH:mm:ss");
                }
               
            } 
            set 
            { 
                CreateTimeStr = value; 
            } 
        }


        public override string ToString()
        {
            return JsonConvert.SerializeObject(this);
        }

    }
}
