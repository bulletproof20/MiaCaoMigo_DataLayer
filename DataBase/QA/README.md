# Database QA

SQL validation for schema integrity, consistency and robustness. Not loaded by Docker `init.sql`.

## Layout

```
QA/
├── 00_Bootstrap/   # Master contract (CI)
├── 01_Integrity/   # constraints, triggers, rules (CI)
├── 04_Stress/      # optional concurrency (non-CI)
├── 05_Manual/      # defense demos (non-CI)
├── contracts/
├── fixtures/
└── runners/
```

## CI (init_qa, Master only)

```powershell
docker compose -f docker-compose.yml -f docker-compose.qa.yml up -d --build
cd DataBase/QA/runners
.\ci.ps1
```

```bash
chmod +x DataBase/QA/runners/qa.sh
DataBase/QA/runners/qa.sh
```

Optional stress in CI: `.\ci.ps1 -IncludeStress`

## Runners

`ci.ps1` (PowerShell) and `qa.sh` (Linux/CI) are the only orchestration entrypoints. Other runners are modular stages invoked by the pipeline or run standalone.

| Script | CI | Purpose |
|--------|-----|---------|
| `ci.ps1` | yes | orchestration: bootstrap + fixtures + integrity (+ optional stress) |
| `stages/bootstrap.ps1` | stage | `00_Bootstrap` |
| `stages/fixtures.ps1` | stage | contracts + fixtures |
| `stages/integrity.ps1` | stage | 21 integrity scripts |
| `stages/stress.ps1` | optional | `04_Stress` (`-IncludeStress` on `ci.ps1`) |

## Manual (`05_Manual`)

Exploratory reference SQL (not CI). Run directly with `psql` or your SQL client after `init_demo` or `init_qa` + fixtures as noted in each file header.

```
05_Manual/
└── 01_Module1/
    ├── Authentication/   # login / logout reference
    └── User_Creation/    # client, employee, assistant, vet reference
```

## Tiers

| Tier | Role |
|------|------|
| **MasterData** | platform invariants (`init_qa`) |
| **DemoData** | demos only (`init_demo`) |
| **QA fixtures** | isolated `QA-*` scenarios |

## Profiles and Docker reset

| Profile | Loaded by | Data |
|---------|-----------|------|
| `init_demo` | default `init.sql` | Master + Demo |
| `init_qa` | `docker-compose.qa.yml` entrypoint | Master only |

Init scripts run **once per volume**. Switching profiles requires:

```bash
docker compose -f docker-compose.yml -f docker-compose.qa.yml down -v
docker compose -f docker-compose.yml -f docker-compose.qa.yml up -d --build
```

GitHub Actions: `.github/workflows/qa-ci.yml`
