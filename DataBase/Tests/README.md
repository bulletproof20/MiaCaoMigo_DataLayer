# MiaCaoMigo — Database Tests

Central home for **executable** validation. Datasets and fixtures live in `DataSeed/01_TestData/` only.

## Separation of concerns

| Layer | Path | Responsibility |
|-------|------|----------------|
| **DataSeed** | `01_TestData/`, `04_Loaders/03_TestData.sql` | Fixtures, stress datasets (no asserts) |
| **Bootstrap** | `Loaders/07_Sanity_Check.sql` | Post-init structural smoke (init pipeline) |
| **Tests** | This folder | Integrity, manual, stress runners, future CI |

## Categories

| Folder | Purpose |
|--------|---------|
| `00_Sanity/` | Optional extra smoke beyond init (future) |
| `01_Integrity/` | PASS/FAIL business rules (triggers, procedures, services) |
| `02_Stress/` | Load/contention stress (metrics); `runners/run_stress_all.ps1` |
| `03_Manual/` | Human workflows (services + procedures); `runners/run_manual_module.ps1` |
| `04_Development/` | Disposable experiments (not CI) |
| `05_Regression/` | Stable suites for future automation |
| `runners/` | PowerShell entry points |

## Integrity layout (`01_Integrity/`)

| Module | Scripts |
|--------|---------|
| `01_Module1/` | Email/NIF, login, clocking, absence, roles, schedule |
| `02_Module2/` | Ownership, breed, delivery, concession |
| `03_Module3/` | Stock, inactive product, returns, invoice total |
| `04_Module4/` | Scheduling, overlap, absence, lifecycle, prescription, notifications |

Run all: `.\runners\run_integrity_all.ps1` (after TestData; Mod3 needs DemoData from `init_demo`).

## Prerequisites

1. Apply full pipeline: `Bootstrap/init.sql` (Docker or manual).
2. Load test fixtures:

```bash
cd DataBase/DataSeed
psql -U postgres -d miacaomigo -v ON_ERROR_STOP=1 -f 04_Loaders/03_TestData.sql
```

Or: `Bootstrap/Profiles/init_test.sql` inside the container.

3. Run tests from `DataBase/Tests`:

```powershell
.\runners\run_integrity_all.ps1
```

## Manual workflows (`03_Manual/`)

After TestData load:

```powershell
.\runners\run_manual_module.ps1              # interactive menu
.\runners\run_manual_module.ps1 -Module 3 -Workflow 02_Invoice_And_Returns_Workflow.sql
```

Service validation matrices moved to `Queries/01_Module1/` (reference only).

## ID contracts

`DataSeed/01_TestData/00_Contracts/00_ID_CONTRACT.txt`

## Not in scope here

- `Queries/` — reference SQL only
- `Services/02_Validations.sql` — production helpers
- `DevelopmentData` / `DemoData` — non-QA tiers (unless testing demo explicitly)
