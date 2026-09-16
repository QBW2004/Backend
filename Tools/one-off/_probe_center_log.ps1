$files = Get-ChildItem 'C:\Server\Logs\*.log' | Sort-Object Length -Descending
$log = $files[0].FullName
Write-Output ("SCAN=" + $files[0].Name + " size=" + $files[0].Length)
$pat = 'HallLoginTiming|LogoutFromHall|StaleOnlineSweep|ForceShutdown|CheckUserLogOut-State|UserLogOutToHall-State|SaveUserInfo'
$m = Select-String -Path $log -Pattern $pat -Encoding UTF8
Write-Output ("TOTAL_MATCHES=" + $m.Count)
$m | Select-Object -Last 35 | ForEach-Object { $_.Line }
