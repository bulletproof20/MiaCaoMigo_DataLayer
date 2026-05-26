# stages/bootstrap.ps1 — Validate 00_Bootstrap/01_Master_Contract.sql (requires init_qa)
# Usage: .\stages\bootstrap.ps1 [-Container miacaomigo-db] [-Db miacaomigo] [-User postgres]

param(
    [string]$Container = "miacaomigo-db",
    [string]$Db = "miacaomigo",
    [string]$User = "postgres"
)

$ErrorActionPreference = "Stop"

$RunnersRoot = Split-Path $PSScriptRoot -Parent
$TestsRoot = Split-Path $RunnersRoot -Parent

. (Join-Path $RunnersRoot "lib/Invoke-QaSqlRunner.ps1")

$path = Join-Path $TestsRoot "00_Bootstrap/01_Master_Contract.sql"

Write-Host "========================================"
Write-Host "QA BOOTSTRAP CHECK (init_qa)"
Write-Host "========================================"
Write-Host ""
Write-Host ">>> 00_Bootstrap/01_Master_Contract.sql"

$result = Invoke-QaSqlScript `
    -Container $Container `
    -DatabaseName $Db `
    -User $User `
    -FilePath $path `
    -CountPass

$result.Output | Write-Host

$passed = Write-QaRunSummary `
    -SuiteName "BOOTSTRAP" `
    -ScriptsRun 1 `
    -ScriptsFailed $(if ($result.Success) { 0 } else { 1 }) `
    -TotalFailNotices $result.Metrics.FailCount `
    -TotalPassNotices $result.Metrics.PassCount `
    -TotalSqlErrors $result.Metrics.ErrorCount `
    -TotalFatals $result.Metrics.FatalCount

if (-not $passed) {
    exit 1
}
