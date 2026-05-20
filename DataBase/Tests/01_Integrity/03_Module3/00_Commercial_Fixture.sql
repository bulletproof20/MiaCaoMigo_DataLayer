-- =========================================================
-- INTEGRITY — MODULE 3 — COMMERCIAL FIXTURE (runner prefix)
-- =========================================================
-- TYPE:     01_Integrity (setup only — no assertions)
-- REQUIRES: init_demo OR empty commercial schema
-- RULE:     ensures product INT-P001 exists for Mod3 tests
-- =========================================================

do $$
declare
    v_fam int;
begin
    if not exists (select 1 from product where ref_pro = 'INT-P001') then
        insert into family (nam_fam, des_fam)
        values ('Integrity', 'integrity QA commercial')
        returning id_fam into v_fam;

        insert into product (ref_pro, bar_pro, nam_pro, des_pro, pri_pro, iva_pro, id_fam, min_sto)
        values ('INT-P001', '9000000000001', 'Integrity Product', 'QA', 14.50, 6.00, v_fam, 5);
    end if;
end;
$$;
