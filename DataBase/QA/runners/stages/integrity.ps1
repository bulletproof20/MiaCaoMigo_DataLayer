# stages/integrity.ps1 — Run 01_Integrity suite (requires init_qa; fixtures unless -SkipFixtures)
# Usage: .\stages\integrity.ps1 [-SkipFixtures]

param(
    [string]$Container = "miacaomigo-db",
    [string]$Db = "miacaomigo",
    [string]$User = "postgres",
    [switch]$SkipFixtures
)

$ErrorActionPreference = "Stop"

$RunnersRoot = Split-Path $PSScriptRoot -Parent
$TestsRoot = Split-Path $RunnersRoot -Parent

. (Join-Path $RunnersRoot "lib/Invoke-QaSqlRunner.ps1")

$Integrity = Join-Path $TestsRoot "01_Integrity"
$Fixtures = Join-Path $TestsRoot "fixtures"

$scripts = @(
    @{ Path = "01_Module1/01_Email_Nif_Uniqueness.sql" }
    @{ Path = "01_Module1/02_Login_Session_Rules.sql" }
    @{ Path = "01_Module1/03_Clocking_Rules.sql"; Cleanup = "reset/m1_clocking_absence.sql" }
    @{ Path = "01_Module1/04_Absence_Overlap.sql" }
    @{ Path = "01_Module1/05_Role_Disjunction.sql" }
    @{ Path = "01_Module1/06_Schedule_Exclusion.sql" }
    @{ Path = "02_Module2/01_Duplicate_Ownership.sql"; Cleanup = "reset/m2_animal1_ownership.sql" }
    @{ Path = "02_Module2/02_Ownership_Lifecycle.sql" }
    @{ Path = "02_Module2/03_Breed_Species_Consistency.sql" }
    @{ Path = "02_Module2/04_Delivery_Date_Consistency.sql" }
    @{ Path = "02_Module2/05_Concession_And_Inactive.sql" }
    @{ Path = "03_Module3/01_Stock_Before_Sale.sql" }
    @{ Path = "03_Module3/02_Inactive_Product_Sale.sql" }
    @{ Path = "03_Module3/03_Return_Quantity.sql" }
    @{ Path = "03_Module3/04_Invoice_Total_Update.sql" }
    @{ Path = "04_Module4/01_Appointment_Scheduling.sql" }
    @{ Path = "04_Module4/02_Appointment_Overlap.sql" }
    @{ Path = "04_Module4/03_Vet_Absence.sql" }
    @{ Path = "04_Module4/04_Appointment_Lifecycle.sql" }
    @{ Path = "04_Module4/05_Prescription_Timing.sql" }
    @{ Path = "04_Module4/06_Notifications.sql" }
)

Write-Host "========================================"
Write-Host "QA INTEGRITY ($($scripts.Count) scripts)"
Write-Host "========================================"

if (-not $SkipFixtures) {
    Write-Host ""
    Write-Host ">>> PRE-FLIGHT - fixtures"

    & (Join-Path $RunnersRoot "stages/fixtures.ps1") `
        -Container $Container `
        -Db $Db `
        -User $User

    if ($LASTEXITCODE -ne 0) {
        exit $LASTEXITCODE
    }
}

# Idempotent M2 baseline before ownership tests
$m2Reset = Join-Path $Fixtures "reset/m2_animal1_ownership.sql"
if (Test-Path $m2Reset) {
    Write-Host ""
    Write-Host ">>> CLEANUP - reset/m2_animal1_ownership.sql (preflight)"
    $pr = Invoke-QaSqlScript -Container $Container -DatabaseName $Db -User $User -FilePath $m2Reset
    $pr.Output | Write-Host
}

$scriptsRun = 0
$scriptsFailed = 0
$totalFail = 0
$totalPass = 0
$totalError = 0
$totalFatal = 0

foreach ($entry in $scripts) {
    if ($entry.Cleanup) {
        $cleanupPath = Join-Path $Fixtures $entry.Cleanup
        if (Test-Path $cleanupPath) {
            Write-Host ""
            Write-Host ">>> CLEANUP - $($entry.Cleanup)"
            $cr = Invoke-QaSqlScript -Container $Container -DatabaseName $Db -User $User -FilePath $cleanupPath
            $cr.Output | Write-Host
            if (-not $cr.Success) {
                $scriptsFailed++
            }
        }
    }

    $rel = $entry.Path
    Write-Host ""
    Write-Host ">>> $rel"

    $path = Join-Path $Integrity $rel

    $result = Invoke-QaSqlScript `
        -Container $Container `
        -DatabaseName $Db `
        -User $User `
        -FilePath $path `
        -CountPass

    $result.Output | Write-Host

    $scriptsRun++
    $totalFail += $result.Metrics.FailCount
    $totalPass += $result.Metrics.PassCount
    $totalError += $result.Metrics.ErrorCount
    $totalFatal += $result.Metrics.FatalCount

    if (-not $result.Success) {
        $scriptsFailed++
        Write-Host "ERROR: failed -> $rel"
    }
}

$passed = Write-QaRunSummary `
    -SuiteName "INTEGRITY" `
    -ScriptsRun $scriptsRun `
    -ScriptsFailed $scriptsFailed `
    -TotalFailNotices $totalFail `
    -TotalPassNotices $totalPass `
    -TotalSqlErrors $totalError `
    -TotalFatals $totalFatal

if (-not $passed) {
    exit 1
}
