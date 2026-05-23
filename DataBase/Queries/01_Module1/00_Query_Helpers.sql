-- =========================================================
-- MODULE 1 — USER MANAGEMENT
-- FILE: Queries/01_Module1/00_Query_Helpers.sql
-- =========================================================
-- PURPOSE:
--   Deterministic query helper functions for resolving
--   canonical rows through ranking and scoped filtering.
--
-- DOMAIN:
--   Authentication, employment lifecycle, schedules
--   and attendance tracking.
--
-- RESPONSIBILITIES:
--   - Resolve latest login attempts
--   - Resolve canonical employee records
--   - Resolve schedule source employees
--   - Resolve active clock-in sessions
--
-- ARCHITECTURE ROLE:
--   Read-only query-layer helpers consumed by services.
--
-- TECHNICAL STRATEGY:
--   - CTE-based filtering
--   - ROW_NUMBER ranking
--   - Deterministic tie-breaking
--
-- LOADED BY:
--   Bootstrap/Loaders/03_Integrity.sql
-- =========================================================


-- =========================================================
-- fn_pick_latest_login_record
-- =========================================================
-- PURPOSE:
--   Resolve the latest login record for a user,
--   optionally filtered by authentication outcome.
--
-- BEHAVIOUR:
--   Latest sig_tim_log wins; id_log breaks ties.
--
-- RELATIONSHIPS:
--   login_record
--
-- CONSUMED BY:
--   Authentication and audit workflows.
-- =========================================================
drop function if exists fn_pick_latest_login_record(int, boolean, boolean);

create or replace function fn_pick_latest_login_record(
    p_id_usr int,
    p_success_only boolean default false,
    p_failed_only boolean default false
)
returns setof login_record
language sql
stable
as $$
    with login_scope as (
        -- narrows attempts for the requested user and outcome filter
        select lr.*
        from login_record lr
        where lr.id_usr = p_id_usr
          and (
                (not p_success_only and not p_failed_only)
             or (p_success_only and not p_failed_only and lr.suc_log = true)
             or (p_failed_only and not p_success_only and lr.suc_log = false)
          )
    ),
    login_ranked as (
        -- ranks attempts deterministically (latest sign-in wins)
        select
            ls.*,
            row_number() over (
                order by ls.sig_tim_log desc, ls.id_log desc
            ) as login_rank
        from login_scope ls
    )
    select
        lr.id_log,
        lr.sig_tim_log,
        lr.sou_tim_log,
        lr.suc_log,
        lr.ip_add_log,
        lr.ema_log,
        lr.id_usr
    from login_ranked lr
    where lr.login_rank = 1;
$$;


-- =========================================================
-- fn_pick_most_recent_employee
-- =========================================================
-- PURPOSE:
--   Resolve the canonical employee row associated
--   with a user for renewal and lifecycle operations.
--
-- BEHAVIOUR:
--   - Active employments outrank inactive employments
--   - Latest dea_dat_emp wins among inactive rows
--   - Latest reg_dat_emp acts as secondary ordering
--   - id_emp acts as deterministic tie-breaker
--
-- RELATIONSHIPS:
--   - employee
--
-- CONSUMED BY:
--   - employment renewal workflows
--   - employee lifecycle services
--   - employment validation logic
-- =========================================================

drop function if exists fn_pick_most_recent_employee(int);

create or replace function fn_pick_most_recent_employee(p_id_usr int)
returns int
language sql
stable
as $$
    with employment_ranked as (
        select
            e.id_emp,
            row_number() over (
                partition by e.id_usr
                order by
                    (e.dea_dat_emp is null) desc,
                    e.dea_dat_emp desc nulls first,
                    e.reg_dat_emp desc,
                    e.id_emp desc
            ) as emp_rank
        from employee e
        where e.id_usr = p_id_usr
    )
    select er.id_emp
    from employment_ranked er
    where er.emp_rank = 1;
$$;


-- =========================================================
-- fn_pick_schedule_source_employee
-- =========================================================
-- PURPOSE:
--   Resolve the latest inactive employee that already
--   owns schedules available for replication workflows.
--
-- BEHAVIOUR:
--   - Only inactive employees are considered
--   - Employee must already possess schedules
--   - Latest dea_dat_emp wins
--   - id_emp acts as deterministic tie-breaker
--   - Preserves current global-selection strategy
--
-- RELATIONSHIPS:
--   - employee
--   - schedule
--
-- CONSUMED BY:
--   - schedule replication workflows
--   - onboarding assistance logic
-- =========================================================

drop function if exists fn_pick_schedule_source_employee();

create or replace function fn_pick_schedule_source_employee()
returns int
language sql
stable
as $$
    with inactive_with_schedule as (
        select
            e.id_emp,
            row_number() over (
                order by e.dea_dat_emp desc nulls last, e.id_emp desc
            ) as source_rank
        from employee e
        where e.dea_dat_emp is not null
          and exists (
                select 1
                from schedule s
                where s.id_emp = e.id_emp
          )
    )
    select iws.id_emp
    from inactive_with_schedule iws
    where iws.source_rank = 1;
$$;


-- =========================================================
-- fn_pick_open_clock_session
-- =========================================================
-- PURPOSE:
--   Resolve the active/open clock-in session associated
--   with an employee.
--
-- BEHAVIOUR:
--   - Only open clock sessions are considered
--   - Latest sta_dat_clk wins
--   - id_clk acts as deterministic tie-breaker
--   - Aligns with uq_clock_in_active_per_employee
--
-- RELATIONSHIPS:
--   - clock_in
--
-- CONSUMED BY:
--   - attendance workflows
--   - clock-in/clock-out services
--   - attendance validation logic
-- =========================================================

drop function if exists fn_pick_open_clock_session(int);

create or replace function fn_pick_open_clock_session(p_id_emp int)
returns int
language sql
stable
as $$
    with open_sessions as (
        select
            c.id_clk,
            row_number() over (
                order by c.sta_dat_clk desc, c.id_clk desc
            ) as session_rank
        from clock_in c
        where c.id_emp = p_id_emp
          and c.end_dat_clk is null
    )
    select os.id_clk
    from open_sessions os
    where os.session_rank = 1;
$$;
