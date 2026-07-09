using System;
using System.Web.Http;
using YYT.BLL.EF;
using YYT.Entity;

namespace YYT.Web.Controllers.Api
{
  
    public class SafeUpdatePwdController : ApiController
    {

        public class SafeModel
        {
            /// <summary>
            /// 玩家账号
            /// </summary>
            public string playerId { get; set; }

            /// <summary>
            /// 保险柜原始密码
            /// </summary>
            public string safeOriginalPwd { get; set; }

            /// <summary>
            /// 保险柜新密码
            /// </summary>
            public string safePwd1 { get; set; }

            /// <summary>
            /// 保险柜确认新密码
            /// </summary>
            public string safePwd2 { get; set; }

        }

        [HttpPost]
        public Msg Post([FromBody] SafeModel model)
        {
            lock (this)
            {
                Msg msg1 = new Msg(10001, "修改保险柜密码错误！");
                try
                {
                    string playerId = model.playerId.Trim();
                    string safeOriginalPwd = model.safeOriginalPwd.Trim();
                    string safePwd1 = model.safePwd1.Trim();
                    string safePwd2 = model.safePwd2.Trim();
                    if (string.IsNullOrWhiteSpace(playerId))
                    {
                        msg1.content = "用户账号不能为空！";
                        return msg1;
                    }
                    if (string.IsNullOrWhiteSpace(safeOriginalPwd))
                    {
                        msg1.content = "保险柜原始密码不能为空！";
                        return msg1;
                    }
                    if (string.IsNullOrWhiteSpace(safePwd1))
                    {
                        msg1.content = "保险柜新密码不能为空！";
                        return msg1;
                    }
                    if (string.IsNullOrWhiteSpace(safePwd2))
                    {
                        msg1.content = "保险柜确认密码不能为空！";
                        return msg1;
                    }
                    if (safePwd1 != safePwd2)
                    {
                        msg1.content = "保险柜确认密码不正确！";
                        return msg1;
                    }
                    msg1 = new B_Users().updateSafePwd(new M_Users { ID = model.playerId,SAFE_PWD=model.safeOriginalPwd },safePwd2);
                 
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
