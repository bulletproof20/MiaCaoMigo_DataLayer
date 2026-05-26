-- =========================================================
-- MODULE 1 — PUBLIC API: USER CREATION
-- FILE: Services/01_Module1/99_Public_API/02_User_Creation_API.sql
-- =========================================================
--
-- svc_* — application entry points (delegates to sp_create_*).
-- =========================================================

drop function if exists svc_create_client(
    varchar, text, varchar, varchar, varchar, varchar, varchar, varchar
);
drop function if exists svc_create_employee(
    varchar, text, varchar, varchar, varchar, varchar,
    varchar, varchar, varchar, int
);
drop function if exists svc_create_assistant(
    varchar, text, varchar, varchar, varchar, varchar,
    varchar, varchar, varchar, int, varchar
);
drop function if exists svc_create_veterinarian(
    varchar, text, varchar, varchar, varchar, varchar,
    varchar, varchar, varchar, int, varchar
);

create or replace function svc_create_client(
    p_nam_usr varchar,
    p_add_usr text,
    p_pos_usr varchar,
    p_nif_usr varchar,
    p_pho_usr varchar,
    p_ema_usr varchar,
    p_pas_cli varchar,
    p_existing_password varchar default null
)
returns int
language plpgsql
as $$
declare
    v_id_cli int;
begin
    call sp_create_client(
        p_nam_usr,
        p_add_usr,
        p_pos_usr,
        p_nif_usr,
        p_pho_usr,
        p_ema_usr,
        p_pas_cli,
        p_existing_password,
        v_id_cli
    );
    return v_id_cli;
end;
$$;

create or replace function svc_create_employee(
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
    v_id_emp int;
begin
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
    return v_id_emp;
end;
$$;

create or replace function svc_create_assistant(
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
    p_fun_ass varchar
)
returns int
language sql
volatile
as $$
    select sp_create_assistant(
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
        p_fun_ass
    );
$$;

create or replace function svc_create_veterinarian(
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
language sql
volatile
as $$
    select sp_create_veterinarian(
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
        p_num_omv_vet
    );
$$;
