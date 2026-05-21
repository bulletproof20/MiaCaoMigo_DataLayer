-- =========================================================
-- QA BOOTSTRAP — MASTER DATA CONTRACT (post init_qa)
-- =========================================================
-- TYPE:     00_Bootstrap
-- REQUIRES: Bootstrap init_qa (MasterData loaded; no DemoData)
-- =========================================================

do $$
declare
    v_cnt int;
begin
    select count(*) into v_cnt from permission;
    if v_cnt <> 9 then
        raise notice 'FAIL: permission count expected 9, got %', v_cnt;
    else
        raise notice 'PASS: permission catalog count = 9';
    end if;

    select count(*) into v_cnt from profile;
    if v_cnt <> 4 then
        raise notice 'FAIL: profile count expected 4, got %', v_cnt;
    else
        raise notice 'PASS: profile catalog count = 4';
    end if;

    select count(*) into v_cnt from have;
    if v_cnt <> 15 then
        raise notice 'FAIL: have matrix count expected 15, got %', v_cnt;
    else
        raise notice 'PASS: have matrix count = 15';
    end if;

    if not exists (select 1 from specialty where id_spe = 1 and nam_spe = 'geral') then
        raise notice 'FAIL: default specialty id_spe=1 (geral) missing';
    else
        raise notice 'PASS: default specialty geral present';
    end if;

    if not exists (
        select 1 from user_account u
         where u.id_usr = 1 and u.ema_usr = 'platform.admin@ipca.pt'
    ) then
        raise notice 'FAIL: bootstrap administrator email contract mismatch';
    else
        raise notice 'PASS: bootstrap administrator email contract ok';
    end if;

    if not exists (
        select 1 from employee e
         where e.id_emp = 1 and e.ema_emp = '1@miacaomigo.pt' and e.dea_dat_emp is null
    ) then
        raise notice 'FAIL: bootstrap administrator employee contract mismatch';
    else
        raise notice 'PASS: bootstrap administrator employee contract ok';
    end if;

    if not exists (select 1 from occupies where id_emp = 1 and id_pro = 1) then
        raise notice 'FAIL: bootstrap admin occupies administrador profile';
    else
        raise notice 'PASS: bootstrap admin RBAC occupies row';
    end if;

    if exists (select 1 from veterinarian where id_emp = 1) then
        raise notice 'FAIL: bootstrap admin must not be registered as veterinarian';
    else
        raise notice 'PASS: bootstrap admin not in veterinarian';
    end if;

    if not exists (select 1 from pg_extension where extname = 'pg_cron') then
        raise notice 'FAIL: pg_cron extension missing';
    else
        raise notice 'PASS: pg_cron extension present';
    end if;

    if not exists (select 1 from pg_extension where extname = 'btree_gist') then
        raise notice 'FAIL: btree_gist extension missing';
    else
        raise notice 'PASS: btree_gist extension present';
    end if;

    if not exists (select 1 from user_account where id_usr = 1) then
        raise notice 'FAIL: bootstrap administrator user_account id_usr=1 missing';
    else
        raise notice 'PASS: bootstrap administrator user anchor present';
    end if;

    if not exists (select 1 from employee where id_emp = 1) then
        raise notice 'FAIL: bootstrap administrator employee id_emp=1 missing';
    else
        raise notice 'PASS: bootstrap administrator employee anchor present';
    end if;

    if exists (select 1 from animal where reg_id_ani like 'MCM-%' limit 1)
       or exists (select 1 from product where ref_pro like 'NUT-%' limit 1) then
        raise notice 'FAIL: DemoData markers detected — use init_qa (not init_demo) for CI';
    else
        raise notice 'PASS: no DemoData animal/product markers detected';
    end if;
end;
$$;
