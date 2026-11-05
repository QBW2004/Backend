// Real MVC serialization, production store and isolated MySQL/PC54 pipe.
using System;
using System.Configuration;
using System.Data.Entity;
using System.Diagnostics;
using System.IO;
using System.IO.Pipes;
using System.Linq;
using System.Text;
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

class MjhlInheritanceValidation
{
    static int checks;
    static void Check(bool value, string name) { if (!value) throw new Exception(name); checks++; }
    sealed class Response : HttpResponseBase
    {
        public readonly StringWriter Body = new StringWriter();
        public override string ContentType { get; set; }
        public override Encoding ContentEncoding { get; set; }
        public override int StatusCode { get; set; }
        public override string StatusDescription { get; set; }
        public override System.Collections.Specialized.NameValueCollection Headers { get { return headers; } }
        readonly System.Collections.Specialized.NameValueCollection headers = new System.Collections.Specialized.NameValueCollection();
        public override void Clear() { Body.GetStringBuilder().Clear(); }
        public override void End() { }
        public override void Write(string value) { Body.Write(value); }
    }
    sealed class Request : HttpRequestBase { public override string HttpMethod { get { return "POST"; } } }
    sealed class Context : HttpContextBase
    {
        public readonly Response Output = new Response();
        public override HttpResponseBase Response { get { return Output; } }
        public override HttpRequestBase Request { get { return new Request(); } }
    }
    static JObject Json(ActionResult result)
    {
        var context = new Context();
        result.ExecuteResult(new ControllerContext { HttpContext = context });
        return JObject.Parse(context.Output.Body.ToString());
    }
    static void Login(string name, int privilege)
    {
        WebHelper.WriteSession("LoginInfo", DESEncrypt.Encrypt(new M_LoginUser { UserID=1, Accounts=name, UserName=name, UserPriv=privilege }.ToString()));
    }
    static MjhlAgentConfigStore.Row Save(string line, long revision, MjhlAgentConfig config, string summary = "fixture-summary")
    {
        using (var ef = new GameDbContext()) return MjhlAgentConfigStore.Save(ef, line, revision, config, "fixture", summary);
    }
    static MjhlAgentConfigStore.Row Change(string line, long revision, long source, bool copy)
    {
        using (var ef = new GameDbContext()) return MjhlAgentConfigStore.ChangeInheritance(ef, line, revision, source, copy, "fixture");
    }
    static void Reject(Action action, string name)
    {
        try { action(); } catch (ArgumentException) { checks++; return; }
        throw new Exception("Expected rejection: " + name);
    }
    static JObject Hot(Func<ActionResult> action)
    {
        string name = ConfigurationManager.AppSettings["pipeName"];
        Check(name.StartsWith("mjhl_inheritance_fixture_"), "isolated pipe");
        using (var pipe = new NamedPipeServerStream(name, PipeDirection.InOut, 1, PipeTransmissionMode.Byte, PipeOptions.Asynchronous))
        {
            var read = Task.Run(() => { pipe.WaitForConnection(); byte[] bytes = new byte[4]; int count=0;
                while(count<4) { int n=pipe.Read(bytes,count,4-count); if(n==0)break; count+=n; }
                return count==4 && bytes.SequenceEqual(new byte[]{80,67,0,54}); });
            var result = Json(action());
            Check((int)result["code"] == 1, "controller mutation: " + result);
            Check(read.Wait(3000) && read.Result && (bool)result["hotReload"], "actual PC54 sent after commit");
            return result;
        }
    }
    static int Main()
    {
        try { Run(); return 0; } catch (Exception ex) { Console.Error.WriteLine(ex); return 1; }
    }
    static void Run()
    {
        var timer=Stopwatch.StartNew();
        var cs=new MySqlConnectionStringBuilder(ConfigurationManager.ConnectionStrings["DbConnString"].ConnectionString);
        Check(cs.Server=="127.0.0.1" && cs.Port==33396 && cs.Database.StartsWith("mth_mjhl_inheritance_fixture_"), "isolated DB only");
        string schema=cs.Database; cs.Database="";
        Database.SetInitializer<GameDbContext>(null);
        var context=new HttpContext(new HttpRequest("","http://localhost/",""),new HttpResponse(new StringWriter()));
        SessionStateUtility.AddHttpSessionStateToContext(context,new HttpSessionStateContainer("fixture",new SessionStateItemCollection(),new HttpStaticObjectsCollection(),30,true,HttpCookieMode.UseCookies,SessionStateMode.InProc,false));
        HttpContext.Current=context; Login("fixture",0);
        var xml=new XmlDocument();xml.Load(Path.Combine(AppDomain.CurrentDomain.BaseDirectory,"Config/MsgDefine.config"));CacheHelper.Add<XmlDocument>("SRV_XML_KEY",xml);
        using(var db=new MySqlConnection(cs.ConnectionString))
        {
            db.Open();
            Action<string> sql=q=>{using(var cmd=new MySqlCommand(q,db))cmd.ExecuteNonQuery();};
            Func<string,string> scalar=q=>{using(var cmd=new MySqlCommand(q,db))return Convert.ToString(cmd.ExecuteScalar());};
            sql("CREATE DATABASE `"+schema+"` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci");
            try
            {
                sql("USE `"+schema+"`");
                string snapshot=SqlSnapshot.Read(ConfigurationManager.AppSettings["repoRoot"]);
                foreach(string table in new[]{"mjhl_agent_config","mjhl_agent_config_history"}) sql(SqlSnapshot.Table(snapshot,table));
                sql("CREATE TABLE admin(ID varchar(64) PRIMARY KEY,PRIV int,AGENCY varchar(64),PlayableGames varchar(100)); INSERT INTO admin VALUES ('fixture',0,'',NULL),('agentA',1,'fixture','54'),('agentB',1,'fixture','54'),('denied',1,'fixture','5'),('child',2,'agentA','54')");
                sql("CREATE TABLE roomtableowner(GameId int,LineAgent varchar(64)); INSERT INTO roomtableowner VALUES(54,'untouched'); CREATE TABLE robot_seat(GameId int,Note varchar(64)); INSERT INTO robot_seat VALUES(54,'untouched')");
                var controller=new GameConfigController();
                foreach(string name in new[]{"CopyMjhlDefaultConfig","RecallMjhlAgentConfig"})
                {
                    var method=typeof(GameConfigController).GetMethod(name);
                    foreach(var attribute in new[]{typeof(AjaxOnlyAttribute),typeof(HttpPostAttribute),typeof(ValidateAntiForgeryTokenAttribute),typeof(SuperAdminAuthorizeAttribute)})
                        Check(method.IsDefined(attribute,true),name+" requires "+attribute.Name);
                }
                Check((int)Json(controller.CopyMjhlDefaultConfig("agentA","0","0"))["code"]==0,"missing default rejected");
                Check((int)Json(controller.RecallMjhlAgentConfig("agentA","0","0"))["code"]==0,"missing default recall rejected");
                Check((int)Json(controller.CopyMjhlDefaultConfig("*","0","0"))["code"]==0,"default self-copy rejected");
                Check((int)Json(controller.CopyMjhlDefaultConfig("denied","0","0"))["code"]==0,"unavailable game rejected");
                Check((int)Json(controller.CopyMjhlDefaultConfig("missing","0","0"))["code"]==0,"unknown agent rejected");
                Check((int)Json(controller.CopyMjhlDefaultConfig("child","0","0"))["code"]==0,"child cannot become a line");
                Check((int)Json(controller.CopyMjhlDefaultConfig("agentA","invalid","0"))["code"]==0,"invalid revision rejected");
                var first=MjhlAgentConfig.Default();first.targetRtp=81;first.goldChance=7;first.bets.scorePerCoin=1;
                Save("*",0,first);
                var inherited=Json(controller.GetMjhlAgentConfig("agentA"));
                Check((bool)inherited["inherited"] && !(bool)inherited["configured"] && (string)inherited["revision"]=="0" && (string)inherited["sourceRevision"]=="1","effective default metadata");
                Check(JToken.DeepEquals(inherited["config"],JObject.Parse(first.ToJson())),"HTTP config is actual saved default");
                Check(scalar("SELECT COUNT(*) FROM mjhl_agent_config")=="1","read never creates independent row");
                Hot(()=>controller.CopyMjhlDefaultConfig("agentA","0","1"));
                var copied=Json(controller.GetMjhlAgentConfig("agentA"));
                Check((bool)copied["configured"] && !(bool)copied["inherited"] && (string)copied["revision"]=="1","copied independent metadata");
                Check(JToken.DeepEquals(copied["config"],inherited["config"]) && (string)copied["simulationSummary"]=="fixture-summary","copy entire config and RTP summary");
                Check((int)Json(controller.CopyMjhlDefaultConfig("agentA","1","1"))["code"]==0,"duplicate copy rejected");
                var other=MjhlAgentConfig.Parse(first.ToJson());other.goldChance=3;Save("agentB",0,other);
                var second=MjhlAgentConfig.Parse(first.ToJson());second.targetRtp=88;second.goldChance=11;Save("*",1,second);
                Check((decimal)Json(controller.GetMjhlAgentConfig("agentA"))["config"]["goldChance"]==7,"default updates do not change independent line");
                Check((int)Json(controller.RecallMjhlAgentConfig("agentA","1","1"))["code"]==0,"stale default revision rejected");
                Hot(()=>controller.RecallMjhlAgentConfig("agentA","1","2"));
                var recalled=Json(controller.GetMjhlAgentConfig("agentA"));
                Check((bool)recalled["inherited"] && !(bool)recalled["configured"] && (string)recalled["revision"]=="2","recall has persistent generation");
                Check(JToken.DeepEquals(recalled["config"],JObject.Parse(second.ToJson())),"recall returns current default");
                Check(scalar("SELECT COUNT(*) FROM mjhl_agent_config WHERE LineAgent='agentA'")=="0","runtime snapshot no longer has independent profile");
                Check(scalar("SELECT ConfigJson FROM mjhl_agent_config_history WHERE LineAgent='agentA' AND Revision=2")==first.ToJson(),"recall audit preserves removed parameters");
                Reject(()=>Save("agentA",1,first),"stale save after recall");
                Reject(()=>Change("agentA",0,2,true),"pre-creation page cannot recreate");
                Hot(()=>controller.CopyMjhlDefaultConfig("agentA","2","2"));
                Check((string)Json(controller.GetMjhlAgentConfig("agentA"))["revision"]=="3","re-copy advances version");
                Reject(()=>Change("agentA",1,2,false),"old recall cannot remove new copy");
                Hot(()=>controller.RecallMjhlAgentConfig("agentA","3","2"));
                Check(Save("agentA",4,first).Revision==5,"ordinary save works after recall");
                Check((int)Json(controller.RecallMjhlAgentConfig("*","2","2"))["code"]==0,"default cannot be recalled");
                Check((decimal)Json(controller.GetMjhlAgentConfig("agentB"))["config"]["goldChance"]==3,"other line unchanged");
                var lines=Json(controller.GetMjhlAgentLines());
                Check((int)lines["code"]==1 && lines["datas"]["Lines"].Any(l=>(string)l["id"]=="agentA" && (string)l["text"]=="agentA（独立参数配置）"),"line status shown");
                Check(!lines["datas"]["Lines"].Any(l=>(string)l["id"]=="denied"),"unavailable game hidden");
                Login("agentA",1);
                Check((int)Json(controller.GetMjhlAgentConfig("agentB"))["code"]==0,"read isolated from other line");
                Check(!(bool)Json(controller.GetMjhlAgentConfig("agentA"))["canEdit"],"ordinary agent read only");
                var authorization=new AuthorizationContext { HttpContext=new Context() };new SuperAdminAuthorizeAttribute().OnAuthorization(authorization);
                Check(authorization.Result!=null,"actual authorization rejects agent writes");Login("fixture",0);
                for(int i=0;i<12;i++)
                {
                    string line="race"+i;
                    var copies=Enumerable.Range(0,2).Select(n=>Task.Run(()=>{try {Change(line,0,2,true);return true;}catch(ArgumentException){return false;}})).ToArray();
                    Task.WaitAll(copies);Check(copies.Count(t=>t.Result)==1,"concurrent copy exactly one winner "+i);
                    var races=new[]{Task.Run(()=>{try{Save(line,1,first);return true;}catch(ArgumentException){return false;}}),Task.Run(()=>{try{Change(line,1,2,false);return true;}catch(ArgumentException){return false;}})};
                    Task.WaitAll(races);Check(races.Count(t=>t.Result)==1,"concurrent save/recall exactly one winner "+i);
                    Check(scalar("SELECT COUNT(*) FROM mjhl_agent_config_history WHERE LineAgent='"+line+"'")=="2","concurrent history consistent "+i);
                }
                Save("rollback",0,first);
                sql("CREATE TRIGGER reject_fixture_history BEFORE INSERT ON mjhl_agent_config_history FOR EACH ROW BEGIN IF NEW.LineAgent IN ('rollback','rollbackcopy') THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='fixture history failure'; END IF; END");
                foreach(bool copy in new[]{false,true})
                {
                    bool failed=false;try{Change(copy?"rollbackcopy":"rollback",copy?0:1,2,copy);}catch(Exception){failed=true;}
                    Check(failed,"injected history failure");
                }
                Check(scalar("SELECT Revision FROM mjhl_agent_config WHERE LineAgent='rollback'")=="1","failed recall rolled back deletion");
                Check(scalar("SELECT COUNT(*) FROM mjhl_agent_config WHERE LineAgent='rollbackcopy'")=="0","failed copy rolled back insertion");
                Check(scalar("SELECT Note FROM robot_seat")=="untouched" && scalar("SELECT LineAgent FROM roomtableowner")=="untouched","table ownership and robots untouched");
                File.WriteAllText(Path.Combine(AppDomain.CurrentDomain.BaseDirectory,"../controller-fixtures.json"),new JObject{{"inherited",inherited},{"copied",copied},{"recalled",recalled}}.ToString());
            }
            finally { sql("DROP DATABASE `"+schema+"`"); }
        }
        Console.WriteLine("PASS "+checks+" Controller/HTTP/MySQL/concurrency/PC54 checks in "+timer.ElapsedMilliseconds+"ms");
    }
}
