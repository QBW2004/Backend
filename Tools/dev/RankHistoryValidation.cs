using System;
using System.IO;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using System.Xml.Linq;
using MySql.Data.MySqlClient;
using Newtonsoft.Json.Linq;
using YYT.Web.Controllers.Api;

class BackendValidation
{
    static int checks;
    static string backendRoot;
    static string serverRoot;
    static bool serveFixture;
    static void Check(bool ok, string name) { if (!ok) throw new Exception(name); checks++; Console.WriteLine("PASS " + name); }
    static void Main(string[] args)
    {
        try { backendRoot = Path.GetFullPath(args[0]); serverRoot = Path.GetFullPath(args[1]); serveFixture = args.Contains("--serve-fixture"); Run(); }
        catch (Exception e) { for (; e != null; e = e.InnerException) Console.WriteLine(e.GetType().FullName + ": " + e.Message); Environment.ExitCode = 1; }
    }
    static void Run()
    {
        var start = DateTime.UtcNow;
        using (var db = new MySqlConnection("Server=localhost;Port=3306;Uid=root;Pwd=123456;Allow User Variables=True;"))
        {
            db.Open();
            Action<string> sql = q => { using (var cmd = new MySqlCommand(q, db)) cmd.ExecuteNonQuery(); };
            sql("CREATE DATABASE mth_rankhistory_validation CHARACTER SET utf8mb4");
            sql("USE mth_rankhistory_validation");
            foreach (string t in new[] { "games", "users", "userrobot", "admin" }) sql("CREATE TABLE IF NOT EXISTS `" + t + "` LIKE mth.`" + t + "`");
            string schema = File.ReadAllText(Path.Combine(backendRoot, "Docs/sql/手机端后台权限与记录保留-20260902.sql"));
            int from = schema.IndexOf("CREATE TABLE");
            sql(schema.Substring(from, schema.IndexOf(";", from) - from + 1));
            sql("DELETE FROM gameprizerecord; DELETE FROM games; DELETE FROM users; DELETE FROM userrobot;");
            sql("INSERT INTO games(GameId,Name,Enable,Num,GameType) VALUES(5,'火凤凰',1,0,1),(40,'水果拉霸',1,0,3),(3,'金蟾捕鱼',1,0,2),(2,'彩金单挑',1,0,4),(54,'麻将胡了',1,0,1),(901,'未知类别',1,0,0),(99,'关闭牌机',0,0,1)");
            sql("INSERT INTO users(ID,NAME,PWD,AGENCY) VALUES('rankplayer','真人昵称','x','')");
            sql("INSERT INTO userrobot(UserName,UserNick,PassW,Ico,Lev,Sex,Gold,IsRobot) VALUES('rankbot','机器人昵称','x',1,1,0,0,2)");
            for (int i = 1; i <= 35; i++)
                sql("INSERT INTO gameprizerecord(EventId,UserID,GameId,GameType,RoomId,TableId,CardType,Score,RecTime) VALUES('event" + i + "','" + (i % 2 == 0 ? "rankbot" : "rankplayer") + "',5,1,0,25,'普通中奖'," + i + ",'2026-10-27 12:00:00')");
            sql("INSERT INTO gameprizerecord(EventId,UserID,GameId,GameType,CardType,Score,RecTime) VALUES('closed','rankbot',99,0,'关闭游戏中奖',999999,'2026-10-27 13:00:00')");
            for (int i = 0; i < 35; i++)
                sql("INSERT INTO gameprizerecord(EventId,UserID,GameId,GameType,CardType,Score,RecTime) VALUES('hidden" + i + "','rankbot'," + new[] { 3, 2, 54, 901, 99 }[i % 5] + ",0,'隐藏游戏中奖',999999,'2026-10-27 14:00:00')");
            string migration = File.ReadAllText(Path.Combine(backendRoot, "Docs/sql/大厅排行榜最新30条-20261027.sql"));
            Action migrate = () => {
                int a = migration.IndexOf("DELIMITER $$"), b = migration.IndexOf("DELIMITER ;");
                sql(migration.Substring(0, a));
                sql(migration.Substring(a + 12, b - a - 12).Trim().TrimEnd('$'));
                sql(migration.Substring(b + 11));
            };
            migrate();
            migrate();
            Check(true, "migration and repeated migration");
            sql("ALTER TABLE gamerankhistory ADD COLUMN LineAgent VARCHAR(50) NOT NULL DEFAULT ''; ALTER TABLE gameprizerecord ADD COLUMN LineAgent VARCHAR(50) NOT NULL DEFAULT ''");
            using (var config = new HttpConfiguration())
            {
                config.MapHttpAttributeRoutes();
                config.Routes.MapHttpRoute("DefaultApi", "api/{controller}/{id}", new { id = RouteParameter.Optional });
                using (var server = new HttpServer(config))
                using (var http = new HttpClient(server) { BaseAddress = new Uri("http://localhost/") })
                {
                    Func<int, JObject> read = id => {
                        var response = http.GetAsync("api/RankingList/History?gameId=" + id).Result;
                        string body = response.Content.ReadAsStringAsync().Result;
                        Check(response.StatusCode == HttpStatusCode.OK, "HTTP route game=" + id + " " + (response.IsSuccessStatusCode ? "" : body));
                        if (id == 0) Check(response.Headers.CacheControl != null && response.Headers.CacheControl.NoStore, "snapshot must not be cached");
                        return JObject.Parse(body);
                    };
                    var snapshot = read(0);
                    var rows = (JArray)snapshot["Rows"];
                    Check(rows.Count == 30, "latest 30");
                    Check((string)rows[0]["Score"] == "35" && (string)rows[29]["Score"] == "6", "same-second ID order, oldest evicted; hidden wins do not consume LIMIT");
                    Check(rows.Any(r => (string)r["Nickname"] == "机器人昵称") && rows.Any(r => (string)r["Nickname"] == "真人昵称"), "all players and robots");
                    Check(rows.Any(r => (string)r["PlayerAccount"] == "ra..ot") && rows.Any(r => (string)r["PlayerAccount"] == "ra..er"), "accounts use fish anonymization instead of nicknames");
                    Check(rows.All(r => (string)r["Machine"] == "25号机"), "recorded one-based card machine");
                    Check(((JArray)snapshot["Games"]).Select(g => (int)g["GameId"]).SequenceEqual(new[] { 5, 40 }), "only enabled card and slot categories, excluding Mahjong fish bet and unknown");
                    foreach (int hidden in new[] { 3, 2, 54, 901, 99, 9876 })
                        Check(((JArray)read(hidden)["Rows"]).Count == 0, "explicit hidden or unknown game returns no rows: " + hidden);
                    var scoped = http.GetAsync("api/RankingList/History?gameId=0&account=rankplayer").Result;
                    Check(scoped.StatusCode == HttpStatusCode.OK && ((JArray)JObject.Parse(scoped.Content.ReadAsStringAsync().Result)["Rows"]).Count == 30,
                        "scoped public player uses same visibility filter");
                    Check(!snapshot.ToString().Contains("关闭牌机") && !snapshot.ToString().Contains("UserID") && !snapshot.ToString().Contains("ManualControl"), "closed-game filter and display-only fields");
                    sql("INSERT INTO gameprizerecord(EventId,UserID,GameId,GameType,Score,RecTime) VALUES('newwin','rankbot',5,1,400,'2026-10-27 12:00:01')");
                    // 与中心服同一环形写入 SQL，自动编号更新后同秒仍能区分新旧。
                    sql("SET @slot=(SELECT (Slot+1)%30 FROM gamerankhistory WHERE GameId=5 ORDER BY ID DESC LIMIT 1);");
                    sql("INSERT INTO gamerankhistory(GameId,Slot,EventId,UserID,CardType,Score,RecTime) VALUES(5,@slot,'newwin','rankbot','普通中奖',400,'2026-10-27 12:00:01') ON DUPLICATE KEY UPDATE ID=VALUES(ID),EventId=VALUES(EventId),UserID=VALUES(UserID),CardType=VALUES(CardType),Score=VALUES(Score),RecTime=VALUES(RecTime)");
                    rows = (JArray)read(5)["Rows"];
                    Check(rows.Count == 30 && (string)rows[0]["Score"] == "400" && (string)rows[29]["Score"] == "7", "31st win replaces oldest");
                    Check(((JArray)read(40)["Rows"]).Count == 0, "empty game");
                    Check(((JArray)read(99)["Rows"]).Count == 0, "disabled selected game");
                    sql("UPDATE games SET Enable=0 WHERE GameId=5");
                    snapshot = read(0);
                    Check(((JArray)snapshot["Rows"]).Count == 0 && ((JArray)snapshot["Games"]).Count == 1, "close game immediately hides players and bots");
                    sql("UPDATE games SET Enable=1 WHERE GameId=5");
                    Check(((JArray)read(5)["Rows"]).Count == 30, "reopen restores retained history");
                    sql("DELETE FROM gameprizerecord");
                    rows = (JArray)read(5)["Rows"];
                    Check(rows.Count == 30 && rows.All(r => (string)r["Machine"] == "--"), "detail cleanup preserves history and marks unavailable machine");
                    sql("INSERT INTO gamerankhistory(GameId,Slot,EventId,UserID,CardType,Score,RecTime) VALUES(40,0,'slot-win','rankbot','拉霸中奖',123,'2026-10-27 15:00:00')");
                    Check((string)read(40)["Rows"][0]["Score"] == "123", "slot wins remain visible");
                    sql("UPDATE games SET Enable=0 WHERE GameId IN (5,40)");
                    snapshot = read(0);
                    Check(((JArray)snapshot["Games"]).Count == 0 && ((JArray)snapshot["Rows"]).Count == 0, "no eligible games returns empty snapshot without invalid IN clause");
                    Check(http.GetAsync("api/RankingList/History?gameId=-1").Result.StatusCode == HttpStatusCode.BadRequest, "invalid game rejected");
                    Check(RankingListController.DisplayScore(40, long.MaxValue) == "9223372036854775807", "Int64 precision");
                    Check(RankingListController.DisplayNickname(null) == "匿名玩家", "missing nickname fallback");
                    Check(RankingListController.DisplayAccount("77123418") == "77..18"
                        && RankingListController.DisplayAccount(null) == ".."
                        && RankingListController.DisplayAccount("") == ".."
                        && RankingListController.DisplayAccount("7") == "7..7"
                        && RankingListController.DisplayAccount("77") == "77..77"
                        && RankingListController.DisplayAccount("a\u0301bcde\u0301") == "a\u0301b..de\u0301", "fish anonymity covers short empty and combining text");
                    Check(RankingListController.DisplayMachine(1, 0, 25) == "25号机"
                        && RankingListController.DisplayMachine(3, 0, 24) == "25号机"
                        && RankingListController.DisplayMachine(2, 2, 25) == "3场·25号机"
                        && RankingListController.DisplayMachine(1, 0, 0) == "--"
                        && RankingListController.DisplayMachine(3, null, null) == "--", "machine bases rooms and unavailable metadata");
                }
            }
            string storeTest = Path.Combine(serverRoot, "tests/_out/rank_history_store_test.exe");
            if (File.Exists(storeTest))
            {
                RunStoreTest("");
            }
            if (serveFixture) ServeFixture(db);
            sql("DROP DATABASE mth_rankhistory_validation");
        }
        Console.WriteLine("PASSED " + checks + " checks in " + (DateTime.UtcNow - start).TotalSeconds.ToString("F2") + " seconds");
    }

