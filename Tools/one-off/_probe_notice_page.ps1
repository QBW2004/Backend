param(
    [string]$BaseUrl = 'http://localhost:8080',
    [string]$User = 'atmadmin',
    [string]$Pwd = '123456',
    [string]$HtmlOut = 'C:\Users\Administrator\notice_page_check.html'
)
# Read-only check for the rewritten Notice admin page (2026-09-23):
# logs in, opens /Game/Notice and calls GetNotice once. It never saves anything.
# ASCII only on purpose: remote PowerShell reads non-BOM UTF-8 as GBK.
$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$loginPage = Invoke-WebRequest -Uri "$BaseUrl/zh-CN/Login/Index" -WebSession $session -UseBasicParsing
$m = [regex]::Match($loginPage.Content, 'name="__RequestVerificationToken"[^>]*value="([^"]+)"')
if (-not $m.Success) { throw 'anti-forgery token not found on login page' }
Write-Output ("login page HTTP=" + $loginPage.StatusCode + " token_len=" + $m.Groups[1].Value.Length)

$null = Invoke-WebRequest -Uri "$BaseUrl/zh-CN/Login/Index" -Method POST -WebSession $session -UseBasicParsing `
    -Body @{ uname = $User; upwd = $Pwd; __RequestVerificationToken = $m.Groups[1].Value }
Write-Output "login post done"

$page = Invoke-WebRequest -Uri "$BaseUrl/Game/Notice" -WebSession $session -UseBasicParsing
Write-Output ("notice page HTTP=" + $page.StatusCode + " bytes=" + $page.Content.Length)
$page.Content | Out-File -Encoding UTF8 -FilePath $HtmlOut

Write-Output ("CHECK has_SaveNotice_url=" + $page.Content.Contains('/Game/Notice/SaveNotice'))
Write-Output ("CHECK has_GetNotice_url=" + $page.Content.Contains('/Game/Notice/GetNotice'))
Write-Output ("CHECK has_fontsize_field=" + $page.Content.Contains('txtFontSize'))
Write-Output ("CHECK has_preview_node=" + $page.Content.Contains('ncPreview'))
Write-Output ("CHECK has_client_font_url=" + $page.Content.Contains('NowarSans-CN-Bold.otf'))
Write-Output ("CHECK has_viewport_648=" + $page.Content.Contains('NC_VIEW_W = 648'))
Write-Output ("CHECK legacy_add_button=" + $page.Content.Contains('showAddNotice'))
Write-Output ("CHECK legacy_datagrid=" + $page.Content.Contains('datagrid'))
Write-Output ("CHECK legacy_del_url=" + $page.Content.Contains('/Game/Notice/delNotice'))

$json = Invoke-WebRequest -Uri "$BaseUrl/Game/Notice/GetNotice" -Method POST -WebSession $session -UseBasicParsing `
    -Headers @{ 'X-Requested-With' = 'XMLHttpRequest' } -ContentType 'application/x-www-form-urlencoded' -Body @{}
Write-Output ("GetNotice HTTP=" + $json.StatusCode)
Write-Output ("GetNotice BODY=" + $json.Content)
