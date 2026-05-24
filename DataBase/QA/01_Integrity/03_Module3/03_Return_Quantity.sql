-- =========================================================
-- INTEGRITY — MODULE 3 — RETURN QUANTITY
-- =========================================================
-- TYPE:     01_Integrity
-- REQUIRES: init_qa + fixtures/03_Module3/01_Commercial_Product.sql
-- RULE:     trg_return_restock / tfn_return_restock
-- CONTRACT: qa_product_int_p001_id()
-- =========================================================
-- expected:
-- - return quantity greater than sold quantity blocked
-- =========================================================

insert into stock (id_pro, bat_sto, qty_sto, ent_dat_sto, val_dat_sto)
select qa_product_int_p001_id(), 'INT-STOCK-03', 20, current_date, current_date + interval '1 year'
 where not exists (
    select 1 from stock s
     where s.id_pro = qa_product_int_p001_id() and s.bat_sto = 'INT-STOCK-03'
 );

do $$
declare
    v_id_inv int;
    v_id_lin int;
    v_id_pro int := qa_product_int_p001_id();
begin
    if v_id_pro is null then
        raise notice 'FAIL: qa_product_int_p001_id contract missing (run fixtures Mod3)';
        return;
    end if;
    insert into invoice (dat_inv, bod_inv, sta_inv)
    values (current_timestamp, 'integrity return test', 'pending')
    returning id_inv into v_id_inv;

    insert into invoice_line (id_inv, id_pro, qty_inv_lin, uni_pri_inv_lin, iva_inv_lin)
    values (v_id_inv, v_id_pro, 2, 10.00, 23.00)
    returning id_inv_lin into v_id_lin;

    insert into "return" (id_cli, id_emp, id_pro, id_inv_lin, qty_ret, mot_ret)
    values (
        qa_client_active_id(),
        qa_registrar_emp_id(),
        v_id_pro,
        v_id_lin,
        99,
        'integrity excessive return'
    );

    raise notice 'FAIL: excessive return quantity should be blocked';
exception
    when others then
        if sqlerrm like '%devolvida%' or sqlerrm like '%vendida%' or sqlerrm like '%excede%' then
            raise notice 'PASS: excessive return quantity blocked — %', sqlerrm;
        else
            raise notice 'FAIL: unexpected return quantity error — %', sqlerrm;
        end if;
end;
$$;
