using System;
using System.Collections.Generic;
using System.Linq;
using YYT.Common;
using YYT.Entity;

namespace YYT.BLL.EF
{
    public class B_Records_MySQL : B_SuperRecords
    {
        public B_Records_MySQL() : base(EDbProviderType.MySql) { }

        public static DateTime GetRetentionCutoff()
        {
            return DateTime.Now.AddDays(-7);
        }

        public static void CleanupExpiredRecords(GameDbContext ef)
        {
            DateTime cutoff = GetRetentionCutoff();
            ef.Database.ExecuteSqlCommand("DELETE FROM `ReChargeRecords` WHERE `CreateTime` < @p0", cutoff);
            ef.Database.ExecuteSqlCommand("DELETE FROM `AgencyOptLog` WHERE `REC_TIME` < @p0", cutoff);
            ef.Database.ExecuteSqlCommand("DELETE FROM `UserOptLog` WHERE `REC_TIME` < @p0", cutoff);
            ef.Database.ExecuteSqlCommand("DELETE FROM `TableCoinRecord` WHERE `CreateTime` < @p0", cutoff);
            ef.Database.ExecuteSqlCommand("DELETE FROM `manageropt` WHERE `TIME` < @p0", cutoff);
            ef.Database.ExecuteSqlCommand("DELETE FROM `clientexchangerecord` WHERE `CreateTime` < @p0", cutoff);
        }

        /// <summary>
        /// 清理代理记录（仅超级管理员）
        /// </summary>
        public int ClearAgencyRecords(M_LoginUser loginUser)
        {
            if (loginUser == null || loginUser.UserPriv != 0)
                return -1;
            using (var ef = new GameDbContext())
            {
                ef.Database.ExecuteSqlCommand("TRUNCATE TABLE `AgencyOptLog`");
                return 1;
            }
        }

        /// <summary>
        /// 清理玩家记录（仅超级管理员）
        /// </summary>
        public int ClearPlayerRecords(M_LoginUser loginUser)
        {
            if (loginUser == null || loginUser.UserPriv != 0)
                return -1;
            using (var ef = new GameDbContext())
            {
                ef.Database.ExecuteSqlCommand("TRUNCATE TABLE `UserOptLog`");
                return 1;
            }
        }

        public override dynamic Get_AgencyRecords(M_LoginUser loginUser, M_Page mPage, dynamic queryEntity)
        {
            M_EasyuiGridData<M_AgencyOptLog> list = new M_EasyuiGridData<M_AgencyOptLog>();
            using (var ef = new GameDbContext())
            {
                CleanupExpiredRecords(ef);
                M_S_Record queryPara = queryEntity;
                var rst = from a in ef.AgencyOptLogs.AsEnumerable()
                          join b in ef.Admins on a.OptID equals b.ID
                          select new M_AgencyOptLog
                          {
                              LID = a.LID,
                              OptID = a.OptID,
                              ID = a.ID,
                              SrcUserTitle = a.SrcUserTitle,
                              DestUserTitle = a.DestUserTitle,
                              AGENCY = b.AGENCY,
                              REC_TIME = a.REC_TIME,
                              OPT = a.OPT,
                              COINS = a.COINS,
                              BEF_COINS = a.BEF_COINS,
                              AFT_COINS = a.AFT_COINS,
                              WEEK = a.WEEK
                          };

                if (!string.IsNullOrWhiteSpace(queryPara.ID))
                    rst = rst.Where(c => c.ID.Equals(queryPara.ID) || c.OptID.Equals(queryPara.ID));
                if (queryPara.S_TIME > DateTime.MinValue)
                {
                    DateTime begin = queryPara.S_TIME.Date;
                    DateTime end = begin.AddDays(1);
                    rst = rst.Where(c => c.REC_TIME >= begin && c.REC_TIME < end);
                }
                if (queryPara.OPT > -1)
                    rst = rst.Where(c => c.OPT == queryPara.OPT);
                if (!string.IsNullOrWhiteSpace(queryPara.AGENCY))
                    rst = rst.Where(c => c.AGENCY.Equals(queryPara.AGENCY));

                if (loginUser.UserPriv != 0)
                {
                    rst = rst.Where(c => c.AGENCY.Equals(loginUser.Accounts) || c.OptID.Equals(loginUser.Accounts));
                }

                if (rst != null)
                {
                    mPage.SetTotalCount(rst.Count());
                    var agencies = rst
                        .OrderByDescending(c => c.LID)
                        .Skip(mPage.PageSize * (mPage.PageIndex - 1)).Take(mPage.PageSize)
                        .ToList();
                    list.rows = agencies;
                    list.total = mPage.TotalCount;
                }
            }
            return list;
        }

