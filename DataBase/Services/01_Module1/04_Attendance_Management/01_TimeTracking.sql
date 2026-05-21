-- =========================================================
-- TIME TRACKING (MODULE 1 — ATTENDANCE)
-- FILE: Services/01_Module1/04_Attendance_Management/01_TimeTracking.sql
-- =========================================================
--
-- PURPOSE
-- Toggle clock-in and clock-out for employees with active contracts.
--
-- DEPENDENCIES
--   - Schema/01_Module1_User_Management/07_Views_Mod1.sql (vw_active_employee_directory)
--   - Schema/01_Module1_User_Management/08_Query_Helpers_Mod1.sql (fn_pick_open_clock_session)
--   - Schema/01_Module1_User_Management/00_Tables_Mod1.sql (clock_in)
--   - Schema/01_Module1_User_Management/04_Indexes_Mod1.sql (uq_clock_in_active_per_employee)
--
-- LOADED BY
--   - Bootstrap/Loaders/06_Services.sql
-- =========================================================

-- ---------------------------------------------------------
-- FUNCTION: fn_clock_employee
-- ---------------------------------------------------------
-- INTENT:
--   Open a new attendance session or close the current open session.
-- FLOW:
--   1. Validate employee is active in vw_active_employee_directory.
--   2. Resolve open clock-in via fn_pick_open_clock_session.
--   3. UPDATE end_dat_clk or INSERT a new clock_in row.
-- EXPECTED RESULT:
--   'CLOCK_OUT' when a session was closed; 'CLOCK_IN' when a new session started.
-- ---------------------------------------------------------

create or replace function fn_clock_employee(p_id_emp int)
returns varchar(50)
language plpgsql
as $$
declare
    v_id_clk int;
begin

    if not exists (
        select 1
        from vw_active_employee_directory d
        where d.id_emp = p_id_emp
    ) then
        raise exception 'Employee % does not exist or is inactive.', p_id_emp;
    end if;

    v_id_clk := fn_pick_open_clock_session(p_id_emp);

    if v_id_clk is not null then

        update clock_in
        set end_dat_clk = current_timestamp
        where id_clk = v_id_clk;

        return 'CLOCK_OUT';
    end if;

    insert into clock_in (id_emp, sta_dat_clk)
    values (p_id_emp, current_timestamp);

    return 'CLOCK_IN';

end;
$$;
