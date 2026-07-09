using Microsoft.AspNet.SignalR;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace YYT.Web.Models
{
    public class ChatService
    {
        public IHubContext Hub => GlobalHost.ConnectionManager.GetHubContext<MessageHub>();
        public static IList<ChatUser> ChatUsers = new List<ChatUser>();

        /// <summary>
        /// 通知某个人
        /// 对应前端
        /// </summary>
        /// <param name="toContextID">连接ID</param>
        /// <param name="msg"></param>
        public void NotifyTo(string toContextID, string msg)
        {
            Hub.Clients.Client(toContextID).showNotify(msg);
        }
        /// <summary>
        /// 通知所有人
        /// </summary>
        /// <param name="msg"></param>
        public void NotifyAll(string msg)
        {
            Hub.Clients.All.showNotify(msg);
        }
    }
}