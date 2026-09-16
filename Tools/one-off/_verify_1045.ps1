$ErrorActionPreference = 'SilentlyContinue'
$files = @(
    'Web.config',
    'bin\YYT.Web.dll',
    'bin\YYT.BLL.dll',
    'Scripts\app\phone\phone.core.js',
    'Scripts\app\phone\phone.players.js',
    'Scripts\app\phone\phone.control.js',
    'Scripts\app\phone\phone.playerdetail.js',
    'Scripts\app\phone\phone.huiyuan.js'
)
foreach ($f in $files) {
    $p = Join-Path 'C:\Backend' $f
    if (Test-Path $p) {
        $h = (Get-FileHash -Path $p -Algorithm MD5).Hash
        Write-Output ($h + '  ' + $f)
    } else {
        Write-Output ('MISSING           ' + $f)
    }
}
Write-Output ('WebVer=' + (Select-String -Path C:\Backend\Web.config -Pattern 'WebVer').Line.Trim())
