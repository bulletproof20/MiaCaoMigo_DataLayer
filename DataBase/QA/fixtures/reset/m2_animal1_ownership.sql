-- =========================================================
-- QA CLEANUP — MODULE 2 — ANIMAL OWNERSHIP RESET
-- =========================================================
-- PURPOSE:
--   Restores the deterministic ownership baseline used by
--   Module 2 integrity and exploratory lifecycle scenarios.
--
-- CLEANUP STRATEGY:
--   - Close any remaining active ownership records
--   - Restore animal operational state to "Interno"
--
-- TARGET FIXTURE:
--   qa_animal_internal_id()
--     -> QA deterministic animal fixture used in:
--        ownership lifecycle
--        duplicate ownership validation
--        concession/adoption scenarios
--
-- SAFETY:
--   Cleanup is fully scoped through QA contracts and
--   only affects deterministic QA fixture entities.
--
-- RELATED:
--   QA/contracts/01_QA_Functions.sql
--   QA/fixtures/seed/m2_animals_ownership.sql
--   QA/01_Integrity/02_Module2/01_Duplicate_Ownership.sql
--   QA/01_Integrity/02_Module2/02_Ownership_Lifecycle.sql
-- =========================================================


do $$
declare
    v_ani int := qa_animal_internal_id();
begin

    -- Fixture not available -> nothing to restore.
    if v_ani is null then
        return;
    end if;


    --==============================
    -- CLOSE ACTIVE OWNERSHIPS
    --==============================
    -- Ensures no ownership remains open after lifecycle,
    -- concession or duplicate-ownership scenarios.

    update ownership
       set end_dat_own = coalesce(end_dat_own, current_date),
           mot_own     = coalesce(mot_own, 'QA cleanup')
     where id_ani = v_ani
       and end_dat_own is null;


    --==============================
    -- RESTORE INTERNAL STATUS
    --==============================
    -- Returns the QA animal fixture to its deterministic
    -- baseline operational state.

    update animal
       set sta_ani = 'Interno'
     where id_ani = v_ani;

end;
$$;