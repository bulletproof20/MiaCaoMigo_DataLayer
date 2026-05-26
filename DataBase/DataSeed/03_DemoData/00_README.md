# Narrative DemoData — Launch Simulation (May–June 2026)

**Source of truth:** `00_MiaCaoMigo_Engineering/01_Planning/01_UserStories`

This tier replaces the legacy module-based demo seed (`01_Module1_DemoData.sql`, etc.).  
Every row maps to a story event in `01_Chronology/TIMELINE_LAUNCH_2026.md`.

## Simulation anchor

| Constant | Value |
|---|---|
| Timezone | `Europe/Lisbon` |
| Narrative “now” | **2026-06-08 12:00** (loads future appointments on 10 & 12 Jun) |
| ID prefix | `MCM-BRG-2026-*` animals; emails `*.dev@gmail.com` |

## Stable identifiers (post-load)

See header comments in each `*.sql` file. Bootstrap retains `id_usr=1`, `id_emp=1`.

## Load order

Executed by `Bootstrap/Loaders/12_DemoData.sql` (numeric filename order).

## Procedures used

- `sp_record_delivery`, `sp_assign_ownership`, `sp_process_concession`
- `sp_create_appointment` pattern via controlled inserts (historical dates)
- `sp_receive_purchase` for supplier receipt (19 May)

Historical appointments disable `trg_block_past_appointments` during insert.

Rows constrained by `<= current_timestamp` (client inactivation, login audit) use
`least(canonical_story_timestamp, current_timestamp - 1s)` so `init_demo` succeeds
before the narrative anchor (2026-06-08); after that date, canonical story times apply.
