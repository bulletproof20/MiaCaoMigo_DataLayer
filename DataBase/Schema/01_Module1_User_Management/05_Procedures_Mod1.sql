-- =========================================================
-- MODULE 1 — USER MANAGEMENT
-- =========================================================
-- FILE: 05_Procedures_Mod1.sql
-- =========================================================
--
-- DESCRIPTION
-- Schema-layer technical procedures (jobs, hygiene automation).
-- Business workflows live in Services/01_Module1 (sp_*).
--
-- LOAD ORDER
-- Requires: 02_Functions_Mod1.sql, 07_Views_Mod1.sql
-- Must load before: 06_Jobs_Mod1.sql
-- =========================================================

-- Remove business workflows previously placed in Schema (reverted to Services).
drop procedure if exists sp_replicate_schedule(int);
drop procedure if exists sp_clock_toggle(int, out varchar);
drop procedure if exists sp_create_employee(
    varchar, text, varchar, varchar, varchar, varchar,
    varchar, varchar, varchar, int, out int
);
drop procedure if exists sp_create_client(
    varchar, text, varchar, varchar, varchar, varchar, varchar, varchar, out int
);
drop procedure if exists sp_renew_employee_record(int, int, out int);

-- =========================================================
-- Closes overnight clock-ins still missing an end timestamp
-- =========================================================

drop procedure if exists jpr_auto_close_clock_in_midnight();
create or replace procedure jpr_auto_close_clock_in_midnight()
language plpgsql
as $$
begin

    update clock_in
    set end_dat_clk = date_trunc('day', now())
    where end_dat_clk is null
      and sta_dat_clk < date_trunc('day', now());

end;
$$;


-- =========================================================
-- Marks expired pending absences as cancelled
-- =========================================================

drop procedure if exists jpr_auto_cancel_expired_absences();
create or replace procedure jpr_auto_cancel_expired_absences()
language plpgsql
as $$
begin

    update absence
    set sta_abs = 'cancelled'
    where sta_abs = 'pending'
      and end_dat_tim_abs < current_timestamp;

end;
$$;
