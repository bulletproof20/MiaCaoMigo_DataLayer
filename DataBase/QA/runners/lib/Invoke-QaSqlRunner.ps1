# =========================================================
# QA SHARED EXECUTION LIBRARY
# FILE: QA/runners/lib/Invoke-QaSqlRunner.ps1
# =========================================================
# PURPOSE:
#   Provides shared SQL execution helpers and validation
#   utilities used across all MiaCaoMigo QA runners.
#
# RESPONSIBILITIES:
#   • Execute SQL validation scripts
#   • Parse FAIL / PASS notices
#   • Detect SQL runtime errors
#   • Detect fatal execution conditions
#   • Aggregate validation metrics
#   • Generate execution summaries
#   • Standardize QA runner behavior
#
# EXECUTION FEATURES:
#   • Docker-based SQL execution
#   • Structured output parsing
#   • Deterministic validation metrics
#   • Shared QA orchestration support
#   • CI-compatible failure propagation
#
# SHARED FUNCTIONS:
#   • Get-SqlOutputMetrics
#   • Invoke-QaSqlScript
#   • Write-QaRunSummary
#
# USED BY:
#   • run_bootstrap_check.ps1
#   • run_ci.ps1
#   • run_fixtures.ps1
#   • run_integrity_all.ps1
#   • run_stress_all.ps1
#
# EXECUTION MODEL:
#   This library is intended to be imported through
#   PowerShell dot-sourcing:
#
#     . (Join-Path $PSScriptRoot "lib/Invoke-QaSqlRunner.ps1")
#
# EXPECTED RESULT:
#   All QA runners share consistent SQL execution,
#   validation parsing and summary reporting behavior.
# =========================================================


# =========================================================
# SQL OUTPUT METRICS PARSER
# =========================================================
# Parses SQL execution output and aggregates validation
# metrics emitted by QA validation scripts.
#
# SUPPORTED NOTICE TYPES:
#   • FAIL:
#   • PASS:
#   • ERROR:
#   • FATAL:
#
# RESPONSIBILITIES:
#   • Detect validation failures
#   • Detect SQL runtime errors
#   • Detect fatal execution conditions
#   • Count PASS notices when enabled
#
# PARAMETERS:
#   Lines:
#     SQL execution output lines.
#
#   CountPass:
#     Enables PASS notice aggregation.
#
# RETURNS:
#   PSCustomObject containing aggregated metrics.
# =========================================================
function Get-SqlOutputMetrics {

    param(

        [string[]]$Lines,

        [switch]$CountPass
    )

    # =====================================================
    # METRICS INITIALIZATION
    # =====================================================
    # Aggregated validation metrics extracted from SQL
    # execution output.
    # =====================================================
    $metrics = [ordered]@{

        FailCount  = 0

        ErrorCount = 0

        FatalCount = 0

        PassCount  = 0
    }

    # =====================================================
    # OUTPUT LINE PARSING
    # =====================================================
    # Sequentially parses SQL execution output lines and
    # aggregates validation metrics.
    # =====================================================
    foreach ($line in $Lines) {

        # Ignore null or empty lines
        if ($null -eq $line -or $line.Length -eq 0) {

            continue
        }

        # =================================================
        # FAIL NOTICE DETECTION
        # =================================================
        # Detects logical validation failures emitted by
        # QA validation scripts.
        # =================================================
        if ($line -match '(?i)(^|\s|:)\s*FAIL:') {

            $metrics.FailCount++

            continue
        }

        # =================================================
        # FATAL EXECUTION DETECTION
        # =================================================
        # Detects fatal execution conditions emitted by
        # PostgreSQL or validation scripts.
        # =================================================
        if ($line -match '(?i)^FATAL:\s') {

            $metrics.FatalCount++

            continue
        }

        # =================================================
        # SQL ERROR DETECTION
        # =================================================
        # Detects SQL runtime errors while intentionally
        # ignoring orchestration-level error messages.
        # =================================================
        if ($line -match '(?i)^ERROR:\s') {

            if ($line -notmatch '(?i)ERROR:\s+script failed') {

                $metrics.ErrorCount++
            }

            continue
        }

        # =================================================
        # PASS NOTICE DETECTION
        # =================================================
        # PASS aggregation is optional because some suites
        # intentionally do not emit PASS notices.
        # =================================================
        if ($CountPass -and ($line -match '(?i)(^|\s|:)\s*PASS:')) {

            $metrics.PassCount++
        }
    }

    # Return aggregated metrics object
    return [pscustomobject]$metrics
}


