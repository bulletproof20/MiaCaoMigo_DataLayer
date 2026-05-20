-- =========================================================
-- DATA TIER LOADER — DEMO DATA (Bootstrap delegate)
-- =========================================================
--
-- DESCRIPTION
-- Appends demo narrative on top of MasterData.
-- Delegates to DataSeed/04_Loaders/01_DemoData.sql.
--
-- PREREQUISITE
--   11_MasterData.sql (or 00_MasterData.sql via DataSeed) already applied.
--
-- REQUIRES MOUNT
--   ./DataBase/DataSeed → /docker-entrypoint-initdb.d/DataSeed
-- =========================================================

\echo '>>> data tier: demo data'

\cd /docker-entrypoint-initdb.d/DataSeed
\i 04_Loaders/01_DemoData.sql
