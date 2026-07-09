using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using YYT.Remote;

namespace UnitTestProj
{
    [TestClass]
    public class ServerTest
    {
        [TestMethod]
        public void LockUser()
        {
            // 锁定用户  指令内容：UL + 充值0/兑换1 + 操作结果失败0/成功1 + 玩家账号
            var srv = new SConnect();
            var tmpMsg = srv.SendReadString(EScMsgType.LK, 0, 0, "123456");
            Assert.AreEqual(tmpMsg.code > -1, true);
        }

        [TestMethod]
        public void UnLockUser()
        {
            // 锁定用户  指令内容：UL + 玩家账号
            var srv = new SConnect();
            var tmpMsg = srv.SendReadString(EScMsgType.UL, "123456");
            Assert.AreEqual(tmpMsg.code > -1, true);
        }

    }
}
