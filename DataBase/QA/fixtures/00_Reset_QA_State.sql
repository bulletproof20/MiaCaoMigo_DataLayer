-- =========================================================
-- QA FIXTURE — RESET SCOPED QA STATE (idempotent preflight)
-- =========================================================
-- TYPE:     fixture (data only)
-- REQUIRES: Bootstrap init_qa (Master only; no DemoData)
-- SCOPE:   QA-tagged rows only; never truncates Master catalogs
-- =========================================================

-- Close open login sessions used by integrity login tests
update login_record
   set sou_tim_log = current_timestamp
 where ema_log in (qa_login_session_emp_email(), qa_registrar_emp_email())
   and sou_tim_log is null;

delete from absence
 where mot_abs like 'integrity%'
    or mot_abs like 'qa fixture%';

-- Module 4 — deterministic far-future appointments
delete from appointment_notification
 where id_app in (
     select a.id_app from appointment a where a.sch_dat_app >= timestamp '2099-01-01'
 );
delete from appointment where sch_dat_app >= timestamp '2099-01-01';

-- Module 3 — QA commercial rows
delete from invoice_line
 where id_pro in (select id_pro from product where ref_pro like 'QA-%');
delete from purchase_line
 where id_pro in (select id_pro from product where ref_pro like 'QA-%');
delete from stock
 where id_pro in (select id_pro from product where ref_pro like 'QA-%');
delete from product where ref_pro like 'QA-%';
delete from family where nam_fam like 'QA %';

-- Module 2 — QA animals and dependents (reg_id_ani prefix)
delete from delivery_employee
 where id_del in (
     select d.id_del
       from delivery d
       join animal an on an.id_ani = d.id_ani
      where an.reg_id_ani like 'QA-%'
 );
delete from concession
 where id_ani in (select id_ani from animal where reg_id_ani like 'QA-%');
delete from delivery
 where id_ani in (select id_ani from animal where reg_id_ani like 'QA-%');
delete from ownership
 where id_ani in (select id_ani from animal where reg_id_ani like 'QA-%');

update animal set sta_ani = 'Interno'
 where reg_id_ani like 'QA-%' and sta_ani = 'Adotado';
delete from animal where reg_id_ani like 'QA-%';

delete from external_entity where ema_ext_ent like '%@qa.miacaomigo.pt';

-- QA-only breeds (Master keeps id_bre 1–2)
delete from breed where nam_bre like 'QA %';

-- QA-only species beyond Master Dog/Cat
delete from species s
 where s.nam_spc = 'Bird'
   and not exists (select 1 from animal a where a.id_spc = s.id_spc and a.reg_id_ani not like 'QA-%');
