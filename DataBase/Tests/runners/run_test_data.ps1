# Load TestData fixture chain (never part of init.sql)
param(
    [string]$Container = "miacaomigo-db",
    [string]$Db = "miacaomigo",
    [string]$User = "postgres"
)

$ErrorActionPreference = "Stop"

docker exec $Container bash -c "cd /docker-entrypoint-initdb.d/DataSeed && psql -U $User -d $Db -v ON_ERROR_STOP=1 -f 04_Loaders/03_TestData.sql"
Write-Host "TestData loaded."