    static void RunStoreTest(string arguments)
    {
        string exe = Path.Combine(serverRoot, "tests/_out/rank_history_store_test.exe");
        var info = new System.Diagnostics.ProcessStartInfo(exe, arguments) { UseShellExecute = false, CreateNoWindow = true, RedirectStandardOutput = true };
        info.EnvironmentVariables["MTH_RANK_TEST_CONNECTION"] = "host=127.0.0.1;port=3306;user=root;password=123456;db=mth_rankhistory_validation;";
        info.EnvironmentVariables["PATH"] = Path.Combine(serverRoot, "bat/Wei-Release/ServerCenterNew/x64/Release") + ";" + Path.Combine(serverRoot, "third_party/pocolink/bin") + ";" + Environment.GetEnvironmentVariable("PATH");
        using (var process = System.Diagnostics.Process.Start(info))
        {
            Console.WriteLine(process.StandardOutput.ReadToEnd());
            process.WaitForExit();
            Check(process.ExitCode == 0, "production Poco transaction and frame decoding; exit=" + process.ExitCode);
        }
    }

    // 只在专用本地库开放回环 HTTP，用生产 WebAPI 路由和 Poco 写入驱动 Unity 的真实请求。
    static void ServeFixture(MySqlConnection db)
    {
        using (var command = new MySqlCommand("SELECT DATABASE()", db))
            if ((string)command.ExecuteScalar() != "mth_rankhistory_validation") throw new InvalidOperationException("Wrong fixture database");
        using (var command = new MySqlCommand("UPDATE games SET Enable=0 WHERE GameId<>777; UPDATE games SET Name='中奖联调',Enable=1,GameType=3 WHERE GameId=777", db)) command.ExecuteNonQuery();
        using (var config = new HttpConfiguration())
        using (var listener = new HttpListener())
        {
            config.MapHttpAttributeRoutes();
            config.Routes.MapHttpRoute("DefaultApi", "api/{controller}/{id}", new { id = RouteParameter.Optional });
            using (var server = new HttpServer(config))
            using (var http = new HttpClient(server) { BaseAddress = new Uri("http://localhost/") })
            {
                listener.Prefixes.Add("http://127.0.0.1:18081/");
                listener.Start();
                Console.WriteLine("FIXTURE_READY http://127.0.0.1:18081");
                while (true)
                {
                    var context = listener.GetContext();
                    string path = context.Request.Url.AbsolutePath;
                    bool stop = false;
                    byte[] content;
                    if (path.StartsWith("/__test/", StringComparison.Ordinal) && context.Request.HttpMethod == "POST")
                    {
                        if (path == "/__test/advance") RunStoreTest("--append");
                        else if (path == "/__test/close" || path == "/__test/open")
                            using (var command = new MySqlCommand("UPDATE games SET Enable=" + (path.EndsWith("open") ? "1" : "0") + " WHERE GameId=777", db)) command.ExecuteNonQuery();
                        else if (path == "/__test/stop") stop = true;
                        else context.Response.StatusCode = 404;
                        content = System.Text.Encoding.UTF8.GetBytes("{}");
                    }
                    else
                    {
                        using (var response = http.GetAsync(context.Request.RawUrl).Result)
                        {
                            context.Response.StatusCode = (int)response.StatusCode;
                            if (response.Headers.CacheControl != null)
                                context.Response.Headers["Cache-Control"] = response.Headers.CacheControl.ToString();
                            content = response.Content.ReadAsByteArrayAsync().Result;
                        }
                    }
                    context.Response.ContentType = "application/json; charset=utf-8";
                    context.Response.ContentLength64 = content.Length;
                    context.Response.OutputStream.Write(content, 0, content.Length);
                    context.Response.Close();
                    if (stop) break;
                }
            }
        }
    }
}
