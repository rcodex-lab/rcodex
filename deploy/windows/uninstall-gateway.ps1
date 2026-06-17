param(
  [string]$InstallDir = "$env:ProgramFiles\rCodex\Gateway",
  [string]$DataDir = "$env:ProgramData\rCodex\Gateway",
  [switch]$RemoveData
)

$ErrorActionPreference = "Stop"

if (Test-Path $InstallDir) {
  Remove-Item -LiteralPath $InstallDir -Recurse -Force
  Write-Host "已移除安装目录：$InstallDir"
}

if ($RemoveData -and (Test-Path $DataDir)) {
  Remove-Item -LiteralPath $DataDir -Recurse -Force
  Write-Host "已移除数据目录：$DataDir"
} elseif (Test-Path $DataDir) {
  Write-Host "已保留数据目录：$DataDir"
}

