
# Hisaab by Zynapse - Release APK verification
# Run from the project root:
# powershell -ExecutionPolicy Bypass -File .\tools\verify_release.ps1

param(
    [string]$ApkUrl = "https://hisaab.zynapse.in/hisaab-release.apk"
)

$ErrorActionPreference = "Stop"

$projectRoot = Split-Path -Parent $PSScriptRoot
$localApk = Join-Path $projectRoot "build\app\outputs\flutter-apk\app-release.apk"
$downloadedApk = Join-Path $env:TEMP "hisaab-website-verification.apk"

$expectedCertificate = "15d0fc5f173f429eaa0827abf3c9db6bdfd3b6d8b37f96111cf34a6e92cea5da"

function Fail([string]$message) {
    Write-Host "`nFAILED: $message" -ForegroundColor Red
    exit 1
}

function Get-SignerDigest([string]$apk, [string]$apksigner) {
    $output = & $apksigner verify --verbose --print-certs $apk 2>&1

    if ($LASTEXITCODE -ne 0) {
        Fail "APK signature verification failed: $apk"
    }

    $match = $output | Select-String "Signer #1 certificate SHA-256 digest:\s*([0-9a-fA-F]+)"

    if (-not $match) {
        Fail "Could not read signing certificate: $apk"
    }

    return $match.Matches[0].Groups[1].Value.ToLowerInvariant()
}

Write-Host "`nHISAAB RELEASE VERIFICATION" -ForegroundColor Cyan
Write-Host "==========================="

if (-not (Test-Path $localApk)) {
    Fail "Local release APK not found. Run flutter build apk --release."
}

if (-not $env:ANDROID_HOME) {
    Fail "ANDROID_HOME is not configured."
}

$apksigner = Get-ChildItem (Join-Path $env:ANDROID_HOME "build-tools") `
    -Recurse -Filter "apksigner.bat" |
    Sort-Object {
        try {
            [version]$_.Directory.Name.Split("-")[0]
        } catch {
            [version]"0.0"
        }
    } -Descending |
    Select-Object -First 1 -ExpandProperty FullName

if (-not $apksigner) {
    Fail "apksigner.bat was not found in Android SDK build-tools."
}

Write-Host "`nDownloading APK from website..."

try {
    & curl.exe --fail --location --show-error --silent `
        --output $downloadedApk $ApkUrl

    if ($LASTEXITCODE -ne 0) {
        Fail "Website APK download failed."
    }
} catch {
    Fail "Could not download website APK: $_"
}

$localHash = (Get-FileHash $localApk -Algorithm SHA256).Hash
$websiteHash = (Get-FileHash $downloadedApk -Algorithm SHA256).Hash

Write-Host "`nLOCAL APK"
Write-Host "Path: $localApk"
Write-Host "SHA256: $localHash"

Write-Host "`nWEBSITE APK"
Write-Host "URL: $ApkUrl"
Write-Host "SHA256: $websiteHash"

$localCertificate = Get-SignerDigest $localApk $apksigner
$websiteCertificate = Get-SignerDigest $downloadedApk $apksigner

Write-Host "`nSIGNING CERTIFICATES"
Write-Host "Local:   $localCertificate"
Write-Host "Website: $websiteCertificate"

if ($localCertificate -ne $expectedCertificate) {
    Fail "Local APK is not signed with the expected Zynapse release certificate."
}

if ($websiteCertificate -ne $expectedCertificate) {
    Fail "Website APK is not signed with the expected Zynapse release certificate."
}

if ($localHash -ne $websiteHash) {
    Write-Host "`nRESULT: APK FILES DIFFER" -ForegroundColor Yellow
    Write-Host "Both APKs have the expected signing certificate, but their contents differ."
    Write-Host "Check whether Cloudflare R2 contains an older release."
    exit 2
}

Write-Host "`nRESULT: VERIFIED" -ForegroundColor Green
Write-Host "The website serves exactly the same APK as the local release build."
Write-Host "Both APK signatures are valid."
Write-Host "Both APKs use the expected Zynapse release certificate."
