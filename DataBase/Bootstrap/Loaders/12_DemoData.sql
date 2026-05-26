-- =========================================================
-- DATA TIER LOADER — NARRATIVE DEMO DATA
-- =========================================================
-- SOURCE: 00_MiaCaoMigo_Engineering/01_Planning/01_UserStories
-- Replaces legacy 03_DemoData/0N_ModuleN_DemoData.sql files.
-- PREREQUISITE: 11_MasterData.sql in the same profile run.
-- INVOKED BY: init_demo only.
-- =========================================================

\echo '========================================'
\echo 'NARRATIVE DEMO DATA (launch simulation)'
\echo '========================================'

\set QUIET 1
set client_min_messages to warning;
set timezone to 'Europe/Lisbon';

\echo '>>> 01 users'
\i /docker-entrypoint-initdb.d/DataSeed/03_DemoData/01_Users.sql
\echo '>>> 02 employees'
\i /docker-entrypoint-initdb.d/DataSeed/03_DemoData/02_Employees.sql
\echo '>>> 03 profiles'
\i /docker-entrypoint-initdb.d/DataSeed/03_DemoData/03_Profiles.sql
\echo '>>> 05 schedules'
\i /docker-entrypoint-initdb.d/DataSeed/03_DemoData/05_Schedules.sql
\echo '>>> 06 attendance'
\i /docker-entrypoint-initdb.d/DataSeed/03_DemoData/06_Attendance.sql
\echo '>>> 07 absences'
\i /docker-entrypoint-initdb.d/DataSeed/03_DemoData/07_Absences.sql
\echo '>>> 08 customers'
\i /docker-entrypoint-initdb.d/DataSeed/03_DemoData/08_Customers.sql
\echo '>>> 09 external entities'
\i /docker-entrypoint-initdb.d/DataSeed/03_DemoData/09_ExternalEntities.sql
\echo '>>> 10 animals'
\i /docker-entrypoint-initdb.d/DataSeed/03_DemoData/10_Animals.sql
\echo '>>> 11 ownerships'
\i /docker-entrypoint-initdb.d/DataSeed/03_DemoData/11_Ownerships.sql
\echo '>>> 12 deliveries and adoptions'
\i /docker-entrypoint-initdb.d/DataSeed/03_DemoData/12_Deliveries_Adoptions.sql
\echo '>>> 13 products'
\i /docker-entrypoint-initdb.d/DataSeed/03_DemoData/13_Products.sql
\echo '>>> 14 commercial'
\i /docker-entrypoint-initdb.d/DataSeed/03_DemoData/14_Commercial.sql
\echo '>>> 15 appointments'
\i /docker-entrypoint-initdb.d/DataSeed/03_DemoData/15_Appointments.sql
\echo '>>> 16 prescriptions'
\i /docker-entrypoint-initdb.d/DataSeed/03_DemoData/16_Prescriptions.sql
\echo '>>> 17 notifications'
\i /docker-entrypoint-initdb.d/DataSeed/03_DemoData/17_Notifications.sql
\echo '>>> 18 audit'
\i /docker-entrypoint-initdb.d/DataSeed/03_DemoData/18_Audit.sql
\echo '>>> 99 validation'
\i /docker-entrypoint-initdb.d/DataSeed/03_DemoData/99_FinalValidation.sql

\set QUIET 0

\echo '========================================'
\echo 'NARRATIVE DEMO DATA COMPLETE'
\echo '========================================'
