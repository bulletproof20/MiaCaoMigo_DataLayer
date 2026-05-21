-- =========================================================
-- CREDENTIAL READ (MODULE 1 — AUTHENTICATION)
-- FILE: Services/01_Module1/01_Authentication/03_Credentials_Read.sql
-- =========================================================
-- PURPOSE:   Read-only access to stored email + password hash by user id
-- DOMAIN:    Module 1 — User Management
-- LOADED BY: Bootstrap/Loaders/06_Services.sql
-- CLEANUP:   drop function if exists before create
-- =========================================================
-- Integration helper only — production APIs should not expose hashes.
-- =========================================================

drop function if exists get_user_credentials(int);

-- --- get_user_credentials ---
-- PURPOSE: resolve active employee or client channel for a user id
-- BEHAVIOUR: CTE channels — employee wins over client when both exist

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
        -- employee corporate channel (preferred when active)
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
        -- personal client channel (used when no active employee row exists)
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
