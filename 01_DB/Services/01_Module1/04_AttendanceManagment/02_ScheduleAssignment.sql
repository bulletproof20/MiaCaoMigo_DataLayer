--=========================================================
-- FUNCTION: fn_replicate_previous_schedule
--=========================================================
-- Replicates the schedule from the most recent inactive
-- employee that has associated schedules.
--
-- Rules:
-- - Receives employee id
-- - Verifies if employee exists and is active
-- - Verifies if employee already has a schedule
-- - Searches inactive employees with schedules
-- - Selects the most recently deactivated employee
-- - Replicates all schedule entries to the target employee

create or replace function fn_replicate_previous_schedule (
    p_id_emp int
)
returns void
language plpgsql
as
$$
declare
    v_source_emp int;
begin

    --=====================================================
    -- Validate target employee
    --=====================================================
    if not exists (
        select 1
        from employee e
        where e.id_emp = p_id_emp
          and e.dea_dat_emp is null
    ) then
        raise exception
            'Employee % does not exist or is inactive.',
            p_id_emp;
    end if;

    --=====================================================
    -- Verify if employee already has schedule
    --=====================================================
    if exists (
        select 1
        from schedule s
        where s.id_emp = p_id_emp
    ) then
        raise exception
            'Employee % already has an associated schedule.',
            p_id_emp;
    end if;

    --=====================================================
    -- Get most recent inactive employee with schedule
    --=====================================================
    select e.id_emp
    into v_source_emp
    from employee e
    where e.dea_dat_emp is not null
      and exists (
            select 1
            from schedule s
            where s.id_emp = e.id_emp
      )
    order by e.dea_dat_emp desc
    limit 1;

    --=====================================================
    -- Validate source employee
    --=====================================================
    if v_source_emp is null then
        raise exception
            'No inactive employee with associated schedule found.';
    end if;

    --=====================================================
    -- Replicate schedule
    --=====================================================
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

select fn_replicate_previous_schedule(10);


-- Função para criar novo horário para um funcionário específico
-- Verifica se o atual funcionário existe e é ativo
-- Verifica se já tem horário associado
-- Se tiver horário associado inativa o registo de funcionário rplicando as informações num novo
-- cria um novo horário e associa ao novo id_emp.
-- 