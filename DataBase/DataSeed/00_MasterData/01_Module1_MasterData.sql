-- =========================================================
-- MASTER DATA — MODULE 1 (USER MANAGEMENT)
-- FILE: 01_Module1_MasterData.sql
-- =========================================================
--
-- TIER
--   MasterData — platform invariants only (no demo or operational rows).
--
-- PURPOSE
--   Bootstrap RBAC catalog, one default clinical specialty, and a single
--   active administrator employee so Services can register further users.
--
-- LOADED BY
--   Bootstrap/Loaders/11_MasterData.sql (after 00_Data_Cleanup.sql).
--
-- PREREQUISITES
--   Schema + Services pipeline applied.
--   Do not INSERT into setup — trg_create_default_setup runs on user_account.
--
-- STABLE IDENTIFIERS (contract for downstream tiers)
--   id_per 1–9   permission domain keys
--   id_pro 1–4   profile catalog
--   id_spe 1     default specialty (general practice)
--   id_usr 1     bootstrap administrator (personal identity)
--   id_emp 1     bootstrap administrator (corporate employee)
--
-- NEXT AUTO IDS AFTER THIS FILE
--   user_account.id_usr → 2
--   employee.id_emp     → 2
-- =========================================================

set timezone to 'Europe/Lisbon';

-- ---------------------------------------------------------
-- Block A1 — Permissions (domain-level RBAC vocabulary)
-- ---------------------------------------------------------

insert into permission (nam_per, des_per) values
    ('manage_users', 'create, update, and deactivate platform identities and clients'),
    ('manage_employees', 'hire, schedule, and deactivate clinic staff'),
    ('manage_roles', 'maintain profile and permission assignments (have, occupies)'),
    ('manage_absences', 'approve or reject employee absence workflows'),
    ('manage_animals', 'animal registry, ownership, and custody lifecycle'),
    ('manage_appointments', 'schedule, update, and cancel clinical appointments'),
    ('manage_commercial', 'product catalog, stock, purchases, invoices, and returns'),
    ('view_reports', 'read-only operational and analytical exports'),
    ('audit_security', 'authentication logs and security review');

-- ---------------------------------------------------------
-- Block A2 — Profiles (fixed platform roles)
-- ---------------------------------------------------------

insert into profile (nam_pro, des_pro) values
    ('administrador', 'full platform governance and security'),
    ('veterinario', 'clinical practitioner with OMV registration'),
    ('assistente', 'front-office and peri-clinical operations (includes reception)'),
    ('cliente', 'client portal access profile');

-- ---------------------------------------------------------
-- Block A3 — Profile × permission (have)
-- id_per: 1 users, 2 employees, 3 roles, 4 absences, 5 animals,
--         6 appointments, 7 commercial, 8 reports, 9 audit
-- ---------------------------------------------------------

insert into have (id_pro, id_per) values
    -- administrador — full domain coverage
    (1, 1), (1, 2), (1, 3), (1, 4), (1, 5), (1, 6), (1, 7), (1, 8), (1, 9),
    -- veterinario — clinical operations
    (2, 5), (2, 6), (2, 8),
    -- assistente — scheduling and read access
    (3, 6), (3, 8),
    -- cliente — portal read scope (API contract; not via occupies)
    (4, 8);

-- ---------------------------------------------------------
-- Block B1 — Default clinical specialty
-- ---------------------------------------------------------

insert into specialty (nam_spe, des_spe) values
    ('geral', 'general practice and triage for companion animals');

-- ---------------------------------------------------------
-- Block C — Bootstrap administrator (sole staff identity)
-- Personal email on user_account; corporate email on employee.
-- ---------------------------------------------------------

insert into user_account (id_usr, nam_usr, add_usr, pos_usr, nif_usr, pho_usr, ema_usr)
overriding system value
values (
    1,
    'MiaCaoMigo Platform Administrator',
    'IPCA Technology Campus, Barcelos, Portugal',
    '4750-810',
    '516284930',
    '+351253802190',
    'platform.admin@ipca.pt'
);

insert into employee (
    id_emp,
    id_usr,
    reg_dat_emp,
    aut_reg_emp,
    pho_emp,
    pho_emg,
    ema_emp,
    pas_emp
)
overriding system value
values (
    1,
    1,
    current_timestamp,
    null,
    '+351253802191',
    '+351912000001',
    '1@miacaomigo.pt',
    '$2b$12$miacaomigo.bootstrap.admin.hash'
);

insert into occupies (id_emp, id_pro) values (1, 1);

-- ---------------------------------------------------------
-- Block D — Identity sequence alignment
-- ---------------------------------------------------------

select setval(pg_get_serial_sequence('permission', 'id_per'),
    (select coalesce(max(id_per), 1) from permission));

select setval(pg_get_serial_sequence('profile', 'id_pro'),
    (select coalesce(max(id_pro), 1) from profile));

select setval(pg_get_serial_sequence('specialty', 'id_spe'),
    (select coalesce(max(id_spe), 1) from specialty));

select setval(pg_get_serial_sequence('user_account', 'id_usr'),
    (select coalesce(max(id_usr), 1) from user_account));

select setval(pg_get_serial_sequence('employee', 'id_emp'),
    (select coalesce(max(id_emp), 1) from employee));
