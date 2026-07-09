using Game.Utils;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Web;
using YYT.Common;

namespace YYT.Web
{
    public  class JDPay
    {
        public  class Config
        {
            public static string payUrl = ConfigHelper.Get("X2payUrl");
            public static string DpayUrl = ConfigHelper.Get("X2DpayUrl");
            public static string shop_id = ConfigHelper.Get("X2shop_id");//商户编号
            public static string shop_key = ConfigHelper.Get("X2shop_key");//商户密钥
            public static string notify_url = ConfigHelper.Get("X2notify_url"); //回调uRL
        }
        /// <summary>
        /// 威富通支付请求类
        /// </summary>
        public class JDH5Request
        {
            //            type int (2)	选填	0=不限定,1=wx,2=zfb，3＝银联
            //  type2   int (2)	选填	0=不限定,1=wx/zfb 收款码, 2=zfb 转 zfb 账号,3=zfb 转银行卡, 4=银联收款码(wx/zfb),5=wx 转银行卡,7=zfb好友转账，8=银行卡
            //   shop_id char (8)	必填 商户 shop_id
            //   orderid char (50)	必填 在你数据库里产生的订单号
            //money float (9,2)	选填 支付金额：0.01~5000（元）
            //attach char (50)	选填 附加参数
            //sign char (32)	必填 签名 = md5(shop_id + orderid + money + shop_key)
            //debug int (1)	选填 调试用，0=不显示参数，1=显示传来参数
            /// <summary>
            /// 商户 shop_id
            /// </summary>
            public string shop_id => Config.shop_id;
            /// <summary>
            /// 签名 
            /// </summary>
            public string sign => Sign();

            /// <summary>
            ///必填 在你数据库里产生的订单号
            /// </summary>
            public string orderid { get; set; }

            /// <summary>
            /// 选填 支付金额：0.01~5000（元）
            /// </summary>
            public string money { get; set; }

            /// <summary>
            /// 选填	0=不限定,1=wx,2=zfb，3＝银联
            /// </summary>
            public int type = 0;

            /// <summary>
            ///选填	0=不限定,1=wx/zfb 收款码, 2=zfb 转 zfb 账号,3=zfb 转银行卡, 4=银联收款码(wx/zfb),5=wx 转银行卡,7=zfb好友转账，8=银行卡
            /// </summary>
            public int type2 = 0;
           
            /// <summary>
            /// 选填 附加参数
            /// </summary>
            public string attach { get; set; }
            /// <summary>
            /// 选填 调试用，0=不显示参数，1=显示传来参数
            /// </summary>
            public string debug { get; set; }

           
            public JDH5Request(string orderId, string orderAmount, string gameId )
            {
                orderid = orderId;
                money = orderAmount.ToString();
                attach = gameId.ToString();
            }

            public string Sign()
            {
                string sign1 = shop_id+orderid+money+ Config.shop_key;
                return Utility.MD5(sign1).ToLower();
            }

            /// <summary>
            /// 转化成支付提交地址
            /// </summary>
            /// <returns></returns>
            public string ToUrl()
            {
                return Config.payUrl + "?" + UrlParams();
            }

            /// <summary>
            /// Url拼接方法
            /// </summary>
            /// <returns></returns>
            public string UrlParams()
            {
                Type t = GetType();
                PropertyInfo[] PropertyList = t.GetProperties();
                string result = "";
                foreach (PropertyInfo item in PropertyList)
                {
                    string name = item.Name;
                    object value = item.GetValue(this, null);
                    if (value != null)
                    {
                        result += $"{name}={value}&";
                    }
                }
                return result.Substring(0, result.Length - 1);
            }

        }

        public class JDH5Notify
        {
            public string pay_type { get; set; }

            /// <summary>
            ///  调起类型（入口类型），1=扫码进入，2=浏览器 h5，3=api 扫码(浏览器 h5 临时码)
            /// </summary>
            public string entrance_way { get; set; }

            /// <summary>
            ///  商户 shop_id
            /// </summary>
            public string shop_id { get; set; }
            /// <summary>
            /// 订单编号（你传过来的订单号）（订单号为空或用户扫商户聚合码支付，回复：0）
            /// </summary>
            public string orderid { get; set; }

            /// <summary>
            /// 订单编号（平台中的订单号）
            /// </summary>
            public string orderid2 { get; set; }
            /// <summary>
            /// 金额：0.01~5000（元）
            /// </summary>
            public string money { get; set; }
            /// <summary>
            /// 附加参数
            /// </summary>
            public string attach { get; set; }

            /// <summary>
            /// 用户充值账号（一般扫码用户输入）
            /// </summary>
            public string cz_zh { get; set; }
            /// <summary>
            /// 客户 IP
            /// </summary>
            public string ip { get; set; }
            /// <summary>
            /// 查询令牌（用于查询支付订单状态”结果”）
            /// </summary>
            public string token { get; set; }
            /// <summary>
            /// 签名=md5(shop_id + orderid + orderid2 + money + shop_key )
            /// </summary>
            public string sign { get; set; }

           
            public bool VerifySign()
            {
                string sign1 = Utility.MD5(Config.shop_id + orderid + orderid2 + money + Config.shop_key).ToLower();

                return sign.ToLower() == sign1;

            }

        }
    }
}