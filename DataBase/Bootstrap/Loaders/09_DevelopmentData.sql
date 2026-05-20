-- =========================================================
-- OPTIONAL DATA TIER — DEVELOPMENT (Bootstrap delegate)
-- =========================================================
--
-- DESCRIPTION
-- Thin orchestration entry that loads DataSeed/04_Loaders/02_DevelopmentData.sql
-- when explicitly enabled. Keeps seed paths out of init.sql body.
--
-- NOT part of Bootstrap/init.sql (official bootstrap is 10_Official_Bootstrap.sql).
--
-- ENABLE (manual)
--   psql -v MIACAOMIGO_SEED_DEV=1 -f Bootstrap/Loaders/09_DevelopmentData.sql
--   or: psql -f DataSeed/04_Loaders/02_DevelopmentData.sql
--
-- PREREQUISITE
--   MasterData loaded (00_MasterData.sql or zzz_dev_bootstrap.sql step 1)
--   Schema + Services pipeline complete
--
-- REQUIRES MOUNT
--   ./DataBase/DataSeed → /docker-entrypoint-initdb.d/DataSeed
-- =========================================================

\echo '>>> optional data tier: development'

\if :{?MIACAOMIGO_SEED_DEV}
\echo '--- MIACAOMIGO_SEED_DEV is set — loading development data'
\i /docker-entrypoint-initdb.d/DataSeed/04_Loaders/02_DevelopmentData.sql
\else
\echo '--- development data skipped (set MIACAOMIGO_SEED_DEV=1 or use docker-compose.dev.yml)'
\endif
