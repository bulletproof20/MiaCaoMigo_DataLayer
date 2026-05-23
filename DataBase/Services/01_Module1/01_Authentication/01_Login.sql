-- =========================================================
-- LOGIN (MODULE 1 — AUTHENTICATION)
-- FILE: Services/01_Module1/01_Authentication/01_Login.sql
-- =========================================================
--
-- PURPOSE
-- Authenticate a user by email and hash, enforce single-session policy,
-- and audit every attempt in login_record.
--
-- DEPENDENCIES
--   - Services/00_Core/01_Normalization_Identity.sql (normalize_email)
--   - Services/01_Module1/00_Core_Mod1/01_Identity.sql (fn_user_exists_by_email, fn_get_user_by_email)
--   - Services/01_Module1/00_Core_Mod1/02_Validations.sql (validate_password, fn_is_account_active)
--   - Services/01_Module1/01_Authentication/00_Common_Auth.sql (has_active_sessions)
--   - Schema/01_Module1_User_Management/00_Tables_Mod1.sql (login_record)
--   - p_password is the API-layer hash (see 00_MiaCaoMigo_Engineering)
--
-- LOADED BY
--   - Bootstrap/Loaders/06_Services.sql
-- =========================================================

drop function if exists login_user(varchar, varchar, inet);

-- ---------------------------------------------------------
-- FUNCTION: login_user
-- ---------------------------------------------------------
-- INTENT:
--   Validate credentials and open a session only when policy allows.
-- FLOW:
--   1. Normalize email; fail fast when user does not exist.
--   2. Validate password hash; record failed attempts when invalid.
--   3. Check account activity and resolve id_usr.
--   4. Block login when another session is already open.
--   5. Insert login_record and return outcome flags to the API.
-- EXPECTED RESULT:
--   One result row with email, password_ok, account_active,
--   has_active_session, user_id, and login_success booleans.
-- ---------------------------------------------------------

create or replace function login_user(
    p_email varchar,
    p_password varchar,
    p_ip inet
)
returns table (
    email varchar,
    password_ok boolean,
    account_active boolean,
    has_active_session boolean,
    user_id integer,
    login_success boolean
)
language plpgsql
as $$

declare
    v_user_id integer;
    v_password_ok boolean;
    v_account_active boolean;
    v_has_session boolean;
    v_login_success boolean;

begin

    p_email := normalize_email(p_email);

    if not fn_user_exists_by_email(p_email) then

        raise notice 'Login attempt Fail (with non-existent email): %', p_email;
        insert into login_record (sig_tim_log, suc_log, ip_add_log, ema_log)
        values (now(), false, p_ip, p_email);

        return query
        select
            null::varchar,
            false::boolean,
            false::boolean,
            false::boolean,
            null::integer,
            false::boolean;

        return;

    end if;

    v_password_ok := validate_password(p_email, p_password);

    if not v_password_ok then

        raise notice 'Login attempt Fail (with incorrect password): %', p_email;
        insert into login_record (sig_tim_log, suc_log, ip_add_log, ema_log)
        values (now(), false, p_ip, p_email);

        return query
        select
            p_email::varchar,
            false::boolean,
            false::boolean,
            false::boolean,
            null::integer,
            false::boolean;

        return;

    end if;

    v_account_active := fn_is_account_active(p_email);
    v_user_id := fn_get_user_by_email(p_email);

    if not v_account_active then

        raise notice 'Login attempt Fail (with inactive account): %', p_email;
        insert into login_record (sig_tim_log, suc_log, ip_add_log, ema_log, id_usr)
        values (now(), false, p_ip, p_email, v_user_id);

        return query
        select
            p_email::varchar,
            true::boolean,
            false::boolean,
            false::boolean,
            v_user_id::integer,
            false::boolean;

        return;

    end if;

    v_has_session := has_active_sessions(p_email);

    if v_has_session then 
        raise notice 'Login attempt Fail (with active session): %', p_email;
    else
        raise notice 'Logged in successfully: %', p_email;
    end if;
    v_login_success := not v_has_session;

    insert into login_record (sig_tim_log, suc_log, ip_add_log, ema_log, id_usr)
    values (now(), v_login_success, p_ip, p_email, v_user_id);

    return query
    select
        p_email::varchar,
        true::boolean,
        true::boolean,
        v_has_session::boolean,
        v_user_id::integer,
        v_login_success::boolean;

end;

$$;
