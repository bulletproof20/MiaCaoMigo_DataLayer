-- =========================================================
-- VALIDATIONS (MODULE 1 — CORE)
-- FILE: Services/01_Module1/00_Core_Mod1/02_Validations.sql
-- =========================================================
-- PURPOSE:   Account and password hash checks for auth flows
-- DOMAIN:    Module 1 — User Management
-- LOADED BY: Bootstrap/Loaders/06_Services.sql (before authentication)
-- See:       ../../../PASSWORD_AUTH.md
-- =========================================================

-- --- fn_is_account_active ---
-- PURPOSE: true when email maps to an active employee or client row
-- BEHAVIOUR: CTE resolves channel once, then checks activity flag

create or replace function fn_is_account_active(p_email varchar)
returns boolean
language sql
stable
as $$
    with normalized_identity as (
        select normalize_email(p_email) as email_norm
    ),
    identity_channel as (
        select
            case
                when ni.email_norm ~ '^[^@\s]+@miacaomigo\.pt$' then 'employee'
                else 'client'
            end as channel
        from normalized_identity ni
    ),
    active_employee as (
        select exists (
            select 1
            from employee e
            cross join normalized_identity ni
            where e.ema_emp = ni.email_norm
              and e.dea_dat_emp is null
        ) as is_active
        from identity_channel ic
        where ic.channel = 'employee'
    ),
    active_client as (
        select exists (
            select 1
            from client c
            inner join user_account u on u.id_usr = c.id_usr
            cross join normalized_identity ni
            where u.ema_usr = ni.email_norm
              and c.ina_dat_cli is null
        ) as is_active
        from identity_channel ic
        where ic.channel = 'client'
    )
    select coalesce(
        (select ae.is_active from active_employee ae),
        (select ac.is_active from active_client ac),
        false
    );
$$;


-- --- validate_password ---
-- PURPOSE: compare stored hash (pas_emp / pas_cli) with API-supplied hash string
-- NOTE: p_password parameter carries the bcrypt hash from the API, not plaintext

drop function if exists validate_password(varchar, varchar);

create or replace function validate_password(p_email varchar, p_password varchar)
returns boolean
language sql
stable
as $$
    with normalized_identity as (
        select normalize_email(p_email) as email_norm
    ),
    stored_hash as (
        -- corporate channel: employee email domain only
        select e.pas_emp as pass_hash
        from employee e
        cross join normalized_identity ni
        where e.ema_emp = ni.email_norm
          and ni.email_norm ~ '^[^@\s]+@miacaomigo\.pt$'
        union all
        -- personal channel: client accounts outside corporate domain
        select c.pas_cli
        from client c
        inner join user_account u on u.id_usr = c.id_usr
        cross join normalized_identity ni
        where u.ema_usr = ni.email_norm
          and ni.email_norm !~ '^[^@\s]+@miacaomigo\.pt$'
    )
    select coalesce(
        (
            select sh.pass_hash = p_password
            from stored_hash sh
            limit 1
        ),
        false
    );
$$;
