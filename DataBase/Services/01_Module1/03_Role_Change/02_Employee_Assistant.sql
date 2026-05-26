-- =========================================================
-- ROLE CHANGE — EMPLOYEE TO ASSISTANT (MODULE 1)
-- BUSINESS WORKFLOW: sp_promote_to_assistant
-- =========================================================

drop function if exists sp_promote_to_assistant(int, varchar, int);

create or replace function sp_promote_to_assistant(
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

    call sp_renew_employee_record(v_id_emp_old, p_id_emp_reg, v_id_emp_new);

    insert into assistant (id_emp, fun_ass)
    values (v_id_emp_new, fn_normalize_text(p_fun_ass));

    return v_id_emp_new;

end;
$$;
