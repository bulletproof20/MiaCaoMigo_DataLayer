-- =========================================================
-- QA CLEANUP — MODULE 1 — CLOCKING / ABSENCE RESIDUE
-- =========================================================
-- PURPOSE:
--   Restores deterministic QA baseline after integrity and
--   exploratory scenarios related to:
--     - employee clocking
--     - inactive employees
--     - absence overlap validation
--
-- CLEANUP STRATEGY:
--   - Remove temporary QA absences created by integrity tests
--   - Restore clockable employee active state
--
-- SAFETY:
--   Cleanup is scoped only to QA-generated records and
--   semantic fixture entities referenced through contracts.
--
-- RELATED:
--   QA/fixtures/01_Module1/01_Core_Context.sql
--   QA/contracts/01_QA_Functions.sql
--   QA/01_Integrity/01_Module1/03_Clocking_Rules.sql
--   QA/01_Integrity/01_Module1/04_Absence_Overlap.sql
-- =========================================================


--==============================
-- REMOVE QA ABSENCE RESIDUE
--==============================
-- Deletes temporary absence records generated during
-- integrity overlap and inactive-state scenarios.

delete from absence
 where mot_abs like 'integrity absence%';


--==============================
-- RESTORE CLOCKABLE EMPLOYEE
--==============================
-- Ensures the deterministic QA employee fixture used in
-- clocking scenarios remains active for subsequent runs.

update employee
   set dea_dat_emp = null
 where id_emp = qa_emp_clockable_id()
   and dea_dat_emp is not null;