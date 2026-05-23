-- =========================================================
-- NARRATIVE DEMO — 17 NOTIFICATIONS
-- Story: cron sp_generate_appointment_warnings (08:00 tomorrow)
-- =========================================================

set timezone to 'Europe/Lisbon';

insert into appointment_notification (id_cli, id_app, msg_not, cre_tim_not, rea_not)
values
  -- 21 May 08:00 — Tico 22 May (Isabel as client id_cli 5)
    (5, 8,
     'Lembrete: Bom dia Isabel Carvalho! A sua consulta para o animal Tico com o/a Dr(a). João Marcelo está marcada para amanhã.',
     '2026-05-21 08:00:00+01', true),
  -- 16 May 08:00 — Felix 17 May (Marta)
    (2, 4,
     'Lembrete: Bom dia Marta Ribeiro! A sua consulta para o animal Felix com o/a Dr(a). João Marcelo está marcada para amanhã.',
     '2026-05-16 08:00:00+01', true),
  -- 14 May 08:00 — Thor 15 May (Pedro — unread)
    (4, 5,
     'Lembrete: Bom dia Pedro Costa! A sua consulta para o animal Thor com o/a Dr(a). João Marcelo está marcada para amanhã.',
     '2026-05-14 08:00:00+01', false),
  -- 9 Jun 08:00 — Jonas 10 Jun (Gonçalo) — narrative future cron
    (1, 10,
     'Lembrete: Bom dia Gonçalo Rego! A sua consulta para o animal Jonas com o/a Dr(a). João Marcelo está marcada para amanhã.',
     '2026-06-09 08:00:00+01', false);

select setval(pg_get_serial_sequence('appointment_notification', 'id_not'),
    (select coalesce(max(id_not), 1) from appointment_notification));
