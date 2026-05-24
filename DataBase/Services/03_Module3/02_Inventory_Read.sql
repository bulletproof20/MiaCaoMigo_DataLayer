-- =========================================================
-- MODULE 3 — INVENTORY READ (svc_* public API)
-- FILE: 02_Inventory_Read.sql
-- =========================================================

drop function if exists svc_list_product_stock_levels();
drop function if exists svc_list_products_to_reorder();
drop function if exists svc_get_product_stock_level(int);

create function svc_list_product_stock_levels()
returns setof vw_product_stock_levels
language sql
stable
parallel safe
as $$
    select * from vw_product_stock_levels order by nam_pro;
$$;

create function svc_list_products_to_reorder()
returns setof vw_products_to_reorder
language sql
stable
parallel safe
as $$
    select * from vw_products_to_reorder order by nam_pro;
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

-- deprecated aliases (Phase 1)
drop function if exists fn_list_product_stock_levels();
create function fn_list_product_stock_levels()
returns setof vw_product_stock_levels
language sql stable parallel safe as $$
    select * from svc_list_product_stock_levels();
$$;

drop function if exists fn_list_products_to_reorder();
create function fn_list_products_to_reorder()
returns setof vw_products_to_reorder
language sql stable parallel safe as $$
    select * from svc_list_products_to_reorder();
$$;

drop function if exists fn_get_product_stock_level(int);
create function fn_get_product_stock_level(p_id_pro int)
returns vw_product_stock_levels
language sql stable parallel safe as $$
    select svc_get_product_stock_level(p_id_pro);
$$;
