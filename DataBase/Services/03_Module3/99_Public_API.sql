-- =========================================================
-- MODULE 3 — PUBLIC API (svc_*)
-- FILE: Services/03_Module3/99_Public_API.sql
-- =========================================================
--
-- Sole Services layer for Module 3: public entry points only.
-- Write workflows delegate to Schema sp_receive_purchase / sp_check_restock_needs.
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

