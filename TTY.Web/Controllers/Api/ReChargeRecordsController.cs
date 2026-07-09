using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Threading.Tasks;
using System.Web.Http;
using YYT.BLL.EF;
using YYT.Common;
using YYT.Entity;

namespace YYT.Web.Controllers.Api
{
  
    public class ReChargeRecordsController : ApiController
    {
        /// <summary>
        /// 游戏类型
        /// </summary>
        /// <returns></returns>
        // GET: api/Games
        public IEnumerable<M_ReChargeRecords> Get(string GameID)
        {
            List<M_ReChargeRecords> list = new List<M_ReChargeRecords>();
            try
            {
                M_ReChargeRecords entity = new M_ReChargeRecords { GameID=GameID};
                list = new B_ReChargeRecords().GetReChargeRecords(entity);
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Controllers.Api.GamesController), ex);
            }
            return list;
        }
    }
}
