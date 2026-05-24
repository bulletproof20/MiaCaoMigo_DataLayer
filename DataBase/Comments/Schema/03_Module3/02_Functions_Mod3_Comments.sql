-- =========================================================
-- comments: functions - module 3
-- =========================================================
-- metadata documentation for stock, invoicing, and return
-- automation helpers used by commercial triggers.
-- =========================================================

comment on function fn_get_available_stock(integer) is
'aggregates positive stock quantities for a product across batches';

comment on function tfn_warn_low_stock() is
'raises a notice when stock falls at or below the product minimum after a sale';

comment on function tfn_check_stock_before_sale() is
'validates invoice lines against available stock before insert';

comment on function tfn_stock_after_sale() is
'decrements fifo batches after a sale line is inserted';

comment on function tfn_update_invoice_total() is
'recalculates invoice header totals when lines change';

comment on function tfn_return_restock() is
'restocks from return.id_pro; validates qty and product against id_inv_lin when set';

comment on function tfn_prevent_inactive_product_sale() is
'blocks invoice lines for inactivated products';

comment on function tfn_set_return_inactivation_date() is
'defaults return closure timestamps when omitted';
