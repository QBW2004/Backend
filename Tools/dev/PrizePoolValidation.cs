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
            sql("CREATE DATABASE `" + schema + "` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci");
            try
            {
                sql("USE `" + schema + "`");
                string snapshot = SqlSnapshot.Read(args[0]);
                foreach (string table in new[] { "admin", "games", "usercontrolstatus", "usercontrolvalue", "gameprizerecord" })
                    sql(SqlSnapshot.Table(snapshot, table));
                sql("INSERT INTO games(GameId,Name,GameType) VALUES(15,'大字版',3),(44,'NBA',3); INSERT INTO admin(ID,PWD,COINS) VALUES('prize_a','fixture',3000),('prize_b','fixture',3000)");
                string[] poolTables = { "agentprizepool", "agentprizecontrol", "agentprizeledger" };
                foreach (string table in poolTables) sql(SqlSnapshot.Table(snapshot, table));
                sql(SqlSnapshot.Procedure(snapshot, "agentprize_record_award"));
                sql(SqlSnapshot.Procedure(snapshot, "agentprize_release_delta"));
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
                foreach (string table in poolTables) sql(SqlSnapshot.Table(snapshot, table, true));
                Check(number("SELECT Balance FROM agentprizepool WHERE AgentID='prize_a'") == 1100, "existing-table initialization preserves money");
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
                // 2026-11-06 手机端提取：超过奖池整笔拒绝、提示明确、钱包/奖池/流水均不变；扣减流水 Kind=2 且为负数
                long ledgerBefore = (long)number("SELECT COUNT(*) FROM agentprizeledger WHERE AgentID='prize_a'");
                var over = service.Transfer(a, 1071, Guid.NewGuid().ToString(), true);
                Check(over.code == 0 && over.content.Contains("奖池余额不足") && over.content.Contains("1070"), "deduct over pool rejected with explicit message");
                Check(number("SELECT Balance FROM agentprizepool WHERE AgentID='prize_a'") == 1070 && number("SELECT COINS FROM admin WHERE ID='prize_a'") == 1900, "rejected deduct leaves money unchanged");
                Check((long)number("SELECT COUNT(*) FROM agentprizeledger WHERE AgentID='prize_a'") == ledgerBefore, "rejected deduct writes no ledger");
                Check(number("SELECT ChangeDiamonds FROM agentprizeledger WHERE AgentID='prize_a' AND Kind=2 ORDER BY ID DESC LIMIT 1") == -10, "deduct ledger kind 2 is negative");
                var poorWallet = service.Transfer(a, 999999, Guid.NewGuid().ToString(), false);
                Check(poorWallet.code == 0 && poorWallet.content.Contains("我的钻石不足"), "recharge over wallet has explicit message");
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
                using (var ef = new GameDbContext()) using (var tx = ef.Database.BeginTransaction()) B_PrizePool.CheckFunding(ef, a, 6, 0);
                Check(number("SELECT Balance FROM agentprizepool WHERE AgentID='prize_a'") == 324, "positive pool funds an award without pre-deducting its estimated prize");
                sql("UPDATE agentprizepool SET Balance=325 WHERE AgentID='prize_a'");
                using (var ef = new GameDbContext()) using (var tx = ef.Database.BeginTransaction()) B_PrizePool.CheckFunding(ef, a, 6, 0);
                Check(number("SELECT Balance FROM agentprizepool WHERE AgentID='prize_a'") == 325, "exactly 325 accepted without premature charge");
                Check(CardPrizeQuoteRules.Find(5, 7).Multiplier == 65, "actual Dazhi four-kind multiplier");
                sql("UPDATE agentprizepool SET Balance=10 WHERE AgentID='prize_a'");
                award(6, "overrun", 2000, 100);
                Check(number("SELECT Balance FROM agentprizepool WHERE AgentID='prize_a'") == 0, "overrun is capped at available pool balance");
                denied = false;
                try { using (var ef = new GameDbContext()) using (var tx = ef.Database.BeginTransaction()) B_PrizePool.CheckFunding(ef, a, 6, 0); }
                catch (InvalidOperationException) { denied = true; }
                Check(denied, "new award blocked when pool is empty");
                control(7, 6, "other_player", b.Accounts);
                var records = JObject.FromObject(service.GetControlRecords(a, new M_Page(1, 2), "", DateTime.Today.AddDays(-1), DateTime.Today.AddDays(1)));
                Check(records["rows"].Select(r => (int)r["ID"]).SequenceEqual(new[] { 6, 5 }) && (int)records["total"] == 5, "SQL paging and creator isolation exclude the completed uncharged overlap release");
                Check(records["rows"].All(r => (string)r["UserID"] != "other_player"), "no other operator records");
                var allRecords = JObject.FromObject(service.GetControlRecords(a, new M_Page(1, 20), "", DateTime.Today.AddDays(-1), DateTime.Today.AddDays(1)));
                Check(allRecords["rows"].Select(r => (int)r["ID"]).SequenceEqual(new[] { 6, 5, 4, 2, 1 }), "zero-charge completed release and other operator remain excluded across the full page");
                var wallet = JObject.FromObject(service.GetWallet(a).datas);
                Check((decimal)wallet["Balance"] == 0 && (long)wallet["Diamonds"] == 1900, "real wallet response");
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
