-- =========================================================
-- BOOTSTRAP PROFILE — DEMO (official Docker default)
-- =========================================================
--
-- Order preserved from legacy Schema/init.sql:
--   core → official bootstrap (master + demo) → sanity
-- =========================================================

\echo '>>> profile: init_demo'

\i /docker-entrypoint-initdb.d/Profiles/init_core.sql
\i /docker-entrypoint-initdb.d/Loaders/10_Official_Bootstrap.sql
\i /docker-entrypoint-initdb.d/Loaders/07_Sanity_Check.sql
