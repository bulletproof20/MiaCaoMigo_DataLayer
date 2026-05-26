-- =========================================================
-- NARRATIVE DEMO — 03 PROFILES & SPECIALTIES
-- Story: Ivo seeds operational profiles (1 May) + dermatology specialty
-- =========================================================
-- id_pro 5 animal manager | 6 commercial manager | 7 consultation manager | 8 public support
-- (story aliases: animal_manager, commercial_manager, consultation_manager, public_support)
-- id_spe 2 dermatology
-- =========================================================

set timezone to 'Europe/Lisbon';

insert into specialty (id_spe, nam_spe, des_spe)
overriding system value
values (2, 'dermatology', 'dermatological conditions and allergy workups for companion animals');

insert into profile (id_pro, nam_pro, des_pro)
overriding system value
values
    (5, 'animal manager', 'shelter intake adoption and animal lifecycle operations'),
    (6, 'commercial manager', 'store stock procurement invoicing and returns'),
    (7, 'consultation manager', 'appointment scheduling and clinical coordination'),
    (8, 'public support', 'front desk appointment assistance and customer routing');

-- manage_animals=5, manage_appointments=6, manage_commercial=7, view_reports=8
insert into have (id_pro, id_per) values
    (5, 5), (5, 8),
    (6, 7), (6, 8),
    (7, 6), (7, 8),
    (8, 6), (8, 8);

insert into occupies (id_emp, id_pro) values
    (2, 1),
    (3, 5),
    (4, 6),
    (5, 7),
    (6, 8),
    (7, 8);

insert into expert (id_emp, id_spe) values
    (5, 1),
    (5, 2);

select setval(pg_get_serial_sequence('specialty', 'id_spe'),
    (select coalesce(max(id_spe), 1) from specialty));

select setval(pg_get_serial_sequence('profile', 'id_pro'),
    (select coalesce(max(id_pro), 1) from profile));
