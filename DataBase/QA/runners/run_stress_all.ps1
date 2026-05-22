# =========================================================
# QA RUNNER — FULL SYSTEM STRESS VALIDATION
# FILE: QA/runners/run_stress_all.ps1
# =========================================================
# PURPOSE:
#   Executes the complete stress and concurrency validation
#   suite across all functional domains simultaneously.
#
# RESPONSIBILITIES:
#   • Execute full-system stress validation scripts
#   • Load stress-oriented QA fixtures
#   • Validate concurrency scenarios
#   • Aggregate FAIL / ERROR / FATAL metrics
#   • Detect SQL runtime failures
#   • Generate execution summaries
#   • Propagate CI-compatible exit codes
#
# EXECUTION PROFILE:
#   • Optional validation layer
#   • Non-CI by default
#   • Extended resilience validation
#   • Full-system concurrency simulation
#
# VALIDATION DOMAINS:
#   • Authentication concurrency
#   • Employee clocking contention
#   • Ownership concurrency
#   • Commercial load validation
#   • FIFO stock contention
#   • Appointment scheduling concurrency
#
# STRESS MODEL:
#   Stress validation intentionally executes all domains
#   together in order to simulate realistic concurrent
#   operational workloads and cross-domain contention.
#
# PREREQUISITES:
#   • init_qa bootstrap initialized
#   • PostgreSQL container available
#   • QA fixtures available
#   • Stress fixture datasets available
#
# DEPENDENCIES:
#   • lib/Invoke-QaSqlRunner.ps1
#   • run_fixtures.ps1
#   • 04_Stress/*
#
# EXPECTED RESULT:
#   Validation succeeds only if all stress validation
#   scripts complete successfully without SQL execution
#   failures or fatal runtime conditions.
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
# =========================================================
param(
    [string]$Container = "miacaomigo-db",

    [string]$Db = "miacaomigo",

    [string]$User = "postgres"
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
# Root directories used during stress validation execution.
# =========================================================
$Tests = Split-Path $PSScriptRoot -Parent

$Stress = Join-Path $Tests "04_Stress"

# =========================================================
# STRESS VALIDATION REGISTRY
# =========================================================
# Ordered full-system stress validation pipeline.
#
# Stress validation intentionally executes all functional
# domains together to simulate realistic operational
# concurrency and resource contention scenarios.
# =========================================================
$scripts = @(

    # =====================================================
    # MODULE 1 — AUTHENTICATION / EMPLOYEE STRESS
    # =====================================================

    "01_Module1/01_Login_Concurrency.sql"

    "01_Module1/02_Clocking_Concurrency.sql"


    # =====================================================
    # MODULE 2 — ANIMAL / OWNERSHIP STRESS
    # =====================================================

    "02_Module2/01_Concurrent_Adoption.sql"


    # =====================================================
    # MODULE 3 — COMMERCIAL / PRODUCT STRESS
    # =====================================================

    "03_Module3/01_Concurrent_Sales.sql"

    "03_Module3/02_High_Volume_Invoice_Lines.sql"

    "03_Module3/03_FIFO_Consumption.sql"

    "03_Module3/04_Return_Storm.sql"


    # =====================================================
    # MODULE 4 — APPOINTMENT / CLINICAL STRESS
    # =====================================================

    "04_Module4/01_Concurrent_Appointment_Booking.sql"

    "04_Module4/02_Appointment_Lifecycle_Load.sql"
)

# =========================================================
# EXECUTION HEADER
# =========================================================
# Displays stress validation execution context and runtime
# configuration information.
# =========================================================
Write-Host "========================================"
Write-Host "FULL SYSTEM STRESS VALIDATION"
Write-Host "Scripts Scheduled: $($scripts.Count)"
Write-Host "Container: $Container"
Write-Host "Database: $Db"
Write-Host "========================================"

# =========================================================
# PRE-FLIGHT FIXTURE INITIALIZATION
# =========================================================
# Loads deterministic QA fixtures and stress-oriented
# datasets required by stress validation scenarios.
#
# Includes:
#   • Core QA fixtures
#   • Commercial stress datasets
#   • Shared concurrency context
# =========================================================
Write-Host ""

Write-Host ">>> PRE-FLIGHT — QA FIXTURES + STRESS DATASETS"

& (Join-Path $PSScriptRoot "run_fixtures.ps1") `
    -Container $Container `
    -Db $Db `
    -User $User `
    -Module all `
    -IncludeStress

# Abort stress execution on fixture initialization failure
if ($LASTEXITCODE -ne 0) {

    exit $LASTEXITCODE
}

# =========================================================
# EXECUTION METRICS
# =========================================================
# Aggregated stress execution counters used for summary
# generation and failure propagation.
# =========================================================
$scriptsRun = 0

$scriptsFailed = 0

$totalFail = 0

$totalError = 0

$totalFatal = 0

# =========================================================
# STRESS EXECUTION PIPELINE
# =========================================================
# Sequentially executes all stress validation scripts.
#
# Validation behavior:
#   • Concurrency validation
#   • Stress/load execution
#   • FAIL notice parsing
#   • SQL runtime error detection
#   • Fatal execution detection
# =========================================================
foreach ($rel in $scripts) {

    Write-Host ""

    Write-Host ">>> $rel"

    # Resolve stress validation script path
    $path = Join-Path $Stress $rel

    # =====================================================
    # EXECUTE STRESS VALIDATION SCRIPT
    # =====================================================
    $result = Invoke-QaSqlScript `
        -Container $Container `
        -DatabaseName $Db `
        -User $User `
        -FilePath $path

    # Display raw SQL execution output
    $result.Output | Write-Host

    # =====================================================
    # AGGREGATE EXECUTION METRICS
    # =====================================================
    $scriptsRun++

    $totalFail += $result.Metrics.FailCount

    $totalError += $result.Metrics.ErrorCount

    $totalFatal += $result.Metrics.FatalCount

    # Track stress validation failures
    if (-not $result.Success) {

        $scriptsFailed++

        Write-Host "ERROR: stress validation failed -> $rel"
    }
}

# =========================================================
# FINAL EXECUTION SUMMARY
# =========================================================
# Generates aggregated stress execution summary and
# determines overall validation success state.
#
# PASS notices are intentionally not used during stress
# validation execution.
# =========================================================
$passed = Write-QaRunSummary `
    -SuiteName "STRESS" `
    -ScriptsRun $scriptsRun `
    -ScriptsFailed $scriptsFailed `
    -TotalFailNotices $totalFail `
    -TotalPassNotices -1 `
    -TotalSqlErrors $totalError `
    -TotalFatals $totalFatal

# =========================================================
# FINAL EXIT STATUS
# =========================================================
# Exit codes:
#   • 0 → stress validation successful
#   • 1 → stress validation failure detected
#
# Allows orchestration runners and CI workflows to detect
# stress validation failures automatically.
# =========================================================
if (-not $passed) {

    exit 1
}