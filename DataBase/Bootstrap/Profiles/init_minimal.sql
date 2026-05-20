-- =========================================================
-- BOOTSTRAP PROFILE — MINIMAL (core + structural sanity, no seed data)
-- =========================================================

\echo '>>> profile: init_minimal'

\i /docker-entrypoint-initdb.d/Profiles/init_core.sql
\i /docker-entrypoint-initdb.d/Loaders/07_Sanity_Check.sql
