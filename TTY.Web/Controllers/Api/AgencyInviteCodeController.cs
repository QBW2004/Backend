using System;
using System.Web.Http;
using YYT.BLL.EF;
using YYT.Common;
using YYT.Entity;

namespace YYT.Web.Controllers.Api
{
    /// <summary>
    /// 客户端个人面板：玩家所属代理的邀请码。
    /// 邀请码是代理的属性（admin.InviteCode），玩家只是注册时使用它的一方：
    /// 新玩家在注册页填这个码，服务端按 admin.InviteCode 反查归属代理写进 users.AGENCY。
    /// 所以这里下发的是"该玩家注册时用的码 → 回退其所属代理的码"，与手机端玩家详情页同口径
    /// （见 B_Users.GetUserPhoneDetail / B_Users.GetPlayerInviteCode）。
    /// 只下发邀请码本身，不下发代理账号，避免把代理账号体系暴露给客户端。
    /// </summary>
    public class AgencyInviteCodeController : ApiController
    {
        public class InviteCodeModel
        {
            /// <summary>
            /// 玩家账号
            /// </summary>
            public string playerId { get; set; }
        }

        public class ReturnModel
        {
            /// <summary>
            /// 邀请码；为空表示该玩家没有可展示的邀请码（如挂在总台 atmadmin 名下），客户端显示占位符
            /// </summary>
            public string InviteCode { get; set; }
        }

        [HttpPost]
        public Msg Post([FromBody] InviteCodeModel model)
        {
            Msg msg = new Msg(10001, "查询失败！");
            try
            {
                if (model == null || string.IsNullOrWhiteSpace(model.playerId))
                {
                    msg.content = "用户账号不能为空！";
                    return msg;
                }

                string playerId = model.playerId.Trim();
                if (new B_Users().GetSingle(new M_Users { ID = playerId }) == null)
                {
                    msg.content = "用户账号不存在！";
                    return msg;
                }

                msg.code = 10000;
                msg.content = "查询成功！";
                msg.datas = new ReturnModel
                {
                    InviteCode = new B_Users().GetPlayerInviteCode(playerId)
                };
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(AgencyInviteCodeController), ex);
                msg.content = ex.Message;
            }
            return msg;
        }
    }
}
