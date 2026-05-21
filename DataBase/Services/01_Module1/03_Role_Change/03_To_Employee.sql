-- =========================================================
-- ROLE CHANGE — TO GENERAL EMPLOYEE (MODULE 1)
-- FILE: Services/01_Module1/03_Role_Change/03_To_Employee.sql
-- =========================================================
--
-- PURPOSE
-- Demote veterinarian or assistant back to a general employee by
-- renewing employment without inserting a new role extension.
--
-- DEPENDENCIES
--   - Services/01_Module1/00_Core_Mod1/01_Identity.sql
--     (fn_get_active_employee_by_user, fn_is_veterinarian, fn_is_assistant)
--   - Services/01_Module1/03_Role_Change/00_CommonManagement.sql (fn_renew_employee_record)
--
-- LOADED BY
--   - Bootstrap/Loaders/06_Services.sql
-- =========================================================

drop function if exists fn_alter_employee_to_general(int, int);

-- ---------------------------------------------------------
-- FUNCTION: fn_alter_employee_to_general
-- ---------------------------------------------------------
-- INTENT:
--   Remove specialized role by creating a fresh general employee row.
-- FLOW:
--   1. Resolve active id_emp; require current veterinarian or assistant role.
--   2. Call fn_renew_employee_record (historical role rows remain on old id_emp).
-- EXPECTED RESULT:
--   id_emp of the new active general employee without role extension insert.
-- ---------------------------------------------------------

create or replace function fn_alter_employee_to_general(
    p_id_usr int,
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

    if not fn_is_veterinarian(v_id_emp_old)
       and not fn_is_assistant(v_id_emp_old) then
        raise exception using
            message = 'Employee account with id ' || v_id_emp_old ||
                      ' is already a general employee.';
    end if;

    v_id_emp_new := fn_renew_employee_record(v_id_emp_old, p_id_emp_reg);

    return v_id_emp_new;

end;

$$;
