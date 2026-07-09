using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using YYT.BLL.EF;
using YYT.Common;
using YYT.Entity;
using static YYT.Web.Controllers.Api.ExChangeController;

namespace YYT.Web.Controllers.Api
{
    [RoutePrefix("api/Cryptocurrency")]
    public class CryptocurrencyController : ApiController
    {
        /// <summary>
        /// 获取加密货币链接
        /// </summary>
        /// <returns></returns>
        // GET: api/Games
        public Msg Get(string GameID)
        {
            Msg msg1 = new Msg(0, "接口错误！");
            string CryptocurrencyUrl = "";
            try
            {
                if (string.IsNullOrWhiteSpace(GameID))
                {
                    msg1.content = "用户账号不能为空！";
                    return msg1;
                }
                M_Users usr = new B_Users().GetSingle(new M_Users { ID = GameID });
                if (usr == null)
                {
                    msg1.content = "用户账号不存在！";
                    return msg1;
                }
                ReturnModel model = new ReturnModel();
                CryptocurrencyUrl = ConfigHelper.Get("Cryptocurrency");
                model.url = CryptocurrencyUrl;
                msg1.datas = model;
                msg1.code = 1;
                msg1.content = "获取成功";
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
            public string url { get; set; }


        }
    }
}
