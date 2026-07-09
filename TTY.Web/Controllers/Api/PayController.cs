using Game.Utils;
using Microsoft.AspNet.SignalR;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using System.Web.Http;
using YYT.BLL.EF;
using YYT.Common;
using YYT.Entity;
using YYT.Web.Models;

namespace YYT.Web.Controllers.Api
{
    [RoutePrefix("api/Pay/{id}/{amount}/{user_ip}/{return_code}")]
    public class PayController : ApiController
    {
        // POST: api/PayOrder
        /// <summary>
        /// 游戏类型
        /// </summary>
        /// <returns></returns>
        // GET: api/Games
        public async Task<dynamic> Get(string id, float amount, string user_ip, string return_code)
        {
            Msg msg = new Msg(0, "充值失败！");
            try
            {
                M_Users usr = new B_Users().GetSingle(new M_Users { ID = id });
                if (usr == null)
                    return msg;
                M_ReChargeRecords entity = new M_ReChargeRecords();

                entity.CreateTime = DateTime.Now;
                entity.Agency = usr.AGENCY;
                entity.GameID = id;
                entity.Coin = Convert.ToInt64(amount);
                string orderid = GetOrderIDByPrefix("wft");
                entity.OrderNo = orderid;
                entity.RechargeType = 2;
                entity.Processed = 0;
                msg = await new B_ReChargeRecords().AddReChargeRecords(entity);
                if (msg.code != 1)
                    return msg;

                WFTPay.WFTRequest request = new WFTPay.WFTRequest(orderid, amount.ToString("F2"),
                         id, user_ip, return_code)
                {

                };
                msg.datas = request.ToUrl();
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Controllers.Api.ReChargeController), ex.Message + "\r\n" + id?.ToString());
            }
            return msg;
        }
        //public async Task<dynamic> Get(string gameid,float Amount,string subtype)
        //{

        //}
        ///// <summary>
        ///// 获取交易流水号
        ///// </summary>
        ///// <param name="prefix"></param>
        ///// <returns></returns>
        public static string GetOrderIDByPrefix(string prefix)
        {
            //构造订单号 (形如:20101201102322159111111)
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