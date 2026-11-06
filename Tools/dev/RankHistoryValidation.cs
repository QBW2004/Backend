using System;
using System.IO;
using System.Configuration;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using System.Xml.Linq;
using MySql.Data.MySqlClient;
using Newtonsoft.Json.Linq;
using YYT.Web.Controllers.Api;
using YYT.BLL.EF;

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
        var connection = new MySqlConnectionStringBuilder(ConfigurationManager.ConnectionStrings["DbConnString"].ConnectionString);
        if (connection.Server != "127.0.0.1" || connection.Port != 33308 || connection.Database != "mth_rankhistory_validation")
            throw new Exception("Requires isolated loopback MySQL on port 33308");
        connection.Database = "";
        using (var db = new MySqlConnection(connection.ConnectionString))
        {
            db.Open();
            Action<string> sql = q => { using (var cmd = new MySqlCommand(q, db)) cmd.ExecuteNonQuery(); };
            sql("CREATE DATABASE mth_rankhistory_validation CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci");
            sql("USE mth_rankhistory_validation");
            string schemaDump = SqlSnapshot.Read(backendRoot);
            foreach (string table in new[] { "games", "users", "userrobot", "admin", "gameprizerecord", "gamerankhistory", "prizebroadcastoutbox", "roomtableconfig", "roomtableowner", "pararoom" })
                sql(SqlSnapshot.Table(schemaDump, table));
            string tableScopeMigration = File.ReadAllText(Path.Combine(backendRoot, "Tools/db/rank-history-table-scope-20261106.sql"));
            sql(tableScopeMigration);
            sql("INSERT INTO roomtableconfig(GAME_ID,RoomIndex,TableIndex,TableName) VALUES(40,0,0,'1')");
            sql("INSERT INTO pararoom(ID,GAME_ID,NUM) VALUES(5000,5,67)");
            for (int i = 0; i < 67; i++)
            {
                sql("INSERT INTO roomtableconfig(GAME_ID,RoomIndex,TableIndex,TableName) VALUES(5,0," + i + ",'" + (i - 48) + "')");
                if (i < 49) sql("INSERT INTO roomtableowner(GAME_ID,TableIndex,LineAgent) VALUES(5," + i + ",'#')");
            }
            sql("INSERT INTO pararoom(ID,GAME_ID,NUM) VALUES(15000,15,42)");
            for (int i = 0; i < 42; i++)
            {
                sql("INSERT INTO roomtableconfig(GAME_ID,RoomIndex,TableIndex,TableName) VALUES(15,0," + i + ",'" + (i - 23) + "')");
                if (i < 24) sql("INSERT INTO roomtableowner(GAME_ID,TableIndex,LineAgent) VALUES(15," + i + ",'#')");
            }
            using (var ef = new GameDbContext())
            {
                var display = TableDisplayMap.Load(ef, new[] { 5, 15, 0 });
                Check(display.OnlineLabel(15, 24) == "1", "a18001 raw index 24 is visible table 1");
                Check(display.OnlineLabel(5, 62) == "14", "online and history share visible table 14");
                Check(display.OnlineLabel(15, 23) == "--" && display.OnlineLabel(0, 0) == "--", "recycled and hall have no machine");
            }
            sql("INSERT INTO games(GameId,Name,Enable,Num,GameType) VALUES(5,'火凤凰',1,0,1),(40,'水果拉霸',1,0,3),(3,'金蟾捕鱼',1,0,2),(2,'彩金单挑',1,0,4),(54,'麻将胡了',1,0,1),(901,'未知类别',1,0,0),(99,'关闭牌机',0,0,1)");
            sql("INSERT INTO users(ID,NAME,PWD,AGENCY) VALUES('rankplayer','真人昵称','x','')");
            sql("INSERT INTO userrobot(UserName,UserNick,PassW,Ico,Lev,Sex,Gold,IsRobot) VALUES('rankbot','机器人昵称','x',1,1,0,0,2)");
            for (int i = 1; i <= 35; i++)
                sql("INSERT INTO gameprizerecord(EventId,UserID,GameId,GameType,RoomId,TableId,CardType,Score,RecTime) VALUES('event" + i + "','" + (i % 2 == 0 ? "rankbot" : "rankplayer") + "',5,1,0,63,'大奖'," + i + ",'2026-10-27 12:00:00')");
            sql("INSERT INTO gameprizerecord(EventId,UserID,GameId,GameType,CardType,Score,RecTime) VALUES('closed','rankbot',99,0,'关闭游戏中奖',999999,'2026-10-27 13:00:00')");
            for (int i = 0; i < 35; i++)
                sql("INSERT INTO gameprizerecord(EventId,UserID,GameId,GameType,CardType,Score,RecTime) VALUES('hidden" + i + "','rankbot'," + new[] { 3, 2, 54, 901, 99 }[i % 5] + ",0,'隐藏游戏中奖',999999,'2026-10-27 14:00:00')");
            // Current ring-schema fixture: the 35 qualifying events retain the latest 30 slots.
            for (int i = 1; i <= 35; i++)
                sql("INSERT INTO gamerankhistory(GameId,Slot,EventId,UserID,CardType,Score,RecTime,IsBigWin) VALUES(5," + ((i-1)%30) + ",'event" + i + "','" + (i%2==0 ? "rankbot" : "rankplayer") + "','大奖'," + i + ",'2026-10-27 12:00:00',1) ON DUPLICATE KEY UPDATE ID=VALUES(ID),EventId=VALUES(EventId),UserID=VALUES(UserID),Score=VALUES(Score),RecTime=VALUES(RecTime),IsBigWin=VALUES(IsBigWin)");
            sql(tableScopeMigration);
            sql(tableScopeMigration);
            Check(Convert.ToInt32(new MySqlCommand("SELECT COUNT(*) FROM gamerankhistory WHERE RoomId=0 AND TableId=63", db).ExecuteScalar()) == 30,
                "repeatable migration backfills only existing event coordinates");
            Check(Convert.ToInt32(new MySqlCommand("SELECT COUNT(*) FROM gamerankhistory WHERE GameId=5", db).ExecuteScalar()) == 30, "current ring schema retains 30 slots");
            sql(SqlSnapshot.Table(schemaDump, "gamerankhistory", true));
            Check(Convert.ToInt32(new MySqlCommand("SELECT COUNT(*) FROM gamerankhistory WHERE GameId=5", db).ExecuteScalar()) == 30, "existing-table initialization preserves rank history");
            sql("UPDATE gameprizerecord SET IsBroadcast=1,Multiplier=50 WHERE EventId LIKE 'event%'");
            sql("INSERT INTO gameprizerecord(EventId,UserID,GameId,GameType,Score,IsBroadcast,RecTime) VALUES('old-small','rankbot',40,3,99999,0,'2026-10-28 00:00:00')");
            sql("INSERT INTO gamerankhistory(GameId,Slot,EventId,UserID,Score,RecTime) VALUES(40,29,'old-small','rankbot',99999,'2026-10-28 00:00:00')");
            Check(Convert.ToInt32(new MySqlCommand("SELECT IsBigWin FROM gamerankhistory WHERE EventId='old-small'", db).ExecuteScalar()) == 0, "ordinary win defaults to unqualified and is filtered by the API");
            using (var config = new HttpConfiguration())
            {
                config.MapHttpAttributeRoutes();
                config.Routes.MapHttpRoute("DefaultApi", "api/{controller}/{id}", new { id = RouteParameter.Optional });
                using (var server = new HttpServer(config))
                using (var http = new HttpClient(server) { BaseAddress = new Uri("http://localhost/") })
                {
                    Func<int, JObject> read = id => {
                        var response = http.GetAsync("api/RankingList/History?account=rankplayer&gameId=" + id).Result;
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
                    Check(rows.All(r => (string)r["PlayerAccount"] == (string)r["Nickname"])
                        && !snapshot.ToString().Contains("rankbot") && !snapshot.ToString().Contains("rankplayer"),
                        "old and new display fields contain full nicknames, never login accounts");
                    Check(rows.All(r => (string)r["Machine"] == "14号机"), "player and robot raw 63 both map to visible 14 after 49 recycled tables");
                    Check(Convert.ToInt32(new MySqlCommand("SELECT MIN(TableId) FROM gameprizerecord WHERE GameId=5", db).ExecuteScalar()) == 63, "history raw machine is unchanged");
                    Check(((JArray)snapshot["Games"]).Select(g => (int)g["GameId"]).SequenceEqual(new[] { 5, 40 }), "only enabled card and slot categories, excluding Mahjong fish bet and unknown");
                    foreach (int hidden in new[] { 3, 2, 54, 901, 99, 9876 })
                        Check(((JArray)read(hidden)["Rows"]).Count == 0, "explicit hidden or unknown game returns no rows: " + hidden);
                    var scoped = http.GetAsync("api/RankingList/History?gameId=0&account=rankplayer").Result;
                    Check(scoped.StatusCode == HttpStatusCode.OK && ((JArray)JObject.Parse(scoped.Content.ReadAsStringAsync().Result)["Rows"]).Count == 30,
                        "scoped public player uses same visibility filter");
                    Check(!snapshot.ToString().Contains("关闭牌机") && !snapshot.ToString().Contains("UserID") && !snapshot.ToString().Contains("ManualControl"), "closed-game filter and display-only fields");
                    sql("INSERT INTO gameprizerecord(EventId,UserID,GameId,GameType,RoomId,TableId,Score,RecTime) VALUES('newwin','rankbot',5,1,0,63,400,'2026-10-27 12:00:01')");
                    // 与中心服同一环形写入 SQL，自动编号更新后同秒仍能区分新旧。
                    sql("SET @slot=(SELECT (Slot+1)%30 FROM gamerankhistory WHERE GameId=5 ORDER BY ID DESC LIMIT 1);");
                    sql("INSERT INTO gamerankhistory(GameId,Slot,EventId,UserID,CardType,Score,RecTime,IsBigWin) VALUES(5,@slot,'newwin','rankbot','大奖',400,'2026-10-27 12:00:01',1) ON DUPLICATE KEY UPDATE ID=VALUES(ID),EventId=VALUES(EventId),UserID=VALUES(UserID),CardType=VALUES(CardType),Score=VALUES(Score),RecTime=VALUES(RecTime)");
                    sql(tableScopeMigration);
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
                    Check(rows.Count == 30 && rows.All(r => (string)r["Machine"] == "14号机"), "detail cleanup preserves durable table scope and machine");
                    sql("INSERT INTO gamerankhistory(GameId,Slot,EventId,UserID,CardType,Score,RecTime,IsBigWin,RoomId,TableId) VALUES(40,0,'slot-win','rankbot','拉霸中奖',123,'2026-10-27 15:00:00',1,0,0)");
                    Check((string)read(40)["Rows"][0]["Score"] == "123", "slot wins remain visible");
                    sql("INSERT INTO gamerankhistory(GameId,Slot,EventId,UserID,CardType,Score,RecTime,IsBigWin) VALUES(40,1,'zero-extra','rankbot','额外玩法',0,'2026-10-27 16:00:00',1),(40,2,'legacy-small','rankbot','普通小奖',999999,'2026-10-27 17:00:00',0)");
                    sql("UPDATE gamerankhistory SET RoomId=0,TableId=0 WHERE GameId=40");
                    rows = (JArray)read(40)["Rows"];
                    Check(rows.Count == 2 && (string)rows[0]["Score"] == "0", "zero-score qualified extra is ranked; large ordinary win is excluded before LIMIT");
                    sql("UPDATE games SET Enable=0 WHERE GameId IN (5,40)");
                    snapshot = read(0);
                    Check(((JArray)snapshot["Games"]).Count == 0 && ((JArray)snapshot["Rows"]).Count == 0, "no eligible games returns empty snapshot without invalid IN clause");
                    Check(http.GetAsync("api/RankingList/History?gameId=-1").Result.StatusCode == HttpStatusCode.BadRequest, "invalid game rejected");
                    Check(RankingListController.DisplayScore(40, long.MaxValue) == "9223372036854775807", "Int64 precision");
                    Check(RankingListController.DisplayNickname(null) == "未知玩家", "missing nickname never exposes account");
                    Check(RankingListController.DisplayNickname("玩家名称测试") == "玩家名称测试"
                        && RankingListController.DisplayNickname("") == "未知玩家"
                        && RankingListController.DisplayNickname(" ") == "未知玩家"
                        && RankingListController.DisplayNickname("7") == "7"
                        && RankingListController.DisplayNickname("77") == "77"
                        && RankingListController.DisplayNickname("a\u0301bcde\u0301") == "a\u0301bcde\u0301", "full nickname display handles missing short and combining text");
                    CheckTableScopes(http, sql);
                }
            }
            string storeTest = StoreTestExecutable();
            if (File.Exists(storeTest))
            {
                RunStoreTest("");
            }
            else if (!string.IsNullOrEmpty(Environment.GetEnvironmentVariable("MTH_RANK_STORE_TEST_EXE")))
                throw new FileNotFoundException("Configured rank store test executable is missing.", storeTest);
            if (serveFixture) ServeFixture(db);
            sql("DROP DATABASE mth_rankhistory_validation");
        }
        Console.WriteLine("PASSED " + checks + " checks in " + (DateTime.UtcNow - start).TotalSeconds.ToString("F2") + " seconds");
    }

    static void CheckTableScopes(HttpClient http, Action<string> sql)
    {
        sql("UPDATE games SET Enable=1 WHERE GameId IN (5,40)");
        sql("INSERT INTO games(GameId,Name,Enable,Num,GameType) VALUES(15,'大字板',1,0,1)");
        sql("INSERT INTO admin(ID,PWD,AGENCY,PRIV,PlayableGames) VALUES('mo','x','',1,'5,15'),('other','x','',1,'5,15,40')");
        sql("INSERT INTO users(ID,NAME,PWD,AGENCY) VALUES('mo-player','莫线玩家','x','mo'),('other-player','另一线玩家','x','other')");
        sql("INSERT INTO roomtableowner(GAME_ID,TableIndex,LineAgent) VALUES(5,49,'mo'),(5,50,'other'),(15,25,'other')");
        sql("DELETE FROM gamerankhistory");
        Action<int, int, string, string, int> add = (game, slot, line, label, table) => sql(
            "INSERT INTO gamerankhistory(GameId,Slot,LineAgent,EventId,UserID,CardType,Score,RecTime,IsBigWin,RoomId,TableId) VALUES("
            + game + "," + slot + ",'" + line + "','scope-" + game + "-" + label + "','rankbot','" + label + "',1,NOW(),1,0," + table + ")");
        add(5, 0, "mo", "mo-private", 50);
        add(5, 0, "other", "other-private", 51);
        add(5, 0, "", "public-robot", 52);
        add(5, 1, "mo", "mo-old-public", 52);
        add(5, 1, "other", "other-old-public", 52);
        for (int i = 1; i < 30; i++) add(5, i, "", "public-new-" + i, 52);
        add(15, 0, "mo", "mo-public", 25);
        add(15, 0, "other", "other-public", 25);
        add(15, 0, "", "public-robot", 25);
        add(15, 1, "other", "other-private", 26);
        add(40, 0, "", "forbidden-game", 0);
        Func<int, string, JObject> read = (game, account) => {
            var response = http.GetAsync("api/RankingList/History?gameId=" + game + "&account=" + account).Result;
            Check(response.StatusCode == HttpStatusCode.OK, "scoped HTTP " + game + " / " + account);
            return JObject.Parse(response.Content.ReadAsStringAsync().Result);
        };
        var mo = read(5, "mo-player");
        Check(((JArray)mo["Games"]).Select(g => (int)g["GameId"]).SequenceEqual(new[] { 5, 15 }), "mo categories honor playable games");
        Check(((JArray)mo["Rows"]).Count == 1 && (string)mo["Rows"][0]["Prize"] == "mo-private"
            && (string)mo["Rows"][0]["Machine"] == "1号机", "mo Phenix only its actual exclusive table");
        var publicRows = (JArray)read(15, "mo-player")["Rows"];
        Check(publicRows.Count == 3 && publicRows.All(r => (string)r["Machine"] == "1号机")
            && publicRows.Any(r => (string)r["Prize"] == "other-public"), "Dazhi public includes all agency humans and robots, excludes private");
        Check(((JArray)read(40, "mo-player")["Rows"]).Count == 0, "direct forbidden game request denied");
        Check(((JArray)read(5, "other-player")["Rows"]).Count == 1, "other private line isolated");
        CheckAnnouncements(sql);
        Check(http.GetAsync("api/RankingList/History?gameId=5").Result.StatusCode == HttpStatusCode.BadRequest, "missing account cannot bypass table isolation");
        Check(http.GetAsync("api/RankingList/History?account=missing").Result.StatusCode == HttpStatusCode.BadRequest, "unknown player cannot become public viewer");
        sql("UPDATE roomtableowner SET LineAgent='#' WHERE GAME_ID=5 AND LineAgent='mo'");
        var recalled = (JArray)read(5, "mo-player")["Rows"];
        Check(recalled.Count == 30 && recalled.All(r => ((string)r["Prize"]).Contains("public")), "recall switches to public and hides recycled table history");
        sql("UPDATE roomtableowner SET LineAgent='mo' WHERE GAME_ID=5 AND TableIndex=50");
        Check(((JArray)read(5, "mo-player")["Rows"]).Count == 0, "reassigned table rejects previous owner history");
        sql("UPDATE gamerankhistory SET RoomId=NULL,TableId=NULL WHERE GameId=15 AND LineAgent='mo'");
        Check(((JArray)read(15, "mo-player")["Rows"]).Count == 2, "unknown historical position fails closed without clearing history");
        sql("INSERT INTO games(GameId,Name,Enable,Num,GameType) VALUES(52,'旧水果',1,0,3)");
        sql("INSERT INTO roomtableconfig(GAME_ID,RoomIndex,TableIndex,TableName) VALUES(52,0,0,'1')");
        sql("UPDATE admin SET PlayableGames='5,15,52' WHERE ID='mo'");
        add(52, 0, "", "legacy-slot-zero", 0);
        Check(((JArray)read(52, "mo-player")["Rows"]).Count == 1, "raw coordinate convention follows game type, not three-slot ID list");
        sql("UPDATE admin SET PlayableGames='15' WHERE ID='mo'");
        Check(((JArray)read(5, "mo-player")["Rows"]).Count == 0, "playable changes apply on next snapshot");
        sql("UPDATE games SET Enable=0 WHERE GameId=15");
        var closed = read(0, "mo-player");
        Check(((JArray)closed["Games"]).Count == 0 && ((JArray)closed["Rows"]).Count == 0, "closed game hides category and rows");
        sql("DELETE FROM gamerankhistory");
    }

    static void CheckAnnouncements(Action<string> sql)
    {
        Func<int, string, int, string, bool> validate = (game, owner, table, viewer) => {
            string id = "scope-ann-" + game + "-" + table;
            string content = "恭喜玩家【机器人】在【游戏】【1】机台，打中【大奖】，获得【1分】，再次表示祝贺！";
            sql("DELETE FROM gameprizerecord WHERE EventId='" + id + "'");
            sql("DELETE FROM prizebroadcastoutbox WHERE EventId='" + id + "'");
            sql("INSERT INTO gameprizerecord(EventId,UserID,GameId,GameType,RoomId,TableId,LineAgent,CardType,Score,IsBroadcast,IsManualControl,RecTime) VALUES('"
                + id + "','rankbot'," + game + "," + (game == 40 ? 3 : 1) + ",0," + table + ",'" + owner + "','大奖',1,1,2,NOW())");
            sql("INSERT INTO prizebroadcastoutbox(EventId,GameId,LineAgent,BroadcastText,CreatedAt) VALUES('" + id + "'," + game + ",'" + owner + "','" + content + "',NOW())");
            using (var controller = new AnnouncementsController(gameId => new System.Collections.Generic.List<YYT.BLL.Services.GameServer.OnlinePlayerInfo>()))
            using (var config = new HttpConfiguration())
            using (var request = new HttpRequestMessage(HttpMethod.Post, "http://localhost/api/Announcements/Validate"))
            {
                controller.Request = request; controller.Configuration = config;
                var result = controller.Validate(new AnnouncementsController.ValidateRequest { Account = viewer, Content = content });
                var response = result.ExecuteAsync(System.Threading.CancellationToken.None).Result;
                bool play = (bool)JObject.Parse(response.Content.ReadAsStringAsync().Result)["Play"];
                sql("DELETE FROM gameprizerecord WHERE EventId='" + id + "'");
                sql("DELETE FROM prizebroadcastoutbox WHERE EventId='" + id + "'");
                return play;
            }
        };
        Check(validate(5, "mo", 50, "mo-player"), "playback API accepts mo exclusive actual table");
        Check(!validate(5, "", 52, "mo-player"), "playback API rejects public Phenix for mo");
        Check(!validate(5, "other", 51, "mo-player"), "playback API rejects another private line");
        Check(validate(15, "", 25, "mo-player"), "playback API accepts public Dazhi");
        Check(!validate(40, "", 0, "mo-player"), "playback API rejects robot game outside playable list");
    }

    static string StoreTestExecutable()
    {
        string configured = Environment.GetEnvironmentVariable("MTH_RANK_STORE_TEST_EXE");
        return string.IsNullOrEmpty(configured) ? Path.Combine(serverRoot, "tests/_out/rank_history_store_test.exe") : Path.GetFullPath(configured);
    }

    static void RunStoreTest(string arguments)
    {
        string exe = StoreTestExecutable();
        var info = new System.Diagnostics.ProcessStartInfo(exe, arguments) { UseShellExecute = false, CreateNoWindow = true, RedirectStandardOutput = true };
        var connection = new MySqlConnectionStringBuilder(ConfigurationManager.ConnectionStrings["DbConnString"].ConnectionString);
        info.EnvironmentVariables["MTH_RANK_TEST_CONNECTION"] = "host=" + connection.Server + ";port=" + connection.Port + ";user=" + connection.UserID + ";password=" + connection.Password + ";db=" + connection.Database + ";";
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
        using (var command = new MySqlCommand("UPDATE games SET Enable=0 WHERE GameId<>14; UPDATE games SET Name='中奖联调',Enable=1,GameType=3 WHERE GameId=14", db)) command.ExecuteNonQuery();
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
                            using (var command = new MySqlCommand("UPDATE games SET Enable=" + (path.EndsWith("open") ? "1" : "0") + " WHERE GameId=14", db)) command.ExecuteNonQuery();
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
