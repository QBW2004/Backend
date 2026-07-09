using System.Linq;
using YYT.Entity;

namespace YYT.BLL.EF
{
    public class B_GameRecords
    {
        /// <summary>
        /// 清理全部桌子账目记录（仅超级管理员）
        /// </summary>
        public int ClearTableCoinRecords(M_LoginUser loginUser)
        {
            if (loginUser == null || loginUser.UserPriv != 0)
                return -1;
            using (var ef = new GameDbContext())
            {
                ef.Database.ExecuteSqlCommand("TRUNCATE TABLE `TableCoinRecord`");
                return 1;
            }
        }

        public M_EasyuiGridData<M_TableCoinRecord_DTO> GetTableCoinRecord(M_Page mPage, M_TableCoinRecord entity)
        {
            M_EasyuiGridData<M_TableCoinRecord_DTO> list = new M_EasyuiGridData<M_TableCoinRecord_DTO>();
            using (var ef = new GameDbContext())
            {
                B_Records_MySQL.CleanupExpiredRecords(ef);
                var rst = from a in ef.TableCoinRecords
                          join b in ef.Games on a.GameID equals b.GameId
                          select new M_TableCoinRecord_DTO
                          {
                              RecIndex = a.RecIndex,
                              GameID = a.GameID,
                              RoomID = a.RoomID,
                              TableID = a.TableID,
                              Coins = a.Coins,
                              CreateTime = a.CreateTime,
                              GameName = b.Name
                          };

                if (entity.GameID > -1)
                    rst = rst.Where(c => c.GameID == entity.GameID);
                if (entity.RoomID > -1)
                    rst = rst.Where(c => c.RoomID == entity.RoomID);
                if (entity.TableID > -1)
                    rst = rst.Where(c => c.TableID == entity.TableID);

                mPage.SetTotalCount(rst.Count());
                list.rows = rst
                    .OrderByDescending(c => c.CreateTime)
                    .ThenBy(c => c.GameID)
                    .ThenBy(c => c.RoomID)
                    .ThenBy(c => c.TableID)
                    .Skip(mPage.PageSize * (mPage.PageIndex - 1))
                    .Take(mPage.PageSize)
                    .ToList();
                list.total = mPage.TotalCount;
            }
            return list;
        }
    }
}
