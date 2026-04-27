--=========================================================
-- TRIGGERS - MODULE 1
-- Binds functions to table events
--=========================================================

--=========================================================
-- TRIGGER: trg_block_clock_in_insert
-- Executes validation before inserting a clock-in record
--=========================================================

create or replace trigger trg_block_clock_in_insert
before insert on clock_in            -- fires before a new row is inserted
for each row                         -- executes once per inserted row
execute function fn_block_clock_in_if_absent(); -- calls validation function

