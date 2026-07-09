using Game.Utils;
using Newtonsoft.Json.Linq;
using System;
using System.Threading.Tasks;
using System.Web.Http;
using System.Web.Script.Serialization;
using YYT.BLL.EF;
using YYT.Common;
using YYT.Entity;
using YYT.Web.Models;

namespace YYT.Web.Controllers.Api
{
    //api/PayOrder
    public class PayOrderController : ApiController
    {
        public string TransactionUrl = ConfigHelper.Get("TransactionUrl");//第三方支付接口
        public string callback_url = ConfigHelper.Get("PayOrderNotify");//回调接口

        public class Model
        {
            /// <summary>
            /// 玩家账号
            /// </summary>
            public string GameID { get; set; }
            public long? Coin { get; set; }
        }
        public async Task<dynamic> Post([FromBody] Model model)
        {
            Msg msg = new Msg(0, "充值支付失败（Thanh toán nạp tiền thất bại）！");
            try
            {
                if (model.Coin < 150000)
                {
                    msg.content = "充值金额需大于等于15万（Số tiền nạp phải lớn hơn 150.000.）";
                    return msg;
                }

                M_Users usr = new B_Users().GetSingle(new M_Users { ID = model.GameID });
                if (usr == null)
                    return msg;
                string orderNo = GetOrderIDByPrefix("tianciv");
                string data = "{ \"amount\": \"" + model.Coin + "\",\"callback_url\": \"" + callback_url + "\",\"out_trade_no\": \"" + orderNo + "\"}";
                JavaScriptSerializer jss = new JavaScriptSerializer();
                RestClientUtil restRe = new RestClientUtil();
                var Tr = restRe.Post(data, TransactionUrl);
                JObject jo = JObject.Parse(Tr);
                var statusCode2 = Convert.ToBoolean(jo["success"].ToString());
                if (statusCode2 == true)
                {
                    M_ReChargeRecords entity = new M_ReChargeRecords();
                    entity.CreateTime = DateTime.Now;
                    entity.Agency = usr.AGENCY;
                    entity.GameID = model.GameID;
                    entity.Coin = Convert.ToInt64(model.Coin) / 3000;
                    entity.OrderNo = orderNo;
                    entity.RechargeType = 30;
                    entity.Processed = 0;
                    msg = await new B_ReChargeRecords().AddReChargeRecords(entity);
                    msg.content = "充值接口调用成功";
                }
                datasModel datas = new datasModel();
                datas.url = jo["data"]["uri"].ToString();
                datas.qrcode = jo["data"]["qrcode"].ToString();
                msg.datas = datas;
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Controllers.Api.PayOrderController), ex.Message + "\r\n" + model.GameID.ToString());
            }
            return msg;
        }

        public class datasModel
        {
            public string url { get; set; }
            public string qrcode { get; set; }
        }

        /// <summary>
        /// 获取交易流水号
        /// </summary>
        /// <param name="prefix"></param>
        /// <returns></returns>
        public static string GetOrderIDByPrefix(string prefix)
        {
            int orderIDLength = 32;
            int randomLength = 6;
            StringBuffer tradeNoBuffer = new StringBuffer();
            tradeNoBuffer += prefix;
            tradeNoBuffer += TextUtility.GetDateTimeLongString();
            if ((tradeNoBuffer.Length + randomLength) > orderIDLength)
                randomLength = orderIDLength - tradeNoBuffer.Length;
            tradeNoBuffer += TextUtility.CreateRandom(randomLength, 1, 0, 0, 0, "");
            return tradeNoBuffer.ToString();
        }
    }
}