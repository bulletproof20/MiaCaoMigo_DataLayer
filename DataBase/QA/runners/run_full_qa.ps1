# Alias for CI gate (bootstrap + integrity).
param(
    [string]$Container = "miacaomigo-db",
    [string]$Db = "miacaomigo",
    [string]$User = "postgres"
)

$ErrorActionPreference = "Stop"
& (Join-Path $PSScriptRoot "run_ci.ps1") -Container $Container -Db $Db -User $User
exit $LASTEXITCODE
