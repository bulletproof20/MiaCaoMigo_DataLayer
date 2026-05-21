-- =========================================================
-- DEMO DATA — MODULE 3 (COMMERCIAL MANAGEMENT)
-- FILE: 03_Module3_DemoData.sql
-- =========================================================
--
-- TIER
--   DemoData — catalog, stock, procurement, and billing samples.
--
-- PREREQUISITES
--   MasterData: id_fam 1 (General)
--   DemoData M1: id_emp 1 (admin), 5–6 (assistants)
--
-- DEMO STABLE IDENTIFIERS
--   id_fam 2–4     Nutrition, Pharmacy, Hygiene
--   id_pro 1–8     sellable catalog
--   id_sto 1–9     batch stock
--   id_pur 1–2     received + pending purchase
--   id_inv 1–3     paid, pending, overdue invoices
--
-- NEXT AUTO IDS
--   product.id_pro → 9 | stock.id_sto → 10
-- =========================================================

set timezone to 'Europe/Lisbon';

-- ---------------------------------------------------------
-- Block A — Product families (extends master id_fam = 1)
-- ---------------------------------------------------------

insert into family (id_fam, nam_fam, des_fam)
overriding system value
values
    (2, 'Canine Nutrition', 'Diets and supplements for dogs'),
    (3, 'Veterinary Pharmacy', 'Prescription and OTC medicines'),
    (4, 'Clinic Hygiene', 'Disinfection and surgical consumables');

-- ---------------------------------------------------------
-- Block B — Product catalog
-- ---------------------------------------------------------

insert into product (
    id_pro, ref_pro, bar_pro, nam_pro, des_pro,
    pri_pro, iva_pro, id_fam, min_sto
)
overriding system value
values
    (1, 'NUT-DOG-15K', '5600001000001', 'Adult Maintenance Kibble 15 kg', 'Complete dry food for adult dogs', 42.90, 23.00, 2, 8),
    (2, 'NUT-CAT-3K', '5600001000002', 'Indoor Cat Formula 3 kg', 'Balanced nutrition for indoor cats', 18.50, 23.00, 2, 10),
    (3, 'PHM-AMOX-250', '5600002000001', 'Amoxicillin 250 mg tablets', 'Antibiotic — prescription required', 12.40, 6.00, 3, 5),
    (4, 'PHM-META-20', '5600002000002', 'Metacam Oral Suspension 20 ml', 'Anti-inflammatory analgesic', 24.80, 6.00, 3, 4),
    (5, 'HYG-CHL-1L', '5600003000001', 'Chlorhexidine Scrub 1 L', 'Surgical hand scrub', 9.90, 23.00, 4, 6),
    (6, 'HYG-GLO-M', '5600003000002', 'Nitrile Examination Gloves (M)', 'Box of 100 units', 7.50, 23.00, 4, 12),
    (7, 'ACC-LEA-01', '5600004000001', 'Adjustable Nylon Lead', 'Daily walk lead — medium size', 11.00, 23.00, 1, 5),
    (8, 'NUT-PUP-3K', '5600001000003', 'Puppy Growth Formula 3 kg', 'Growth support up to 12 months', 22.00, 23.00, 2, 6);

-- ---------------------------------------------------------
-- Block C — Stock batches (FIFO-ready quantities)
-- ---------------------------------------------------------

insert into stock (id_sto, id_pro, bat_sto, qty_sto, ent_dat_sto, val_dat_sto)
overriding system value
values
    (1, 1, 'LOT-NUT-2026-A1', 40, current_date - interval '20 days', current_date + interval '14 months'),
    (2, 1, 'LOT-NUT-2026-A2', 25, current_date - interval '5 days', current_date + interval '16 months'),
    (3, 2, 'LOT-CAT-2026-B1', 30, current_date - interval '12 days', current_date + interval '10 months'),
    (4, 3, 'LOT-AMX-2026-C1', 60, current_date - interval '30 days', current_date + interval '8 months'),
    (5, 4, 'LOT-MET-2026-D1', 18, current_date - interval '25 days', current_date + interval '6 months'),
    (6, 5, 'LOT-HYG-2026-E1', 15, current_date - interval '10 days', current_date + interval '24 months'),
    (7, 6, 'LOT-GLO-2026-F1', 24, current_date - interval '8 days', current_date + interval '36 months'),
    (8, 7, 'LOT-ACC-2026-G1', 20, current_date - interval '15 days', null),
    (9, 8, 'LOT-PUP-2026-H1', 12, current_date - interval '3 days', current_date + interval '9 months');

-- ---------------------------------------------------------
-- Block D — Procurement (received + pending)
-- ---------------------------------------------------------

insert into purchase (id_pur, pur_dat_pur, sta_pur, id_emp, ord_num_pur, pay_met_pur)
overriding system value
values
    (1, current_timestamp - interval '12 days', 'received', 6, 'PO-NVS-2026-0142', 'bank transfer'),
    (2, current_timestamp - interval '2 days', 'pending', 1, 'PO-NVS-2026-0158', 'bank transfer');

insert into purchase_line (id_pur, id_pro, bat_pln, qty_pln, uni_cos_pln) values
    (1, 3, 'LOT-AMX-2026-C1', 40, 7.20),
    (1, 6, 'LOT-GLO-2026-F1', 30, 4.10),
    (2, 1, 'LOT-NUT-2026-A3', 50, 28.50),
    (2, 8, 'LOT-PUP-2026-H2', 20, 14.00);

-- ---------------------------------------------------------
-- Block E — Invoices (workflow states)
-- Lines respect trg_check_stock_before_sale / FIFO triggers
-- ---------------------------------------------------------

insert into invoice (id_inv, dat_inv, sta_inv, bod_inv)
overriding system value
values
    (1, current_timestamp - interval '6 days', 'paid', 'Consultation and diet plan — Bobi'),
    (2, current_timestamp - interval '1 day', 'pending', 'Vaccination bundle — Luna'),
    (3, current_timestamp - interval '35 days', 'overdue', 'Hygiene restock — internal consumption');

insert into invoice_line (id_inv, id_pro, qty_inv_lin, uni_pri_inv_lin, iva_inv_lin) values
    (1, 1, 1, 42.90, 23.00),
    (1, 7, 1, 11.00, 23.00),
    (2, 4, 1, 24.80, 6.00),
    (2, 2, 2, 18.50, 23.00),
    (3, 5, 2, 9.90, 23.00),
    (3, 6, 1, 7.50, 23.00);

-- ---------------------------------------------------------
-- Block F — Sequence alignment
-- ---------------------------------------------------------

select setval(pg_get_serial_sequence('family', 'id_fam'),
    (select coalesce(max(id_fam), 1) from family));

select setval(pg_get_serial_sequence('product', 'id_pro'),
    (select coalesce(max(id_pro), 1) from product));

select setval(pg_get_serial_sequence('stock', 'id_sto'),
    (select coalesce(max(id_sto), 1) from stock));

select setval(pg_get_serial_sequence('purchase', 'id_pur'),
    (select coalesce(max(id_pur), 1) from purchase));

select setval(pg_get_serial_sequence('purchase_line', 'id_pur_lin'),
    (select coalesce(max(id_pur_lin), 1) from purchase_line));

select setval(pg_get_serial_sequence('invoice', 'id_inv'),
    (select coalesce(max(id_inv), 1) from invoice));

select setval(pg_get_serial_sequence('invoice_line', 'id_inv_lin'),
    (select coalesce(max(id_inv_lin), 1) from invoice_line));
