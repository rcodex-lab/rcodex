param(
  [Parameter(Mandatory = $true)]
  [string]$Version,
  [string]$Arch = "x64"
)

$ErrorActionPreference = "Stop"

$RootDir = Split-Path -Parent $PSScriptRoot
$GatewayDir = Join-Path $RootDir "services\gateway"
$DistDir = Join-Path $RootDir "dist\native\gateway-$Version-windows-$Arch"
$PackagePath = Join-Path $RootDir "dist\native\rcodex-gateway-$Version-windows-$Arch.zip"

function Test-NativePackageDirectory {
  param([Parameter(Mandatory = $true)][string]$Path)

  $relativeEntries = Get-ChildItem -LiteralPath $Path -Recurse -Force | ForEach-Object {
    $_.FullName.Substring($Path.Length).TrimStart('\', '/') -replace '\\', '/'
  }

  $blocked = $relativeEntries | Where-Object {
    $_ -match '(^|/)src/' -or
    $_ -match '\.ts$' -or
    $_ -match '\.test\.' -or
    $_ -match '(^|/)\.env$' -or
    $_ -match '(^|/)\.git(/|$)' -or
    $_ -match '(^|/)docs/plans/' -or
    $_ -match '(^|/)tmp(/|$)'
  }

  if ($blocked) {
    throw "原生发布包包含禁止分发内容：$($blocked -join ', ')"
  }

  $required = @(
    'dist/',
    'package.json',
    'package-lock.json',
    'deploy/version/',
    'etc/rcodex-gateway.env.example'
  )

  foreach ($item in $required) {
    $matched = $relativeEntries | Where-Object { $_ -eq $item.TrimEnd('/') -or $_.StartsWith($item) }
    if (-not $matched) {
      throw "原生发布包缺少必要内容：$item"
    }
  }
}

if (Test-Path $DistDir) {
  Remove-Item -LiteralPath $DistDir -Recurse -Force
}
New-Item -ItemType Directory -Force -Path $DistDir, (Join-Path $DistDir "bin"), (Join-Path $DistDir "etc"), (Join-Path $DistDir "deploy") | Out-Null

Push-Location $GatewayDir
try {
  npm ci
  npm run build
  npm prune --omit=dev
} finally {
  Pop-Location
}

Copy-Item -LiteralPath (Join-Path $GatewayDir "dist") -Destination (Join-Path $DistDir "dist") -Recurse
Copy-Item -LiteralPath (Join-Path $GatewayDir "package.json") -Destination $DistDir
Copy-Item -LiteralPath (Join-Path $GatewayDir "package-lock.json") -Destination $DistDir
Copy-Item -LiteralPath (Join-Path $GatewayDir "node_modules") -Destination (Join-Path $DistDir "node_modules") -Recurse
Copy-Item -LiteralPath (Join-Path $RootDir "deploy\version") -Destination (Join-Path $DistDir "deploy\version") -Recurse
Copy-Item -LiteralPath (Join-Path $RootDir "deploy\windows\rcodex-gateway.env.example") -Destination (Join-Path $DistDir "etc\rcodex-gateway.env.example")

@"
param([string]`$Action = "start")

`$ErrorActionPreference = "Stop"
`$RootDir = Split-Path -Parent `$PSScriptRoot
`$EnvFile = if (`$env:RCODEX_GATEWAY_ENV) { `$env:RCODEX_GATEWAY_ENV } else { "`$env:ProgramData\rCodex\Gateway\gateway.env" }

if (`$Action -eq "--version") {
  `$pkg = Get-Content -LiteralPath (Join-Path `$RootDir "package.json") | ConvertFrom-Json
  Write-Host "rCodex Gateway `$(`$pkg.version)"
  exit 0
}

if (Test-Path `$EnvFile) {
  Get-Content `$EnvFile | Where-Object { `$_ -and -not `$_.StartsWith("#") } | ForEach-Object {
    `$parts = `$_.Split("=", 2)
    if (`$parts.Length -eq 2) {
      [Environment]::SetEnvironmentVariable(`$parts[0], `$parts[1], "Process")
    }
  }
}

Set-Location `$RootDir
node dist/index.js
"@ | Set-Content -LiteralPath (Join-Path $DistDir "bin\rcodex-gateway.ps1") -Encoding UTF8

Test-NativePackageDirectory -Path $DistDir

if (Test-Path $PackagePath) {
  Remove-Item -LiteralPath $PackagePath -Force
}
Compress-Archive -Path (Join-Path $DistDir "*") -DestinationPath $PackagePath

Get-FileHash -Algorithm SHA256 -LiteralPath $PackagePath
