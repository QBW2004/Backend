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
  
    public class GameCodeController : ApiController
    {
        public string apApi = "https://ap.api-bet.net";//亚太区域 API 域名
        //游戏接口
       public string gameCode = "/api/server/gameCode";//游戏代码
        public class TransModel
        {
            public string platType { get; set; }
        }

        [HttpPost]
        public Msg Post([FromBody] TransModel model)
        {
            lock (this)
            {
                Msg msg1 = new Msg(10001, "错误！");
                try
                { 
                    string data = "{ \"platType\": \"" + model.platType + "\"}";
                    JavaScriptSerializer jss = new JavaScriptSerializer();
                    RestClientUtil restRe = new RestClientUtil();
                    var Tr = restRe.PostJson(data, apApi+ gameCode);
                    JObject jo = JObject.Parse(Tr);
                    foreach (JObject item in jo["data"])
                    {
                        item.Remove("imageUrl");
                    }
                    msg1.code = Convert.ToInt32(jo["code"].ToString());
                    msg1.content = jo["msg"].ToString();
                    msg1.datas = jo["data"];
                }
                catch (Exception ex)
                {
                    msg1.content =ex.Message;
                }
                return msg1;
            }
        }
    }
}
