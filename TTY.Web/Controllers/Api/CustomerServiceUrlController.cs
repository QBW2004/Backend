using System;
using System.Web.Http;
using YYT.BLL.EF;
using YYT.Entity;

namespace YYT.Web.Controllers.Api
{
  
    public class CustomerServiceUrlController : ApiController
    {

        public class SafeModel
        {
            /// <summary>
            /// 玩家账号
            /// </summary>
            public string playerId { get; set; }
        }

        [HttpPost]
        public Msg Post([FromBody] SafeModel model)
        {
            // 本接口无状态写入，无需跨请求互斥；lock(this) 因 Web API 每次新建实例而无效，已移除。
            Msg msg1 = new Msg(10000, "查询成功！");
            try
            {
                if (model == null || string.IsNullOrWhiteSpace(model.playerId))
                {
                    msg1.content = "用户账号不能为空！";
                    return msg1;
                }
                string playerId = model.playerId.Trim();

                M_Users users = new B_Users().GetSingle(new M_Users { ID = playerId });
                if (users == null)
                {
                    msg1.content = "用户账号不存在！";
                    return msg1;
                }
                ReturnModel returnModel = new ReturnModel();
                returnModel.CustomerServiceUrl = new B_Admin().ResolveCustomerServiceUrl(users.AGENCY);
                msg1.datas = returnModel;
            }
            catch (Exception ex)
            {
                msg1.content = ex.Message;
            }
            return msg1;
        }
        public class ReturnModel
        {
            public string CustomerServiceUrl { get; set;}
        }
    }
}
