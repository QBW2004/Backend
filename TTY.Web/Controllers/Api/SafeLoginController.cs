using System;
using System.Web.Http;
using YYT.BLL.EF;
using YYT.Entity;

namespace YYT.Web.Controllers.Api
{
  
    public class SafeLoginController : ApiController
    {

        public class SafeModel
        {
            /// <summary>
            /// 玩家账号
            /// </summary>
            public string playerId { get; set; }

            /// <summary>
            /// 保险柜密码
            /// </summary>
            public string safePwd { get; set; }

        }

        [HttpPost]
        public Msg Post([FromBody] SafeModel model)
        {
            lock (this)
            {
                Msg msg1 = new Msg(10001, "登录错误！");
                try
                {
                    string playerId = model.playerId.Trim();
                    string safePwd = model.safePwd.Trim();
                    if (string.IsNullOrWhiteSpace(playerId))
                    {
                        msg1.content = "用户账号不能为空！";
                        return msg1;
                    }
                    if (string.IsNullOrWhiteSpace(safePwd))
                    {
                        msg1.content = "保险柜密码不能为空！";
                        return msg1;
                    }
                    msg1 = new B_Users().GetBySafePwd(new M_Users { ID = model.playerId,SAFE_PWD=model.safePwd });
                 
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
