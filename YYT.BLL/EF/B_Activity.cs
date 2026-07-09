using System;
using System.Linq;
using YYT.Common;
using YYT.Entity;

namespace YYT.BLL.EF
{
    public class B_Activity
    {
        public Msg AddActivity(M_Activity entity)
        {
            Msg msg = new Msg(0, "活动发布失败！");
            using (var ef = new GameDbContext())
            {
                using (var trans = ef.Database.BeginTransaction())
                {
                    try
                    {
                        ef.Activities.Add(entity);
                        ef.SaveChanges();
                        trans.Commit();
                        msg.code = 1;
                        msg.content = "活动发布成功！";
                    }
                    catch (Exception ex)
                    {
                        trans.Rollback();
                        LogHelper.WriteLog(typeof(YYT.BLL.EF.B_Activity), ex);
                    }
                }
            }
            return msg;
        }

        public Msg updateActivity(M_Activity entity)
        {
            Msg msg = new Msg(0, "活动修改失败！");
            using (var ef = new GameDbContext())
            {
                var rst = ef.Activities.Where(c => c.ID.Equals(entity.ID)).SingleOrDefault();
                if (rst != null)
                {
                    rst.TITLE = entity.TITLE;
                    rst.Activity = entity.Activity;
                    ef.SaveChanges();
                    msg.code = 1;
                    msg.content = "活动修改成功！";
                }
            }
            return msg;
        }

        public int DelActivity(M_Activity entity)
        {
            int val = 0;
            using (var ef = new GameDbContext())
            {
                using (var trans = ef.Database.BeginTransaction())
                {
                    try
                    {
                        ef.Activities.Attach(entity);
                        ef.Activities.Remove(entity);
                        val = ef.SaveChanges();
                        trans.Commit();
                    }
                    catch (Exception ex)
                    {
                        trans.Rollback();
                        LogHelper.WriteLog(typeof(YYT.BLL.EF.B_Activity), ex);
                    }
                }
            }
            return val;
        }

        public M_EasyuiGridData<M_Activity> GetActivity(M_LoginUser loginUser, M_Activity entity)
        {
            M_EasyuiGridData<M_Activity> list = new M_EasyuiGridData<M_Activity>();
            using (var ef = new GameDbContext())
            {
                var rst = ef.Activities.ToList();
                if (!string.IsNullOrWhiteSpace(entity.TITLE))
                    rst = rst.Where(c => c.TITLE.Equals(entity.TITLE)).ToList();
                list.rows = rst;
                list.total = rst.Count;
            }
            return list;
        }

        public M_Activity GetNotice(M_Activity entity)
        {
            using (var ef = new GameDbContext())
            {
                return ef.Activities.Where(c => c.ID.Equals(entity.ID)).SingleOrDefault();
            }
        }
    }
}
