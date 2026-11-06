using System;
using System.Collections.Generic;
using System.Configuration;
using System.Diagnostics;
using System.Linq;
using System.IO;
using System.IO.Pipes;
using System.Net;
using System.Net.Http;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using System.Web.Http;
using System.Web.Http.Controllers;
using System.Web.Http.Dispatcher;
using MySql.Data.MySqlClient;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using YYT.BLL.Services.GameServer;
using YYT.Web.Controllers.Api;

class AnnouncementHttpValidation
{
    static int checks, queries;
    static List<OnlinePlayerInfo> players = new List<OnlinePlayerInfo>();
    static void Check(bool ok, string name) { if (!ok) throw new Exception(name); checks++; Console.WriteLine("PASS " + name); }
    sealed class Activator : IHttpControllerActivator
    {
        public IHttpController Create(HttpRequestMessage request, HttpControllerDescriptor descriptor, Type type)
        {
            if (type != typeof(AnnouncementsController)) throw new Exception("Unexpected controller");
            return new AnnouncementsController(game => { queries++; return players; });
        }
    }
    static void Main(string[] args)
    {
        var log = new log4net.Appender.ConsoleAppender { Layout = new log4net.Layout.PatternLayout("%message%newline%exception") };
        log.ActivateOptions();
        log4net.Config.BasicConfigurator.Configure(log);
        try { Run(args[0]); }
        catch (Exception ex) { for (; ex != null; ex = ex.InnerException) Console.WriteLine(ex.GetType().Name + ": " + ex.Message); Thread.Sleep(100); Environment.ExitCode = 1; }
    }
    static void Run(string repository)
    {
        var timer = Stopwatch.StartNew();
        ValidatePipe(true);
        ValidatePipe(false);
        var connection = new MySqlConnectionStringBuilder(ConfigurationManager.ConnectionStrings["DbConnString"].ConnectionString);
        if (connection.Server != "127.0.0.1" || connection.Port != 33418
            || !System.Text.RegularExpressions.Regex.IsMatch(connection.Database, "^mth_announcement_validation_[0-9]+$"))
            throw new Exception("Requires dedicated loopback MySQL 33418 and isolated database");
        string database = connection.Database;
        connection.Database = "";
        using (var db = new MySqlConnection(connection.ConnectionString))
        {
            db.Open();
            Action<string> sql = q => { using (var cmd = new MySqlCommand(q, db)) cmd.ExecuteNonQuery(); };
            sql("CREATE DATABASE " + database + " CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci");
            sql("USE " + database);
            string snapshot = SqlSnapshot.Read(repository);
            foreach (string table in new[] { "games", "users", "userrobot", "admin", "gameprizerecord", "prizebroadcastoutbox", "roomtableconfig", "roomtableowner", "pararoom" })
                sql(SqlSnapshot.Table(snapshot, table));
            sql("INSERT INTO games(GameId,Name,Enable,Num,GameType) VALUES(5,'火凤凰',1,0,1)");
            sql("INSERT INTO users(ID,NAME,PWD,AGENCY) VALUES('noticeplayer','真人','x','')");
            sql("INSERT INTO userrobot(UserName,UserNick,PassW,Ico,Lev,Sex,Gold,IsRobot) VALUES('noticebot','机器人','x',1,1,0,0,2)");
            sql("INSERT INTO pararoom(ID,GAME_ID,NUM) VALUES(5000,5,67)");
            for (int i = 0; i < 67; i++)
            {
                sql("INSERT INTO roomtableconfig(GAME_ID,RoomIndex,TableIndex,TableName) VALUES(5,0," + i + ",'x')");
                if (i < 49) sql("INSERT INTO roomtableowner(GAME_ID,TableIndex,LineAgent) VALUES(5," + i + ",'#')");
            }
            string text = "恭喜玩家【机器人】在【火凤凰】【63】机台，打中【五鬼】，获得【80000分】，再次表示祝贺！";
            string human = text.Replace("【机器人】", "【真人】");
            string longText = text.Replace("【机器人】", "【" + new string('名', 130) + "】");
            string wireLong = YYT.BLL.EF.AnnouncementRules.WireText(longText);
            int eventNumber = 0;
            foreach (string content in new[] { text, human, longText })
            {
                bool robot = eventNumber != 1;
                string id = "notice-" + eventNumber++;
                sql("INSERT INTO gameprizerecord(EventId,UserID,GameId,GameType,RoomId,TableId,CardType,Score,IsBroadcast,IsManualControl,RecTime) VALUES('" + id + "','" + (robot ? "noticebot" : "noticeplayer") + "',5,1,0,63,'五鬼',80000,1," + (robot ? 2 : 0) + ",NOW())");
                using (var cmd = new MySqlCommand("INSERT INTO prizebroadcastoutbox(EventId,GameId,LineAgent,BroadcastText,CreatedAt) VALUES(@id,5,'',@text,NOW())", db))
                {
                    cmd.Parameters.AddWithValue("@id", id); cmd.Parameters.AddWithValue("@text", content); cmd.ExecuteNonQuery();
                }
            }
            using (var config = new HttpConfiguration())
            {
                Console.WriteLine("CONTROLLER=" + typeof(AnnouncementsController).FullName);
                config.IncludeErrorDetailPolicy = IncludeErrorDetailPolicy.Always;
                config.Services.Replace(typeof(IHttpControllerActivator), new Activator());
                config.MapHttpAttributeRoutes();
                using (var server = new HttpServer(config))
                using (var http = new HttpClient(server) { BaseAddress = new Uri("http://127.0.0.1/") })
                {
                    Func<string, string, JObject> validate = (content, account) =>
                    {
                        var body = new StringContent(JsonConvert.SerializeObject(new { Account = account, Content = content }), Encoding.UTF8, "application/json");
                        var response = http.PostAsync("api/Announcements/Validate", body).Result;
                        string json = response.Content.ReadAsStringAsync().Result;
                        Check(response.StatusCode == HttpStatusCode.OK, "HTTP 200 validation" + (response.StatusCode == HttpStatusCode.OK ? "" : ": " + response.StatusCode + " " + json));
                        Check(response.Headers.CacheControl != null && response.Headers.CacheControl.NoStore, "no cached occupancy decisions");
                        Check(!json.Contains("TableId") && !json.Contains("UserID") && !json.Contains("noticebot"), "response contains no account or seat data");
                        return JObject.Parse(json);
                    };
                    JObject result = validate(text, "noticeplayer");
                    Check((bool)result["Play"] && ((string)result["Content"]).Contains("【14】机台"), "queued raw63 renders visible14 when empty");
                    players.Add(new OnlinePlayerInfo { GameID = 5, TableId = 62, IsSitDown = true });
                    Check(!(bool)validate(text, "noticeplayer")["Play"], "human took real table62 after enqueue");
                    players[0].TableId = 63;
                    Check((bool)validate(text, "noticeplayer")["Play"], "another actual table is not confused with old text63");
                    players[0].TableId = 62; players[0].IsSitDown = false;
                    Check((bool)validate(text, "noticeplayer")["Play"], "selection-stage stale table field is not a seated human");
                    players[0].IsSitDown = null;
                    Check(!(bool)validate(text, "noticeplayer")["Play"], "old center missing sitting flag fails closed");
                    players = null;
                    Check(!(bool)validate(text, "noticeplayer")["Play"], "unavailable center fails closed");
                    int beforeHuman = queries;
                    Check((bool)validate(human, "noticeplayer")["Play"] && queries == beforeHuman, "real prize unaffected by robot occupancy gate");
                    players = new List<OnlinePlayerInfo>();
                    Check((bool)validate(wireLong, "noticeplayer")["Play"], "500-byte UTF8 wire text finds original event");
                    Check(!(bool)validate(text, "missing-account")["Play"], "unknown account rejected");
                    Check(!(bool)validate("unmatched' OR 1=1 --", "noticeplayer")["Play"], "unknown or injected text cannot invent an event");
                    sql("UPDATE games SET Enable=0 WHERE GameId=5");
                    Check(!(bool)validate(text, "noticeplayer")["Play"], "closed game rejected");
                    sql("UPDATE games SET Enable=1 WHERE GameId=5");
                    sql("INSERT INTO roomtableowner(GAME_ID,TableIndex,LineAgent) VALUES(5,62,'#')");
                    Check(!(bool)validate(text, "noticeplayer")["Play"], "recycled queued machine rejected");
                    sql("DELETE FROM roomtableowner WHERE GAME_ID=5 AND TableIndex=62");
                    sql("UPDATE prizebroadcastoutbox SET CreatedAt=DATE_SUB(NOW(),INTERVAL 301 SECOND)");
                    Check(!(bool)validate(text, "noticeplayer")["Play"], "expired queued event rejected");
                    Check(Convert.ToInt32(new MySqlCommand("SELECT COUNT(*) FROM gameprizerecord WHERE Score=80000 AND TableId=63", db).ExecuteScalar()) == 3,
                        "validation never rewrites stored scores or actual tables");
                }
            }
            sql("DROP DATABASE " + database);
        }
        Console.WriteLine("PASS " + checks + " HTTP/EF/MySQL checks; seconds=" + timer.Elapsed.TotalSeconds.ToString("F3"));
    }

