using Game.Utils;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using System.Web.Http;
using YYT.BLL.EF;
using YYT.Common;
using YYT.Entity;
using YYT.Web.Models;

namespace YYT.Web.Controllers
{
    /// <summary>
    /// 第三方支付平台回调通知
    /// </summary>
    [RoutePrefix("api/PayOrderNotify")]
    public class PayOrderNotifyController : ApiController
    {

        public static string api_token = ConfigHelper.Get("api_token");
        public static string notify_token = ConfigHelper.Get("notify_token");
        public class Notify
        {
            /// <summary>
            /// 平台订单号
            /// </summary>
            public string trade_no { get; set; }

            /// <summary>
            ///  支付请求金额
            /// </summary>
            public int request_amount { get; set; }

            /// <summary>
            /// 支付实际金额
            /// </summary>
            public int amount { get; set; }

            /// <summary>
            /// 商户订单号
            /// </summary>
            public string out_trade_no { get; set; }
            /// <summary>
            ///状态码
            /// </summary>
            public string state { get; set; }
            /// <summary>
            /// 状态码
            /// </summary>
            public string sign { get; set; }

            /// <summary>
            /// 回调网址
            /// </summary>
            public string callback_url { get; set; }

            //md5("amount=300000&out_trade_no=lt0085DB4AE5444B_60509043_112159&state=completed&trade_no=fdd49c43-e1c1-49da-9d23-8027f5412fe6api_tokennotify_token")
            public bool VerifySign()
            {
                Dictionary<string, string> dics = new Dictionary<string, string>();
                dics.Add("amount", request_amount.ToString());
                dics.Add("out_trade_no", out_trade_no);
                dics.Add("state", state);
                dics.Add("trade_no", trade_no);
                RestClientUtil restRe = new RestClientUtil();
                String param = restRe.getParamSrc(dics);
                string sign1 = Utility.MD5(param+ api_token + notify_token).ToLower();
                return sign.ToLower() == sign1;
            }

        }
        // GET api/PayOrderNotify
        public async Task<string> Post([FromBody] Notify entity)
        {
            string msg = "fail";
            try
            {
                await Task.Factory.StartNew(() =>
                {
                    if (entity.VerifySign())
                    {
                        M_ReChargeRecords entityre = new M_ReChargeRecords();
                        entityre.CreateTime = DateTime.Now;
                        entityre.Processed = 1;
                        entityre.OrderNo = entity.out_trade_no;

                        decimal money= Convert.ToDecimal(entity.request_amount);
                        entityre.Coin =(int)money;
                        int count = new B_ReChargeRecords().UpdateReChargeRecords(entityre);
                        msg = "ok";
                    }
                });
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Controllers.Api.PayOrderController), ex.Message + "\r\n" + entity.out_trade_no.ToString());
            }
            // 接收到通知后必须返回ok这个英文单词，不可以再返回其它任何信息
            return msg;
           
        }
    }
}