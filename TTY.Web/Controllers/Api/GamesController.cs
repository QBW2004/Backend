using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using YYT.BLL.EF;
using YYT.Common;
using YYT.Entity;

namespace YYT.Web.Controllers.Api
{
    public class GamesController : ApiController
    {
        /// <summary>
        /// 游戏类型
        /// </summary>
        /// <returns></returns>
        // GET: api/Games
        public IEnumerable<M_Games> Get()
        {
            List<M_Games> list = new List<M_Games>();
            try
            {
                // 获取所有游戏类型
                // M_Games entity = new M_Games { };
                // list = new B_Games().GetGames1(entity);

                // 获取所有启用的游戏类型
                M_Games entity = new M_Games { Enable = 1 };
                list = new B_Games().GetGames(entity);
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Controllers.Api.GamesController), ex);
            }
            return list;
        }
    }
}
