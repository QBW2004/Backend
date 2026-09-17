# Read-only load probe: hammer endpoints from localhost and report the latency distribution.
$ErrorActionPreference = 'Stop'
$base = 'http://127.0.0.1'

function Hammer($url, $n, $label) {
  $times = New-Object System.Collections.Generic.List[int]
  for ($i = 0; $i -lt $n; $i++) {
    $sw = [Diagnostics.Stopwatch]::StartNew()
    try {
      $r = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 30
      $null = $r.RawContentLength
      $sw.Stop()
      $times.Add([int]$sw.ElapsedMilliseconds)
    } catch {
      $sw.Stop()
      $times.Add(-1)
    }
  }
  $sorted = $times | Sort-Object
  $stalls = ($times | Where-Object { $_ -ge 400 }).Count
  $avg = [math]::Round(($times | Measure-Object -Average).Average, 1)
  Write-Output ("[{0}] n={1} avg={2} min={3} p50={4} p90={5} max={6} stalls>=400ms={7}" -f `
      $label, $times.Count, $avg, $sorted[0], $sorted[[int]($times.Count * 0.5)], `
      $sorted[[int]($times.Count * 0.9)], $sorted[$times.Count - 1], $stalls)
  $slow = $times | Where-Object { $_ -ge 400 }
  if ($slow) { Write-Output ("    slow values: " + (($slow | Sort-Object) -join ',')) }
}

Hammer "$base/Content/css/phone.css" 250 'static phone.css'
Hammer "$base/zh-CN/Login/Mobile" 150 'GET Login/Mobile (view+session)'
Hammer "$base/Content/css/animate.css" 150 'static animate.css'
