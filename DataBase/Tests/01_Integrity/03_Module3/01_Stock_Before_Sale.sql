-- =========================================================
-- INTEGRITY — MODULE 3 — STOCK BEFORE SALE
-- =========================================================
-- TYPE:     01_Integrity
-- REQUIRES: Bootstrap init_demo (DemoData Mod3) + 03_TestData.sql
-- RULE:     trg_check_stock_before_sale / fn_check_stock_before_sale
-- FIXTURES: Demo product id_pro 2 (stock 8 units)
-- =========================================================
-- expected:
-- - invoice line exceeding available stock blocked
-- =========================================================

insert into stock (id_pro, bat_sto, qty_sto, ent_dat_sto, val_dat_sto)
select id_pro, 'INT-STOCK-01', 50, current_date, current_date + interval '1 year'
  from product where ref_pro = 'INT-P001';

do $$
declare
    v_id_inv int;
begin
    insert into invoice (dat_inv, bod_inv, sta_inv)
    values (current_timestamp, 'integrity stock test', 'pending')
    returning id_inv into v_id_inv;

    insert into invoice_line (id_inv, id_pro, qty_inv_lin, uni_pri_inv_lin, iva_inv_lin)
    select v_id_inv, id_pro, 999, 10.00, 23.00
      from product where ref_pro = 'INT-P001';

    raise notice 'FAIL: insufficient stock sale should be blocked';
exception
    when others then
        if sqlerrm like '%Stock insuficiente%' or sqlerrm like '%stock%' then
            raise notice 'PASS: insufficient stock blocked — %', sqlerrm;
        else
            raise notice 'FAIL: unexpected stock error — %', sqlerrm;
        end if;
end;
$$;
