-- =========================================================
-- LOGIN (MODULE 1 — AUTHENTICATION)
-- BUSINESS WORKFLOW: sp_auth_login
-- =========================================================
--
-- PURPOSE
-- Authenticate a user by email and hash, enforce single-session policy,
-- and audit every attempt in login_record.
--
-- DEPENDENCIES
--   - Services/00_Core/01_Normalization_Identity.sql (fn_normalize_email)
--   - Services/01_Module1/00_Core_Mod1/01_Identity.sql (fn_user_exists_by_email, fn_get_user_by_email)
--   - Services/01_Module1/00_Core_Mod1/02_Validations.sql (fn_validate_password, fn_is_account_active)
--   - Services/01_Module1/01_Authentication/00_Common_Auth.sql (fn_has_active_sessions)
--   - Schema/01_Module1_User_Management/00_Tables_Mod1.sql (login_record)
--   - p_password is the API-layer hash (see 00_MiaCaoMigo_Engineering)
--
-- LOADED BY
--   - Bootstrap/Loaders/06_Services.sql
-- =========================================================

drop function if exists sp_auth_login(varchar, varchar, inet);

-- ---------------------------------------------------------
-- FUNCTION: sp_auth_login (business workflow)
-- ---------------------------------------------------------

create or replace function sp_auth_login(
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

    p_email := fn_normalize_email(p_email);

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

    v_password_ok := fn_validate_password(p_email, p_password);

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

    v_has_session := fn_has_active_sessions(p_email);

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
