using System;
using System.Linq;
using YYT.Common;
using YYT.Entity;

namespace YYT.BLL.EF
{
    public class B_Notice
    {
        public Msg AddNotice(M_Notice entity)
        {
            Msg msg = new Msg(0, "公告发布失败！");
            using (var ef = new GameDbContext())
            {
                using (var trans = ef.Database.BeginTransaction())
                {
                    try
                    {
                        ef.Notices.Add(entity);
                        ef.SaveChanges();
                        trans.Commit();
                        msg.code = 1;
                        msg.content = "公告发布成功！";
                    }
                    catch (Exception ex)
                    {
                        trans.Rollback();
                        LogHelper.WriteLog(typeof(YYT.BLL.EF.B_Notice), ex);
                    }
                }
            }
            return msg;
        }

        public Msg updateNotice(M_Notice entity)
        {
            Msg msg = new Msg(0, "公告修改失败！");
            using (var ef = new GameDbContext())
            {
                var rst = ef.Notices.Where(c => c.ID.Equals(entity.ID)).SingleOrDefault();
                if (rst != null)
                {
                    rst.TITLE = entity.TITLE;
                    rst.NOTICE = entity.NOTICE;
                    ef.SaveChanges();
                    msg.code = 1;
                    msg.content = "公告修改成功！";
                }
            }
            return msg;
        }

        public int DelNotice(M_Notice entity)
        {
            int val = 0;
            using (var ef = new GameDbContext())
            {
                using (var trans = ef.Database.BeginTransaction())
                {
                    try
                    {
                        ef.Notices.Attach(entity);
                        ef.Notices.Remove(entity);
                        val = ef.SaveChanges();
                        trans.Commit();
                    }
                    catch (Exception ex)
                    {
                        trans.Rollback();
                        LogHelper.WriteLog(typeof(YYT.BLL.EF.B_Notice), ex);
                    }
                }
            }
            return val;
        }

        public M_EasyuiGridData<M_Notice> GetNotices(M_LoginUser loginUser, M_Notice entity)
        {
            M_EasyuiGridData<M_Notice> list = new M_EasyuiGridData<M_Notice>();
            using (var ef = new GameDbContext())
            {

                var rst = ef.Notices.ToList();
                if (!string.IsNullOrWhiteSpace(entity.TITLE))
                    rst = rst.Where(c => c.TITLE.Equals(entity.TITLE)).ToList();
                list.rows = rst;
                list.total = rst.Count;
            }
            return list;
        }

        public M_Notice GetNotice(M_Notice entity)
        {
            using (var ef = new GameDbContext())
            {
                return ef.Notices.Where(c => c.ID.Equals(entity.ID)).SingleOrDefault();
            }
        }
    }
}