    static void ValidatePipe(bool connected)
    {
        string name = ConfigurationManager.AppSettings["pipeName"];
        if (ConfigurationManager.AppSettings["serverName"] != "." || !name.StartsWith("mth_announcement_validation_"))
            throw new Exception("Requires isolated local validation pipe");
        using (var pipe = new NamedPipeServerStream(name, PipeDirection.InOut, 1, PipeTransmissionMode.Byte, PipeOptions.Asynchronous))
        {
            string received = null;
            var serve = Task.Run(() => {
                pipe.WaitForConnection();
                using (var reader = new StreamReader(pipe, Encoding.UTF8, true, 1024, true))
                using (var writer = new StreamWriter(pipe, new UTF8Encoding(false), 1024, true) { AutoFlush = true })
                {
                    received = reader.ReadLine().TrimEnd('\0');
                    writer.WriteLine("{\"Version\":1,\"AvailableGames\":" + (connected ? "[5]" : "[]") + ",\"Players\":[]}");
                }
            });
            var result = new PipeGameServerClient().QueryAnnouncementOccupants(5);
            Check(serve.Wait(5000), "actual QN pipe round-trip completed");
            Check(received == "QN", "real command config sends QN");
            Check(connected ? result != null && result.Count == 0 : result == null,
                connected ? "connected empty snapshot allows occupancy check" : "disconnected game never becomes empty occupancy");
        }
    }
}
