-- =========================================================
-- NARRATIVE DEMO — 10 ANIMALS (registry)
-- Story: shelter intake, owned pets, final states after lifecycle scripts
-- =========================================================
-- id_spc 1 Dog | 2 Cat | id_bre 1 dog generic | 2 cat generic
-- =========================================================

set timezone to 'Europe/Lisbon';

insert into animal (
    id_ani, reg_id_ani, nam_ani, dat_bir_ani, gen_ani, ori_ani, sta_ani,
    id_spc, id_bre, reg_dat_ani, ina_dat_ani
)
overriding system value
values
    (1, 'MCM-BRG-2026-JONAS', 'Jonas', '2020-03-15', 'M', 'Owner registered', 'Interno', 2, 2, '2024-06-01', null),
    (2, 'MCM-BRG-2026-ROGERIM', 'Rogerim', '2023-08-20', 'M', 'Shelter transfer', 'Interno', 1, 1, '2026-05-04', null),
    (3, 'MCM-BRG-2026-QUICO', 'Quico', '2024-11-02', 'M', 'Highway abandonment', 'Interno', 1, 1, '2026-05-04', null),
    (4, 'MCM-BRG-2026-PIPOCA', 'Pipoca', '2024-01-18', 'F', 'Shelter transfer', 'Interno', 2, 2, '2026-05-05', null),
    (5, 'MCM-BRG-2026-MAX', 'Max', '2016-06-25', 'M', 'Shelter long stay', 'Interno', 1, 1, '2026-04-01', null),
    (6, 'MCM-BRG-2026-BENTO', 'Bento', '2012-04-10', 'M', 'Owner registered', 'Interno', 2, 2, '2018-01-01', null),
    (7, 'MCM-BRG-2026-FELIX', 'Felix', '2023-02-01', 'M', 'Local shelter', 'Interno', 1, 1, '2026-05-08', null),
    (8, 'MCM-BRG-2026-TICO', 'Tico', '2019-07-12', 'M', 'Owner registered', 'Interno', 2, 2, '2023-05-01', null),
    (9, 'MCM-BRG-2026-TECO', 'Teco', '2021-01-20', 'M', 'Owner registered', 'Interno', 2, 2, '2024-02-01', null),
    (10, 'MCM-BRG-2026-JERONIMO', 'Jerónimo', '2018-09-30', 'M', 'Owner registered', 'Interno', 1, 1, '2022-08-01', null),
    (11, 'MCM-BRG-2026-THOR', 'Thor', '2019-05-05', 'M', 'Owner registered', 'Interno', 1, 1, '2025-12-01', null);

select setval(pg_get_serial_sequence('animal', 'id_ani'),
    (select coalesce(max(id_ani), 1) from animal));
