// Actual controller + SConnect against uniquely named local test pipes. No database is used.
using System;
using System.Configuration;
using System.Diagnostics;
using System.IO.Pipes;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Web.Mvc;
using Newtonsoft.Json.Linq;
using YYT.Web.Areas.Game.Controllers;

class RobotPlayTimeValidation
{
    static int checks;
    static void Check(bool value, string name) { if (!value) throw new Exception(name); checks++; }
    static JObject Json(ActionResult result) { return JObject.FromObject(((JsonResult)result).Data); }
    static FormCollection Form(string min, string max, string enabled = "1")
    {
        return new FormCollection { { "MinHours", min }, { "MaxHours", max }, { "Enabled", enabled } };
    }
    static JObject Call(string command, string response, Func<ActionResult> action)
    {
        string pipeName = ConfigurationManager.AppSettings["robotPipeName"];
        string centerName = ConfigurationManager.AppSettings["pipeName"];
        Check(pipeName.StartsWith("codex_robot_playtime_test_") && centerName.StartsWith("codex_robot_playtime_test_"), "isolated test pipes");
        using (var center = new NamedPipeServerStream(centerName, PipeDirection.InOut, 1, PipeTransmissionMode.Byte, PipeOptions.Asynchronous))
        using (var robot = new NamedPipeServerStream(pipeName, PipeDirection.InOut, 1, PipeTransmissionMode.Byte, PipeOptions.Asynchronous))
        {
            var centerWait = Task.Run(() => center.WaitForConnection());
            var responder = Task.Run(() =>
            {
                robot.WaitForConnection();
                var bytes = new System.Collections.Generic.List<byte>();
                int b;
                while ((b = robot.ReadByte()) > 0) bytes.Add((byte)b);
                Check(Encoding.UTF8.GetString(bytes.ToArray()) == command, "exact command: " + command);
                byte[] reply = Encoding.UTF8.GetBytes(response + "\n");
                robot.Write(reply, 0, reply.Length);
                robot.Flush();
            });
            var result = Json(action());
            Check(responder.Wait(2000) && centerWait.Wait(2000), "local pipe completion");
            return result;
        }
    }
    static void Main()
    {
        var timer = Stopwatch.StartNew();
        var controller = new RobotController();
        foreach (string name in new[] { "GetRobotPlayTime", "SaveRobotPlayTime" })
        {
            var attrs = typeof(RobotController).GetMethod(name).GetCustomAttributes(false).Select(a => a.GetType().Name).ToArray();
            foreach (string attr in new[] { "MemberAuthorizeAttribute", "AjaxOnlyAttribute", "HttpPostAttribute" })
                Check(attrs.Contains(attr), name + " " + attr);
            if (name == "SaveRobotPlayTime") Check(attrs.Contains("SuperAdminAuthorizeAttribute"), "superadmin save only");
        }
        foreach (string invalid in new[] { null, "", "0", "-1", "0.01", "1.25", "720.1", "NaN", "Infinity", "1,5", "1e2", "1\nPLAYTIME 0" })
            Check((int)Json(controller.SaveRobotPlayTime(Form(invalid, "4")))["code"] == 0, "reject minimum " + invalid);
        foreach (string invalid in new[] { "", "0", "1", "721", "2.01", "NaN" })
            Check((int)Json(controller.SaveRobotPlayTime(Form("2", invalid)))["code"] == 0, "reject maximum " + invalid);
        foreach (string invalid in new[] { "", "2", "true", "1 0" })
            Check((int)Json(controller.SaveRobotPlayTime(Form("1", "2", invalid)))["code"] == 0, "reject enabled " + invalid);
        Check((int)Call("PLAYTIME 1 5400 10800", "PLAYTIME_OK", () => controller.SaveRobotPlayTime(Form("1.5", "3")))["code"] == 1, "decimal save");
        Check((int)Call("PLAYTIME 1 360 360", "PLAYTIME_OK", () => controller.SaveRobotPlayTime(Form("0.1", "0.1")))["code"] == 1, "fixed minimum");
        Check((int)Call("PLAYTIME 0 360 2592000", "PLAYTIME_OK", () => controller.SaveRobotPlayTime(Form("0.1", "720", "0")))["code"] == 1, "disable + upper bound");
        Check((int)Call("PLAYTIME 1 3600 7200", "PLAYTIME_BAD", () => controller.SaveRobotPlayTime(Form("1", "2")))["code"] == 0, "server rejection is failure");
        var loaded = Call("PLAYTIME_GET", "PLAYTIME_JSON {\"enabled\":1,\"minSeconds\":5400,\"maxSeconds\":10800}", () => controller.GetRobotPlayTime(new FormCollection()));
        Check((int)loaded["code"] == 1 && (bool)loaded["Enabled"] && (decimal)loaded["MinHours"] == 1.5m && (decimal)loaded["MaxHours"] == 3m, "read seconds as hours");
        Check((int)Call("PLAYTIME_GET", "RTER", () => controller.GetRobotPlayTime(new FormCollection()))["code"] == 0, "old server cannot fake a successful read");
        Check((int)Call("PLAYTIME_GET", "PLAYTIME_JSON {}", () => controller.GetRobotPlayTime(new FormCollection()))["code"] == 0, "malformed read fails");
        Console.WriteLine("PASS " + checks + " actual controller/pipe/input/auth checks (" + timer.Elapsed.TotalSeconds.ToString("F2") + "s)");
    }
}
