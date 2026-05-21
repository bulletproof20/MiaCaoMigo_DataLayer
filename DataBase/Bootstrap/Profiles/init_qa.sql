-- =========================================================
-- BOOTSTRAP PROFILE — QA (core + MasterData + sanity)
-- =========================================================
-- Master-only database for automated QA / CI regression.
-- DemoData is not loaded. Operational richness for demos: init_demo.
-- =========================================================

\echo '>>> profile: init_qa'

\i /docker-entrypoint-initdb.d/Profiles/init_core.sql
\i /docker-entrypoint-initdb.d/Loaders/11_MasterData.sql
\i /docker-entrypoint-initdb.d/Loaders/07_Sanity_Check.sql
