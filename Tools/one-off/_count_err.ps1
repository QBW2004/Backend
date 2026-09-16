$pat = 'cannot be constructed in a LINQ to Entities query'
$acts = 'UserInfoController.Get\w+|B_Users\.\w+'
Get-ChildItem 'C:\Backend\Logs\*.log' | Sort-Object Name | ForEach-Object {
  $f=$_
  $m = Select-String -Path $f.FullName -Pattern $pat -Encoding Default
  if ($m.Count -gt 0) {
    $t = Select-String -Path $f.FullName -Pattern 'UserInfoController\.\w+' -Encoding Default
    $a = ($t | ForEach-Object { ($_.Line -replace '.*UserInfoController\.','') } | Group-Object | ForEach-Object { $_.Name + 'x' + $_.Count }) -join ' '
    Write-Output ("$($f.Name)  err=$($m.Count)  entries=$a")
  }
}
