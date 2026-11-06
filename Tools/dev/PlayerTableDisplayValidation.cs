using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.Entity;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Web;
using System.Web.Mvc;
using System.Web.SessionState;
using MySql.Data.MySqlClient;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using YYT.BLL.EF;
using YYT.Common;
using YYT.Entity;
using YYT.Web.Areas.Game.Controllers;

class PlayerTableDisplayValidation
{
    static int checks;
    static void Check(bool ok, string name) { if (!ok) throw new Exception(name); checks++; }
    static int Main(string[] args)
    {
        try { Run(args[0]); return 0; }
        catch (Exception ex) { Console.Error.WriteLine(ex); return 1; }
    }

    static void Run(string root)
    {
        var timer = Stopwatch.StartNew();
        var cs = new MySqlConnectionStringBuilder(ConfigurationManager.ConnectionStrings["DbConnString"].ConnectionString);
        if (cs.Server != "127.0.0.1" || cs.Port != 33416 || !cs.Database.StartsWith("mth_table_display_validation_"))
            throw new Exception("Requires isolated loopback MySQL on port 33416");
        string schema = cs.Database; cs.Database = "";
        using (var db = new MySqlConnection(cs.ConnectionString))
        {
            db.Open();
            Action<string> sql = q => { using (var cmd = new MySqlCommand(q, db)) cmd.ExecuteNonQuery(); };
            sql("CREATE DATABASE `" + schema + "` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci");
            try
            {
                sql("USE `" + schema + "`");
                string snapshot = SqlSnapshot.Read(root);
                foreach (string table in new[] { "users", "games", "useroptlog", "roomtableconfig", "roomtableowner", "pararoom", "gameprizerecord" })
                    sql(SqlSnapshot.Table(snapshot, table));
                sql("INSERT INTO users(ID,NAME,PWD,AGENCY,INHALL) VALUES('a18001','fixture','x','',1),('left','fixture','x','',1)");
                sql("INSERT INTO games(GameId,Name,GameType,Enable) VALUES(15,'大字板',1,1),(3,'金蟾捕鱼',2,1),(54,'麻将胡了',1,1)");
                sql("INSERT INTO pararoom(ID,GAME_ID,NUM) VALUES(15000,15,42)");
                for (int i = 0; i < 42; i++)
                {
                    sql("INSERT INTO roomtableconfig(GAME_ID,RoomIndex,TableIndex,TableName) VALUES(15,0," + i + ",'错误自定义999')");
                    if (i < 24) sql("INSERT INTO roomtableowner(GAME_ID,TableIndex,LineAgent) VALUES(15," + i + ",'#')");
                }
                sql("INSERT INTO roomtableconfig(GAME_ID,RoomIndex,TableIndex,TableName) VALUES(3,0,7,'贵宾桌')");
                sql("INSERT INTO useroptlog(UserID,OPT,COINS,GAME_TYPE,TABLE_ID,REC_TIME) VALUES"
                    + "('a18001',2,1000,15,24,NOW()),('a18001',3,1100,15,24,NOW()),"
                    + "('a18001',8,1100,15,25,NOW()),('a18001',7,1000,15,25,NOW()),"
                    + "('a18001',0,1000,15,24,NOW()),('a18001',2,1000,15,24,NOW()),('left',3,1000,15,24,NOW())");

                var login = new M_LoginUser { Accounts = "fixture", UserPriv = 0 };
                var records = (M_EasyuiGridData<M_UserOptLog>)new B_Records_MySQL().Get_PlayerRecords(login,
                    new M_Page(1, 20), new M_S_Record { ID = "a18001", S_TIME = DateTime.Today });
                var rows = records.rows.ToList();
                Check(records.total == 6 && rows.Count == 6, "record totals unchanged");
                foreach (var row in rows)
                    Check(row.TableDisplay == (row.OPT == 0 ? "--" : row.TABLE_ID == 24 ? "1" : "2"), "enter/leave display " + row.LID);
                Check(rows.First(r => r.OPT == 3).SessionProfit == -100 && rows.First(r => r.OPT == 7).SessionProfit == 100,
                    "display mapping preserves raw-table pairing and balances");
                Check(rows.Where(r => r.OPT != 0).All(r => r.TABLE_ID == 24 || r.TABLE_ID == 25), "raw table indexes unchanged");
                var page = (M_EasyuiGridData<M_UserOptLog>)new B_Records_MySQL().Get_PlayerRecords(login,
                    new M_Page(2, 2), new M_S_Record { ID = "a18001", S_TIME = DateTime.Today });
                Check(page.total == 6 && page.rows.Count() == 2 && page.rows.All(r => r.TableDisplay == "2"), "paged mapping");

                using (var ef = new GameDbContext())
                {
                    var users = new List<M_Users_DTO> { new M_Users_DTO { ID = "a18001", INHALL = true },
                        new M_Users_DTO { ID = "left", INHALL = true }, new M_Users_DTO { ID = "offline", INHALL = false } };
                    typeof(B_Users).GetMethod("FillCurrentPlayInfo", BindingFlags.Instance | BindingFlags.NonPublic)
                        .Invoke(new B_Users(), new object[] { ef, users });
                    Check(users[0].CurrentTableId == 24 && users[0].CurrentTableDisplay == "1", "legacy online list maps raw24 to1");
                    Check(users[1].CurrentTableDisplay == "--" && users[2].CurrentTableDisplay == null, "left/offline never invent a current table");
                }

                sql("INSERT INTO gameprizerecord(EventId,UserID,GameId,GameType,RoomId,TableId,CardType,Multiplier,Score,IsBroadcast,RecTime) VALUES"
                    + "('card','a18001',15,1,0,25,'大奖',50,5000,1,DATE_SUB(NOW(),INTERVAL 1 SECOND)),"
                    + "('fish','a18001',3,2,0,8,'大奖',50,5000,1,DATE_SUB(NOW(),INTERVAL 1 SECOND))");
                HttpContext.Current = new HttpContext(new HttpRequest("", "http://localhost/", ""), new HttpResponse(new StringWriter()));
                SessionStateUtility.AddHttpSessionStateToContext(HttpContext.Current, new HttpSessionStateContainer("fixture",
                    new SessionStateItemCollection(), new HttpStaticObjectsCollection(), 30, true, HttpCookieMode.UseCookies, SessionStateMode.InProc, false));
                HttpContext.Current.Session["LoginInfo"] = DESEncrypt.Encrypt(JsonConvert.SerializeObject(login));
                using (var controller = new UserRecordController())
                {
                    var result = (JsonResult)controller.GetPrizeHistory(new FormCollection { { "ID", "a18001" } });
                    var json = JObject.FromObject(result.Data); var prizes = (JArray)json["rows"];
                    Check((int)json["total"] == 2, "actual prize history controller and EF mapping");
                    Check((string)prizes.Single(r => (int)r["GameId"] == 15)["TableLabel"] == "1号机", "prize raw25 also displays1");
                    Check((string)prizes.Single(r => (int)r["GameId"] == 3)["TableLabel"] == "贵宾桌", "fish keeps selection name");
                    Check(prizes.All(r => r["LineAgent"] == null), "ownership is not exposed in JSON");
                    HttpContext.Current.Session.Clear();
                    result = (JsonResult)controller.GetPrizeHistory(new FormCollection { { "ID", "a18001" } });
                    Check((int)JObject.FromObject(result.Data)["total"] == 0, "missing login receives no records");
                }
                Console.WriteLine("PASS " + checks + " actual BLL/controller/MySQL checks in " + timer.Elapsed.TotalSeconds.ToString("F2") + "s");
            }
            finally { HttpContext.Current = null; sql("DROP DATABASE `" + schema + "`"); }
        }
    }
}
