# =========================================================
# QA RUNNER — CONTINUOUS INTEGRATION GATE
# FILE: QA/runners/run_ci.ps1
# =========================================================
# PURPOSE:
#   Main QA orchestration runner responsible for executing
#   the complete validation pipeline used by CI workflows
#   and local integrity validation environments.
#
# RESPONSIBILITIES:
#   • Validate bootstrap integrity contracts
#   • Load deterministic QA fixtures
#   • Execute integrity validation suites
#   • Optionally execute stress validation suites
#   • Propagate CI-compatible exit codes
#
# EXECUTION FLOW:
#   1. Bootstrap validation
#   2. Fixture initialization
#   3. Integrity validation
#   4. Optional stress validation
#
# VALIDATION SCOPE:
#   • Bootstrap contract consistency
#   • QA fixture integrity
#   • Relational integrity validation
#   • Trigger/function validation
#   • Structural consistency checks
#   • Optional stress/load scenarios
#
# PREREQUISITES:
#   • Docker environment running
#   • init_qa bootstrap initialized
#   • PostgreSQL container available
#   • QA runner dependencies available
#
# DEPENDENCIES:
#   • run_bootstrap_check.ps1
#   • run_fixtures.ps1
#   • run_integrity_all.ps1
#   • run_stress_all.ps1
#
# EXPECTED RESULT:
#   Runner succeeds only if all mandatory QA validation
#   stages complete successfully without integrity failures.
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
# SkipBootstrapCheck:
#   Skips bootstrap contract validation stage.
#
# IncludeStress:
#   Enables optional stress validation suites.
# =========================================================
param(
    [string]$Container = "miacaomigo-db",
    [string]$Db = "miacaomigo",
    [string]$User = "postgres",

    [switch]$SkipBootstrapCheck,

    [switch]$IncludeStress
)

# Stop execution immediately on runtime failures
$ErrorActionPreference = "Stop"

# Current runners directory
$Runners = $PSScriptRoot

# =========================================================
# EXECUTION HEADER
# =========================================================
# Displays CI execution context and initialization profile.
# =========================================================
Write-Host "========================================"
Write-Host "QA CI"
Write-Host "Profile: init_qa"
Write-Host "Execution Mode: Continuous Integration"
Write-Host "========================================"
Write-Host ""

Write-Host "Prerequisite:"
Write-Host "docker compose -f docker-compose.yml -f docker-compose.qa.yml up -d --build"
Write-Host ""

# =========================================================
# STEP 1 — BOOTSTRAP CONTRACT VALIDATION
# =========================================================
# Validates:
#   • Bootstrap initialization state
#   • Core master entities
#   • QA contract availability
#   • Structural initialization consistency
#
# This validation may be skipped for faster iterative runs.
# =========================================================
if (-not $SkipBootstrapCheck) {

    Write-Host ">>> STEP 1 — BOOTSTRAP VALIDATION"

    & (Join-Path $Runners "run_bootstrap_check.ps1") `
        -Container $Container `
        -Db $Db `
        -User $User

    # Abort pipeline on validation failure
    if ($LASTEXITCODE -ne 0) {
        exit $LASTEXITCODE
    }
}

# =========================================================
# STEP 2 — FIXTURE INITIALIZATION
# =========================================================
# Loads deterministic QA fixtures required by integrity
# and stress validation suites.
#
# Includes:
#   • QA users
#   • Employees
#   • Veterinarians
#   • Login sessions
#   • Appointment contexts
#   • Controlled integrity scenarios
# =========================================================
Write-Host ">>> STEP 2 — FIXTURE INITIALIZATION"

& (Join-Path $Runners "run_fixtures.ps1") `
    -Container $Container `
    -Db $Db `
    -User $User `
    -Module all

# Abort pipeline on fixture loading failure
if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
}

# =========================================================
# STEP 3 — INTEGRITY VALIDATION
# =========================================================
# Executes the complete integrity validation suite against
# the initialized QA environment.
#
# Validation targets may include:
#   • Constraints
#   • Triggers
#   • Procedures
#   • Referential integrity
#   • Business rules
#   • Functional consistency
#
# Fixture loading is skipped because fixtures were already
# initialized during the previous stage.
# =========================================================
Write-Host ">>> STEP 3 — INTEGRITY VALIDATION"

& (Join-Path $Runners "run_integrity_all.ps1") `
    -Container $Container `
    -Db $Db `
    -User $User `
    -SkipFixtures

# Abort pipeline on integrity validation failure
if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
}

# =========================================================
# STEP 4 — OPTIONAL STRESS VALIDATION
# =========================================================
# Executes optional stress and resilience validation suites.
#
# Triggered only when:
#   -IncludeStress
#
# Intended for:
#   • Extended CI runs
#   • Performance validation
#   • Concurrency validation
#   • Stress scenario execution
# =========================================================
if ($IncludeStress) {

    Write-Host ">>> STEP 4 — STRESS VALIDATION"

    & (Join-Path $Runners "run_stress_all.ps1") `
        -Container $Container `
        -Db $Db `
        -User $User

    # Abort pipeline on stress validation failure
    if ($LASTEXITCODE -ne 0) {
        exit $LASTEXITCODE
    }
}

# =========================================================
# FINAL EXECUTION STATUS
# =========================================================
# CI gate completed successfully.
#
# Exit codes:
#   • 0 → success
#   • non-zero → validation failure
# =========================================================
Write-Host ""
Write-Host "========================================"
Write-Host "QA CI: PASSED"
Write-Host "========================================"

exit 0