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
                return ef.UserRelations.Where(c => c.ID.Equals(account)).Select(c => c.UserID).SingleOrDefault();
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
