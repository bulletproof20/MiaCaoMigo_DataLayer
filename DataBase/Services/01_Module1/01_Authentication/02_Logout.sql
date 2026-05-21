-- =========================================================
-- LOGOUT (MODULE 1 — AUTHENTICATION)
-- FILE: Services/01_Module1/01_Authentication/02_Logout.sql
-- =========================================================
--
-- PURPOSE
-- API-facing logout that closes open sessions for a given email.
--
-- DEPENDENCIES
--   - Services/01_Module1/01_Authentication/00_Common_Auth.sql (has_active_sessions)
--   - Services/00_Core/00_Normalization.sql (normalize_email)
--   - Schema/01_Module1_User_Management/07_Views_Mod1.sql (vw_active_login_sessions)
--   - Schema/01_Module1_User_Management/00_Tables_Mod1.sql (login_record)
--
-- LOADED BY
--   - Bootstrap/Loaders/06_Services.sql
-- =========================================================

drop function if exists logout_user(varchar);

-- ---------------------------------------------------------
-- FUNCTION: logout_user
-- ---------------------------------------------------------
-- INTENT:
--   Close the active session associated with an email when present.
-- FLOW:
--   1. Normalize email and detect active sessions.
--   2. Update open rows via the active-session view join.
--   3. Return whether any row was closed.
-- EXPECTED RESULT:
--   false when no session existed; true when at least one row was updated.
-- ---------------------------------------------------------

create or replace function logout_user(p_email varchar)
returns boolean
language plpgsql
as $$
declare
    v_has_session boolean;
    v_closed int;
begin

    p_email := normalize_email(p_email);

    v_has_session := has_active_sessions(p_email);

    if not v_has_session then
        return false;
    end if;

    update login_record lr
    set sou_tim_log = now()
    from vw_active_login_sessions als
    where lr.id_log = als.id_log
      and als.ema_log = p_email;

    get diagnostics v_closed = row_count;

    return v_closed > 0;

end;
$$;
