--=========================================================
-- TRIGGERS - MODULE 2
-- Enforces business rules and automates animal status updates
--=========================================================

--=========================================================
-- TRIGGER 1: trg_animal_adotado
-- Updates the animal status to 'Adotado' automatically
-- upon the creation of a new ownership record.
--=========================================================

create or replace trigger trg_animal_adotado
after insert on ownership           -- fires after a new adoption is recorded
for each row                         -- executes once per adoption
execute function fn_update_animal_status_ownership();


--=========================================================
-- TRIGGER 2: trg_animal_chegou
-- Updates the animal status to 'Interno' automatically
-- upon the registration of a new delivery/rescue.
--=========================================================

create or replace trigger trg_animal_chegou
after insert on delivery             -- fires after a new rescue/delivery
for each row                         -- executes once per record
execute function fn_update_animal_status_delivery();


--=========================================================
-- TRIGGER 3: trg_animal_cedido
-- Updates the animal status to 'Cedido' automatically
-- when an animal is transferred to an external entity.
--=========================================================

create or replace trigger trg_animal_cedido
after insert on concession           -- fires after a new concession record
for each row                         -- executes once per transaction
execute function fn_update_animal_status_concession();