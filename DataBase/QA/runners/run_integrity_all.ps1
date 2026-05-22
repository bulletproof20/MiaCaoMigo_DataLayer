# =========================================================
# QA RUNNER — FULL INTEGRITY VALIDATION SUITE
# FILE: QA/runners/run_integrity_all.ps1
# =========================================================
# PURPOSE:
#   Executes the complete database integrity validation suite
#   across all QA modules using deterministic fixtures and
#   structured FAIL/PASS notice parsing.
#
# RESPONSIBILITIES:
#   • Execute all integrity validation scripts
#   • Optionally initialize QA fixtures
#   • Execute cleanup/reset scripts when required
#   • Aggregate PASS / FAIL / ERROR metrics
#   • Detect SQL execution failures
#   • Generate CI-compatible execution summaries
#   • Propagate validation failure exit codes
#
# EXECUTION FLOW:
#   1. Optional fixture initialization
#   2. Optional cleanup/reset execution
#   3. Sequential integrity validation
#   4. Metrics aggregation
#   5. Summary generation
#
# VALIDATION SCOPE:
#   • Email and NIF uniqueness
#   • Login session constraints
#   • Clocking rules
#   • Employee absence overlaps
#   • Role disjunction integrity
#   • Schedule exclusion rules
#   • Animal ownership integrity
#   • Breed/species consistency
#   • Commercial transaction validation
#   • Appointment scheduling integrity
#   • Prescription timing rules
#   • Notification validation
#
# PREREQUISITES:
#   • init_qa bootstrap initialized
#   • PostgreSQL container available
#   • QA fixtures available
#   • QA helper library available
#
# DEPENDENCIES:
#   • lib/Invoke-QaSqlRunner.ps1
#   • run_fixtures.ps1
#   • 01_Integrity/*
#   • fixtures/cleanup/*
#
# EXPECTED RESULT:
#   Validation succeeds only if all integrity scripts
#   complete successfully without FAIL notices, SQL errors
#   or fatal runtime conditions.
# =========================================================

# =========================================================
# RUNTIME PARAMETERS
# =========================================================
# Container:
#   Target PostgreSQL Docker container.
#
# Db:
#   Target database name.
#
# User:
#   PostgreSQL execution user.
#
# SkipFixtures:
#   Prevents automatic fixture initialization before
#   integrity validation execution.
# =========================================================
param(
    [string]$Container = "miacaomigo-db",

    [string]$Db = "miacaomigo",

    [string]$User = "postgres",

    [switch]$SkipFixtures
)

# Stop execution immediately on runtime failures
$ErrorActionPreference = "Stop"

# =========================================================
# LOAD QA EXECUTION LIBRARY
# =========================================================
# Imports:
#   • Invoke-QaSqlScript
#   • Write-QaRunSummary
#   • Shared QA execution helpers
# =========================================================
. (Join-Path $PSScriptRoot "lib/Invoke-QaSqlRunner.ps1")

# =========================================================
# RESOLVE TEST DIRECTORY STRUCTURE
# =========================================================
# Root directories used during integrity validation.
# =========================================================
$Tests = Split-Path $PSScriptRoot -Parent

$Integrity = Join-Path $Tests "01_Integrity"

$Fixtures = Join-Path $Tests "fixtures"

# =========================================================
# INTEGRITY VALIDATION REGISTRY
# =========================================================
# Ordered integrity validation execution pipeline.
#
# Optional Cleanup:
#   Some integrity scenarios require deterministic cleanup
#   before execution to avoid state contamination between
#   repeated validation runs.
# =========================================================
$scripts = @(

    # =====================================================
    # MODULE 1 — AUTHENTICATION / EMPLOYEE INTEGRITY
    # =====================================================

    @{ Path = "01_Module1/01_Email_Nif_Uniqueness.sql" }

    @{ Path = "01_Module1/02_Login_Session_Rules.sql" }

    @{ Path = "01_Module1/03_Clocking_Rules.sql" }

    @{ Path = "01_Module1/04_Absence_Overlap.sql" }

    @{ Path = "01_Module1/05_Role_Disjunction.sql" }

    @{ Path = "01_Module1/06_Schedule_Exclusion.sql" }


    # =====================================================
    # MODULE 2 — ANIMAL / OWNERSHIP INTEGRITY
    # =====================================================

    @{
        Path = "02_Module2/01_Duplicate_Ownership.sql"
        Cleanup = "cleanup/02_Reset_Module2_Animal1.sql"
    }

    @{ Path = "02_Module2/02_Ownership_Lifecycle.sql" }

    @{ Path = "02_Module2/03_Breed_Species_Consistency.sql" }

    @{ Path = "02_Module2/04_Delivery_Date_Consistency.sql" }

    @{ Path = "02_Module2/05_Concession_And_Inactive.sql" }


    # =====================================================
    # MODULE 3 — COMMERCIAL / PRODUCT INTEGRITY
    # =====================================================

    @{ Path = "03_Module3/01_Stock_Before_Sale.sql" }

    @{ Path = "03_Module3/02_Inactive_Product_Sale.sql" }

    @{ Path = "03_Module3/03_Return_Quantity.sql" }

    @{ Path = "03_Module3/04_Invoice_Total_Update.sql" }


    # =====================================================
    # MODULE 4 — APPOINTMENT / CLINICAL INTEGRITY
    # =====================================================

    @{ Path = "04_Module4/01_Appointment_Scheduling.sql" }

    @{ Path = "04_Module4/02_Appointment_Overlap.sql" }

    @{ Path = "04_Module4/03_Vet_Absence.sql" }

    @{ Path = "04_Module4/04_Appointment_Lifecycle.sql" }

    @{ Path = "04_Module4/05_Prescription_Timing.sql" }

    @{ Path = "04_Module4/06_Notifications.sql" }
)

