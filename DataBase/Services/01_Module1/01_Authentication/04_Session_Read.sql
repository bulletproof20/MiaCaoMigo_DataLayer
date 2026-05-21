-- =========================================================
-- SESSION READ (MODULE 1 — AUTHENTICATION)
-- FILE: Services/01_Module1/01_Authentication/04_Session_Read.sql
-- =========================================================
-- PURPOSE:   Login session queries (active sessions, latest login audit)
-- DOMAIN:    Module 1 — login_record workflows
-- LOADED BY: Bootstrap/Loaders/06_Services.sql
-- CLEANUP:   drop function if exists before create
-- =========================================================
-- Ranking helpers: Schema/01_Module1_User_Management/08_Query_Helpers_Mod1.sql
-- Active session view: vw_active_login_sessions
-- =========================================================

drop function if exists is_user_logged_in(int);

-- --- is_user_logged_in ---
-- PURPOSE: boolean guard for open successful sessions per user id
-- BEHAVIOUR: reads vw_active_login_sessions (no ORDER BY ... LIMIT 1)

create or replace function is_user_logged_in(p_id_usr int)
returns boolean
language sql
stable
as $$
    select exists (
        select 1
        from vw_active_login_sessions als
        where als.id_usr = p_id_usr
    );
$$;


drop function if exists get_active_sessions();

-- --- get_active_sessions ---
-- PURPOSE: list open sessions for operational dashboards
-- BEHAVIOUR: joins active session view with user_account

create or replace function get_active_sessions()
returns table(
    id_usr int,
    name varchar,
    login_time timestamp,
    ip inet
)
language sql
stable
as $$
    select
        als.id_usr,
        u.nam_usr,
        als.sig_tim_log,
        als.ip_add_log
    from vw_active_login_sessions als
    inner join user_account u on u.id_usr = als.id_usr
    order by als.sig_tim_log desc;
$$;


drop function if exists get_last_login(int);

-- --- get_last_login ---
-- PURPOSE: latest login attempt regardless of outcome
-- BEHAVIOUR: delegates to fn_pick_latest_login_record (ROW_NUMBER)

create or replace function get_last_login(p_id_usr int)
returns setof login_record
language sql
stable
as $$
    select lr.*
    from fn_pick_latest_login_record(p_id_usr, false, false) lr;
$$;


drop function if exists get_last_successful_login(int);

-- --- get_last_successful_login ---
-- PURPOSE: latest successful authentication row
-- BEHAVIOUR: fn_pick_latest_login_record with success filter

create or replace function get_last_successful_login(p_id_usr int)
returns setof login_record
language sql
stable
as $$
    select lr.*
    from fn_pick_latest_login_record(p_id_usr, true, false) lr;
$$;


drop function if exists get_last_failed_login(int);

-- --- get_last_failed_login ---
-- PURPOSE: latest failed authentication row
-- BEHAVIOUR: fn_pick_latest_login_record with failure filter

create or replace function get_last_failed_login(p_id_usr int)
returns setof login_record
language sql
stable
as $$
    select lr.*
    from fn_pick_latest_login_record(p_id_usr, false, true) lr;
$$;
