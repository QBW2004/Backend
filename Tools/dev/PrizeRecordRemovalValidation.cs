using System;
using System.Configuration;
using System.Data.Entity;
using System.Diagnostics;
using System.Reflection;
using MySql.Data.MySqlClient;
using Newtonsoft.Json.Linq;
using YYT.BLL.EF;
using YYT.BLL.Services.GameServer;
using YYT.Entity;

class PrizeRecordRemovalValidation
{
    static int checks;
    static void Check(bool ok, string name) { if (!ok) throw new Exception(name); checks++; }
    static int Main()
    {
        try { Run(); return 0; } catch (Exception ex) { Console.Error.WriteLine(ex); return 1; }
    }
    static void Run()
    {
        var timer = Stopwatch.StartNew();
        var cs = new MySqlConnectionStringBuilder(ConfigurationManager.ConnectionStrings["DbConnString"].ConnectionString);
        if (cs.Server != "127.0.0.1" || cs.Port != 33308 || !cs.Database.StartsWith("mth_prize_remove_validation_"))
            throw new Exception("Requires isolated loopback MySQL fixture");
        string schema = cs.Database; cs.Database = "";
        Database.SetInitializer<GameDbContext>(null);
        // 只验证本地数据库和指令发件箱，禁止向任何游戏管道发送测试控制。
        typeof(PipeGameServerClient).GetField("breakerOpenUntilUtc", BindingFlags.Static | BindingFlags.NonPublic)
            .SetValue(null, DateTime.UtcNow.AddHours(1));
        using (var db = new MySqlConnection(cs.ConnectionString))
        {
            db.Open();
            Action<string> sql = q => { using (var cmd = new MySqlCommand(q, db)) cmd.ExecuteNonQuery(); };
            Func<string, long> number = q => { using (var cmd = new MySqlCommand(q, db)) return Convert.ToInt64(cmd.ExecuteScalar()); };
            sql("CREATE DATABASE `" + schema + "` CHARACTER SET utf8 COLLATE utf8_general_ci");
            try
            {
                sql("USE `" + schema + "`");
                sql("CREATE TABLE users(ID varchar(50) PRIMARY KEY) ENGINE=InnoDB; INSERT INTO users VALUES('p'),('q'),('r'),('s')");
                sql("CREATE TABLE usercontrolstatus(ID int PRIMARY KEY,UserID varchar(50),GameType int,GameId int,ControlMode int,TargetCoins bigint DEFAULT 0,ConsumedCoins bigint DEFAULT 0,GrantedCoins bigint DEFAULT 0,LimitCoins bigint DEFAULT 0,KillRatio int DEFAULT 0,Status int DEFAULT 0,CreatedBy varchar(50),CreatedTime datetime,ExpiredTime datetime NULL) ENGINE=InnoDB");
                sql("CREATE TABLE usercontrolvalue(USERID varchar(50),CONTROL_TYPE int,NUMBER int,TOTAL_NUMBER int) ENGINE=InnoDB");
                sql("CREATE TABLE agentprizecontrol(ControlId int PRIMARY KEY,AwardTime datetime NULL) ENGINE=InnoDB");
                sql("INSERT INTO usercontrolstatus(ID,UserID,GameType,GameId,ControlMode,Status,CreatedBy,CreatedTime) VALUES(201,'p',9,5,6,0,'owner',NOW()),(202,'p',9,0,5,0,'owner',NOW()),(203,'q',9,5,6,0,'other',NOW()),(204,'r',9,5,6,0,'owner',NOW()),(205,'s',9,5,6,1,'owner',NOW())");
                sql("INSERT INTO agentprizecontrol VALUES(201,NULL),(202,NULL),(203,NULL),(204,NOW()),(205,NULL); INSERT INTO usercontrolvalue VALUES('p',5,1,5),('p',14,1,5)");
                var owner = new M_LoginUser { Accounts = "owner", UserPriv = 0 };
                var bll = new B_UserControl();
                Check(bll.CloseTotalControl(null, "p", 6, true, 201).code == 0, "requires login");
                Check(bll.CloseTotalControl(new M_LoginUser { Accounts = "owner", UserPriv = 2 }, "p", 6, true, 201).code == 0, "requires mode permission");
                Check(bll.CloseTotalControl(owner, "p", 6, true, 201).code == 1, "own pending record removed");
                Check(number("SELECT Status FROM usercontrolstatus WHERE ID=201") == 1, "record expired");
                Check(number("SELECT COUNT(*) FROM usercontrolvalue WHERE USERID='p' AND CONTROL_TYPE=5") == 0, "target card parameters cleared");
                Check(number("SELECT COUNT(*) FROM usercontrolvalue WHERE USERID='p' AND CONTROL_TYPE=14") == 1, "other parameters preserved");
                Check(number("SELECT Status FROM usercontrolstatus WHERE ID=202") == 0, "coexisting release preserved");
                Check(number("SELECT COUNT(*) FROM agentprizecontrol WHERE ControlId=201") == 1, "award history preserved");
                Check(number("SELECT COUNT(*) FROM gamecommandoutbox WHERE CommandType='UC'") == 1, "one clear command queued");
                using (var cmd = new MySqlCommand("SELECT Payload FROM gamecommandoutbox LIMIT 1", db))
                {
                    var args = JObject.Parse((string)cmd.ExecuteScalar())["Args"];
                    Check((string)args[0] == "32" && (string)args[1] == "00" && (string)args.Last == "p", "existing card clear protocol used");
                }
                Check(bll.CloseTotalControl(owner, "p", 6, true, 201).code == 0, "duplicate removal rejected");
                sql("INSERT INTO usercontrolstatus(ID,UserID,GameType,GameId,ControlMode,CreatedBy,CreatedTime) VALUES(206,'p',9,5,6,'owner',NOW())");
                Check(bll.CloseTotalControl(owner, "p", 6, true, 201).code == 0, "stale list cannot remove replacement");
                Check(number("SELECT Status FROM usercontrolstatus WHERE ID=206") == 0, "replacement still active");
                Check(bll.CloseTotalControl(owner, "q", 6, true, 203).code == 0, "other creator denied even for administrator");
                Check(bll.CloseTotalControl(owner, "r", 6, true, 204).code == 0, "already opened record denied");
                Check(bll.CloseTotalControl(owner, "s", 6, true, 205).code == 0, "expired record denied");
                Check(bll.CloseTotalControl(owner, "p", 5, true, 206).code == 0, "wrong mode cannot remove another record");
                Check(number("SELECT COUNT(*) FROM gamecommandoutbox") == 1, "rejections send no commands");
                Check(bll.CloseTotalControl(owner, "p", 5, true, 202).code == 1, "pending release removed");
                Check(number("SELECT Status FROM usercontrolstatus WHERE ID=206") == 0, "card preserved when release removed");
                Check(bll.CloseTotalControl(owner, "p", 6).code == 1, "existing manual removal overload still works");
                Console.WriteLine("PASS " + checks + " actual BLL/MySQL removal checks in " + timer.Elapsed.TotalSeconds.ToString("F3") + "s");
            }
            finally { sql("DROP DATABASE `" + schema + "`"); }
        }
    }
}
