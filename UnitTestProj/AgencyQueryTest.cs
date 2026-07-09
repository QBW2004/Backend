using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using YYT.BLL.EF;
using YYT.Common;
using YYT.Entity;

namespace UnitTestProj
{
    [TestClass]
    public class AgencyQueryTest
    {

        [TestMethod]
        public void GetAgenciesBySupperMgrUsr()
        {
            // 超级管理员查询代理 及 管理员
            M_LoginUser loginUser = new M_LoginUser { UserPriv = 0 };
            List<M_Admin> rst = new B_Admin().GetAgenciesWithPermission(loginUser, null);
            Assert.AreNotEqual(rst.Count, 0);
        }


        [TestMethod]
        public void GetAgenciesBySupperAgencyUsr()
        {
            // 总代理 查询代理信息
            M_LoginUser loginUser = new M_LoginUser { UserPriv = 1, Accounts = "test1" };
            List<M_Admin> rst = new B_Admin().GetAgenciesWithPermission(loginUser, new M_Agency { Priv = loginUser.UserPriv.Value, ID = loginUser.Accounts });
            Assert.AreNotEqual(rst.Count, 0);
        }


        [TestMethod]
        public void GetAgenciesByGeneralAgencyUsr()
        {
            // 一般代理查询 代理
            M_LoginUser loginUser = new M_LoginUser { UserPriv = 2, Accounts = "test2" };
            List<M_Admin> rst = new B_Admin().GetAgenciesWithPermission(loginUser, new M_Agency { Priv = loginUser.UserPriv.Value, ID = loginUser.Accounts });
            Assert.AreEqual(rst.Count, 0);
        }


        [TestMethod]
        public void GetAgenciesByViceMgrUsr()
        {
            // 副管理查询代理
            M_LoginUser loginUser = new M_LoginUser { UserPriv = 9 };
            List<M_Admin> rst = new B_Admin().GetAgenciesWithPermission(loginUser, null);
            Assert.AreNotEqual(rst.Count, 0);
        }


        [TestMethod]
        public void GetAgenciesByDevUsr()
        {
            // 运维、开发查询代理
            M_LoginUser loginUser = new M_LoginUser { UserPriv = 10 };
            List<M_Admin> rst = new B_Admin().GetAgenciesWithPermission(loginUser, null);
            Assert.AreEqual(rst.Count, 0);
        }
    }
}
