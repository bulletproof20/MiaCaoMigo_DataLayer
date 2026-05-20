# Run full integrity suite (Module1 -> Module4)
# Prerequisites:
#   - Bootstrap pipeline applied (init_demo recommended for Mod3 DemoData)
#   - 04_Loaders/03_TestData.sql loaded (run_test_data.ps1 or init_test)
param(
    [string]$Container = "miacaomigo-db",
    [string]$Db = "miacaomigo",
    [string]$User = "postgres"
)

$ErrorActionPreference = "Continue"
$Tests = Split-Path $PSScriptRoot -Parent
$Integrity = Join-Path $Tests "01_Integrity"

$scripts = @(
    "01_Module1/01_Email_Nif_Uniqueness.sql",
    "01_Module1/02_Login_Session_Rules.sql",
    "01_Module1/03_Clocking_Rules.sql",
    "01_Module1/04_Absence_Overlap.sql",
    "01_Module1/05_Role_Disjunction.sql",
    "01_Module1/06_Schedule_Exclusion.sql",
    "02_Module2/01_Duplicate_Ownership.sql",
    "02_Module2/02_Ownership_Lifecycle.sql",
    "02_Module2/03_Breed_Species_Consistency.sql",
    "02_Module2/04_Delivery_Date_Consistency.sql",
    "02_Module2/05_Concession_And_Inactive.sql",
    "03_Module3/00_Commercial_Fixture.sql",
    "03_Module3/01_Stock_Before_Sale.sql",
    "03_Module3/02_Inactive_Product_Sale.sql",
    "03_Module3/03_Return_Quantity.sql",
    "03_Module3/04_Invoice_Total_Update.sql",
    "04_Module4/01_Appointment_Scheduling.sql",
    "04_Module4/02_Appointment_Overlap.sql",
    "04_Module4/03_Vet_Absence.sql",
    "04_Module4/04_Appointment_Lifecycle.sql",
    "04_Module4/05_Prescription_Timing.sql",
    "04_Module4/06_Notifications.sql"
)

Write-Host "========================================"
Write-Host "INTEGRITY SUITE - $($scripts.Count) scripts"
Write-Host "Container: $Container  Database: $Db"
Write-Host "========================================"

$fail = 0
foreach ($rel in $scripts) {
    $path = Join-Path $Integrity $rel
    Write-Host ""
    Write-Host ">>> $rel"
    Get-Content -Path $path -Raw -Encoding UTF8 | docker exec -i $Container psql -U $User -d $Db -v ON_ERROR_STOP=1 2>&1 | Out-Host
    if ($LASTEXITCODE -ne 0) {
        $fail++
        Write-Host "ERROR: script failed - $rel (exit $LASTEXITCODE)"
    }
}

Write-Host ""
Write-Host "========================================"
if ($fail -eq 0) {
    Write-Host "Integrity runners finished. Review NOTICE lines for PASS/FAIL."
} else {
    Write-Host "Integrity suite completed with $fail script error(s)."
}
Write-Host "========================================"

if ($fail -gt 0) { exit 1 }
