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
                ef.SaveChanges();
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
                // 时间过滤必须下推 SQL（配合 loginmissrecord(ID) 索引与全表扫描防护）；
                // 定时任务上下文用同步保存，避免 SaveChangesAsync 未 await 丢写
                DateTime time = DateTime.Now.AddMinutes(-5);
                List<M_LoginMissRecord> list = ef.LoginMissRecords
                    .Where(c => c.LoginResult == 0 && c.LoginTime <= time)
                    .ToList();
                foreach (var item in list)
                {
                    item.MissCount = 0;
                }
                if (list.Count > 0)
                    ef.SaveChanges();
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
                ef.SaveChanges();
                return true;
            }
        }
    }
}