# =========================================================
# EXECUTION HEADER
# =========================================================
# Displays integrity execution context and runtime profile.
# =========================================================
Write-Host "========================================"
Write-Host "FULL INTEGRITY VALIDATION SUITE"
Write-Host "Scripts Scheduled: $($scripts.Count)"
Write-Host "Profile: init_qa"
Write-Host "Container: $Container"
Write-Host "Database: $Db"
Write-Host "========================================"

# =========================================================
# OPTIONAL FIXTURE INITIALIZATION
# =========================================================
# Loads QA contracts and deterministic fixtures before
# integrity validation execution.
#
# Intended for:
#   • Standalone execution
#   • Local validation environments
#   • Fresh QA runtime contexts
# =========================================================
if (-not $SkipFixtures) {

    Write-Host ""
    Write-Host ">>> PRE-FLIGHT — QA CONTRACTS + FIXTURES"

    & (Join-Path $PSScriptRoot "run_fixtures.ps1") `
        -Container $Container `
        -Db $Db `
        -User $User

    # Abort validation pipeline on fixture failure
    if ($LASTEXITCODE -ne 0) {

        exit $LASTEXITCODE
    }
}

# =========================================================
# EXECUTION METRICS
# =========================================================
# Aggregated execution counters used for final summary
# generation and CI result propagation.
# =========================================================
$scriptsRun = 0

$scriptsFailed = 0

$totalFail = 0

$totalPass = 0

$totalError = 0

$totalFatal = 0

# =========================================================
# INTEGRITY EXECUTION PIPELINE
# =========================================================
# Sequentially executes all integrity validation scripts.
#
# Execution behavior:
#   • Optional cleanup/reset execution
#   • Integrity validation execution
#   • PASS/FAIL notice parsing
#   • Metrics aggregation
#   • Failure tracking
# =========================================================
foreach ($entry in $scripts) {

    $rel = $entry.Path

    # =====================================================
    # OPTIONAL CLEANUP EXECUTION
    # =====================================================
    # Some validation scenarios require deterministic state
    # cleanup before integrity validation execution.
    # =====================================================
    if ($entry.Cleanup) {

        $cleanupRel = $entry.Cleanup

        Write-Host ""
        Write-Host ">>> CLEANUP — $cleanupRel"

        $cleanupPath = Join-Path $Fixtures $cleanupRel

        if (Test-Path $cleanupPath) {

            $cr = Invoke-QaSqlScript `
                -Container $Container `
                -DatabaseName $Db `
                -User $User `
                -FilePath $cleanupPath

            $cr.Output | Write-Host

            # Track cleanup execution failures
            if (-not $cr.Success) {

                $scriptsFailed++
            }
        }
    }

    Write-Host ""
    Write-Host ">>> $rel"

    # Resolve integrity script path
    $path = Join-Path $Integrity $rel

    # =====================================================
    # EXECUTE INTEGRITY VALIDATION SCRIPT
    # =====================================================
    # Validation includes:
    #   • FAIL notice parsing
    #   • PASS notice parsing
    #   • SQL runtime error detection
    #   • Fatal execution detection
    # =====================================================
    $result = Invoke-QaSqlScript `
        -Container $Container `
        -DatabaseName $Db `
        -User $User `
        -FilePath $path `
        -CountPass

    # Display raw SQL execution output
    $result.Output | Write-Host

    # =====================================================
    # AGGREGATE EXECUTION METRICS
    # =====================================================
    $scriptsRun++

    $totalFail += $result.Metrics.FailCount

    $totalPass += $result.Metrics.PassCount

    $totalError += $result.Metrics.ErrorCount

    $totalFatal += $result.Metrics.FatalCount

    # Track validation execution failures
    if (-not $result.Success) {

        $scriptsFailed++

        Write-Host "ERROR: integrity validation failed -> $rel"
    }
}

# =========================================================
# FINAL EXECUTION SUMMARY
# =========================================================
# Generates aggregated integrity execution summary and
# determines overall validation success state.
# =========================================================
$passed = Write-QaRunSummary `
    -SuiteName "INTEGRITY" `
    -ScriptsRun $scriptsRun `
    -ScriptsFailed $scriptsFailed `
    -TotalFailNotices $totalFail `
    -TotalPassNotices $totalPass `
    -TotalSqlErrors $totalError `
    -TotalFatals $totalFatal

# =========================================================
# FINAL EXIT STATUS
# =========================================================
# Exit codes:
#   • 0 → validation successful
#   • 1 → validation failure detected
#
# Allows CI workflows and orchestration runners to detect
# integrity validation failures automatically.
# =========================================================
if (-not $passed) {

    exit 1
}