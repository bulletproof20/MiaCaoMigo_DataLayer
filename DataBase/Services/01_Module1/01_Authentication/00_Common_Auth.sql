-- =========================================================
-- COMMON AUTH (MODULE 1)
-- FILE: Services/01_Module1/01_Authentication/00_Common_Auth.sql
-- =========================================================
-- PURPOSE:   Session existence checks and bulk session termination
-- DOMAIN:    Module 1 — login_record
-- LOADED BY: Bootstrap/Loaders/06_Services.sql
-- CLEANUP:   drop function if exists before create
-- =========================================================

drop function if exists has_active_sessions(varchar);

-- --- has_active_sessions ---
-- PURPOSE: detect open successful sessions for an email snapshot
-- BEHAVIOUR: uses vw_active_login_sessions (shared session semantics)
-- SIDE-EFFECTS: none

create or replace function has_active_sessions(p_email varchar)
returns boolean
language plpgsql
stable
as $$
declare
    v_exists boolean;
begin

    p_email := normalize_email(p_email);

    -- resolves latest active session rows for the normalized email
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

-- --- close_active_sessions_by_email ---
-- PURPOSE: enforce single-session policy on logout / admin close
-- BEHAVIOUR: updates only rows in vw_active_login_sessions scope
-- SIDE-EFFECTS: sets sou_tim_log on login_record

create or replace function close_active_sessions_by_email(p_email varchar)
returns void
language plpgsql
as $$
begin

    p_email := normalize_email(p_email);

    if has_active_sessions(p_email) then

        -- closes every open successful session for the email
        update login_record lr
        set sou_tim_log = now()
        from vw_active_login_sessions als
        where lr.id_log = als.id_log
          and als.ema_log = p_email;

    end if;

end;
$$;
