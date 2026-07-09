using System;
using System.Threading.Tasks;
using YYT.Common;
using YYT.Entity;

namespace YYT.BLL.EF
{
    public class B_AgencyOptLog
    {
        public void AddAgencyOptLog(M_AgencyOptLog entity)
        {
            using (var ef = new GameDbContext())
            {
                ef.AgencyOptLogs.Add(entity);
                ef.SaveChangesAsync();
            }
        }
        public Msg AddAgencyOptLog(GameDbContext ef, M_AgencyOptLog entity)
        {
            ef.AgencyOptLogs.Add(entity);
            if (ef.SaveChanges() > 0)
                return new Msg(1, "添加成功！");
            return new Msg(0, "添加失败！");
        }
    }
}
