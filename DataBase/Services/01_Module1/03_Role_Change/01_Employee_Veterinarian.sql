-- =========================================================
-- ROLE CHANGE — EMPLOYEE TO VETERINARIAN (MODULE 1)
-- BUSINESS WORKFLOW: sp_promote_to_veterinarian
-- =========================================================

drop function if exists sp_promote_to_veterinarian(int, varchar, int);

create or replace function sp_promote_to_veterinarian(
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

    p_num_omv_vet := fn_normalize_omv_number(p_num_omv_vet);

    v_id_emp_old := fn_get_active_employee_by_user(p_id_usr);

    if v_id_emp_old is null then
        raise exception using
            message = 'No active employee account found for user id: ' || p_id_usr;
    end if;

    if fn_is_veterinarian(v_id_emp_old) then
        raise exception using
            message = 'Employee account with id ' || v_id_emp_old || ' is already a veterinarian.';
    end if;

    call sp_renew_employee_record(v_id_emp_old, p_id_emp_reg, v_id_emp_new);

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
