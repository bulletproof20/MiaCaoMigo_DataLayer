-- =========================================================
-- MODULE 1 — PUBLIC API: AUTHENTICATION
-- FILE: Services/01_Module1/99_Public_API/01_Authentication_API.sql
-- =========================================================
--
-- svc_* — application entry points (delegates to sp_auth_*).
-- =========================================================

drop function if exists login_user(varchar, varchar, inet);
drop function if exists logout_user(varchar);
drop function if exists svc_auth_login(varchar, varchar, inet);
drop function if exists svc_auth_logout(varchar);

create or replace function svc_auth_login(
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
language sql
volatile
as $$
    select * from sp_auth_login(p_email, p_password, p_ip);
$$;

create or replace function svc_auth_logout(p_email varchar)
returns boolean
language sql
volatile
as $$
    select sp_auth_logout(p_email);
$$;
