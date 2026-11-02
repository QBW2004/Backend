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

            /// <summary>
            /// 登录密码（必填，校验 users.PWD；该接口此前无任何鉴权，匿名可改任意玩家昵称）
            /// </summary>
            public string pwd { get; set; }

        }

        /// <summary>进入大厅后查询，密码只从 POST 请求体接收，不进 URL 或响应。</summary>
        [HttpPost]
        [Route("api/UpdateUsers/NicknameStatus")]
        public Msg NicknameStatus([FromBody] UsersModel model)
        {
            if (model == null || string.IsNullOrWhiteSpace(model.playerId) || string.IsNullOrWhiteSpace(model.pwd))
                return new Msg(10001, "账号或密码错误！");
            try
            {
                var state = new B_Users().GetNicknameState(model.playerId.Trim(), model.pwd.Trim());
                if (state == null) return new Msg(10001, "账号或密码错误！");
                return new Msg(10000, "查询成功")
                {
                    datas = new { name = state.Name, nicknameSet = state.NicknameSet == 1 }
                };
            }
            catch (Exception)
            {
                // 未升级数据库或暂时断库时不能伪造“已设置”，客户端稍后重试。
                return new Msg(10001, "昵称状态查询失败，请稍后重试！");
            }
        }

        [HttpPost]
        public Msg Post([FromBody] UsersModel model)
        {
            lock (this)
            {
                Msg msg1 = new Msg(10001, "Sửa đổi thất bại（修改失败）！");
                try
                {
                    string playerId = model == null || model.playerId == null ? "" : model.playerId.Trim();
                    string name = model == null || model.name == null ? "" : model.name.Trim();
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
                    if (name.Length > 8)
                        return new Msg(10001, "昵称长度不能超过8位！");
                    foreach (char c in name)
                        if (c != ' ' && !char.IsLetterOrDigit(c))
                            return new Msg(10001, "昵称不允许包含特殊符号！");
                    // 鉴权：必须带玩家登录密码
                    M_Users authUser = new B_Users().GetSingle(new M_Users { ID = playerId });
                    if (authUser == null || string.IsNullOrWhiteSpace(model.pwd) || authUser.PWD != model.pwd.Trim())
                    {
                        msg1.content = "账号或密码错误！";
                        return msg1;
                    }
                    msg1 = new B_Users().updateUsersName(new M_Users { ID = playerId, NAME = name, PWD = model.pwd.Trim() });
                    if (msg1.code == 10000)
                        msg1.datas = new { playerId = playerId, name = name, nicknameSet = true };
                 
                }
                catch (Exception)
                {
                    msg1.content = "昵称保存失败，请稍后重试！";
                }
                return msg1;
            }
        }
    }
}
