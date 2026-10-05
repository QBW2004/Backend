using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using YYT.Entity;

namespace YYT.BLL.EF
{
    public class B_UserRelations
    {
        public int? GetSingle(string account)
        {
            using (var ef = new GameDbContext())
            {
                // userrelations.ID 无唯一约束（中心服 Register 无条件 INSERT，重试/并发会留重复行）；
                // 重复时取最小 UserID —— 与中心服 GetUserInfo 按索引序读到的第一行一致。
                return ef.UserRelations.Where(c => c.ID.Equals(account))
                    .OrderBy(c => c.UserID)
                    .Select(c => (int?)c.UserID)
                    .FirstOrDefault();
            }
        }

        public string GetSingle(int userID)
        {
            using (var ef = new GameDbContext())
            {
                return ef.UserRelations.Where(c => c.UserID == userID).Select(c => c.ID).SingleOrDefault();
            }
        }
    }
}
