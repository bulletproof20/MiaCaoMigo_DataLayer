-- =========================================================
-- NEW VETERINARIAN (MODULE 1 — USER CREATION)
-- BUSINESS WORKFLOW: sp_create_veterinarian
-- =========================================================

drop function if exists sp_create_veterinarian(
    varchar, text, varchar, varchar, varchar, varchar,
    varchar, varchar, varchar,
    int,
    varchar
);

create or replace function sp_create_veterinarian(
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

    p_num_omv_vet := fn_normalize_omv_number(p_num_omv_vet);

    call sp_create_employee(
        p_nam_usr,
        p_add_usr,
        p_pos_usr,
        p_nif_usr,
        p_pho_usr,
        p_ema_usr,
        p_pho_emp,
        p_pho_emg,
        p_pas_emp,
        p_id_emp_reg,
        v_id_emp
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
