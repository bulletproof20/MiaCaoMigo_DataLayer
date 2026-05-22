-- =========================================================
-- QUERIES — MODULE 1 — CLIENT CREATION (reference scenarios)
-- =========================================================
-- TYPE:
--   Exploratory reference scenarios
--
-- PURPOSE:
--   Manual validation of fn_create_client identity rules,
--   validation errors, and QA contract bindings.
--
-- REQUIRES:
--   init_qa + QA fixtures + qa_*() contracts loaded
--
-- RELATED:
--   Services/01_Module1/02_User_Creation/01_NewClient.sql
--   QA/contracts/01_QA_Functions.sql
--   QA/fixtures/01_Module1/01_Core_Context.sql
--   Queries/01_Module1/02_User_Creation_Inspection.sql
-- =========================================================

--==============================
-- PREFLIGHT CLEANUP (manual scope)
--==============================

delete from client
 where id_usr in (
     select id_usr from user_account
      where ema_usr like 'qa.manual.client.%@qa.miacaomigo.pt'
 );

delete from user_account
 where ema_usr like 'qa.manual.client.%@qa.miacaomigo.pt';


--==============================
-- SUCCESS PATHS
--==============================

-- create completely new client
-- context: fresh QA-MANUAL identity
-- expected:
-- - new user_account + client row
-- - returns id_cli

select fn_create_client(
    'QA Manual New Client',
    'Rua QA Manual Client 1, Braga',
    '4700-801',
    '619000801',
    '+351910380801',
    'qa.manual.client.new@qa.miacaomigo.pt',
    '$2b$12$cstress_new_client_001'
);


-- create client for active employee identity (bootstrap admin)
-- context: platform.admin@ipca.pt / id_usr = 1 (Master contract)
-- expected:
-- - existing user reused
-- - client row created

select fn_create_client(
    'MiaCaoMigo Platform Administrator',
    'IPCA Technology Campus, Barcelos, Portugal',
    '4750-810',
    '516284930',
    '+351253802190',
    'platform.admin@ipca.pt',
    '$2b$12$cstress_client_bind_admin',
    '$2b$12$miacaomigo.bootstrap.admin.hash'
);


-- create client for active veterinarian identity
-- context: qa_vet_primary (bruno.matos.cstress@outlook.pt / OMV-QA-PRIMARY)
-- expected:
-- - existing user reused
-- - client row created

select fn_create_client(
    'Bruno Filipe Matos QA Vet',
    'Rua da Junqueira 55, Coimbra',
    '3000-341',
    '610000004',
    '+351910300004',
    'bruno.matos.cstress@outlook.pt',
    '$2b$12$cstress_client_bind_vet',
    '$2b$12$cstress_u04_vet_track'
);


--==============================
-- BUSINESS RULE VIOLATIONS
--==============================

-- duplicated client (QA_CLIENT_ACTIVE contract)
-- context: goncalo.pratas.cstress@gmail.com already has client
-- expected: exception — user already has a client account

select fn_create_client(
    'Goncalo Miguel Pratas QA',
    'Rua da Se 12, Faro',
    '8000-078',
    '610000023',
    '+351910300023',
    'goncalo.pratas.cstress@gmail.com',
    '$2b$12$cstress_duplicate_client_005'
);


-- wrong password when binding existing employee identity
-- context: QA registrar personal email (claudia.faria.cstress@icloud.com)
-- expected: exception — ownership / password validation failed

select fn_create_client(
    'QA Registrar Spell',
    'Rua Goncalo Sampaio 412, Porto',
    '4150-564',
    '610000020',
    '+351910300020',
    'claudia.faria.cstress@icloud.com',
    '$2b$12$cstress_wrong_password_007',
    'wrong_password'
);


-- NIF belongs to user A / email belongs to user B
-- context: admin NIF + secondary client email
-- expected: exception — identity inconsistency

select fn_create_client(
    'QA Manual Identity Conflict',
    'Rua de Teste',
    '4700-999',
    '516284930',
    '+351933333333',
    'goncalo.machado.cstress@gmail.com',
    '$2b$12$cstress_identity_conflict_008'
);


-- existing NIF + new email
-- context: vet NIF + fresh email
-- expected: exception — identity inconsistency

select fn_create_client(
    'QA Manual Partial Conflict NIF',
    'Rua de Teste',
    '4700-999',
    '610000004',
    '+351944444444',
    'qa.manual.client.partial.nif@qa.miacaomigo.pt',
    '$2b$12$cstress_partial_conflict_009'
);


-- existing email + new NIF
-- context: vet email + fresh NIF
-- expected: exception — identity inconsistency

select fn_create_client(
    'QA Manual Partial Conflict Email',
    'Rua de Teste',
    '4700-999',
    '619000899',
    '+351955555555',
    'bruno.matos.cstress@outlook.pt',
    '$2b$12$cstress_partial_conflict_010'
);


--==============================
-- FORMAT VALIDATION
--==============================

-- invalid email format — expected: validation exception

select fn_create_client(
    'QA Manual Invalid Email',
    'Rua de Teste',
    '4700-999',
    '619000811',
    '+351966666666',
    'email_invalido',
    '$2b$12$cstress_invalid_email_011'
);


-- invalid postal code — expected: validation exception

select fn_create_client(
    'QA Manual Invalid Postal',
    'Rua de Teste',
    '4700999',
    '619000812',
    '+351977777777',
    'qa.manual.client.postal@qa.miacaomigo.pt',
    '$2b$12$cstress_invalid_postal_012'
);


-- invalid phone format — expected: validation exception

select fn_create_client(
    'QA Manual Invalid Phone',
    'Rua de Teste',
    '4700-999',
    '619000813',
    '912345678',
    'qa.manual.client.phone@qa.miacaomigo.pt',
    '$2b$12$cstress_invalid_phone_013'
);


-- invalid password hash — expected: validation exception

select fn_create_client(
    'QA Manual Invalid Password',
    'Rua de Teste',
    '4700-999',
    '619000814',
    '+351988888888',
    'qa.manual.client.password@qa.miacaomigo.pt',
    '123'
);


-- invalid NIF format — expected: validation exception

select fn_create_client(
    'QA Manual Invalid NIF',
    'Rua de Teste',
    '4700-999',
    'ABC123',
    '+351999999999',
    'qa.manual.client.nif@qa.miacaomigo.pt',
    '$2b$12$cstress_invalid_nif_015'
);


--==============================
-- POSTFLIGHT CLEANUP (manual scope)
--==============================

delete from client
 where id_usr in (
     select id_usr from user_account
      where ema_usr like 'qa.manual.client.%@qa.miacaomigo.pt'
         or ema_usr = 'platform.admin@ipca.pt'
 );

delete from user_account
 where ema_usr like 'qa.manual.client.%@qa.miacaomigo.pt';

-- restore bootstrap admin to employee-only (no client row)
delete from client c
 using user_account u
 where c.id_usr = u.id_usr
   and u.ema_usr = 'platform.admin@ipca.pt';

delete from client c
 using user_account u
 where c.id_usr = u.id_usr
   and u.ema_usr = 'bruno.matos.cstress@outlook.pt';
