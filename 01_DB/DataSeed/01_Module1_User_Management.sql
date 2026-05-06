--=========================================================
-- MODULE 1: USER MANAGEMENT - DATA SEED
--=========================================================
-- Purpose:
-- Populate the module with coherent operational data
-- for testing integrity, triggers, authentication,
-- attendance and RBAC logic.
--=========================================================



--=========================================================
-- 0. CLEAN DATA
--=========================================================

truncate table
    have,
    occupies,
    assistant,
    veterinarian,
    schedule,
    absence,
    clock_in,
    setup,
    login_record,
    employee,
    client,
    profile,
    permission,
    specialty,
    user_account
restart identity cascade;



--=========================================================
-- 1. USER_ACCOUNT
--=========================================================

insert into user_account (
    nam_usr,
    add_usr,
    pos_usr,
    nif_usr,
    pho_usr,
    ema_usr
)
values
('Ricardo Santos','Rua da Universidade, Braga','4700-001','251000001','+351910000001','ricardo@gmail.com'),
('Ana Silva','Rua das Flores, Braga','4700-002','251000002','+351910000002','ana@gmail.com'),
('Carlos Mendes','Avenida Central, Porto','4000-001','251000003','+351910000003','carlos@email.pt'),
('Maria Costa','Rua da Liberdade, Lisboa','1000-001','251000004','+351910000004','maria@email.pt'),
('Joao Ferreira','Rua do Hospital, Braga','4700-003','251000005','+351910000005','joao@email.pt'),
('Sofia Rocha','Rua do Sol, Porto','4000-002','251000006','+351910000006','sofia@email.pt'),
('Tiago Almeida','Rua Nova, Guimaraes','4800-001','251000007','+351910000007','tiago@email.pt'),
('Beatriz Sousa','Rua Verde, Braga','4700-004','251000008','+351910000008','beatriz@email.pt');



--=========================================================
-- 2. SETUP
--=========================================================

insert into setup (
    id_usr,
    the_set,
    lan_set
)
values
(1,'dark','pt-pt'),
(2,'light','pt-pt'),
(3,'dark','en-us'),
(4,'light','pt-pt'),
(5,'dark','pt-pt'),
(6,'light','en-us'),
(7,'dark','pt-pt'),
(8,'light','pt-pt');



--=========================================================
-- 3. EMPLOYEE
--=========================================================

insert into employee (
    id_usr,
    pho_emp,
    pho_emg,
    ema_emp,
    pas_emp
)
values
(
    1,
    '+351253000001',
    '+351911111111',
    'ricardo@miacaomigo.pt',
    'hashed_password_secure_123456789'
),
(
    2,
    '+351253000002',
    '+351922222222',
    'ana@miacaomigo.pt',
    'hashed_password_secure_123456789'
),
(
    3,
    '+351253000003',
    '+351933333333',
    'carlos@miacaomigo.pt',
    'hashed_password_secure_123456789'
),
(
    7,
    '+351253000004',
    '+351944444444',
    'tiago@miacaomigo.pt',
    'hashed_password_secure_123456789'
);



--=========================================================
-- 4. CLIENT
--=========================================================

insert into client (
    id_usr,
    pas_cli
)
values
(4,'hashed_password_secure_123456789'),
(5,'hashed_password_secure_123456789'),
(6,'hashed_password_secure_123456789'),
(8,'hashed_password_secure_123456789');



--=========================================================
-- 5. PROFILE
--=========================================================

insert into profile (
    nam_pro,
    des_pro
)
values
('administrador','system administration'),
('veterinario','clinical operations'),
('assistente','front desk and operational support'),
('gestor','management operations');



--=========================================================
-- 6. PERMISSION
--=========================================================

insert into permission (
    nam_per,
    des_per
)
values
('manage_users','manage system users'),
('manage_animals','manage animals'),
('manage_appointments','manage appointments'),
('manage_inventory','manage inventory'),
('view_reports','view operational reports'),
('manage_absences','manage employee absences');



--=========================================================
-- 7. HAVE
--=========================================================

insert into have (
    id_pro,
    id_per
)
values

-- administrador
(1,1),
(1,2),
(1,3),
(1,4),
(1,5),
(1,6),

-- veterinario
(2,2),
(2,3),
(2,5),

-- assistente
(3,3),

-- gestor
(4,5),
(4,6);



--=========================================================
-- 8. OCCUPIES
--=========================================================

insert into occupies (
    id_emp,
    id_pro
)
values
(1,1),
(2,2),
(3,3),
(4,4);



--=========================================================
-- 9. SPECIALTY
--=========================================================

insert into specialty (
    nam_spe,
    des_spe
)
values
('cirurgia geral','procedimentos cirurgicos'),
('medicina geral','consultas gerais'),
('dermatologia veterinaria','problemas dermatologicos'),
('ortopedia veterinaria','tratamentos ortopedicos');



--=========================================================
-- 10. SPECIALIZATION
--=========================================================

insert into veterinarian (
    id_emp,
    num_omv_vet,
    id_spe
)
values
(1,'OMV-1001',1),
(2,'OMV-1002',2);



insert into assistant (
    id_emp,
    fun_ass
)
values
(3,'assistente clinico'),
(4,'gestao operacional');



--=========================================================
-- 11. LOGIN_RECORD
--=========================================================

insert into login_record (
    sig_tim_log,
    sou_tim_log,
    suc_log,
    ip_add_log,
    eml_usr,
    id_usr
)
values

-- successful closed session
(
    now() - interval '4 hours',
    now() - interval '2 hours',
    true,
    '192.168.1.10',
    'ricardo@miacaomigo.pt',
    1
),

-- active successful session
(
    now() - interval '1 hour',
    null,
    true,
    '192.168.1.20',
    'ana@miacaomigo.pt',
    2
),

-- client active session
(
    now() - interval '30 minutes',
    null,
    true,
    '192.168.1.30',
    'maria@email.pt',
    4
),

-- failed login
(
    now() - interval '10 minutes',
    null,
    false,
    '192.168.1.40',
    'unknown@email.pt',
    null
);



--=========================================================
-- 12. SCHEDULE
--=========================================================

insert into schedule (
    id_emp,
    day_wee_sch,
    sta_tim_sch,
    fin_hou_sch
)
values

-- Ricardo
(1,1,'09:00','18:00'),
(1,2,'09:00','18:00'),
(1,3,'09:00','18:00'),

-- Ana
(2,1,'10:00','19:00'),
(2,2,'10:00','19:00'),
(2,3,'10:00','19:00'),

-- Carlos
(3,1,'08:00','17:00'),
(3,2,'08:00','17:00'),

-- Tiago
(4,4,'09:00','18:00'),
(4,5,'09:00','18:00');



--=========================================================
-- 13. CLOCK_IN
--=========================================================

insert into clock_in (
    id_emp,
    sta_dat_clk,
    end_dat_clk
)
values

-- finished attendance
(
    1,
    now() - interval '5 hours',
    now() - interval '1 hour'
),

-- active attendance
(
    2,
    now() - interval '2 hours',
    null
);



--=========================================================
-- 14. ABSENCE
--=========================================================

insert into absence (
    id_emp,
    sta_dat_tim_abs,
    end_dat_tim_abs,
    mot_abs,
    sta_abs
)
values

(
    3,
    '2026-05-10 09:00:00',
    '2026-05-10 18:00:00',
    'consulta medica',
    'approved'
),

(
    4,
    '2026-05-11 09:00:00',
    '2026-05-15 18:00:00',
    'ferias',
    'pending'
);