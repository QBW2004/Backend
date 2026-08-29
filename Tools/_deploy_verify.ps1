# One-off: post-deploy verification on server.
$ErrorActionPreference = 'Continue'
$web = 'C:\Backend'
$bk = Get-ChildItem C:\ -Directory -Filter 'Backend_backup_*' | Sort-Object Name -Descending | Select-Object -First 1
Write-Output ("LATEST_BACKUP: " + $bk.FullName)

# --- Web.config diff (masked), old vs new ---
$cfgOld = [xml](Get-Content (Join-Path $bk.FullName 'Web.config') -Raw)
$cfgNew = [xml](Get-Content (Join-Path $web 'Web.config') -Raw)
function AppsetMap([xml]$c) {
  $h = @{}
  foreach ($a in $c.configuration.appSettings.add) { $h[$a.key] = $a.value }
  return $h
}
$old = AppsetMap $cfgOld
$new = AppsetMap $cfgNew
Write-Output '--- appSettings CHANGED (pwd masked) ---'
foreach ($k in ($old.Keys + $new.Keys | Sort-Object -Unique)) {
  $ov = if ($old.ContainsKey($k)) { $old[$k] } else { '<ABSENT>' }
  $nv = if ($new.ContainsKey($k)) { $new[$k] } else { '<ABSENT>' }
  if ($ov -ne $nv) {
    $ovm = $ov -replace '(=[A-Za-z0-9+/]{8})[A-Za-z0-9+/=]{8,}', '$1***'
    $nvm = $nv -replace '(=[A-Za-z0-9+/]{8})[A-Za-z0-9+/=]{8,}', '$1***'
    Write-Output ("APPSET " + $k + ": [" + $ovm + "] -> [" + $nvm + "]")
  }
}
$ocs = ($cfgOld.configuration.connectionStrings.add | Where-Object { $_.name -eq 'DbConnString' }).connectionString
$ncs = ($cfgNew.configuration.connectionStrings.add | Where-Object { $_.name -eq 'DbConnString' }).connectionString
if ($ocs -ne $ncs) { Write-Output 'CONNSTR: CHANGED' } else { Write-Output 'CONNSTR: unchanged' }

# --- new files present ---
Write-Output '--- new phone files on server ---'
foreach ($f in @('Content\css\phone.css','Views\Login\Mobile.cshtml','Areas\Mobile\Views\Home\Abnormal.cshtml','Areas\Mobile\Views\Home\Huiyuan.cshtml','Areas\Game\Controllers\AbnormalController.cs','Filters\MobileOnlyAttribute.cs')) {
  $p = Join-Path $web $f
  Write-Output ((Test-Path $p).ToString() + '  ' + $f)
}
Get-ChildItem (Join-Path $web 'Scripts\app\phone') -ErrorAction SilentlyContinue | ForEach-Object { Write-Output ('  js: ' + $_.Name) }

# --- version + dll ---
$ver = $new['WebVer']
Write-Output ("WebVer now: " + $ver)
Write-Output ("YYT.Web.dll LastWriteTime: " + (Get-Item (Join-Path $web 'bin\YYT.Web.dll')).LastWriteTime)

# --- upload dir situation ---
Write-Output ("UploadPath setting: " + $new['UploadPath'])
Write-Output ("C:\Uploads exists: " + (Test-Path 'C:\Uploads'))
Write-Output ("D:\ exists: " + (Test-Path 'D:\'))
Write-Output ("C:\Backend\Upload exists: " + (Test-Path (Join-Path $web 'Upload')))
