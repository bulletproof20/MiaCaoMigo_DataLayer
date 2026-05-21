-- =========================================================
-- TIME TRACKING (MODULE 1 — ATTENDANCE)
-- FILE: Services/01_Module1/04_Attendance_Management/01_TimeTracking.sql
-- =========================================================
-- PURPOSE:   Toggle clock-in / clock-out for active employees
-- DOMAIN:    Module 1 — clock_in
-- LOADED BY: Bootstrap/Loaders/06_Services.sql
-- CLEANUP:   none (create or replace)
-- =========================================================

-- --- fn_clock_employee ---
-- PURPOSE: open or close the current attendance session
-- BEHAVIOUR: fn_pick_open_clock_session selects deterministic open row
-- SIDE-EFFECTS: INSERT or UPDATE on clock_in

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

    -- resolves open session with ROW_NUMBER (newest sta_dat_clk wins)
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
