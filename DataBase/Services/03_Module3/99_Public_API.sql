-- =========================================================
-- MODULE 3 — PUBLIC API (svc_*)
-- FILE: Services/03_Module3/99_Public_API.sql
-- =========================================================
--
-- Sole Services layer for Module 3: public entry points only.
-- Write workflows delegate to Schema sp_receive_purchase / sp_check_restock_needs.
-- =========================================================

drop function if exists svc_list_product_stock_levels();
drop function if exists svc_list_products_to_reorder();
drop function if exists svc_get_product_stock_level(int);
drop function if exists svc_receive_purchase(int);
drop function if exists svc_check_restock_needs();

create function svc_list_product_stock_levels()
returns setof vw_product_stock_levels
language sql
stable
parallel safe
as $$
    select *
    from vw_product_stock_levels
    order by nam_pro;
$$;

create function svc_list_products_to_reorder()
returns setof vw_products_to_reorder
language sql
stable
parallel safe
as $$
    select *
    from vw_products_to_reorder
    order by nam_pro;
$$;

create function svc_get_product_stock_level(p_id_pro int)
returns vw_product_stock_levels
language sql
stable
parallel safe
as $$
    select *
    from vw_product_stock_levels
    where id_pro = p_id_pro;
$$;

create function svc_receive_purchase(p_id_pur int)
returns void
language plpgsql
as $$
begin
    call sp_receive_purchase(p_id_pur);
end;
$$;

create function svc_check_restock_needs()
returns void
language plpgsql
as $$
begin
    call sp_check_restock_needs();
end;
$$;
