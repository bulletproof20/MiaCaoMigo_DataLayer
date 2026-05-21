-- =========================================================
-- COMMON AUTH (MODULE 1)
-- FILE: Services/01_Module1/01_Authentication/00_Common_Auth.sql
-- =========================================================
--
-- PURPOSE
-- Shared helpers for detecting and closing open login sessions
-- before login/logout orchestration runs.
--
-- DEPENDENCIES
--   - Services/00_Core/00_Normalization.sql (normalize_email)
--   - Schema/01_Module1_User_Management/07_Views_Mod1.sql (vw_active_login_sessions)
--   - Schema/01_Module1_User_Management/00_Tables_Mod1.sql (login_record)
--
-- LOADED BY
--   - Bootstrap/Loaders/06_Services.sql (before 01_Login.sql, 02_Logout.sql)
-- =========================================================

drop function if exists has_active_sessions(varchar);

-- ---------------------------------------------------------
-- FUNCTION: has_active_sessions
-- ---------------------------------------------------------
-- INTENT:
--   Check whether an email currently has an open successful session.
-- FLOW:
--   1. Normalize the email input.
--   2. Probe vw_active_login_sessions for a matching row.
-- EXPECTED RESULT:
--   true when at least one active session exists; otherwise false.
-- ---------------------------------------------------------

create or replace function has_active_sessions(p_email varchar)
returns boolean
language plpgsql
stable
as $$
declare
    v_exists boolean;
begin

    p_email := normalize_email(p_email);

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

-- ---------------------------------------------------------
-- FUNCTION: close_active_sessions_by_email
-- ---------------------------------------------------------
-- INTENT:
--   Terminate every open successful session tied to an email.
-- FLOW:
--   1. Normalize email and skip when no active session exists.
--   2. Update login_record rows referenced by the active-session view.
-- EXPECTED RESULT:
--   void; matching rows receive sou_tim_log = now().
-- ---------------------------------------------------------

create or replace function close_active_sessions_by_email(p_email varchar)
returns void
language plpgsql
as $$
begin

    p_email := normalize_email(p_email);

    if has_active_sessions(p_email) then

        update login_record lr
        set sou_tim_log = now()
        from vw_active_login_sessions als
        where lr.id_log = als.id_log
          and als.ema_log = p_email;

    end if;

end;
$$;
