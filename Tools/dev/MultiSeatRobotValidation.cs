using System;
using System.Configuration;
using System.Data.Entity;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using System.Web;
using System.Web.Mvc;
using System.Web.Routing;
using MySql.Data.MySqlClient;
using Newtonsoft.Json.Linq;
using YYT.BLL.EF;
using YYT.Web.Areas.Game.Controllers;

class MultiSeatRobotValidation
{
    static int checks;
    static MySqlConnection db;
    static void Check(bool ok, string name) { if (!ok) throw new Exception(name); checks++; }
    static void Sql(string sql) { using (var cmd = new MySqlCommand(sql, db)) cmd.ExecuteNonQuery(); }
    static int Scalar(string sql) { using (var cmd = new MySqlCommand(sql, db)) return Convert.ToInt32(cmd.ExecuteScalar()); }
    sealed class PostRequest : HttpRequestWrapper
    {
        public PostRequest(HttpRequest request) : base(request) { }
        public override string HttpMethod { get { return "POST"; } }
    }
    sealed class PostContext : HttpContextWrapper
    {
        readonly HttpRequestBase request;
        public PostContext(HttpContext context) : base(context) { request = new PostRequest(context.Request); }
        public override HttpRequestBase Request { get { return request; } }
    }
    static JObject Json(Controller controller, ActionResult result)
    {
        var output = new StringWriter();
        var http = new HttpContext(new HttpRequest("", "http://localhost/", ""), new HttpResponse(output));
        var context = new ControllerContext(new PostContext(http), new RouteData(), controller);
        result.ExecuteResult(context);
        return JObject.Parse(output.ToString());
    }
    static void Main()
    {
        var timer = System.Diagnostics.Stopwatch.StartNew();
        try
        {
            var cs = new MySqlConnectionStringBuilder(ConfigurationManager.ConnectionStrings["DbConnString"].ConnectionString);
            if (cs.Server != "127.0.0.1" || cs.Port != 33406 || !cs.Database.StartsWith("mth_robot_limit_validation_"))
                throw new Exception("Requires isolated localhost:33406 test database");
            string schema = cs.Database;
            if (!System.Text.RegularExpressions.Regex.IsMatch(schema, "^[a-z0-9_]+$")) throw new Exception("Invalid schema");
            string repo = ConfigurationManager.AppSettings["repoRoot"];
            cs.Database = "";
            using (db = new MySqlConnection(cs.ConnectionString))
            {
                db.Open();
                Sql("CREATE DATABASE `" + schema + "` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci");
                try
                {
                    Sql("USE `" + schema + "`");
                    var snapshot = SqlSnapshot.Read(repo);
                    foreach (var table in new[] { "games", "robot_seat", "roomtableconfig", "roomtableowner" }) Sql(SqlSnapshot.Table(snapshot, table));
                    Database.SetInitializer<GameDbContext>(null);
                    var bll = new B_Robot();
                    Sql("INSERT INTO games(GameId,Name,Enable,GameType) VALUES(3,'fish',1,2),(10,'bet',1,0),(47,'bmw',1,0),(5,'card',1,1)");
                    Check(bll.SetMultiSeatRobots(3, 1, "", 1).code == 0, "missing migration rejected");
                    string migration = File.ReadAllText(Path.Combine(repo, "Tools/db/robot-table-limit-20261106.sql"));
                    Sql(migration);
                    Sql(migration);
                    Check(Scalar("SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='robot_seat' AND COLUMN_NAME='MAX_PER_TABLE'") == 1, "migration idempotent");
                    foreach (int game in new[] { 3, 10, 47 })
                    {
                        int type = game == 3 ? 2 : 0;
                        foreach (int table in new[] { 0, 2, 8, 10, 11, 20, 30, 40 })
                            Sql("INSERT INTO roomtableconfig(GAME_ID,RoomIndex,TableIndex,Enabled,MaxSeats) VALUES(" + game + ",0," + table + "," + (table == 8 ? 0 : 1) + "," + (table == 2 ? 2 : 6) + ")");
                        Sql("INSERT INTO roomtableowner(GAME_ID,RoomIndex,TableIndex,LineAgent) VALUES(" + game + ",0,10,'lineA'),(" + game + ",0,11,'lineA'),(" + game + ",0,20,'lineB'),(" + game + ",0,30,'#')");
                        Sql("INSERT INTO robot_seat(GAME_ID,GAME_TYPE,ROOM_ID,TABLE_ID,ROBOT_NO) VALUES(" + game + "," + type + ",0,0,6),(" + game + "," + type + ",0,0,1),(" + game + "," + type + ",0,8,2)");
                        Check(bll.SetMultiSeatRobots(game, 7, "", 3).code == 1, "legacy quotas replaced with balanced total");
                        Check(Scalar("SELECT SUM(ROBOT_NO) FROM robot_seat WHERE GAME_ID=" + game) == 7, "total conserved");
                        Check(Scalar("SELECT COUNT(*) FROM robot_seat WHERE GAME_ID=" + game + " AND (ROBOT_NO>3 OR TABLE_ID=8 OR MAX_PER_TABLE<>3)") == 0, "limits and disabled tables");
                        Check(Scalar("SELECT ROBOT_NO FROM robot_seat WHERE GAME_ID=" + game + " AND TABLE_ID=2") == 1, "small table leaves human seat");
                        Check(bll.SetMultiSeatRobots(game, 8, "", 3).code == 0, "overflow rejected");
                        Check(bll.SetMultiSeatRobots(game, 1, "", 99).code == 0, "invalid per table limit");
                        Check(bll.SetMultiSeatRobots(game, 1, "missing", 1).code == 0, "unknown line rejected");
                        Check(bll.SetMultiSeatRobots(game, 1, "#", 1).code == 0, "recycled line rejected");
                        Check(bll.SetMultiSeatRobots(game, 4, "LINEA", 2).code == 1, "agent line case insensitive");
                        Check(bll.SetMultiSeatRobots(game, 1, "lineB", 2).code == 1, "independent agent");
                        using (var ef = new GameDbContext())
                        {
                            Check(B_Robot.GetCardRobots(ef, game, "").Sum(r => r.ROBOT_NO) == 7, "agent saves preserve public quotas");
                            Check(B_Robot.ReadMaxPerTable(ef, B_Robot.GetCardRobots(ef, game, "lineA")) == 2, "limit persists per line");
                        }
                        var tasks = new[] { 2, 5 }.Select(n => Task.Run(() => new B_Robot().SetMultiSeatRobots(game, n, "", 3).code)).ToArray();
                        Task.WaitAll(tasks);
                        Check(tasks.All(t => t.Result == 1), "concurrent absolute saves accepted");
                        using (var ef = new GameDbContext())
                        {
                            int total = B_Robot.GetCardRobots(ef, game, "").Sum(r => r.ROBOT_NO);
                            Check(total == 2 || total == 5, "concurrent saves do not add targets");
                        }
                        Check(bll.SetMultiSeatRobots(game, 0, "", 3).code == 1, "zero target accepted");
                        using (var ef = new GameDbContext())
                        {
                            var robots = B_Robot.GetCardRobots(ef, game, "");
                            Check(robots.Sum(r => r.ROBOT_NO) == 0 && B_Robot.ReadMaxPerTable(ef, robots) == 3, "zero retains configured limit");
                            Check(B_Robot.GetCardRobots(ef, game, "lineA").Sum(r => r.ROBOT_NO) == 4, "zero keeps other line");
                        }
                        var controller = new RobotController();
                        var result = Json(controller, controller.GetCardRobotCapacity(new FormCollection { { "GameId", game.ToString() }, { "Line", "_public" } }));
                        Check((int)result["current"] == 0 && (int)result["maxPerTable"] == 3 && (int)result["total"] == 7 && (bool)result["schemaReady"], "actual MVC JSON readback");
                        var old = Json(controller, controller.SaveRobot(new FormCollection { { "GameId", game.ToString() }, { "GameType", type.ToString() }, { "RobotNo", "1" }, { "TABLE_ID", "0" } }));
                        Check((int)old["code"] == 0, "old page cannot overwrite new quotas");
                        Sql("UPDATE roomtableconfig SET Enabled=0 WHERE GAME_ID=" + game + " AND TableIndex IN(0,2,40)");
                        Check(bll.SetMultiSeatRobots(game, 0, "", 3).code == 1, "disabled line can clear remaining quotas");
                        Sql("UPDATE games SET Enable=0 WHERE GameId=" + game);
                        Check(bll.SetMultiSeatRobots(game, 1, "lineA", 1).code == 0, "closed game rejected");
                    }
                    Check(bll.SetMultiSeatRobots(5, 1, "", 1).code == 0, "machine family preserved");
                }
                finally { Sql("DROP DATABASE `" + schema + "`"); }
            }
            Console.WriteLine("PASS " + checks + " isolated database/MVC checks in " + timer.Elapsed.TotalSeconds.ToString("F2") + "s");
        }
        catch (Exception ex) { Console.WriteLine(ex.GetType().Name + ": " + ex.Message); Environment.ExitCode = 1; }
    }
}
