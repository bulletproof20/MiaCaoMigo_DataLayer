-- =========================================================
-- MODULE 1 — PUBLIC API: ROLE CHANGE
-- FILE: Services/01_Module1/99_Public_API/03_Role_Change_API.sql
-- =========================================================
--
-- svc_* — application entry points (delegates to sp_promote_* / sp_demote_*).
-- =========================================================

drop function if exists svc_promote_to_veterinarian(int, varchar, int);
drop function if exists svc_promote_to_assistant(int, varchar, int);
drop function if exists svc_demote_to_general_employee(int, int);

create or replace function svc_promote_to_veterinarian(
    p_id_usr int,
    p_num_omv_vet varchar,
    p_id_emp_reg int
)
returns int
language sql
volatile
as $$
    select sp_promote_to_veterinarian(p_id_usr, p_num_omv_vet, p_id_emp_reg);
$$;

create or replace function svc_promote_to_assistant(
    p_id_usr int,
    p_fun_ass varchar,
    p_id_emp_reg int
)
returns int
language sql
volatile
as $$
    select sp_promote_to_assistant(p_id_usr, p_fun_ass, p_id_emp_reg);
$$;

create or replace function svc_demote_to_general_employee(
    p_id_usr int,
    p_id_emp_reg int
)
returns int
language sql
volatile
as $$
    select sp_demote_to_general_employee(p_id_usr, p_id_emp_reg);
$$;
