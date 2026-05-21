# Manual QA (non-CI)

Demonstration workflows for academic defense. Human-reviewed NOTICE and SELECT output.

```powershell
cd DataBase/QA/runners
.\run_fixtures.ps1
.\run_manual_module.ps1 -Module 1 -Workflow 01_Authentication_Session_Workflow.sql
```

Prerequisite: **init_qa** + fixtures.
