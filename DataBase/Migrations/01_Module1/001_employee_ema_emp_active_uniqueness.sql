-- =========================================================
-- MIGRATION: versioned employee — ema_emp active uniqueness
-- FILE: Migrations/01_Module1/001_employee_ema_emp_active_uniqueness.sql
-- =========================================================
--
-- PURPOSE
--   Replace global UNIQUE(ema_emp) with partial uniqueness on active
--   employment rows only, so historical versions may share the same
--   corporate email (sp_renew / schedule_revision / promote / demote).
--
-- APPLY ON
--   Existing databases already bootstrapped with uq_ema_emp.
--   Fresh installs: 00_Tables_Mod1.sql + 04_Indexes_Mod1.sql (no uq_ema_emp).
--
-- PREREQUISITE
--   Re-apply Services after this file:
--     Services/01_Module1/00_Core_Mod1/01_Identity.sql
--     Services/01_Module1/00_Core_Mod1/02_Validations.sql
-- =========================================================

\set ON_ERROR_STOP on

-- ---------------------------------------------------------
-- Pre-check: at most one active row per corporate email
-- ---------------------------------------------------------

do $$
declare
    v_dup_count int;
begin
    select count(*)::int
    into v_dup_count
    from (
        select e.ema_emp
        from employee e
        where e.dea_dat_emp is null
        group by e.ema_emp
        having count(*) > 1
    ) duplicates;

    if v_dup_count > 0 then
        raise exception
            'Migration aborted: % active employee row(s) share the same ema_emp. Resolve data before applying.',
            v_dup_count;
    end if;
end;
$$;

-- ---------------------------------------------------------
-- Replace constraint
-- ---------------------------------------------------------

alter table employee drop constraint if exists uq_ema_emp;

drop index if exists uq_employee_ema_emp_active;

create unique index uq_employee_ema_emp_active
on employee (ema_emp)
where dea_dat_emp is null;

comment on index uq_employee_ema_emp_active is
    'At most one active employment version per corporate email; historical rows may repeat ema_emp.';

\echo 'Migration 001_employee_ema_emp_active_uniqueness applied.'
