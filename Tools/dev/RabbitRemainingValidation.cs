// 独立 MySQL + 实际 BLL/MVC/WebAPI 回归；不会连接线上，测试库在 finally 中删除。
using System;
using System.Configuration;
using System.Data.Entity;
using System.IO;
using System.Text;
using System.Web;
using System.Web.Mvc;
using MySql.Data.MySqlClient;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using YYT.BLL.EF;
using YYT.Web.Areas.Game.Controllers;
using YYT.Web.Controllers.Api;

class RabbitRemainingValidation
{
    static int checks;
    static MySqlConnection db;
    static void Check(bool ok, string label) { if (!ok) throw new Exception("FAIL: " + label); checks++; }
    static void Sql(string sql) { using (var c = new MySqlCommand(sql, db)) c.ExecuteNonQuery(); }
    static DateTime Utc(DateTime bj) { return DateTime.SpecifyKind(bj.AddHours(-8), DateTimeKind.Utc); }
    static void Award(DateTime bj, int game, string type, int robot)
    {
        using (var c = new MySqlCommand("INSERT INTO gameprizerecord(GameId,CardType,RecTime,IsManualControl) VALUES(@g,@t,@d,@r)", db))
        {
            c.Parameters.AddWithValue("@g", game); c.Parameters.AddWithValue("@t", type);
            c.Parameters.AddWithValue("@d", Utc(bj).ToLocalTime()); c.Parameters.AddWithValue("@r", robot);
            c.ExecuteNonQuery();
        }
    }
    static void Award(DateTime bj) { Award(bj, 55, RabbitRaceActivity.PrizeName, 0); }
    class Response : HttpResponseBase
    {
        public StringWriter Body = new StringWriter();
        public override string ContentType { get; set; }
        public override Encoding ContentEncoding { get; set; }
        public override void Write(string value) { Body.Write(value); }
    }
    class Request : HttpRequestBase { public override string HttpMethod { get { return "POST"; } } }
    class Context : HttpContextBase
    {
        public Response Output = new Response();
        public override HttpResponseBase Response { get { return Output; } }
        public override HttpRequestBase Request { get { return new Request(); } }
    }
    static JObject Admin()
    {
        var context = new Context();
        new ActivityConfigController().GetRabbitRace().ExecuteResult(new ControllerContext { HttpContext = context });
        var result = JObject.Parse(context.Output.Body.ToString());
        Check((int)result["code"] == 1 && (bool)result["ready"], "actual MVC JSON ready: " + result);
        return result;
    }
    static JObject Client()
    {
        var result = JObject.Parse(JsonConvert.SerializeObject(new RabbitRaceActivityController().Get("quota_test")));
        Check((int)result["code"] == 10000, "actual WebAPI success");
        return (JObject)result["datas"];
    }
    static void Save(RabbitRaceActivity cfg)
    {
        using (var ef = new GameDbContext()) ActivityConfigs.Save(ef, RabbitRaceActivity.Key, 55, cfg.Enabled, cfg.ToJson(), "isolated_test");
    }
    static void Run()
    {
        var day = RabbitRaceActivity.BeijingNow(DateTime.UtcNow).Date;
        var cfg = RabbitRaceActivity.Default(); cfg.Enabled = true; cfg.StartMinute = 720;
        // 复现线上：凌晨 1 次，改为 12 点开始之后 49 次，游戏服台账已扣满 50。
        Award(day.AddHours(1));
        for (int i = 0; i < 49; i++) Award(day.AddHours(12).AddSeconds(i), 55, RabbitRaceActivity.PrizeName, i % 2 == 0 ? 2 : 0);
        Award(day.AddSeconds(-1));
        Award(day.AddHours(13), 5, RabbitRaceActivity.PrizeName, 0);
        Award(day.AddHours(13), 55, "小四梅", 0);
        using (var ef = new GameDbContext())
        {
            int used = ActivityConfigs.CountUsed(ef, cfg, Utc(day.AddHours(13)));
            Check(used == 50, "same-day start change must count 50 awards, got " + used);
            cfg.StartMinute = 600;
            Check(ActivityConfigs.CountUsed(ef, cfg, Utc(day.AddHours(13))) == 50, "opening time cannot refund quota");
            cfg.StartMinute = 720;
            Check(ActivityConfigs.CountUsed(ef, cfg, Utc(day.AddHours(9))) == 1, "before opening uses previous round");
            Check(ActivityConfigs.CountUsed(ef, cfg, Utc(day.AddHours(22))) == 50, "closing cannot restore quota");
            Check(ActivityConfigs.CountUsed(ef, cfg, Utc(day.AddDays(1))) == 50, "midnight cannot restore quota");
            Check(ActivityConfigs.CountUsed(ef, cfg, Utc(day.AddDays(1).AddHours(12).AddSeconds(-1))) == 50, "exhausted until next opening");
            Check(ActivityConfigs.CountUsed(ef, cfg, Utc(day.AddDays(1).AddHours(12))) == 0, "next opening restores quota");
            Award(day.AddDays(1).AddHours(12));
            Check(ActivityConfigs.CountUsed(ef, cfg, Utc(day.AddDays(1).AddHours(13))) == 1, "new round only counts new awards");
        }
        // 实际 Controller 使用当前时钟，零点开始保证此组回包断言在任意运行时间均属于当天。
        cfg.StartMinute = 0;
        Save(cfg);
        var admin = Admin(); var client = Client();
        File.WriteAllText(Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "remaining-zero.json"), admin.ToString());
        File.WriteAllText(Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "client-zero.json"), client.ToString());
        Check((int)admin["usedToday"] == 50 && (int)admin["remainingToday"] == 0, "admin wire JSON explicitly has zero");
        Check((bool)client["show"] && (int)client["remaining"] == 0, "client wire JSON explicitly has zero");
        cfg.DailyQuota = 100; Save(cfg);
        Check((int)Admin()["remainingToday"] == 50 && (int)Client()["remaining"] == 50, "quota 50 to 100 keeps 50 spent, leaving 50");
        cfg.DailyQuota = 49; Save(cfg);
        Check((int)Admin()["remainingToday"] == 0 && (int)Client()["remaining"] == 0, "lower quota clamps both to zero");
        cfg.Enabled = false; Save(cfg);
        Check(!(bool)Admin()["enabled"] && !(bool)Client()["show"], "disabled visibility unchanged");
        cfg.Enabled = true; Save(cfg);
        Check((int)Admin()["remainingToday"] == 0 && (int)Client()["remaining"] == 0, "toggle cannot reset spent quota");
        cfg.Enabled = true; cfg.StartMinute = 1320; cfg.EndMinute = 120;
        Sql("DELETE FROM gameprizerecord");
        Award(day.AddHours(2).AddSeconds(-1)); // previous quota day
        Award(day.AddHours(2)); // first instant of this quota day
        Award(day.AddHours(21)); // before a changed opening time
        Award(day.AddHours(22));
        Award(day.AddDays(1).AddHours(2).AddSeconds(-1));
        Award(day.AddDays(1).AddHours(2)); // next quota day
        using (var ef = new GameDbContext())
        {
            Check(ActivityConfigs.CountUsed(ef, cfg, Utc(day.AddHours(1))) == 1, "overnight early hours use previous quota day");
            Check(ActivityConfigs.CountUsed(ef, cfg, Utc(day.AddHours(2))) == 1, "overnight closing keeps previous round");
            Check(ActivityConfigs.CountUsed(ef, cfg, Utc(day.AddHours(22).AddSeconds(-1))) == 1, "overnight waiting keeps previous round");
            Check(ActivityConfigs.CountUsed(ef, cfg, Utc(day.AddHours(22))) == 4, "overnight begins next round at opening");
            Check(ActivityConfigs.CountUsed(ef, cfg, Utc(day.AddDays(1).AddHours(1))) == 4, "overnight includes both dates and earlier start");
            Check(ActivityConfigs.CountUsed(ef, cfg, Utc(day.AddDays(1).AddHours(2))) == 4, "overnight after closing retains used quota");
            Check(ActivityConfigs.CountUsed(ef, cfg, Utc(day.AddDays(1).AddHours(22))) == 1, "overnight next opening switches quota day");
            Sql("DELETE FROM gameprizerecord");
            Check(ActivityConfigs.CountUsed(ef, cfg, Utc(day.AddHours(23))) == 0, "empty records return zero used");
        }
    }
    static void Main()
    {
        try { MainChecked(); }
        catch (Exception ex) { Console.Error.WriteLine(ex.GetType().FullName + ": " + ex.Message); Environment.ExitCode = 1; }
    }
    static void MainChecked()
    {
        var timer = System.Diagnostics.Stopwatch.StartNew();
        var cs = new MySqlConnectionStringBuilder(ConfigurationManager.ConnectionStrings["DbConnString"].ConnectionString);
        if (cs.Server != "127.0.0.1" || cs.Port != 33416 || !cs.Database.StartsWith("rabbit_remaining_test_"))
            throw new Exception("Refusing non-isolated database");
        string schema = cs.Database; cs.Database = "";
        using (db = new MySqlConnection(cs.ConnectionString))
        {
            db.Open(); Sql("CREATE DATABASE `" + schema + "` CHARACTER SET utf8mb4"); db.ChangeDatabase(schema);
            try
            {
                Database.SetInitializer<GameDbContext>(null);
                Sql("CREATE TABLE gameprizerecord(ID BIGINT AUTO_INCREMENT PRIMARY KEY,GameId INT,CardType VARCHAR(100),RecTime DATETIME,IsManualControl INT)");
                Sql("CREATE TABLE activityconfig(ActivityKey VARCHAR(50) PRIMARY KEY,GameId INT,Enabled INT,CfgJson TEXT,Operator VARCHAR(50),UpdateTime DATETIME)");
                Sql("CREATE TABLE games(GameId INT PRIMARY KEY,Enable INT)"); Sql("INSERT INTO games VALUES(55,1)");
                Sql("CREATE TABLE users(ID VARCHAR(50) PRIMARY KEY,AGENCY VARCHAR(50))"); Sql("INSERT INTO users VALUES('quota_test','')");
                Run();
                Console.WriteLine("PASS " + checks + " actual BLL/MySQL/MVC/WebAPI checks in " + timer.Elapsed.TotalSeconds.ToString("F3") + "s");
            }
            finally { Sql("DROP DATABASE `" + schema + "`"); }
        }
    }
}
