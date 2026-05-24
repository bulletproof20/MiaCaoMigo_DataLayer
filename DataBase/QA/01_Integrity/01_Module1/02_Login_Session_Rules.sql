-- =========================================================
-- INTEGRITY — MODULE 1 — LOGIN / SESSION RULES
-- =========================================================
-- TYPE:     01_Integrity
-- REQUIRES: init_qa + fixtures/01_Module1/01_Core_Context.sql
-- RULE:     svc_auth_login — single active session; svc_auth_logout semantics
-- FIXTURES: qa_login_session_emp_email (open session), qa_registrar_emp_email
-- CONTRACT: qa_login_session_emp_email(), qa_registrar_emp_email()
-- =========================================================
-- expected:
-- - login blocked when active session exists
-- - logout returns false without active session
-- - login succeeds when no active session
-- =========================================================

-- TEST 01 — login blocked with active session (id_emp 12 open session in stress)
do $$
declare
    v_success boolean;
begin
    select login_success
      into v_success
      from svc_auth_login(
          qa_login_session_emp_email(),
          '$2b$12$cstress_u12_active',
          '127.0.0.1'::inet
      );

    if v_success is false then
        raise notice 'PASS: login blocked when active session exists';
    else
        raise notice 'FAIL: login should not succeed with active session';
    end if;
exception
    when others then
        raise notice 'FAIL: login active-session test — %', sqlerrm;
end;
$$;

-- TEST 02 — logout without session
do $$
declare
    v_ok boolean;
begin
    v_ok := svc_auth_logout('integrity.no.session@pessoal.com');

    if v_ok is false then
        raise notice 'PASS: logout without active session returns false';
    else
        raise notice 'FAIL: logout should return false when no session';
    end if;
exception
    when others then
        raise notice 'FAIL: logout without session — %', sqlerrm;
end;
$$;

-- TEST 03 — successful login when no open session
do $$
declare
    v_success boolean;
begin
    select login_success
      into v_success
      from svc_auth_login(
          qa_registrar_emp_email(),
          '$2b$12$cstress_registrar_emp001',
          '127.0.0.2'::inet
      );

    if v_success is true then
        raise notice 'PASS: login succeeds without prior active session';
    else
        raise notice 'FAIL: login should succeed for active registrar';
    end if;
exception
    when others then
        raise notice 'FAIL: login success test — %', sqlerrm;
end;
$$;

-- Re-run safety: close registrar session opened by test 03
update login_record
   set sou_tim_log = current_timestamp
 where ema_log = qa_registrar_emp_email()
   and sou_tim_log is null;
