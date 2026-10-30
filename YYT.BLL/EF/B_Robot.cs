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
        // 每行保留一个机器人名额，TABLE_ID 只用于定位所属代理线；实际入座由 ServerRobot 随机寻找空机台。
        public static List<int> PlanCardRobotAddition(IEnumerable<int> tables, IEnumerable<M_Robot> robots, int count)
        {
            var indexes = tables.Distinct().OrderBy(i => i).ToList();
            var existing = robots.ToList();
            long current = existing.Sum(r => (long)Math.Max(0, r.ROBOT_NO));
            if (count < 1 || count > indexes.Count - current) return null;
            var used = new HashSet<int>(existing.Where(r => r.ROBOT_NO > 0).Select(r => r.TABLE_ID));
            return indexes.Where(i => !used.Contains(i)).Take(count).ToList();
        }

        public static List<int> GetCardRobotTables(GameDbContext ef, int gameId, string line)
        {
            if (line == LineScopeRules.RecycledLine) return new List<int>();
            var owners = LineTables.GetOwners(ef, gameId);
            return ef.Database.SqlQuery<int>(
                "SELECT TableIndex FROM roomtableconfig WHERE GAME_ID={0} AND RoomIndex=0 AND Enabled=1 ORDER BY TableIndex", gameId)
                .Where(i => i >= 0 && i < LineTables.MaxTables && LineScopeRules.TableBelongsTo(owners, i, line)).ToList();
        }

        public static List<M_Robot> GetCardRobots(GameDbContext ef, int gameId, string line)
        {
            var owners = LineTables.GetOwners(ef, gameId);
            return ef.Robots.Where(r => r.GAME_ID == gameId && r.ROOM_ID == 0).ToList()
                .Where(r => LineScopeRules.TableBelongsTo(owners, r.TABLE_ID, line)).ToList();
        }

        /// <summary>
        /// 把某线牌机机器人总数直接设置为 target（0~本线启用机台数）：多了按差额增加名额，少了从高桌号起删减名额。
        /// 每个名额仍是一行 ROBOT_NO=1 的 robot_seat，TABLE_ID 只用于定位所属代理线，实际入座由 ServerRobot 随机寻找空机台。
        /// </summary>
        public Msg SetCardRobots(int gameId, int target, string line)
        {
            using (var ef = new GameDbContext())
            using (var tx = ef.Database.BeginTransaction())
            {
                // 同一游戏串行校验和调整，防止同时保存突破机台数量上限。
                ef.Database.SqlQuery<int>("SELECT GameId FROM games WHERE GameId={0} FOR UPDATE", gameId).ToList();
                var game = ef.Games.SingleOrDefault(g => g.GameId == gameId && g.Enable == 1 && g.GameType == 1);
                if (game == null || gameId == 54) return new Msg(0, "该游戏不支持设置牌机机器人！");
                var tables = GetCardRobotTables(ef, gameId, line);
                var existing = GetCardRobots(ef, gameId, line);
                int current = existing.Sum(r => Math.Max(0, r.ROBOT_NO));
                if (tables.Count == 0 && current == 0)
                    return new Msg(0, "该代理线在此游戏没有启用的机台！");
                if (target < 0 || target > tables.Count)
                    return new Msg(0, "机器人数量须在 0~" + tables.Count + " 之间（当前代理线启用机台" + tables.Count + "台）！");
                if (target == current)
                    return new Msg(1, "机器人数量未变化，仍为" + current + "个");
                if (target > current)
                {
                    var plan = PlanCardRobotAddition(tables, existing, target - current);
                    if (plan == null)
                        return new Msg(0, "机台数量不足，无法设置为" + target + "个！");
                    foreach (int index in plan)
                    {
                        var row = existing.FirstOrDefault(r => r.TABLE_ID == index);
                        if (row == null)
                        {
                            row = new M_Robot { GAME_ID = gameId, ROOM_ID = 0, TABLE_ID = index };
                            ef.Robots.Add(row);
                        }
                        row.GAME_TYPE = 1;
                        row.GAME_NAME = game.Name;
                        row.ROOM_NAME = "初级场";
                        row.ROBOT_NO = 1;
                    }
                }
                else
                {
                    // 先删已停用机台上的名额，再从高桌号往低删
                    int remove = current - target;
                    var tableSet = new HashSet<int>(tables);
                    foreach (var row in existing.Where(r => r.ROBOT_NO > 0)
                        .OrderBy(r => tableSet.Contains(r.TABLE_ID) ? 1 : 0).ThenByDescending(r => r.TABLE_ID).ToList())
                    {
                        if (remove <= 0) break;
                        int take = Math.Min(row.ROBOT_NO, remove);
                        row.ROBOT_NO -= take;
                        remove -= take;
                        if (row.ROBOT_NO <= 0) ef.Robots.Remove(row);
                    }
                }
                ef.SaveChanges();
                tx.Commit();
                return new Msg(1, "机器人数量已从" + current + "个设置为" + target + "个，将随机寻找本线空机台入座！");
            }
        }

        public Msg AddCardRobots(int gameId, int count, string line)
        {
            using (var ef = new GameDbContext())
            using (var tx = ef.Database.BeginTransaction())
            {
                // 同一游戏串行校验和增加，防止同时保存突破机台数量上限。
                ef.Database.SqlQuery<int>("SELECT GameId FROM games WHERE GameId={0} FOR UPDATE", gameId).ToList();
                var game = ef.Games.SingleOrDefault(g => g.GameId == gameId && g.Enable == 1 && g.GameType == 1);
                if (game == null || gameId == 54) return new Msg(0, "该游戏不支持添加牌机机器人！");
                var tables = GetCardRobotTables(ef, gameId, line);
                var existing = GetCardRobots(ef, gameId, line);
                var plan = PlanCardRobotAddition(tables, existing, count);
                if (plan == null)
                    return new Msg(0, "请输入正整数；累计机器人数量不可超过当前代理线的启用机台数量（" + tables.Count + "台，已设置" + existing.Sum(r => Math.Max(0, r.ROBOT_NO)) + "个）！");
                foreach (int index in plan)
                {
                    var row = existing.FirstOrDefault(r => r.TABLE_ID == index);
                    if (row == null)
                    {
                        row = new M_Robot { GAME_ID = gameId, ROOM_ID = 0, TABLE_ID = index };
                        ef.Robots.Add(row);
                    }
                    row.GAME_TYPE = 1;
                    row.GAME_NAME = game.Name;
                    row.ROOM_NAME = "初级场";
                    row.ROBOT_NO = 1;
                }
                ef.SaveChanges();
                tx.Commit();
                return new Msg(1, "已增加" + count + "个机器人，将随机寻找本线空机台入座！");
            }
        }


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

        /// <summary>机器人列表“代理线”筛选里表示“公共桌台”的值（与 RobotController.PublicLineKey 一致）。</summary>
        public const string PublicLineKey = "_public";

        public M_EasyuiGridData<M_Robot> getRobots(M_Page mPage, M_Robot entity)
        {
            return getRobots(mPage, entity, null);
        }

        /// <param name="lineFilter">代理线筛选：null/空/"*" 不筛选；PublicLineKey 只看公共桌台；其余只看该直属代理的专属桌台（# 为已收回）。</param>
        public M_EasyuiGridData<M_Robot> getRobots(M_Page mPage, M_Robot entity, string lineFilter)
        {
            M_EasyuiGridData<M_Robot> list = new M_EasyuiGridData<M_Robot>();
            using (var ef = new GameDbContext())
            {
                // 桌台显示名映射：roomtableconfig 为空名时保底"桌台"+TableIndex
                Dictionary<string, string> tableNameMap = ef.Database.SqlQuery<RobotTableNameRow>(
                        "SELECT GAME_ID, TableIndex, TableName FROM roomtableconfig").ToList()
                    .ToDictionary(r => r.GAME_ID + "_" + r.TableIndex,
                                  r => string.IsNullOrWhiteSpace(r.TableName) ? ("桌台" + r.TableIndex) : r.TableName.Trim());

                IEnumerable<M_Robot> rst = ef.Robots;
                if (!string.IsNullOrWhiteSpace(entity.GAME_NAME))
                    rst = rst.Where(c => c.GAME_NAME.Contains(entity.GAME_NAME));
                if (entity.ROOM_ID >= 0)
                    rst = rst.Where(c => c.ROOM_ID.Equals(entity.ROOM_ID));
                if (entity.TABLE_ID >= 0)
                    rst = rst.Where(c => c.TABLE_ID.Equals(entity.TABLE_ID));

                List<M_Robot> ListRobot = rst.ToList();
                // 填充桌子名称(缺配置或空名一律保底"桌台n")
                foreach (var item in ListRobot)
                {
                    string key = item.GAME_ID + "_" + item.TABLE_ID;
                    string name;
                    item.TABLE_NAME = tableNameMap.TryGetValue(key, out name) ? name : ("桌台" + item.TABLE_ID);
                    if (item.GAME_TYPE == 1) item.TABLE_NAME = "随机空机台";
                }
                // 所属代理线：没有归属记录 = 公共桌台(空串)；SQL 补丁未执行时全部按公共处理
                Dictionary<string, string> ownerMap = new Dictionary<string, string>();
                if (LineTables.OwnerTableExists(ef))
                {
                    foreach (RobotOwnerRow r in ef.Database.SqlQuery<RobotOwnerRow>(
                        "SELECT GAME_ID, TableIndex, IFNULL(LineAgent,'') AS LineAgent FROM roomtableowner").ToList())
                    {
                        ownerMap[r.GAME_ID + "_" + r.TableIndex] = r.LineAgent ?? string.Empty;
                    }
                }
                foreach (var item in ListRobot)
                {
                    string owner;
                    item.LINE_AGENT = ownerMap.TryGetValue(item.GAME_ID + "_" + item.TABLE_ID, out owner) ? owner : string.Empty;
                }
                string lf = (lineFilter ?? string.Empty).Trim();
                if (lf == PublicLineKey)
                    ListRobot = ListRobot.Where(c => string.IsNullOrEmpty(c.LINE_AGENT)).ToList();
                else if (lf.Length > 0 && lf != "*")
                    ListRobot = ListRobot.Where(c => string.Equals(c.LINE_AGENT, lf, StringComparison.OrdinalIgnoreCase)).ToList();
                // 桌子名称模糊搜索(含保底名"桌台n")
                if (!string.IsNullOrWhiteSpace(entity.TABLE_NAME))
                    ListRobot = ListRobot.Where(c => c.TABLE_NAME.Contains(entity.TABLE_NAME.Trim())).ToList();

                // 分页
                List<M_Robot> ListFooter = new List<M_Robot>();
                int tatolRobotNo = ListRobot.Sum(c => c.ROBOT_NO);
                M_Robot footer = new M_Robot();
                footer.ROBOT_NO = tatolRobotNo;
                footer.GAME_TYPE = 5;
                footer.TABLE_ID = -1;
                ListFooter.Add(footer);
                if (ListRobot != null)
                {
                    mPage.SetTotalCount(ListRobot.Count);
                    var users = ListRobot.AsEnumerable()
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

        /// <summary>roomtableowner 归属查询行(机器人列表代理线列用)</summary>
        public class RobotOwnerRow
        {
            public int GAME_ID { get; set; }
            public int TableIndex { get; set; }
            public string LineAgent { get; set; }
        }

        /// <summary>
        /// roomtableconfig 桌台显示名查询行(机器人列表桌子名称映射用)
        /// </summary>
        public class RobotTableNameRow
        {
            public int GAME_ID { get; set; }
            public int TableIndex { get; set; }
            public string TableName { get; set; }
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

        /// <summary>
        /// 删除全部机器人(清空 robot_seat，C++ center 直接读表生效)
        /// </summary>
        public int DelAllRobot()
        {
            int val = 0;
            using (var ef = new GameDbContext())
            {
                using (var trans = ef.Database.BeginTransaction())
                {
                    try
                    {
                        val = ef.Database.ExecuteSqlCommand("DELETE FROM robot_seat");
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
