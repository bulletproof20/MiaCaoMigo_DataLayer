# Master contract validation (requires init_qa bootstrap).
param(
    [string]$Container = "miacaomigo-db",
    [string]$Db = "miacaomigo",
    [string]$User = "postgres"
)

$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "lib/Invoke-QaSqlRunner.ps1")

$TestsRoot = Split-Path $PSScriptRoot -Parent
$path = Join-Path $TestsRoot "00_Bootstrap/01_Master_Contract.sql"

Write-Host "========================================"
Write-Host "QA BOOTSTRAP CHECK"
Write-Host "Prerequisite: init_qa (docker-compose.qa.yml)"
Write-Host "========================================"
Write-Host ""
Write-Host ">>> 00_Bootstrap/01_Master_Contract.sql"

$result = Invoke-QaSqlScript -Container $Container -DatabaseName $Db -User $User -FilePath $path -CountPass
$result.Output | Write-Host

$passed = Write-QaRunSummary `
    -SuiteName "BOOTSTRAP" `
    -ScriptsRun 1 `
    -ScriptsFailed $(if ($result.Success) { 0 } else { 1 }) `
    -TotalFailNotices $result.Metrics.FailCount `
    -TotalPassNotices $result.Metrics.PassCount `
    -TotalSqlErrors $result.Metrics.ErrorCount `
    -TotalFatals $result.Metrics.FatalCount

if (-not $passed) { exit 1 }
