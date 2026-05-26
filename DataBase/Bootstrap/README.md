# Bootstrap — orchestration only

Docker runs `init.sql` → profile `init_demo` (see `docker-compose.yml`).

## Pipeline (init_demo)

```
init_core
  00_Extensions → 01_Types → 01_Structure → 02_FK → 03_Integrity
  → 05_Comments → 06_Services → 08_Service_Comments
11_MasterData
  00_Data_Cleanup (TRUNCATE) → 00_MasterData/*.sql (INSERT)
12_DemoData → 03_DemoData/*.sql (INSERT)
07_Sanity_Check
```

## Loaders (all in use)

| Loader | Target |
|--------|--------|
| `00_Extensions` | pg_cron, btree_gist |
| `01_Structure` | `Schema/*/00_Tables_Mod*` |
| `02_ForeignKeys` | `Schema/*/01_ForeignKeys_*` |
| `03_Integrity` | functions, triggers, indexes, views, procedures, jobs |
| `05_Comments` | `Comments/Schema/` |
| `06_Services` | `Services/` |
| `08_Service_Comments` | `Comments/Services/` |
| `07_Sanity_Check` | post-init smoke |
| `11_MasterData` | `00_Data_Cleanup` + `DataSeed/00_MasterData/` |
| `12_DemoData` | `DataSeed/03_DemoData/` |

## Profiles

| Profile / entry | Use |
|-----------------|-----|
| `init_core.sql` | Shared DDL + services base (composed by demo/qa) |
| `init_demo.sql` | **Default** — Master + Demo + sanity |
| `init_qa.sql` | **CI / automated QA** — Master + sanity, no Demo |
| `entrypoints/init_qa_entry.sql` | Mounted as `init.sql` by `docker-compose.qa.yml` |

## CI (init_qa)

```bash
docker compose -f docker-compose.yml -f docker-compose.qa.yml down -v
docker compose -f docker-compose.yml -f docker-compose.qa.yml up -d --build
cd DataBase/QA/runners && ./ci.ps1
```

## Reset (local demo)

```bash
docker compose down -v && docker compose up --build -d
```
