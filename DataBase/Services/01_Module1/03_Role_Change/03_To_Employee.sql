-- =========================================================
-- ROLE CHANGE — TO GENERAL EMPLOYEE (MODULE 1)
-- BUSINESS WORKFLOW: sp_demote_to_general_employee
-- =========================================================

drop function if exists sp_demote_to_general_employee(int, int);

create or replace function sp_demote_to_general_employee(
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

    call sp_renew_employee_record(v_id_emp_old, p_id_emp_reg, v_id_emp_new);

    return v_id_emp_new;

end;
$$;
