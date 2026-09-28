# Re-save one bet-game table with its CURRENT values to trigger the backend's RP+TC hot push
# (center -> ServerBetAnimal). Payload values are read back from the same endpoint the page uses,
# so the save is a no-op; only the config push happens. Defaults to GAME_ID=10 (Lucky Lion) table 0.
param(
    [int]$GameId = 10,
    [int]$TableIndex = 0
)

$ErrorActionPreference = 'Stop'
$base = 'http://127.0.0.1'
$h = @{ 'X-Requested-With' = 'XMLHttpRequest' }
$tableId = $GameId * 1000 + $TableIndex

# 1) login (desktop form post; the captcha field itself is not validated, but the
#    antiforgery token from the same page IS required)
$loginPage = Invoke-WebRequest -Uri "$base/zh-CN/Login/Index" -SessionVariable sess -UseBasicParsing -TimeoutSec 60
$lm = [regex]::Match($loginPage.Content, 'name="__RequestVerificationToken"[^>]*value="([^"]*)"')
if (-not $lm.Success) { $lm = [regex]::Match($loginPage.Content, 'value="([^"]*)"[^>]*name="__RequestVerificationToken"') }
if (-not $lm.Success) { throw 'antiforgery token not found on login page' }
$login = Invoke-WebRequest -Uri "$base/zh-CN/Login/Index" -Method POST -Body @{ uname = 'atmadmin'; upwd = '123456'; __RequestVerificationToken = $lm.Groups[1].Value } -WebSession $sess -UseBasicParsing -TimeoutSec 60
Write-Output ("LOGIN status=" + $login.StatusCode)

# 2) antiforgery token from the config page (no lang prefix: the Game area route has none)
$page = Invoke-WebRequest -Uri "$base/Game/GameConfig/Index" -WebSession $sess -UseBasicParsing -TimeoutSec 120
$m = [regex]::Match($page.Content, 'name="__RequestVerificationToken"[^>]*value="([^"]*)"')
if (-not $m.Success) { $m = [regex]::Match($page.Content, 'value="([^"]*)"[^>]*name="__RequestVerificationToken"') }
if (-not $m.Success) { throw 'antiforgery token not found on config page' }
$tok = $m.Groups[1].Value
Write-Output ("TOKEN len=" + $tok.Length)

# 3) current table values (same endpoint the page fills the form from)
$cfgRes = Invoke-WebRequest -Uri "$base/Game/GameConfig/GetTableConfig" -Method POST -Body @{ GAME_TYPE = '0'; GAME_ID = [string]$GameId } -WebSession $sess -Headers $h -UseBasicParsing -TimeoutSec 180
$cfg = $cfgRes.Content | ConvertFrom-Json
$t = @($cfg.datas) | Where-Object { $_.id -eq $tableId }
if ($null -eq $t) { throw ("table " + $tableId + " not found in GetTableConfig") }

Write-Output ("TABLE id=" + $t.id + " name=" + $t.tableName + " min=" + $t.minBet + " max=" + $t.maxBet +
    " minVice=" + $t.betMinVice + " maxVice=" + $t.betMaxVice + " minDraw=" + $t.betMinDraw + " maxDraw=" + $t.betMaxDraw +
    " chips=" + $t.betScores + " cfgLen=" + ([string]$t.betGameCfg).Length)

$body = [ordered]@{
    GAME_TYPE           = '0'
    GAME_ID             = [string]$GameId
    ID                  = [string]$t.id
    TableName           = [string]$t.tableName
    Enabled             = [string]$t.enabled
    IdleFireTimeoutSec  = [string]$t.idleFireTimeoutSec
    IdleFireKickEnabled = [string]$t.idleFireKickEnabled
    MinBet              = [string]$t.minBet
    MaxBet              = [string]$t.maxBet
    COIN_SC             = [string]$t.coinSc
    COIN_NEED           = [string]$t.coinNeed
    EX_COIN             = [string]$t.exCoin
    Game_Mo             = [string]$t.gameMo
    scoreSwitch         = '1'
    BET_TIME            = [string]$t.betTime
    SC_LIMIT_SING       = [string]$t.scLimitSing
    SC_LIMIT_ALL        = [string]$t.scLimitAll
    BANKER_SC_NEED      = [string]$t.bankerScNeed
    BET_MAX_VICE        = [string]$t.betMaxVice
    BET_MAX_DRAW        = [string]$t.betMaxDraw
    BET_MIN_VICE        = [string]$t.betMinVice
    BANKER_PER          = [string]$t.bankerPer
    DIF                 = [string]$t.dif
    HAR                 = [string]$t.har
    SITE_TYPE           = [string]$t.siteType
    BANKER_DIF          = [string]$t.bankerDif
    BANKER_HAR          = [string]$t.bankerHar
    BANKER_SITE_TYPE    = [string]$t.bankerSiteType
    BetScores           = [string]$t.betScores
    BetGameCfg          = [string]$t.betGameCfg
    __RequestVerificationToken = $tok
}

# UTF-8 form body (PS 5.1 default body encoding would mangle the Chinese inside BetGameCfg)
Add-Type -AssemblyName System.Web
$pairs = @()
foreach ($k in $body.Keys) {
    $pairs += ([System.Web.HttpUtility]::UrlEncode($k) + '=' + [System.Web.HttpUtility]::UrlEncode([string]$body[$k]))
}
$bytes = [System.Text.Encoding]::UTF8.GetBytes(($pairs -join '&'))

# 4) save (values unchanged) -> backend sends RP + TC, center re-pushes per-table bet params
$save = Invoke-WebRequest -Uri "$base/Game/GameConfig/SaveTableConfig" -Method POST -ContentType 'application/x-www-form-urlencoded; charset=utf-8' -Body $bytes -WebSession $sess -Headers $h -UseBasicParsing -TimeoutSec 300
Write-Output ("SAVE " + $save.Content)

$null = Invoke-WebRequest -Uri "$base/zh-CN/Login/LoginOut" -WebSession $sess -UseBasicParsing -TimeoutSec 30
Write-Output 'LOGOUT_OK'
