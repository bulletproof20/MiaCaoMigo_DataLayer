# =========================================================
# QA RUNNER — FIXTURE INITIALIZATION
# FILE: QA/runners/run_fixtures.ps1
# =========================================================
# PURPOSE:
#   Loads deterministic QA contracts and fixture datasets
#   required for integrity, stress and CI validation suites.
#
# RESPONSIBILITIES:
#   • Load QA semantic contract functions
#   • Reset previous QA runtime state
#   • Load module-specific QA fixtures
#   • Support partial module initialization
#   • Optionally load stress-oriented fixtures
#   • Validate fixture file availability
#   • Propagate CI-compatible failure states
#
# EXECUTION MODES:
#   • Full fixture initialization
#   • Per-module fixture loading
#   • Stress fixture extension
#   • Reset-free incremental execution
#
# FIXTURE SCOPE:
#   • QA users and employees
#   • Veterinarians and specialties
#   • Animals and ownership
#   • Products and commercial context
#   • Appointment scheduling context
#   • Login sessions and runtime states
#   • Stress validation datasets
#
# PREREQUISITES:
#   • init_qa bootstrap initialized
#   • PostgreSQL container available
#   • QA execution helper library available
#
# DEPENDENCIES:
#   • lib/Invoke-QaSqlRunner.ps1
#   • contracts/01_QA_Functions.sql
#   • fixtures/*
#
# EXPECTED RESULT:
#   All requested QA fixtures and semantic contracts are
#   loaded successfully without SQL execution failures.
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
# Module:
#   Target fixture module scope.
#
#   Available values:
#     • all
#     • 1
#     • 2
#     • 3
#     • 4
#
# IncludeStress:
#   Loads optional stress-oriented fixture datasets.
#
# SkipReset:
#   Prevents QA runtime state reset execution.
# =========================================================
param(
    [string]$Container = "miacaomigo-db",

    [string]$Db = "miacaomigo",

    [string]$User = "postgres",

    [ValidateSet("all", "1", "2", "3", "4")]
    [string]$Module = "all",

    [switch]$IncludeStress,

    [switch]$SkipReset
)

# Stop execution immediately on runtime failures
$ErrorActionPreference = "Stop"

# =========================================================
# LOAD QA EXECUTION LIBRARY
# =========================================================
# Imports:
#   • Invoke-QaSqlScript
#   • Shared QA execution helpers
#   • SQL execution wrappers
# =========================================================
. (Join-Path $PSScriptRoot "lib/Invoke-QaSqlRunner.ps1")

# Root QA tests directory
$TestsRoot = Split-Path $PSScriptRoot -Parent

# =========================================================
# CORE FIXTURE FILES
# =========================================================
# Base QA initialization layer.
#
# Includes:
#   • Semantic contract functions
#   • Optional QA runtime reset
# =========================================================
$coreFiles = @(
    "contracts/01_QA_Functions.sql"
)

# Optional runtime reset layer
if (-not $SkipReset) {

    $coreFiles += "fixtures/00_Reset_QA_State.sql"
}

# =========================================================
# MODULE FIXTURE REGISTRY
# =========================================================
# Maps fixture modules to their corresponding SQL datasets.
#
# Module 1:
#   Core users, employees and login context
#
# Module 2:
#   Animals and ownership context
#
# Module 3:
#   Commercial and product context
#
# Module 4:
#   Appointment scheduling context
# =========================================================
$moduleFiles = @{

    "1" = @(
        "fixtures/01_Module1/01_Core_Context.sql"
    )

    "2" = @(
        "fixtures/02_Module2/01_Animals_Ownership.sql"
    )

    "3" = @(
        "fixtures/03_Module3/01_Commercial_Product.sql"
    )

    "4" = @(
        "fixtures/04_Module4/01_Appointment_Slots.sql"
    )
}

# =========================================================
# BUILD EXECUTION FILE LIST
# =========================================================
# Dynamically constructs the fixture execution pipeline
# according to:
#   • selected module scope
#   • reset options
#   • stress execution mode
# =========================================================
$files = [System.Collections.Generic.List[string]]::new()

# Add core initialization files
foreach ($f in $coreFiles) {

    $files.Add($f)
}

# Full fixture initialization mode
if ($Module -eq "all") {

    foreach ($k in @("1", "2", "3", "4")) {

        foreach ($f in $moduleFiles[$k]) {

            $files.Add($f)
        }
    }
}
else {

    # Partial module initialization mode
    foreach ($f in $moduleFiles[$Module]) {

        $files.Add($f)
    }
}

# =========================================================
# OPTIONAL STRESS FIXTURES
# =========================================================
# Adds additional stress-oriented datasets intended for:
#   • load testing
#   • concurrency validation
#   • high-volume execution scenarios
# =========================================================
if ($IncludeStress) {

    $files.Add(
        "fixtures/03_Module3/02_Stress_Commercial.sql"
    )
}

# =========================================================
# EXECUTION HEADER
# =========================================================
# Displays contextual information about the current
# fixture initialization execution.
# =========================================================
Write-Host "========================================"
Write-Host "QA FIXTURE INITIALIZATION"
Write-Host "Module Scope: $Module"
Write-Host "Files Scheduled: $($files.Count)"
Write-Host "Container: $Container"
Write-Host "Database: $Db"
Write-Host "========================================"

# =========================================================
# FIXTURE EXECUTION PIPELINE
# =========================================================
# Sequentially executes all requested fixture files.
#
# Validation behavior:
#   • Confirms file existence
#   • Executes SQL fixture scripts
#   • Displays execution output
#   • Tracks fixture execution failures
# =========================================================
$fail = 0

foreach ($rel in $files) {

    $path = Join-Path $TestsRoot $rel

    # Validate fixture file existence
    if (-not (Test-Path $path)) {

        Write-Host "ERROR: missing fixture file -> $rel"

        $fail++

        continue
    }

    Write-Host ""
    Write-Host ">>> $rel"

    # Execute fixture SQL script
    $result = Invoke-QaSqlScript `
        -Container $Container `
        -DatabaseName $Db `
        -User $User `
        -FilePath $path

    # Display SQL execution output
    $result.Output | Write-Host

    # Track execution failures
    if (-not $result.Success) {

        $fail++

        Write-Host "ERROR: fixture execution failed -> $rel"
    }
}

# =========================================================
# FINAL EXECUTION STATUS
# =========================================================
# Exit codes:
#   • 0 → fixture initialization successful
#   • 1 → one or more fixture failures detected
# =========================================================
if ($fail -gt 0) {

    exit 1
}

Write-Host ""
Write-Host "QA fixtures loaded successfully."