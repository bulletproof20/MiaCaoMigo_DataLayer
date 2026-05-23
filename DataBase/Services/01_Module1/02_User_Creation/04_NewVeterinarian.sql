-- =========================================================
-- NEW VETERINARIAN (MODULE 1 — USER CREATION)
-- FILE: Services/01_Module1/02_User_Creation/04_NewVeterinarian.sql
-- =========================================================
--
-- PURPOSE
-- Create an employee identity and attach the veterinarian role (OMV).
--
-- DEPENDENCIES
--   - Services/01_Module1/02_User_Creation/02_NewEmployee.sql (fn_create_employee)
--   - Schema/01_Module1_User_Management/00_Tables_Mod1.sql (veterinarian, assistant)
--   - Schema/01_Module1_User_Management/02_Functions_Mod1.sql (role exclusion triggers)
--
-- LOADED BY
--   - Bootstrap/Loaders/06_Services.sql
-- =========================================================

drop function if exists fn_create_veterinarian(
    varchar, text, varchar, varchar, varchar, varchar,
    varchar, varchar, varchar,
    int,
    varchar
);

-- ---------------------------------------------------------
-- FUNCTION: fn_create_veterinarian
-- ---------------------------------------------------------
-- INTENT:
--   Onboard a new veterinarian (employee + veterinarian role).
-- FLOW:
--   1. Trim OMV number and delegate employee creation.
--   2. Reject when assistant role already exists on the same id_emp.
--   3. INSERT veterinarian row with num_omv_vet.
-- EXPECTED RESULT:
--   id_emp of the employee that now holds the veterinarian role.
-- ---------------------------------------------------------

create or replace function fn_create_veterinarian(
    p_nam_usr varchar,
    p_add_usr text,
    p_pos_usr varchar,
    p_nif_usr varchar,
    p_pho_usr varchar,
    p_ema_usr varchar,
    p_pho_emp varchar,
    p_pho_emg varchar,
    p_pas_emp varchar,
    p_id_emp_reg int,
    p_num_omv_vet varchar
)
returns int
language plpgsql
as $$

declare
    v_id_emp int;

begin

    p_num_omv_vet := normalize_omv_number(p_num_omv_vet);

    v_id_emp := fn_create_employee(
        p_nam_usr,
        p_add_usr,
        p_pos_usr,
        p_nif_usr,
        p_pho_usr,
        p_ema_usr,
        p_pho_emp,
        p_pho_emg,
        p_pas_emp,
        p_id_emp_reg
    );

    if exists (
        select 1
        from assistant a
        where a.id_emp = v_id_emp
    ) then
        raise exception using
            message = 'Employee already has an assistant role.';
    end if;

    insert into veterinarian (id_emp, num_omv_vet)
    values (v_id_emp, p_num_omv_vet);

    return v_id_emp;

exception
    when check_violation then
        raise exception using
            message = 'Veterinarian data validation failed.',
            detail = sqlerrm,
            errcode = sqlstate;
    when foreign_key_violation then
        raise exception using
            message = 'Invalid employee association.',
            detail = sqlerrm,
            errcode = sqlstate;
    when unique_violation then
        raise exception using
            message = 'Veterinarian role already exists.',
            detail = sqlerrm,
            errcode = sqlstate;
    when others then
        raise exception using
            message = 'Unexpected error while creating veterinarian account.',
            detail = sqlerrm,
            errcode = sqlstate;
end;

$$;
