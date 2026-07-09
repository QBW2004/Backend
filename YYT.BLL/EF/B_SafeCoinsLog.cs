using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using YYT.Common;
using YYT.Entity;
using YYT.Remote;

namespace YYT.BLL.EF
{
    public class B_SafeCoinsLog
    {
        public void AddSafeCoinsLog(M_SafeCoinsLog entity)
        {
            using (var ef = new GameDbContext())
            {
                ef.safeCoinsLogs.Add(entity);
                ef.SaveChangesAsync();
            }
        }
        public Msg AddSafeCoinsLog(GameDbContext ef, M_SafeCoinsLog entity)
        {
            ef.safeCoinsLogs.Add(entity);
            if (ef.SaveChanges() > 0)
                return new Msg(1, "添加成功！");
            return new Msg(0, "添加失败！");
        }
        public M_EasyuiGridData<M_SafeCoinsLog> GetSafeCoinsLog(M_Page mPage, M_SafeCoinsLog entity)
        {
            M_EasyuiGridData<M_SafeCoinsLog> list = new M_EasyuiGridData<M_SafeCoinsLog>();
            using (var ef = new GameDbContext())
            {
                IEnumerable<M_SafeCoinsLog> rst = ef.safeCoinsLogs;
                if (!string.IsNullOrWhiteSpace(entity.User_Id))
                    rst = rst.Where(c => c.User_Id.Equals(entity.User_Id));
                // 分页
                if (rst != null)
                {
                    mPage.SetTotalCount(rst.Count());
                    var users = rst.AsEnumerable()
                        .OrderByDescending(c => c.Create_Time)
                        .Skip(mPage.PageSize * (mPage.PageIndex - 1)).Take(mPage.PageSize)
                        .ToList();
                    list.rows = users;
                    list.total = mPage.TotalCount;
                }
            }
            return list;
        }
    }
}
