using System.Collections.Generic;
using System.Threading.Tasks;
using System.Web.Http;
using YYT.BLL.EF;
using YYT.Entity;

namespace YYT.Web.Controllers.Api
{
    /// <summary>
    /// 收款人信息接口
    /// </summary>
    public class CashierController : ApiController
    {
        // GET: api/Cashier
        public async Task<List<M_Cashier>> Get()
        {
            return await new B_CashierInfo().GetCashierInfosAsync();
        }        
    }
}
