using System.Collections.Generic;
using System.Linq;
using YYT.Entity;

namespace YYT.BLL.EF
{
    /// <summary>
    /// 针对超级用户   PRIV为0的
    /// </summary>
    public class TypeZeroAdmin : IAgencyQuery
    {
        public List<M_Admin> GetAgencies(M_Agency entity)
        {
            List<M_Admin> list = new List<M_Admin>();

            using (var ef = new GameDbContext())
            {
                if (entity != null)
                {
                    if (!string.IsNullOrWhiteSpace(entity.Agency))
                        list = ef.Admins.Where(c => c.PRIV > entity.Priv && c.AGENCY.Equals(entity.Agency)).ToList();
                    else
                        list = ef.Admins.Where(c => c.PRIV > entity.Priv).ToList();
                }
                else
                {
                    list = ef.Admins.Where(c => c.PRIV != 0).ToList();
                }
                return list;
            }
        }
    }
}
