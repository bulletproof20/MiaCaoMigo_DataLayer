-- =========================================================
-- LOGOUT (MODULE 1 — AUTHENTICATION)
-- FILE: Services/01_Module1/01_Authentication/02_Logout.sql
-- =========================================================
-- PURPOSE:   Terminate the active session for an email
-- DOMAIN:    Module 1 — login_record
-- LOADED BY: Bootstrap/Loaders/06_Services.sql
-- CLEANUP:   drop function if exists before create
-- =========================================================

drop function if exists logout_user(varchar);

-- --- logout_user ---
-- PURPOSE: API logout — closes open successful sessions
-- BEHAVIOUR: reuses has_active_sessions + targets vw_active_login_sessions rows
-- SIDE-EFFECTS: sets sou_tim_log on matching login_record rows

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

    -- closes active sessions linked to the email snapshot
    update login_record lr
    set sou_tim_log = now()
    from vw_active_login_sessions als
    where lr.id_log = als.id_log
      and als.ema_log = p_email;

    get diagnostics v_closed = row_count;

    return v_closed > 0;

end;
$$;
