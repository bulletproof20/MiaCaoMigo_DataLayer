-- =========================================================
-- NARRATIVE DEMO — 18 AUDIT (login_record)
-- Story: Gonçalo email typos | Marcelo password fails | Pedro inactive
-- =========================================================

set timezone to 'Europe/Lisbon';

insert into login_record (sig_tim_log, suc_log, ip_add_log, ema_log, id_usr, sou_tim_log) values
    -- Ivo password retry 2 May
    ('2026-05-02 08:01:00+01', false, '192.168.10.10', '2@miacaomigo.pt', null, null),
    ('2026-05-02 08:02:00+01', true, '192.168.10.10', '2@miacaomigo.pt', 2, '2026-05-02 18:00:00+01'),
    -- Marcelo failures 12 May
    ('2026-05-12 07:55:00+01', false, '192.168.10.25', '5@miacaomigo.pt', null, null),
    ('2026-05-12 07:56:00+01', false, '192.168.10.25', '5@miacaomigo.pt', null, null),
    ('2026-05-12 07:57:00+01', true, '192.168.10.25', '5@miacaomigo.pt', 5, '2026-05-12 18:10:00+01'),
    -- Gonçalo email typos 23 May
    ('2026-05-23 09:10:00+01', false, '203.0.113.10', 'goncalo.rego.dev@gmai.com', null, null),
    ('2026-05-23 09:11:00+01', false, '203.0.113.10', 'goncalo.rego.dev@gmail.co', null, null),
    ('2026-05-23 09:12:00+01', true, '203.0.113.10', 'goncalo.rego.dev@gmail.com', 8, null),
    -- Navarro stable session 22 May
    ('2026-05-22 08:00:00+01', true, '192.168.10.30', '4@miacaomigo.pt', 4, '2026-05-22 18:05:00+01'),
    -- Pedro inactive attempt 5 Jun (story); clamped for ck_login_dates at seed load
    (least(timestamptz '2026-06-05 10:00:00+01', current_timestamp - interval '1 second'),
     false, '198.51.100.8', 'pedro.costa.dev@gmail.com', 11, null),
    -- Bernardo historical (archive)
    ('2026-02-01 09:00:00+01', true, '192.168.10.5', '7@miacaomigo.pt', 7, '2026-02-01 17:00:00+01');

select setval(pg_get_serial_sequence('login_record', 'id_log'),
    (select coalesce(max(id_log), 1) from login_record));
