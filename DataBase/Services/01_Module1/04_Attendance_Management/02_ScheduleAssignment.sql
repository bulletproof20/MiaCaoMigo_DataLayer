-- =========================================================
-- SCHEDULE ASSIGNMENT (MODULE 1 — ATTENDANCE)
-- BUSINESS WORKFLOW: sp_replicate_schedule
-- =========================================================

drop procedure if exists sp_replicate_schedule(int);

create or replace procedure sp_replicate_schedule(p_id_emp int)
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
