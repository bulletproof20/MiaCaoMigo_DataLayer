 --=========================================================
-- FUNCTION: fn_clock_employee
--=========================================================
-- Creates a clock-in if no active attendance exists.
-- If an active attendance exists (without end_dat_clk),
-- performs the corresponding clock-out.

create or replace function fn_clock_employee (
    p_id_emp int
)
returns varchar(50)
language plpgsql
as
$$
declare
    v_id_clk int;
begin

    -- Verify if employee exists and is active
    if not exists (
        select 1
        from employee e
        where e.id_emp = p_id_emp
          and e.dea_dat_emp is null
    ) then
        raise exception 'Employee % does not exist or is inactive.', p_id_emp;
    end if;

    -- Search for active clock-in
    select c.id_clk
    into v_id_clk
    from clock_in c
    where c.id_emp = p_id_emp
      and c.end_dat_clk is null
    order by c.sta_dat_clk desc
    limit 1;

    --=====================================================
    -- CLOCK-OUT
    --=====================================================
    if v_id_clk is not null then

        update clock_in
        set end_dat_clk = current_timestamp
        where id_clk = v_id_clk;

        return 'CLOCK_OUT';

    end if;

    --=====================================================
    -- CLOCK-IN
    --=====================================================
    insert into clock_in (
        id_emp,
        sta_dat_clk
    )
    values (
        p_id_emp,
        current_timestamp
    );

    return 'CLOCK_IN';

end;
$$;

select fn_clock_employee(3);
select * from clock_in
where id_emp = 3
order by sta_dat_clk desc;