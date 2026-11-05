using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.Entity;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Text.RegularExpressions;
using MySql.Data.MySqlClient;
using Newtonsoft.Json.Linq;
using YYT.BLL.EF;
using YYT.Entity;

class PlayerWinLossValidation
{
    static int checks;
    static void Check(bool ok, string message)
    {
        if (!ok) throw new Exception(message);
        checks++;
        Console.WriteLine("PASS " + message);
    }

    static int Main(string[] args)
    {
        try { Run(args[0]); return 0; }
        catch (Exception e) { Console.Error.WriteLine(e); return 1; }
    }

    static void Run(string repo)
    {
        var timer = Stopwatch.StartNew();
        var cs = new MySqlConnectionStringBuilder(ConfigurationManager.ConnectionStrings["DbConnString"].ConnectionString);
        if (cs.Server != "127.0.0.1" || cs.Port != 33308 || !cs.Database.StartsWith("mth_winloss_validation_"))
            throw new Exception("Requires isolated loopback MySQL on port 33308");
        string schema = cs.Database;
        cs.Database = "";
        using (var db = new MySqlConnection(cs.ConnectionString))
        {
            db.Open();
            Action<string> sql = text => { using (var cmd = new MySqlCommand(text, db)) cmd.ExecuteNonQuery(); };
            Func<string, object> scalar = text => { using (var cmd = new MySqlCommand(text, db)) return cmd.ExecuteScalar(); };
            sql("CREATE DATABASE `" + schema + "` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci");
            try
            {
                sql("USE `" + schema + "`");
                string dump = SqlSnapshot.Read(repo);
                foreach (string name in new[] { "users", "userrelations", "user_daily_winloss", "games", "useroptlog", "rechargerecords", "admin", "invite_codes" })
                    sql(SqlSnapshot.Table(dump, name));
                sql(SqlSnapshot.Table(dump, "userloginrecord"));
                Check((string)scalar("SELECT DATA_TYPE FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='user_daily_winloss' AND COLUMN_NAME='WINLOSS'") == "decimal", "canonical schema preserves coin fractions");
                sql("INSERT INTO users(ID,NAME,PWD,AGENCY,INHALL,COINS,COINS_BUY,COINS_BACK,GAME_SCORE,SAFE_COINS,GRADE,FROZEN) VALUES('profit1','profit1','fixture','top',b'0',100,999999,0,0,0,1,0),('loss1','loss1','fixture','top',b'0',100,888888,0,0,0,1,0),('empty1','empty1','fixture','top',b'0',100,777777,0,0,0,1,0)");
                sql("INSERT INTO userrelations(UserID,ID) VALUES(1,'profit1'),(2,'loss1'),(3,'empty1')");
                sql("INSERT INTO user_daily_winloss(UserID,DAY,WINLOSS) VALUES('profit1',CURDATE(),4689),('profit1',DATE_SUB(CURDATE(),INTERVAL 1 DAY),-0.25),('loss1',CURDATE(),-0.4)");
                Database.SetInitializer<GameDbContext>(null);
                var login = new M_LoginUser { UserPriv = 0, Accounts = "top" };
                var bll = new B_Users();
                var initial = bll.GetUsersList(new M_Page(1, 50), new M_Users_DTO(), login);
                Check(initial.total == 3 && initial.rows.Count == 3, "real first-page query returns all fixture players");
                Check(initial.rows.Single(x => x.ID == "profit1").Profit == 4688.75m, "first-page total includes all days and fractions");
                Check(initial.rows.Single(x => x.ID == "loss1").TodayWinLoss == -0.4m, "first-page loss keeps fractional coins");
                Check(initial.rows.Single(x => x.ID == "empty1").Profit == 0m, "recharge-only player has zero game profit");
                var refresh = bll.GetUserRowsByIds(new List<string> { "profit1", "loss1", "empty1" }, login, false);
                foreach (var row in initial.rows)
                    Check(refresh.Single(x => x.ID == row.ID).Profit == row.Profit, "first-page and refresh agree for " + row.ID);
                foreach (var rows in new[] {
                    bll.GetOfflineUsersList(new M_Page(1, 50), new M_Users_DTO(), login, null).rows,
                    bll.GetMemberWinLossList(new M_Page(1, 50), new M_Users_DTO(), login, "profit-desc").rows })
                {
                    Check(rows.Single(x => x.ID == "profit1").Profit == 4688.75m, "mobile SQL total keeps fractional coins");
                    Check(rows.Single(x => x.ID == "loss1").TodayWinLoss == -0.4m, "mobile SQL today keeps fractional coins");
                }
                var detail = bll.GetUserPhoneDetail("profit1", login);
                Check(detail.TotalWinLoss == 4688.75m && detail.TodayWinLoss == 4689m, "detail shares daily and all-time coin amounts");
                Check(bll.GetTodayTotalWinLoss(login) == 4688.6m, "today aggregate does not cast decimals to signed integers");
                var stats = bll.GetMemberWinLossStats(login, null);
                Check(stats.TodayWinLoss == 4688.6m && stats.TotalWinLoss == 4688.35m, "member stats aggregate exact coin fractions");
                var json = JObject.FromObject(detail);
                Check(json.Value<decimal>("TotalWinLoss") == 4688.75m, "JSON retains decimal amounts");
                sql("UPDATE users SET INHALL=b'1' WHERE ID='profit1'");
                var legacy = bll.GetOnlinePlayersList(new M_Page(1, 50), new M_Users_DTO(), login);
                Check(legacy.rows.Single().Profit == 4688.75m && legacy.rows.Single().TodayWinLoss == 4689m,
                    "legacy online query also uses game profit instead of recharge balance");
                sql("UPDATE users SET INHALL=b'0' WHERE ID='profit1'");
                Console.WriteLine("PASS " + checks + " checks in " + timer.Elapsed.TotalSeconds.ToString("F2") + " seconds");
            }
            finally { sql("DROP DATABASE `" + schema + "`"); }
        }
    }
}
