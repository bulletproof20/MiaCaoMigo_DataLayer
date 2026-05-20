-- =========================================================
-- INTEGRITY — MODULE 1 — SCHEDULE EXCLUSION
-- =========================================================
-- TYPE:     01_Integrity
-- REQUIRES: 04_Loaders/03_TestData.sql
-- RULE:     ex_schedule_overlap (GiST on schedule)
-- FIXTURES: id_emp 1 Monday 08:00–18:00 (CreationStress)
-- =========================================================
-- expected:
-- - overlapping schedule interval for same employee/day blocked
-- =========================================================

do $$
begin
    insert into schedule (id_emp, day_wee_sch, sta_tim_sch, fin_hou_sch)
    values (1, 1, '10:00', '12:00');

    raise notice 'FAIL: overlapping schedule should be blocked';
exception
    when others then
        if sqlerrm like '%overlap%' or sqlerrm like '%ex_schedule%' or sqlerrm like '%conflict%' then
            raise notice 'PASS: schedule overlap blocked — %', sqlerrm;
        else
            raise notice 'FAIL: unexpected schedule exclusion error — %', sqlerrm;
        end if;
end;
$$;
