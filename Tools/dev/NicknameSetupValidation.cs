// 独立本机库验证真实 WebAPI 路由、鉴权、原子保存及迁移；不连接线上。
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Diagnostics;
using System.IO;
using System.Net.Http;
using System.Web.Http;
using MySql.Data.MySqlClient;
using Newtonsoft.Json.Linq;
using YYT.Web.Controllers.Api;

class NicknameSetupValidation
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
        if (cs.Server != "127.0.0.1" || cs.Port != 33307 || !cs.Database.StartsWith("mth_nickname_validation_"))
            throw new Exception("Requires isolated local validation DB");
        string schema = cs.Database;
        cs.Database = "";
        using (var db = new MySqlConnection(cs.ConnectionString))
        {
            db.Open();
            Action<string> sql = text => { using (var cmd = new MySqlCommand(text, db)) cmd.ExecuteNonQuery(); };
            Func<string, object> scalar = text => { using (var cmd = new MySqlCommand(text, db)) return cmd.ExecuteScalar(); };
            sql("CREATE DATABASE `" + schema + "` CHARACTER SET utf8mb4");
            try
            {
                sql("USE `" + schema + "`; CREATE TABLE users LIKE mth.users");
                Check(Convert.ToInt32(scalar("SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='users' AND COLUMN_NAME='NICKNAME_SET'")) == 0,
                    "fixture starts with pre-migration schema");
                sql("INSERT INTO users(ID,NAME,PWD,AGENCY) VALUES('new001','new001','Test123',''),('old001','老玩家','Test123',''),('empty1','   ','Test123',''),('other1','other1','Test123','')");
                var controller = new UpdateUsersController();
                Check(controller.NicknameStatus(new UpdateUsersController.UsersModel { playerId = "new001", pwd = "Test123" }).code != 10000,
                    "missing migration returns failure instead of completed");
                string migration = File.ReadAllText(Path.Combine(repo, "Docs/sql/玩家昵称设置标记-20261101.sql"));
                sql(migration);
                Check(Convert.ToInt32(scalar("SELECT NICKNAME_SET FROM users WHERE ID='new001'")) == 0, "default account stays unset");
                Check(Convert.ToInt32(scalar("SELECT NICKNAME_SET FROM users WHERE ID='old001'")) == 1, "legacy custom nickname preserved");
                Check(Convert.ToInt32(scalar("SELECT NICKNAME_SET FROM users WHERE ID='empty1'")) == 0, "legacy whitespace stays unset");
                sql("INSERT INTO users(ID,NAME,PWD,AGENCY) VALUES('later1','预置名字','Test123','')");
                sql(migration);
                Check(Convert.ToInt32(scalar("SELECT NICKNAME_SET FROM users WHERE ID='later1'")) == 0, "new registrations default to unset and repeated migration does not backfill them");
                using (var config = new HttpConfiguration())
                {
                    config.MapHttpAttributeRoutes();
                    config.Routes.MapHttpRoute("DefaultApi", "api/{controller}/{id}", new { id = RouteParameter.Optional });
                    using (var server = new HttpServer(config))
                    using (var http = new HttpClient(server) { BaseAddress = new Uri("http://localhost/") })
                    {
                        Func<string, string, string, string, JObject> post = (route, id, pwd, name) => {
                            var fields = new Dictionary<string, string> { { "playerId", id }, { "pwd", pwd } };
                            if (name != null) fields["name"] = name;
                            var response = http.PostAsync("api/UpdateUsers" + route, new FormUrlEncodedContent(fields)).Result;
                            Check(response.IsSuccessStatusCode, "POST " + route + " route accepts Unity form body");
                            var result = JObject.Parse(response.Content.ReadAsStringAsync().Result);
                            Check(result["datas"] == null || !result["datas"].ToString().Contains("Test123"), "response never echoes password");
                            return result;
                        };
                        Func<string, string, JObject> status = (id, pwd) => post("/NicknameStatus", id, pwd, null);
                        Check(!(bool)status("new001", "Test123")["datas"]["nicknameSet"], "first lobby needs setup");
                        Check(!(bool)status("new001", "Test123")["datas"]["nicknameSet"], "closing without save and entering again still needs setup");
                        Check((bool)status("old001", "Test123")["datas"]["nicknameSet"], "existing custom nickname needs no prompt");
                        foreach (string pwd in new[] { "", "wrong", "test123", "' OR 1=1 --" })
                            Check((int)status("new001", pwd)["code"] != 10000, "invalid or differently cased password rejected");
                        Check((int)status("missing", "Test123")["code"] != 10000, "unknown player rejected");
                        Check((int)post("", "new001", "wrong", "名字")["code"] != 10000, "save rejects wrong password");
                        foreach (string name in new[] { "", "   ", "123456789", "名字!" })
                            Check((int)post("", "new001", "Test123", name)["code"] != 10000, "invalid nickname rejected");
                        Check(!(bool)status("new001", "Test123")["datas"]["nicknameSet"], "failed saves never mark completion");
                        var saved = post("", "new001", "Test123", "  星河一号  ");
                        Check((int)saved["code"] == 10000 && (string)saved["datas"]["name"] == "星河一号", "trimmed nickname saves successfully");
                        Check((bool)status("new001", "Test123")["datas"]["nicknameSet"], "fresh request sees persisted completion");
                        Check((int)post("", "new001", "Test123", "星河一号")["code"] == 10000, "repeated same-name save succeeds");
                        Check((int)post("", "other1", "Test123", "other1")["code"] == 10000, "explicitly choosing account itself is allowed");
                        Check((bool)status("other1", "Test123")["datas"]["nicknameSet"], "completion comes from flag, not name comparison");
                        sql("CREATE TRIGGER reject_nickname BEFORE UPDATE ON users FOR EACH ROW SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='test rollback'");
                        Check((int)post("", "later1", "Test123", "失败测试")["code"] != 10000, "database save failure reported");
                        Check(!(bool)status("later1", "Test123")["datas"]["nicknameSet"], "database failure leaves completion unset");
                        Check((string)scalar("SELECT NAME FROM users WHERE ID='later1'") == "预置名字", "database failure leaves nickname unchanged");
                        sql("DROP TRIGGER reject_nickname");
                        sql("DELETE FROM users WHERE ID='other1'; INSERT INTO users(ID,NAME,PWD,AGENCY) VALUES('other1','other1','Test123','')");
                        Check(!(bool)status("other1", "Test123")["datas"]["nicknameSet"], "deleted account registered again starts unset");
                        Check(controller.Post(null).code != 10000 && controller.NicknameStatus(null).code != 10000, "null requests fail safely");
                        Check(!http.GetAsync("api/UpdateUsers/NicknameStatus?playerId=new001&pwd=Test123").Result.IsSuccessStatusCode, "status only accepts POST");
                    }
                }
                Console.WriteLine("PASS " + checks + " checks in " + timer.Elapsed.TotalSeconds.ToString("F2") + " seconds");
            }
            finally { sql("DROP DATABASE `" + schema + "`"); }
        }
    }
}
