using Game.Utils;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Text.RegularExpressions;
using System.Web.Http;
using System.Web.Script.Serialization;
using YYT.BLL.EF;
using YYT.Common;
using YYT.Entity;
using YYT.Web.Models;

namespace YYT.Web.Controllers.Api
{
  
    public class UserTransAllController : ApiController
    {
        public string apApi = "https://ap.api-bet.net";//亚太区域 API 域名
        //public string saApi = "https://sa.api-bet.net";//南美区域 API 域名
        //公共接口
        //public string gameUrl = "/api/server/gameUrl";//登录接口
        //public string create = "/api/server/create";//创建玩家
        //public string balance = "/api/server/balance";//查询余额
        public string balanceAll = "/api/server/balanceAll";//一键查询
        public string transferAll = "/api/server/transferAll";//一键回收
        //public string demoUrl = "/api/server/demoUrl";//试玩游戏
        ////游戏记录
        //public string recordAll = "/api/server/recordAll";//实时记录
        //public string recordHistory = "/api/server/recordHistory";//历史记录
        //public string recordOrder = " /api/server/recordOrder";//订单查询
        ////转账钱包
        //public string transfer = "/api/server/transfer";//额度转换
        //public string transferStatus = "/api/server/transferStatus";//转换状态
        ////免转钱包
        public string walletTransfer = "/api/server/walletTransfer";//额度转换
        //public string walletStatus = "/api/server/walletStatus";//转换状态
        public string walletBalance = "/api/server/walletBalance";//查询钱包
        //游戏接口
       // public string gameCode = "/api/server/gameCode";//游戏代码
        //商户接口
       // public string quota = "/api/server/quota";//查询余额
        //sign_key
        public string secretKey = ConfigHelper.Get("secretKey");
        //SN
        public string SN = ConfigHelper.Get("SN");
        //walletType
        public string walletType = ConfigHelper.Get("walletType");

        public class TransModel
        {
            /// <summary>
            /// 玩家账号
            /// </summary>
            public string playerId { get; set; }
           

        }

        [HttpPost]
        public Msg Post([FromBody] TransModel model)
        {
            lock (this)
            {
                string strJSON = "";
                Msg msg1 = new Msg(10001, "错误！");
                try
                { 
                    string currency = "CNY";
                    string data = "{ \"playerId\": \"" + model.playerId + "\",\"currency\": \"" + currency + "\"}";
                    JavaScriptSerializer jss = new JavaScriptSerializer();
                    RestClientUtil restRe = new RestClientUtil();
                    //调用一键回收接口
                    var Tr = restRe.PostJson(data, apApi+ transferAll);
                    JObject jo = JObject.Parse(Tr);
                    LogHelper.WriteLog(typeof(UserTransAllController), $"一键回收：\n{jo}");
                    string statusCode = jo["code"].ToString();
                    if (statusCode == "10000")
                    {
                        long? allCount = Convert.ToInt64(jo["data"]["balanceAll"]);
                        if (allCount > 0)
                        {
                            using (var ef = new GameDbContext())
                            {
                                // 日志
                                new B_TransferLog().AddTransferLog(ef, new M_TransferLog
                                {
                                    UserName = model.playerId,
                                    Status = 1,
                                    Money = allCount,
                                    CreateTime = DateTime.Now,
                                    PlatType="All",
                                    Type="out",
                                    Remark = "一键转出:" + model.playerId + " 转出金额：" + allCount
                                });
                            }
                            int count1 = new B_Users().UpdateCoin(model.playerId, allCount);
                        }
                    }
                    M_Users usr = new B_Users().GetSingle(new M_Users { ID = model.playerId });
                    returnModel rtmodel = new returnModel();
                    rtmodel.coins = usr.COINS;
                    msg1.code = Convert.ToInt32(jo["code"].ToString());
                    msg1.content = jo["msg"].ToString();
                    msg1.datas = rtmodel;
                }
                catch (Exception ex)
                {
                    msg1.content =ex.Message;
                }
                return msg1;
            }
        }
        public class returnModel
        {
        

            /// <summary>
            /// 金币数
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
