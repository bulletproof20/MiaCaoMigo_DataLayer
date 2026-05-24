# Stress QA (optional)

Concurrency and volume probes. `STRESS` NOTICE metrics; SQL errors fail the run.

Not part of default CI. Enable with `.\ci.ps1 -IncludeStress` or run standalone:

```powershell
cd DataBase/QA/runners
.\stages/stress.ps1
```

Prerequisite: **init_qa** + `stages/fixtures.ps1 -IncludeStress`.
