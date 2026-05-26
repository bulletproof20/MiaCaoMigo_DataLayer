-- =========================================================
-- QUERIES — MODULE 1 — EMPLOYEE CREATION (reference scenarios)
-- =========================================================
-- TYPE:
--   Exploratory reference scenarios
--
-- PURPOSE:
--   Manual validation of svc_create_employee registrar rules,
--   identity reuse, and validation errors using QA contracts.
--
-- REQUIRES:
--   init_qa + QA fixtures + qa_registrar_emp_id()
--
-- RELATED:
--   Services/01_Module1/02_User_Creation/02_NewEmployee.sql
--   QA/fixtures/seed/m1_core_context.sql
--   Queries/01_Module1/02_User_Creation_Inspection.sql
-- =========================================================

--==============================
-- PREFLIGHT CLEANUP (manual scope)
--==============================

delete from occupies
 where id_emp in (
     select e.id_emp
       from employee e
       join user_account u on u.id_usr = e.id_usr
      where u.ema_usr like 'qa.manual.employee.%@qa.miacaomigo.pt'
 );

delete from assistant
 where id_emp in (
     select e.id_emp from employee e
       join user_account u on u.id_usr = e.id_usr
      where u.ema_usr like 'qa.manual.employee.%@qa.miacaomigo.pt'
 );

delete from veterinarian
 where id_emp in (
     select e.id_emp from employee e
       join user_account u on u.id_usr = e.id_usr
      where u.ema_usr like 'qa.manual.employee.%@qa.miacaomigo.pt'
        and e.ema_emp not in ('8@miacaomigo.pt', '21@miacaomigo.pt')
 );

delete from employee
 where id_usr in (
     select id_usr from user_account
      where ema_usr like 'qa.manual.employee.%@qa.miacaomigo.pt'
 );

delete from client
 where id_usr in (
     select id_usr from user_account
      where ema_usr = 'qa.manual.employee.clientonly@qa.miacaomigo.pt'
 );

delete from user_account
 where ema_usr like 'qa.manual.employee.%@qa.miacaomigo.pt';


--==============================
-- SETUP (client-only identity for promotion test)
--==============================

select svc_create_client(
    'QA Manual Client To Employee',
    'Rua QA Manual 20, Braga',
    '4700-820',
    '619000820',
    '+351910382020',
    'qa.manual.employee.clientonly@qa.miacaomigo.pt',
    '$2b$12$cstress_client_to_emp_020'
);


--==============================
-- SUCCESS PATHS
--==============================

-- create completely new employee
-- context: registrar = qa_registrar_emp_id()
-- expected:
-- - new user_account + employee
-- - corporate email {id_usr}@miacaomigo.pt

select svc_create_employee(
    'QA Manual New Employee',
    'Rua QA Manual Employee 1, Braga',
    '4700-821',
    '619000821',
    '+351910382021',
    'qa.manual.employee.new@qa.miacaomigo.pt',
    '+351253382021',
    '+351912382021',
    '$2b$12$cstress_new_employee_001',
    qa_registrar_emp_id()
);


-- create employee for pure client identity
-- context: qa.manual.employee.clientonly@qa.miacaomigo.pt
-- expected:
-- - identity reused
-- - employee spell created

select svc_create_employee(
    'QA Manual Client To Employee',
    'Rua QA Manual 20, Braga',
    '4700-820',
    '619000820',
    '+351910382020',
    'qa.manual.employee.clientonly@qa.miacaomigo.pt',
    '+351253382020',
    '+351912382020',
    '$2b$12$cstress_client_to_employee_002',
    qa_registrar_emp_id()
);


--==============================
-- BUSINESS RULE VIOLATIONS
--==============================

-- duplicated active employee (bootstrap administrator)
-- context: id_usr = 1 already has employee id_emp = 1
-- expected: exception — user already has an employee account

select svc_create_employee(
    'MiaCaoMigo Platform Administrator',
    'IPCA Technology Campus, Barcelos, Portugal',
    '4750-810',
    '516284930',
    '+351253802190',
    'platform.admin@ipca.pt',
    '+351253802299',
    '+351912382299',
    '$2b$12$cstress_duplicate_employee_004',
    qa_registrar_emp_id()
);


-- invalid registrar employee id
-- expected: exception — registering employee invalid

select svc_create_employee(
    'QA Manual Invalid Registrar Target',
    'Rua de Teste',
    '4700-999',
    '619000825',
    '+351922222222',
    'qa.manual.employee.badreg@qa.miacaomigo.pt',
    '+351253382525',
    '+351912382525',
    '$2b$12$cstress_invalid_registrar_005',
    9999
);


-- inactive registrar employee
-- context: bootstrap admin deactivated for this scenario only
-- expected: exception — registering employee inactive

update employee
   set dea_dat_emp = current_timestamp
 where id_emp = 1
   and dea_dat_emp is null;

