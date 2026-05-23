-- =========================================================
-- QA FIXTURE — GLOBAL QA STATE RESET (idempotent preflight)
-- =========================================================
-- TYPE:
--   Fixture cleanup / deterministic baseline restoration
--
-- PURPOSE:
--   Restores the shared QA environment to a deterministic
--   baseline before integrity, stress and exploratory runs.
--
-- EXECUTION:
--   Automatically loaded by:
--     - run_fixtures.ps1
--     - run_ci.ps1
--     - run_integrity_all.ps1
--     - run_stress_all.ps1
--
-- REQUIRES:
--   Bootstrap init_qa (Master baseline only; no DemoData)
--
-- CLEANUP STRATEGY:
--   - Only affects QA-scoped entities
--   - Never truncates Master catalogs
--   - Never touches production-style baseline data
--   - Uses semantic QA prefixes/contracts for isolation
--
-- QA IDENTIFIERS:
--   QA-*
--   qa.*
--   qa-manual-*
--   STRESS-*
--
-- SAFETY:
--   Cleanup is deterministic and idempotent:
--     - safe to execute multiple times
--     - safe before CI/integrity/stress reruns
--     - avoids persistent QA drift
--
-- RELATED:
--   QA/contracts/01_QA_Functions.sql
--   QA/fixtures/*
--   QA/fixtures/cleanup/*
-- =========================================================



-- =========================================================
-- MODULE 1 — AUTHENTICATION / ABSENCE RESET
-- =========================================================
-- Restores deterministic authentication and employee state
-- used by integrity and exploratory scenarios.


-- Close open QA login sessions used by integrity scenarios.

update login_record
   set sou_tim_log = current_timestamp
 where ema_log in (
     qa_login_session_emp_email(),
     qa_registrar_emp_email()
 )
   and sou_tim_log is null;


-- Remove temporary integrity/fixture absences.

delete from absence
 where mot_abs like 'integrity%'
    or mot_abs like 'qa fixture%';



-- =========================================================
-- MODULE 4 — APPOINTMENT / NOTIFICATION RESET
-- =========================================================
-- Removes QA-scoped appointments (2099 slots + integrity near-now rows).


delete from appointment_notification
 where id_app in (
     select ap.id_app
       from appointment ap
       join animal a on a.id_ani = ap.id_ani
      where a.reg_id_ani like 'QA-%'
 );


delete from rel_app_product
 where id_app in (
     select ap.id_app
       from appointment ap
       join animal a on a.id_ani = ap.id_ani
      where a.reg_id_ani like 'QA-%'
 );


delete from prescription
 where id_app in (
     select ap.id_app
       from appointment ap
       join animal a on a.id_ani = ap.id_ani
      where a.reg_id_ani like 'QA-%'
 );


delete from anamnesis
 where id_app in (
     select ap.id_app
       from appointment ap
       join animal a on a.id_ani = ap.id_ani
      where a.reg_id_ani like 'QA-%'
 );


delete from overall_assessment
 where id_app in (
     select ap.id_app
       from appointment ap
       join animal a on a.id_ani = ap.id_ani
      where a.reg_id_ani like 'QA-%'
 );


delete from appointment
 where id_ani in (
     select id_ani from animal where reg_id_ani like 'QA-%'
 );


delete from appointment
 where sch_dat_app >= timestamp '2099-01-01';



-- =========================================================
-- MODULE 3 — COMMERCIAL / STOCK RESET
-- =========================================================
-- Removes QA-tagged commercial entities and dependent rows
-- created by integrity and stress scenarios.


delete from invoice_line
 where id_pro in (
     select id_pro
       from product
      where ref_pro like 'QA-%'
 );


delete from purchase_line
 where id_pro in (
     select id_pro
       from product
      where ref_pro like 'QA-%'
 );


delete from stock
 where id_pro in (
     select id_pro
       from product
      where ref_pro like 'QA-%'
 );


delete from product
 where ref_pro like 'QA-%';


delete from family
 where nam_fam like 'QA %';



-- =========================================================
-- MODULE 2 — ANIMAL / OWNERSHIP RESET
-- =========================================================
-- Removes deterministic QA animal lifecycle residue and
-- restores baseline operational state.


delete from delivery_employee
 where id_del in (
     select d.id_del
       from delivery d
       join animal an on an.id_ani = d.id_ani
      where an.reg_id_ani like 'QA-%'
 );


delete from concession
 where id_ani in (
     select id_ani
       from animal
      where reg_id_ani like 'QA-%'
 );


delete from delivery
 where id_ani in (
     select id_ani
       from animal
      where reg_id_ani like 'QA-%'
 );


delete from ownership
 where id_ani in (
     select id_ani
       from animal
      where reg_id_ani like 'QA-%'
 );


-- Restore adopted QA animals back to deterministic
-- internal operational state before deletion.

update animal
   set sta_ani = 'Interno'
 where reg_id_ani like 'QA-%'
   and sta_ani = 'Adotado';


delete from animal
 where reg_id_ani like 'QA-%';


delete from external_entity
 where ema_ext_ent like '%@qa.miacaomigo.pt';



-- =========================================================
-- MASTER-SAFE QA CATALOG CLEANUP
-- =========================================================
-- Removes QA-only catalog extensions while preserving
-- deterministic Master baseline entities.


-- QA-only breeds (Master keeps canonical breeds).

delete from breed
 where nam_bre like 'QA %';


-- QA-only species beyond Master baseline Dog/Cat.

delete from species s
 where s.nam_spc = 'Bird'
   and not exists (
       select 1
         from animal a
        where a.id_spc = s.id_spc
          and a.reg_id_ani not like 'QA-%'
   );