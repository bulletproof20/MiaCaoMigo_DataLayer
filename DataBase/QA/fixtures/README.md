# Fixtures (official QA context)

Data-only SQL. No `PASS:` / `FAIL:`.

## Layout

```
fixtures/
├── 00_Reset_QA_State.sql      # scoped DELETE (QA-* / 2099 appointments)
├── 01_Module1/01_Core_Context.sql
├── 02_Module2/01_Animals_Ownership.sql
├── 03_Module3/01_Commercial_Product.sql
├── 04_Module4/01_Appointment_Slots.sql
└── cleanup/
    └── 02_Reset_Module2_Animal1.sql
```

## Load

```powershell
cd DataBase/QA/runners
.\run_fixtures.ps1
```

## Prerequisite

**init_qa** (Master only). See `docker-compose.qa.yml`.

## Rules

| Rule | Detail |
|------|--------|
| Keys | `QA-ANI-*`, `QA-PRO-001`, `OMV-QA-PRIMARY` |
| Time | Mod4 uses `2099-*` slots |
| Scope | Never TRUNCATE Master catalogs |
| Isolation | Prefix `QA-%`; reset in `00_Reset_QA_State.sql` |
