-- =========================================================
-- DEMO DATA — MODULE 2 (ANIMAL MANAGEMENT)
-- FILE: 02_Module2_DemoData.sql
-- =========================================================
--
-- TIER
--   DemoData — clinic animal population and custody flows.
--
-- PREREQUISITES
--   MasterData: id_spc 1–2, id_bre 1–2
--   DemoData M1: id_cli 1–6, id_emp 2–6
--
-- DEMO STABLE IDENTIFIERS
--   id_bre 3–5        additional breeds
--   id_ext_ent 1–2    shelter + supplier
--   id_ani 1–8        animals
--   id_own 1–7        ownership rows (6 active, 1 closed)
--   id_del 1          rescue delivery
--   id_con 1          shelter concession
--
-- NEXT AUTO IDS
--   breed.id_bre → 6 | animal.id_ani → 9
-- =========================================================

set timezone to 'Europe/Lisbon';

-- ---------------------------------------------------------
-- Block A — Extended breed catalog
-- ---------------------------------------------------------

insert into breed (id_bre, nam_bre, id_spc, sci_nam_bre)
overriding system value
values
    (3, 'Labrador Retriever', 1, 'Canis lupus familiaris'),
    (4, 'European Shorthair', 2, 'Felis catus'),
    (5, 'Estrela Mountain Dog', 1, 'Canis lupus familiaris');

-- ---------------------------------------------------------
-- Block B — External partners
-- ---------------------------------------------------------

insert into external_entity (id_ext_ent, nam_ext_ent, loc_ext_ent, pho_ext_ent, ema_ext_ent, typ_ext_ent)
overriding system value
values
    (1, 'Associação Patinhas do Ave', 'Avenida Marechal Gomes da Costa, Vila Nova de Famalicão', '+351252401880', 'contacto@patinhasave.pt', 'Shelter'),
    (2, 'NorteVet Supply Lda', 'Zona Industrial de Palmeira, Braga', '+351253800120', 'comercial@nortevetsupply.pt', 'Supplier');

-- ---------------------------------------------------------
-- Block C — Animals (clinic registry)
-- id_cli on animal optional; authoritative link is ownership
-- ---------------------------------------------------------

insert into animal (
    id_ani, reg_id_ani, nam_ani, dat_bir_ani, gen_ani,
    ori_ani, sta_ani, id_spc, id_bre, id_cli
)
overriding system value
values
    (1, 'MCM-ANI-2024-0001', 'Bobi', '2019-03-12', 'M', 'Clinic intake', 'Active', 1, 3, 1),
    (2, 'MCM-ANI-2024-0002', 'Milú', '2022-07-08', 'F', 'Owner registered', 'Active', 1, 3, 1),
    (3, 'MCM-ANI-2024-0003', 'Luna', '2021-02-14', 'F', 'Clinic intake', 'Active', 2, 4, 2),
    (4, 'MCM-ANI-2024-0004', 'Tareco', '2018-11-20', 'M', 'Owner registered', 'Active', 2, 2, 3),
    (5, 'MCM-ANI-2024-0005', 'Kika', '2023-05-01', 'F', 'Owner registered', 'Active', 1, 1, 4),
    (6, 'MCM-ANI-2024-0006', 'Rambo', '2017-09-30', 'M', 'Owner registered', 'Active', 1, 5, 5),
    (7, 'MCM-ANI-2025-0001', 'Pipoca', '2024-01-18', 'F', 'Shelter transfer', 'Internal', 2, 4, null),
    (8, 'MCM-ANI-2025-0002', 'Max', '2016-06-25', 'M', 'Shelter transfer', 'Internal', 1, 3, null);

-- ---------------------------------------------------------
-- Block D — Ownership (active custody + one closed interval)
-- ---------------------------------------------------------

insert into ownership (id_own, id_cli, id_ani, sta_dat_own, end_dat_own, mot_own, id_emp)
overriding system value
values
    (1, 1, 1, current_date - interval '24 months', null, 'Primary registration at MiaCaoMigo Braga', 5),
    (2, 1, 2, current_date - interval '8 months', null, 'Second family dog — same household', 5),
    (3, 2, 3, current_date - interval '14 months', null, 'Adoption follow-up programme', 2),
    (4, 3, 4, current_date - interval '10 months', null, 'New client onboarding', 5),
    (5, 4, 5, current_date - interval '7 months', null, 'Routine preventive care', 6),
    (6, 5, 6, current_date - interval '4 months', null, 'Large breed weight management plan', 2),
    (7, 2, 3, current_date - interval '36 months', current_date - interval '15 months', 'Previous owner before adoption', 2);

-- Row 7 is historical (end_dat_own set); row 3 is the active custody for Luna.

-- ---------------------------------------------------------
-- Block E — Rescue delivery (intake before adoption)
-- ---------------------------------------------------------

insert into delivery (
    id_del, reg_dat_del, res_dat_del, del_dat_del,
    res_loc_del, cli_sta_del, id_ext_ent, id_ani
)
overriding system value
values (
    1,
    current_timestamp - interval '40 days',
    current_timestamp - interval '38 days',
    current_timestamp - interval '35 days',
    'Parque da Ponte, Braga',
    'Dehydrated, responsive',
    1,
    7
);

insert into delivery_employee (id_del, id_emp) values
    (1, 2), (1, 6);

-- ---------------------------------------------------------
-- Block F — Concession to partner shelter
-- ---------------------------------------------------------

insert into concession (id_con, dat_con, mot_con, cli_sta_con, id_ext_ent, id_emp, id_ani)
overriding system value
values (
    1,
    current_date - interval '12 days',
    'Long-term placement with partner shelter',
    'Stable for transfer',
    1,
    4,
    8
);

-- ---------------------------------------------------------
-- Block G — Sequence alignment
-- ---------------------------------------------------------

select setval(pg_get_serial_sequence('breed', 'id_bre'),
    (select coalesce(max(id_bre), 1) from breed));

select setval(pg_get_serial_sequence('external_entity', 'id_ext_ent'),
    (select coalesce(max(id_ext_ent), 1) from external_entity));

select setval(pg_get_serial_sequence('animal', 'id_ani'),
    (select coalesce(max(id_ani), 1) from animal));

select setval(pg_get_serial_sequence('ownership', 'id_own'),
    (select coalesce(max(id_own), 1) from ownership));

select setval(pg_get_serial_sequence('delivery', 'id_del'),
    (select coalesce(max(id_del), 1) from delivery));

select setval(pg_get_serial_sequence('concession', 'id_con'),
    (select coalesce(max(id_con), 1) from concession));
