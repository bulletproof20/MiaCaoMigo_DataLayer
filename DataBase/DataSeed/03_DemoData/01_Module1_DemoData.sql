-- =========================================================
-- DEMO DATA — MODULE 1 (USER MANAGEMENT)
-- FILE: 01_Module1_DemoData.sql
-- =========================================================
--
-- TIER
--   DemoData — operational clinic narrative (append-only after MasterData).
--
-- PREREQUISITES (MasterData — do not recreate)
--   id_usr 1 / id_emp 1 — platform administrator
--   id_pro 1–4, id_per 1–9, id_spe 1 (geral)
--
-- DEMO STABLE IDENTIFIERS (cross-file contract)
--   id_spe 2–4   extra specialties
--   id_usr 2–12  staff (2–6) + clients (7–12)
--   id_emp 2–6   three veterinarians, two assistants
--   id_cli 1–6   companion animal owners
--
-- NEXT AUTO IDS AFTER THIS FILE
--   user_account.id_usr → 13
--   employee.id_emp     → 7
--   client.id_cli       → 7
--   specialty.id_spe    → 5
-- =========================================================

set timezone to 'Europe/Lisbon';

-- ---------------------------------------------------------
-- Block A — Clinical specialty catalog (extends master id_spe = 1)
-- ---------------------------------------------------------

insert into specialty (id_spe, nam_spe, des_spe)
overriding system value
values
    (2, 'dermatology', 'dermatological conditions and allergy workups'),
    (3, 'surgery', 'surgical planning and perioperative care'),
    (4, 'internal', 'internal medicine and chronic disease management');

-- ---------------------------------------------------------
-- Block B — Identities (user_account)
-- Corporate staff: id_usr 2–6 | Clients: id_usr 7–12
-- ---------------------------------------------------------

insert into user_account (id_usr, nam_usr, add_usr, pos_usr, nif_usr, pho_usr, ema_usr)
overriding system value
values
    (2, 'Sofia Mendes', 'Rua D. Pedro V 214, Braga', '4700-325', '198274561', '+351912340201', 'sofia.mendes@sapo.pt'),
    (3, 'Miguel Costa', 'Avenida da Liberdade 88, Guimarães', '4800-019', '213456789', '+351912340202', 'miguel.costa@outlook.pt'),
    (4, 'Inês Ribeiro', 'Travessa das Oliveiras 12, Barcelos', '4750-242', '224567891', '+351912340203', 'ines.ribeiro@gmail.com'),
    (5, 'Catarina Fonseca', 'Campus do IPCA, Rua do Lagedo, Braga', '4700-313', '235678912', '+351912340204', 'catarina.fonseca@ipca.pt'),
    (6, 'Pedro Almeida', 'Largo da Porta Nova 7, Braga', '4700-435', '246789123', '+351912340205', 'pedro.almeida@ipca.pt'),
    (7, 'João Pratas', 'Urbanização Bouça do Monte 45, Braga', '4700-051', '256891234', '+351912340301', 'joao.pratas@gmail.com'),
    (8, 'Maria Machado', 'Rua de São Marcos 18, Braga', '4700-294', '267912345', '+351912340302', 'maria.machado@sapo.pt'),
    (9, 'André Ferreira', 'Rua do Raio 152, Braga', '4700-325', '278123456', '+351912340303', 'andre.ferreira@outlook.pt'),
    (10, 'Beatriz Lopes', 'Avenida Central 102, Guimarães', '4800-201', '289234567', '+351912340304', 'beatriz.lopes@gmail.com'),
    (11, 'Daniel Sousa', 'Rua de Couros 31, Porto', '4050-602', '290345678', '+351912340305', 'daniel.sousa@sapo.pt'),
    (12, 'Rita Carvalho', 'Rua da Bandeira 9, Barcelos', '4750-323', '301456789', '+351912340306', 'rita.carvalho@gmail.com');

-- ---------------------------------------------------------
-- Block C — Employees (aut_reg_emp = 1 bootstrap administrator)
-- ---------------------------------------------------------

insert into employee (
    id_emp, id_usr, reg_dat_emp, aut_reg_emp,
    pho_emp, pho_emg, ema_emp, pas_emp
)
overriding system value
values
    (2, 2, current_timestamp - interval '18 months', 1, '+351253802402', '+351912340211', '2@miacaomigo.pt', '$2b$12$miacaomigo.demo.staff.hash02'),
    (3, 3, current_timestamp - interval '14 months', 1, '+351253802403', '+351912340212', '3@miacaomigo.pt', '$2b$12$miacaomigo.demo.staff.hash03'),
    (4, 4, current_timestamp - interval '9 months', 1, '+351253802404', '+351912340213', '4@miacaomigo.pt', '$2b$12$miacaomigo.demo.staff.hash04'),
    (5, 5, current_timestamp - interval '8 months', 1, '+351253802405', '+351912340214', '5@miacaomigo.pt', '$2b$12$miacaomigo.demo.staff.hash05'),
    (6, 6, current_timestamp - interval '6 months', 1, '+351253802406', '+351912340215', '6@miacaomigo.pt', '$2b$12$miacaomigo.demo.staff.hash06');

-- ---------------------------------------------------------
-- Block D — Role extensions (veterinarian / assistant disjunction)
-- ---------------------------------------------------------

