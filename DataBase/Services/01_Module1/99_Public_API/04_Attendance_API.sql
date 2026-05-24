-- =========================================================
-- MODULE 1 — PUBLIC API: ATTENDANCE
-- FILE: Services/01_Module1/99_Public_API/04_Attendance_API.sql
-- =========================================================
--
-- svc_* — application entry points (delegates to sp_clock_* / sp_replicate_*).
-- =========================================================

drop function if exists fn_clock_employee(int);
drop function if exists fn_replicate_previous_schedule(int);

drop function if exists svc_clock_toggle(int);
drop function if exists svc_replicate_schedule(int);

create or replace function svc_clock_toggle(p_id_emp int)
returns varchar(50)
language plpgsql
as $$
declare
    v_action varchar(50);
begin
    call sp_clock_toggle(p_id_emp, v_action);
    return v_action;
end;
$$;

create or replace function svc_replicate_schedule(p_id_emp int)
returns void
language plpgsql
as $$
begin
    call sp_replicate_schedule(p_id_emp);
end;
$$;
