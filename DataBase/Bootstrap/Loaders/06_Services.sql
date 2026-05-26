-- =========================================================

-- SERVICES LAYER LOADER

-- =========================================================

--

-- DESCRIPTION

-- Application domain layer: business workflows (sp_*) and public API (svc_*).

-- Loads after schema integrity (tables, FKs, vw_*, technical sp_*, triggers, jobs).

--

-- ARCHITECTURE

--   svc_*  — public API (M1: 99_Public_API/; M2–M4: 99_Public_API.sql)

--   sp_*   — business workflows (Services/01_Module1; not Schema)

--   fn_*   — internal helpers (normalization, validation, identity, fn_pick_*)

--   vw_*   — read models (Schema; consumed by sp_* / fn_*)

--

-- See DataBase/Services/README.md

--

-- LOAD ORDER (Module 1)

--   fn core → fn_pick helpers → auth helpers → sp workflows → svc public API

-- =========================================================



\echo '>>> loading services layer (00_Core)'



\i /docker-entrypoint-initdb.d/Services/00_Core/00_Normalization_Text.sql
\i /docker-entrypoint-initdb.d/Services/00_Core/01_Normalization_Identity.sql

\echo '>>> loading services layer (01_Module1)'



\echo '--- module 1 | query helpers (fn_pick_*)'

\i /docker-entrypoint-initdb.d/Services/01_Module1/05_Query_Helpers/00_Pick_Helpers.sql



\i /docker-entrypoint-initdb.d/Services/01_Module1/00_Core_Mod1/01_Identity.sql

\i /docker-entrypoint-initdb.d/Services/01_Module1/00_Core_Mod1/02_Validations.sql



\i /docker-entrypoint-initdb.d/Services/01_Module1/01_Authentication/00_Common_Auth.sql

\i /docker-entrypoint-initdb.d/Services/01_Module1/01_Authentication/01_Login.sql

\i /docker-entrypoint-initdb.d/Services/01_Module1/01_Authentication/02_Logout.sql



\i /docker-entrypoint-initdb.d/Services/01_Module1/02_User_Creation/00_UserCreation.sql

\i /docker-entrypoint-initdb.d/Services/01_Module1/02_User_Creation/01_NewClient.sql

\i /docker-entrypoint-initdb.d/Services/01_Module1/02_User_Creation/02_NewEmployee.sql

\i /docker-entrypoint-initdb.d/Services/01_Module1/02_User_Creation/03_NewAssistant.sql

\i /docker-entrypoint-initdb.d/Services/01_Module1/02_User_Creation/04_NewVeterinarian.sql



\i /docker-entrypoint-initdb.d/Services/01_Module1/03_Role_Change/00_Renew_Employee_Record.sql

\i /docker-entrypoint-initdb.d/Services/01_Module1/03_Role_Change/01_Employee_Veterinarian.sql

\i /docker-entrypoint-initdb.d/Services/01_Module1/03_Role_Change/02_Employee_Assistant.sql

\i /docker-entrypoint-initdb.d/Services/01_Module1/03_Role_Change/03_To_Employee.sql



\i /docker-entrypoint-initdb.d/Services/01_Module1/04_Attendance_Management/01_TimeTracking.sql

\i /docker-entrypoint-initdb.d/Services/01_Module1/04_Attendance_Management/02_ScheduleAssignment.sql



\echo '--- module 1 | public API (svc_*)'

\i /docker-entrypoint-initdb.d/Services/01_Module1/99_Public_API/01_Authentication_API.sql

\i /docker-entrypoint-initdb.d/Services/01_Module1/99_Public_API/02_User_Creation_API.sql

\i /docker-entrypoint-initdb.d/Services/01_Module1/99_Public_API/03_Role_Change_API.sql

\i /docker-entrypoint-initdb.d/Services/01_Module1/99_Public_API/04_Attendance_API.sql



\echo '>>> loading services layer (02_Module2)'



\echo '--- module 2 | public API (svc_*)'

\i /docker-entrypoint-initdb.d/Services/02_Module2/99_Public_API.sql



\echo '>>> loading services layer (03_Module3)'



\echo '--- module 3 | public API (svc_*)'

\i /docker-entrypoint-initdb.d/Services/03_Module3/99_Public_API.sql



\echo '>>> loading services layer (04_Module4)'



\echo '--- module 4 | public API (svc_*)'

\i /docker-entrypoint-initdb.d/Services/04_Module4/99_Public_API.sql

