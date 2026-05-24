# ci.ps1 — Full QA pipeline (init_qa): bootstrap → fixtures → integrity → [stress]
# Usage: .\ci.ps1 [-IncludeStress] [-SkipBootstrapCheck]
# Prerequisite: docker compose -f docker-compose.yml -f docker-compose.qa.yml up -d --build

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
Write-Host "QA CI (init_qa)"
Write-Host "========================================"
Write-Host ""
Write-Host "Prerequisite:"
Write-Host "  docker compose -f docker-compose.yml -f docker-compose.qa.yml up -d --build"
Write-Host ""

if (-not $SkipBootstrapCheck) {
    Write-Host ">>> STEP 1 - bootstrap"
    & (Join-Path $Runners "stages/bootstrap.ps1") -Container $Container -Db $Db -User $User
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}

Write-Host ">>> STEP 2 - fixtures"
& (Join-Path $Runners "stages/fixtures.ps1") -Container $Container -Db $Db -User $User -Module all
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host ">>> STEP 3 - integrity"
& (Join-Path $Runners "stages/integrity.ps1") -Container $Container -Db $Db -User $User -SkipFixtures
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

if ($IncludeStress) {
    Write-Host ">>> STEP 4 - stress"
    & (Join-Path $Runners "stages/stress.ps1") -Container $Container -Db $Db -User $User
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}

Write-Host ""
Write-Host "========================================"
Write-Host "QA CI: PASSED"
Write-Host "========================================"

exit 0
