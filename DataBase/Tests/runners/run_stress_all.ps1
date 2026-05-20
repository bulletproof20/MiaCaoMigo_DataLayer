# Run stress suite (metrics via NOTICE — not integrity PASS/FAIL)
# Prerequisites: Bootstrap + recommended run_test_data.ps1
param(
    [string]$Container = "miacaomigo-db",
    [string]$Db = "miacaomigo",
    [string]$User = "postgres",
    [ValidateSet("0", "1", "2", "3", "4", "all")]
    [string]$Module = "all"
)

$ErrorActionPreference = "Continue"
$Tests = Split-Path $PSScriptRoot -Parent
$Stress = Join-Path $Tests "02_Stress"
$SetupCommercial = "00_Setup/01_Commercial_Stress_Fixture.sql"

$allScripts = [ordered]@{
    "1" = @(
        "01_Module1/01_Login_Concurrency.sql",
        "01_Module1/02_Clocking_Concurrency.sql"
    )
    "2" = @("02_Module2/01_Concurrent_Adoption.sql")
    "3" = @(
        "03_Module3/01_Concurrent_Sales.sql",
        "03_Module3/02_High_Volume_Invoice_Lines.sql",
        "03_Module3/03_FIFO_Consumption.sql",
        "03_Module3/04_Return_Storm.sql"
    )
    "4" = @(
        "04_Module4/01_Concurrent_Appointment_Booking.sql",
        "04_Module4/02_Appointment_Lifecycle_Load.sql"
    )
}

if ($Module -eq "all") {
    $scripts = @()
    foreach ($k in $allScripts.Keys) {
        $scripts += $allScripts[$k]
    }
} else {
    $scripts = $allScripts[$Module]
}

function Invoke-StressSql {
    param([string]$RelativePath)
    $path = Join-Path $Stress $RelativePath
    Get-Content -Path $path -Raw -Encoding UTF8 | docker exec -i $Container psql -U $User -d $Db -v ON_ERROR_STOP=1 2>&1 | Out-Host
    return $LASTEXITCODE
}

Write-Host "========================================"
Write-Host "STRESS SUITE - $($scripts.Count) script(s)  Module: $Module"
Write-Host "Container: $Container  Database: $Db"
Write-Host "========================================"

$fail = 0
foreach ($rel in $scripts) {
    if ($rel -like "03_Module3/*") {
        Write-Host ""
        Write-Host ">>> (setup) $SetupCommercial"
        if ((Invoke-StressSql -RelativePath $SetupCommercial) -ne 0) { $fail++ }
    }

    Write-Host ""
    Write-Host ">>> $rel"
    if ((Invoke-StressSql -RelativePath $rel) -ne 0) {
        $fail++
        Write-Host "ERROR: stress script failed - $rel"
    }
}

Write-Host ""
Write-Host "========================================"
if ($fail -eq 0) {
    Write-Host "Stress runners finished. Review STRESS M*-* NOTICE metrics."
} else {
    Write-Host "Stress suite completed with $fail script error(s)."
}
Write-Host "========================================"

if ($fail -gt 0) { exit 1 }
