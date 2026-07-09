using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNet.SignalR;
using YYT.Common;
using YYT.Entity;

namespace YYT.Web.Models
{
    public class MessageHub : Hub
    {
        public static List<ChatUser> ChatUsers = new List<ChatUser>();

        #region 重写Hub事件
        public override Task OnConnected()
        {
            var user = MessageHub.ChatUsers.SingleOrDefault(u => u.ContextID == Context.ConnectionId);
            if (user == null)
            {
                user = new ChatUser { ContextID = Context.ConnectionId, Name = string.Empty };
                MessageHub.ChatUsers.Add(user);
            }

            return base.OnConnected();
        }
        public override Task OnDisconnected(bool stopCalled)
        {
            var user = MessageHub.ChatUsers.SingleOrDefault(u => u.ContextID == Context.ConnectionId);
            if (user != null)
            {
                MessageHub.ChatUsers.Remove(user);
            }

            return base.OnDisconnected(stopCalled);
        }
        public override Task OnReconnected()
        {
            return base.OnReconnected();
        } 
        #endregion

        #region 服务器提供给前端调用的接口
        /// <summary>
        /// 发送消息到指定用户
        /// </summary>
        /// <param name="account">用户账号</param>
        /// <param name="message">消息内容</param>
        public void SendMessageTo(string account, string message)
        {
            var user = MessageHub.ChatUsers.SingleOrDefault(u => u.Name.Equals(account));
            if (user != null)
            {
                Clients.Client(user.ContextID).showNotify(message);
            }
        }

        /// <summary>
        /// 告诉服务器自己的账号
        /// </summary>
        /// <param name="account">用户账号</param>
        public void SelfIntroduction(string account)
        {
            var user = MessageHub.ChatUsers.SingleOrDefault(u => u.ContextID == Context.ConnectionId);
            if (user != null)
            {
                user.Name = account;
                Clients.Client(Context.ConnectionId).showID(Context.ConnectionId);
            }
        } 
        #endregion
    }
}