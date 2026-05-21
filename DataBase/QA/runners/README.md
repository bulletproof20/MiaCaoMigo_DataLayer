# QA runners

Shared parser: `lib/Invoke-QaSqlRunner.ps1` (PASS/FAIL/ERROR/FATAL from NOTICE).

## CI

```
run_ci.ps1  ->  run_bootstrap_check.ps1
            ->  run_fixtures.ps1
            ->  run_integrity_all.ps1 -SkipFixtures
```

Linux/GitHub Actions: `run_qa.sh` (same scope).

## Optional

- `run_stress_all.ps1` — `04_Stress`
- `run_manual_module.ps1` — `05_Manual` (interactive menu if `-Module` omitted)

Exit code `1` when any script fails or emits `FAIL:` / `FATAL:`.
