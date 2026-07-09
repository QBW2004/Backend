using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;
using YYT.Common;
using YYT.Entity;
using YYT.Remote;

namespace YYT.BLL.EF
{
    public class B_UserRobot
    {
        public bool Exists(M_UserRobot entity)
        {
            using (var ef = new GameDbContext())
            {
                return ef.userRobots.Any(c => c.UserName.Equals(entity.UserName));
            }
        }

        public Msg AddRobot(M_UserRobot entity)
        {
            Msg msg = new Msg(0, "机器人添加失败！");
            using (var ef = new GameDbContext())
            {
                ef.userRobots.Add(entity);
                int val = ef.SaveChanges();
                if (val > 0)
                {
                    msg.code = 1;
                    msg.content = "机器人添加成功！";
                }
            }
            return msg;
        }

        public Msg UpdateRobot(M_UserRobot entity)
        {
            Msg msg = new Msg(0, "机器人修改失败！");
            using (var ef = new GameDbContext())
            {
                var usr = ef.userRobots.Where(c => c.ID.Equals(entity.ID)).FirstOrDefault();
                if (usr != null)
                {
                    usr.UserName = entity.UserName;
                    usr.Ico = entity.Ico;
                    usr.Lev = entity.Lev;
                    usr.Sex = entity.Sex;
                    usr.Gold = entity.Gold;
                    int val = ef.SaveChanges();
                    if (val > 0)
                    {
                        msg.code = 1;
                        msg.content = "机器人修改成功！";
                    }
                }
            }
            return msg;
        }

        public Msg UpdateBatchRobot(M_UserRobot entity)
        {
            Msg msg = new Msg(0, "机器人修改失败！");
            using (var ef = new GameDbContext())
            {
                var usr = ef.userRobots.Where(c => c.ID.Equals(entity.ID)).FirstOrDefault();
                if (usr != null)
                {
                    usr.UserNick = entity.UserNick;
                    usr.Gold = entity.Gold;
                    int val = ef.SaveChanges();
                    if (val > 0)
                    {
                        msg.code = 1;
                        msg.content = "机器人修改成功！";
                    }
                }
            }
            return msg;
        }

        public M_UserRobot GetUserRobot()
        {
            using (var ef = new GameDbContext())
            {
                var latestData = (
                    from data in ef.userRobots
                    orderby data.ID descending
                    select data
                ).FirstOrDefault();
                ////from c in ef.userRobots.get
                ////group c by c.Id into g
                ////select g.OrderByDescending(r => r.CollTime).FirstOrDefault()
                return latestData;
            }
        }

        public M_EasyuiGridData<M_UserRobot> getRobots(M_Page mPage, M_UserRobot entity)
        {
            M_EasyuiGridData<M_UserRobot> list = new M_EasyuiGridData<M_UserRobot>();
            using (var ef = new GameDbContext())
            {
                IEnumerable<M_UserRobot> rst = ef.userRobots;
                if (!string.IsNullOrWhiteSpace(entity.UserName))
                    rst = rst.Where(c => c.UserName.Contains(entity.UserName));
                if (!string.IsNullOrWhiteSpace(entity.UserNick))
                    rst = rst.Where(c => c.UserNick.Equals(entity.UserNick));
                // 分页
                if (rst != null)
                {
                    mPage.SetTotalCount(rst.Count());
                    var users = rst.AsEnumerable()
                        .OrderByDescending(c => c.ID)
                        .Skip(mPage.PageSize * (mPage.PageIndex - 1))
                        .Take(mPage.PageSize)
                        .ToList();
                    list.rows = users;
                    list.total = mPage.TotalCount;
                }
            }
            return list;
        }

        public int DelRobot(M_UserRobot entity)
        {
            int val = 0;
            using (var ef = new GameDbContext())
            {
                using (var trans = ef.Database.BeginTransaction())
                {
                    try
                    {
                        ef.userRobots.Attach(entity);
                        ef.userRobots.Remove(entity);
                        val = ef.SaveChanges();
                        trans.Commit();
                    }
                    catch (Exception ex)
                    {
                        trans.Rollback();
                        LogHelper.WriteLog(typeof(YYT.BLL.EF.B_UserRobot), ex);
                    }
                }
            }
            return val;
        }
    }
}
