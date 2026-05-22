-- =========================================================
-- QUERIES — MODULE 1 — VETERINARIAN CREATION (reference scenarios)
-- =========================================================
-- TYPE:
--   Exploratory reference scenarios
--
-- PURPOSE:
--   Manual validation of fn_create_veterinarian onboarding,
--   OMV uniqueness, and assistant/veterinarian exclusivity.
--
-- REQUIRES:
--   init_qa + QA fixtures + qa_registrar_emp_id(), qa_client_active_id()
--
-- RELATED:
--   Services/01_Module1/02_User_Creation/04_NewVeterinarian.sql
--   QA/contracts/01_QA_Functions.sql (OMV-QA-PRIMARY)
--   Queries/01_Module1/02_User_Creation_Inspection.sql
-- =========================================================

--==============================
-- PREFLIGHT CLEANUP (manual scope)
--==============================

delete from expert
 where id_emp in (
     select e.id_emp
       from employee e
       join user_account u on u.id_usr = e.id_usr
      where u.ema_usr like 'qa.manual.vet.%@qa.miacaomigo.pt'
 );

delete from veterinarian
 where id_emp in (
     select e.id_emp
       from employee e
       join user_account u on u.id_usr = e.id_usr
      where u.ema_usr like 'qa.manual.vet.%@qa.miacaomigo.pt'
 );

delete from occupies
 where id_emp in (
     select e.id_emp
       from employee e
       join user_account u on u.id_usr = e.id_usr
      where u.ema_usr like 'qa.manual.vet.%@qa.miacaomigo.pt'
 );

delete from employee
 where id_usr in (
     select id_usr from user_account
      where ema_usr like 'qa.manual.vet.%@qa.miacaomigo.pt'
 );

delete from user_account
 where ema_usr like 'qa.manual.vet.%@qa.miacaomigo.pt';


--==============================
-- SUCCESS PATHS
--==============================

-- create completely new veterinarian
-- expected:
-- - employee + veterinarian rows
-- - returns id_emp

select fn_create_veterinarian(
    'QA Manual New Veterinarian',
    'Rua QA Manual Vet 1, Braga',
    '4700-841',
    '619000841',
    '+351910384141',
    'qa.manual.vet.new@qa.miacaomigo.pt',
    '+351253384141',
    '+351912384141',
    '$2b$12$validhashvet00000001',
    qa_registrar_emp_id(),
    'OMV-QA-MANUAL-00001'
);


-- create veterinarian for existing client identity
-- context: qa_client_active (goncalo.pratas — client only before this call)
-- expected:
-- - identity reused
-- - employee + veterinarian created

select fn_create_veterinarian(
    'Goncalo Miguel Pratas QA',
    'Rua da Se 12, Faro',
    '8000-078',
    '610000023',
    '+351910300023',
    'goncalo.pratas.cstress@gmail.com',
    '+351253384242',
    '+351912384242',
    '$2b$12$validhashvet00000002',
    qa_registrar_emp_id(),
    'OMV-QA-MANUAL-00002'
);


--==============================
-- BUSINESS RULE VIOLATIONS
--==============================

-- duplicated veterinarian role on QA vet primary contract
-- context: qa_vet_primary_id() / OMV-QA-PRIMARY
-- expected: exception — veterinarian role already exists

select fn_create_veterinarian(
    'Bruno Filipe Matos QA Vet',
    'Rua da Junqueira 55, Coimbra',
    '3000-341',
    '610000004',
    '+351910300004',
    'bruno.matos.cstress@outlook.pt',
    '+351253384343',
    '+351912384343',
    '$2b$12$validhashvet00000003',
    qa_registrar_emp_id(),
    'OMV-QA-MANUAL-00003'
);


-- duplicated OMV registration (Master seed collision)
-- context: OMV-PT-2023-CR-03319 on QA absence overlap vet (21@)
-- expected: exception — OMV uniqueness

select fn_create_veterinarian(
    'QA Manual Duplicated OMV',
    'Rua Teste',
    '4700-999',
    '619000845',
    '+351955555555',
    'qa.manual.vet.dupomv@qa.miacaomigo.pt',
    '+351253384545',
    '+351912384545',
    '$2b$12$validhashvet00000005',
    qa_registrar_emp_id(),
    'OMV-PT-2023-CR-03319'
);


-- invalid OMV format
-- expected: check constraint / validation exception

select fn_create_veterinarian(
    'QA Manual Invalid OMV',
    'Rua Teste',
    '4700-999',
    '619000846',
    '+351966666666',
    'qa.manual.vet.invalid@qa.miacaomigo.pt',
    '+351253384646',
    '+351912384646',
    '$2b$12$validhashvet00000006',
    qa_registrar_emp_id(),
    ' '
);


-- invalid registering employee
-- expected: exception — invalid registrar

select fn_create_veterinarian(
    'QA Manual Invalid Registrar Vet',
    'Rua Teste',
    '4700-999',
    '619000847',
    '+351977777777',
    'qa.manual.vet.badreg@qa.miacaomigo.pt',
    '+351253384747',
    '+351912384747',
    '$2b$12$validhashvet00000007',
    9999,
    'OMV-QA-MANUAL-00007'
);


--==============================
-- POSTFLIGHT CLEANUP (manual scope)
--==============================

delete from expert
 where id_emp in (
     select e.id_emp
       from employee e
       join user_account u on u.id_usr = e.id_usr
      where u.ema_usr like 'qa.manual.vet.%@qa.miacaomigo.pt'
         or u.ema_usr = 'goncalo.pratas.cstress@gmail.com'
 );

delete from veterinarian
 where id_emp in (
     select e.id_emp
       from employee e
       join user_account u on u.id_usr = e.id_usr
      where u.ema_usr like 'qa.manual.vet.%@qa.miacaomigo.pt'
         or (u.ema_usr = 'goncalo.pratas.cstress@gmail.com'
             and e.ema_emp <> '8@miacaomigo.pt')
 );

delete from occupies
 where id_emp in (
     select e.id_emp
       from employee e
       join user_account u on u.id_usr = e.id_usr
      where u.ema_usr like 'qa.manual.vet.%@qa.miacaomigo.pt'
 );

delete from employee e
 using user_account u
 where e.id_usr = u.id_usr
   and u.ema_usr like 'qa.manual.vet.%@qa.miacaomigo.pt';

delete from employee e
 using user_account u
 where e.id_usr = u.id_usr
   and u.ema_usr = 'goncalo.pratas.cstress@gmail.com'
   and e.ema_emp <> '8@miacaomigo.pt';

delete from user_account
 where ema_usr like 'qa.manual.vet.%@qa.miacaomigo.pt';

-- restore qa_client_active as client-only (fixture contract)
delete from veterinarian v
 using employee e, user_account u, client c
 where v.id_emp = e.id_emp
   and e.id_usr = u.id_usr
   and c.id_usr = u.id_usr
   and u.ema_usr = 'goncalo.pratas.cstress@gmail.com'
   and v.num_omv_vet like 'OMV-QA-MANUAL-%';

delete from employee e
 using user_account u, client c
 where e.id_usr = u.id_usr
   and c.id_usr = u.id_usr
   and u.ema_usr = 'goncalo.pratas.cstress@gmail.com'
   and e.ema_emp <> '8@miacaomigo.pt';
