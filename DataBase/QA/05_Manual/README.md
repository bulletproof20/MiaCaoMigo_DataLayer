# Manual QA (non-CI)

Exploratory reference SQL for demonstrations and local validation. **Not** loaded by Docker init and **not** invoked by `ci.ps1`.

Run with `psql` (or your client) against a running database. Prerequisites are stated in each file header (`init_demo` or `init_qa` + fixtures).

## Layout

```
05_Manual/
└── 01_Module1/
    ├── Authentication/     # login / logout reference
    └── User_Creation/      # client, employee, assistant, veterinarian
```

For automated rule checks use `01_Integrity/` via `runners/ci.ps1`.
