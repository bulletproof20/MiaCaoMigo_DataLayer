-- =========================================================
-- NEW EMPLOYEE (MODULE 1 — USER CREATION)
-- FILE: Services/01_Module1/02_User_Creation/02_NewEmployee.sql
-- =========================================================
--
-- PURPOSE
-- Create an employee row with corporate email generation and optional
-- reuse of an existing user_account identity.
--
-- DEPENDENCIES
--   - Services/01_Module1/02_User_Creation/00_UserCreation.sql (fn_create_user_account)
--   - Services/01_Module1/00_Core_Mod1/01_Identity.sql (fn_get_user_by_nif, fn_get_user_by_email)
--   - Services/00_Core/01_Normalization_Identity.sql
--   - Schema/01_Module1_User_Management/00_Tables_Mod1.sql (employee)
--
-- LOADED BY
--   - Bootstrap/Loaders/06_Services.sql
-- =========================================================

drop function if exists fn_create_employee(
    varchar, text, varchar, varchar, varchar, varchar,
    varchar, varchar, varchar,
    int
);

-- ---------------------------------------------------------
-- FUNCTION: fn_create_employee
-- ---------------------------------------------------------
-- INTENT:
--   Register an employee linked to a shared or new user identity.
-- FLOW:
--   1. Normalize inputs and validate registering employee is active.
--   2. Resolve identity; reject NIF/email conflicts and duplicate employees.
--   3. Create user_account when needed; build corporate email {id_usr}@miacaomigo.pt.
--   4. INSERT employee row with audit columns.
-- EXPECTED RESULT:
--   id_emp of the newly created employee row.
-- ---------------------------------------------------------

create or replace function fn_create_employee(
    p_nam_usr varchar,
    p_add_usr text,
    p_pos_usr varchar,
    p_nif_usr varchar,
    p_pho_usr varchar,
    p_ema_usr varchar,
    p_pho_emp varchar,
    p_pho_emg varchar,
    p_pas_emp varchar,
    p_id_emp_reg int
)
returns int
language plpgsql
as $$

declare
    v_id_usr int;
    v_id_emp int;
    v_ema_emp varchar;
    v_id_usr_by_nif int;
    v_id_usr_by_email int;

begin

    p_nif_usr := normalize_nif(p_nif_usr);
    p_ema_usr := normalize_email(p_ema_usr);

    if not exists (
        select 1
        from employee e
        where e.id_emp = p_id_emp_reg
          and e.dea_dat_emp is null
    ) then
        raise exception using
            message = 'Registering employee is invalid or inactive.';
    end if;

    v_id_usr_by_nif := fn_get_user_by_nif(p_nif_usr);
    v_id_usr_by_email := fn_get_user_by_email(p_ema_usr);

    if v_id_usr_by_nif is distinct from v_id_usr_by_email then
        raise exception using
            message = 'NIF and email belong to different identities.';
    end if;

    v_id_usr := v_id_usr_by_nif;

    if v_id_usr is not null
    and exists (
        select 1
        from employee e
        where e.id_usr = v_id_usr
    ) then
        raise exception using
            message = 'User already has an employee account.';
    end if;

    if v_id_usr is null then
        v_id_usr := fn_create_user_account(
            p_nam_usr,
            p_add_usr,
            p_pos_usr,
            p_nif_usr,
            p_pho_usr,
            p_ema_usr
        );
    end if;

    v_ema_emp := v_id_usr || '@miacaomigo.pt';

    insert into employee (
        id_usr,
        pho_emp,
        pho_emg,
        ema_emp,
        pas_emp,
        reg_dat_emp,
        aut_reg_emp
    )
    values (
        v_id_usr,
        normalize_phone_nullable(p_pho_emp),
        normalize_phone_nullable(p_pho_emg),
        v_ema_emp,
        normalize_secret(p_pas_emp),
        current_timestamp,
        p_id_emp_reg
    )
    returning id_emp
    into v_id_emp;

    return v_id_emp;

exception
    when check_violation then
        raise exception using
            message = 'Employee data validation failed.',
            detail = sqlerrm,
            errcode = sqlstate;
    when foreign_key_violation then
        raise exception using
            message = 'Invalid employee association.',
            detail = sqlerrm,
            errcode = sqlstate;
    when unique_violation then
        raise exception using
            message = 'Employee account already exists.',
            detail = sqlerrm,
            errcode = sqlstate;
    when others then
        raise exception using
            message = 'Unexpected error while creating employee account.',
            detail = sqlerrm,
            errcode = sqlstate;
end;

$$;
