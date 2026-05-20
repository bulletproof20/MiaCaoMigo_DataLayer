-- =========================================================
-- BOOTSTRAP PROFILE — TEST (core + master + test fixtures + sanity)
-- =========================================================

\echo '>>> profile: init_test'

\i /docker-entrypoint-initdb.d/Profiles/init_core.sql
\i /docker-entrypoint-initdb.d/Loaders/11_MasterData.sql
\i /docker-entrypoint-initdb.d/Loaders/13_TestData.sql
\i /docker-entrypoint-initdb.d/Loaders/07_Sanity_Check.sql
