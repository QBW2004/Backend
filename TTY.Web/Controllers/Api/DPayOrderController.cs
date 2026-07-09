using Game.Utils;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using System.Web.Http;
using System.Web.Script.Serialization;
using YYT.BLL.EF;
using YYT.Common;
using YYT.Entity;
using YYT.Web.Models;

namespace YYT.Web.Controllers.Api
{
    public class DPayOrderController : ApiController
    {
        public string TransactionUrl = ConfigHelper.Get("paymentUrl");//第三方提现接口
        public string callback_url = ConfigHelper.Get("DPayOrderNotify");//回调接口
        public static string api_token = ConfigHelper.Get("api_token");
        public static string notify_token = ConfigHelper.Get("notify_token");
        public class Model
        {
            /// <summary>
            /// 玩家账号
            /// </summary>
            public string GameID { get; set; }
            /// <summary>
            /// 请求金额
            /// </summary>
            public long? Coin { get; set; }
            /// <summary>
            /// 银行代码
            /// </summary>
            public string BankId { get; set; }
            /// <summary>
            /// 交易方名称
            /// </summary>
            public string BankOwner { get; set; }
            /// <summary>
            /// 交易银行卡号
            /// </summary>
            public string AccountNumber { get; set; }
        }
        public async Task<dynamic> Post([FromBody] Model model)
        {
            Msg msg = new Msg(0, "提现失败！");
            try
            {
                M_Users usr = new B_Users().GetSingle(new M_Users { ID = model.GameID });
                if (usr == null)
                    return msg;
                string orderNo = GetOrderIDByPrefix("tianciv");
                long? coins = 0;
                long? exchangeRate = Convert.ToInt64(ConfigHelper.Get("ExchangeRate"));
                if (exchangeRate > 0)
                    coins = Convert.ToInt64(model.Coin) / exchangeRate;
                else
                    coins = Convert.ToInt64(model.Coin);
                Dictionary<string, string> dics = new Dictionary<string, string>();
                dics.Add("out_trade_no", orderNo);
                dics.Add("bank_id", model.BankId);
                dics.Add("bank_owner", model.BankOwner);
                dics.Add("account_number", model.AccountNumber);
                dics.Add("amount", coins.ToString());
                dics.Add("callback_url", callback_url);
                dics.Add("verify_channel_no", "1");
                RestClientUtil restRe = new RestClientUtil();
                String param = restRe.getParamSrc(dics);
                string sign = Utility.MD5(param + api_token + notify_token).ToLower();
                int verify_channel_no = 1;
                string data = "{ \"out_trade_no\": \"" + orderNo + "\",\"bank_id\": \"" + model.BankId + "\",\"bank_owner\": \"" + model.BankOwner + "\",\"account_number\": \"" + model.AccountNumber + "\",\"amount\": \"" + (float)coins + "\",\"callback_url\": \"" + callback_url + "\",\"verify_channel_no\": \"" + verify_channel_no + "\",\"sign\": \"" + sign + "\"}";
                JavaScriptSerializer jss = new JavaScriptSerializer();
                var Tr = restRe.Post(data, TransactionUrl);
                JObject jo = JObject.Parse(Tr);
                var statusCode2 = Convert.ToBoolean(jo["success"].ToString());
                if (statusCode2 == true)
                {
                    M_ReChargeRecords entity = new M_ReChargeRecords();
                    entity.Coin = model.Coin;
                    entity.CreateTime = DateTime.Now;
                    entity.Agency = usr.AGENCY;
                    entity.GameID = model.GameID;
                    entity.Coin = model.Coin;
                    entity.OrderNo = orderNo;
                    entity.RechargeType = 31;
                    entity.Processed = 0;
                    msg = await new B_ReChargeRecords().AddReChargeRecords(entity);
                    msg.content = "提现成功！";
                }
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Controllers.Api.PayOrderController), ex.Message + "\r\n" + model.GameID.ToString());
            }
            return msg;
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