-- =========================================================
-- SCHEDULE ASSIGNMENT (MODULE 1 — ATTENDANCE)
-- FILE: Services/01_Module1/04_Attendance_Management/02_ScheduleAssignment.sql
-- =========================================================
--
-- PURPOSE
-- Copy weekly schedule rows onto a new active employee from a
-- historical employment record that already had a schedule.
--
-- DEPENDENCIES
--   - Schema/01_Module1_User_Management/07_Views_Mod1.sql (vw_active_employee_directory)
--   - Schema/01_Module1_User_Management/08_Query_Helpers_Mod1.sql (fn_pick_schedule_source_employee)
--   - Schema/01_Module1_User_Management/00_Tables_Mod1.sql (schedule, employee)
--
-- LOADED BY
--   - Bootstrap/Loaders/06_Services.sql
-- =========================================================

-- ---------------------------------------------------------
-- FUNCTION: fn_replicate_previous_schedule
-- ---------------------------------------------------------
-- INTENT:
--   Bootstrap schedule rows for an employee without an existing schedule.
-- FLOW:
--   1. Validate target employee is active and has no schedule yet.
--   2. Pick source employee via fn_pick_schedule_source_employee.
--   3. INSERT schedule rows cloned from the source id_emp.
-- EXPECTED RESULT:
--   void; target employee receives a copy of the source weekly pattern.
-- ---------------------------------------------------------

create or replace function fn_replicate_previous_schedule(p_id_emp int)
returns void
language plpgsql
as $$
declare
    v_source_emp int;
begin

    if not exists (
        select 1
        from vw_active_employee_directory as d
        where d.id_emp = p_id_emp
    ) then
        raise exception
            'Employee % does not exist or is inactive.',
            p_id_emp;
    end if;

    if exists (
        select 1
        from schedule as s
        where s.id_emp = p_id_emp
    ) then
        raise exception
            'Employee % already has an associated schedule.',
            p_id_emp;
    end if;

    v_source_emp := fn_pick_schedule_source_employee();

    if v_source_emp is null then
        raise exception
            'No inactive employee with associated schedule found.';
    end if;

    insert into schedule (
        id_emp,
        day_wee_sch,
        sta_tim_sch,
        fin_hou_sch
    )
    select
        p_id_emp,
        s.day_wee_sch,
        s.sta_tim_sch,
        s.fin_hou_sch
    from schedule as s
    where s.id_emp = v_source_emp;

end;
$$;
