using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using YYT.BLL.EF;
using YYT.Entity;

namespace YYT.Web.Controllers.Api
{
    [RoutePrefix("api/RankingList")]
    public class RankingListController : ApiController
    {
        /// <summary>
        /// 游戏类型
        /// </summary>
        /// <returns></returns>
        // GET: api/Games
        public IEnumerable<RankUsersList> Get()
        {
            List<RankUsersList> list = new List<RankUsersList>();
            try
            {
                list = new B_Users().GetRankingUserList();
            }
            catch (Exception ex)
            {
            }
            return list;
        }
    }
}
