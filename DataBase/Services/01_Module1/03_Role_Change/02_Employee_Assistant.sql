-- =========================================================
-- ROLE CHANGE — EMPLOYEE TO ASSISTANT (MODULE 1)
-- FILE: Services/01_Module1/03_Role_Change/02_Employee_Assistant.sql
-- =========================================================
--
-- PURPOSE
-- Promote an active employee to assistant by renewing employment
-- and attaching the assistant role to the new id_emp.
--
-- DEPENDENCIES
--   - Services/01_Module1/00_Core_Mod1/01_Identity.sql
--     (fn_get_active_employee_by_user, fn_is_assistant)
--   - Services/01_Module1/03_Role_Change/00_CommonManagement.sql (fn_renew_employee_record)
--   - Schema/01_Module1_User_Management/00_Tables_Mod1.sql (assistant)
--
-- LOADED BY
--   - Bootstrap/Loaders/06_Services.sql
-- =========================================================

drop function if exists fn_alter_employee_to_assistant(int, varchar, int);

-- ---------------------------------------------------------
-- FUNCTION: fn_alter_employee_to_assistant
-- ---------------------------------------------------------
-- INTENT:
--   Convert a general employee into an assistant with a new employment row.
-- FLOW:
--   1. Resolve active id_emp for the user; reject when already assistant.
--   2. Call fn_renew_employee_record to inactivate old row and create successor.
--   3. INSERT assistant extension on the new id_emp.
-- EXPECTED RESULT:
--   id_emp of the new active employee holding the assistant role.
-- ---------------------------------------------------------

create or replace function fn_alter_employee_to_assistant(
    p_id_usr int,
    p_fun_ass varchar,
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

    if fn_is_assistant(v_id_emp_old) then
        raise exception using
            message = 'Employee account with id ' || v_id_emp_old || ' is already a assistant.';
    end if;

    v_id_emp_new := fn_renew_employee_record(v_id_emp_old, p_id_emp_reg);

    insert into assistant (id_emp, fun_ass)
    values (v_id_emp_new, p_fun_ass);

    return v_id_emp_new;

end;

$$;
