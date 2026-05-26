-- =========================================================
-- TIME TRACKING (MODULE 1 — ATTENDANCE)
-- BUSINESS WORKFLOW: sp_clock_toggle
-- =========================================================

drop procedure if exists sp_clock_toggle(int, out varchar);

create or replace procedure sp_clock_toggle(
    p_id_emp int,
    out p_action varchar
)
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

        p_action := 'CLOCK_OUT';
        return;
    end if;

    insert into clock_in (id_emp, sta_dat_clk)
    values (p_id_emp, current_timestamp);

    p_action := 'CLOCK_IN';

end;
$$;
