# CI gate: bootstrap + fixtures + integrity (init_qa). Optional stress via -IncludeStress.
param(
    [string]$Container = "miacaomigo-db",
    [string]$Db = "miacaomigo",
    [string]$User = "postgres",
    [switch]$SkipBootstrapCheck,
    [switch]$IncludeStress
)

$ErrorActionPreference = "Stop"
$Runners = $PSScriptRoot

Write-Host "========================================"
Write-Host "QA CI"
Write-Host "Prerequisite: docker compose -f docker-compose.yml -f docker-compose.qa.yml up -d --build"
Write-Host "========================================"

if (-not $SkipBootstrapCheck) {
    & (Join-Path $Runners "run_bootstrap_check.ps1") -Container $Container -Db $Db -User $User
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}

& (Join-Path $Runners "run_fixtures.ps1") -Container $Container -Db $Db -User $User -Module all
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

& (Join-Path $Runners "run_integrity_all.ps1") -Container $Container -Db $Db -User $User -SkipFixtures
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

if ($IncludeStress) {
    & (Join-Path $Runners "run_stress_all.ps1") -Container $Container -Db $Db -User $User
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}

Write-Host ""
Write-Host "QA CI: PASSED"
exit 0
