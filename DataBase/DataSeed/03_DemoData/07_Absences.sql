-- =========================================================
-- NARRATIVE DEMO — 07 ABSENCES
-- Story: approved / detected / pending / rejected
-- =========================================================

set timezone to 'Europe/Lisbon';

insert into absence (id_abs, id_emp, sta_dat_tim_abs, end_dat_tim_abs, mot_abs, sta_abs, res_abs, cre_tim_abs)
overriding system value
values
    -- Ivo hospital 7 May (approved by platform admin)
    (1, 2, '2026-05-07 08:00:00+01', '2026-05-07 18:00:00+01', 'hospital appointment', 'approved', 1, '2026-05-05 10:00:00+01'),
    -- Ivo detected 21 May
    (2, 2, '2026-05-21 08:00:00+01', '2026-05-21 18:00:00+01', 'no_show', 'detected', null, '2026-05-21 18:05:00+01'),
    -- Ivo pending 25 May afternoon
    (3, 2, '2026-05-25 14:00:00+01', '2026-05-25 18:00:00+01', 'academic presentation defense', 'pending', null, '2026-05-22 09:00:00+01'),
    -- Tiago detected
    (4, 3, '2026-05-15 08:00:00+01', '2026-05-15 18:00:00+01', 'no_show', 'detected', null, '2026-05-15 18:10:00+01'),
    (5, 3, '2026-05-16 08:00:00+01', '2026-05-16 18:00:00+01', 'no_show', 'detected', null, '2026-05-16 18:10:00+01'),
    (6, 3, '2026-05-20 08:00:00+01', '2026-05-20 18:00:00+01', 'no_show', 'detected', null, '2026-05-20 18:10:00+01'),
    (7, 3, '2026-05-25 08:00:00+01', '2026-05-25 18:00:00+01', 'academic presentation defense', 'pending', null, '2026-05-23 11:00:00+01'),
    -- Isabel detected stretch (sample days)
    (8, 6, '2026-05-06 08:00:00+01', '2026-05-06 18:00:00+01', 'no_show', 'detected', null, '2026-05-06 18:05:00+01'),
    (9, 6, '2026-05-12 08:00:00+01', '2026-05-12 18:00:00+01', 'no_show', 'detected', null, '2026-05-12 18:05:00+01'),
    (10, 6, '2026-05-19 08:00:00+01', '2026-05-19 18:00:00+01', 'no_show', 'detected', null, '2026-05-19 18:05:00+01'),
    -- Isabel pending 3 Jun
    (11, 6, '2026-06-03 08:00:00+01', '2026-06-03 18:00:00+01', 'aps and web programming presentation defense', 'pending', null, '2026-05-28 14:00:00+01'),
    -- Marcelo pending 25 May
    (12, 5, '2026-05-25 08:00:00+01', '2026-05-25 13:00:00+01', 'academic presentation defense', 'pending', null, '2026-05-24 16:00:00+01'),
    -- Tiago rejected (overlap lesson) 26 May
    (13, 3, '2026-05-26 08:00:00+01', '2026-05-26 18:00:00+01', 'personal errand', 'rejected', 2, '2026-05-25 15:00:00+01');

select setval(pg_get_serial_sequence('absence', 'id_abs'),
    (select coalesce(max(id_abs), 1) from absence));
