param(
    [Parameter(Mandatory = $true)]
    [string]$GodotBin,
    [Parameter(Mandatory = $true)]
    [string]$AndroidSdk,
    [Parameter(Mandatory = $true)]
    [string]$SigningEnv,
    [string]$JavaHome = $env:JAVA_HOME
)

$ErrorActionPreference = 'Stop'

$projectRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..')).Path
$outputDir = Join-Path $projectRoot 'releases'
$outputPath = Join-Path $outputDir 'ECOS-0.6.0-android.apk'
$apksigner = Join-Path $AndroidSdk 'build-tools\36.0.0\apksigner.bat'

foreach ($requiredPath in @($GodotBin, $SigningEnv, $apksigner)) {
    if (-not (Test-Path -LiteralPath $requiredPath)) {
        throw "No existe el requisito local: $requiredPath"
    }
}

New-Item -ItemType Directory -Force -Path $outputDir | Out-Null
$resolvedOutputDir = (Resolve-Path -LiteralPath $outputDir).Path
$expectedOutputDir = Join-Path $projectRoot 'releases'
if ($resolvedOutputDir -ne $expectedOutputDir) {
    throw "Directorio de salida inesperado: $resolvedOutputDir"
}

foreach ($line in Get-Content -LiteralPath $SigningEnv) {
    if ($line -match '^\s*([A-Z0-9_]+)=(.*)$') {
        $key = $matches[1]
        $value = $matches[2].Trim().Trim('"').Trim("'")
        Set-Item -Path "Env:$key" -Value $value
    }
}

foreach ($requiredVariable in @(
    'GODOT_ANDROID_KEYSTORE_RELEASE_PATH',
    'GODOT_ANDROID_KEYSTORE_RELEASE_USER',
    'GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD'
)) {
    if ([string]::IsNullOrWhiteSpace((Get-Item -Path "Env:$requiredVariable").Value)) {
        throw "Falta $requiredVariable en la configuracion de firma."
    }
}

$env:ANDROID_HOME = $AndroidSdk
$env:ANDROID_SDK_ROOT = $AndroidSdk
if (-not [string]::IsNullOrWhiteSpace($JavaHome)) {
    $env:JAVA_HOME = $JavaHome
}

Get-ChildItem -LiteralPath $outputDir -File -Filter '*.apk' |
    ForEach-Object { Remove-Item -LiteralPath $_.FullName -Force }

& $GodotBin --headless --path $projectRoot --export-release Android $outputPath
if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
}
if (-not (Test-Path -LiteralPath $outputPath) -or (Get-Item -LiteralPath $outputPath).Length -eq 0) {
    throw "La exportacion no genero $outputPath"
}

& $apksigner verify --verbose $outputPath
if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
}
$idsigPath = "$outputPath.idsig"
if (Test-Path -LiteralPath $idsigPath) {
    Remove-Item -LiteralPath $idsigPath -Force
}

$apk = Get-Item -LiteralPath $outputPath
$hash = Get-FileHash -Algorithm SHA256 -LiteralPath $outputPath
Write-Output "APK release local: $($apk.FullName)"
Write-Output "Tamano: $($apk.Length) bytes"
Write-Output "SHA-256: $($hash.Hash)"
