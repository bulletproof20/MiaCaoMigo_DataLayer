# Services layer — application domain & public API

The `Services/` directory is the **application domain layer**: business workflows,
orchestration, and the **official public database API** (`svc_*`).

## Layer separation

| Layer | Responsibility |
|-------|----------------|
| **Schema** | Tables, `vw_*`, technical functions, triggers, **technical** `sp_*` (jobs/hygiene) |
| **Services** | Business `sp_*` workflows, internal `fn_*` (incl. `fn_pick_*`), public `svc_*` API |
| **Queries** | Manual inspection SQL (not loaded by bootstrap) |

## Reference flow (Module 1)

```
Application / API
       │
       ▼
    svc_*          ← Services/01_Module1/99_Public_API/
       │
       ▼
    sp_*           ← Services/01_Module1/* (business workflows)
       │
       ├── fn_*   ← Services/00_Core, 00_Core_Mod1, 05_Query_Helpers/
       └── vw_*   ← Schema/07_Views_Mod1.sql
```

Modules 2–4: all `svc_*` in a single `99_Public_API.sql` over Schema `sp_*` / `vw_*`.

## Prefix contract

| Prefix | Where | Callable by API? |
|--------|-------|------------------|
| **`svc_*`** | `99_Public_API/` (M1) or `99_Public_API.sql` (M2–M4) | **Yes** — sole public contract |
| **`sp_*`** | Services (M1 workflows); Schema (technical only) | No |
| **`fn_*`** | Services | No — internal helpers |
| **`vw_*`** | Schema | No — via `sp_*` / `fn_*` / `svc_*` |

## Module 1 layout

```
Services/01_Module1/
├── 00_Core_Mod1/           fn_* identity & validation
├── 01_Authentication/      fn session helpers + sp_auth_*
├── 02_User_Creation/       fn building blocks + sp_create_*
├── 03_Role_Change/         sp_renew_* + sp_promote_* / sp_demote_*
├── 04_Attendance_Management/  sp_clock_* / sp_replicate_*
├── 05_Query_Helpers/       fn_pick_* ranking helpers
└── 99_Public_API/          svc_* by domain (official entry points)
```

**Schema M1 technical procedures:** `jpr_auto_close_clock_in_midnight`, `jpr_auto_cancel_expired_absences`

## Modules 2–4 layout

```
Services/02_Module2/99_Public_API.sql   (7 svc_* — animals)
Services/03_Module3/99_Public_API.sql   (5 svc_* — commercial)
Services/04_Module4/99_Public_API.sql   (5 svc_* — appointments)
```

No internal `sp_*` / `fn_*` in Services for M2–M4; complexity stays in Schema.

Load order: `Bootstrap/Loaders/06_Services.sql`

## Module 1 — public `svc_*` map

| svc_* | Business workflow |
|-------|-------------------|
| `svc_auth_login` | `sp_auth_login` |
| `svc_auth_logout` | `sp_auth_logout` |
| `svc_create_client` | `sp_create_client` |
| `svc_create_employee` | `sp_create_employee` |
| `svc_create_assistant` | `sp_create_assistant` |
| `svc_create_veterinarian` | `sp_create_veterinarian` |
| `svc_promote_to_veterinarian` | `sp_promote_to_veterinarian` |
| `svc_promote_to_assistant` | `sp_promote_to_assistant` |
| `svc_demote_to_general_employee` | `sp_demote_to_general_employee` |
| `svc_clock_toggle` | `sp_clock_toggle` |
| `svc_replicate_schedule` | `sp_replicate_schedule` |
