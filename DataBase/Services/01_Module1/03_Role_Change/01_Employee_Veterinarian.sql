-- =========================================================
-- ROLE CHANGE — EMPLOYEE TO VETERINARIAN (MODULE 1)
-- FILE: Services/01_Module1/03_Role_Change/01_Employee_Veterinarian.sql
-- =========================================================
--
-- PURPOSE
-- Promote an active employee to veterinarian by renewing employment
-- and attaching the veterinarian role to the new id_emp.
--
-- DEPENDENCIES
--   - Services/01_Module1/00_Core_Mod1/01_Identity.sql
--     (fn_get_active_employee_by_user, fn_is_veterinarian)
--   - Services/01_Module1/03_Role_Change/00_CommonManagement.sql (fn_renew_employee_record)
--   - Schema/01_Module1_User_Management/00_Tables_Mod1.sql (veterinarian)
--
-- LOADED BY
--   - Bootstrap/Loaders/06_Services.sql
-- =========================================================

drop function if exists fn_alter_employee_to_veterinarian(int, varchar, int);

-- ---------------------------------------------------------
-- FUNCTION: fn_alter_employee_to_veterinarian
-- ---------------------------------------------------------
-- INTENT:
--   Convert a general employee into a veterinarian with a new employment row.
-- FLOW:
--   1. Resolve active id_emp for the user; reject when already veterinarian.
--   2. Call fn_renew_employee_record to inactivate old row and create successor.
--   3. INSERT veterinarian extension on the new id_emp.
-- EXPECTED RESULT:
--   id_emp of the new active employee holding the veterinarian role.
-- ---------------------------------------------------------

create or replace function fn_alter_employee_to_veterinarian(
    p_id_usr int,
    p_num_omv_vet varchar,
    p_id_emp_reg int
)
returns int
language plpgsql
as $$

declare
    v_id_emp_old int;
    v_id_emp_new int;

begin

    v_id_emp_old := fn_get_active_employee_by_user(p_id_usr);

    if v_id_emp_old is null then
        raise exception using
            message = 'No active employee account found for user id: ' || p_id_usr;
    end if;

    if fn_is_veterinarian(v_id_emp_old) then
        raise exception using
            message = 'Employee account with id ' || v_id_emp_old || ' is already a veterinarian.';
    end if;

    v_id_emp_new := fn_renew_employee_record(v_id_emp_old, p_id_emp_reg);

    insert into veterinarian (id_emp, num_omv_vet)
    values (v_id_emp_new, p_num_omv_vet);

    return v_id_emp_new;

exception
    when unique_violation then
        raise exception using
            message = 'Veterinarian record already exists for this employee.',
            detail = sqlerrm,
            errcode = sqlstate;
    when foreign_key_violation then
        raise exception using
            message = 'Invalid employee association while creating veterinarian.',
            detail = sqlerrm,
            errcode = sqlstate;
    when others then
        raise exception using
            message = 'Unexpected error while converting employee to veterinarian.',
            detail = sqlerrm,
            errcode = sqlstate;
end;

$$;
