using Game.Utils;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Web;
using YYT.Common;

namespace YYT.Web
{
    public  class DJDPay
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
        public class DJDH5Request
        {
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
            /// 必填	1=wx，2=zfb，3=银行卡
            /// </summary>
            public int type { get; set; }

            /// <summary>
            ///必填	1=wx/zfb 收款码, 2=wx/zfb 账号（wx为注册手机号），3=银行卡
            /// </summary>
            public int type2 { get; set; }

            /// <summary>
            /// 必填 附加参数
            /// </summary>
            public string attach { get; set; }
            /// <summary>
            /// 选填 调试用，0=不显示参数，1=显示传来参数
            /// </summary>
            public string debug { get; set; }

            public string bank_account { get; set; }
            public string bank_cardNum { get; set; }
            public string bank_id { get; set; }

            public DJDH5Request(string orderId, string orderAmount, string gameId, string bank_account1, string bank_cardNum1, string bank_id1 )
            {
                orderid = orderId;
                money = orderAmount.ToString();
                attach = gameId.ToString();
                type = 3;
                type2 = 3;
                bank_account = bank_account1;
                bank_cardNum = bank_cardNum1;
                bank_id = bank_id1;
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
                return Config.DpayUrl + "?" + UrlParams();
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

        public class DJDH5Notify
        {
            //            code Int(2)  1=成功，2=失败
            //type    Int(2)  1=wx，2=zfb，3=银行卡
            //type2   Int(2)  1=wx/zfb 收款码, 2=wx/zfb 账号，3=银行卡
            //shop_id char (8)	商户 shop_id
            //orderid char (50)	在你数据库里产生的订单号（你的下发订单号）
            //orderid2 char (50)	订单编号（平台中的订单号）
            //money float (9,2)	代付金额：0.01~5000（元）
            //attach char (50)	附加参数
            //poundage    float (5,2)	手续费
            // token   char (32)	查询令牌（用于查询代付订单状态(结果）
            //sign    char(32)    签名=md5(shop_id + orderid + orderid2 + money + shop_key )
            public int code { get; set; }

            /// <summary>
            /// 必填	1=wx，2=zfb，3=银行卡
            /// </summary>
            public int type { get; set; }

            /// <summary>
            ///必填	1=wx/zfb 收款码, 2=wx/zfb 账号（wx为注册手机号），3=银行卡
            /// </summary>
            public int type2 { get; set; }


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
            /// 手续费
            /// </summary>
            public string poundage { get; set; }
           
            /// <summary>
            /// 查询令牌（用于查询支付订单状态”结果”）
            /// </summary>
            public string token { get; set; }
            /// <summary>
            ///md5(shop_id + orderid + orderid2 + money + shop_key )
            /// </summary>
            public string sign { get; set; }
            
            public DJDH5Notify(HttpRequest request)
            {
                Type t = GetType();
                PropertyInfo[] PropertyList = t.GetProperties();
                foreach (PropertyInfo item in PropertyList)
                {
                    foreach (string key in request.Params.Keys)
                    {
                        if (item.Name == key)
                        {
                            item.SetValue(this, request.Params[key], null);
                        }
                    }
                }
            }
            public bool VerifySign()
            {
                string sign1 = Config.shop_id + orderid + orderid2 +money+ Config.shop_key;
                return sign.ToLower() == Utility.MD5(sign1).ToLower();

            }

        }
    }
}