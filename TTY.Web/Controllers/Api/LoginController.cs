using Game.Utils;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.IO;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Security.Principal;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using System.Web.Http;
using System.Web.Mvc;
using System.Web.Script.Serialization;
using YYT.BLL.EF;
using YYT.Common;
using YYT.Entity;
using YYT.Web.Controllers.Api;
using YYT.Web.Models;

namespace YYT.Web.Controllers.AgbbinApi
{
    public class LoginController : ApiController
    {
        public string apApi = "https://ap.api-bet.net";//亚太区域 API 域名
        //public string saApi = "https://sa.api-bet.net";//南美区域 API 域名
        //公共接口
        public string gameUrl = "/api/server/gameUrl";//登录接口
        public string create = "/api/server/create";//创建玩家
        //public string balance = "/api/server/balance";//查询余额
        //public string balanceAll = "/api/server/balanceAll";//一键查询
        public string transferAll = "/api/server/transferAll";//一键回收
        //public string demoUrl = "/api/server/demoUrl";//试玩游戏
        //游戏记录
        //public string recordAll = "/api/server/recordAll";//实时记录
        //public string recordHistory = "/api/server/recordHistory";//历史记录
        //public string recordOrder = " /api/server/recordOrder";//订单查询
        //转账钱包
       // public string transfer = "/api/server/transfer";//额度转换
        //public string transferStatus = "/api/server/transferStatus";//转换状态
        //免转钱包
        public string walletTransfer = "/api/server/walletTransfer";//额度转换
        //public string walletStatus = "/api/server/walletStatus";//转换状态
        //public string walletBalance = "/api/server/walletBalance";//查询钱包
        //游戏接口
        public string gameCode = "/api/server/gameCode";//游戏代码
        //商户接口
        public string quota = "/api/server/quota";//查询余额
        //sign_key
        public string secretKey = ConfigHelper.Get("secretKey");
        //SN
        public string SN = ConfigHelper.Get("SN");
        //walletType
        public string walletType = ConfigHelper.Get("walletType");
        public class loginModel
        {
            /// <summary>
            /// 玩家账号
            /// </summary>
            public string playerId { get; set; }
            /// <summary>
            /// 游戏平台，参考"游戏平台"附录
            /// </summary>
            public string platType { get; set; }
            /// <summary>
            /// 游戏货币，参考"游戏平台"附录
            /// </summary>
            public string currency { get; set; }
            /// <summary>
            /// 游戏类型，参考"游戏平台"附录
            /// </summary>
            public string gameType { get; set; }
            /// <summary>
            /// 游戏语言，参考"游戏语言"附录，默认货币对应的语言
            /// </summary>
            public string lang { get; set; }
            /// <summary>
            /// 游戏代码，参考"游戏代码"接口，默认游戏大厅
            /// </summary>
            public string gameCode { get; set; }
            /// <summary>
            /// 返回地址，游戏退出时跳转地址，示例："https://www.xxxxx.com"
            /// </summary>
            public string returnUrl { get; set; }
            /// <summary>
            ///终端类型，device1:电脑网页版、device2:手机网页版，其他特定终端请参考"游戏平台"附录
            /// </summary>
            public string ingress { get; set; }
            /// <summary>
            /// 钱包模式，1:转账钱包(默认)、2:免转钱包，登录游戏时系统自动转换额度
            /// </summary>
            public string walletType { get; set; }
            /// <summary>
            ///赔率类型，参考"游戏平台"附录
            /// </summary>
            public string oddsType { get; set; }

        }
        [System.Web.Http.HttpPost]
        public Msg Post([FromBody] loginModel model)
        {
            lock (this)
            {
                string strJSON = "";
                Msg msg1 = new Msg(10001, "错误！");
                RestClientUtil restRe = new RestClientUtil();
                JavaScriptSerializer jssRe = new JavaScriptSerializer();
                try
                {
                    if (string.IsNullOrEmpty(model.playerId))
                    {
                        msg1.content = "玩家账号不能为空,必填字段";
                        return msg1;
                    }
                    if (string.IsNullOrEmpty(model.currency))
                    {
                        msg1.content = "游戏货币不能为空,必填字段";
                        return msg1;
                    }
                    if (string.IsNullOrEmpty(model.platType))
                    {
                        msg1.content = "游戏平台不能为空,必填字段";
                        return msg1;
                    }
                    if (string.IsNullOrEmpty(model.gameType))
                    {
                        msg1.content = "游戏类型不能为空,必填字段";
                        return msg1;
                    }
                    if (string.IsNullOrEmpty(model.ingress))
                    {
                        msg1.content = "终端类型不能为空,必填字段";
                        return msg1;
                    }
                    M_PlatType p = new B_PlatType().GetType(new M_PlatType { Type = model.platType });
                    if (p == null)
                    {
                        msg1.content = "未找到该平台";
                        return msg1;
                    }
                    else
                    {
                        if (p.Enable == false)
                        {
                            msg1.content = "该平台已经禁用";
                            return msg1;
                        }
                    }

                    M_Users user = new B_Users().GetSingle(new M_Users { ID = model.playerId });
                    if (user == null)
                    {
                        msg1.content = "此ID用户不存在！";
                        return msg1;
                    }
                    else
                    {
                        string data = "{ \"playerId\": \"" + model.playerId + "\",\"platType\": \"" + model.platType + "\",\"currency\": \"" + model.currency + "\"}";
                        var r1 = restRe.PostJson(data, apApi + create);
                        Agbbin_VO.ReturnMessage msgRe = jssRe.Deserialize<Agbbin_VO.ReturnMessage>(r1);
                        if (msgRe.code == 10000)
                        {//注册成功
                            int val = new B_Users().IsRegisterUser(user);
                        }
                    }
                    //登录
                    string data2 = "{ \"playerId\": \"" + model.playerId + "\",\"platType\": \"" + model.platType + "\",\"currency\": \"" + model.currency + "\",\"gameType\": \"" + model.gameType + "\",\"ingress\": \"" + model.ingress + "\"" +
                        ",\"walletType\": \"" + walletType + "\",\"lang\": \"" + model.lang + "\",\"gameCode\": \"" + model.gameCode + "\",\"oddsType\": \"" + model.oddsType + "\",\"returnUrl\": \"" + model.returnUrl + "\"}";
                    strJSON = restRe.PostJson(data2, apApi + gameUrl);
                    JObject jo = JObject.Parse(strJSON);
                    var statusCode2 = jo["code"].ToString();
                    if (statusCode2 == "10000")
                    {
                        using (var ef = new GameDbContext())
                        {
                            // 日志
                            new B_AccountLog().AddAccountLog(ef, new M_AccountLog
                            {
                                UserName = model.playerId,
                                CreateTime = DateTime.Now,
                                PlayGame = model.platType + "-" + model.gameType
                            });
                        }
                        if (walletType == "2")//免转钱包
                        {
                            string data1 = "{}";
                            var r = restRe.PostJson(data1, apApi + quota);
                            JObject jo3 = JObject.Parse(r);
                            var statusCode3 = jo3["code"].ToString();
                            if (statusCode3 == "10000")//调用成功
                            {
                                double tyscore = Convert.ToDouble(jo3["data"]["shared-CNY"].ToString());
                                double coins = Convert.ToDouble(user.COINS / 10);
                                if (tyscore >= coins)
                                {
                                    if (user.COINS > 0)
                                    {
                                        //调用免转钱包
                                        string orderId = GetOrderIDByPrefix("YYTGAME");
                                        data1 = "{ \"playerId\": \"" + model.playerId + "\",\"type\": \"" + 1 + "\",\"currency\": \"" + model.currency + "\",\"amount\": \"" + Convert.ToDouble(user.COINS) + "\",\"orderId\": \"" + orderId + "\"}";
                                        var Tr = restRe.PostJson(data1, apApi + walletTransfer);
                                        M_TransferLog log = new M_TransferLog();
                                        JObject jo1 = JObject.Parse(Tr);
                                        var statusCode1 = jo1["code"].ToString();
                                        LogHelper.WriteLog(typeof(LoginController), $"调用视讯参数：\n{data1}");
                                        if (statusCode1 == "10000")
                                        {
                                            LogHelper.WriteLog(typeof(LoginController), $"视讯返回参数：\n{jo1}");
                                            int count1 = new B_Users().UpdateCoin(model.playerId, -user.COINS);
                                            log.Status = 1;
                                            log.Remark = "免转钱包:" + model.playerId + " 转入平台 " + model.platType + " ，金额：" + user.COINS;
                                        }
                                        else
                                        {
                                            log.Status = 0;
                                            log.Remark = "免转钱包更新失败:" + model.playerId + " 转入平台 " + model.platType + " ，金额：" + user.COINS;
                                        }
                                        using (var ef = new GameDbContext())
                                        {
                                            // 日志
                                            new B_TransferLog().AddTransferLog(ef, new M_TransferLog
                                            {
                                                UserName = model.playerId,
                                                Status = log.Status,
                                                ClientTransferId = orderId,
                                                Money = Convert.ToInt64(user.COINS),
                                                CreateTime = DateTime.Now,
                                                PlatType = model.platType,
                                                Type = "in",
                                                Remark = log.Remark
                                            });
                                        }
                                    }
                                    else
                                    {
                                        msg1.content = "接口调用成功，请用户充值！";
                                        return msg1;
                                    }
                                }
                                else
                                {
                                    msg1.content = "接口调用成功，请商户检查余额！";
                                    return msg1;
                                }
                            }
                        }
                    }
                    msg1.code = Convert.ToInt32(jo["code"]);
                    msg1.content = jo["msg"].ToString();
                    msg1.datas = jo["data"];
                    return msg1;
                }
                catch (Exception ex)
                {
                    msg1.content = "异常" + ex.Message;
                }
                return msg1;
            }
        }

