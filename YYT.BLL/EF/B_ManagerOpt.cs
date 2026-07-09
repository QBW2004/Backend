using System.Collections.Generic;
using System.Linq;
using YYT.Entity;

namespace YYT.BLL.EF
{
    public class B_ManagerOpt
    {
        /// <summary>
        /// 清理全部点杀记录（仅超级管理员可操作）
        /// </summary>
        public int ClearRecords(M_LoginUser loginUser)
        {
            if (loginUser == null || loginUser.UserPriv != 0)
                return -1;

            using (var ef = new GameDbContext())
            {
                ef.Database.ExecuteSqlCommand("TRUNCATE TABLE `manageropt`");
                return 1;
            }
        }

        public int RemoveKillRecord(string userId)
        {
            using (var ef = new GameDbContext())
            {
                var rows = ef.ManagerOpts.Where(m => m.UserID == userId && (m.Opt == 1 || m.Opt == 3)).ToList();
                if (rows.Count < 1)
                    return 1;
                ef.ManagerOpts.RemoveRange(rows);
                return ef.SaveChanges();
            }
        }


        public M_EasyuiGridData<View_ManagerOpt_DTO> GetUsersListWithPermission(M_Page mPage, M_Users entity, M_LoginUser loginUser)
        {
            M_EasyuiGridData<View_ManagerOpt_DTO> list = new M_EasyuiGridData<View_ManagerOpt_DTO>();
            if (loginUser == null)
                return list;

            using (var ef = new GameDbContext())
            {
                B_Records_MySQL.CleanupExpiredRecords(ef);
                // 点杀记录
                IEnumerable<View_ManagerOpt_DTO> rst = null;

                // 针对非超级管理员，加权限查询
                if (loginUser.UserPriv == 0)
                {
                    rst = from a in ef.View_ManagerOpts
                          select new View_ManagerOpt_DTO
                          {
                              AGENCY = a.AGENCY,
                              NAME = a.NAME,
                              Opt = a.Opt,
                              OptValue = a.OptValue,
                              TIME = a.TIME,
                              Type = a.Type,
                              UserID = a.UserID
                          };
                    if (!string.IsNullOrWhiteSpace(entity.AGENCY))
                        rst = rst.Where(c => c.AGENCY.Equals(entity.AGENCY));
                }
                else
                {

                    // 查询权限内的所有用户
                    rst = from a in ef.View_ManagerOpts
                          where a.AGENCY.Equals(loginUser.Accounts)
                          select new View_ManagerOpt_DTO
                          {
                              AGENCY = a.AGENCY,
                              NAME = a.NAME,
                              Opt = a.Opt,
                              OptValue = a.OptValue,
                              TIME = a.TIME,
                              Type = a.Type,
                              UserID = a.UserID
                          };

                    if (rst == null || rst.Count() < 1)
                        return list;
                }

                if (!string.IsNullOrWhiteSpace(entity.ID))
                    rst = rst.Where(c => c.UserID.Equals(entity.ID));

                // 分页
                if (rst != null)
                {
                    mPage.SetTotalCount(rst.Count());
                    var users = rst
                        .OrderByDescending(c => c.TIME)
                        .ThenBy(c => c.UserID)
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
