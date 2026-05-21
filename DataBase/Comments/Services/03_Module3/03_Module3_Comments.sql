-- =========================================================
-- comments: services — module 3 (commercial management)
-- =========================================================

-- inventory reads
comment on function fn_list_product_stock_levels() is
'Full catalog read from vw_product_stock_levels ordered by product name.';

comment on function fn_list_products_to_reorder() is
'Reorder candidates from vw_products_to_reorder (at or below minimum stock).';

comment on function fn_get_product_stock_level(integer) is
'Single product row from vw_product_stock_levels.';

-- commercial writes
comment on function fn_receive_purchase(integer) is
'Application wrapper for sp_receive_purchase (marks purchase received and materializes stock).';

comment on function fn_check_restock_needs() is
'Application wrapper for sp_check_restock_needs (notices when vw_products_to_reorder is non-empty).';
