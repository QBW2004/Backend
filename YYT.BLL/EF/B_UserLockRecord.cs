using System;
using System.Collections.Generic;
using System.Linq;
using YYT.Common;
using YYT.Entity;
using YYT.BLL.Services.GameServer;

namespace YYT.BLL.EF
{
    public class B_UserLockRecord
    {
        public void AddUserLockRecord(M_UserLockRecord entity)
        {
            if (string.IsNullOrWhiteSpace(entity?.ID)) return;

            using (var ef = new GameDbContext())
            {
                var rst = ef.UserLockRecords.Where(c => c.ID.Equals(entity.ID)).FirstOrDefault();
                if (rst == null)
                {
                    ef.UserLockRecords.Add(entity);
                    ef.SaveChanges();
                }
            }
        }

        public bool DelUserLockRecord(string id)
        {
            if (string.IsNullOrWhiteSpace(id)) return false;

            using (var ef = new GameDbContext())
            {
                var rst = ef.UserLockRecords.Where(c => c.ID.Equals(id)).FirstOrDefault();
                if (rst != null)
                {
                    ef.UserLockRecords.Remove(rst);
                    return ef.SaveChanges() > 0;
                }
            }
            return false;
        }

        public List<M_UserLockRecord> GetUserLockRecords()
        {
            using (var ef = new GameDbContext())
            {
                return ef.UserLockRecords.ToList();
            }
        }

        public void TimerTaskRun()
        {
            try
            {
                List<M_UserLockRecord> list = GetUserLockRecords();
                if (list != null && list.Count > 0)
                {
                    foreach (M_UserLockRecord item in list)
                    {
                        SendCmd(item);
                    }
                }
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.BLL.EF.B_UserLockRecord), ex);
            }
        }

        private void SendCmd(M_UserLockRecord entity)
        {
            try
            {
                M_ReChargeRecords rechargeRecord = FindLatestRechargeRecord(entity);
                if (rechargeRecord == null || !rechargeRecord.Coin.HasValue)
                {
                    LogHelper.WriteLog(typeof(YYT.BLL.EF.B_UserLockRecord), string.Format("Legacy UserLockRecord cannot be migrated because coin amount was not found: {0}", entity));
                    return;
                }

                int rechargeType = NormalizeRechargeType(entity.RechargeType, rechargeRecord.RechargeType);
                M_GameCommandOutbox command = new B_GameCommandOutbox().Create("UL", entity.ID, new { RechargeType = rechargeType, Result = entity.OptResult, Coins = rechargeRecord.Coin, UserAccount = entity.ID });
                if (command != null && !string.IsNullOrWhiteSpace(command.CommandId))
                {
                    DelUserLockRecord(entity.ID);
                }
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.BLL.EF.B_UserLockRecord), string.Format("{0} > {1}", "YYT.BLL.EF.B_UserLockRecord.SendCmd", ex.Message));
            }
        }

        private M_ReChargeRecords FindLatestRechargeRecord(M_UserLockRecord entity)
        {
            using (var ef = new GameDbContext())
            {
                return ef.ReChargeRecords
                    .Where(c => c.GameID == entity.ID)
                    .OrderByDescending(c => c.CreateTime)
                    .FirstOrDefault();
            }
        }

        private int NormalizeRechargeType(int legacyType, int rechargeRecordType)
        {
            if (legacyType >= 20)
                return legacyType - 20;
            if (legacyType >= 0)
                return legacyType;
            if (rechargeRecordType >= 20)
                return rechargeRecordType - 20;
            return rechargeRecordType;
        }
    }
}
