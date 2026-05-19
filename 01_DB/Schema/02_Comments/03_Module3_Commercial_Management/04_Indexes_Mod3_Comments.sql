-- =========================================================
-- comments: indexes - module 3
-- =========================================================

comment on index ix_stock_id_pro is
'supports stock availability lookups and FIFO scans by product';

comment on index ix_purchase_line_id_pur is
'supports purchase line aggregation when receiving orders';

comment on index ix_invoice_line_id_inv is
'supports invoice total recalculation from child lines';
