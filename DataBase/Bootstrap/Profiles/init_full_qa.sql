-- =========================================================
-- BOOTSTRAP PROFILE — FULL QA (test fixtures + manual test hint)
-- =========================================================
--
-- USE FOR
--   QA environment seed. SQL init loads TestData only.
--   Run integrity scripts after DB is up:
--     cd DataBase/Tests/runners
--     .\run_integrity_all.ps1
-- =========================================================

\echo '>>> profile: init_full_qa'

\i /docker-entrypoint-initdb.d/Profiles/init_test.sql

\echo '>>> next step (host): Tests/runners/run_integrity_all.ps1'
