# QA runners

Shared SQL helper: `lib/Invoke-QaSqlRunner.ps1` (PASS/FAIL/ERROR/FATAL from NOTICE).

## Quick start

```powershell
# init_qa database
docker compose -f docker-compose.yml -f docker-compose.qa.yml up -d --build
cd DataBase/QA/runners
.\ci.ps1
```

```bash
chmod +x DataBase/QA/runners/qa.sh
DataBase/QA/runners/qa.sh
```

Optional stress: `.\ci.ps1 -IncludeStress` or `./qa.sh -IncludeStress`

## Pipeline

```
ci.ps1 / qa.sh
  └── stages/bootstrap.ps1      # 00_Bootstrap contract
  └── stages/fixtures.ps1       # contracts + fixtures/reset + fixtures/seed
  └── stages/integrity.ps1      # 01_Integrity (-SkipFixtures when called from ci)
  └── stages/stress.ps1         # 04_Stress (optional, -IncludeStress)
```

`qa.sh` waits for PostgreSQL, then delegates to `ci.ps1` (single source of truth).

## Stages (standalone)

| Script | Purpose |
|--------|---------|
| `stages/bootstrap.ps1` | Master bootstrap contract |
| `stages/fixtures.ps1` | `-Module 1\|2\|3\|4\|all`, `-IncludeStress`, `-SkipReset` |
| `stages/integrity.ps1` | Full integrity suite; `-SkipFixtures` if fixtures already loaded |
| `stages/stress.ps1` | Stress suite + stress seed |

## Parameters (all stages)

| Parameter | Default | Notes |
|-----------|---------|-------|
| `-Container` | `miacaomigo-db` | Docker container |
| `-Db` | `miacaomigo` | Database name |
| `-User` | `postgres` | DB user |

Exit code `1` on SQL failure, `FAIL:` notices, or `FATAL:`.
