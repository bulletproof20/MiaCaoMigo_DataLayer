-- =========================================================
-- MODULE 3 — PUBLIC API: INVENTORY READ
-- FILE: Services/03_Module3/99_Public_API/01_Inventory_Read_API.sql
-- =========================================================

drop function if exists svc_get_product_stock_level(int);

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
