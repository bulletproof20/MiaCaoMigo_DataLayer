-- =========================================================
-- DATA TIER LOADER — TEST DATA (Bootstrap delegate, manual / QA)
-- =========================================================
--
-- DESCRIPTION
-- Loads QA fixture chain (CreationStress + module fixtures).
-- Delegates to DataSeed/04_Loaders/03_TestData.sql.
--
-- NOT part of Docker default init (use Profiles/init_test.sql or manual run).
--
-- PREREQUISITE
--   Schema + Services; typically after 11_MasterData.sql.
--
-- AFTER LOAD
--   DataBase/Tests/runners/run_integrity_all.ps1
-- =========================================================

\echo '>>> data tier: test data (fixtures)'

\cd /docker-entrypoint-initdb.d/DataSeed
\i 04_Loaders/03_TestData.sql
