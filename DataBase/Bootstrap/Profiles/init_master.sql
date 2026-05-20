-- =========================================================
-- BOOTSTRAP PROFILE — MASTER (core + MasterData + sanity)
-- =========================================================

\echo '>>> profile: init_master'

\i /docker-entrypoint-initdb.d/Profiles/init_core.sql
\i /docker-entrypoint-initdb.d/Loaders/11_MasterData.sql
\i /docker-entrypoint-initdb.d/Loaders/07_Sanity_Check.sql
