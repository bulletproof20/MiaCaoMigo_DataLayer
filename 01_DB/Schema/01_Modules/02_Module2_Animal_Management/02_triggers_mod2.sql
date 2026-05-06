--=========================================================
-- TRIGGERS - MODULE 2 (ANIMAL MANAGEMENT / ADOPTION)
-- Enforces business rules for adoptions and animal flow
--=========================================================

--=========================================================
-- TRIGGER 1: trg_register_adoption
-- Validates if an animal is available before allowing
-- a new ownership record to be created.
--=========================================================
create or replace trigger trg_register_adoption
before insert on ownwership
for each row
execute function fn_register_adoption();

--=========================================================
-- TRIGGER 2: trg_register_delivery_team
-- Handles post-rescue logic, ensuring the animal status
-- is updated to 'Interno' after a delivery is registered.
--=========================================================
create or replace trigger trg_register_delivery_team
after insert on delivery
for each row
execute function fn_register_delivery_team();

--=========================================================
-- TRIGGER 3: trg_animal_exit
-- Automatically closes open ownerships when an animal's 
-- status is updated to a terminal state (e.g., 'Falecido').
--=========================================================
create or replace trigger trg_animal_exit
after update of sta_ani on animal
for each row
execute function fn_animal_exit();

--=========================================================
-- TRIGGER 4: trg_get_animal_history
-- Note: Typically, 'GET' functions are called via SELECT.
-- If used as a trigger for logging purposes, it would 
-- trigger after changes to relevant tables.
--=========================================================
create or replace trigger trg_get_animal_history
after insert or update on Titularidade
for each row
execute function fn_get_animal_history();