select svc_create_employee(
    'QA Manual Inactive Registrar Blocked',
    'Rua de Teste',
    '4700-999',
    '619000826',
    '+351933333333',
    'qa.manual.employee.inactive.reg@qa.miacaomigo.pt',
    '+351253382626',
    '+351912382626',
    '$2b$12$cstress_inactive_registrar_006',
    1
);

update employee
   set dea_dat_emp = null
 where id_emp = 1;


-- NIF belongs to user A / email belongs to user B
-- context: admin NIF + secondary QA client email
-- expected: exception — identity inconsistency

select svc_create_employee(
    'QA Manual Identity Conflict',
    'Rua de Teste',
    '4700-999',
    '516284930',
    '+351944444444',
    'goncalo.machado.cstress@gmail.com',
    '+351253382727',
    '+351912382727',
    '$2b$12$cstress_identity_conflict_007',
    qa_registrar_emp_id()
);


-- existing NIF + new email
-- expected: exception — identity inconsistency

select svc_create_employee(
    'QA Manual Partial Conflict NIF',
    'Rua de Teste',
    '4700-999',
    '610000004',
    '+351955555555',
    'qa.manual.employee.partial.nif@qa.miacaomigo.pt',
    '+351253382828',
    '+351912382828',
    '$2b$12$cstress_partial_conflict_008',
    qa_registrar_emp_id()
);


-- existing email + new NIF
-- expected: exception — identity inconsistency

select svc_create_employee(
    'QA Manual Partial Conflict Email',
    'Rua de Teste',
    '4700-999',
    '619000829',
    '+351966666666',
    'bruno.matos.cstress@outlook.pt',
    '+351253382929',
    '+351912382929',
    '$2b$12$cstress_partial_conflict_009',
    qa_registrar_emp_id()
);


--==============================
-- FORMAT VALIDATION
--==============================

select svc_create_employee(
    'QA Manual Invalid Professional Phone',
    'Rua de Teste',
    '4700-999',
    '619000830',
    '+351977777777',
    'qa.manual.employee.phone.pro@qa.miacaomigo.pt',
    '912345678',
    '+351912383030',
    '$2b$12$cstress_invalid_phone_010',
    qa_registrar_emp_id()
);

select svc_create_employee(
    'QA Manual Invalid Emergency Phone',
    'Rua de Teste',
    '4700-999',
    '619000831',
    '+351988888888',
    'qa.manual.employee.phone.emg@qa.miacaomigo.pt',
    '+351253383131',
    '939999999',
    '$2b$12$cstress_invalid_emergency_011',
    qa_registrar_emp_id()
);

select svc_create_employee(
    'QA Manual Invalid Email',
    'Rua de Teste',
    '4700-999',
    '619000832',
    '+351999999999',
    'email_invalido',
    '+351253383232',
    '+351912383232',
    '$2b$12$cstress_invalid_email_012',
    qa_registrar_emp_id()
);

select svc_create_employee(
    'QA Manual Invalid Postal',
    'Rua de Teste',
    '4700999',
    '619000833',
    '+351911111111',
    'qa.manual.employee.postal@qa.miacaomigo.pt',
    '+351253383333',
    '+351912383333',
    '$2b$12$cstress_invalid_postal_013',
    qa_registrar_emp_id()
);

select svc_create_employee(
    'QA Manual Invalid Password',
    'Rua de Teste',
    '4700-999',
    '619000834',
    '+351922222223',
    'qa.manual.employee.password@qa.miacaomigo.pt',
    '+351253383434',
    '+351912383434',
    '123',
    qa_registrar_emp_id()
);

select svc_create_employee(
    'QA Manual Invalid NIF',
    'Rua de Teste',
    '4700-999',
    'ABC123',
    '+351933333334',
    'qa.manual.employee.nif@qa.miacaomigo.pt',
    '+351253383535',
    '+351912383535',
    '$2b$12$cstress_invalid_nif_015',
    qa_registrar_emp_id()
);


--==============================
-- POSTFLIGHT CLEANUP (manual scope)
--==============================

delete from occupies
 where id_emp in (
     select e.id_emp
       from employee e
       join user_account u on u.id_usr = e.id_usr
      where u.ema_usr like 'qa.manual.employee.%@qa.miacaomigo.pt'
 );

delete from employee
 where id_usr in (
     select id_usr from user_account
      where ema_usr like 'qa.manual.employee.%@qa.miacaomigo.pt'
 );

delete from client
 where id_usr in (
     select id_usr from user_account
      where ema_usr = 'qa.manual.employee.clientonly@qa.miacaomigo.pt'
 );

delete from user_account
 where ema_usr like 'qa.manual.employee.%@qa.miacaomigo.pt';

update employee
   set dea_dat_emp = null
 where id_emp = 1;
