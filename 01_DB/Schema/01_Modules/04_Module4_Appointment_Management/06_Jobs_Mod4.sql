--=========================================================
-- JOBS - MODULE 4
-- Scheduled tasks for appointment management
--=========================================================


-- ┌───────────── min (0 - 59)
-- │ ┌────────────── hour (0 - 23)
-- │ │ ┌─────────────── day of month (1 - 31) or last day of the month ($)
-- │ │ │ ┌──────────────── month (1 - 12)
-- │ │ │ │ ┌───────────────── day of week (0 - 6) (0 to 6 are Sunday to
-- │ │ │ │ │                  Saturday, or use names; 7 is also Sunday)
-- │ │ │ │ │
-- │ │ │ │ │
-- * * * * *

--=========================================================
-- JOB 1: daily_appointment_warnings
-- Executes daily to generate warnings for appointments on the next day.
--=========================================================
select cron.schedule(
    'daily_appointment_warnings',
    '0 8 * * *',  -- Executes daily at 8:00 AM
    $$ CALL prc_generate_appointment_warnings(); $$
);

--=========================================================
-- JOB 2: daily_no_show_appointment_updater
-- Executes daily after midnight to mark missed appointments as 'No-Show'.
--=========================================================
select cron.schedule(
<<<<<<< HEAD:01_DB/Schema/01_Modules/04_Module4_Appointment_Management/06_Jobs_Mod4.sql
    'opened_appointments_auto_close',
    '30 22 * * 1-5',      -- Executa de meia em meia hora, das 08:00 às 19:30, de segunda a sexta-feira
    $$ CALL prc_auto_close_clock_in_midnight(); $$
=======
    'daily_no_show_appointment_updater',
    '5 0 * * *', -- Executes daily at 00:05 AM
    $$ CALL prc_auto_update_no_show_appointments(); $$
>>>>>>> main:01_DB/Schema/01_Modules/04_Module4_Appointment_Management/05_Jobs_Mod4.sql
);
--=========================================================