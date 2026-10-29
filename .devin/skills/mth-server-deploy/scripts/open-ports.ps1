# open-ports.ps1 — create the Windows Firewall inbound rules MTH needs.
# Mirrors production rule names ("MTH-Backend HTTP <port>" / "MTH-GameServer TCP <port>").
# Run as administrator. Idempotent (skips ports that already have an allow rule).
param(
  # Web ports opened to ANY. 80 = admin backend direct/CDN origin, 8081 = app HTTP APIs.
  [int[]]$WebPorts = @(80, 8081),
  # Game ports (players connect raw TCP): 9000 center + per-game ports.
  # Includes ports of currently-offline games so re-enabling them needs no firewall edit.
  [int[]]$GamePorts = @(9000, 9100, 9102, 9103, 9109, 9200, 9203, 9204, 9206, 9208, 9209,
                        9300, 9302, 9305, 9307, 9309, 9315, 9316, 9321, 9400, 9402, 9403),
  # Port 8080 on production is restricted to the nginx relay only. Leave empty to skip.
  [string]$TransitIp = ''
)
$ErrorActionPreference = 'Continue'

function Test-PortOpen([int]$Port) {
  foreach ($r in (Get-NetFirewallRule -Direction Inbound -Action Allow -Enabled True -EA SilentlyContinue)) {
    $f = $r | Get-NetFirewallPortFilter -EA SilentlyContinue
    if ($f -and ($f.LocalPort -contains "$Port")) { return $true }
  }
  return $false
}

foreach ($p in $WebPorts) {
  if (Test-PortOpen $p) { Write-Output "SKIP web $p (already open)"; continue }
  New-NetFirewallRule -DisplayName "MTH-Backend HTTP $p" -Direction Inbound -Protocol TCP -LocalPort $p -Action Allow | Out-Null
  Write-Output "OPEN web $p (Any)"
}
foreach ($p in $GamePorts) {
  if (Test-PortOpen $p) { Write-Output "SKIP game $p (already open)"; continue }
  New-NetFirewallRule -DisplayName "MTH-GameServer TCP $p" -Direction Inbound -Protocol TCP -LocalPort $p -Action Allow | Out-Null
  Write-Output "OPEN game $p (Any)"
}
if ($TransitIp) {
  if (Test-PortOpen 8080) { Write-Output "SKIP 8080 (already open)" }
  else {
    New-NetFirewallRule -DisplayName "Allow Nginx Proxy 8080" -Direction Inbound -Protocol TCP -LocalPort 8080 -RemoteAddress $TransitIp -Action Allow | Out-Null
    Write-Output "OPEN 8080 restricted to $TransitIp"
  }
}
Write-Output ""
Write-Output "NOTE: port 3306 (MySQL) and 9600 (robot listener) are intentionally NOT opened."
Write-Output "NOTE: cloud security group (if any) must also allow these ports - Windows firewall alone is not enough on Aliyun/Tencent."
