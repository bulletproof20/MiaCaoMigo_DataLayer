-- =========================================================
-- BOOTSTRAP PROFILE — FULL QA
-- =========================================================
-- SQL init: Master only (init_qa). After container is up:
--   cd DataBase/QA/runners
--   .\run_ci.ps1
-- =========================================================

\echo '>>> profile: init_full_qa'

\i /docker-entrypoint-initdb.d/Profiles/init_qa.sql

\echo '>>> next step (host): QA/runners/run_ci.ps1'
