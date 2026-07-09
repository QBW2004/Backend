using System.Collections.Generic;
using System.Linq;
using YYT.BLL.EF;
using YYT.Common;
using YYT.Entity;

namespace YYT.BLL.EF
{
    public class B_Games
    {
        
        public List<M_Games> GetGames(M_Games entity)
        {
            using (var ef = new GameDbContext())
            {
                IQueryable<M_Games> games = null;
                var rst = ef.Games;

                if (entity.Enable.HasValue)
                    games = rst.Where(c => c.Enable == entity.Enable);
                else
                    games = (IQueryable<M_Games>)rst.ToList();

                return games.ToList();
            }
        }

        public List<M_Games> GetGames1(M_Games entity)
        {
            M_EasyuiGridData<M_Games> list = new M_EasyuiGridData<M_Games>();
            using (var ef = new GameDbContext())
            {
                var rst = ef.Games.ToList();
                list.rows = rst;
                list.total = rst.Count;
            }
            return list.rows;
        }

        public M_EasyuiGridData<M_Games> GetGames(M_Page mPage, M_Games entity)
        {
            M_EasyuiGridData<M_Games> list = new M_EasyuiGridData<M_Games>();
            using (var ef = new GameDbContext())
            {
                IEnumerable<M_Games> rst = ef.Games;
                if (!string.IsNullOrWhiteSpace(entity.Name))
                    rst = rst.Where(c => c.Name.Contains(entity.Name));
                if (entity.GameType >= 0)
                    rst = rst.Where(c => c.GameType.Equals(entity.GameType));
                // 分页
                if (rst != null)
                {
                    mPage.SetTotalCount(rst.Count());
                    var users = rst.AsEnumerable()
                        .OrderByDescending(c => c.GameType)
                        .Skip(mPage.PageSize * (mPage.PageIndex - 1)).Take(mPage.PageSize)
                        .ToList();
                    list.rows = users;
                    list.total = mPage.TotalCount;
                }
            }
            return list;
        }

        public int EnableGames(M_Games entity)
        {
            using (var ef = new GameDbContext())
            {
                var usr = ef.Games.Where(c => c.GameId.Equals(entity.GameId)).FirstOrDefault();
                if (usr != null)
                {
                    if (usr.Enable.Equals(entity.Enable))
                        return 1;
                    usr.Enable = entity.Enable;
                    return ef.SaveChanges();
                }
            }
            return 0;
        }


        public List<M_TreeModel> GetGamesTreeData(M_Games entity)
        {
            List<M_TreeModel> rstList = new List<M_TreeModel>();
            List<M_Games> gameList = GetGames(entity);
            string[] arr = { "下注类型", "牌机类型", "鱼机类型", "街机类型" };
            List<M_TreeModel> childrens = new List<M_TreeModel>();
            for (int i = 0; i < arr.Length; i++)
            {
                childrens = ToTreeModel(gameList, i);
                if (childrens.Count > 0)
                {
                    rstList.Add(new M_TreeModel
                    {
                        id = i,
                        text = arr[i],
                        iconCls = "icon-folder",
                        state = i == 0 ? "open" : "closed",
                        children = childrens
                    });
                }
            }
            return rstList;
        }
        public M_Games GetSingle(M_Games entity)
        {
            using (var ef = new GameDbContext())
            {
                return ef.Games.Find(entity.GameId);
            }
        }
        private List<M_TreeModel> ToTreeModel(List<M_Games> list, int gameType)
        {
            return list.AsEnumerable()
                .Where(c => c.GameType == gameType)
                .Select(c => new M_TreeModel { id = c.GameId, text = c.Name, attributes = new { GameType = gameType } })
                .ToList();
        }
    }
}
