-- =========================================================
-- MIACAOMIGO — DATABASE INITIALIZATION (Bootstrap/init.sql)
-- =========================================================
--
-- DESCRIPTION
-- Docker/CI entry point. Orchestration lives under Bootstrap/;
-- structural DDL lives under Schema/; data tiers under DataSeed/.
--
-- DEFAULT PROFILE (docker-compose.yml)
--   Profiles/init_demo.sql — core + MasterData + DemoData + sanity
--
-- QA PROFILE (docker-compose.qa.yml → entrypoints/init_qa_entry.sql)
--   Profiles/init_qa.sql — core + MasterData + sanity (no DemoData)
--   Then run QA/runners/run_ci.ps1 on the host.
--
-- SHARED BASE (not a standalone Docker profile)
--   Profiles/init_core.sql — DDL + services + comments
--
-- MOUNTS (docker-compose.yml)
--   DataBase/Bootstrap  → /docker-entrypoint-initdb.d
--   DataBase/Schema     → /docker-entrypoint-initdb.d/Schema
--   DataBase/Comments   → /docker-entrypoint-initdb.d/Comments
--   DataBase/Services   → /docker-entrypoint-initdb.d/Services
--   DataBase/DataSeed   → /docker-entrypoint-initdb.d/DataSeed
-- =========================================================

\echo '========================================'
\echo 'MIACAOMIGO DATABASE INITIALIZATION'
\echo '========================================'

\set ON_ERROR_STOP on
\set QUIET 1
set client_min_messages to warning;

\echo '>>> setting timezone to Europe/Lisbon'
SET timezone TO 'Europe/Lisbon';

\i /docker-entrypoint-initdb.d/Profiles/init_demo.sql

\set QUIET 0

\echo '========================================'
\echo 'INITIALIZATION COMPLETE'
\echo '========================================'
