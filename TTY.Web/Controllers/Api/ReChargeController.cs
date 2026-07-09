using Game.Utils;
using Microsoft.AspNet.SignalR;
using System;
using System.Threading.Tasks;
using System.Web.Http;
using YYT.BLL.EF;
using YYT.Common;
using YYT.Entity;
using YYT.Web.Models;

namespace YYT.Web.Controllers.Api
{
    public class ReChargeController : ApiController
    {
        // POST: api/ReCharge
        public async Task<dynamic> Post([FromBody]M_ReChargeRecords entity)
        {
            Msg msg = new Msg(0, "充值失败！");
            try
            {
                M_Users usr = new B_Users().GetSingle(new M_Users { ID = entity.GameID });
                if (usr == null)
                    return msg;

                entity.CreateTime = DateTime.Now;
                entity.Agency = usr.AGENCY;

                entity.OrderNo = GetOrderIDByPrefix("QDRE");
                entity.RechargeType = 30;
                msg = await new B_ReChargeRecords().AddReChargeRecords(entity);
                if (msg.code != 1)
                    return msg;
                var hub = GlobalHost.ConnectionManager.GetHubContext<MessageHub>();
                //【旧版本】通知所有后台账号
                hub.Clients.All.sayHello($"用户【{entity.GameID}】充值，请及时处理订单。");
                //// 通知直属代理
                //string agency = new B_Users().GetSingle(new M_Users { ID = entity.GameID })?.AGENCY;
                //if (!string.IsNullOrWhiteSpace(agency))
                //{
                //    string connectionId = MessageHub.ChatUsers.Find(c => c.Name.Equals(agency))?.ContextID;
                //    if (!string.IsNullOrWhiteSpace(connectionId))
                //        hub.Clients.Client(connectionId).sayHello($"用户【{entity.GameID}】充值，请及时处理订单。");
                //}
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Controllers.Api.ReChargeController), ex.Message + "\r\n" + entity?.ToString());
            }
            return msg;
        }

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
