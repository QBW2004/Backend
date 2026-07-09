using System.Collections.Generic;
using System.Linq;
using YYT.Entity;

namespace YYT.BLL.EF
{
    /// <summary>
    /// 针对普通代理   PRIV > 1 AND PRIV < 9
    /// </summary>
    public class TypeGeneralAdmin : IAgencyQuery
    {
        public List<M_Admin> GetAgencies(M_Agency entity)
        {
            List<M_Admin> list = new List<M_Admin>();
            using (var ef = new GameDbContext())
            {
                if (entity != null && !string.IsNullOrWhiteSpace(entity.ID))
                    list = ef.Admins.Where(c => c.PRIV > entity.Priv && c.AGENCY.Equals(entity.ID)).ToList();
            }
            return list;
        }
    }
}
