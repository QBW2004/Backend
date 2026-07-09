using System;
using System.Data.Entity.Validation;
using System.Web.Http;
using YYT.BLL.EF;
using YYT.Entity;

namespace YYT.Web.Controllers.Api
{
  
    public class UpdateUsersController : ApiController
    {

        public class UsersModel
        {
            /// <summary>
            /// 玩家账号
            /// </summary>
            public string playerId { get; set; }

            /// <summary>
            /// 用户昵称
            /// </summary>
            public string name { get; set; }

        }

        [HttpPost]
        public Msg Post([FromBody] UsersModel model)
        {
            lock (this)
            {
                Msg msg1 = new Msg(10001, "Sửa đổi thất bại（修改失败）！");
                try
                {
                    string playerId = model.playerId.Trim();
                    string name = model.name.Trim();
                    if (string.IsNullOrWhiteSpace(playerId))
                    {
                        msg1.content = "Tài khoản người dùng không được để trống（用户账号不能为空）！";
                        return msg1;
                    }
                    if (string.IsNullOrWhiteSpace(name))
                    {
                        msg1.content = "Tên người dùng không được để trống（用户昵称不能为空）！";
                        return msg1;
                    }
                    msg1 = new B_Users().updateUsersName(new M_Users { ID = model.playerId,NAME=model.name });
                    msg1.datas = model;
                 
                }
                catch (Exception ex)
                {
                    msg1.content = ex.Message;
                }
                return msg1;
            }
        }
    }
}
