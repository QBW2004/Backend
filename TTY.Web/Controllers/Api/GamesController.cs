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
        public IEnumerable<M_Games> Get(string account = null)
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

                // 新包登录后带上玩家账号：只返回玩家所在代理线可玩的游戏；不带账号（老包、未登录）照旧返回全部
                if (!string.IsNullOrWhiteSpace(account) && list != null)
                {
                    using (var ef = new GameDbContext())
                    {
                        List<int> playable = LineScopeRules.GetPlayableGamesOfPlayer(ef, account.Trim());
                        if (playable != null)
                            list = list.Where(g => playable.Contains(g.GameId)).ToList();
                    }
                }
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Controllers.Api.GamesController), ex);
            }
            return list;
        }
    }
}
