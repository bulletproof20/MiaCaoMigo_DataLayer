# =========================================================
# QA RUNNER — MANUAL / EXPLORATORY SCENARIOS (Module 1)
# FILE: QA/runners/run_manual_module.ps1
# =========================================================
# PURPOSE:
#   Executes 05_Manual reference scripts (non-CI).
#   Does not gate on PASS/FAIL notices — SQL errors fail the run.
#
# PREREQUISITES:
#   init_qa + run_fixtures.ps1
# =========================================================

param(
    [string]$Container = "miacaomigo-db",
    [string]$Db = "miacaomigo",
    [string]$User = "postgres",

    [ValidateSet("all", "1")]
    [string]$Module = "all",

    [switch]$SkipFixtures
)

$ErrorActionPreference = "Stop"

. (Join-Path $PSScriptRoot "lib/Invoke-QaSqlRunner.ps1")

$Tests = Split-Path $PSScriptRoot -Parent
$Manual = Join-Path $Tests "05_Manual"

$scriptsByModule = @{
    "1" = @(
        "01_Module1/Authentication/01_Login_Reference.sql"
        "01_Module1/User_Creation/01_Client_Reference.sql"
        "01_Module1/User_Creation/02_Employee_Reference.sql"
        "01_Module1/User_Creation/03_Assistant_Reference.sql"
        "01_Module1/User_Creation/04_Veterinarian_Reference.sql"
    )
}

$scripts = if ($Module -eq "all") {
    $scriptsByModule["1"]
} else {
    $scriptsByModule[$Module]
}

Write-Host "========================================"
Write-Host "QA MANUAL (exploratory)"
Write-Host "Module: $Module"
Write-Host "Scripts: $($scripts.Count)"
Write-Host "========================================"

if (-not $SkipFixtures) {
    Write-Host ""
    Write-Host ">>> PRE-FLIGHT — QA CONTRACTS + FIXTURES"

    & (Join-Path $PSScriptRoot "run_fixtures.ps1") `
        -Container $Container `
        -Db $Db `
        -User $User

    if ($LASTEXITCODE -ne 0) {
        exit $LASTEXITCODE
    }
}

$fail = 0

foreach ($rel in $scripts) {
    $path = Join-Path $Manual $rel

    if (-not (Test-Path $path)) {
        Write-Host "ERROR: missing manual script -> $rel"
        $fail++
        continue
    }

    Write-Host ""
    Write-Host ">>> $rel"

    $result = Invoke-QaSqlScript `
        -Container $Container `
        -DatabaseName $Db `
        -User $User `
        -FilePath $path

    $result.Output | Write-Host

    if (-not $result.Success) {
        $fail++
        Write-Host "ERROR: manual script failed -> $rel"
    }
}

if ($fail -gt 0) {
    exit 1
}

Write-Host ""
Write-Host "QA manual scripts finished (review output; expected errors may occur)."

exit 0
