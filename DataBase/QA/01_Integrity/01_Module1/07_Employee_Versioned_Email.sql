-- =========================================================
-- INTEGRITY — MODULE 1 — VERSIONED ema_emp + RENEW + AUTH
-- =========================================================
-- TYPE:     01_Integrity
-- REQUIRES: init_qa + fixtures/seed/m1_core_context.sql
--           Migration 001_employee_ema_emp_active_uniqueness.sql
--           Updated fn_get_user_by_email / fn_validate_password
-- RULE:     uq_employee_ema_emp_active; sp_renew_employee_record
-- CONTRACT: qa_emp_clockable_id(), qa_registrar_emp_id(), qa_registrar_emp_email()
-- =========================================================

-- TEST 01 — sp_renew keeps ema_emp on old and new versions
do $$
declare
    v_source int;
    v_reg int;
    v_new int;
    v_id_usr int;
    v_email varchar;
    v_rows int;
begin
    v_source := qa_emp_clockable_id();
    v_reg := qa_registrar_emp_id();

    select e.id_usr, e.ema_emp
    into v_id_usr, v_email
    from employee e
    where e.id_emp = v_source;

    call sp_renew_employee_record(v_source, v_reg, v_new);

    select count(*)::int
    into v_rows
    from employee e
    where e.ema_emp = v_email;

    if v_rows < 2 then
        raise exception 'FAIL: expected at least 2 employee rows with email %', v_email;
    end if;

    if not exists (
        select 1
        from employee e
        where e.id_emp = v_new
          and e.ema_emp = v_email
          and e.dea_dat_emp is null
    ) then
        raise exception 'FAIL: renewed row % should be active with email %', v_new, v_email;
    end if;

    if not exists (
        select 1
        from employee e
        where e.id_emp = v_source
          and e.dea_dat_emp is not null
    ) then
        raise exception 'FAIL: source row % should be inactive after renew', v_source;
    end if;

    raise notice 'PASS: sp_renew preserves ema_emp across versions (new id_emp=%)', v_new;
exception
    when others then
        raise notice 'FAIL: renew ema_emp test — %', sqlerrm;
end;
$$;

-- TEST 02 — duplicate active ema_emp for different users blocked
do $$
declare
    v_other_usr int;
begin
    select u.id_usr
    into v_other_usr
    from user_account u
    where u.ema_usr = 'qa.clockable.user@gmail.com'
    limit 1;

    insert into employee (
        id_usr,
        pho_emp,
        ema_emp,
        pas_emp,
        reg_dat_emp,
        aut_reg_emp
    )
    values (
        v_other_usr,
        '+351910000099',
        qa_registrar_emp_email(),
        '$2b$12$integrity.duplicate.active.ema',
        current_timestamp,
        qa_registrar_emp_id()
    );

    raise exception 'FAIL: duplicate active ema_emp should be blocked';
exception
    when unique_violation then
        raise notice 'PASS: duplicate active ema_emp blocked — %', sqlerrm;
    when others then
        raise notice 'FAIL: unexpected error on duplicate active ema_emp — %', sqlerrm;
end;
$$;

-- TEST 03 — fn_get_user_by_email resolves active employment only
do $$
declare
    v_id_usr int;
begin
    v_id_usr := fn_get_user_by_email(qa_registrar_emp_email());

    if v_id_usr is null then
        raise exception 'FAIL: fn_get_user_by_email returned null for active registrar';
    end if;

    raise notice 'PASS: fn_get_user_by_email returns id_usr=% for registrar', v_id_usr;
exception
    when others then
        raise notice 'FAIL: fn_get_user_by_email — %', sqlerrm;
end;
$$;

-- TEST 04 — fn_validate_password uses active employee hash
do $$
declare
    v_ok boolean;
begin
    v_ok := fn_validate_password(
        qa_registrar_emp_email(),
        '$2b$12$cstress_registrar_emp001'
    );

    if v_ok is true then
        raise notice 'PASS: fn_validate_password matches active registrar hash';
    else
        raise exception 'FAIL: fn_validate_password should succeed for registrar';
    end if;
exception
    when others then
        raise notice 'FAIL: fn_validate_password — %', sqlerrm;
end;
$$;

-- TEST 05 — login still succeeds for active corporate email
do $$
declare
    v_success boolean;
begin
    select login_success
    into v_success
    from svc_auth_login(
        qa_registrar_emp_email(),
        '$2b$12$cstress_registrar_emp001',
        '127.0.0.3'::inet
    );

    if v_success is true then
        raise notice 'PASS: svc_auth_login succeeds after ema_emp policy change';
    else
        raise exception 'FAIL: svc_auth_login should succeed for registrar';
    end if;
exception
    when others then
        raise notice 'FAIL: svc_auth_login — %', sqlerrm;
end;
$$;
