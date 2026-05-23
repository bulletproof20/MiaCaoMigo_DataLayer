-- =========================================================
-- NARRATIVE DEMO — 08 CUSTOMERS
-- Story: Gonçalo 6 May | Marta 8 May | Ana 6 May | Pedro inactive 2 Jun | Isabel hybrid
-- =========================================================
-- id_cli 1 Gonçalo | 2 Marta | 3 Ana | 4 Pedro | 5 Isabel (employee id_usr 6)
-- =========================================================

set timezone to 'Europe/Lisbon';

insert into client (id_cli, id_usr, pas_cli, reg_dat_cli, ina_dat_cli)
overriding system value
values
    (1, 8, '$2b$12$miacaomigo.narrative.demo.hash', '2026-05-06 10:30:00+01', null),
    (2, 9, '$2b$12$miacaomigo.narrative.demo.hash', '2026-05-08 09:15:00+01', null),
    (3, 10, '$2b$12$miacaomigo.narrative.demo.hash', '2026-05-06 11:00:00+01', null),
    -- Pedro inactive 2 Jun (story); clamped to wall-clock for ck_client_dates at seed load
    (4, 11, '$2b$12$miacaomigo.narrative.demo.hash', '2026-05-07 14:00:00+01',
     least(timestamptz '2026-06-02 09:00:00+01', current_timestamp - interval '1 second')),
    (5, 6, '$2b$12$miacaomigo.narrative.demo.hash', '2025-11-01 10:00:00+01', null);

select setval(pg_get_serial_sequence('client', 'id_cli'),
    (select coalesce(max(id_cli), 1) from client));
