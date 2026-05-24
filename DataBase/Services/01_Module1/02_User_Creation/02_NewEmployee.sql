-- =========================================================
-- NEW EMPLOYEE (MODULE 1 — USER CREATION)
-- BUSINESS WORKFLOW: sp_create_employee
-- =========================================================

drop procedure if exists sp_create_employee(
    varchar, text, varchar, varchar, varchar, varchar,
    varchar, varchar, varchar, int, out int
);

create or replace procedure sp_create_employee(
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
    out p_id_emp int
)
language plpgsql
as $$
declare
    v_id_usr int;
    v_ema_emp varchar;
    v_id_usr_by_nif int;
    v_id_usr_by_email int;
begin

    p_nif_usr := fn_normalize_nif(p_nif_usr);
    p_ema_usr := fn_normalize_email(p_ema_usr);

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
        fn_normalize_phone_nullable(p_pho_emp),
        fn_normalize_phone_nullable(p_pho_emg),
        v_ema_emp,
        fn_normalize_secret(p_pas_emp),
        current_timestamp,
        p_id_emp_reg
    )
    returning id_emp
    into p_id_emp;

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
