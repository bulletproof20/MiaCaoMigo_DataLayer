-- =========================================================
-- INTEGRITY — MODULE 2 — BREED / SPECIES CONSISTENCY
-- =========================================================
-- TYPE:     01_Integrity
-- REQUIRES: init_qa + fixtures/02_Module2/01_Animals_Ownership.sql
-- RULE:     trg_validate_animal_breed_species
-- CONTRACT: qa_animal_stress_internal_id (dog); mismatched cat breed by name
-- =========================================================

do $$
declare
    v_mismatch_bre int;
begin
    select b.id_bre into v_mismatch_bre
      from breed b
      join species s on s.id_spc = b.id_spc
     where s.id_spc = qa_species_cat_id()
     limit 1;

    update animal
       set id_bre = v_mismatch_bre
     where id_ani = qa_animal_stress_internal_id();

    raise notice 'FAIL: breed/species mismatch should be blocked';
exception
    when others then
        if sqlerrm like '%Breed%' or sqlerrm like '%species%' or sqlerrm like '%Consistency%' then
            raise notice 'PASS: breed/species inconsistency blocked — %', sqlerrm;
        else
            raise notice 'FAIL: unexpected breed/species error — %', sqlerrm;
        end if;
end;
$$;
