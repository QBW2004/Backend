// 真实 Controller + 独立回环 MySQL；专用测试管道只接收 PC55，不接触在服进程。
using System;
using System.Configuration;
using System.Data.Entity;
using System.Diagnostics;
using System.IO;
using System.IO.Pipes;
using System.Text;
using System.Linq;
using System.Threading.Tasks;
using System.Web;
using System.Web.Mvc;
using System.Web.SessionState;
using System.Xml;
using MySql.Data.MySqlClient;
using Newtonsoft.Json.Linq;
using YYT.BLL.EF;
using YYT.Common;
using YYT.Entity;
using YYT.Web;
using YYT.Web.Areas.Game.Controllers;
using YYT.Web.Models;

class RabbitRulesValidation
{
    static int checks;
    static void Check(bool value, string name) { if (!value) throw new Exception(name); checks++; }
    static JObject Json(ActionResult result) { return JObject.FromObject(((JsonResult)result).Data); }
    static JObject ReadTable(GameConfigController controller, int id)
    {
        JObject result = Json(controller.GetTableConfig(new FormCollection { {"GAME_ID","55"}, {"GAME_TYPE","1"} }));
        Check((int)result["code"] == 1, "actual table query: " + result);
        return ((JArray)result["datas"]).OfType<JObject>().Single(t => (int)t["id"] == id);
    }
    static JObject FullRules(bool enabled, int offset)
    {
        var c = JObject.Parse(RabbitConfig.DefaultJson);
        c["smallFourMultiplier"] = 61 + offset; c["keepMax"] = 8 + offset; c["keepMinHands"] = 123 + offset;
        c["passTarget"] = 33000 + offset; c["passBonus"] = 3300 + offset;
        c["explodeTarget"] = 110000 + offset; c["explodeBonus"] = 11000 + offset;
        var a = (JObject)c.SelectToken("specialRules.authentic"); a["enabled"] = enabled;
        a["baseMultiplier"] = 83 + offset; a["revealTimeoutSeconds"] = 21 + offset;
        a["multipliers"] = JObject.Parse("{values:[1,4,14],weights:[2,5,7]}");
        var f = (JObject)c.SelectToken("specialRules.five"); f["enabled"] = enabled;
        f["baseMultiplier"] = 251 + offset; f["successMultiplier"] = 3 + offset; f["missMultiplier"] = 1 + offset;
        f["revealTimeoutSeconds"] = 21 + offset;
        f["successChance"] = JObject.Parse("{numerator:2,denominator:7}");
        f["forcedSuccessChance"] = JObject.Parse("{numerator:3,denominator:8}");
        var t = (JObject)c.SelectToken("specialRules.streak"); t["enabled"] = enabled;
        t["burnRounds"] = 23 + offset; t["poolContributionBasisPoints"] = 345 + offset;
        t["initialPool"] = 456789 + offset; t["awardCounts"] = JObject.Parse("{values:[2,4,6],weights:[3,5,7]}");
        int d = 11;
        foreach (string name in new[] {"startChance","continueChance","expiredChance","secondJokerChance","jokerFirstChance"})
            t[name] = new JObject { {"numerator", ++d + offset}, {"denominator", d + 10 + offset} };
        t["guaranteeLastRound"] = enabled; t["blockHigherPrizes"] = enabled;
        c["specialRules"]["settlement"]["passEnabled"] = enabled;
        c["specialRules"]["settlement"]["explodeEnabled"] = enabled;
        return c;
    }
    static void VerifyAllFields(GameConfigController controller, MySqlConnection db)
    {
        var fixture = new JObject { {"tables",new JArray()} };
        for (int i = 0; i < 2; i++)
        {
            int id = 55000 + i; JObject config = FullRules(i == 0, i);
            var form = TableForm(id, config.ToString());
            string[] names = {"TableName","MinBet","MaxBet","COIN_SC","COIN_NEED","EX_COIN","Game_Mo","scoreSwitch","CardDIF","HYPE_TYPE","IdleFireTimeoutSec","Enabled","MaxSeats"};
            string[][] values = {
                new[] {"全参数A'桌","3","120","37","41","111","1","7","1234567890123456","2","4","1","1"},
                new[] {"全参数B桌","5","180","53","91","222","2","9","6543210987654321","3","0","0","1"}
            };
            for (int j = 0; j < names.Length; j++) form[names[j]] = values[i][j];
            form["jk1"] = (1000 + i).ToString(); form["jk2"] = (2000 + i).ToString(); form["jk3"] = (3000 + i).ToString();
            form["JokerOn"] = (1 - i).ToString();
            for (int h = 0; h <= 12; h++) {form["hp"+h] = (h == 0 ? 8000 : 10 * (h + 1) + i).ToString(); form["he"+h] = (h == 2 || h == 4 ? "0" : "1");}
            SaveTable(controller, form);
            JObject actual = ReadTable(controller, id);
            string[] keys = {"tableName","minBet","maxBet","coinSc","coinNeed","exCoin","gameMo","scoreSwitch","cardDif","hypeType","idleFireTimeoutSec","enabled","maxSeats"};
            for (int j = 0; j < keys.Length; j++) Check(actual[keys[j]].ToString() == values[i][j], "full field readback table " + i + ": " + keys[j]);
            Check((int)actual["jokerOn"] == 1-i && (int)actual["payoutOn"] == 1, "rule toggles read back per table " + i);
            for (int j=1;j<=3;j++) Check(actual["jk"+j].ToString()==form["jk"+j], "joker field roundtrip " + i + "/" + j);
            for (int h=0;h<=12;h++) {
                Check(actual["payout"]["p"+h].ToString()==form["hp"+h], "payout probability roundtrip " + i + "/" + h);
                Check(actual["payout"]["e"+h].ToString()==(h==0?"1":form["he"+h]), "payout enable roundtrip " + i + "/" + h);
            }
            JObject stored=(JObject)Json(controller.GetRabbitConfig(i))["config"];
            foreach (JValue leaf in config.Descendants().OfType<JValue>()) Check(JToken.DeepEquals(leaf,stored.SelectToken(leaf.Path)), "gameplay field roundtrip " + i + ": " + leaf.Path);
            Func<string,string> scalar=q=>{using(var cmd=new MySqlCommand(q,db))return Convert.ToString(cmd.ExecuteScalar());};
            Check(scalar("SELECT IdleFireTimeoutSec FROM roomtableconfig WHERE GAME_ID=55 AND TableIndex="+i)==(i==0?"240":"0"), "idle minutes converted to database seconds " + i);
            Check(scalar("SELECT MinBetUnits FROM roomtableconfig WHERE GAME_ID=55 AND TableIndex="+i)==(i==0?"30":"50"), "minimum internal units " + i);
            Check(scalar("SELECT MaxBetUnits FROM roomtableconfig_card WHERE GAME_ID=55 AND TableIndex="+i)==(i==0?"1200":"1800"), "maximum internal units " + i);
            ((JArray)fixture["tables"]).Add(new JObject { {"id",id},{"form",JObject.FromObject(form.AllKeys.ToDictionary(k=>k,k=>form[k]))},{"table",actual},{"rules",stored} });
        }
        Check((int)ReadTable(controller,55000)["coinSc"]==37 && (int)ReadTable(controller,55001)["coinSc"]==53,"full second save leaves both complete table snapshots distinct");
        File.WriteAllText(Path.Combine(AppDomain.CurrentDomain.BaseDirectory,"all-parameters.json"),fixture.ToString(),new UTF8Encoding(false));
    }
    static FormCollection TableForm(int id, string rules)
    {
        var form = new FormCollection { {"ID",id.ToString()}, {"GAME_ID","55"}, {"GAME_TYPE","1"},
            {"TableName","统一保存桌台"}, {"MinBet","1"}, {"MaxBet","100"}, {"scoreSwitch","1"},
            {"COIN_SC","100"}, {"EX_COIN","100"}, {"PayoutOn","1"}, {"hp7","10"}, {"JokerOn","1"}, {"jk1","100"} };
        if (rules != null) form.Add("RabbitConfigJson", rules);
        return form;
    }
    static Task<string> Serve(NamedPipeServerStream pipe, bool robot, bool connectionOnly = false)
    {
        return Task.Factory.StartNew(() => { using(pipe) {
            pipe.WaitForConnection();if(connectionOnly)return "CONNECT";
            var all = new MemoryStream(); var bytes = new byte[2048]; int count;
            do { count=pipe.Read(bytes,0,bytes.Length);if(count==0)break;all.Write(bytes,0,count);
                var current=all.ToArray();if(current.Length>=2&&(current[0]==84&&current[1]==67||current[0]==80&&current[1]==67&&current.Length>=4)||current.Contains((byte)10)||robot&&current.Contains((byte)0))break;
            } while(true);
            bytes=all.ToArray();count=bytes.Length;
            string command = Encoding.UTF8.GetString(bytes,0,count).Trim('\uFEFF','\0','\r','\n');
            if (!robot && count == 4 && bytes.Take(4).SequenceEqual(new byte[]{80,67,0,55})) return "PC55";
            string reply = robot ? "RTOK" : command.StartsWith("RP") ? "RPOK" : command.StartsWith("TC") ? "TCOK" : "PAOK";
            byte[] response = Encoding.UTF8.GetBytes(reply+"\n"); pipe.Write(response,0,response.Length); pipe.Flush();
            return robot ? "ROBOT" : command.Substring(0,2);
        } },System.Threading.CancellationToken.None,TaskCreationOptions.LongRunning,TaskScheduler.Default);
    }
    static JObject SaveTable(GameConfigController controller, FormCollection form)
    {
        string name = ConfigurationManager.AppSettings["pipeName"], robot = ConfigurationManager.AppSettings["robotPipeName"];
        Check(name.StartsWith("rabbit_rules_fixture_") && robot.StartsWith("rabbit_rules_fixture_robot_"), "isolated unified-save pipes");
        var pipes = Enumerable.Range(0,5).Select(i => new NamedPipeServerStream(name,PipeDirection.InOut,5,PipeTransmissionMode.Byte,PipeOptions.Asynchronous)).ToList();
        pipes.Add(new NamedPipeServerStream(robot,PipeDirection.InOut,1,PipeTransmissionMode.Byte,PipeOptions.Asynchronous));
        try {
            var readers = pipes.Select((p,i) => Serve(p,i==5,i==4)).ToArray();
            JObject result = Json(controller.SaveTableConfig(form));
            Check((int)result["code"]==1 && (bool)result["datas"], "actual unified save: "+result);
            Check(Task.WaitAll(readers,3000) && readers.Select(r=>r.Result).OrderBy(x=>x).SequenceEqual(new[]{"CONNECT","PA","PC55","ROBOT","RP","TC"}), "RP/TC/PA/PC55 and robot reload after commit");
            return result;
        } finally { foreach(var pipe in pipes) pipe.Dispose(); }
    }
    static int Main()
    {
        try { Run(); return 0; } catch (Exception ex) { Console.Error.WriteLine(ex); return 1; }
    }
    static void Run()
    {
        var timer = Stopwatch.StartNew();
        var cs = new MySqlConnectionStringBuilder(ConfigurationManager.ConnectionStrings["DbConnString"].ConnectionString);
        Check(cs.Server == "127.0.0.1" && (cs.Port == 33308 || cs.Port == 33395) && cs.Database.StartsWith("mth_rabbit_rules_fixture_"), "isolated database");
        string schema = cs.Database; cs.Database = "";
        Database.SetInitializer<GameDbContext>(null);
        var context = new HttpContext(new HttpRequest("", "http://localhost/", ""), new HttpResponse(new StringWriter()));
        SessionStateUtility.AddHttpSessionStateToContext(context, new HttpSessionStateContainer("fixture", new SessionStateItemCollection(), new HttpStaticObjectsCollection(), 30, true, HttpCookieMode.UseCookies, SessionStateMode.InProc, false));
        HttpContext.Current = context;
        WebHelper.WriteSession("LoginInfo", DESEncrypt.Encrypt(new M_LoginUser { Accounts="fixture", UserName="fixture", UserPriv=0 }.ToString()));
        var doc = new XmlDocument(); doc.Load(Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "Config/MsgDefine.config"));
        CacheHelper.Add<XmlDocument>("SRV_XML_KEY", doc);
        var controller = new ActivityConfigController();
        var defaults = JObject.Parse(RabbitConfig.DefaultJson);
        foreach (var attr in new[] { typeof(MemberAuthorizeAttribute), typeof(SuperAdminAuthorizeAttribute) })
            Check(typeof(ActivityConfigController).IsDefined(attr, true), "controller authorization " + attr.Name);
        Check(typeof(ActivityConfigController).GetMethod("SaveRabbitConfig").IsDefined(typeof(ValidateAntiForgeryTokenAttribute), true), "save requires CSRF");
        Check((int)Json(controller.SaveRabbitConfig("{}"))["code"] == 0, "invalid config rejected");
        using (var db = new MySqlConnection(cs.ConnectionString))
        {
            db.Open();
            Action<string> sql = q => { using (var cmd = new MySqlCommand(q, db)) cmd.ExecuteNonQuery(); };
            Func<string, string> scalar = q => { using (var cmd = new MySqlCommand(q, db)) return Convert.ToString(cmd.ExecuteScalar()); };
            sql("CREATE DATABASE `" + schema + "` CHARACTER SET utf8mb4");
            try
            {
                sql("USE `" + schema + "`");
                sql("CREATE TABLE activityconfig(ActivityKey varchar(32) PRIMARY KEY,GameId int,Enabled tinyint,CfgJson text,Operator varchar(50),UpdateTime datetime) ENGINE=InnoDB");
                sql("CREATE TABLE roomtableconfig(GAME_ID int,TableIndex int,BetMax int,RoomIndex int DEFAULT 0,TableName varchar(80) DEFAULT '',Enabled int DEFAULT 1,OneCoinScore int DEFAULT 100,BetMin int DEFAULT 1,CoinsNeed int DEFAULT 0,IdleFireTimeoutSec int DEFAULT 0,IdleFireKickEnabled int DEFAULT 1,MaxSeats int DEFAULT 0,MinBetUnits int DEFAULT 10,GunPowerStep int DEFAULT 10,PRIMARY KEY(GAME_ID,TableIndex)) ENGINE=InnoDB");
                sql("CREATE TABLE cardgamecfg(GAME_ID int,TableIndex int,CfgJson text,PRIMARY KEY(GAME_ID,TableIndex)) ENGINE=InnoDB");
                sql("CREATE TABLE cardpayoutprofile(GAME_ID int,TableId int,HandType int,PayoutMultiplier int DEFAULT 0,ProbabilityBasis int,StockLimit int,StockRemain int,Enabled int,PRIMARY KEY(GAME_ID,TableId,HandType)) ENGINE=InnoDB");
                sql("CREATE TABLE roomtableconfig_card(GAME_ID int,RoomIndex int,TableIndex int,ExCoin int,ScoreSwitch int,GameMo int,MaxBetUnits int,PRIMARY KEY(GAME_ID,TableIndex)) ENGINE=InnoDB");
                sql("CREATE TABLE paracard(ID int PRIMARY KEY,GAME_ID int,DIF varchar(16),HYPE_TYPE int) ENGINE=InnoDB");
                sql("CREATE TABLE pararoom(ID int PRIMARY KEY,GAME_ID int,NUM int,BET_MIN int,BET_MAX int,EX_COIN int,COIN_SC int,COIN_NEED int,scoreSwitch int,Game_Mo int,TableName varchar(80),MaxSeats int,IdleFireTimeoutSec int,IdleFireKickEnabled int,Enabled int,MinBetUnits int,MaxBetUnits int,BetMinValLimit int DEFAULT 0,BetMaxValLimit int DEFAULT 0) ENGINE=InnoDB");
                sql("CREATE TABLE paragame(ID int PRIMARY KEY,ROOM_MAX int,PLY_MAX int) ENGINE=InnoDB");
                var tableController = new GameConfigController();
                Check(typeof(GameConfigController).GetMethod("GetRabbitConfig").IsDefined(typeof(SuperAdminAuthorizeAttribute),true), "table rules require super admin");
                Check(typeof(GameConfigController).GetMethod("SaveTableConfig").IsDefined(typeof(ValidateAntiForgeryTokenAttribute),true), "unified table save requires CSRF");
                var load = Json(tableController.GetRabbitConfig(-1));
                Check((int)load["code"]==1 && (int)load["config"]["smallFourMultiplier"]==50 && (string)load["source"]=="default", "new table starts with independent defaults");
                Check(scalar("SELECT COUNT(*) FROM cardgamecfg")=="0", "reading rules does not persist");
                Check((int)Json(tableController.GetRabbitConfig(-2))["code"]==0 && (int)Json(tableController.GetRabbitPayoutRules(256))["code"]==0, "invalid table rejected");
                Action<int,JObject> put = (index,c) => { using(var command=new MySqlCommand("INSERT INTO cardgamecfg VALUES(55,@index,@json) ON DUPLICATE KEY UPDATE CfgJson=VALUES(CfgJson)",db)) {command.Parameters.AddWithValue("@index",index);command.Parameters.AddWithValue("@json",c.ToString());command.ExecuteNonQuery();} };
                sql("INSERT INTO roomtableconfig(GAME_ID,TableIndex,BetMax) VALUES(55,0,100),(55,1,200),(5,0,100)");
                var a=(JObject)defaults.DeepClone();a["smallFourMultiplier"]=60;a["keepMax"]=9;a["keepMinHands"]=888;a["futureKey"]="keep";
                var b=(JObject)defaults.DeepClone();b["smallFourMultiplier"]=90;
                var legacy=(JObject)defaults.DeepClone();legacy["smallFourMultiplier"]=110;
                put(0,a);put(1,b);sql("INSERT INTO cardgamecfg VALUES(5,0,'other')");
                using(var ef=new GameDbContext())ActivityConfigs.Save(ef,RabbitConfig.SharedKey,55,true,legacy.ToString(),"legacy");
                string legacyJson=scalar("SELECT CfgJson FROM activityconfig WHERE ActivityKey='rabbit_rules'");
                Check((int)Json(tableController.GetRabbitConfig(0))["config"]["smallFourMultiplier"]==60, "first table reads own rules");
                Check((int)Json(tableController.GetRabbitPayoutRules(1))["config"]["smallFourMultiplier"]==90, "second table reads different rules");
                Check(!(bool)Json(tableController.GetRabbitConfig(0))["shared"], "rules never marked shared");
                Check((int)Json(controller.GetRabbitConfig())["code"]==0 && (int)Json(controller.SaveRabbitConfig(legacyJson))["code"]==0, "cached global editor read and write rejected");
                Check((int)Json(tableController.SaveRabbitConfig(0,legacyJson))["code"]==0, "separate cached rule-save route rejected");
                sql("DELETE FROM cardgamecfg WHERE GAME_ID=55 AND TableIndex=1");
                load=Json(tableController.GetRabbitConfig(1));
                Check((string)load["source"]=="legacy" && (int)load["config"]["smallFourMultiplier"]==110, "existing table without row reads old rule as compatibility snapshot");
                Check((int)Json(tableController.GetRabbitConfig(-1))["config"]["smallFourMultiplier"]==50, "new table does not inherit global rule");
                b["smallFourMultiplier"]=99;SaveTable(tableController,TableForm(55001,b.ToString()));
                Check((int)Json(tableController.GetRabbitConfig(1))["config"]["smallFourMultiplier"]==99 && (string)Json(tableController.GetRabbitConfig(1))["source"]=="table", "saving compatibility snapshot creates independent row");
                Check((int)Json(tableController.GetRabbitConfig(0))["config"]["smallFourMultiplier"]==60 && scalar("SELECT CfgJson FROM activityconfig WHERE ActivityKey='rabbit_rules'")==legacyJson, "saving second table preserves first and legacy row");
                sql("UPDATE roomtableconfig SET BetMax=4000000 WHERE GAME_ID=55 AND TableIndex=1");
                a["smallFourMultiplier"]=70;a["race"]=JObject.Parse("{enabled:true,id:9,start:100,end:200,total:1000,multiplier:1}");SaveTable(tableController,TableForm(55000,a.ToString()));
                Check((int)Json(tableController.GetRabbitConfig(0))["config"]["smallFourMultiplier"]==70, "save does not validate unrelated table bet ceiling");
                Check((int)Json(tableController.GetRabbitConfig(1))["config"]["smallFourMultiplier"]==99, "first save never overwrites second rules");
                var stored=Json(tableController.GetRabbitConfig(0))["config"];
                Check((int)stored["keepMax"]==9 && (int)stored["keepMinHands"]==888 && (string)stored["futureKey"]=="keep", "hidden keep settings and unknown keys preserved");
                Check(!(bool)stored["race"]["enabled"] && scalar("SELECT COUNT(*) FROM activityconfig WHERE ActivityKey='rabbit_race'")=="0", "legacy table race disabled without editing global race activity");
                sql("UPDATE roomtableconfig SET BetMax=200 WHERE GAME_ID=55 AND TableIndex=1");
                b["smallFourMultiplier"]=85;b["specialRules"]["authentic"]["multipliers"]=JObject.Parse("{values:[1,2,3,4],weights:[10,20,30,40]}");b["specialRules"]["five"]["successChance"]=JObject.Parse("{numerator:2,denominator:5}");
                SaveTable(tableController,TableForm(55001,b.ToString()));
                Check((int)Json(tableController.GetRabbitConfig(0))["config"]["specialRules"]["authentic"]["multipliers"]["weights"][0]==60 && (int)Json(tableController.GetRabbitConfig(1))["config"]["specialRules"]["authentic"]["multipliers"]["values"][3]==4, "authentic tiers differ independently per table");
                Check((int)Json(tableController.GetRabbitConfig(0))["config"]["specialRules"]["five"]["successChance"]["denominator"]==3 && (int)Json(tableController.GetRabbitConfig(1))["config"]["specialRules"]["five"]["successChance"]["denominator"]==5, "five probability differs independently per table");
                string beforeA=scalar("SELECT CfgJson FROM cardgamecfg WHERE GAME_ID=55 AND TableIndex=0"),beforeB=scalar("SELECT CfgJson FROM cardgamecfg WHERE GAME_ID=55 AND TableIndex=1");
                var invalid=TableForm(55000,a.ToString());invalid["MaxBet"]="4000000";invalid["TableName"]="不应保存";
                Check((int)Json(tableController.SaveTableConfig(invalid))["code"]==0 && scalar("SELECT CfgJson FROM cardgamecfg WHERE GAME_ID=55 AND TableIndex=0")==beforeA, "own unsafe bet maximum blocks whole save");
                sql("UPDATE roomtableconfig SET BetMax=4000000 WHERE GAME_ID=55 AND TableIndex=0");a["smallFourMultiplier"]=2000;SaveTable(tableController,TableForm(55000,a.ToString()));
                Check(scalar("SELECT BetMax FROM roomtableconfig WHERE GAME_ID=55 AND TableIndex=0")=="100", "current bet validated against submitted value");
                beforeA=scalar("SELECT CfgJson FROM cardgamecfg WHERE GAME_ID=55 AND TableIndex=0");
                sql("CREATE TRIGGER rabbit_table_fail BEFORE INSERT ON paracard FOR EACH ROW SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='fixture late failure'");
                a["smallFourMultiplier"]=99;var failed=TableForm(55000,a.ToString());failed["TableName"]="失败桌台";failed["hp7"]="20";
                Check((int)Json(tableController.SaveTableConfig(failed))["code"]==0, "late table write failure rejected");
                Check(scalar("SELECT CfgJson FROM cardgamecfg WHERE GAME_ID=55 AND TableIndex=0")==beforeA && scalar("SELECT TableName FROM roomtableconfig WHERE GAME_ID=55 AND TableIndex=0")=="统一保存桌台" && scalar("SELECT ProbabilityBasis FROM cardpayoutprofile WHERE GAME_ID=55 AND TableId=0 AND HandType=7")=="10", "own rules base parameters and weights roll back together");
                Check(scalar("SELECT CfgJson FROM cardgamecfg WHERE GAME_ID=55 AND TableIndex=1")==beforeB && scalar("SELECT CfgJson FROM activityconfig WHERE ActivityKey='rabbit_rules'")==legacyJson, "failed save preserves other table and legacy rules");
                Check((int)Json(tableController.SaveTableConfig(TableForm(-1,a.ToString())))["code"]==0 && scalar("SELECT COUNT(*) FROM roomtableconfig WHERE GAME_ID=55 AND TableIndex=2")=="0" && scalar("SELECT COUNT(*) FROM cardgamecfg WHERE GAME_ID=55 AND TableIndex=2")=="0", "failed new table leaves no rule or parameter row");
                sql("DROP TRIGGER rabbit_table_fail");
                a["smallFourMultiplier"]=120;SaveTable(tableController,TableForm(-1,a.ToString()));a["smallFourMultiplier"]=140;SaveTable(tableController,TableForm(-1,a.ToString()));
                Check((int)Json(tableController.GetRabbitConfig(2))["config"]["smallFourMultiplier"]==120 && (int)Json(tableController.GetRabbitConfig(3))["config"]["smallFourMultiplier"]==140, "new tables store different submitted rules");
                a["smallFourMultiplier"]=125;SaveTable(tableController,TableForm(55002,a.ToString()));
                Check((int)Json(tableController.GetRabbitConfig(3))["config"]["smallFourMultiplier"]==140, "editing first new table preserves other new table");
                SaveTable(tableController,TableForm(55000,null));
                Check(scalar("SELECT CfgJson FROM cardgamecfg WHERE GAME_ID=55 AND TableIndex=0")==beforeA, "old base-only form preserves own rule");
                sql("INSERT INTO roomtableconfig(GAME_ID,TableIndex,BetMax) VALUES(55,4,100)");SaveTable(tableController,TableForm(55004,null));
                Check((int)Json(tableController.GetRabbitConfig(4))["config"]["smallFourMultiplier"]==110 && scalar("SELECT CfgJson FROM activityconfig WHERE ActivityKey='rabbit_rules'")==legacyJson, "base-only old table materializes compatible rule without changing shared row");
                SaveTable(tableController,TableForm(-1,null));Check((int)Json(tableController.GetRabbitConfig(5))["config"]["smallFourMultiplier"]==50, "base-only new table receives independent defaults");
                var wrong=TableForm(5000,a.ToString());wrong["GAME_ID"]="5";
                Check((int)Json(tableController.SaveTableConfig(wrong))["code"]==0 && scalar("SELECT CfgJson FROM cardgamecfg WHERE GAME_ID=5")=="other", "wrong game cannot receive rabbit rule payload");
                Check((int)Json(tableController.SaveTableConfig(TableForm(55000,"")))["code"]==0, "empty rule payload rejected");
                sql("DROP TABLE activityconfig");b["smallFourMultiplier"]=88;SaveTable(tableController,TableForm(55001,b.ToString()));
                Check((int)Json(tableController.GetRabbitConfig(1))["config"]["smallFourMultiplier"]==88 && scalar("SELECT CfgJson FROM cardgamecfg WHERE GAME_ID=55 AND TableIndex=0")==beforeA, "independent saves do not depend on activity schema");
                Check((int)Json(tableController.GetRabbitConfig(-1))["config"]["smallFourMultiplier"]==50, "default reads do not depend on activity schema");
                VerifyAllFields(tableController,db);
            }
            finally { sql("DROP DATABASE `" + schema + "`"); }
        }
        Console.WriteLine("PASS " + checks + " actual controller/MySQL/auth/PC55 checks in " + timer.Elapsed.TotalSeconds.ToString("F3") + "s");
    }
}
