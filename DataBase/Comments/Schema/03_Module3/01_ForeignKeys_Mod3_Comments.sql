--=========================================================
-- MODULE 3 — metadata: foreign keys
--=========================================================
-- Declarative FKs are defined in 01_ForeignKeys_Mod3.sql after
-- cross-module tables exist (including appointment from module 4).
-- Optional nullable references are not enforced at database level.
--=========================================================

comment on constraint fk_product_family on product is
'every product belongs to a catalog family';

comment on constraint fk_stock_product on stock is
'stock rows reference their product master data';

comment on constraint fk_purchase_employee on purchase is
'employee responsible for the purchase';

comment on constraint fk_purchase_line_purchase on purchase_line is
'lines roll up to a purchase header';

comment on constraint fk_purchase_line_product on purchase_line is
'lines reference catalog products';

comment on constraint fk_invoice_line_invoice on invoice_line is
'sales lines belong to an invoice';

comment on constraint fk_invoice_line_product on invoice_line is
'sales lines reference sellable products';

comment on constraint fk_return_client on "return" is
'return is attributed to one client';

comment on constraint fk_return_employee on "return" is
'return is processed by one responsible employee';

comment on constraint fk_return_product on "return" is
'returned product on the header (restock source of truth)';
