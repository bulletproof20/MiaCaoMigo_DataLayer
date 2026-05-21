-- =========================================================
-- EMPLOYEE RENEWAL (MODULE 1 — ROLE CHANGE)
-- FILE: Services/01_Module1/03_Role_Change/00_CommonManagement.sql
-- =========================================================
--
-- PURPOSE
-- Renew employment by inactivating the latest employee row and
-- inserting a successor record with duplicated contact data.
--
-- DEPENDENCIES
--   - Schema/01_Module1_User_Management/08_Query_Helpers_Mod1.sql (fn_pick_most_recent_employee)
--   - Schema/01_Module1_User_Management/00_Tables_Mod1.sql (employee)
--   - Services/01_Module1/03_Role_Change/*.sql (callers)
--
-- LOADED BY
--   - Bootstrap/Loaders/06_Services.sql (before role-change workflows)
-- =========================================================

drop function if exists fn_renew_employee_record(int, int);

-- ---------------------------------------------------------
-- FUNCTION: fn_renew_employee_record
-- ---------------------------------------------------------
-- INTENT:
--   Replace the most recent employment row while preserving user linkage.
-- FLOW:
--   1. Validate registering employee is active.
--   2. Lock target row and read user id + active flag.
--   3. Confirm target is the ranked most recent row for that user.
--   4. Inactivate when still active, then INSERT successor employee row.
-- EXPECTED RESULT:
--   id_emp of the newly created active employment record.
-- ---------------------------------------------------------

create or replace function fn_renew_employee_record(
    p_id_emp int,
    p_id_emp_reg int
)
returns int
language plpgsql
as $$
declare
    v_id_usr int;
    v_is_active boolean;
    v_id_emp_most_recent int;
    v_id_emp_new int;
begin

    if not exists (
        select 1
        from employee e
        where e.id_emp = p_id_emp_reg
          and e.dea_dat_emp is null
    ) then
        raise exception using
            message = 'Registering employee is invalid or inactive.';
    end if;

    select
        e.id_usr,
        e.dea_dat_emp is null
    into
        v_id_usr,
        v_is_active
    from employee e
    where e.id_emp = p_id_emp
    for update;

    if v_id_usr is null then
        raise exception using
            message = 'Employee record not found for id ' || p_id_emp;
    end if;

    v_id_emp_most_recent := fn_pick_most_recent_employee(v_id_usr);

    if v_id_emp_most_recent is distinct from p_id_emp then
        raise exception using
            message =
                'Employee id ' || p_id_emp ||
                ' is not the most recent record for user id ' || v_id_usr;
    end if;

    if v_is_active then

        update employee
        set
            dea_dat_emp = current_timestamp,
            aut_ina_emp = p_id_emp_reg
        where id_emp = p_id_emp;

    else
        raise notice
            'Employee id % is already inactive; replacement will continue.',
            p_id_emp;
    end if;

    insert into employee (
        id_usr,
        pho_emp,
        pho_emg,
        ema_emp,
        pas_emp,
        reg_dat_emp,
        aut_reg_emp
    )
    select
        e.id_usr,
        e.pho_emp,
        e.pho_emg,
        e.ema_emp,
        e.pas_emp,
        current_timestamp,
        p_id_emp_reg
    from employee e
    where e.id_emp = p_id_emp
    returning id_emp
    into v_id_emp_new;

    return v_id_emp_new;

exception
    when others then
        raise exception using
            message = 'fn_renew_employee_record failed: ' || sqlerrm,
            errcode = sqlstate;
end;
$$;
