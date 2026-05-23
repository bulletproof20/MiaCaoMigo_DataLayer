# =========================================================
# QA RUNNER - FULL STRESS VALIDATION SUITE
# FILE: QA/runners/run_stress_all.ps1
# =========================================================
# PURPOSE:
#   Executes the complete 04_Stress validation suite after
#   deterministic QA fixtures (including stress datasets).
#
# PREREQUISITES:
#   init_qa bootstrap, Docker PostgreSQL, lib/Invoke-QaSqlRunner.ps1
#
# NOTE:
#   Use ASCII hyphens only inside double-quoted strings so
#   Windows PowerShell 5.1 parses UTF-8 files without BOM.
# =========================================================

param(
    [string]$Container = "miacaomigo-db",
    [string]$Db = "miacaomigo",
    [string]$User = "postgres"
)

$ErrorActionPreference = "Stop"

. (Join-Path $PSScriptRoot "lib/Invoke-QaSqlRunner.ps1")

$Tests = Split-Path $PSScriptRoot -Parent
$Stress = Join-Path $Tests "04_Stress"

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
Write-Host "FULL SYSTEM STRESS VALIDATION"
Write-Host "Scripts Scheduled: $($scripts.Count)"
Write-Host "Container: $Container"
Write-Host "Database: $Db"
Write-Host "========================================"

Write-Host ""
Write-Host ">>> PRE-FLIGHT - QA FIXTURES + STRESS DATASETS"

& (Join-Path $PSScriptRoot "run_fixtures.ps1") `
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
        Write-Host "ERROR: stress script not found -> $path"
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
        Write-Host "ERROR: stress validation failed -> $rel"
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
