using System.Collections.Generic;
using YYT.Entity;

namespace YYT.BLL.EF
{
    public interface IAgencyQuery
    {
        List<M_Admin> GetAgencies(M_Agency entity);
    }
}
