-- =========================================================
-- BOOTSTRAP PROFILE — CORE (DDL + services, no data, no sanity)
-- =========================================================
--
-- Shared base for init_demo and init_qa. Data tiers and sanity are
-- composed by those profiles.
-- =========================================================

\set ON_ERROR_STOP on

\i /docker-entrypoint-initdb.d/Loaders/00_Extensions.sql
\i /docker-entrypoint-initdb.d/Schema/00_Core/01_Types.sql
\i /docker-entrypoint-initdb.d/Loaders/01_Structure.sql
\i /docker-entrypoint-initdb.d/Loaders/02_ForeignKeys.sql
\i /docker-entrypoint-initdb.d/Loaders/03_Integrity.sql
\i /docker-entrypoint-initdb.d/Loaders/05_Comments.sql
\i /docker-entrypoint-initdb.d/Loaders/06_Services.sql
\i /docker-entrypoint-initdb.d/Loaders/08_Service_Comments.sql
