-- =========================================================
-- MODULE 2 — ANIMAL MANAGEMENT
-- =========================================================
-- FILE: 03_Triggers_Mod2.sql
-- =========================================================
--
-- DESCRIPTION
-- ---------------------------------------------------------
-- Table-level triggers enforcing temporal, ownership, and species
-- consistency rules for animals and deliveries.
--
-- This file contains:
-- - Ownership guards tied to animal state
-- - Delivery vs rescue date checks
-- - Breed/species validation hooks
-- ---------------------------------------------------------
--
-- LOAD ORDER
-- ---------------------------------------------------------
-- Requires:
-- - 02_Functions_Mod2.sql
-- - Module 2 core tables (animal, ownership, delivery)
--
-- Must load before:
-- - 04_Indexes_Mod2.sql (partial uniques complement triggers)
-- =========================================================

-- =========================================================
-- Validates ownership inserts against the animal record       Bloqueia a inserção de uma nova posse se o animal associado estiver inativo, falecido ou adotado
-- =========================================================

drop trigger if exists trg_block_ownership_if_animal_inactive on ownership;
create trigger trg_block_ownership_if_animal_inactive
before insert on ownership           -- fires before linking an owner
for each row                         -- once per new ownership row
execute function tfn_block_ownership_if_animal_inactive();


-- =========================================================
-- Ensures delivery dates are not earlier than rescue dates   Garante que a data de entrega não seja anterior à data de resgate
-- =========================================================

drop trigger if exists trg_check_delivery_date_consistency on delivery;
create trigger trg_check_delivery_date_consistency
before insert or update on delivery   -- fires on delivery insert/update
for each row                          -- once per affected row
execute function tfn_check_delivery_date_after_rescue();


-- =========================================================
-- Prevents parallel active ownership rows for the same animal  Impede que um segundo registro de posse seja criado para o mesmo animal enquanto uma posse anterior ainda estiver ativa
-- =========================================================

drop trigger if exists trg_prevent_duplicate_active_ownership on ownership;
create trigger trg_prevent_duplicate_active_ownership
before insert on ownership           -- fires before insert
for each row                         -- once per attempted row
execute function tfn_prevent_overlapping_ownership();


-- =========================================================
-- Validates breed/species consistency on animal changes        Garante que a raça do animal pertença à espécie selecionada
-- =========================================================

drop trigger if exists trg_validate_animal_breed_species on animal;
create trigger trg_validate_animal_breed_species
before insert or update on animal    -- fires on animal insert/update
for each row                         -- once per animal row
execute function tfn_validate_breed_species_consistency();
