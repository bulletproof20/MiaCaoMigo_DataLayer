# Stress QA (optional)

Concurrency and volume probes. `STRESS` NOTICE metrics; SQL errors fail the run.

Not part of default CI. Enable with `.\ci.ps1 -IncludeStress` or run standalone:

```powershell
cd DataBase/QA/runners
.\stages/stress.ps1
```

Prerequisite: **init_qa** + `stages/fixtures.ps1 -Module all -IncludeStress` (loads `fixtures/seed/m3_stress_commercial.sql` for Module 3).

## Module 3 commercial seed

| Path | Role |
|------|------|
| `fixtures/seed/m3_stress_commercial.sql` | **Active** — loaded by `ci.ps1 -IncludeStress` / `stages/stress.ps1` |
| `00_Setup/01_Commercial_Stress_Fixture.sql` | **Legacy** — same intent; not called by runners |

## Layout

```
04_Stress/
├── 00_Setup/          # legacy M3 fixture (manual only)
├── 01_Module1/        # login, clocking concurrency
├── 02_Module2/        # concurrent adoption
├── 03_Module3/        # sales, invoice lines, FIFO, returns
└── 04_Module4/        # appointment booking, lifecycle load
```

True parallel sessions for some scripts require multiple `psql` clients (see script headers).
