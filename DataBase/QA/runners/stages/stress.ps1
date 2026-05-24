# stages/stress.ps1 — 04_Stress suite (loads fixtures with -IncludeStress first)
# Usage: .\stages\stress.ps1

param(
    [string]$Container = "miacaomigo-db",
    [string]$Db = "miacaomigo",
    [string]$User = "postgres"
)

$ErrorActionPreference = "Stop"

$RunnersRoot = Split-Path $PSScriptRoot -Parent
$TestsRoot = Split-Path $RunnersRoot -Parent

. (Join-Path $RunnersRoot "lib/Invoke-QaSqlRunner.ps1")

$Stress = Join-Path $TestsRoot "04_Stress"

$scripts = @(
    "01_Module1/01_Login_Concurrency.sql"
    "01_Module1/02_Clocking_Concurrency.sql"
    "02_Module2/01_Concurrent_Adoption.sql"
    "03_Module3/01_Concurrent_Sales.sql"
    "03_Module3/02_High_Volume_Invoice_Lines.sql"
    "03_Module3/03_FIFO_Consumption.sql"
    "03_Module3/04_Return_Storm.sql"
    "04_Module4/01_Concurrent_Appointment_Booking.sql"
    "04_Module4/02_Appointment_Lifecycle_Load.sql"
)

Write-Host "========================================"
Write-Host "QA STRESS ($($scripts.Count) scripts)"
Write-Host "========================================"

Write-Host ""
Write-Host ">>> PRE-FLIGHT - fixtures + stress seed"

& (Join-Path $RunnersRoot "stages/fixtures.ps1") `
    -Container $Container `
    -Db $Db `
    -User $User `
    -Module all `
    -IncludeStress

if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
}

$scriptsRun = 0
$scriptsFailed = 0
$totalFail = 0
$totalError = 0
$totalFatal = 0

foreach ($rel in $scripts) {
    Write-Host ""
    Write-Host ">>> $rel"

    $path = Join-Path $Stress $rel

    if (-not (Test-Path -LiteralPath $path)) {
        $scriptsFailed++
        Write-Host "ERROR: not found -> $path"
        continue
    }

    $result = Invoke-QaSqlScript `
        -Container $Container `
        -DatabaseName $Db `
        -User $User `
        -FilePath $path

    $result.Output | Write-Host

    $scriptsRun++
    $totalFail += $result.Metrics.FailCount
    $totalError += $result.Metrics.ErrorCount
    $totalFatal += $result.Metrics.FatalCount

    if (-not $result.Success) {
        $scriptsFailed++
        Write-Host "ERROR: failed -> $rel"
    }
}

$passed = Write-QaRunSummary `
    -SuiteName "STRESS" `
    -ScriptsRun $scriptsRun `
    -ScriptsFailed $scriptsFailed `
    -TotalFailNotices $totalFail `
    -TotalPassNotices -1 `
    -TotalSqlErrors $totalError `
    -TotalFatals $totalFatal

if (-not $passed) {
    exit 1
}
