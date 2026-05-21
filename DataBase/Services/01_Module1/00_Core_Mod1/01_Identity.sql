-- =========================================================
-- IDENTITY (MODULE 1 — CORE)
-- FILE: Services/01_Module1/00_Core_Mod1/01_Identity.sql
-- =========================================================
--
-- PURPOSE
-- Lightweight identity lookups and role predicates shared by
-- authentication, onboarding, RBAC, and attendance services.
--
-- DEPENDENCIES
--   - Services/00_Core/00_Normalization.sql (normalize_email)
--   - Schema/01_Module1_User_Management/00_Tables_Mod1.sql
--     (user_account, employee, client, veterinarian, assistant)
--
-- LOADED BY
--   - Bootstrap/Loaders/06_Services.sql (first Module 1 file)
-- =========================================================

drop function if exists fn_is_employee_email(varchar);

-- ---------------------------------------------------------
-- FUNCTION: fn_is_employee_email
-- ---------------------------------------------------------
-- INTENT:
--   Classify an email as corporate staff based on domain rules.
-- FLOW:
--   1. Normalize email.
--   2. Match against @miacaomigo.pt pattern.
-- EXPECTED RESULT:
--   true for corporate domain; false for personal client emails.
-- ---------------------------------------------------------

create function fn_is_employee_email(p_email varchar)
returns boolean
language plpgsql
as $$
begin
    p_email := normalize_email(p_email);
    return p_email ~ '^[^@\s]+@miacaomigo\.pt$';
end;
$$;


drop function if exists fn_get_user_by_email(varchar);

-- ---------------------------------------------------------
-- FUNCTION: fn_get_user_by_email
-- ---------------------------------------------------------
-- INTENT:
--   Resolve id_usr from either corporate or personal email channel.
-- FLOW:
--   1. Normalize email and branch on fn_is_employee_email.
--   2. Read employee.ema_emp or user_account.ema_usr accordingly.
-- EXPECTED RESULT:
--   id_usr when found; NULL when no matching row exists.
-- ---------------------------------------------------------

create function fn_get_user_by_email(p_email varchar)
returns integer
language plpgsql
as $$
declare
    v_user_id integer;
begin
    p_email := normalize_email(p_email);

    if fn_is_employee_email(p_email) then
        select e.id_usr
        into v_user_id
        from employee e
        where e.ema_emp = p_email;
    else
        select u.id_usr
        into v_user_id
        from user_account u
        where u.ema_usr = p_email;
    end if;

    return v_user_id;
end;
$$;


drop function if exists fn_get_user_by_nif(varchar);

-- ---------------------------------------------------------
-- FUNCTION: fn_get_user_by_nif
-- ---------------------------------------------------------
-- INTENT:
--   Lookup shared identity by tax number (NIF).
-- FLOW:
--   1. Trim NIF.
--   2. SELECT id_usr from user_account.
-- EXPECTED RESULT:
--   id_usr or NULL.
-- ---------------------------------------------------------

create or replace function fn_get_user_by_nif(p_nif varchar)
returns int
language plpgsql
as $$
declare
    v_id_usr int;
begin
    p_nif := trim(p_nif);

    select u.id_usr
    into v_id_usr
    from user_account u
    where u.nif_usr = p_nif;

    return v_id_usr;
end;
$$;


drop function if exists fn_get_user_by_employee(int);

-- ---------------------------------------------------------
-- FUNCTION: fn_get_user_by_employee
-- ---------------------------------------------------------
-- INTENT:
--   Map an employee row back to its shared user identity.
-- FLOW:
--   1. SELECT id_usr FROM employee by id_emp.
-- EXPECTED RESULT:
--   id_usr or NULL.
-- ---------------------------------------------------------

create or replace function fn_get_user_by_employee(p_id_emp int)
returns int
language plpgsql
as $$
declare
    v_id_usr int;
begin
    select e.id_usr
    into v_id_usr
    from employee e
    where e.id_emp = p_id_emp;

    return v_id_usr;
end;
$$;


drop function if exists fn_get_user_by_client(int);

-- ---------------------------------------------------------
-- FUNCTION: fn_get_user_by_client
-- ---------------------------------------------------------
-- INTENT:
--   Map a client row back to its shared user identity.
-- FLOW:
--   1. SELECT id_usr FROM client by id_cli.
-- EXPECTED RESULT:
--   id_usr or NULL.
-- ---------------------------------------------------------

create or replace function fn_get_user_by_client(p_id_cli int)
returns int
language plpgsql
as $$
declare
    v_id_usr int;
begin
    select c.id_usr
    into v_id_usr
    from client c
    where c.id_cli = p_id_cli;

    return v_id_usr;
end;
$$;


drop function if exists fn_get_active_employee_by_user(int);

-- ---------------------------------------------------------
-- FUNCTION: fn_get_active_employee_by_user
-- ---------------------------------------------------------
-- INTENT:
--   Return the active employment id for a user with deterministic ranking.
-- FLOW:
--   1. Filter active rows (dea_dat_emp IS NULL).
--   2. ROW_NUMBER by reg_dat_emp DESC, id_emp DESC; pick rank 1.
-- EXPECTED RESULT:
--   id_emp of the chosen active row, or NULL when none exist.
-- ---------------------------------------------------------

