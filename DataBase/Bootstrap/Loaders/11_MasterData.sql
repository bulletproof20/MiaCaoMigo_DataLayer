-- =========================================================
-- DATA TIER LOADER — MASTER DATA (Bootstrap delegate)
-- =========================================================
--
-- DESCRIPTION
-- Thin orchestration entry for the MasterData tier.
-- Delegates to DataSeed/04_Loaders/00_MasterData.sql (TRUNCATE + invariants).
--
-- PREREQUISITE
--   Schema + Services pipeline complete (Loaders 00–08).
--
-- REQUIRES MOUNT
--   ./DataBase/DataSeed → /docker-entrypoint-initdb.d/DataSeed
--
-- NOT FOR
--   TestData (13_TestData.sql) or DevelopmentData (09_DevelopmentData.sql)
-- =========================================================

\echo '>>> data tier: master data'

\cd /docker-entrypoint-initdb.d/DataSeed
\i 04_Loaders/00_MasterData.sql
