-- =========================================================
-- INTEGRITY — MODULE 3 — INACTIVE PRODUCT SALE
-- =========================================================
-- TYPE:     01_Integrity
-- REQUIRES: init_qa + fixtures/03_Module3/01_Commercial_Product.sql
-- RULE:     trg_prevent_inactive_product_sale
-- CONTRACT: qa_product_int_p001_id()
-- =========================================================
-- expected:
-- - sale line for inactive product blocked
-- =========================================================

insert into stock (id_pro, bat_sto, qty_sto, ent_dat_sto, val_dat_sto)
select qa_product_int_p001_id(), 'INT-STOCK-02', 20, current_date, current_date + interval '1 year'
 where not exists (
    select 1 from stock s
     where s.id_pro = qa_product_int_p001_id() and s.bat_sto = 'INT-STOCK-02'
 );

do $$
declare
    v_id_inv int;
    v_id_pro int := qa_product_int_p001_id();
begin
    if v_id_pro is null then
        raise notice 'FAIL: qa_product_int_p001_id contract missing (run fixtures Mod3)';
        return;
    end if;
    update product set ina_dat_pro = current_timestamp where id_pro = v_id_pro;

    insert into invoice (dat_inv, bod_inv, sta_inv)
    values (current_timestamp, 'integrity inactive product test', 'pending')
    returning id_inv into v_id_inv;

    insert into invoice_line (id_inv, id_pro, qty_inv_lin, uni_pri_inv_lin, iva_inv_lin)
    values (v_id_inv, v_id_pro, 1, 5.00, 23.00);

    raise notice 'FAIL: inactive product sale should be blocked';

    update product set ina_dat_pro = null where id_pro = v_id_pro;
exception
    when others then
        update product set ina_dat_pro = null where id_pro = v_id_pro;

        if sqlerrm like '%inativo%' or sqlerrm like '%inactive%' then
            raise notice 'PASS: inactive product sale blocked — %', sqlerrm;
        else
            raise notice 'FAIL: unexpected inactive product error — %', sqlerrm;
        end if;
end;
$$;
