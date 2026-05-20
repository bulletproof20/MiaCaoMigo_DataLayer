# MiaCaoMigo — Stress tests (`02_Stress/`)

Executable **load and contention** scenarios. Not business-rule PASS/FAIL (see `01_Integrity/`).

## Purpose

| Stress validates | Integrity validates |
|------------------|---------------------|
| Throughput, duration, volume | Single-rule PASS/FAIL |
| Serial contention / race patterns | Deterministic fixtures |
| Stock, FIFO, EXCLUDE under load | One failure mode per script |
| Observable metrics (`NOTICE`) | Regression contracts |

## Prerequisites

1. Full bootstrap: `Bootstrap/init.sql` (schema + services).
2. **Recommended:** `runners/run_test_data.ps1` (CreationStress + Mod2/4 fixtures).
3. **Mod3 commercial stress:** `00_Setup/01_Commercial_Stress_Fixture.sql` (run automatically by `run_stress_all.ps1` before Mod3 scripts).

**Not** part of Docker init, `run_integrity_all.ps1`, or CI by default.

## Layout

```
02_Stress/
├── README.md
├── 00_Setup/
│   └── 01_Commercial_Stress_Fixture.sql   # STRESS-M3 product + FIFO batches
├── 01_Module1/
│   ├── 01_Login_Concurrency.sql
│   └── 02_Clocking_Concurrency.sql
├── 02_Module2/
│   └── 01_Concurrent_Adoption.sql
├── 03_Module3/                            # highest priority
│   ├── 01_Concurrent_Sales.sql
│   ├── 02_High_Volume_Invoice_Lines.sql
│   ├── 03_FIFO_Consumption.sql
│   └── 04_Return_Storm.sql
└── 04_Module4/
    ├── 01_Concurrent_Appointment_Booking.sql
    └── 02_Appointment_Lifecycle_Load.sql
```

## Data tiers

| Source | Role |
|--------|------|
| `DataSeed/01_TestData/02_CreationStress.sql` | Mod1 stress identities (via `03_TestData.sql`) |
| `DataSeed/01_TestData/01_Module3_VolumeStress.sql` | **Isolated** bulk commercial seed (do not mix with default QA) |
| `02_Stress/00_Setup/` | Minimal idempotent commercial fixture for Mod3 stress only |

Fixtures and assertions are **never** mixed in the same file.

## Execution

```powershell
cd DataBase/Tests/runners

# Optional: reload QA fixtures first
.\run_test_data.ps1

# Stress suite (Mod3 setup runs before each commercial script)
.\run_stress_all.ps1

# Single module
.\run_stress_all.ps1 -Module 3
```

Read `NOTICE` lines prefixed with `STRESS M*-*` for metrics.

## Concurrency model

Scripts use **controlled loops** inside a single `psql` session (serial transactions). That simulates contention on shared rows and measures guard behaviour.

True OS-level parallelism requires **multiple `psql` clients** against the same database (documented for future hardening). The runner does not spawn parallel processes by default.

## Risks and cleanup

| Risk | Mitigation |
|------|------------|
| Large `invoice` / `appointment` growth | Run on dev DB; reseed with `docker compose down -v` |
| `STRESS-M3` product pollution | Setup script deletes `STRESS-M3%` invoices before re-run |
| Mod1 login noise | Uses `12@miacaomigo.pt` session from CreationStress |
| Mod2 animal 5 state | Adoption stress resets animal 5 to `Interno` |

After a full stress run, prefer `run_test_data.ps1` or fresh volume before integrity QA.

## Architecture touchpoints (stress targets)

| Module | Mechanism under load |
|--------|----------------------|
| Mod3 | `fn_check_stock_before_sale`, `fn_stock_after_sale` (FIFO), `fn_update_invoice_total`, `fn_return_restock` |
| Mod4 | `ex_appointment_vet_overlap`, `sp_start/end_appointment`, `ck_appointment_flow` |
| Mod1 | `login_user`, `uq_login_single_active_session_email`, `fn_clock_employee`, `uq_clock_in_active_per_employee` |
| Mod2 | `sp_assign_ownership`, `trg_prevent_duplicate_active_ownership`, `uq_ownership_active_per_animal` |

## Related

- Integrity: `01_Integrity/` + `run_integrity_all.ps1`
- Full QA: `run_full_qa.ps1` (test data + integrity only)
