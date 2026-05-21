-- =========================================================
-- QA FIXTURE — MODULE 3 — COMMERCIAL PRODUCT
-- =========================================================
-- TYPE:     fixture (data only)
-- REQUIRES: Bootstrap init_qa
-- PROVIDES: QA-PRO-001 (qa_product_int_p001_id)
-- =========================================================

do $$
declare
    v_fam int;
begin
    if not exists (select 1 from product where ref_pro = 'QA-PRO-001') then
        insert into family (nam_fam, des_fam)
        values ('QA Commercial', 'integrity and regression commercial fixture')
        returning id_fam into v_fam;

        insert into product (ref_pro, bar_pro, nam_pro, des_pro, pri_pro, iva_pro, id_fam, min_sto)
        values ('QA-PRO-001', '9000000000001', 'QA Integrity Product', 'QA', 14.50, 6.00, v_fam, 5);
    end if;
end;
$$;
