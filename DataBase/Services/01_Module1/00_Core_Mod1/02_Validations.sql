-- =========================================================
-- VALIDATIONS (MODULE 1 — CORE)
-- FILE: Services/01_Module1/00_Core_Mod1/02_Validations.sql
-- =========================================================
--
-- PURPOSE
-- Account activity and password-hash validation helpers consumed
-- by the authentication service layer before session creation.
--
-- DEPENDENCIES
--   - Services/00_Core/00_Normalization.sql (normalize_email)
--   - Services/01_Module1/00_Core_Mod1/01_Identity.sql (fn_is_employee_email semantics)
--   - Schema/01_Module1_User_Management/00_Tables_Mod1.sql (employee, client, user_account)
--   - password hash contract documented in 00_MiaCaoMigo_Engineering
--
-- LOADED BY
--   - Bootstrap/Loaders/06_Services.sql (before 01_Authentication)
-- =========================================================

-- ---------------------------------------------------------
-- FUNCTION: fn_is_account_active
-- ---------------------------------------------------------
-- INTENT:
--   Report whether an email maps to an active employee or client row.
-- FLOW:
--   1. Normalize email and resolve channel (corporate vs personal).
--   2. Check activity on the matching table via CTE branches.
-- EXPECTED RESULT:
--   true when the resolved channel has an active row; otherwise false.
-- ---------------------------------------------------------

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


drop function if exists validate_password(varchar, varchar);

-- ---------------------------------------------------------
-- FUNCTION: validate_password
-- ---------------------------------------------------------
-- INTENT:
--   Compare stored hash with the API-supplied hash for the email channel.
-- FLOW:
--   1. Normalize email.
--   2. Resolve stored hash from employee or client CTE branch.
--   3. Return equality result (no hashing inside the database).
-- EXPECTED RESULT:
--   true when hashes match; false when missing or different.
-- ---------------------------------------------------------

create or replace function validate_password(p_email varchar, p_password varchar)
returns boolean
language sql
stable
as $$
    with normalized_identity as (
        select normalize_email(p_email) as email_norm
    ),
    stored_hash as (
        select e.pas_emp as pass_hash
        from employee e
        cross join normalized_identity ni
        where e.ema_emp = ni.email_norm
          and ni.email_norm ~ '^[^@\s]+@miacaomigo\.pt$'
        union all
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
