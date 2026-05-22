-- =========================================================
-- QA CLEANUP — MODULE 1 clocking / absence test residue
-- =========================================================

delete from absence
 where mot_abs like 'integrity absence%';

update employee
   set dea_dat_emp = null
 where id_emp = qa_emp_clockable_id()
   and dea_dat_emp is not null;
