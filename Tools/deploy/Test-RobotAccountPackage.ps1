param([Parameter(Mandatory=$true)][string]$SitePath)

# Run in a fresh Windows PowerShell process so validation uses this package's DLLs.
# PrepareMethod checks references without executing an action or touching the DB.
$ErrorActionPreference='Stop'
$bin=Join-Path (Resolve-Path -LiteralPath $SitePath).Path 'bin'
foreach($name in @('System.Web.Mvc.dll','YYT.Entity.dll','YYT.BLL.dll')) {
    [void][Reflection.Assembly]::LoadFrom((Join-Path $bin $name))
}
$web=[Reflection.Assembly]::LoadFrom((Join-Path $bin 'YYT.Web.dll'))
$controller=$web.GetType('YYT.Web.Areas.Game.Controllers.RobotController',$true)
foreach($name in @('BatchCreateRobotAccounts','BatchDeleteRobotAccounts')) {
    $method=$controller.GetMethod($name)
    if($null -eq $method) { continue } # Older releases do not expose batch actions.
    try {
        [Runtime.CompilerServices.RuntimeHelpers]::PrepareMethod($method.MethodHandle)
    } catch {
        throw "Robot package dependency check failed ($name): $($_.Exception.GetBaseException().Message)"
    }
    Write-Output "$name dependency check passed"
}
