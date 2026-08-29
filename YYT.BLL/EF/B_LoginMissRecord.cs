using System;
using System.Collections.Generic;
using System.Linq;
using YYT.Entity;

namespace YYT.BLL.EF
{
    public class B_LoginMissRecord
    {
        public void UpadteRecord(M_LoginMissRecord entity)
        {
            using (var ef = new GameDbContext())
            {
                var rst = ef.LoginMissRecords.Where(c => c.ID.Equals(entity.ID)).FirstOrDefault();
                if (rst == null)
                {
                    ef.LoginMissRecords.Add(entity);
                }
                else
                {
                    rst.LoginResult = entity.LoginResult;
                    rst.LoginTime = DateTime.Now;
                    if (entity.LoginResult == 1)
                    {
                        rst.MissCount = 0;
                    }
                    else
                    {
                        rst.MissCount = entity.MissCount + 1;
                    }
                }
                ef.SaveChangesAsync();
            }
        }

        public M_LoginMissRecord GetRecord(M_LoginMissRecord entity)
        {
            using (var ef = new GameDbContext())
            {
                return ef.LoginMissRecords.Where(c => c.ID.Equals(entity.ID)).FirstOrDefault();
            }
        }

        public void ResetLoginMissRecord()
        {
            using (var ef = new GameDbContext())
            {
                DateTime time = DateTime.Now.AddMinutes(-5);
                List<M_LoginMissRecord> list = ef.LoginMissRecords.Where(c => c.LoginResult == 0).ToList();
                if (list != null)
                {
                    foreach (var item in list)
                    {
                        if (time >= item.LoginTime)
                            item.MissCount = 0;
                    }
                }
                ef.SaveChangesAsync();
            }
        }

        /// <summary>
        /// 手机端：异常登录锁定的账号列表（连续失败 5 次及以上且未解锁）
        /// </summary>
        public List<M_LoginMissRecord> GetAbnormalList()
        {
            using (var ef = new GameDbContext())
            {
                return ef.LoginMissRecords
                    .Where(c => c.LoginResult == 0 && c.MissCount > 4)
                    .OrderByDescending(c => c.LoginTime)
                    .ToList();
            }
        }

        /// <summary>
        /// 手机端：解除异常登录锁定（清零失败计数）
        /// </summary>
        public bool Unblock(string id)
        {
            using (var ef = new GameDbContext())
            {
                var rst = ef.LoginMissRecords.Where(c => c.ID.Equals(id)).FirstOrDefault();
                if (rst == null)
                    return false;
                rst.LoginResult = 1;
                rst.MissCount = 0;
                rst.LoginTime = DateTime.Now;
                ef.SaveChangesAsync();
                return true;
            }
        }
    }
}
