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
        select f.id_fam into v_fam
          from family f
         where f.nam_fam = 'QA Commercial'
         limit 1;

        if v_fam is null then
            insert into family (nam_fam, des_fam)
            values ('QA Commercial', 'integrity QA commercial fixture')
            returning id_fam into v_fam;
        end if;

        insert into product (ref_pro, bar_pro, nam_pro, des_pro, pri_pro, iva_pro, id_fam, min_sto)
        values ('QA-PRO-001', '9000000000001', 'QA Integrity Product', 'QA', 14.50, 6.00, v_fam, 5);
    end if;
end;
$$;

select ref_pro, nam_pro
from product
where ref_pro like 'QA-%'
   or ref_pro like 'STRESS-%';
