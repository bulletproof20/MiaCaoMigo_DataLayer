# QA runners

Shared parser: `lib/Invoke-QaSqlRunner.ps1` (PASS/FAIL/ERROR/FATAL from NOTICE).

## Orchestration

`run_ci.ps1` is the sole PowerShell entrypoint for the full CI validation pipeline (bootstrap, fixtures, integrity, optional stress). All other `.ps1` scripts are modular execution stages invoked by `run_ci.ps1` or run standalone for focused validation.

Linux/GitHub Actions equivalent: `run_qa.sh` (same scope).

## CI pipeline

```
run_ci.ps1  ->  run_bootstrap_check.ps1
            ->  run_fixtures.ps1
            ->  run_integrity_all.ps1 -SkipFixtures
            ->  run_stress_all.ps1          (optional: -IncludeStress)
```

## Optional stages

- `run_stress_all.ps1` — `04_Stress`
- `run_manual_module.ps1` — `05_Manual` (interactive menu if `-Module` omitted)

Exit code `1` when any script fails or emits `FAIL:` / `FATAL:`.
