# Fixtures (official QA context)

Data-only SQL. No `PASS:` / `FAIL:`.

## Layout

```
fixtures/
├── reset/                         # cleanup / baseline restore
│   ├── global_qa_state.sql        # preflight DELETE (QA-* / 2099-*)
│   ├── m1_clocking_absence.sql      # post-test M1 residue
│   └── m2_animal1_ownership.sql   # targeted M2 animal restore
└── seed/                          # deterministic QA datasets
    ├── m1_core_context.sql
    ├── m2_animals_ownership.sql
    ├── m3_commercial_product.sql
    ├── m4_appointment_slots.sql
    └── m3_stress_commercial.sql   # optional (-IncludeStress)
```

## Load

```powershell
cd DataBase/QA/runners
.\stages/fixtures.ps1
```

Optional stress: `.\stages/fixtures.ps1 -IncludeStress`

## Prerequisite

**init_qa** (Master only). See `docker-compose.qa.yml`.

## Rules

| Rule | Detail |
|------|--------|
| Keys | `QA-ANI-001..005`, `QA-PRO-001`, `OMV-QA-PRIMARY` |
| Time | Mod4 uses `2099-*` slots |
| Scope | Never TRUNCATE Master catalogs |
| Isolation | Prefix `QA-%`; global reset in `reset/global_qa_state.sql` |
| Idempotency | Resolve `user_account` by `ema_usr` before employee/role inserts |
