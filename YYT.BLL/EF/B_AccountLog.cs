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
    public class B_AccountLog
    {
        public void AddAccountLog(M_AccountLog entity)
        {
            using (var ef = new GameDbContext())
            {
                ef.AccountLogs.Add(entity);
                ef.SaveChangesAsync();
            }
        }
        public Msg AddAccountLog(GameDbContext ef, M_AccountLog entity)
        {
            try
            {
                entity.IP = "127.0.0.1";
                ef.AccountLogs.Add(entity);

                if (ef.SaveChanges() > 0)
                    return new Msg(1, "添加成功！");
                return new Msg(0, "添加失败！");
            }
            catch(Exception ex)
            {
                return new Msg(0, "添加失败！"+ex.Message);
            }

        }
        public M_EasyuiGridData<M_AccountLog> GetAccountLogs(M_LoginUser loginUser, M_Page mPage, M_AccountLog entity)
        {
            M_EasyuiGridData<M_AccountLog> list = new M_EasyuiGridData<M_AccountLog>();
            using (var ef = new GameDbContext())
            {
                IEnumerable<M_AccountLog> rst = ef.AccountLogs;
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
