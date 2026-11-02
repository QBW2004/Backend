// 独立本地数据库验收；连接串必须指向 mth_card_robot_validation_*，不允许使用线上库。
using System;
using System.Configuration;
using System.Data.Entity;
using System.Linq;
using System.Threading.Tasks;
using MySql.Data.MySqlClient;
using YYT.BLL.EF;
using YYT.Entity;

class CardRobotValidation
{
    static int checks;
    static void Check(bool value, string name)
    {
        if (!value) throw new Exception(name);
        checks++;
    }
    static void Main()
    {
        var timer = System.Diagnostics.Stopwatch.StartNew();
        try
        {
            var cs = new MySqlConnectionStringBuilder(ConfigurationManager.ConnectionStrings["DbConnString"].ConnectionString);
            if ((cs.Server != "localhost" && cs.Server != "127.0.0.1") || !cs.Database.StartsWith("mth_card_robot_validation_"))
                throw new Exception("Requires an isolated local validation database");
            string schema = cs.Database;
            if (!System.Text.RegularExpressions.Regex.IsMatch(schema, "^[a-z0-9_]+$")) throw new Exception("Invalid schema");
            cs.Database = "";
            using (var db = new MySqlConnection(cs.ConnectionString))
            {
                db.Open();
                Action<string> sql = q => { using (var cmd = new MySqlCommand(q, db)) cmd.ExecuteNonQuery(); };
                sql("CREATE DATABASE `" + schema + "` CHARACTER SET utf8mb4");
                try
                {
                    sql("USE `" + schema + "`");
                    foreach (var t in new[] { "games", "robot_seat", "roomtableconfig" })
                        sql("CREATE TABLE `" + t + "` LIKE mth.`" + t + "`");
                    sql("CREATE TABLE roomtableowner(GAME_ID INT,RoomIndex INT,TableIndex INT,LineAgent VARCHAR(50),PRIMARY KEY(GAME_ID,RoomIndex,TableIndex)) ENGINE=InnoDB");
                    sql("INSERT INTO games(GameId,Name,Enable,GameType) VALUES(5,'card',1,1),(3,'fish',1,2),(15,'closed',0,1),(54,'mjhl',1,1)");
                    foreach (int n in new[] { 0, 1, 2, 10, 11, 20, 30 })
                        sql("INSERT INTO roomtableconfig(GAME_ID,RoomIndex,TableIndex,TableName,Enabled) VALUES(5,0," + n + ",'table'," + (n == 1 ? 0 : 1) + ")");
                    sql("INSERT INTO roomtableowner(GAME_ID,RoomIndex,TableIndex,LineAgent) VALUES(5,0,10,'lineA'),(5,0,11,'lineA'),(5,0,20,'lineB'),(5,0,30,'#')");
                    Database.SetInitializer<GameDbContext>(null);
                    var bll = new B_Robot();
                    using (var ef = new GameDbContext())
                    {
                        Check(B_Robot.GetCardRobotTables(ef, 5, "").SequenceEqual(new[] { 0, 2 }), "public enabled tables");
                        Check(B_Robot.GetCardRobotTables(ef, 5, "LINEA").SequenceEqual(new[] { 10, 11 }), "line matching");
                        Check(B_Robot.GetCardRobotTables(ef, 5, "#").Count == 0, "recycled tables excluded");
                    }
                    foreach (int count in new[] { 0, -1, int.MaxValue }) Check(bll.AddCardRobots(5, count, "").code == 0, "invalid count");
                    Check(bll.AddCardRobots(5, 2, "").code == 1, "exact capacity accepted");
                    Check(bll.AddCardRobots(5, 1, "").code == 0, "cumulative limit enforced");
                    Check(bll.AddCardRobots(5, 1, "lineA").code == 1, "agent addition");
                    Check(bll.AddCardRobots(5, 2, "lineA").code == 0, "over limit atomic rejection");
                    Check(bll.AddCardRobots(5, 1, "lineA").code == 1, "incremental addition");
                    Check(bll.AddCardRobots(5, 1, "lineB").code == 1, "separate line capacity");
                    Check(bll.AddCardRobots(5, 1, "#").code == 0, "recycled line rejected");
                    Check(bll.AddCardRobots(5, 1, "missing").code == 0, "unknown line rejected");
                    Check(bll.AddCardRobots(3, 1, "").code == 0, "non-card rejected");
                    Check(bll.AddCardRobots(15, 1, "").code == 0, "closed game rejected");
                    Check(bll.AddCardRobots(54, 1, "").code == 0, "mjhl rejected");
                    using (var ef = new GameDbContext())
                    {
                        Check(ef.Robots.Count() == 5 && ef.Robots.All(r => r.ROBOT_NO == 1 && r.ROOM_ID == 0), "one row per new quota");
                        Check(B_Robot.GetCardRobots(ef, 5, "lineA").Count == 2, "line counts isolated");
                        var row = B_Robot.GetCardRobots(ef, 5, "lineB").Single();
                        Check(bll.DelRobot(new M_Robot { ID = row.ID }) == 1, "delete quota");
                    }
                    Check(bll.AddCardRobots(5, 1, "lineB").code == 1, "delete frees capacity");
                    sql("DELETE FROM robot_seat WHERE TABLE_ID IN(0,2)");
                    var races = Enumerable.Range(0, 2).Select(i => Task.Run(() => new B_Robot().AddCardRobots(5, 2, "").code)).ToArray();
                    Task.WaitAll(races);
                    Check(races.Count(t => t.Result == 1) == 1, "concurrent additions serialized");
                    using (var ef = new GameDbContext()) Check(B_Robot.GetCardRobots(ef, 5, "").Sum(r => r.ROBOT_NO) == 2, "no concurrent overflow");
                    sql("UPDATE roomtableconfig SET Enabled=0 WHERE TableIndex=2");
                    Check(bll.AddCardRobots(5, 1, "").code == 0, "current reduced capacity used");
                    // 设置总数（后台“机器人数”实际调用）：可增可减，范围 0~启用机台数
                    sql("UPDATE roomtableconfig SET Enabled=1 WHERE TableIndex=2");
                    sql("DELETE FROM robot_seat");
                    foreach (int count in new[] { -1, 3 }) Check(bll.SetCardRobots(5, count, "").code == 0, "set out of range");
                    Check(bll.SetCardRobots(5, 2, "").code == 1, "set up to capacity");
                    using (var ef = new GameDbContext()) Check(B_Robot.GetCardRobots(ef, 5, "").Sum(r => r.ROBOT_NO) == 2, "set increases");
                    Check(bll.SetCardRobots(5, 1, "").code == 1, "set decreases");
                    using (var ef = new GameDbContext()) Check(B_Robot.GetCardRobots(ef, 5, "").Sum(r => r.ROBOT_NO) == 1, "set decreased to target");
                    Check(bll.SetCardRobots(5, 1, "lineA").code == 1, "set other line");
                    Check(bll.SetCardRobots(5, 0, "").code == 1, "set to zero");
                    using (var ef = new GameDbContext())
                    {
                        Check(B_Robot.GetCardRobots(ef, 5, "").Count == 0, "zero removes rows");
                        Check(B_Robot.GetCardRobots(ef, 5, "lineA").Sum(r => r.ROBOT_NO) == 1, "other line untouched");
                    }
                    Check(bll.SetCardRobots(5, 1, "missing").code == 0, "set unknown line rejected");
                    Check(bll.SetCardRobots(54, 1, "").code == 0, "set mjhl rejected");
                    foreach (int gameId in new[] { 16, 40, 53 })
                    {
                        sql("INSERT INTO games(GameId,Name,Enable,GameType) VALUES(" + gameId + ",'laba',1,3)");
                        sql("INSERT INTO roomtableconfig(GAME_ID,RoomIndex,TableIndex,TableName,Enabled) SELECT " + gameId + ",RoomIndex,TableIndex,TableName,Enabled FROM roomtableconfig WHERE GAME_ID=5");
                        sql("INSERT INTO roomtableowner SELECT " + gameId + ",RoomIndex,TableIndex,LineAgent FROM roomtableowner WHERE GAME_ID=5");
                        foreach (int count in new[] { -1, 3 }) Check(bll.SetCardRobots(gameId, count, "").code == 0, "laba range rejected");
                        Check(bll.SetCardRobots(gameId, 2, "").code == 1, "laba public target set");
                        Check(bll.SetCardRobots(gameId, 1, "lineA").code == 1, "laba agent target set");
                        using (var ef = new GameDbContext())
                        {
                            Check(B_Robot.GetCardRobots(ef, gameId, "").Sum(r => r.ROBOT_NO) == 2, "laba capacity used");
                            Check(ef.Robots.Where(r => r.GAME_ID == gameId).All(r => r.GAME_TYPE == 3 && r.ROBOT_NO == 1), "laba type preserved");
                        }
                        Check(bll.SetCardRobots(gameId, 1, "").code == 1, "laba target reduced");
                        Check(bll.SetCardRobots(gameId, 0, "").code == 1, "laba target cleared");
                        using (var ef = new GameDbContext())
                        {
                            Check(B_Robot.GetCardRobots(ef, gameId, "").Count == 0, "laba rows cleared");
                            Check(B_Robot.GetCardRobots(ef, gameId, "lineA").Sum(r => r.ROBOT_NO) == 1, "laba other line untouched");
                        }
                        sql("INSERT INTO robot_seat(GAME_ID,GAME_TYPE,ROOM_ID,TABLE_ID,ROBOT_NO) VALUES(" + gameId + ",3,0,0,6)");
                        Check(bll.SetCardRobots(gameId, 2, "").code == 1, "laba legacy multi-count reduced");
                        using (var ef = new GameDbContext()) Check(B_Robot.GetCardRobots(ef, gameId, "").Sum(r => r.ROBOT_NO) == 2, "laba legacy target exact");
                        Check(bll.SetCardRobots(gameId, 0, "").code == 1, "laba legacy cleared");
                        var sets = Enumerable.Range(0, 2).Select(i => Task.Run(() => new B_Robot().SetCardRobots(gameId, 2, "").code)).ToArray();
                        Task.WaitAll(sets);
                        Check(sets.All(t => t.Result == 1), "laba concurrent targets serialized");
                        using (var ef = new GameDbContext()) Check(B_Robot.GetCardRobots(ef, gameId, "").Sum(r => r.ROBOT_NO) == 2, "laba concurrent target exact");
                        Check(bll.SetCardRobots(gameId, 1, "missing").code == 0, "laba unknown line rejected");
                        Check(bll.SetCardRobots(gameId, 1, "#").code == 0, "laba recycled line rejected");
                        sql("UPDATE games SET Enable=0 WHERE GameId=" + gameId);
                        Check(bll.SetCardRobots(gameId, 1, "").code == 0, "laba closed game rejected");
                    }
                    Check(bll.SetCardRobots(3, 1, "").code == 0, "fish target mode rejected");
                }
                finally { sql("DROP DATABASE `" + schema + "`"); }
            }
            Console.WriteLine("PASS " + checks + " database checks in " + timer.Elapsed.TotalSeconds.ToString("F2") + "s");
        }
        catch (Exception ex) { Console.WriteLine(ex); Environment.ExitCode = 1; }
    }
}
