-- =========================================================
-- NARRATIVE DEMO — 16 PRESCRIPTIONS
-- Story: Tico (22 May) and Felix (14 May) — sp_prescription pattern
-- =========================================================

set timezone to 'Europe/Lisbon';

insert into prescription (id_pre, id_app, reg_dat_pre, des_pre)
overriding system value
values
    (1, 8, '2026-05-22 10:20:00+01', 'Dental care: oral gel twice daily for 14 days'),
    (2, 3, '2026-05-14 09:45:00+01', 'Anti-inflammatory course — follow label');

insert into rel_pre_prod (id_pre, id_pro, qty_pre_pro, dos_pre_pro) values
    (1, 4, 1, 'once daily 7 days'),
    (1, 3, 1, 'as directed'),
    (2, 4, 1, '5 drops every 24h');

insert into overall_assessment (id_app, bod_tmp_ova, wei_ova, hrt_rat_ova, res_rat_ova, gen_sta_ova) values
    (1, 38.4, 4.80, 180, 30, 'Alert cooperative cat'),
    (2, 38.6, 4.75, 175, 28, 'Mild skin irritation'),
    (3, 38.5, 12.20, 100, 24, 'Limping right forelimb'),
    (4, 38.4, 12.10, 96, 22, 'Improved gait'),
    (8, 38.2, 5.10, 160, 26, 'Gingivitis grade 1'),
    (9, 36.8, 3.90, 140, 32, 'Quiet — renal palliative');

insert into anamnesis (id_app, reg_dat_ana, des_ana) values
    (1, '2026-05-12 10:00:00+01', 'Routine annual visit'),
    (2, '2026-05-16 15:00:00+01', 'Scratching and coat dullness two weeks'),
    (3, '2026-05-13 09:00:00+01', 'Lameness after park play'),
    (8, '2026-05-22 10:00:00+01', 'Bad breath noticed at home'),
    (9, '2026-05-20 14:00:00+01', 'Weight loss and lethargy');

select setval(pg_get_serial_sequence('prescription', 'id_pre'), (select max(id_pre) from prescription));
