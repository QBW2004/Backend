using Microsoft.AspNet.SignalR;
using System;
using System.Threading.Tasks;
using System.Web.Http;
using YYT.Common;
using YYT.Entity;
using YYT.Web.Models;

namespace YYT.Web.Controllers
{
    /// <summary>
    /// 第三方支付平台回调通知
    /// </summary>
    public class ReChargeNotifyController : ApiController
    {
        // GET api/ReChargeNotify
        public async Task<string> Post([FromBody]M_ReChargeNotify entity)
        {
            LogHelper.WriteLog(typeof(YYT.Web.Controllers.ReChargeNotifyController), $"收到支付通知：\n{entity.ToString()}");
            try
            {
                await Task.Factory.StartNew(() =>
                {
                    var hub = GlobalHost.ConnectionManager.GetHubContext<MessageHub>();
                    //【旧版】通知的所有
                    hub.Clients.All.sayHello($"流水号：{entity.order_id}，订单号：{entity.out_order_id}，充值金额：{entity.realprice}，请及时处理订单。");

                });
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Controllers.Api.ReChargeController), ex.Message + "\n" + entity?.ToString());
            }
            LogHelper.WriteLog(typeof(YYT.Web.Controllers.ReChargeNotifyController), $"收到支付通知：\n{Request.Headers.Referrer.AbsolutePath}");
            // 接收到通知后必须返回success这个英文单词，不可以再返回其它任何信息
            return "success";
        }
    }
}