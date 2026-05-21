-- =========================================================
-- MIACAOMIGO — QA / CI DATABASE INITIALIZATION
-- =========================================================
-- Mount as /docker-entrypoint-initdb.d/init.sql (see docker-compose.qa.yml).
-- =========================================================

\echo '========================================'
\echo 'MIACAOMIGO DATABASE INITIALIZATION (QA)'
\echo '========================================'

\set ON_ERROR_STOP on
\set QUIET 1
set client_min_messages to warning;

\echo '>>> setting timezone to Europe/Lisbon'
SET timezone TO 'Europe/Lisbon';

\i /docker-entrypoint-initdb.d/Profiles/init_qa.sql

\set QUIET 0

\echo '========================================'
\echo 'INITIALIZATION COMPLETE (init_qa)'
\echo '========================================'
