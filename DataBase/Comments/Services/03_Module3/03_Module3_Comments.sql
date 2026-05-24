-- =========================================================
-- comments: services — module 3 (commercial management)
-- =========================================================

comment on function svc_list_product_stock_levels() is
'Public API: full catalog read from vw_product_stock_levels.';

comment on function svc_list_products_to_reorder() is
'Public API: reorder candidates from vw_products_to_reorder.';

comment on function svc_get_product_stock_level(integer) is
'Public API: single product row from vw_product_stock_levels.';

comment on function svc_receive_purchase(integer) is
'Public API: receive supplier purchase via sp_receive_purchase.';

comment on function svc_check_restock_needs() is
'Public API: operational restock notice via sp_check_restock_needs.';

comment on function fn_list_product_stock_levels() is
'DEPRECATED alias for svc_list_product_stock_levels.';

comment on function fn_list_products_to_reorder() is
'DEPRECATED alias for svc_list_products_to_reorder.';

comment on function fn_get_product_stock_level(integer) is
'DEPRECATED alias for svc_get_product_stock_level.';

comment on function fn_receive_purchase(integer) is
'DEPRECATED alias for svc_receive_purchase.';

comment on function fn_check_restock_needs() is
'DEPRECATED alias for svc_check_restock_needs.';
