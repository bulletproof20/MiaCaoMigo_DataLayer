-- =========================================================
-- NARRATIVE DEMO — 13 PRODUCTS & STOCK
-- Story: clinic catalog for launch week sales (Navarro)
-- =========================================================
-- product.id_pro 1–8 | stock id_sto 1–9
-- =========================================================

set timezone to 'Europe/Lisbon';

insert into family (id_fam, nam_fam, des_fam)
overriding system value
values
    (2, 'Canine Nutrition', 'Diets and supplements for dogs'),
    (3, 'Veterinary Pharmacy', 'Prescription and OTC medicines'),
    (4, 'Clinic Hygiene', 'Disinfection and surgical consumables');

insert into product (
    id_pro, ref_pro, bar_pro, nam_pro, des_pro, pri_pro, iva_pro, id_fam, min_sto
)
overriding system value
values
    (1, 'NUT-DOG-15K', '5600001000001', 'Adult Maintenance Kibble 15 kg', 'Complete dry food adult dogs', 42.90, 23.00, 2, 8),
    (2, 'NUT-CAT-3K', '5600001000002', 'Indoor Cat Formula 3 kg', 'Indoor cat nutrition', 18.50, 23.00, 2, 10),
    (3, 'PHM-AMOX-250', '5600002000001', 'Amoxicillin 250 mg tablets', 'Antibiotic prescription', 12.40, 6.00, 3, 5),
    (4, 'PHM-META-20', '5600002000002', 'Metacam Oral Suspension 20 ml', 'Anti-inflammatory', 24.80, 6.00, 3, 4),
    (5, 'HYG-CHL-1L', '5600003000001', 'Chlorhexidine Scrub 1 L', 'Surgical scrub', 9.90, 23.00, 4, 6),
    (6, 'HYG-GLO-M', '5600003000002', 'Nitrile Examination Gloves M', 'Box 100', 7.50, 23.00, 4, 12),
    (7, 'ACC-LEA-01', '5600004000001', 'Adjustable Nylon Lead', 'Medium lead', 11.00, 23.00, 1, 5),
    (8, 'ACC-TOY-01', '5600004000002', 'Rubber Chew Toy', 'Enrichment toy', 6.50, 23.00, 1, 10),
    (9, 'NUT-DERM-DOG', '5600001000004', 'Dermatology Support Diet 12 kg', 'Skin support formula', 54.00, 23.00, 2, 4);

insert into stock (id_sto, id_pro, bat_sto, qty_sto, ent_dat_sto, val_dat_sto)
overriding system value
values
    (1, 1, 'LOT-NUT-2026-A1', 80, '2026-04-20', '2027-06-01'),
    (2, 2, 'LOT-CAT-2026-B1', 50, '2026-04-25', '2027-02-01'),
    (3, 3, 'LOT-AMX-2026-C1', 100, '2026-04-10', '2026-12-01'),
    (4, 4, 'LOT-MET-2026-D1', 40, '2026-04-15', '2026-10-01'),
    (5, 7, 'LOT-ACC-2026-G1', 40, '2026-04-18', null),
    (6, 8, 'LOT-ACC-2026-T1', 60, '2026-04-18', null),
    (7, 9, 'LOT-DERM-2026-H1', 30, '2026-05-01', '2027-01-01'),
    (8, 6, 'LOT-GLO-2026-F1', 48, '2026-05-19', '2028-01-01'),
    (9, 5, 'LOT-HYG-2026-E1', 20, '2026-04-28', '2028-06-01');

select setval(pg_get_serial_sequence('family', 'id_fam'), (select max(id_fam) from family));
select setval(pg_get_serial_sequence('product', 'id_pro'), (select max(id_pro) from product));
select setval(pg_get_serial_sequence('stock', 'id_sto'), (select max(id_sto) from stock));
