-- =========================================================
-- MASTER DATA — MODULE 3 (COMMERCIAL MANAGEMENT)
-- FILE: 03_Module3_MasterData.sql
-- =========================================================
--
-- TIER
--   MasterData — catalog anchor only.
--
-- PURPOSE
--   One product family so the commercial module can create products
--   (product.id_fam is NOT NULL). No products, stock, or invoices here.
--
-- LOADED BY
--   Bootstrap/Loaders/11_MasterData.sql (after 02_Module2_MasterData.sql).
--
-- PREREQUISITES
--   No foreign keys to Modules 1–2.
--
-- STABLE IDENTIFIERS
--   id_fam 1 — default catalog family
--
-- NEXT AUTO IDS AFTER THIS FILE
--   family.id_fam → 2
-- =========================================================

set timezone to 'Europe/Lisbon';

-- ---------------------------------------------------------
-- Block A — Default product family
-- ---------------------------------------------------------

insert into family (nam_fam, des_fam) values
    (
        'General',
        'default product family for MiaCaoMigo bootstrap environments'
    );

-- ---------------------------------------------------------
-- Block B — Sequence alignment
-- ---------------------------------------------------------

select setval(pg_get_serial_sequence('family', 'id_fam'),
    (select coalesce(max(id_fam), 1) from family));