        #region 解析JSON
        /// <summary>
        /// 解析JSON
        /// </summary>
        /// <param name="strJson"></param>
        /// <returns></returns>
        public static NameValueCollection ParseJson(string strJson)
        {
            NameValueCollection mc = new NameValueCollection();
            Regex regex = new Regex(@"(\s*\""?([^""]*)\""?\s*\:\s*\""?([^""]*)\""?\,?)");
            strJson = strJson.Trim();
            if (strJson.StartsWith("{"))
            {
                strJson = strJson.Substring(1, strJson.Length - 2);
            }

            foreach (Match m in regex.Matches(strJson))
            {
                mc.Add(m.Groups[2].Value, m.Groups[3].Value);
            }
            return mc;
        }
        #endregion

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

        /// <summary>
        /// 生成随机字符串
        /// </summary>
        /// <param name="length">字符串长度</param>
        /// <returns></returns>
        public string GetChar(int length)
        {
            char[] chars = {
                                '0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
                                'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j',
                                'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't',
                                'u', 'v', 'w', 'x', 'y', 'z'
                               };
            string result = "";
            Random rnd = new Random(Guid.NewGuid().GetHashCode());
            for (int i = 0; i < length; i++)
            {
                result += chars[rnd.Next(chars.Length)];
            }
            return result;
        }



    }
}
