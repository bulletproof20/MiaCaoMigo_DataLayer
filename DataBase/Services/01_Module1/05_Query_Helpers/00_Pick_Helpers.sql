-- =========================================================
-- MODULE 1 — QUERY HELPERS (fn_pick_*)
-- FILE: Services/01_Module1/05_Query_Helpers/00_Pick_Helpers.sql
-- =========================================================
-- PURPOSE:
--   Deterministic query helper functions for resolving
--   canonical rows through ranking and scoped filtering.
--
-- DOMAIN:
--   Authentication, employment lifecycle, schedules
--   and attendance tracking.
--
-- ARCHITECTURE ROLE:
--   Internal read-only helpers consumed by Services workflows.
--
-- LOADED BY:
--   Bootstrap/Loaders/06_Services.sql (before Module 1 workflows)
-- =========================================================


-- =========================================================
-- fn_pick_latest_login_record
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
        select
            ls.*,
            row_number() over (
                order by ls.sig_tim_log desc, ls.id_log desc
            ) as login_rank
        from login_scope ls
    )

    select ls.*
    from login_scope ls
    where ls.id_log = (
        select lr.id_log
        from login_ranked lr
        where lr.login_rank = 1
    );

$$;


-- =========================================================
-- fn_pick_most_recent_employee
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