# =========================================================
# QA SQL SCRIPT EXECUTOR
# =========================================================
# Executes a SQL script against the target PostgreSQL
# container and returns structured execution metrics.
#
# EXECUTION FEATURES:
#   • Docker-based SQL execution
#   • UTF-8 SQL script loading
#   • psql runtime validation
#   • FAIL / ERROR / FATAL parsing
#   • Structured execution results
#
# VALIDATION BEHAVIOR:
#   • Detects SQL runtime failures
#   • Detects logical QA failures
#   • Aggregates execution metrics
#   • Supports optional PASS notice counting
#
# PARAMETERS:
#   Container:
#     Target PostgreSQL Docker container.
#
#   DatabaseName:
#     Target database name.
#
#   User:
#     PostgreSQL execution user.
#
#   FilePath:
#     SQL script absolute path.
#
#   CountPass:
#     Enables PASS notice aggregation.
#
# RETURNS:
#   PSCustomObject containing:
#     • Output
#     • Metrics
#     • Success state
#     • psql exit code
#     • Logical failure state
# =========================================================
function Invoke-QaSqlScript {

    param(

        [Parameter(Mandatory = $true)]
        [string]$Container,

        [Parameter(Mandatory = $true)]
        [string]$DatabaseName,

        [Parameter(Mandatory = $true)]
        [string]$User,

        [Parameter(Mandatory = $true)]
        [string]$FilePath,

        [switch]$CountPass
    )

    # =====================================================
    # TEMPORARY ERROR HANDLING OVERRIDE
    # =====================================================
    # Prevents PowerShell runtime interruption during SQL
    # execution while still capturing command output.
    # =====================================================
    $prevEap = $ErrorActionPreference

    $ErrorActionPreference = 'Continue'

    try {

        # =================================================
        # SQL SCRIPT EXECUTION
        # =================================================
        # Loads SQL script as UTF-8 and executes it inside
        # the target PostgreSQL Docker container.
        #
        # psql flags:
        #   • ON_ERROR_STOP=1
        #     Abort execution immediately on SQL errors.
        # =================================================
        $output = Get-Content `
            -Path $FilePath `
            -Raw `
            -Encoding UTF8 |

            docker exec -i $Container `
                psql `
                    -U $User `
                    -d $DatabaseName `
                    -v ON_ERROR_STOP=1 2>&1
    }
    finally {

        # Restore previous PowerShell error behavior
        $ErrorActionPreference = $prevEap
    }

    # =====================================================
    # OUTPUT NORMALIZATION
    # =====================================================
    # Converts execution output into normalized text and
    # line collections for metrics parsing.
    # =====================================================
    $text = if ($output -is [array]) {

        $output -join "`n"
    }
    else {

        [string]$output
    }

    $lines = $text -split "`r?`n"

    # =====================================================
    # PARSE EXECUTION METRICS
    # =====================================================
    $metrics = Get-SqlOutputMetrics `
        -Lines $lines `
        -CountPass:$CountPass

    # =====================================================
    # EXECUTION RESULT EVALUATION
    # =====================================================
    # psqlExit:
    #   Native psql process exit code.
    #
    # logicalFail:
    #   Logical validation failure detected through
    #   FAIL or FATAL notices.
    # =====================================================
    $psqlExit = $LASTEXITCODE

    $logicalFail =
        ($metrics.FailCount -gt 0) -or
        ($metrics.FatalCount -gt 0)

    # =====================================================
    # STRUCTURED EXECUTION RESULT
    # =====================================================
    # Shared execution result object returned to QA runners.
    # =====================================================
    [pscustomobject]@{

        PsqlExit     = $psqlExit

        Metrics      = $metrics

        Output       = $text

        Success      =
            ($psqlExit -eq 0) -and
            (-not $logicalFail)

        LogicalFail  = $logicalFail
    }
}


# =========================================================
# QA EXECUTION SUMMARY WRITER
# =========================================================
# Displays aggregated QA execution metrics and determines
# overall validation success state.
#
# SUMMARY METRICS:
#   • Scripts executed
#   • Scripts failed
#   • FAIL notices
#   • PASS notices
#   • SQL runtime errors
#   • Fatal execution conditions
#
# GATE FAILURE CONDITIONS:
#   Validation fails if any of the following occur:
#     • Script execution failure
#     • FAIL notice detection
#     • SQL ERROR detection
#     • FATAL condition detection
#
# PARAMETERS:
#   SuiteName:
#     Validation suite name.
#
#   ScriptsRun:
#     Total executed scripts.
#
#   ScriptsFailed:
#     Total failed scripts.
#
#   TotalFailNotices:
#     Aggregated FAIL notice count.
#
#   TotalPassNotices:
#     Aggregated PASS notice count.
#
#   TotalSqlErrors:
#     Aggregated SQL ERROR count.
#
#   TotalFatals:
#     Aggregated FATAL count.
#
# RETURNS:
#   Boolean validation success state.
# =========================================================
function Write-QaRunSummary {

    param(

        [string]$SuiteName,

        [int]$ScriptsRun,

        [int]$ScriptsFailed,

        [int]$TotalFailNotices,

        [int]$TotalPassNotices,

        [int]$TotalSqlErrors,

        [int]$TotalFatals
    )

    # =====================================================
    # SUMMARY HEADER
    # =====================================================
    Write-Host ""

    Write-Host "========================================"

    Write-Host "$SuiteName - SUMMARY"

    Write-Host "========================================"

    # =====================================================
    # AGGREGATED EXECUTION METRICS
    # =====================================================
    Write-Host "Scripts executed : $ScriptsRun"

    Write-Host "Scripts failed   : $ScriptsFailed (psql exit != 0)"

    Write-Host "FAIL: notices     : $TotalFailNotices"

    # PASS notices may intentionally be disabled for some
    # validation suites such as stress testing.
    if ($TotalPassNotices -ge 0) {

        Write-Host "PASS: notices     : $TotalPassNotices"
    }

    Write-Host "SQL ERROR: lines  : $TotalSqlErrors"

    Write-Host "FATAL: lines      : $TotalFatals"

    # =====================================================
    # FINAL VALIDATION GATE
    # =====================================================
    # Validation fails if:
    #   • Any script execution fails
    #   • FAIL notices are detected
    #   • SQL ERROR lines are detected
    #   • FATAL lines are detected
    # =====================================================
    $gateFail =
        ($ScriptsFailed -gt 0) -or
        ($TotalFailNotices -gt 0) -or
        ($TotalSqlErrors -gt 0) -or
        ($TotalFatals -gt 0)

    # =====================================================
    # FINAL EXECUTION RESULT
    # =====================================================
    if ($gateFail) {

        Write-Host "RESULT           : FAILED"
    }
    else {

        Write-Host "RESULT           : PASSED"
    }

    Write-Host "========================================"

    # Return boolean validation success state
    return (-not $gateFail)
}