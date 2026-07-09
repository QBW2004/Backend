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
    public class B_Robot
    {


        public Msg AddRobot(M_Robot entity)
        {
            Msg msg = new Msg(0, "机器人添加失败！");
            using (var ef = new GameDbContext())
            {
                var rst = ef.Robots.Where(c => c.GAME_ID.Equals(entity.GAME_ID) && c.ROOM_ID.Equals(entity.ROOM_ID) && c.TABLE_ID.Equals(entity.TABLE_ID)).FirstOrDefault();
                if (rst != null)
                {
                    rst.GAME_ID = entity.GAME_ID;
                    rst.GAME_TYPE = entity.GAME_TYPE;
                    rst.ROOM_ID = entity.ROOM_ID;
                    rst.ROOM_NAME = entity.ROOM_NAME;
                    rst.TABLE_ID = entity.TABLE_ID;
                    rst.GAME_NAME = entity.GAME_NAME;
                    rst.ROBOT_NO = entity.ROBOT_NO;
                    ef.Entry(rst).State = EntityState.Modified;
                }
                else
                {
                    entity.GAME_ID = entity.GAME_ID;
                    entity.GAME_TYPE = entity.GAME_TYPE;
                    entity.ROOM_ID = entity.ROOM_ID;
                    entity.ROOM_NAME = entity.ROOM_NAME;
                    entity.TABLE_ID = entity.TABLE_ID;
                    entity.GAME_NAME = entity.GAME_NAME;
                    entity.ROBOT_NO = entity.ROBOT_NO;
                    ef.Robots.Add(entity);
                }
                int val = ef.SaveChanges();
                if (val > 0)
                {
                    msg.code = 1;
                    msg.content = "机器人添加成功！";
                }
            }
            return msg;
        }

        public M_EasyuiGridData<M_Robot> getRobots(M_Page mPage, M_Robot entity)
        {
            M_EasyuiGridData<M_Robot> list = new M_EasyuiGridData<M_Robot>();
            using (var ef = new GameDbContext())
            {
                IEnumerable<M_Robot> rst = ef.Robots;
                if (!string.IsNullOrWhiteSpace(entity.GAME_NAME))
                    rst = rst.Where(c => c.GAME_NAME.Contains(entity.GAME_NAME));
                if (entity.ROOM_ID >= 0)
                    rst = rst.Where(c => c.ROOM_ID.Equals(entity.ROOM_ID));
                if (entity.TABLE_ID >= 0)
                    rst = rst.Where(c => c.TABLE_ID.Equals(entity.TABLE_ID));
                // 分页
                List<M_Robot> ListFooter = new List<M_Robot>();
                int tatolRobotNo = 0;
             
                List<M_Robot> ListRobot = new List<M_Robot>();
                ListRobot = rst.ToList();
                foreach (var item in ListRobot)
                {
                    tatolRobotNo += item.ROBOT_NO;
                }
                M_Robot footer = new M_Robot();
                footer.ROBOT_NO = tatolRobotNo;
                footer.GAME_TYPE = 5;
                footer.TABLE_ID = -1;
                ListFooter.Add(footer);
                if (rst != null)
                {
                    mPage.SetTotalCount(rst.Count());
                    var users = rst.AsEnumerable()
                        .OrderByDescending(c => c.GAME_ID)
                        .Skip(mPage.PageSize * (mPage.PageIndex - 1)).Take(mPage.PageSize)
                        .ToList();
                    list.footer = ListFooter;
                    list.rows = users;
                    list.total = mPage.TotalCount;
                }
            }
            return list;
        }

        public int DelRobot(M_Robot entity)
        {
            int val = 0;
            using (var ef = new GameDbContext())
            {
                using (var trans = ef.Database.BeginTransaction())
                {
                    try
                    {
                        ef.Robots.Attach(entity);
                        ef.Robots.Remove(entity);
                        val = ef.SaveChanges();
                        trans.Commit();
                    }
                    catch (Exception ex)
                    {
                        trans.Rollback();
                        LogHelper.WriteLog(typeof(YYT.BLL.EF.B_Robot), ex);
                    }
                }
            }
            return val;
        }
    }
}
