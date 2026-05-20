-- =========================================================
-- OFFICIAL DATA BOOTSTRAP (composite — Master + Demo)
-- =========================================================
--
-- DESCRIPTION
-- Official seed tiers for Docker default profile (init_demo).
-- Composes 11_MasterData.sql + 12_DemoData.sql without duplicating logic.
--
-- INVOKED BY
--   Bootstrap/Profiles/init_demo.sql
--   Bootstrap/init.sql (default)
-- =========================================================

\echo '========================================'
\echo 'OFFICIAL DATA BOOTSTRAP'
\echo '========================================'

\i /docker-entrypoint-initdb.d/Loaders/11_MasterData.sql
\i /docker-entrypoint-initdb.d/Loaders/12_DemoData.sql

\echo '========================================'
\echo 'OFFICIAL DATA BOOTSTRAP COMPLETE'
\echo '========================================'
