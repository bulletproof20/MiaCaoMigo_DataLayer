-- =========================================================
-- INTEGRITY — MODULE 2 — DELIVERY DATE CONSISTENCY
-- =========================================================
-- TYPE:     01_Integrity
-- REQUIRES: init_qa + fixtures/seed/m2_animals_ownership.sql
-- RULE:     trg_check_delivery_date_consistency
-- CONTRACT: qa_animal_no_delivery_id(), qa_external_entity_shelter_id()
-- =========================================================
-- expected:
-- - delivery date earlier than rescue date blocked
-- =========================================================

do $$
declare
    v_ani int := qa_animal_no_delivery_id();
    v_ext int := qa_external_entity_shelter_id();
begin
    if v_ani is null or v_ext is null then
        raise notice 'FAIL: QA delivery fixture contracts missing (run fixtures Mod2)';
        return;
    end if;

    insert into delivery (
        reg_dat_del, res_dat_del, del_dat_del, res_loc_del, cli_sta_del, id_ext_ent, id_ani
    )
    values (
        now(),
        current_timestamp,
        current_timestamp - interval '2 days',
        'Integrity test location',
        'Test state',
        v_ext,
        v_ani
    );

    raise notice 'FAIL: delivery before rescue date should be blocked';
exception
    when others then
        if sqlerrm like '%Delivery date%' or sqlerrm like '%rescue%' then
            raise notice 'PASS: delivery date consistency blocked — %', sqlerrm;
        else
            raise notice 'FAIL: unexpected delivery date error — %', sqlerrm;
        end if;
end;
$$;
