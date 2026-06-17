param(
  [string]$Version = "1.2.58",
  [string]$Arch = "x64",
  [string]$ReleaseBaseUrl = "https://github.com/rcodexlab/rcodex-releases/releases/download",
  [string]$InstallDir = "$env:ProgramFiles\rCodex\Gateway",
  [string]$DataDir = "$env:ProgramData\rCodex\Gateway",
  [switch]$SkipService
)

$ErrorActionPreference = "Stop"

function Require-Admin {
  $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
  $principal = New-Object Security.Principal.WindowsPrincipal($identity)
  if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    throw "请以管理员身份运行 PowerShell。"
  }
}

function Require-Command($Name) {
  if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
    throw "未找到命令：$Name"
  }
}

Require-Admin
Require-Command "node"

$packageName = "rcodex-gateway-$Version-windows-$Arch.zip"
$packageUrl = "$ReleaseBaseUrl/v$Version/$packageName"
$tempZip = Join-Path $env:TEMP $packageName
$tempDir = Join-Path $env:TEMP "rcodex-gateway-$Version"

New-Item -ItemType Directory -Force -Path $InstallDir, $DataDir, (Join-Path $DataDir "logs"), (Join-Path $DataDir "data") | Out-Null

Write-Host "下载 $packageUrl"
Invoke-WebRequest -Uri $packageUrl -OutFile $tempZip

if (Test-Path $tempDir) {
  Remove-Item -LiteralPath $tempDir -Recurse -Force
}
Expand-Archive -LiteralPath $tempZip -DestinationPath $tempDir

Copy-Item -Path (Join-Path $tempDir "*") -Destination $InstallDir -Recurse -Force

$envFile = Join-Path $DataDir "gateway.env"
if (-not (Test-Path $envFile)) {
  Copy-Item -LiteralPath (Join-Path $InstallDir "etc\rcodex-gateway.env.example") -Destination $envFile
}

Write-Host "已安装到 $InstallDir"
Write-Host "配置文件：$envFile"

if (-not $SkipService) {
  Write-Host "服务注册逻辑将在后续接入 WinSW 后启用。当前可先用 bin\rcodex-gateway.ps1 start 前台验证。"
}

