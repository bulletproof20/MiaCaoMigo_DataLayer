-- =========================================================
-- SCHEDULE ASSIGNMENT (MODULE 1 — ATTENDANCE)
-- FILE: Services/01_Module1/04_Attendance_Management/02_ScheduleAssignment.sql
-- =========================================================
-- PURPOSE:   Copy schedule rows from a historical employment record
-- DOMAIN:    Module 1 — schedule / employee history
-- LOADED BY: Bootstrap/Loaders/06_Services.sql
-- CLEANUP:   none (create or replace)
-- =========================================================

-- --- fn_replicate_previous_schedule ---
-- PURPOSE: bootstrap weekly schedule for a new active employee row
-- BEHAVIOUR: source picked via fn_pick_schedule_source_employee (ROW_NUMBER)
-- SIDE-EFFECTS: INSERT schedule rows

create or replace function fn_replicate_previous_schedule(p_id_emp int)
returns void
language plpgsql
as $$
declare
    v_source_emp int;
begin

    if not exists (
        select 1
        from vw_active_employee_directory d
        where d.id_emp = p_id_emp
    ) then
        raise exception
            'Employee % does not exist or is inactive.',
            p_id_emp;
    end if;

    if exists (
        select 1
        from schedule s
        where s.id_emp = p_id_emp
    ) then
        raise exception
            'Employee % already has an associated schedule.',
            p_id_emp;
    end if;

    -- ranks inactive employees that already own schedules (legacy global scope)
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
    from schedule s
    where s.id_emp = v_source_emp;

end;
$$;
