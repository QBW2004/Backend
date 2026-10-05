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
                              UserID = a.UserID,
                              OPERATOR = a.OPERATOR
                          };
                    if (!string.IsNullOrWhiteSpace(entity.AGENCY))
                        rst = rst.Where(c => c.AGENCY.Equals(entity.AGENCY));
                }
                else
                {
                    // 控制类操作记录与「控制状态」同口径：特级代理限本线，其余代理仅能看到直属玩家的记录
                    int priv = loginUser.UserPriv ?? -1;
                    List<string> visibleAgencies = priv == AgencyRules.TopAgentPriv
                        ? new B_Admin().GetAgencyLineAccounts(ef, loginUser.Accounts)
                        : new List<string> { loginUser.Accounts };
                    rst = from a in ef.View_ManagerOpts
                          where visibleAgencies.Contains(a.AGENCY)
                          select new View_ManagerOpt_DTO
                          {
                              AGENCY = a.AGENCY,
                              NAME = a.NAME,
                              Opt = a.Opt,
                              OptValue = a.OptValue,
                              TIME = a.TIME,
                              Type = a.Type,
                              UserID = a.UserID,
                              OPERATOR = a.OPERATOR
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