insert into veterinarian (id_emp, num_omv_vet) values
    (2, 'OMV-PT-2024-BR-00821'),
    (3, 'OMV-PT-2023-GM-00457'),
    (4, 'OMV-PT-2025-BC-00112');

insert into assistant (id_emp, fun_ass) values
    (5, 'Reception and client intake'),
    (6, 'Clinical support and stock coordination');

insert into expert (id_emp, id_spe) values
    (2, 1), (2, 2),
    (3, 1), (3, 4),
    (4, 1), (4, 3);

insert into occupies (id_emp, id_pro) values
    (2, 2), (3, 2), (4, 2),
    (5, 3), (6, 3);

-- ---------------------------------------------------------
-- Block E — Clients
-- ---------------------------------------------------------

insert into client (id_cli, id_usr, pas_cli, reg_dat_cli)
overriding system value
values
    (1, 7, '$2b$12$miacaomigo.demo.client.hash01', current_timestamp - interval '2 years'),
    (2, 8, '$2b$12$miacaomigo.demo.client.hash02', current_timestamp - interval '16 months'),
    (3, 9, '$2b$12$miacaomigo.demo.client.hash03', current_timestamp - interval '11 months'),
    (4, 10, '$2b$12$miacaomigo.demo.client.hash04', current_timestamp - interval '8 months'),
    (5, 11, '$2b$12$miacaomigo.demo.client.hash05', current_timestamp - interval '5 months'),
    (6, 12, '$2b$12$miacaomigo.demo.client.hash06', current_timestamp - interval '3 months');

-- ---------------------------------------------------------
-- Block F — Weekly schedules (Mon–Fri, active employees only)
-- ---------------------------------------------------------

insert into schedule (id_emp, day_wee_sch, sta_tim_sch, fin_hou_sch)
select e.id_emp, d.day, '08:30'::time, '18:30'::time
from employee e
cross join generate_series(1, 5) as d(day)
where e.dea_dat_emp is null
  and e.id_emp >= 2;

-- ---------------------------------------------------------
-- Block G — Absences (approved / pending; clear of demo appointments)
-- ---------------------------------------------------------

insert into absence (
    id_emp, sta_dat_tim_abs, end_dat_tim_abs,
    mot_abs, sta_abs, res_abs
) values
    (
        4,
        current_timestamp + interval '45 days',
        current_timestamp + interval '45 days' + interval '3 days',
        'continuing education',
        'approved',
        1
    ),
    (
        3,
        current_timestamp + interval '60 days',
        current_timestamp + interval '62 days',
        'personal leave',
        'pending',
        null
    );

-- ---------------------------------------------------------
-- Block H — Attendance history (closed clock-ins)
-- ---------------------------------------------------------

insert into clock_in (id_emp, sta_dat_clk, end_dat_clk) values
    (2, current_timestamp - interval '2 days' + time '08:35', current_timestamp - interval '2 days' + time '18:10'),
    (2, current_timestamp - interval '1 day' + time '08:40', current_timestamp - interval '1 day' + time '18:05'),
    (3, current_timestamp - interval '2 days' + time '09:00', current_timestamp - interval '2 days' + time '17:55'),
    (5, current_timestamp - interval '1 day' + time '08:30', current_timestamp - interval '1 day' + time '18:25'),
    (5, current_timestamp - interval '0 days' + time '08:32', current_timestamp - interval '0 days' + time '12:00'),
    (6, current_timestamp - interval '3 days' + time '09:05', current_timestamp - interval '3 days' + time '18:00');

-- ---------------------------------------------------------
-- Block I — Authentication audit trail
-- ---------------------------------------------------------

insert into login_record (sig_tim_log, suc_log, ip_add_log, ema_log, id_usr, sou_tim_log) values
    (current_timestamp - interval '3 hours', true, '192.168.10.21', '2@miacaomigo.pt', 2, current_timestamp - interval '1 hour'),
    (current_timestamp - interval '2 hours', true, '192.168.10.22', '5@miacaomigo.pt', 5, null),
    (current_timestamp - interval '1 day', true, '10.0.0.45', 'joao.pratas@gmail.com', 7, current_timestamp - interval '23 hours'),
    (current_timestamp - interval '30 minutes', false, '203.0.113.50', 'unknown.client@example.com', null, null),
    (current_timestamp - interval '4 days', true, '192.168.10.23', '3@miacaomigo.pt', 3, current_timestamp - interval '4 days' + interval '9 hours');

-- ---------------------------------------------------------
-- Block J — Sequence alignment
-- ---------------------------------------------------------

select setval(pg_get_serial_sequence('specialty', 'id_spe'),
    (select coalesce(max(id_spe), 1) from specialty));

select setval(pg_get_serial_sequence('user_account', 'id_usr'),
    (select coalesce(max(id_usr), 1) from user_account));

select setval(pg_get_serial_sequence('employee', 'id_emp'),
    (select coalesce(max(id_emp), 1) from employee));

select setval(pg_get_serial_sequence('client', 'id_cli'),
    (select coalesce(max(id_cli), 1) from client));

select setval(pg_get_serial_sequence('absence', 'id_abs'),
    (select coalesce(max(id_abs), 1) from absence));

select setval(pg_get_serial_sequence('clock_in', 'id_clk'),
    (select coalesce(max(id_clk), 1) from clock_in));

select setval(pg_get_serial_sequence('login_record', 'id_log'),
    (select coalesce(max(id_log), 1) from login_record));
