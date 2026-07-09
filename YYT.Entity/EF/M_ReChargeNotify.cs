using Newtonsoft.Json;

namespace YYT.Entity
{
    public class M_ReChargeNotify
    {
        /// <summary>
        /// 免签支付系统中的订单流水号
        /// </summary>
        public string order_id { get; set; }
        /// <summary>
        /// 游戏管理系统的唯一订单号
        /// </summary>
        public string out_order_id { get; set; }
        /// <summary>
        /// 订单金额
        /// </summary>
        public float price { get; set; }
        /// <summary>
        /// 实际支付金额
        /// </summary>
        public float realprice { get; set; }
        /// <summary>
        /// 支付的方式，wechat:微信 alipay:支付宝
        /// </summary>
        public string type { get; set; }
        /// <summary>
        /// 支付时间，时间戳
        /// </summary>
        public int paytime { get; set; }
        /// <summary>
        /// 原样返回你请求的extend信息
        /// </summary>
        public string extend { get; set; }
        /// <summary>
        /// 签名,构造格式见下方的签名方法
        /// <para> 签名方法 : md5(md5(order_id + out_order_id + price + realprice + type + paytime + extend)+secretkey) </para>
        /// </summary>
        public string sign { get; set; }

        public override string ToString()
        {
            return JsonConvert.SerializeObject(this);
        }
    }
}
