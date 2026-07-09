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
    public class B_TransferLog
    {
        public void AddTransferLog(M_TransferLog entity)
        {
            using (var ef = new GameDbContext())
            {
                ef.TransferLogs.Add(entity);
                ef.SaveChangesAsync();
            }
        }
        public Msg AddTransferLog(GameDbContext ef, M_TransferLog entity)
        {
            ef.TransferLogs.Add(entity);
            if (ef.SaveChanges() > 0)
                return new Msg(1, "添加成功！");
            return new Msg(0, "添加失败！");
        }
        public M_EasyuiGridData<M_TransferLog> GetTransferLogs(M_LoginUser loginUser, M_Page mPage, M_TransferLog entity)
        {
            M_EasyuiGridData<M_TransferLog> list = new M_EasyuiGridData<M_TransferLog>();
            using (var ef = new GameDbContext())
            {
                IEnumerable<M_TransferLog> rst = ef.TransferLogs;
                if (!string.IsNullOrWhiteSpace(entity.UserName))
                    rst = rst.Where(c => c.UserName.Equals(entity.UserName));
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
                        .OrderByDescending(c => c.CreateTime)
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
