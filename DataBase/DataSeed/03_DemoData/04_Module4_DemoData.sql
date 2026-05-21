-- =========================================================
-- DEMO DATA — MODULE 4 (APPOINTMENT MANAGEMENT)
-- FILE: 04_Module4_DemoData.sql
-- =========================================================
--
-- TIER
--   DemoData — clinical scheduling and visit narratives.
--
-- PREREQUISITES
--   DemoData M1: id_cli 1–6, id_emp 2–4 (vets), id_spe 1–4, expert matrix
--   DemoData M2: active ownership for scheduled pairs (id_own 1–6)
--   DemoData M3: id_inv 1–3 (optional billing link)
--
-- TRIGGER NOTE
--   trg_block_past_appointments requires sch_dat_app >= current_timestamp on INSERT.
--   Completed / in-progress rows therefore use a future sch_dat_app with realistic
--   sta_dat_app / end_dat_app values (clinical times may precede scheduled slot).
--
-- DEMO STABLE IDENTIFIERS
--   id_app 1–10   appointments
--   id_pre 1–2    prescriptions (completed visits)
--
-- NEXT AUTO IDS
--   appointment.id_app → 11
-- =========================================================

set timezone to 'Europe/Lisbon';

-- ---------------------------------------------------------
-- Block A — Scheduled consultations (future, non-overlapping per vet)
-- 30-minute exclusivity applies only among status = scheduled
-- ---------------------------------------------------------

insert into appointment (
    id_app, id_ani, id_emp, id_cli, id_spe,
    sch_dat_app, sta_dat_app, end_dat_app,
    status_app, dia_app, com_app
)
overriding system value
values
    (
        1, 1, 2, 1, 1,
        current_timestamp + interval '1 day' + time '10:00',
        null, null,
        'scheduled', null,
        'Annual wellness review — Bobi'
    ),
    (
        2, 3, 3, 2, 4,
        current_timestamp + interval '2 days' + time '11:00',
        null, null,
        'scheduled', null,
        'Endocrine follow-up — Luna'
    ),
    (
        3, 4, 3, 3, 1,
        current_timestamp + interval '4 days' + time '14:00',
        null, null,
        'scheduled', null,
        'Post-adoption health check — Tareco'
    ),
    (
        4, 6, 2, 5, 1,
        current_timestamp + interval '5 days' + time '09:30',
        null, null,
        'scheduled', null,
        'Orthopaedic screening — Rambo'
    ),
    (
        5, 2, 4, 1, 3,
        current_timestamp + interval '6 days' + time '10:00',
        null, null,
        'scheduled', null,
        'Pre-operative assessment — Milú'
    ),
    (
        6, 5, 2, 4, 2,
        current_timestamp + interval '8 days' + time '15:00',
        null, null,
        'scheduled', null,
        'Dermatology workup — Kika'
    );

-- ---------------------------------------------------------
-- Block B — Visits in progress and recently completed
-- ---------------------------------------------------------

insert into appointment (
    id_app, id_ani, id_emp, id_cli, id_spe,
    sch_dat_app, sta_dat_app, end_dat_app,
    status_app, dia_app, com_app, id_inv
)
overriding system value
values
    (
        7, 1, 2, 1, 1,
        current_timestamp + interval '2 hours',
        current_timestamp - interval '25 minutes',
        current_timestamp - interval '10 minutes',
        'completed',
        'Mild otitis externa; dietary adjustment recommended',
        'Finished visit — invoice MCM-INV-1',
        1
    ),
    (
        8, 3, 3, 2, 1,
        current_timestamp + interval '4 hours',
        current_timestamp - interval '3 hours',
        current_timestamp - interval '2 hours 30 minutes',
        'completed',
        'Stable chronic kidney values; continue prescription diet',
        'Renal monitoring — prior labs reviewed',
        null
    ),
    (
        9, 2, 2, 1, 1,
        current_timestamp + interval '30 minutes',
        current_timestamp - interval '5 minutes',
        null,
        'in_progress',
        null,
        'Ongoing vaccination and clinical examination — Milú'
    );

-- ---------------------------------------------------------
-- Block C — Cancelled slot
-- ---------------------------------------------------------

insert into appointment (
    id_app, id_ani, id_emp, id_cli, id_spe,
    sch_dat_app, status_app, com_app
)
overriding system value
values (
    10, 5, 3, 4, 1,
    current_timestamp + interval '10 days' + time '16:00',
    'cancelled',
    'Client rescheduled — family travel'
);

-- ---------------------------------------------------------
-- Block D — Clinical documentation (completed / in-progress visits)
-- ---------------------------------------------------------

insert into overall_assessment (id_app, bod_tmp_ova, wei_ova, hrt_rat_ova, res_rat_ova, gen_sta_ova) values
    (7, 38.6, 31.20, 96, 22, 'Alert, mild ear discomfort'),
    (8, 38.2, 4.10, 140, 28, 'Quiet, adequately hydrated'),
    (9, 38.4, 12.50, 110, 24, 'Good body condition, receptive to examination');

insert into anamnesis (id_app, des_ana) values
    (7, 'Shaking head since last week; no systemic signs; up to date on deworming.'),
    (8, 'Polydipsia monitored; renal diet introduced two months ago.'),
    (9, 'Routine booster due; owner reports normal appetite and activity.');

insert into prescription (id_pre, id_app, des_pre) values
    (1, 7, 'Topical ear cleaner for 7 days; recheck if no improvement.'),
    (2, 8, 'Continue renal diet; repeat biochemistry in 90 days.');

insert into rel_pre_prod (id_pre, id_pro, qty_pre_pro, dos_pre_pro) values
    (1, 4, 1, 'Once daily with food for 5 days');

insert into rel_app_product (id_app, id_pro, qty_pre_pro) values
    (7, 5, 1);

-- ---------------------------------------------------------
-- Block E — Client notifications
-- ---------------------------------------------------------

insert into appointment_notification (id_cli, id_app, msg_not, rea_not) values
    (1, 1, 'Reminder: Bobi has a consultation tomorrow at 10:00.', false),
    (2, 2, 'Reminder: Luna internal medicine review in two days.', true),
    (1, 7, 'Visit summary available — otitis externa management plan.', false);

-- ---------------------------------------------------------
-- Block F — Sequence alignment
-- ---------------------------------------------------------

select setval(pg_get_serial_sequence('appointment', 'id_app'),
    (select coalesce(max(id_app), 1) from appointment));

select setval(pg_get_serial_sequence('prescription', 'id_pre'),
    (select coalesce(max(id_pre), 1) from prescription));

select setval(pg_get_serial_sequence('appointment_notification', 'id_not'),
    (select coalesce(max(id_not), 1) from appointment_notification));
