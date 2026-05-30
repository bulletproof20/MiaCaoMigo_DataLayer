-- =========================================================
-- MASTER DATA — MODULE 1 (USER MANAGEMENT)
-- FILE: 01_Module1_MasterData.sql
-- =========================================================
--
-- TIER
--   MasterData — platform invariants only (no demo or operational rows).
--
-- PURPOSE
--   Bootstrap RBAC catalog (24 permissions, 6 profiles), one default
--   clinical specialty, and a single active administrator employee.
--
-- LOADED BY
--   Bootstrap/Loaders/11_MasterData.sql (after 00_Data_Cleanup.sql).
--
-- PREREQUISITES
--   Schema + Services pipeline applied.
--   Do not INSERT into setup — trg_create_default_setup runs on user_account.
--
-- STABLE IDENTIFIERS (contract for downstream tiers)
--   id_per 1–24  permission catalog (granular RBAC)
--   id_pro 1–6   profile catalog
--   id_spe 1     default specialty (general practice)
--   id_usr 1     bootstrap administrator (personal identity)
--   id_emp 1     bootstrap administrator (corporate employee)
--
-- PERMISSION INDEX (id_per)
--   1 manage_users          2 manage_employees       3 manage_roles
--   4 manage_schedules      5 manage_absences        6 view_clients
--   7 manage_clients        8 view_animals           9 manage_animals
--  10 manage_ownerships   11 view_clinical_history 12 manage_appointments
--  13 start_appointments   14 complete_appointments 15 issue_prescriptions
--  16 use_consultation_products
--  17 view_products        18 manage_products        19 manage_stock
--  20 manage_purchases     21 manage_sales          22 manage_invoices
--  23 view_reports         24 view_audit_logs
--
-- PROFILE INDEX (id_pro)
--   1 administrador   2 veterinario   3 assistente
--   4 gestor comercial   5 gestor rh   6 diretor clinico
--
-- NEXT AUTO IDS AFTER THIS FILE
--   user_account.id_usr → 2
--   employee.id_emp     → 2
-- =========================================================

set timezone to 'Europe/Lisbon';

-- ---------------------------------------------------------
-- Block A1 — Permissions (granular RBAC vocabulary)
-- ---------------------------------------------------------

insert into permission (nam_per, des_per) values
    -- organizational management
    ('manage_users', 'create, update, and deactivate platform identities'),
    ('manage_employees', 'hire, schedule, and deactivate clinic staff'),
    ('manage_roles', 'maintain profile and permission assignments (have, occupies)'),
    ('manage_schedules', 'define and update employee weekly schedules'),
    ('manage_absences', 'approve, reject, and manage employee absence workflows'),
    -- clients and animals
    ('view_clients', 'read client records and contact details'),
    ('manage_clients', 'register, update, and deactivate client accounts'),
    ('view_animals', 'read animal registry and catalog entries'),
    ('manage_animals', 'register, update, and manage animal lifecycle records'),
    ('manage_ownerships', 'assign, transfer, and end client-animal ownership'),
    -- clinical
    ('view_clinical_history', 'read clinical history, visits, and prescriptions'),
    ('manage_appointments', 'schedule, reschedule, and cancel appointments'),
    ('start_appointments', 'transition scheduled appointments to in progress'),
    ('complete_appointments', 'close in-progress appointments with clinical notes'),
    ('issue_prescriptions', 'register prescriptions linked to completed visits'),
    ('use_consultation_products', 'record products consumed during consultations'),
    -- commercial
    ('view_products', 'read product catalog and stock levels'),
    ('manage_products', 'maintain product catalog and pricing'),
    ('manage_stock', 'receive stock, monitor levels, and handle replenishment'),
    ('manage_purchases', 'create and receive supplier purchase orders'),
    ('manage_sales', 'register sales and invoice line items'),
    ('manage_invoices', 'manage invoice lifecycle, returns, and billing status'),
    -- supervision and audit
    ('view_reports', 'read-only operational and analytical exports'),
    ('view_audit_logs', 'review authentication and security audit trails');

-- ---------------------------------------------------------
-- Block A2 — Profiles (platform roles)
-- ---------------------------------------------------------

insert into profile (nam_pro, des_pro) values
    ('administrador', 'full platform governance and security'),
    ('veterinario', 'clinical practitioner with OMV registration'),
    ('assistente', 'front-office, client intake, and peri-clinical operations'),
    ('gestor comercial', 'product catalog, stock, procurement, and billing'),
    ('gestor rh', 'workforce, schedules, absences, and user administration'),
    ('diretor clinico', 'clinical supervision, reporting, and audit oversight');

-- ---------------------------------------------------------
-- Block A3 — Profile × permission (have)
-- ---------------------------------------------------------

insert into have (id_pro, id_per) values
    -- administrador — full coverage (1–24)
    (1, 1), (1, 2), (1, 3), (1, 4), (1, 5),
    (1, 6), (1, 7), (1, 8), (1, 9), (1, 10),
    (1, 11), (1, 12), (1, 13), (1, 14), (1, 15), (1, 16),
    (1, 17), (1, 18), (1, 19), (1, 20), (1, 21), (1, 22),
    (1, 23), (1, 24),
    -- veterinario — clinical operations
    (2, 6), (2, 8), (2, 11),
    (2, 12), (2, 13), (2, 14), (2, 15), (2, 16),
    (2, 17),
    -- assistente — front office and scheduling
    (3, 6), (3, 7), (3, 8), (3, 9),
    (3, 12), (3, 21), (3, 22), (3, 17),
    -- gestor comercial
    (4, 17), (4, 18), (4, 19), (4, 20), (4, 21), (4, 22), (4, 23),
    -- gestor rh
    (5, 1), (5, 2), (5, 4), (5, 5), (5, 23),
    -- diretor clinico — supervision (read-heavy + appointment oversight)
    (6, 6), (6, 8), (6, 11), (6, 17), (6, 23), (6, 24), (6, 12);

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
