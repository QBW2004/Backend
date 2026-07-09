using Game.Utils;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Web;
using YYT.Common;
namespace YYT.Web.Models
{
    public class WFTPay
    {

        public class Config
        {
            public static string payUrl = ConfigHelper.Get("wftpayUrl");
            public static string pay_source = ConfigHelper.Get("wftpay_source"); //支付方式
            public static string shop_id = ConfigHelper.Get("wftshop_id");//商户编号
            public static string shop_key = ConfigHelper.Get("wftshop_key");//商户密钥
            public static string notify_url = ConfigHelper.Get("wftnotify_url"); //回调uRL
        }
        /// <summary>
        /// 威富通支付请求类
        /// </summary>
        public class WFTRequest
        {
            /// <summary>
            /// 商户在竣付通平台的应用ID
            /// </summary>
            public string shop_id => Config.shop_id;
            /// <summary>
            /// 支付方式
            /// </summary>
            public string pay_source=>Config.pay_source;

            /// <summary>
            /// 订单金额。下单金额不含小数点将随机减少2毛内金额请做好回调处理
            /// </summary>
            public string amount { get; set; }
            /// <summary>
            /// 支付结果通知url
            /// </summary>
            public string notify_url => Config.notify_url;
            /// <summary>
            /// 支付用户的ip地址
            /// </summary>
            public string user_ip { get; set; }
            /// <summary>
            /// 商户单号
            /// </summary>
            public string order_no { get; set; }
            /// <summary>
            /// 符加数据
            /// </summary>
            public string attach { get; set; }
            /// <summary>
            /// 商品名称
            /// </summary>
            public string order_body { get; set; }
            /// <summary>
            /// 前商跳转URL
            /// </summary>
            public string frontUrl { get; set; }
            /// <summary>
            /// 终端代码
            /// </summary>
            public string return_type { get; set; }
        
            /// <summary>
            /// 签名 
            /// </summary>
            public string sign => Sign();

            //  shop_id=100523&pay_source=alipay&amount=1.00&notify_url=JDPay.aspx&user_ip=0_0_0_0&order_no=wft20200929182651408541647&order_body=100102&frontUrl=JDPay.aspx&return_type=IOS&sign=53205420500FCA9347387211F68F302D

            public WFTRequest(string orderId, string orderAmount, string gameId, string user_Ip,string return_code)
            {
                order_no = orderId;
                amount = orderAmount.ToString();
                order_body = gameId.ToString();
                attach = gameId;
                user_ip = user_Ip;
                return_type = return_code;
            }

            public string Sign()
            {
                string sign1 = shop_id+pay_source+amount+Config.shop_key;
                return Utility.MD5(sign1).ToUpper();
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

            /// <summary>
            /// 终端类型从Fetch.GetTerminalType 转化成JFT参数
            /// </summary>
            /// <param name="terminal"></param>
            //public void SetTerminal(int terminal)
            //{
            //    switch (terminal)
            //    {
            //        case 0:
            //        default:
            //            p25_terminal = "1";
            //            break;
            //        case 1:
            //            p25_terminal = "3";
            //            break;
            //        case 2:
            //            p25_terminal = "2";
            //            break;
            //    }
            //}
        }

        public class WFTNotify
        {
            public string success { get; set; }

            /// <summary>
            ///  订单号 Y 商户提交的订单号。
            /// </summary>
            public string order_no { get; set; }

            /// <summary>
            ///  金额  Y 该次交易金额（以通知金额为准）。无论商户发起支付时金额采用哪种格式，返回金额均保留两位小数。
            /// </summary>
            public string amount { get; set; }

            /// <summary>
            /// 支付结果    Y	（必须）支付返回结果1代表成功，其他为失败。
            /// </summary>
            public string pay_status { get; set; }

            public string trade_type { get; set; }
            public string terminal_trace { get; set; }
            public string total_fee { get; set; }
            public string merchant_no { get; set; }
            public string out_trade_no { get; set; }
            public string user_id { get; set; }
            public string attach { get; set; }
            public string sign { get; set; }

            public WFTNotify(HttpRequest request)
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
                string sign1 = Config.shop_id + Config.pay_source + amount + Config.shop_key;
                return sign == Utility.MD5(sign1);

            }
        }
    }
}