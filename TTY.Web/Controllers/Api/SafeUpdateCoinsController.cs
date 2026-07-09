using System;
using System.Web.Http;
using YYT.BLL.EF;
using YYT.Entity;

namespace YYT.Web.Controllers.Api
{
  
    public class SafeUpdateCoinsController : ApiController
    {

        public class SafeModel
        {
            /// <summary>
            /// 玩家账号
            /// </summary>
            public string playerId { get; set; }
            /// <summary>
            /// 0取出、1存储
            /// </summary>
            public int type { get; set; }
            /// <summary>
            /// 取出、存储金币
            /// </summary>
            public int coins { get; set; }
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
                Msg msg1 = new Msg(10001, "接口错误！");
                try
                {
                    string playerId = model.playerId.Trim();
                    long? coins =Convert.ToInt64(model.coins);
                    int type = model.type;
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
                    if (model.coins <= 0)
                    {
                        msg1.content = "请输入正确的金额！";
                        return msg1;
                    }
                    msg1 = new B_Users().updateSafeCoins(new M_Users { ID = model.playerId,SAFE_PWD=model.safePwd }, type, coins);
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
