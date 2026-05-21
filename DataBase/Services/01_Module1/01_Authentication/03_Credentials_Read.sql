-- =========================================================
-- CREDENTIAL READ (MODULE 1 — AUTHENTICATION)
-- FILE: Services/01_Module1/01_Authentication/03_Credentials_Read.sql
-- =========================================================
--
-- PURPOSE
-- Read-only helper to resolve stored email and password hash by user id
-- for integration tests (not for production credential exposure).
--
-- DEPENDENCIES
--   - Schema/01_Module1_User_Management/00_Tables_Mod1.sql
--     (employee, client, user_account)
--   - DataBase/PASSWORD_AUTH.md (hash column semantics)
--
-- LOADED BY
--   - Bootstrap/Loaders/06_Services.sql
-- =========================================================

drop function if exists get_user_credentials(int);

-- ---------------------------------------------------------
-- FUNCTION: get_user_credentials
-- ---------------------------------------------------------
-- INTENT:
--   Return the active credential channel (employee preferred over client).
-- FLOW:
--   1. Build active_employee_channel CTE when dea_dat_emp IS NULL.
--   2. Build active_client_channel CTE when no active employee shares id_usr.
--   3. UNION into resolved_credentials and project result columns.
-- EXPECTED RESULT:
--   Zero or one row with id_usr, email, pass_hash, and role text.
-- ---------------------------------------------------------

create or replace function get_user_credentials(p_id_usr int)
returns table(
    id_usr int,
    email varchar,
    pass_hash varchar,
    role text
)
language sql
stable
as $$
    with active_employee_channel as (
        select
            e.id_usr,
            e.ema_emp as email,
            e.pas_emp as pass_hash,
            'employee'::text as role
        from employee e
        where e.id_usr = p_id_usr
          and e.dea_dat_emp is null
    ),
    active_client_channel as (
        select
            u.id_usr,
            u.ema_usr as email,
            c.pas_cli as pass_hash,
            'client'::text as role
        from client c
        inner join user_account u on u.id_usr = c.id_usr
        where c.id_usr = p_id_usr
          and c.ina_dat_cli is null
    ),
    resolved_credentials as (
        select * from active_employee_channel
        union all
        select ac.*
        from active_client_channel ac
        where not exists (
            select 1
            from active_employee_channel ae
            where ae.id_usr = ac.id_usr
        )
    )
    select
        rc.id_usr,
        rc.email,
        rc.pass_hash,
        rc.role
    from resolved_credentials rc;
$$;
