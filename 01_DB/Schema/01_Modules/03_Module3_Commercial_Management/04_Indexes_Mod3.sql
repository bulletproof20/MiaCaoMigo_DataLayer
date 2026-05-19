-- =========================================================
-- MODULE 3 — COMMERCIAL MANAGEMENT
-- =========================================================
-- FILE: 04_Indexes_Mod3.sql
-- =========================================================
--
-- DESCRIPTION
-- ---------------------------------------------------------
-- Secondary indexes supporting catalog, stock, and billing lookups.
--
-- LOAD ORDER
-- ---------------------------------------------------------
-- Requires:
-- - 00_Tables_Mod3.sql and 01_ForeignKeys_Mod3.sql
-- =========================================================

-- =========================================================
-- stock — product lookup for availability calculations
-- =========================================================

create index ix_stock_id_pro
on stock (id_pro);


-- =========================================================
-- purchase_line — parent purchase aggregation
-- =========================================================

create index ix_purchase_line_id_pur
on purchase_line (id_pur);


-- =========================================================
-- invoice_line — parent invoice total maintenance
-- =========================================================

create index ix_invoice_line_id_inv
on invoice_line (id_inv);
