param([string]$WebBin = '')
$ErrorActionPreference = 'Stop'
if ($PSVersionTable.PSEdition -eq 'Core') { throw 'Run with Windows PowerShell 5.1 for the .NET Framework MVC runtime.' }
$watch = [Diagnostics.Stopwatch]::StartNew()
$root = (Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
if (!$WebBin) { $WebBin = Join-Path $root 'TTY.Web/bin' }
$mvcPath = Join-Path $WebBin 'System.Web.Mvc.dll'
Add-Type -AssemblyName System.Web
[void][Reflection.Assembly]::LoadFrom($mvcPath)
$web = [Reflection.Assembly]::LoadFrom((Join-Path $WebBin 'YYT.Web.dll'))
$source = @'
using System;
using System.Collections.Specialized;
using System.Web;
using System.Web.Mvc;
using System.Web.Routing;
public class GameRecordProbeRequest : HttpRequestBase {
    public string Verb;
    public NameValueCollection Values = new NameValueCollection();
    public override string HttpMethod { get { return Verb; } }
    public override NameValueCollection Headers { get { return new NameValueCollection { { "X-Requested-With", "XMLHttpRequest" } }; } }
    public override NameValueCollection Form { get { return Values; } }
    public override NameValueCollection QueryString { get { return new NameValueCollection(); } }
}
public class GameRecordProbeContext : HttpContextBase {
    public GameRecordProbeRequest ProbeRequest;
    public override HttpRequestBase Request { get { return ProbeRequest; } }
}
public class GameRecordProbeController : Controller {}
public static class GameRecordRouteProbe {
    public static string Select(Type type, string verb, bool withId) {
        var request = new GameRecordProbeRequest { Verb = verb };
        if (withId) request.Values.Add("id", "5");
        var context = new ControllerContext(new GameRecordProbeContext { ProbeRequest = request }, new RouteData(), new GameRecordProbeController());
        var descriptor = new ReflectedControllerDescriptor(type);
        var action = descriptor.FindAction(context, "GetGamesTreeData");
        return action == null ? "NO_ACTION" : ((ReflectedActionDescriptor)action).MethodInfo.ToString();
    }
}
'@
Add-Type -TypeDefinition $source -ReferencedAssemblies @($mvcPath, 'System.Web.dll')
$gameRecord = $web.GetType('YYT.Web.Areas.Game.Controllers.GameRecordController', $true)
$expected = 'System.Web.Mvc.ActionResult GetGamesTreeData()'
foreach ($withId in @($false, $true)) {
    $actual = [GameRecordRouteProbe]::Select($gameRecord, 'POST', $withId)
    if ($actual -ne $expected) { throw "Unexpected POST selection: $actual" }
}
if ([GameRecordRouteProbe]::Select($gameRecord, 'GET', $false) -ne 'NO_ACTION') { throw 'GET must remain rejected.' }
$method = $gameRecord.GetMethod('GetGamesTreeData')
$attributes = @($method.GetCustomAttributes($true) | ForEach-Object { $_.GetType().Name })
if ($attributes -notcontains 'AjaxOnlyAttribute' -or $attributes -notcontains 'HttpPostAttribute') { throw 'Action guards missing.' }
if (@($gameRecord.GetCustomAttributes($true) | ForEach-Object { $_.GetType().Name }) -notcontains 'MemberAuthorizeAttribute') { throw 'Member authorization missing.' }
$robot = $web.GetType('YYT.Web.Areas.Game.Controllers.RobotController', $true)
if ([GameRecordRouteProbe]::Select($robot, 'POST', $false) -ne 'System.Web.Mvc.ActionResult GetGamesTreeData(System.Web.Mvc.FormCollection)') { throw 'Robot control case failed.' }
$watch.Stop()
[pscustomobject]@{ Result = 'PASS'; Checks = 6; ElapsedMs = $watch.ElapsedMilliseconds; Scope = 'MVC action selection and guards only; no controller action, DB or pipe invoked' } | ConvertTo-Json
