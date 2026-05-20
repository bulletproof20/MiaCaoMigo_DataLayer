# Manual tests (`03_Manual`)

Human-driven **functional workflows** that chain real services, procedures, and views. Outputs are meant for visual inspection in psql or a SQL client.

## vs other layers

| Layer | Role |
|-------|------|
| **Queries/** | Reusable SELECTs and service call catalogs (reference / API exploration) |
| **01_Integrity/** | Automated PASS/FAIL rule checks |
| **02_Stress/** | Load, contention, throughput metrics |
| **03_Manual/** (here) | Coherent business flows + before/after state |

## Prerequisites

1. Full schema + services loaded (`Bootstrap/init.sql` or equivalent).
2. Test fixtures:

```powershell
cd DataBase\Tests\runners
.\run_test_data.ps1
```

3. Optional: `init_demo` for extra commercial catalog (Mod3 can also self-seed `INT-P001` in workflows).

## Layout

```
03_Manual/
├── README.md
├── 01_Module1/   Authentication, onboarding, attendance
├── 02_Module2/   Animal, ownership, delivery, concession
├── 03_Module3/   Procurement, stock, invoice, returns
└── 04_Module4/   Appointments, prescriptions, notifications
```

## Execution

Interactive runner (recommended):

```powershell
cd DataBase\Tests\runners
.\run_manual_module.ps1              # menu
.\run_manual_module.ps1 -Module 3 -Workflow 02_Invoice_And_Returns_Workflow.sql
```

Direct psql:

```powershell
Get-Content ..\03_Manual\01_Module1\01_Authentication_Session_Workflow.sql -Raw -Encoding UTF8 |
  docker exec -i miacaomigo-db psql -U postgres -d miacaomigo
```

## Conventions

- Each file = **one functional flow** (not a query dump).
- `MANUAL M*-*` notices mark steps; `SELECT` blocks show inspectable state.
- Uses CreationStress IDs where noted (`id_cli` 4, `id_ani` 3, `id_emp` 8, etc.).
- Not run from bootstrap, `run_integrity_all.ps1`, or `run_stress_all.ps1`.

## Reference SQL moved to Queries/

- `Queries/01_Module1/User_Creation/` — fn_create_* scenario matrix
- `Queries/01_Module1/Authentication/01_Login_Logout_Reference.sql`
- `Queries/02_Module2/01_Animal_Exploration.sql`

## Risks

- Workflows mutate data; re-run `run_test_data.ps1` or reset DB after heavy exploration.
- Some flows use isolated timestamps (`2099-*`) to avoid GiST overlap with fixtures.
