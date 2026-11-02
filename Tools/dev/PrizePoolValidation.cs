using System;
using System.Configuration;
using System.Data.Entity;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using MySql.Data.MySqlClient;
using Newtonsoft.Json.Linq;
using YYT.BLL.EF;
using YYT.Entity;

class PrizePoolValidation
{
    static int checks;
    static void Check(bool value, string message) { if (!value) throw new Exception(message); checks++; }
    static void RunScript(MySqlConnection db, string source)
    {
        var buffer = new StringBuilder(); string delimiter = ";";
        foreach (string line in source.Replace("\r\n", "\n").Split('\n'))
        {
            if (line.StartsWith("DELIMITER ")) { delimiter = line.Substring(10).Trim(); continue; }
            buffer.AppendLine(line);
            string sql = buffer.ToString().Trim();
            if (!sql.EndsWith(delimiter)) continue;
            using (var cmd = new MySqlCommand(sql.Substring(0, sql.Length - delimiter.Length), db)) cmd.ExecuteNonQuery();
            buffer.Clear();
        }
        if (buffer.ToString().Trim().Length != 0) throw new Exception("Unterminated migration statement");
    }
    static int Main(string[] args)
    {
        try { Run(args); return 0; } catch (Exception ex) { Console.Error.WriteLine(ex); return 1; }
    }
    static void Run(string[] args)
    {
        var watch = Stopwatch.StartNew();
        var cs = new MySqlConnectionStringBuilder(ConfigurationManager.ConnectionStrings["DbConnString"].ConnectionString);
        if (cs.Server != "127.0.0.1" || cs.Port != 33308 || !cs.Database.StartsWith("mth_prize_validation_")) throw new Exception("Requires isolated loopback database");
        string schema = cs.Database, connection = cs.ConnectionString; cs.Database = "";
        Database.SetInitializer<GameDbContext>(null);
        using (var db = new MySqlConnection(cs.ConnectionString))
        {
            db.Open();
            Action<string> sql = text => { using (var cmd = new MySqlCommand(text, db)) cmd.ExecuteNonQuery(); };
            Func<string, decimal> number = text => { using (var cmd = new MySqlCommand(text, db)) return Convert.ToDecimal(cmd.ExecuteScalar()); };
            sql("CREATE DATABASE `" + schema + "` CHARACTER SET utf8 COLLATE utf8_general_ci");
            try
            {
                sql("USE `" + schema + "`");
                sql("CREATE TABLE admin(ID varchar(50) PRIMARY KEY,COINS bigint NOT NULL) ENGINE=InnoDB");
                sql("CREATE TABLE games(GameId int PRIMARY KEY,Name varchar(50),GameType int) ENGINE=InnoDB");
                sql("CREATE TABLE usercontrolstatus(ID int PRIMARY KEY,UserID varchar(50),GameType int,GameId int,ControlMode int,TargetCoins bigint DEFAULT 0,ConsumedCoins bigint DEFAULT 0,GrantedCoins bigint DEFAULT 0,LimitCoins bigint DEFAULT 0,KillRatio int DEFAULT 0,Status int DEFAULT 0,CreatedBy varchar(50),CreatedTime datetime(6),ExpiredTime datetime(6) NULL) ENGINE=InnoDB");
                sql("CREATE TABLE usercontrolvalue(USERID varchar(50),CONTROL_TYPE int,NUMBER int,TOTAL_NUMBER int) ENGINE=InnoDB");
                sql("CREATE TABLE gameprizerecord(ID bigint PRIMARY KEY AUTO_INCREMENT,EventId varchar(64) UNIQUE,UserID varchar(50),GameId int,GameType int,RoomId bigint,TableId bigint,CardType varchar(100),Multiplier decimal(18,2),Score bigint,IsManualControl int,IsBroadcast int,RecTime datetime,LineAgent varchar(50)) ENGINE=InnoDB");
                sql("INSERT INTO games VALUES(15,'大字版',3),(44,'NBA',3); INSERT INTO admin VALUES('prize_a',3000),('prize_b',3000)");
                string migration = File.ReadAllText(Path.Combine(args[0], "Docs/sql/代理送奖奖池-20261102.sql"));
                RunScript(db, migration);
                // 重复执行迁移保留已有余额与流水。
                var a = new M_LoginUser { Accounts = "prize_a", UserPriv = 2, IsRelease = 1, IsProbability = 1, IsKill = 1 };
                var b = new M_LoginUser { Accounts = "prize_b", UserPriv = 2, IsRelease = 1 };
                var service = new B_PrizePool(); string token = Guid.NewGuid().ToString();
                Check(service.Transfer(a, 1000, token, false).code == 1, "recharge");
                Check(number("SELECT Balance FROM agentprizepool WHERE AgentID='prize_a'") == 1000, "pool credit");
                Check(number("SELECT COINS FROM admin WHERE ID='prize_a'") == 2000, "wallet debit");
                Check(service.Transfer(a, 1000, token, false).code == 1, "idempotent retry result");
                Check(number("SELECT Balance FROM agentprizepool WHERE AgentID='prize_a'") == 1000, "no retry double debit");
                Check(service.Transfer(a, 4000, Guid.NewGuid().ToString(), false).code == 0, "insufficient wallet rejected");
                Check(service.Transfer(a, -1, Guid.NewGuid().ToString(), false).code == 0, "negative transfer rejected");
                string parallelToken = Guid.NewGuid().ToString();
                Parallel.For(0, 6, i => { if (service.Transfer(a, 100, parallelToken, false).code != 1) throw new Exception("Concurrent transfer failed"); });
                Check(number("SELECT Balance FROM agentprizepool WHERE AgentID='prize_a'") == 1100, "six concurrent retries charge once");
                Check(number("SELECT COINS FROM admin WHERE ID='prize_a'") == 1900, "concurrent conservation");
                RunScript(db, migration);
                Check(number("SELECT Balance FROM agentprizepool WHERE AgentID='prize_a'") == 1100, "migration reentry preserves money");
                Action<int, int, string, string> control = (id, mode, user, owner) =>
                {
                    sql("INSERT INTO usercontrolstatus(ID,UserID,GameType,GameId,ControlMode,KillRatio,CreatedBy,CreatedTime) VALUES(" + id + ",'" + user + "',9,5," + mode + ",7,'" + owner + "',DATE_SUB(NOW(6),INTERVAL 1 MINUTE))");
                    using (var ef = new GameDbContext()) B_PrizePool.AttachControl(ef, owner == a.Accounts ? a : b, new M_UserControlStatus { ID = id, UserID = user, ControlMode = mode });
                };
                Action<int, string, long, long> award = (id, evt, units, rate) => sql("CALL agentprize_record_award('" + evt + "'," + id + ",'player1',15,15,'四梅'," + units + "," + rate + ",NOW(6))");
                Action<int, string, long, long> release = (id, evt, units, rate) => sql("CALL agentprize_release_delta('" + evt + "'," + id + ",'player1',15,15," + units + "," + rate + ",NOW(6))");
                control(1, 6, "player1", a.Accounts);
                award(1, "test-award-1", 3000, 100);
                Check(number("SELECT Balance FROM agentprizepool WHERE AgentID='prize_a'") == 1070, "card actual units/rate");
                award(1, "test-award-1", 3000, 100);
                Check(number("SELECT Balance FROM agentprizepool WHERE AgentID='prize_a'") == 1070, "duplicate award ignored");
                Check(service.Transfer(a, 10, Guid.NewGuid().ToString(), true).code == 1, "return pool funds to own wallet");
                Check(number("SELECT COINS FROM admin WHERE ID='prize_a'") == 1910, "return credits own wallet");
                Check(number("SELECT Balance FROM agentprizepool WHERE AgentID='prize_a'") == 1060, "return debits pool");
                Check(service.Transfer(a, 10, Guid.NewGuid().ToString(), false).code == 1, "recharge reverses return");
                sql("UPDATE usercontrolstatus SET Status=2,ExpiredTime=DATE_SUB(NOW(6),INTERVAL 2 MINUTE) WHERE ID=1");
                control(2, 5, "player1", a.Accounts);
                release(2, "net-1", 25, 100);
                Check(number("SELECT Balance FROM agentprizepool WHERE AgentID='prize_a'") == 1069.75m, "fractional release preserved");
                release(2, "net-1", 25, 100);
                Check(number("SELECT NetDiamonds FROM agentprizecontrol WHERE ControlId=2") == .25m, "release retry idempotent");
                release(2, "net-2", -10, 100);
                Check(number("SELECT Balance FROM agentprizepool WHERE AgentID='prize_a'") == 1069.85m, "net loss refunds prior excess");
                release(2, "net-3", -100, 100);
                Check(number("SELECT Balance FROM agentprizepool WHERE AgentID='prize_a'") == 1070, "negative net cannot mint more than original pool");
                release(2, "net-4", 200, 100);
                Check(number("SELECT Balance FROM agentprizepool WHERE AgentID='prize_a'") == 1068.85m, "net recovery");
                release(2, "tiny", 1, 100000000);
                Check(number("SELECT BookedDiamonds FROM agentprizecontrol WHERE ControlId=2") == 1.15000001m, "eight decimal precision");
                sql("UPDATE usercontrolstatus SET Status=2,ExpiredTime=DATE_SUB(NOW(6),INTERVAL 2 MINUTE) WHERE ID=2");
                control(3, 5, "player1", a.Accounts); control(4, 6, "player1", a.Accounts);
                decimal before = number("SELECT Balance FROM agentprizepool WHERE AgentID='prize_a'");
                release(3, "overlap-net", 3000, 100); award(4, "overlap-award", 3000, 100);
                Check(number("SELECT Balance FROM agentprizepool WHERE AgentID='prize_a'") == before - 30, "parallel card/release billed once");
                Check(number("SELECT BookedDiamonds FROM agentprizecontrol WHERE ControlId=3") == 0, "overlap release debit corrected");
                sql("UPDATE usercontrolstatus SET Status=2,ExpiredTime=DATE_SUB(NOW(6),INTERVAL 2 MINUTE) WHERE ID IN(3,4)");
                control(5, 5, "player1", a.Accounts); control(6, 6, "player1", a.Accounts);
                before = number("SELECT Balance FROM agentprizepool WHERE AgentID='prize_a'");
                award(6, "overlap-award-first", 3000, 100); release(5, "overlap-net-second", 3000, 100);
                Check(number("SELECT Balance FROM agentprizepool WHERE AgentID='prize_a'") == before - 30, "reversed event order billed once");
                sql("START TRANSACTION"); award(6, "rollback", 100, 1); sql("ROLLBACK");
                Check(number("SELECT COUNT(*) FROM agentprizeledger WHERE EventId='rollback'") == 0, "rolled back ledger");
                Check(number("SELECT Balance FROM agentprizepool WHERE AgentID='prize_a'") == before - 30, "rolled back pool");
                bool denied = false;
                try { using (var ef = new GameDbContext()) using (var tx = ef.Database.BeginTransaction()) B_PrizePool.CheckFunding(ef, a, 5, 999999); }
                catch (InvalidOperationException) { denied = true; }
                Check(denied, "unaffordable release target blocked");
                sql("UPDATE agentprizepool SET Balance=324 WHERE AgentID='prize_a'");
                denied = false;
                try { using (var ef = new GameDbContext()) using (var tx = ef.Database.BeginTransaction()) B_PrizePool.CheckFunding(ef, a, 6, 0, 5m * 65m); }
                catch (InvalidOperationException ex) { denied = ex.Message == "奖池余额不足，请充值奖池"; }
                Check(denied, "5 diamonds times 65 requires at least 325 with exact prompt");
                sql("UPDATE agentprizepool SET Balance=325 WHERE AgentID='prize_a'");
                using (var ef = new GameDbContext()) using (var tx = ef.Database.BeginTransaction()) B_PrizePool.CheckFunding(ef, a, 6, 0, 5m * 65m);
                Check(number("SELECT Balance FROM agentprizepool WHERE AgentID='prize_a'") == 325, "exactly 325 accepted without premature charge");
                Check(CardPrizeQuoteRules.Find(5, 7).Multiplier == 65, "actual Dazhi four-kind multiplier");
                sql("UPDATE agentprizepool SET Balance=10 WHERE AgentID='prize_a'");
                award(6, "overrun", 2000, 100);
                Check(number("SELECT Balance FROM agentprizepool WHERE AgentID='prize_a'") == -10, "overrun retains debt");
                denied = false;
                try { using (var ef = new GameDbContext()) using (var tx = ef.Database.BeginTransaction()) B_PrizePool.CheckFunding(ef, a, 6, 0); }
                catch (InvalidOperationException) { denied = true; }
                Check(denied, "new award blocked in debt");
                control(7, 6, "other_player", b.Accounts);
                var records = JObject.FromObject(service.GetControlRecords(a, new M_Page(1, 2), "", DateTime.Today.AddDays(-1), DateTime.Today.AddDays(1)));
                Check(records["rows"].Count() == 2 && (int)records["total"] == 6, "SQL paging and creator isolation");
                Check(records["rows"].All(r => (string)r["UserID"] != "other_player"), "no other operator records");
                var wallet = JObject.FromObject(service.GetWallet(a).datas);
                Check((decimal)wallet["Balance"] == -10 && (long)wallet["Diamonds"] == 1900, "real wallet response");
                if (args.Length > 1)
                {
                    sql("CREATE TABLE prize_fixture_failure(reject_write int); INSERT INTO prize_fixture_failure VALUES(0)");
                    sql("CREATE TRIGGER reject_prize_fixture BEFORE INSERT ON agentprizeledger FOR EACH ROW BEGIN IF (SELECT reject_write FROM prize_fixture_failure LIMIT 1)=1 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='fixture rollback'; END IF; END");
                    var info = new ProcessStartInfo(args[1]) { UseShellExecute = false };
                    info.EnvironmentVariables["MTH_PRIZE_TEST_CONN"] = "host=127.0.0.1;port=33308;user=root;password=;db=" + schema + ";auto-reconnect=true";
                    using (var process = Process.Start(info)) { process.WaitForExit(); Check(process.ExitCode == 0, "actual Poco persistence and stop methods"); }
                }
                Console.WriteLine("PASS " + checks + " actual BLL/MySQL prize-pool checks in " + watch.Elapsed.TotalSeconds.ToString("F3") + "s");
            }
            finally { sql("DROP DATABASE `" + schema + "`"); }
        }
    }
}