        public override dynamic Get_PlayerRecords(M_LoginUser loginUser, M_Page mPage, dynamic queryEntity)
        {
            M_EasyuiGridData<M_UserOptLog> list = new M_EasyuiGridData<M_UserOptLog>();
            using (var ef = new GameDbContext())
            {
                CleanupExpiredRecords(ef);
                M_S_Record queryPara = queryEntity;
                var rst = from a in ef.UserOptLogs.AsEnumerable()
                          join b in ef.Users on a.UserID equals b.ID
                          join c in ef.Games on a.GAME_TYPE equals c.GameId into r
                          from g in r.DefaultIfEmpty()
                          select new M_UserOptLog
                          {
                              LID = a.LID,
                              UserID = a.UserID,
                              AGENCY = b?.AGENCY,
                              OPT = a.OPT,
                              OPT_COINS = a.OPT_COINS,
                              COINS = a.COINS,
                              SCORE = a.SCORE,
                              ROOM = a.ROOM,
                              TABLE_ID = a.TABLE_ID,
                              SEAT_ID = a.SEAT_ID,
                              GameName = g?.Name,
                              GAME_TYPE = a.GAME_TYPE,
                              REC_TIME = a.REC_TIME,
                              REC_WEEK = a.REC_WEEK
                          };

                if (!string.IsNullOrWhiteSpace(queryPara.ID))
                    rst = rst.Where(c => c.UserID.Equals(queryPara.ID));
                if (queryPara.S_TIME > DateTime.MinValue)
                {
                    DateTime begin = queryPara.S_TIME.Date;
                    DateTime end = begin.AddDays(1);
                    rst = rst.Where(c => c.REC_TIME >= begin && c.REC_TIME < end);
                }

                if (loginUser.UserPriv != 0)
                {
                    rst = rst.Where(c => c.AGENCY.Equals(loginUser.Accounts));
                }

                if (rst != null)
                {
                    List<M_UserOptLog> all = rst.ToList();
                    FillEnterLeave(all);
                    mPage.SetTotalCount(all.Count);
                    var users = all
                        .OrderByDescending(c => c.LID)
                        .Skip(mPage.PageSize * (mPage.PageIndex - 1)).Take(mPage.PageSize)
                        .ToList();
                    list.rows = users;
                    list.total = mPage.TotalCount;
                }
            }
            return list;
        }

        /// <summary>
        /// 为“离开”记录配对本次盈亏：进入余额取同一用户/游戏/桌台最近一条进入记录的余额，
        /// 离开余额取该记录自身余额，本次盈亏 = 进入 - 离开（玩家亏钱为正，赢钱为负）。
        /// </summary>
        private void FillEnterLeave(List<M_UserOptLog> all)
        {
            if (all == null || all.Count < 1)
                return;
            var enterBalance = new Dictionary<Tuple<string, int, long>, long>();
            foreach (var r in all.OrderBy(c => c.LID))
            {
                if (r.OPT == 2 || r.OPT == 8) // 进入记录
                {
                    enterBalance[Tuple.Create(r.UserID, r.GAME_TYPE, r.TABLE_ID)] = r.COINS;
                }
                else if (r.OPT == 3 || r.OPT == 7) // 离开记录
                {
                    r.LeaveCoins = r.COINS;
                    long ent;
                    if (enterBalance.TryGetValue(Tuple.Create(r.UserID, r.GAME_TYPE, r.TABLE_ID), out ent))
                    {
                        r.EnterCoins = ent;
                        r.SessionProfit = ent - r.COINS;
                    }
                }
            }
        }
    }
}
