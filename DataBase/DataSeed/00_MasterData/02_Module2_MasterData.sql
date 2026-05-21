-- =========================================================
-- MASTER DATA — MODULE 2 (ANIMAL MANAGEMENT)
-- FILE: 02_Module2_MasterData.sql
-- =========================================================
--
-- TIER
--   MasterData — taxonomy invariants only.
--
-- PURPOSE
--   Minimum species and generic breed anchors required before any
--   animal row can satisfy animal.id_spc NOT NULL (breed remains optional).
--
-- LOADED BY
--   Bootstrap/Loaders/11_MasterData.sql (after 01_Module1_MasterData.sql).
--
-- PREREQUISITES
--   No foreign keys to Module 1.
--
-- STABLE IDENTIFIERS
--   id_spc 1 — dog (default small-animal clinic species)
--   id_spc 2 — cat
--   id_bre 1 — unspecified breed (dog)
--   id_bre 2 — unspecified breed (cat)
--
-- NEXT AUTO IDS AFTER THIS FILE
--   species.id_spc → 3
--   breed.id_bre   → 3
-- =========================================================

set timezone to 'Europe/Lisbon';

-- ---------------------------------------------------------
-- Block A — Species catalog (companion animals)
-- ---------------------------------------------------------

insert into species (nam_spc, sci_nam_spc) values
    ('Dog', 'Canis lupus familiaris'),
    ('Cat', 'Felis catus');

-- ---------------------------------------------------------
-- Block B — Generic breeds (one per master species)
-- ---------------------------------------------------------

insert into breed (nam_bre, id_spc) values
    ('Unspecified breed (dog)', 1),
    ('Unspecified breed (cat)', 2);

-- ---------------------------------------------------------
-- Block C — Sequence alignment
-- ---------------------------------------------------------

select setval(pg_get_serial_sequence('species', 'id_spc'),
    (select coalesce(max(id_spc), 1) from species));

select setval(pg_get_serial_sequence('breed', 'id_bre'),
    (select coalesce(max(id_bre), 1) from breed));
