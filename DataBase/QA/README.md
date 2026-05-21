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
.\run_ci.ps1
```

```bash
chmod +x DataBase/QA/runners/run_qa.sh
DataBase/QA/runners/run_qa.sh
```

Optional stress in CI: `.\run_ci.ps1 -IncludeStress`

## Runners

| Script | CI | Purpose |
|--------|-----|---------|
| `run_bootstrap_check.ps1` | yes | `00_Bootstrap` |
| `run_fixtures.ps1` | yes | contracts + fixtures |
| `run_integrity_all.ps1` | yes | 21 integrity scripts |
| `run_ci.ps1` | yes | bootstrap + fixtures + integrity |
| `run_stress_all.ps1` | no | `04_Stress` |
| `run_manual_module.ps1` | no | `05_Manual` |

## Tiers

| Tier | Role |
|------|------|
| **MasterData** | platform invariants (`init_qa`) |
| **DemoData** | demos only (`init_demo`) |
| **QA fixtures** | isolated `QA-*` scenarios |

See `MIGRATION.txt` for profile switching.
