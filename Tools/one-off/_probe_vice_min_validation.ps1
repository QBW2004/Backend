# 验证 1.0.51 的"庄闲/和最高押分不能小于最低压分"校验已上线：
# 提交一个非法组合(BET_MAX_VICE=0)，预期被校验拦下并在写库之前返回错误 → 库内零改动。
param(
    [int]$GameId = 10,
    [int]$TableIndex = 0
)

$ErrorActionPreference = 'Stop'
$base = 'http://127.0.0.1'
$h = @{ 'X-Requested-With' = 'XMLHttpRequest' }
$tableId = $GameId * 1000 + $TableIndex

$loginPage = Invoke-WebRequest -Uri "$base/zh-CN/Login/Index" -SessionVariable sess -UseBasicParsing -TimeoutSec 60
$lm = [regex]::Match($loginPage.Content, 'name="__RequestVerificationToken"[^>]*value="([^"]*)"')
$login = Invoke-WebRequest -Uri "$base/zh-CN/Login/Index" -Method POST -Body @{ uname = 'atmadmin'; upwd = '123456'; __RequestVerificationToken = $lm.Groups[1].Value } -WebSession $sess -UseBasicParsing -TimeoutSec 60
Write-Output ("LOGIN status=" + $login.StatusCode)

$page = Invoke-WebRequest -Uri "$base/Game/GameConfig/Index" -WebSession $sess -UseBasicParsing -TimeoutSec 120
$m = [regex]::Match($page.Content, 'name="__RequestVerificationToken"[^>]*value="([^"]*)"')
if (-not $m.Success) { $m = [regex]::Match($page.Content, 'value="([^"]*)"[^>]*name="__RequestVerificationToken"') }
$tok = $m.Groups[1].Value

$cfgRes = Invoke-WebRequest -Uri "$base/Game/GameConfig/GetTableConfig" -Method POST -Body @{ GAME_TYPE = '0'; GAME_ID = [string]$GameId } -WebSession $sess -Headers $h -UseBasicParsing -TimeoutSec 180
$cfg = $cfgRes.Content | ConvertFrom-Json
$t = @($cfg.datas) | Where-Object { $_.id -eq $tableId }
if ($null -eq $t) { throw ("table " + $tableId + " not found") }

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
    BET_MAX_VICE        = '0'          # 非法：低于最低压分，应被 1.0.51 校验拦住
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

Add-Type -AssemblyName System.Web
$pairs = @()
foreach ($k in $body.Keys) {
    $pairs += ([System.Web.HttpUtility]::UrlEncode($k) + '=' + [System.Web.HttpUtility]::UrlEncode([string]$body[$k]))
}
$bytes = [System.Text.Encoding]::UTF8.GetBytes(($pairs -join '&'))

$save = Invoke-WebRequest -Uri "$base/Game/GameConfig/SaveTableConfig" -Method POST -ContentType 'application/x-www-form-urlencoded; charset=utf-8' -Body $bytes -WebSession $sess -Headers $h -UseBasicParsing -TimeoutSec 300
Write-Output ("SAVE(expect rejected) " + $save.Content)

$null = Invoke-WebRequest -Uri "$base/zh-CN/Login/LoginOut" -WebSession $sess -UseBasicParsing -TimeoutSec 30
Write-Output 'LOGOUT_OK'
