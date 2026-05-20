-- =========================================================
-- INTEGRITY — MODULE 4 — APPOINTMENT OVERLAP (GiST)
-- =========================================================
-- TYPE:     01_Integrity
-- REQUIRES: 04_Loaders/03_TestData.sql (Module4 fixtures)
-- RULE:     ex_appointment_vet_overlap
-- FIXTURES: appointment id_app 1 — emp 8, now()+1 day
-- =========================================================
-- expected:
-- - overlapping scheduled slot for same veterinarian blocked
-- =========================================================

do $$
declare
    v_slot timestamp;
begin
    select sch_dat_app into v_slot
      from appointment
     where id_emp = 8
       and status_app = 'scheduled'
     order by id_app
     limit 1;

    if v_slot is null then
        raise notice 'FAIL: no scheduled fixture appointment for overlap test';
        return;
    end if;

    call sp_create_appointment(4, 3, 8, 1, v_slot);
    raise notice 'FAIL: overlapping appointment should be blocked';
exception
    when others then
        if sqlerrm like '%sobreposta%' or sqlerrm like '%overlap%' or sqlerrm like '%ex_appointment%' then
            raise notice 'PASS: overlapping appointment blocked — %', sqlerrm;
        else
            raise notice 'FAIL: unexpected overlap error — %', sqlerrm;
        end if;
end;
$$;
