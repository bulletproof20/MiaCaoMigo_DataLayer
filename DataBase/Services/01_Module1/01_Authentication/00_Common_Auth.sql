-- =========================================================
-- COMMON AUTH (MODULE 1)
-- FILE: Services/01_Module1/01_Authentication/00_Common_Auth.sql
-- =========================================================
--
-- PURPOSE
-- Internal session helpers (fn_*) over vw_active_login_sessions.
--
-- DEPENDENCIES
--   - Services/00_Core/01_Normalization_Identity.sql (fn_normalize_email)
--   - Schema/01_Module1_User_Management/07_Views_Mod1.sql (vw_active_login_sessions)
--   - Schema/01_Module1_User_Management/00_Tables_Mod1.sql (login_record)
--
-- LOADED BY
--   - Bootstrap/Loaders/06_Services.sql (before 01_Login.sql, 02_Logout.sql)
-- =========================================================

drop function if exists has_active_sessions(varchar);
drop function if exists fn_has_active_sessions(varchar);

create or replace function fn_has_active_sessions(p_email varchar)
returns boolean
language plpgsql
stable
as $$
declare
    v_exists boolean;
begin

    p_email := fn_normalize_email(p_email);

    select exists (
        select 1
        from vw_active_login_sessions als
        where als.ema_log = p_email
    )
    into v_exists;

    return v_exists;

end;
$$;


drop function if exists close_active_sessions_by_email(varchar);
drop function if exists fn_close_active_sessions_by_email(varchar);

create or replace function fn_close_active_sessions_by_email(p_email varchar)
returns boolean
language plpgsql
as $$
declare
    v_closed int;
begin

    p_email := fn_normalize_email(p_email);

    if not fn_has_active_sessions(p_email) then
        return false;
    end if;

    update login_record lr
    set sou_tim_log = greatest(
        current_timestamp,
        lr.sig_tim_log + interval '1 microsecond'
    )
    from vw_active_login_sessions als
    where lr.id_log = als.id_log
      and als.ema_log = p_email;

    get diagnostics v_closed = row_count;

    return v_closed > 0;

end;
$$;