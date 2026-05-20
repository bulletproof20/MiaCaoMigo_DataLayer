-- =========================================================
-- INTEGRITY — MODULE 4 — APPOINTMENT SCHEDULING
-- =========================================================
-- TYPE:     01_Integrity
-- REQUIRES: 04_Loaders/03_TestData.sql
-- RULE:     trg_block_past_appointments; trg_validate_appointment_vet_specialty;
--           trg_validate_animal_client_relationship; sp_create_appointment
-- FIXTURES: id_cli 4, id_ani 3, id_emp 8, id_spe 1
-- =========================================================
-- expected:
-- - past appointment blocked
-- - vet without specialty blocked
-- - animal not owned by client blocked
-- - valid appointment succeeds
-- =========================================================

-- TEST 01 — valid create
do $$
begin
    call sp_create_appointment(4, 3, 8, 1, (now() + interval '5 days')::timestamp);
    raise notice 'PASS: sp_create_appointment succeeded for valid case';
exception
    when others then
        raise notice 'FAIL: valid appointment should succeed — %', sqlerrm;
end;
$$;

-- TEST 02 — past appointment
do $$
begin
    call sp_create_appointment(4, 3, 8, 1, (now() - interval '1 day')::timestamp);
    raise notice 'FAIL: past appointment should be blocked';
exception
    when others then
        if sqlerrm like '%passado%' then
            raise notice 'PASS: past appointment blocked';
        else
            raise notice 'FAIL: unexpected past appointment error — %', sqlerrm;
        end if;
end;
$$;

-- TEST 03 — vet specialty mismatch (emp 8 has spe 1,7 — use spe 2)
do $$
begin
    call sp_create_appointment(4, 3, 8, 2, (now() + interval '6 days')::timestamp);
    raise notice 'FAIL: vet specialty mismatch should be blocked';
exception
    when others then
        if sqlerrm like '%especialidade%' or sqlerrm like '%associado%' then
            raise notice 'PASS: vet specialty mismatch blocked';
        else
            raise notice 'FAIL: unexpected specialty error — %', sqlerrm;
        end if;
end;
$$;

-- TEST 04 — animal/client relationship (client 5 does not own animal 3)
do $$
begin
    call sp_create_appointment(5, 3, 8, 1, (now() + interval '7 days')::timestamp);
    raise notice 'FAIL: animal/client mismatch should be blocked';
exception
    when others then
        if sqlerrm like '%não pertence%' or sqlerrm like '%pertence%' then
            raise notice 'PASS: animal/client relationship blocked';
        else
            raise notice 'FAIL: unexpected animal/client error — %', sqlerrm;
        end if;
end;
$$;
