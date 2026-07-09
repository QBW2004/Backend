using System.Collections.Generic;
using System.Linq;
using YYT.BLL.EF;
using YYT.Common;
using YYT.Entity;

namespace YYT.BLL.EF
{
    public class B_PlatType
    {
        public List<M_PlatType> GetPlatType(M_PlatType entity)
        {
            using (var ef = new GameDbContext())
            {
                IQueryable<M_PlatType> games = null;
                var rst = ef.PlatTypes;

                if (entity.Enable)
                    games = rst.Where(c => c.Enable == entity.Enable);
                else
                    rst.ToList();

                return games.ToList();
            }
        }
        public M_PlatType GetType(M_PlatType entity)
        {
            using (var ef = new GameDbContext())
            {
                entity = ef.PlatTypes.Where(c => c.ID.Equals(entity.ID)).SingleOrDefault();
                return entity;
            }
        }
        public M_EasyuiGridData<M_PlatType> GetPlatType(M_LoginUser loginUser, M_Page mPage, M_PlatType entity)
        {
            M_EasyuiGridData<M_PlatType> list = new M_EasyuiGridData<M_PlatType>();
            using (var ef = new GameDbContext())
            {
                IEnumerable<M_PlatType> rst = ef.PlatTypes;
                if (!string.IsNullOrWhiteSpace(entity.Name))
                    rst = rst.Where(c => c.Name.Equals(entity.Name));
                // 加权限查询
                //if (loginUser.UserPriv != 0)
                //{
                //    rst = rst.Where(c => c.Agency.Equals(loginUser.Accounts));
                //}

                // 分页
                if (rst != null)
                {
                    mPage.SetTotalCount(rst.Count());
                    var users = rst.AsEnumerable()
                        .OrderByDescending(c => c.ID)
                        .Skip(mPage.PageSize * (mPage.PageIndex - 1)).Take(mPage.PageSize)
                        .ToList();
                    list.rows = users;
                    list.total = mPage.TotalCount;
                }
            }
            return list;
        }

        public int EnablePlatType(M_PlatType entity)
        {
            using (var ef = new GameDbContext())
            {
                var usr = ef.PlatTypes.Where(c => c.ID.Equals(entity.ID)).FirstOrDefault();
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
    }
}
