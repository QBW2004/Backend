using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.Http;
using YYT.BLL.EF;
using YYT.Common;
using YYT.Entity;

namespace YYT.Web.Controllers.Api
{
    public class AgencyController : ApiController
    {
        // api/Agency/{targetPriv}
        [Route("api/Agency/{targetPriv}")]
        public dynamic Get(int targetPriv)
        {
            List<M_Agency> list = new List<M_Agency>();
            try
            {
                M_LoginUser loginUser = WebHelper.GetLoginInfo();
                if (loginUser != null)
                {
                    B_Admin bll = new B_Admin();
                    List<M_Admin> rst;
                    using (var ef = new GameDbContext())
                    {
                        if (loginUser.UserPriv == 0)
                        {
                            rst = ef.Admins.Where(c => c.PRIV != 0).ToList();
                        }
                        else
                        {
                            List<string> managedAccounts = bll.GetManagedAgencyAccounts(ef, loginUser);
                            rst = ef.Admins
                                .Where(c => managedAccounts.Contains(c.ID) && c.ID != loginUser.Accounts)
                                .ToList();
                        }
                    }

                    if (targetPriv != 2 && loginUser.UserPriv != 2)
                        // 只查询目标类型代理
                        rst = rst.Where(c => c.PRIV == targetPriv).ToList();

                    // 转换结果
                    list = bll.AdminToAgencies(rst);
                }
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Controllers.Api.AgencyController), ex);
            }
            return list;
        }
    }
}
