-- =========================================================
-- BOOTSTRAP PROFILE — TEST (alias for QA / CI)
-- =========================================================

\echo '>>> profile: init_test (alias init_qa)'

\i /docker-entrypoint-initdb.d/Profiles/init_qa.sql
