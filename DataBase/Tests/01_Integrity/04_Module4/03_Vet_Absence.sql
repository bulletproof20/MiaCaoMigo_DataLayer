-- =========================================================
-- INTEGRITY — MODULE 4 — VET ABSENCE BLOCK
-- =========================================================
-- TYPE:     01_Integrity
-- REQUIRES: 04_Loaders/03_TestData.sql
-- RULE:     trg_block_appointment_if_vet_unavailable
-- FIXTURES: id_emp 8
-- =========================================================
-- expected:
-- - appointment during approved absence blocked
-- =========================================================

do $$
declare
    v_slot timestamp := now() + interval '9 days';
begin
    insert into absence (id_emp, sta_dat_tim_abs, end_dat_tim_abs, mot_abs, sta_abs, cre_tim_abs)
    values (
        8,
        v_slot - interval '1 hour',
        v_slot + interval '2 hours',
        'integrity vet absence block',
        'approved',
        current_timestamp
    );

    call sp_create_appointment(4, 3, 8, 1, v_slot);
    raise notice 'FAIL: appointment during vet absence should be blocked';
exception
    when others then
        if sqlerrm ilike '%indispon%' or sqlerrm ilike '%ausência%' or sqlerrm ilike '%ausencia%' then
            raise notice 'PASS: appointment during vet absence blocked';
        else
            raise notice 'FAIL: unexpected vet absence error — %', sqlerrm;
        end if;
end;
$$;
