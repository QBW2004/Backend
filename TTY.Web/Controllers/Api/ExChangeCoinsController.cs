using Game.Utils;
using Microsoft.AspNet.SignalR;
using System;
using System.Threading.Tasks;
using System.Web.Http;
using YYT.BLL.EF;
using YYT.Entity;
using YYT.Web.Models;

namespace YYT.Web.Controllers.Api
{
  
    public class ExChangeCoinsController : ApiController
    {

        public class ExChangeModel
        {
            /// <summary>
            /// 玩家账号
            /// </summary>
            public string playerId { get; set; }

            /// <summary>
            /// 兑换金币
            /// </summary>
            public long? coins { get; set; }

            /// <summary>
            /// 手机号码
            /// </summary>
            public string phoneNumber { get; set; }

            /// <summary>
            /// 游戏密码
            /// </summary>
            public string pwd { get; set; }
        }


        [HttpPost]
        public Msg Post([FromBody] ExChangeModel model)
        {
            Msg msg1 = new Msg(10001, "兑换错误！");
            try
            {
                string playerId = model.playerId.Trim();
                string pwd = model.pwd.Trim();
                long? coins = model.coins;
                string phoneNumber = model.phoneNumber.Trim();
                if (string.IsNullOrWhiteSpace(playerId))
                {
                    msg1.content = "用户账号不能为空！";
                    return msg1;
                }
                if (string.IsNullOrWhiteSpace(pwd))
                {
                    msg1.content = "游戏密码不能为空！";
                    return msg1;
                }
                if (coins <= 0)
                {
                    msg1.content = "请重新输入要兑换的金币！";
                    return msg1;
                }
                if (string.IsNullOrWhiteSpace(phoneNumber))
                {
                    msg1.content = "手机号码不能为空！";
                    return msg1;
                }
                M_Users usr = new B_Users().GetSingle(new M_Users { ID = model.playerId });
                if (usr == null)
                {
                    msg1.content = "用户账号不存在！";
                    return msg1;
                }
                if (usr.PWD != pwd)
                {
                    msg1.content = "请重新输入密码，游戏密码不正确！";
                    return msg1;
                }
                if (coins > usr.COINS)
                {
                    msg1.content = "输入的金币大于拥有的金币！";
                    return msg1;
                }
                M_Admin admin = new B_Admin().GetSingle(new M_Admin { ID = usr.AGENCY });
                if (admin.ID != "atmadmin")
                {
                    if (admin.COINS < coins)
                    {
                        msg1.content = "该代理[" + usr.AGENCY + "]金币不够兑换！请重新输入金币数量！";
                        return msg1;
                    }
                }
                M_ReChargeRecords entity = new M_ReChargeRecords();
                entity.GameID = model.playerId;
                entity.Processed = 0;
                entity.CreateTime = DateTime.Now;
                entity.Agency = usr.AGENCY;
                entity.OrderNo = GetOrderIDByPrefix("QDEX");
                entity.RechargeType = 31;
                entity.Coin = coins;
                using (var ef = new GameDbContext())
                {
                    // 日志
                    msg1 = new B_ReChargeRecords().AddReChargeRecords(ef,entity);
                }
                if (msg1.code != 10000)
                    return msg1;
                var hub = GlobalHost.ConnectionManager.GetHubContext<MessageHub>();
                //【旧版本】通知所有后台账号
                hub.Clients.All.sayHello($"用户【{entity.GameID}】兑换，请及时处理订单。");
            }
            catch (Exception ex)
            {
                msg1.content = ex.Message;
            }
            return msg1;
        }
        public class ReturnModel
        {
            /// <summary>
            /// 最新余额
            /// </summary>
            public long? coins { get; set; }


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
