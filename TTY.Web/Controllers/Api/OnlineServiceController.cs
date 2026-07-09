using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using YYT.BLL.EF;
using YYT.Common;
using YYT.Entity;

namespace YYT.Web.Controllers.Api
{
    [RoutePrefix("api/OnlineService")]
    public class OnlineServiceController : ApiController
    {
        /// <summary>
        /// 游戏类型
        /// </summary>
        /// <returns></returns>
        // GET: api/Games
        public string Get()
        {
            string OnlineServiceUrl = "";
            try
            {
                OnlineServiceUrl = ConfigHelper.Get("jiaxincloudURL");
                string appName = ConfigHelper.Get("appName");
                string appChannel = ConfigHelper.Get("appChannel");
                OnlineServiceUrl += "&appName=" + appName + "&appChannel=" + appChannel + "";
            }
            catch (Exception ex)
            {
            }
            return OnlineServiceUrl;
        }
    }
}
