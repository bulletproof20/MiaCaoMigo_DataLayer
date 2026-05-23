-- =========================================================
-- NARRATIVE DEMO — 15 APPOINTMENTS
-- Story: all appointment_status paths (see OPS_APPOINTMENT_STATES)
-- =========================================================
-- id_app 1–11 | disable past-date trigger for historical May rows
-- =========================================================

set timezone to 'Europe/Lisbon';

alter table appointment disable trigger trg_block_past_appointments;

insert into appointment (
    id_app, id_ani, id_emp, id_cli, id_spe,
    sch_dat_app, sta_dat_app, end_dat_app, status_app, dia_app, com_app, id_inv
)
overriding system value
values
    -- 12 May Jonas geral completed
    (1, 1, 5, 1, 1,
     '2026-05-12 10:00:00+01', '2026-05-12 10:05:00+01', '2026-05-12 10:25:00+01',
     'completed', 'Routine wellness', 'Annual check — healthy', null),
    -- 16 May Jonas dermatology completed
    (2, 1, 5, 1, 2,
     '2026-05-16 15:00:00+01', '2026-05-16 15:10:00+01', '2026-05-16 15:35:00+01',
     'completed', 'Mild dermatitis', 'Diet change recommended', null),
    -- 13–14 May Felix acute (completed)
    (3, 7, 5, 2, 1,
     '2026-05-13 09:00:00+01', '2026-05-13 09:25:00+01', '2026-05-14 10:00:00+01',
     'completed', 'Lameness forelimb', 'Delayed start — overcrowded morning', 7),
    -- 17 May Felix follow-up (late arrival, completed)
    (4, 7, 5, 2, 1,
     '2026-05-17 11:00:00+01', '2026-05-17 11:35:00+01', '2026-05-17 11:55:00+01',
     'completed', 'Improving mobility', 'Owner arrived late A3 traffic', null),
    -- 15 May Pedro Thor no_show
    (5, 11, 5, 4, 1,
     '2026-05-15 11:00:00+01', null, null,
     'no_show', null, 'Owner did not attend — cron marked no_show', null),
    -- 22 May Pedro cancelled retry
    (6, 11, 5, 4, 1,
     '2026-05-22 16:00:00+01', null, null,
     'cancelled', null, 'Client moved abroad — cancelled in time', null),
    -- 24 May Marta surgery prep cancelled
    (7, 7, 5, 2, 1,
     '2026-06-20 09:00:00+01', null, null,
     'cancelled', null, 'Family travel — sp_cancel_appointment', null),
    -- 22 May Tico completed (Isabel client)
    (8, 8, 5, 5, 1,
     '2026-05-22 10:00:00+01', '2026-05-22 10:02:00+01', '2026-05-22 10:28:00+01',
     'completed', 'Mild gingivitis', 'Dental hygiene plan', 6),  -- id_inv set at insert; invoice.id_app linked below
    -- 20 May Bento palliative (Ana)
    (9, 6, 5, 3, 1,
     '2026-05-20 14:00:00+01', '2026-05-20 14:05:00+01', '2026-05-20 14:40:00+01',
     'completed', 'Chronic renal decline', 'Palliative options discussed', null),
    -- Future scheduled
    (10, 1, 5, 1, 2,
     '2026-06-10 11:00:00+01', null, null,
     'scheduled', null, 'Dermatology follow-up Jonas', null),
    (11, 4, 5, 3, 1,
     '2026-06-12 10:00:00+01', null, null,
     'scheduled', null, 'Post-adoption Pipoca wellness', null);

-- 28 May — Bento euthanasia (after 20 May palliative appointment; story EMP_MARCELO / ANI_BENTO)
update ownership
set end_dat_own = '2026-05-28', mot_own = 'euthanasia clinic'
where id_ani = 6 and end_dat_own is null;

update animal
set sta_ani = 'Falecido', ina_dat_ani = '2026-05-28'
where id_ani = 6;

-- Link consultation invoices (appointments must exist before FK on invoice.id_app)
update invoice set id_app = 8 where id_inv = 6;
update invoice set id_app = 3 where id_inv = 7;

alter table appointment enable trigger trg_block_past_appointments;

select setval(pg_get_serial_sequence('appointment', 'id_app'), (select max(id_app) from appointment));
