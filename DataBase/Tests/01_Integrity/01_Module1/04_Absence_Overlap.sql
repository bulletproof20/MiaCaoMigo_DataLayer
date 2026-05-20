-- =========================================================
-- INTEGRITY — MODULE 1 — ABSENCE OVERLAP
-- =========================================================
-- TYPE:     01_Integrity
-- REQUIRES: 04_Loaders/03_TestData.sql
-- RULE:     trg_block_absence_overlap_by_user / fn_block_absence_overlap_by_user
-- FIXTURES: id_emp 21 pending absence (+15 to +16 days)
-- =========================================================
-- expected:
-- - overlapping absence for same employee blocked
-- =========================================================

do $$
begin
    insert into absence (id_emp, sta_dat_tim_abs, end_dat_tim_abs, mot_abs, sta_abs, cre_tim_abs)
    values (
        21,
        current_timestamp + interval '15 days 2 hours',
        current_timestamp + interval '15 days 8 hours',
        'integrity overlapping absence',
        'pending',
        current_timestamp
    );

    raise notice 'FAIL: overlapping absence should be blocked';
exception
    when others then
        if sqlerrm like '%overlapping%' or sqlerrm like '%absence%' then
            raise notice 'PASS: overlapping absence blocked — %', sqlerrm;
        else
            raise notice 'FAIL: unexpected absence overlap error — %', sqlerrm;
        end if;
end;
$$;
