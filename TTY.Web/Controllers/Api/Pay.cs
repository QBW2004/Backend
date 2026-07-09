using Game.Utils;
using Microsoft.AspNet.SignalR;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Threading.Tasks;
using System.Web.Http;
using YYT.BLL.EF;
using YYT.Common;
using YYT.Entity;
using YYT.Web.Models;

namespace YYT.Web.Controllers.Api
{
    public class Pay : ApiController
    {
        // GET api/<controller>
        public async Task<dynamic> Get(string gameid, float Amount, string subtype)
        {
            Msg msg = new Msg(0, "充值失败！");
            try
            {
                M_Users usr = new B_Users().GetSingle(new M_Users { ID = gameid });
                if (usr == null)
                    return msg;
                M_ReChargeRecords entity = new M_ReChargeRecords();

                entity.CreateTime = DateTime.Now;
                entity.Agency = usr.AGENCY;
                entity.GameID = gameid;
                entity.Coin = Convert.ToInt64(Amount);
                string orderid = GetOrderIDByPrefix("wft");
                entity.OrderNo = orderid;
                entity.RechargeType = 2;
                entity.Processed = 0;
                msg = await new B_ReChargeRecords().AddReChargeRecords(entity);
                if (msg.code != 1)
                    return msg;

                var hub = GlobalHost.ConnectionManager.GetHubContext<MessageHub>();
                //【旧版本】通知所有后台账号
                hub.Clients.All.sayHello($"用户【{entity.GameID}】充值，请及时处理订单。");


                JDPay.JDH5Request request = new JDPay.JDH5Request(orderid, Amount.ToString("F2"),
                         gameid
                          )
                {

                };
                msg.datas = request.ToUrl();
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Controllers.Api.ReChargeController), ex.Message + "\r\n" + gameid?.ToString());
            }
            return msg;
            //return new string[] { "value1", "value2" };
        }

        // GET api/<controller>/5
        public string Get(int id)
        {
            return "value";
        }

        // POST api/<controller>
        public void Post([FromBody] string value)
        {
        }

        // PUT api/<controller>/5
        public void Put(int id, [FromBody] string value)
        {
        }

        // DELETE api/<controller>/5
        public void Delete(int id)
        {
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



//        @RequestMapping(value = "login", method = RequestMethod.POST)
//    public String login(@RequestParam(value = "username") String username,
//                        @RequestParam(value = "plat_type") String plat_type,
//                        @RequestParam(value = "game_type") String game_type,
//                        @RequestParam(value = "game_code") String game_code,
//                        @RequestParam(value = "is_mobile_url") String is_mobile_url,
//                        @RequestParam(value = "lott_type", required = false) String lott_type,
//                           @RequestParam(value = "demo", required = false) String demo, HttpServletRequest request
//                        ) {



//        if(StringUtils.isEmpty(username) || StringUtils.isEmpty(plat_type) || StringUtils.isEmpty(game_code)|| StringUtils.isEmpty(is_mobile_url)){
//            return new Result().getErrorMsg(ServiceErrorEnum.REQUEST_SERVICE_INVALID_PARAMETER);
//    }
//        try {
//            lock.lock();
//            Map<String, String> map = new HashMap<>();
//    map.put("username",username);
//            map.put("plat_type",plat_type);
//            map.put("game_type",game_type);
//            map.put("game_code",game_code);
//            map.put("is_mobile_url",is_mobile_url);
//            map.put("lott_type",lott_type);
//            map.put("demo",demo);
//            return xinLiWebService.login(map, request);
//        }catch (Exception e)
//{
//    e.printStackTrace();
//}
//finally
//{
//    lock.unlock();
//}
//return new Result().getErrorMsg("服务器繁忙，请稍后重试。。。");
//    }







//@Transactional
//    public String login(Map<String, String> param, HttpServletRequest request)
//{
//    if (CollectionUtils.isEmpty(param))
//    {
//        return new Result().getErrorMsg(ServiceErrorEnum.REQUEST_SERVICE_INVALID_PARAMETER);
//    }
//    //判断游戏平台是否启用
//    PlatType platType = platTypeDao.queryPlatTypeByType(param.get("plat_type"));
//    if (platType == null)
//    {
//        return new Result().getErrorMsg(ServiceErrorEnum.REQUEST_SERVICE_PLAT_TYPE_NON_EXISTENT);
//    }
//    else
//    {
//        if (platType.getState() == 1)
//        {
//            return new Result().getErrorMsg(ServiceErrorEnum.REQUEST_SERVICE_PLAT_TYPE_NON_EXISTENT);
//        }
//    }
//    //判断用户是否注册过
//    Account account = accountDao.findAccount(param.get("username"));
//    if (account == null)
//    {
//        CommomUser user = xinLiUserDao.getUserAccount(param.get("username"));
//        if (user == null)
//        {
//            return new Result().getErrorMsg("用户不存在");
//        }
//        //去第三方注册用户
//        Map<String, String> registerMap = new HashMap<>();
//        registerMap.put("username", param.get("username"));
//        registerMap.put("plat_type", param.get("plat_type"));
//        String rep = xinHaoMerchantsService.register(registerMap);
//        Map map = new Gson().fromJson(rep, Map.class);
//if (map.get("statusCode").equals("01"))
//{//注册成功
//    account = new Account();
//    account.setUserName(param.get("username"));
//    account.setPhone(user.getPhone());
//    account.setPromoterId(user.getPromoterId() + "");
//    account.setPromoterName(user.getPromoterName());
//    account.setCreateDate(new Date());
//    account.setUpdateDate(new Date());
//    account.setRegisterIp(getIpAddr(request));
//    account.setDevice(param.get("device"));
//    accountDao.insert(account);
//}
//        }
//        //判断是否是免转钱包
//        if (walletType == 2)
//{//免转钱包
//    CommomUser user = xinLiUserDao.getUserAccount(param.get("username"));
//    /* if(user.getGameGold() < 200){ // 梦之城 视讯 金额限制
//         log.info("视讯最低 200 才能进入游戏！username={}",param.get("username"));
//         return new Result().getErrorMsg("视讯最低 200 才能进入游戏！");
//     }*/
//    if (user.getGameGold() > 0)
//    {
//        String res = xinHaoMerchantsService.allCredit(new HashMap<>());
//        JSONObject jsonObject = JSONObject.parseObject(res);
//        if (jsonObject.get("statusCode").equals("01"))
//        {//获取成功
//            if (!StringUtils.isEmpty(jsonObject.get("data")))
//            {
//                JSONObject jsonObject1 = jsonObject.getJSONObject("data");
//                double gameGold = new BigDecimal(user.getGameGold()).divide(new BigDecimal(rate)).setScale(2, BigDecimal.ROUND_DOWN).doubleValue();
//                if (jsonObject1.getBigDecimal("tyscore").compareTo(new BigDecimal(gameGold)) == 1 || jsonObject1.getBigDecimal("tyscore").compareTo(new BigDecimal(gameGold)) == 0)
//                {
//                    //判断商户额度是否够
//                    Map<String, String> walletMap = new HashMap<>();
//                    walletMap.put("username", param.get("username"));
//                    walletMap.put("money", gameGold + "");
//                    walletMap.put("client_transfer_id", orderPrefix + OrderNumUtil.generateOrderCode());
//                    String rep = xinHaoMerchantsService.walletTrans(walletMap);
//                    Map map = new Gson().fromJson(rep, Map.class);
//TransferLog transferLog = new TransferLog();
//if (map.get("statusCode").equals("01"))
//{//转账成功
//    xinLiUserDao.updateAmount(param.get("username"), -user.getGameGold());
//    transferLog.setStatus(1);
//    transferLog.setRemark("免转钱包:" + user.getUsername() + " 转入平台 " + param.get("plat_type") + " ，金额：" + gameGold);
//}
//else
//{
//    transferLog.setStatus(2);
//    transferLog.setRemark("免转钱包更新失败:" + user.getUsername() + " 转入平台 " + param.get("plat_type") + " ，金额：" + gameGold);
//}
//transferLog.setUserName(user.getUsername());
//transferLog.setClientTransferId(walletMap.get("client_transfer_id"));
//transferLog.setMoney(new BigDecimal(gameGold));
//transferLog.setType("in");
//transferLog.setPlatType(param.get("plat_type"));
//transferLog.setCreateDate(new Date());
//transferLog.setUpdateDate(new Date());
//transferLogDao.insert(transferLog);
//                        }
//                    }
//                }
//            }
//        }
//        //登录平台
//        Map<String, String> loginMap = new HashMap<>();
//loginMap.put("username", param.get("username"));
//loginMap.put("plat_type", param.get("plat_type"));
//loginMap.put("game_type", param.get("game_type"));
//loginMap.put("game_code", param.get("game_code"));
//loginMap.put("is_mobile_url", param.get("is_mobile_url"));
//loginMap.put("lott_type", "");
//loginMap.put("lang", "");
//loginMap.put("demo", "");//1进入试玩 为空进入真实游戏
//loginMap.put("wallet_type", walletType + "");
//String rep = xinHaoMerchantsService.login(loginMap);
//Map map = new Gson().fromJson(rep, Map.class);
//if (map.get("statusCode").equals("01"))
//{//登录成功
//    AccountLog accountLog = new AccountLog();
//    account.setLoginIp(getIpAddr(request));
//    account.setLastLoginTime(new Date());
//    account.setDevice(param.get("device"));
//    account.setUpdateDate(new Date());
//    if (StringUtils.isEmpty(account.getPlayGame()))
//    {
//        account.setPlayGame(param.get("plat_type") + "-" + param.get("game_type"));
//    }
//    else
//    {
//        String s = param.get("plat_type") + "-" + param.get("game_type");
//        List<String> list = Arrays.asList(account.getPlayGame().split(","));
//        if (!list.contains(s))
//        {
//            account.setPlayGame(account.getPlayGame() + "," + s);
//        }
//    }
//    accountLog.setUserName(account.getUserName());
//    accountLog.setIp(account.getLoginIp());
//    accountLog.setCreateTime(new Date());
//    accountDao.accountUpdate(account);
//    accountLogDao.insert(accountLog);
//}
//return rep;
//    }















//  @RequestMapping(value = "userTransAll", method = RequestMethod.POST)
//    public String userTransAll(@RequestParam(value = "username") String username
//    ) {
//    if (StringUtils.isEmpty(username))
//    {
//        return new Result().getErrorMsg(ServiceErrorEnum.REQUEST_SERVICE_INVALID_PARAMETER);
//    }
//    try
//    {
//        userTransLock.lock () ;
//        Map<String, String> map = new HashMap<>();
//        map.put("username", username);
//        return xinLiWebService.userTransAll(map);
//    }
//    catch (Exception e)
//    {
//        e.printStackTrace();
//    }
//    finally
//    {
//        userTransLock.unlock();
//    }
//    return new Result().getErrorMsg("服务器繁忙，请稍后重试。。。");
//}



//@Transactional
//    public String userTransAll(Map<String, String> param)
//{
//    String rep = xinHaoService.userTransAll(param);
//    JSONObject map = JSON.parseObject(rep);
//    if (map.get("statusCode").equals("01"))
//    {//一键转出成功
//        JSONObject transMap = null;
//        String str = map.getString("data");
//        char[] strChar = str.substring(0, 1).toCharArray();
//        char firstChar = strChar[0];
//        if (firstChar == '{')
//        {
//            transMap = map.getJSONObject("data");
//        }
//        else if (firstChar == '[')
//        {
//            JSONArray jsonArray = map.getJSONArray("data");
//            if (CollectionUtils.isEmpty(jsonArray))
//            {
//                return new Result().success("暂无平台额度转出");
//            }
//        }
//        BigDecimal bigDecimal = transMap.getBigDecimal("allCount");
//        if (bigDecimal.compareTo(new BigDecimal(0)) == 1)
//        {
//            CommomUser commomUser = xinLiUserDao.getUserAccount(param.get("username"));
//            int allCount = bigDecimal.multiply(new BigDecimal(rate)).setScale(0, BigDecimal.ROUND_DOWN).intValue();
//            TransferLog transferLog = new TransferLog();
//            xinLiUserDao.updateAmount(param.get("username"), allCount);
//            transferLog.setUserName(param.get("username"));
//            transferLog.setStatus(1);
//            transferLog.setMoney(bigDecimal.negate());
//            transferLog.setType("out");
//            transferLog.setPlatType("ALL");
//            transferLog.setCreateDate(new Date());
//            transferLog.setUpdateDate(new Date());
//            transferLog.setRemark("一键转出:" + param.get("username") + " 转出金额：" + allCount);
//            transferLogDao.insert(transferLog);
//            try
//            {
//                UserAward ua = new UserAward();
//                ua.setUserId(commomUser.getId());
//                ua.setUsername(commomUser.getUsername());
//                ua.setGold(allCount);
//                ua.setStatus(0);
//                ua.setDatetime(sdf.format(new Date()));
//                ua.setAdmin("system-live");
//                ua.setAuthority(0);
//                userAwardDao.insert(ua);
//                userAwardDao.updateGiveInfoByUid(commomUser.getId(), allCount);
//            }
//            catch (Exception e)
//            {
//                e.printStackTrace();
//                logger.error(e.getMessage());
//            }
//        }
//        else
//        {
//            return new Result().success("暂无平台额度转出");
//        }
//    }
//    return rep;
//}








    }
}