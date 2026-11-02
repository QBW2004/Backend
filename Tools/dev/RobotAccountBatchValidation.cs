// Actual BLL validation against a disposable local MySQL database only.
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.Entity;
using System.Linq;
using System.Web.Mvc;
using MySql.Data.MySqlClient;
using YYT.BLL.EF;
using YYT.Entity;

class RobotAccountBatchValidation
{
    static int checks;
    static void Check(bool condition, string name)
    {
        if (!condition) throw new Exception(name);
        checks++;
        Console.WriteLine("PASS " + name);
    }
    static M_UserRobot Account(string name)
    {
        return new M_UserRobot { UserName = name, UserNick = "测试" + name,
            PassW = "local-test-only", Lev = 1, Gold = 100000, IsRobot = 2 };
    }
    static int Main()
    {
        try { return Run(); }
        catch (Exception ex)
        {
            while (ex != null)
            {
                Console.Error.WriteLine(ex.GetType().FullName);
                Console.Error.WriteLine(ex.Message);
                ex = ex.InnerException;
            }
            return 1;
        }
    }
    static int Run()
    {
        var timer = System.Diagnostics.Stopwatch.StartNew();
        var cs = new MySqlConnectionStringBuilder(ConfigurationManager.ConnectionStrings["DbConnString"].ConnectionString);
        if (cs.Server != "127.0.0.1" || cs.Port != 33307 ||
            !System.Text.RegularExpressions.Regex.IsMatch(cs.Database, "^mth_robot_accounts_validation_[a-z0-9_]+$"))
            throw new Exception("Requires the isolated local robot-account validation DB");
        string schema = cs.Database;
        cs.Database = "";
        using (var db = new MySqlConnection(cs.ConnectionString))
        {
            db.Open();
            Action<string> sql = q => { using (var cmd = new MySqlCommand(q, db)) cmd.ExecuteNonQuery(); };
            Func<int> count = () => { using (var cmd = new MySqlCommand("SELECT COUNT(*) FROM userrobot", db)) return Convert.ToInt32(cmd.ExecuteScalar()); };
            sql("CREATE DATABASE `" + schema + "` CHARACTER SET utf8mb4");
            try
            {
                sql("USE `" + schema + "`");
                sql("CREATE TABLE userrobot(ID BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY, UserName VARCHAR(50) NOT NULL UNIQUE, UserNick VARCHAR(50), PassW VARCHAR(50), Ico INT NOT NULL, Lev INT NOT NULL, Sex INT NOT NULL, Gold INT NOT NULL, IsRobot INT NOT NULL) ENGINE=InnoDB");
                Database.SetInitializer<GameDbContext>(null);
                var controllerType = System.Reflection.Assembly.Load("YYT.Web")
                    .GetType("YYT.Web.Areas.Game.Controllers.RobotController", true);
                var controller = Activator.CreateInstance(controllerType);
                foreach (string action in new[] { "BatchCreateRobotAccounts", "BatchDeleteRobotAccounts" })
                {
                    var result = (JsonResult)controllerType.GetMethod(action).Invoke(controller, new object[] { new FormCollection() });
                    Check(Convert.ToInt32(result.Data.GetType().GetProperty("code").GetValue(result.Data, null)) == 0,
                        action + " executes and rejects empty input without MissingMethodException");
                }
                var bll = new B_UserRobot();
                Check(bll.AddRobots(null).code == 0, "null creation rejected");
                Check(bll.AddRobots(new List<M_UserRobot>()).code == 0, "empty creation rejected");
                Check(bll.DelRobots(null) == 0 && bll.DelRobots(new List<long>()) == 0, "empty deletion is a no-op");
                var accounts = Enumerable.Range(0, 51).Select(i => Account((800000 + i).ToString())).ToList();
                Check(bll.AddRobots(accounts).code == 1, "batch creation succeeds");
                Check(count() == 51 && accounts.All(a => a.ID > 0), "all 51 accounts persisted with IDs");
                var selected = accounts.Take(50).Select(a => a.ID).ToList();
                selected.Add(selected[0]);
                selected.Add(long.MaxValue);
                Check(bll.DelRobots(selected) == 50, "deletes exactly 50 selected accounts despite duplicate and absent IDs");
                Check(count() == 1, "unselected account survives");
                using (var ef = new GameDbContext())
                    Check(ef.userRobots.Single().ID == accounts[50].ID, "survivor is the unselected account");
                Check(bll.DelRobots(selected) == 0 && count() == 1, "repeat deletion is a no-op");
                Check(bll.AddRobots(new List<M_UserRobot> { Account("900000"), Account(accounts[50].UserName) }).code == 0,
                    "duplicate account rejects the entire creation transaction");
                Check(count() == 1, "failed creation has no partial insert");
                var extra = new List<M_UserRobot> { Account("900001"), Account("900002") };
                Check(bll.AddRobots(extra).code == 1, "create deletion rollback fixtures");
                sql("CREATE TRIGGER reject_test_delete BEFORE DELETE ON userrobot FOR EACH ROW BEGIN IF OLD.UserName='900002' THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='validation rejection'; END IF; END");
                Check(bll.DelRobots(extra.Select(a => a.ID).ToList()) == 0, "deletion failure reported");
                Check(count() == 3, "failed deletion rolls back all selected accounts");
                sql("DROP TRIGGER reject_test_delete");
                Check(bll.DelRobots(extra.Select(a => a.ID).ToList()) == 2, "deletion succeeds after constraint is removed");
                Check(bll.DelRobots(new List<long> { accounts[50].ID }) == 1 && count() == 0, "single selected account deletion succeeds");
                Console.WriteLine("PASS " + checks + " checks in " + timer.Elapsed.TotalSeconds.ToString("F2") + " seconds");
                return 0;
            }
            finally { sql("DROP DATABASE `" + schema + "`"); }
        }
    }
}
