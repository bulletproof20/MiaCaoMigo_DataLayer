# Stress QA (optional)

Concurrency and volume probes. `STRESS` NOTICE metrics; SQL errors fail the run.

Not part of default CI. Enable with `.\run_ci.ps1 -IncludeStress` or run standalone:

```powershell
cd DataBase/QA/runners
.\run_stress_all.ps1
```

Prerequisite: **init_qa** + `run_fixtures.ps1 -IncludeStress`.
