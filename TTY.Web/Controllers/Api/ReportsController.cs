using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Threading.Tasks;
using System.Web.Http;
using YYT.BLL.EF;
using YYT.Common;
using YYT.Entity;

namespace YYT.Web.Controllers
{
    public class ReportsController : ApiController
    {
        // GET: api/Reports
        public Msg Get()
        {
            Msg msg = new Msg(0,"获取失败！");
            try
            {
                M_LoginUser loginUser = WebHelper.GetLoginInfo();
                if (loginUser != null)
                {
                    msg.code = 1;
                    msg.content = "获取成功！";
                    msg.datas = new B_Reports(loginUser).GetReports();
                }
                else
                {
                    msg.code = (int)EServerData.Login_Time_Out;
                    msg.content = "登录超时，请重新登录！";
                }
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Controllers.ReportsController), ex);
            }
            return msg;
        }
    }
}
