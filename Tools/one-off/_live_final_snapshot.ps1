$ErrorActionPreference = 'Stop'
& 'C:\mysql\bin\mysql.exe' -uroot -p123456 mth -e "SELECT GameId,LineAgent,Revision,LEFT(ConfigHash,8) h FROM mjhl_agent_config ORDER BY LineAgent; SELECT ID,BET_MIN,BET_MAX,EX_COIN,COIN_SC,BetScores FROM parabetroom WHERE GAME_ID=54" 2>$null
Select-String -Path 'C:\Server\Logs\麻将胡了日志.log' -Pattern 'snapshot committed|oneCoinScore=1|betScores tableIndex' | Select-Object -Last 3 | ForEach-Object { $_.Line.Substring(0, [Math]::Min(160, $_.Line.Length)) }
Get-Process ServerCardMjhl -ErrorAction SilentlyContinue | Select-Object Id, StartTime
