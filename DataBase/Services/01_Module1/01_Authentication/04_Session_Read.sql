-- =========================================================
-- SESSION READ (MODULE 1 — AUTHENTICATION)
-- FILE: Services/01_Module1/01_Authentication/04_Session_Read.sql
-- =========================================================
--
-- PURPOSE
-- Query open login sessions and latest login_record rows per user.
--
-- DEPENDENCIES
--   - Schema/01_Module1_User_Management/07_Views_Mod1.sql (vw_active_login_sessions)
--   - Schema/01_Module1_User_Management/08_Query_Helpers_Mod1.sql (fn_pick_latest_login_record)
--   - Schema/01_Module1_User_Management/00_Tables_Mod1.sql (login_record, user_account)
--
-- LOADED BY
--   - Bootstrap/Loaders/06_Services.sql
-- =========================================================

drop function if exists is_user_logged_in(int);

-- ---------------------------------------------------------
-- FUNCTION: is_user_logged_in
-- ---------------------------------------------------------
-- INTENT:
--   Boolean guard for an open successful session by user id.
-- FLOW:
--   1. EXISTS on vw_active_login_sessions filtered by id_usr.
-- EXPECTED RESULT:
--   true when the user has an active session; otherwise false.
-- ---------------------------------------------------------

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

-- ---------------------------------------------------------
-- FUNCTION: get_active_sessions
-- ---------------------------------------------------------
-- INTENT:
--   List operational details for every open successful session.
-- FLOW:
--   1. Join vw_active_login_sessions with user_account.
--   2. ORDER BY sig_tim_log descending.
-- EXPECTED RESULT:
--   Setof rows: id_usr, name, login_time, ip.
-- ---------------------------------------------------------

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

-- ---------------------------------------------------------
-- FUNCTION: get_last_login
-- ---------------------------------------------------------
-- INTENT:
--   Fetch the latest login_record row regardless of outcome.
-- FLOW:
--   1. Delegate to fn_pick_latest_login_record (no outcome filter).
-- EXPECTED RESULT:
--   Zero or one full login_record row.
-- ---------------------------------------------------------

create or replace function get_last_login(p_id_usr int)
returns setof login_record
language sql
stable
as $$
    select lr.*
    from fn_pick_latest_login_record(p_id_usr, false, false) lr;
$$;


drop function if exists get_last_successful_login(int);

-- ---------------------------------------------------------
-- FUNCTION: get_last_successful_login
-- ---------------------------------------------------------
-- INTENT:
--   Fetch the latest successful login_record for a user.
-- FLOW:
--   1. Delegate to fn_pick_latest_login_record with success filter.
-- EXPECTED RESULT:
--   Zero or one login_record row where suc_log = true.
-- ---------------------------------------------------------

create or replace function get_last_successful_login(p_id_usr int)
returns setof login_record
language sql
stable
as $$
    select lr.*
    from fn_pick_latest_login_record(p_id_usr, true, false) lr;
$$;


drop function if exists get_last_failed_login(int);

-- ---------------------------------------------------------
-- FUNCTION: get_last_failed_login
-- ---------------------------------------------------------
-- INTENT:
--   Fetch the latest failed login_record for a user.
-- FLOW:
--   1. Delegate to fn_pick_latest_login_record with failure filter.
-- EXPECTED RESULT:
--   Zero or one login_record row where suc_log = false.
-- ---------------------------------------------------------

create or replace function get_last_failed_login(p_id_usr int)
returns setof login_record
language sql
stable
as $$
    select lr.*
    from fn_pick_latest_login_record(p_id_usr, false, true) lr;
$$;