create or replace function fn_get_active_employee_by_user(p_id_usr int)
returns int
language sql
stable
as $$
    with active_employment as (
        select
            e.id_emp,
            row_number() over (
                order by e.reg_dat_emp desc, e.id_emp desc
            ) as emp_rank
        from employee e
        where e.id_usr = p_id_usr
          and e.dea_dat_emp is null
    )
    select ae.id_emp
    from active_employment ae
    where ae.emp_rank = 1;
$$;


drop function if exists fn_get_client_by_user(int);

-- ---------------------------------------------------------
-- FUNCTION: fn_get_client_by_user
-- ---------------------------------------------------------
-- INTENT:
--   Resolve client id from a shared user identity.
-- FLOW:
--   1. SELECT id_cli FROM client WHERE id_usr matches.
-- EXPECTED RESULT:
--   id_cli or NULL.
-- ---------------------------------------------------------

create or replace function fn_get_client_by_user(p_id_usr int)
returns int
language plpgsql
as $$
declare
    v_id_cli int;
begin
    select c.id_cli
    into v_id_cli
    from client c
    where c.id_usr = p_id_usr;

    return v_id_cli;
end;
$$;


drop function if exists fn_user_exists_by_email(varchar);

-- ---------------------------------------------------------
-- FUNCTION: fn_user_exists_by_email
-- ---------------------------------------------------------
-- INTENT:
--   Test whether an email is registered as client or active employee.
-- FLOW:
--   1. Normalize email.
--   2. EXISTS over UNION of user_account and active employee matches.
-- EXPECTED RESULT:
--   true when either channel matches; otherwise false.
-- ---------------------------------------------------------

create or replace function fn_user_exists_by_email(p_email varchar)
returns boolean
language plpgsql
as $$
begin
    p_email := normalize_email(p_email);

    return exists (
        select 1
        from (
            select 1 as found
            from user_account u
            where u.ema_usr = p_email
            union all
            select 1
            from employee e
            where e.ema_emp = p_email
              and e.dea_dat_emp is null
        ) email_matches
    );
end;
$$;


drop function if exists fn_user_exists_by_nif(varchar);

-- ---------------------------------------------------------
-- FUNCTION: fn_user_exists_by_nif
-- ---------------------------------------------------------
-- INTENT:
--   Test whether a NIF already belongs to a user_account row.
-- FLOW:
--   1. Trim NIF and probe user_account.
-- EXPECTED RESULT:
--   true when a row exists; otherwise false.
-- ---------------------------------------------------------

create or replace function fn_user_exists_by_nif(p_nif varchar)
returns boolean
language plpgsql
as $$
begin
    p_nif := trim(p_nif);

    return exists (
        select 1
        from user_account u
        where u.nif_usr = p_nif
    );
end;
$$;


drop function if exists fn_client_exists(int);

-- ---------------------------------------------------------
-- FUNCTION: fn_client_exists
-- ---------------------------------------------------------
-- INTENT:
--   Test whether a user already owns a client account.
-- FLOW:
--   1. EXISTS on client for the given id_usr.
-- EXPECTED RESULT:
--   true when a client row exists; otherwise false.
-- ---------------------------------------------------------

create or replace function fn_client_exists(p_id_usr int)
returns boolean
language plpgsql
as $$
begin
    return exists (
        select 1
        from client c
        where c.id_usr = p_id_usr
    );
end;
$$;


drop function if exists fn_has_active_employee(int);

-- ---------------------------------------------------------
-- FUNCTION: fn_has_active_employee
-- ---------------------------------------------------------
-- INTENT:
--   Test whether a user currently has an active employment contract.
-- FLOW:
--   1. EXISTS on employee with dea_dat_emp IS NULL.
-- EXPECTED RESULT:
--   true when at least one active row exists; otherwise false.
-- ---------------------------------------------------------

create or replace function fn_has_active_employee(p_id_usr int)
returns boolean
language plpgsql
as $$
begin
    return exists (
        select 1
        from employee e
        where e.id_usr = p_id_usr
          and e.dea_dat_emp is null
    );
end;
$$;


drop function if exists fn_is_veterinarian(int);

-- ---------------------------------------------------------
-- FUNCTION: fn_is_veterinarian
-- ---------------------------------------------------------
-- INTENT:
--   Test whether an employee row is registered as veterinarian.
-- FLOW:
--   1. EXISTS on veterinarian for id_emp.
-- EXPECTED RESULT:
--   true when role row exists; otherwise false.
-- ---------------------------------------------------------

create or replace function fn_is_veterinarian(p_id_emp int)
returns boolean
language plpgsql
as $$
begin
    return exists (
        select 1
        from veterinarian v
        where v.id_emp = p_id_emp
    );
end;
$$;


drop function if exists fn_is_assistant(int);

-- ---------------------------------------------------------
-- FUNCTION: fn_is_assistant
-- ---------------------------------------------------------
-- INTENT:
--   Test whether an employee row is registered as assistant.
-- FLOW:
--   1. EXISTS on assistant for id_emp.
-- EXPECTED RESULT:
--   true when role row exists; otherwise false.
-- ---------------------------------------------------------

create or replace function fn_is_assistant(p_id_emp int)
returns boolean
language plpgsql
as $$
begin
    return exists (
        select 1
        from assistant a
        where a.id_emp = p_id_emp
    );
end;
$$;
