-- =========================================================
-- QUERIES — MODULE 1 — LOGIN / LOGOUT (reference scenarios)
-- =========================================================
-- TYPE:
--   Exploratory reference scenarios
--
-- PURPOSE:
--   Manual validation and behavioral exploration for login_user
--   and logout_user against deterministic QA session fixtures.
--
-- REQUIRES:
--   init_qa + QA fixtures (run_fixtures.ps1)
--
-- RELATED:
--   Services/01_Module1/01_Authentication/01_Login.sql
--   Services/01_Module1/01_Authentication/02_Logout.sql
--   QA/fixtures/01_Module1/01_Core_Context.sql
--   QA/01_Integrity/01_Module1/02_Login_Session_Rules.sql
--   Queries/01_Module1/01_Authentication.sql
-- =========================================================



--==============================
-- LOGIN TESTS
--==============================

-- login with non-existent email
-- context: no matching user_account
-- expected:
-- - login_success = false
-- - password_ok = false
-- - user_id is null

select *
  from login_user(
      'qa-manual-missing@qa.miacaomigo.pt',
      '$2b$12$fakepasswordhash000000000',
      '127.0.0.1'
  );


-- login with incorrect password (QA client fixture)
-- context: qa_client_active (goncalo.pratas.cstress@gmail.com)
-- expected:
-- - password_ok = false
-- - login_success = false

select *
  from login_user(
      'goncalo.pratas.cstress@gmail.com',
      'wrong_password_hash',
      '127.0.0.1'
  );


-- login client WITH active session
-- context: open login_record seeded above for portal email
-- expected:
-- - login_success = false
-- - has_active_session = true

select *
  from login_user(
      'goncalo.pratas.cstress@gmail.com',
      '$2b$12$cstress_cli_pure_u023',
      '127.0.0.1'
  );


-- login employee WITHOUT active session
-- context: QA registrar 20@ (fixture password)
-- expected:
-- - login_success = true

select *
  from login_user(
      '20@miacaomigo.pt',
      '$2b$12$cstress_registrar_emp001',
      '127.0.0.2'
  );


-- login employee WITH active session
-- context: QA fixture 12@ open session
-- expected:
-- - login_success = false
-- - has_active_session = true

select *
  from login_user(
      '12@miacaomigo.pt',
      '$2b$12$cstress_u12_active',
      '127.0.0.1'
  );


-- login inactive employee
-- context: qa-manual-inactive@miacaomigo.pt (dea_dat_emp set in setup)
-- expected:
-- - login_success = false
-- - account_active = false

select *
  from login_user(
      'qa-manual-inactive@miacaomigo.pt',
      '$2b$12$cstress_u12_active',
      '127.0.0.3'
  );


-- brute-force simulation (wrong passwords, same IP)
-- context: QA registrar target
-- expected: successive failures; inspect login_record via Queries/

select *
  from login_user(
      '20@miacaomigo.pt',
      'wrong_hash_1',
      '192.168.50.10'
  );

select *
  from login_user(
      '20@miacaomigo.pt',
      'wrong_hash_2',
      '192.168.50.10'
  );

select *
  from login_user(
      '20@miacaomigo.pt',
      'wrong_hash_3',
      '192.168.50.10'
  );



