-- =========================================================
-- INTEGRITY — MODULE 4 — PRESCRIPTION TIMING
-- =========================================================
-- TYPE:     01_Integrity
-- REQUIRES: 04_Loaders/03_TestData.sql
-- RULE:     trg_validate_prescription_timing
-- =========================================================
-- expected:
-- - prescription before appointment start blocked
-- - prescription after start allowed
-- =========================================================

do $$
declare
    v_id_app int;
begin
    call sp_create_appointment(4, 3, 8, 1, (now() + interval '10 days')::timestamp);

    select id_app into v_id_app
      from appointment
     where id_cli = 4
     order by id_app desc
     limit 1;

    insert into prescription (id_app, reg_dat_pre, des_pre)
    values (v_id_app, now() - interval '1 hour', 'integrity early prescription');

    raise notice 'FAIL: prescription before appointment start should be blocked';
exception
    when others then
        if sqlerrm like '%consulta%' or sqlerrm like '%emissão%' or sqlerrm like '%início%' then
            raise notice 'PASS: prescription timing blocked — %', sqlerrm;
        else
            raise notice 'FAIL: unexpected prescription timing error — %', sqlerrm;
        end if;
end;
$$;

do $$
declare
    v_id_app int;
begin
    call sp_create_appointment(4, 3, 8, 7, (now() + interval '11 days')::timestamp);

    select id_app into v_id_app
      from appointment
     where id_cli = 4
     order by id_app desc
     limit 1;

    call sp_start_appointment(v_id_app);

    insert into prescription (id_app, reg_dat_pre, des_pre)
    values (v_id_app, now(), 'integrity valid prescription');

    raise notice 'PASS: prescription after appointment start allowed';
exception
    when others then
        raise notice 'FAIL: valid prescription after start — %', sqlerrm;
end;
$$;
