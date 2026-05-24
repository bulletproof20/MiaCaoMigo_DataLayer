# Services layer — application domain & public API

The `Services/` directory is the **application domain layer**: business workflows,
orchestration, and the **official public database API** (`svc_*`).

## Layer separation

| Layer | Responsibility |
|-------|----------------|
| **Schema** | Tables, `vw_*`, technical functions, triggers, **technical** `sp_*` (jobs/hygiene) |
| **Services** | Business `sp_*` workflows, internal `fn_*`, public `svc_*` API |
| **Queries** | Read/ranking helpers (`fn_pick_*`) consumed by Services |

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
       ├── fn_*   ← Services/00_Core, 00_Core_Mod1, Queries/
       └── vw_*   ← Schema/07_Views_Mod1.sql
```

Module 2–4: `svc_*` over Schema `sp_*` / `vw_*` where applicable.

## Prefix contract

| Prefix | Where | Callable by API? |
|--------|-------|------------------|
| **`svc_*`** | `99_Public_API/` (M1) | **Yes** — sole public contract |
| **`sp_*`** | Services (M1 workflows); Schema (technical only) | No |
| **`fn_*`** | Services / Queries | No — internal helpers |
| **`vw_*`** | Schema | No — via `sp_*` / `fn_*` |

## Module 1 layout

```
Services/01_Module1/
├── 00_Core_Mod1/           fn_* identity & validation
├── 01_Authentication/      fn session helpers + sp_auth_*
├── 02_User_Creation/       fn building blocks + sp_create_*
├── 03_Role_Change/         sp_renew_* + sp_promote_* / sp_demote_*
├── 04_Attendance_Management/  sp_clock_* / sp_replicate_*
└── 99_Public_API/          svc_* by domain (official entry points)
```

**Schema M1 technical procedures:** `sp_auto_close_clock_in_midnight`, `sp_auto_cancel_expired_absences`

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
