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
            // 必须同步保存：原来在 using 内调用未 await 的 SaveChangesAsync，
            // context 先被 Dispose，异步写入静默失败（禁用/退出日志曾一直丢失）。
            using (var ef = new GameDbContext())
            {
                ef.AgencyOptLogs.Add(entity);
                ef.SaveChanges();
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
