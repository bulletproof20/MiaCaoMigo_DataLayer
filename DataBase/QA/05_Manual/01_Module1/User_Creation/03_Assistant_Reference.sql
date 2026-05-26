-- =========================================================
-- QUERIES — MODULE 1 — ASSISTANT CREATION (reference scenarios)
-- =========================================================
-- TYPE:
--   Exploratory reference scenarios
--
-- PURPOSE:
--   Manual validation of svc_create_assistant onboarding,
--   role exclusivity, and validation rules.
--
-- REQUIRES:
--   init_qa + QA fixtures + qa_registrar_emp_id(), qa_vet_primary_id()
--
-- RELATED:
--   Services/01_Module1/02_User_Creation/03_NewAssistant.sql
--   QA/01_Integrity/01_Module1/05_Role_Disjunction.sql
--   Queries/01_Module1/02_User_Creation_Inspection.sql
-- =========================================================

--==============================
-- PREFLIGHT CLEANUP (manual scope)
--==============================

delete from assistant
 where id_emp in (
     select e.id_emp
       from employee e
       join user_account u on u.id_usr = e.id_usr
      where u.ema_usr like 'qa.manual.assistant.%@qa.miacaomigo.pt'
 );

delete from occupies
 where id_emp in (
     select e.id_emp
       from employee e
       join user_account u on u.id_usr = e.id_usr
      where u.ema_usr like 'qa.manual.assistant.%@qa.miacaomigo.pt'
 );

delete from employee
 where id_usr in (
     select id_usr from user_account
      where ema_usr like 'qa.manual.assistant.%@qa.miacaomigo.pt'
 );

delete from user_account
 where ema_usr like 'qa.manual.assistant.%@qa.miacaomigo.pt';


--==============================
-- SUCCESS PATHS
--==============================

-- create completely new assistant
-- expected:
-- - employee + assistant rows
-- - returns id_emp

select svc_create_assistant(
    'QA Manual New Assistant',
    'Rua QA Manual Assistant 1, Braga',
    '4700-831',
    '619000831',
    '+351910383131',
    'qa.manual.assistant.new@qa.miacaomigo.pt',
    '+351253383131',
    '+351912383131',
    '$2b$12$validhashassistant000001',
    qa_registrar_emp_id(),
    'triagem clinica'
);


-- create assistant for existing client identity
-- context: qa_client_secondary (goncalo.machado.cstress@gmail.com)
-- expected:
-- - identity reused
-- - employee + assistant created

select svc_create_assistant(
    'Goncalo Filipe Machado QA',
    'Rua de Santa Justa 14, Lisboa',
    '1100-483',
    '610000034',
    '+351910300034',
    'goncalo.machado.cstress@gmail.com',
    '+351253383232',
    '+351912383232',
    '$2b$12$validhashassistant000002',
    qa_registrar_emp_id(),
    'rececao e apoio administrativo'
);


--==============================
-- BUSINESS RULE VIOLATIONS
--==============================

-- duplicated assistant role on same employee
-- context: employee created in first success test
-- expected: exception — assistant role already exists

insert into assistant (id_emp, fun_ass)
select e.id_emp, 'duplicated role'
  from employee e
  join user_account u on u.id_usr = e.id_usr
 where u.ema_usr = 'qa.manual.assistant.new@qa.miacaomigo.pt';


-- veterinarian role conflict
-- context: qa_vet_primary_id() already holds veterinarian role
-- expected: exception — employee already has veterinarian role

select svc_create_assistant(
    'Bruno Filipe Matos QA Vet',
    'Rua da Junqueira 55, Coimbra',
    '3000-341',
    '610000004',
    '+351910300004',
    'bruno.matos.cstress@outlook.pt',
    '+351253383434',
    '+351912383434',
    '$2b$12$validhashassistant000004',
    qa_registrar_emp_id(),
    'conflicting role'
);


-- invalid function description (check constraint)
-- expected: validation exception

select svc_create_assistant(
    'QA Manual Invalid Assistant',
    'Rua Teste',
    '4700-999',
    '619000835',
    '+351955555555',
    'qa.manual.assistant.invalid@qa.miacaomigo.pt',
    '+351253383535',
    '+351912383535',
    '$2b$12$validhashassistant000005',
    qa_registrar_emp_id(),
    ' '
);


-- invalid registering employee
-- expected: exception during employee creation (invalid registrar)

select svc_create_assistant(
    'QA Manual Invalid Registrar Assistant',
    'Rua Teste',
    '4700-999',
    '619000836',
    '+351966666666',
    'qa.manual.assistant.badreg@qa.miacaomigo.pt',
    '+351253383636',
    '+351912383636',
    '$2b$12$validhashassistant000006',
    9999,
    'support operations'
);


--==============================
-- POSTFLIGHT CLEANUP (manual scope)
--==============================

delete from assistant
 where id_emp in (
     select e.id_emp
       from employee e
       join user_account u on u.id_usr = e.id_usr
      where u.ema_usr like 'qa.manual.assistant.%@qa.miacaomigo.pt'
         or u.ema_usr = 'goncalo.machado.cstress@gmail.com'
 );

delete from occupies
 where id_emp in (
     select e.id_emp
       from employee e
       join user_account u on u.id_usr = e.id_usr
      where u.ema_usr like 'qa.manual.assistant.%@qa.miacaomigo.pt'
 );

delete from employee
 where id_usr in (
     select id_usr from user_account
      where ema_usr like 'qa.manual.assistant.%@qa.miacaomigo.pt'
 );

-- restore QA_CLIENT_SECONDARY as client-only
delete from employee e
 using user_account u
 where e.id_usr = u.id_usr
   and u.ema_usr = 'goncalo.machado.cstress@gmail.com';

delete from user_account
 where ema_usr like 'qa.manual.assistant.%@qa.miacaomigo.pt';
