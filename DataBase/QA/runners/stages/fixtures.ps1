# stages/fixtures.ps1 — Load contracts + fixtures/reset + fixtures/seed (requires init_qa)
# Usage: .\stages\fixtures.ps1 [-Module all|1|2|3|4] [-IncludeStress] [-SkipReset]

param(
    [string]$Container = "miacaomigo-db",
    [string]$Db = "miacaomigo",
    [string]$User = "postgres",
    [ValidateSet("all", "1", "2", "3", "4")]
    [string]$Module = "all",
    [switch]$IncludeStress,
    [switch]$SkipReset
)

$ErrorActionPreference = "Stop"

$RunnersRoot = Split-Path $PSScriptRoot -Parent
$TestsRoot = Split-Path $RunnersRoot -Parent

. (Join-Path $RunnersRoot "lib/Invoke-QaSqlRunner.ps1")

$coreFiles = @("contracts/01_QA_Functions.sql")

if (-not $SkipReset) {
    $coreFiles += "fixtures/reset/global_qa_state.sql"
}

$moduleFiles = @{
    "1" = @("fixtures/seed/m1_core_context.sql")
    "2" = @("fixtures/seed/m2_animals_ownership.sql")
    "3" = @("fixtures/seed/m3_commercial_product.sql")
    "4" = @("fixtures/seed/m4_appointment_slots.sql")
}

$files = [System.Collections.Generic.List[string]]::new()

foreach ($f in $coreFiles) {
    $files.Add($f)
}

if ($Module -eq "all") {
    foreach ($k in @("1", "2", "3", "4")) {
        foreach ($f in $moduleFiles[$k]) {
            $files.Add($f)
        }
    }
}
else {
    foreach ($f in $moduleFiles[$Module]) {
        $files.Add($f)
    }
}

if ($IncludeStress) {
    $files.Add("fixtures/seed/m3_stress_commercial.sql")
}

Write-Host "========================================"
Write-Host "QA FIXTURES"
Write-Host "Module: $Module | Files: $($files.Count)"
Write-Host "========================================"

$fail = 0

foreach ($rel in $files) {
    $path = Join-Path $TestsRoot $rel

    if (-not (Test-Path $path)) {
        Write-Host "ERROR: missing -> $rel"
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
        Write-Host "ERROR: failed -> $rel"
    }
}

if ($fail -gt 0) {
    exit 1
}

Write-Host ""
Write-Host "QA fixtures loaded successfully."
