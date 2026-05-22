# =========================================================
# QA RUNNER — BOOTSTRAP CONTRACT VALIDATION
# FILE: QA/runners/run_bootstrap_check.ps1
# =========================================================
# PURPOSE:
#   Executes the master bootstrap contract validation suite
#   against an initialized QA database environment.
#
# RESPONSIBILITIES:
#   • Load QA SQL execution helpers
#   • Resolve bootstrap validation script location
#   • Execute bootstrap contract validation
#   • Collect PASS / FAIL / ERROR metrics
#   • Generate execution summary
#   • Return CI-compatible exit codes
#
# VALIDATION TARGET:
#   • Bootstrap integrity
#   • Master data availability
#   • Structural consistency
#   • Core QA contract resolution
#   • init_qa initialization completeness
#
# PREREQUISITES:
#   • Docker container running
#   • PostgreSQL available
#   • init_qa bootstrap successfully executed
#   • QA helper library available
#
# DEPENDENCIES:
#   • lib/Invoke-QaSqlRunner.ps1
#   • 00_Bootstrap/01_Master_Contract.sql
#
# EXPECTED RESULT:
#   Validation succeeds only if all bootstrap contracts
#   and required master entities are available.
# =========================================================

# =========================================================
# RUNTIME PARAMETERS
# =========================================================
# Container:
#   Target PostgreSQL Docker container.
#
# Db:
#   Target database name used during validation.
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
#   • Shared QA execution utilities
# =========================================================
. (Join-Path $PSScriptRoot "lib/Invoke-QaSqlRunner.ps1")

# =========================================================
# RESOLVE TEST SUITE LOCATION
# =========================================================
# Dynamically resolves the bootstrap contract validation
# script path relative to the current runner location.
# =========================================================
$TestsRoot = Split-Path $PSScriptRoot -Parent

$path = Join-Path `
    $TestsRoot `
    "00_Bootstrap/01_Master_Contract.sql"

# =========================================================
# EXECUTION HEADER
# =========================================================
# Displays contextual information about the validation
# suite being executed.
# =========================================================
Write-Host "========================================"
Write-Host "QA BOOTSTRAP CHECK"
Write-Host "Profile: init_qa"
Write-Host "Validation: Master Contract Integrity"
Write-Host "========================================"
Write-Host ""

# Display current validation target
Write-Host ">>> 00_Bootstrap/01_Master_Contract.sql"

# =========================================================
# EXECUTE VALIDATION SUITE
# =========================================================
# Runs the bootstrap validation SQL script and collects:
#   • PASS notices
#   • FAIL notices
#   • SQL runtime errors
#   • Fatal execution errors
# =========================================================
$result = Invoke-QaSqlScript `
    -Container $Container `
    -DatabaseName $Db `
    -User $User `
    -FilePath $path `
    -CountPass

# Display raw SQL execution output
$result.Output | Write-Host

# =========================================================
# EXECUTION SUMMARY
# =========================================================
# Aggregates execution metrics and determines overall
# validation success status.
# =========================================================
$passed = Write-QaRunSummary `
    -SuiteName "BOOTSTRAP" `
    -ScriptsRun 1 `
    -ScriptsFailed $(if ($result.Success) { 0 } else { 1 }) `
    -TotalFailNotices $result.Metrics.FailCount `
    -TotalPassNotices $result.Metrics.PassCount `
    -TotalSqlErrors $result.Metrics.ErrorCount `
    -TotalFatals $result.Metrics.FatalCount

# =========================================================
# FINAL EXIT STATUS
# =========================================================
# Exit code behavior:
#   • 0 → validation successful
#   • 1 → validation failed
#
# Allows CI pipelines and GitHub Actions to detect
# bootstrap integrity failures automatically.
# =========================================================
if (-not $passed) {
    exit 1
}