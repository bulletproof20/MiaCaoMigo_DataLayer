-- =========================================================
-- INTEGRITY — MODULE 4 — APPOINTMENT NOTIFICATIONS
-- =========================================================
-- TYPE:     01_Integrity
-- REQUIRES: 04_Loaders/03_TestData.sql (tomorrow appointment, id_cli 4)
-- RULE:     appointment_notification persistence (fixture-driven)
-- =========================================================
-- expected:
-- - notification row can be created for tomorrow appointment
-- =========================================================

do $$
declare
    v_count integer;
begin
    delete from appointment_notification where id_cli = 4;

    insert into appointment_notification (id_cli, id_app, msg_not, rea_not)
    select a.id_cli,
           a.id_app,
           'Reminder: your pet has an appointment scheduled for tomorrow.',
           false
      from appointment a
     where a.id_cli = 4
       and date(a.sch_dat_app) = current_date + interval '1 day';

    select count(*)
      into v_count
      from appointment_notification
     where id_cli = 4
       and msg_not ilike '%appointment scheduled for tomorrow%'
       and rea_not = false;

    if v_count >= 1 then
        raise notice 'PASS: tomorrow notification created for client 4 (count=%)', v_count;
    else
        raise notice 'FAIL: expected notification for client 4, found %', v_count;
    end if;
exception
    when others then
        raise notice 'FAIL: notification test — %', sqlerrm;
end;
$$;
