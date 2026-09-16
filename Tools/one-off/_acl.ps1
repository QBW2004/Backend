Write-Output "=== APP POOL IDENTITY ==="
$is64 = [Environment]::Is64BitProcess
$appcmd = if ($is64) { "$env:windir\System32\inetsrv\appcmd.exe" } else { "$env:windir\Sysnative\inetsrv\appcmd.exe" }
& $appcmd list apppool /apppool.name:DefaultAppPool /text:processModel.identityType 2>&1 | Write-Output
& $appcmd list apppool /apppool.name:DefaultAppPool /text:processModel.userName 2>&1 | Write-Output
& $appcmd list apppool /apppool.name:DefaultAppPool /text:name 2>&1 | Write-Output
Write-Output "=== PIPE ACL (try Get-Acl) ==="
try { $a = Get-Acl -LiteralPath '\.\pipe\mynamedpipe' -ErrorAction Stop; Write-Output ($a.Sddl) } catch { Write-Output ("GETACL_FAIL: " + $_.Exception.Message) }
Write-Output "=== PIPE ACL via .NET DirectoryInfo ==="
try { $di = New-Object System.IO.DirectoryInfo '\.\pipe\'; $a2 = $di.GetAccessControl(); Write-Output ("DIR_SDDL=" + $a2.Sddl) } catch { Write-Output ("DIR_FAIL: " + $_.Exception.Message) }
