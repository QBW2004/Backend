using System.Collections.Generic;
using System.Linq;
using YYT.Entity;

namespace YYT.BLL.EF
{
    /// <summary>
    /// 针对PRIV 代理层级为9的
    /// </summary>
    public class TypeNineAdmin : IAgencyQuery
    {
        public List<M_Admin> GetAgencies(M_Agency entity)
        {
            List<M_Admin> list = new List<M_Admin>();
            using (var ef = new GameDbContext())
            {
                if (entity != null)
                {
                    if (!string.IsNullOrWhiteSpace(entity.Agency))
                        list = ef.Admins.Where(c => c.PRIV > 0 && c.PRIV < 9 && c.AGENCY.Equals(entity.Agency)).ToList();
                }
                else
                {
                    list = ef.Admins.Where(c => c.PRIV > 0 && c.PRIV < 9).ToList();
                }
                return list;
            }
        }
    }
}
