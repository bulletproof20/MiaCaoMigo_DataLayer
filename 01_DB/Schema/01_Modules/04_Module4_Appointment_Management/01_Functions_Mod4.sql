--=========================================================
-- FUNCTIONS - MODULE 4 (APPOINTMENT MANAGEMENT)
-- Contains trigger-support functions and business logic
--=========================================================

--=========================================================
-- FUNCTION 1: fn_block_overlapping_appointments
-- Prevents scheduling of overlapping appointments for the same veterinarian.
--=========================================================
create or replace function fn_block_overlapping_appointments()
returns trigger as $$
begin
    -- Check for existing appointments that overlap with the new/updated one
    if exists (
        select 1
        from appointment a
        where a.id_emp = new.id_emp -- Same veterinarian
          and a.id_app != new.id_app -- Exclude the current appointment itself during updates
          and (
                (new.sta_dat_app, new.end_dat_app) OVERLAPS (a.sta_dat_app, a.end_dat_app)
              )
    ) then
        raise exception 'O veterinário já tem uma consulta sobreposta agendada.';
    end if;

    return new;
end;
$$ language plpgsql;

--=========================================================
-- FUNCTION 2: fn_block_appointment_if_vet_unavailable
-- Prevents scheduling an appointment if the assigned veterinarian
-- is marked as absent during the appointment period.
--=========================================================
create or replace function fn_block_appointment_if_vet_unavailable()
returns trigger as $$
begin
    -- Check if the veterinarian is absent during the proposed appointment time
    if exists (
        select 1
        from absence a
        where a.id_emp = new.id_emp -- Same veterinarian
          and (new.sta_dat_app, new.end_dat_app) OVERLAPS (a.sta_dat_tim_abs, a.end_dat_tim_abs)
    ) then
        raise exception 'O veterinário está indisponível devido a uma ausência durante este período de consulta.';
    end if;

    -- Optionally, you could also check for clock-in status if it's a strict requirement
    -- For example, if an employee *must* be clocked in to have an appointment.
    -- This would depend on business rules. For now, we focus on explicit absences.

    return new;
end;
$$ language plpgsql;

--=========================================================
-- FUNCTION 3: fn_validate_prescription_timing
-- Ensures a prescription's issue date is not before the
-- associated appointment's start date.
--=========================================================
create or replace function fn_validate_prescription_timing()
returns trigger as $$
declare
    v_appointment_start_time timestamp;
begin
    select sta_dat_app into v_appointment_start_time
    from appointment
    where id_app = new.id_app;

    if new.reg_dat_pre < v_appointment_start_time then
        raise exception 'A data de emissão da prescrição não pode ser anterior à data de início da consulta.';
    end if;

    return new;
end;
$$ language plpgsql;

--=========================================================
-- FUNCTION 4: fn_deduct_product_stock
-- Deducts the quantity of products used in an appointment
-- from the stock. Checks for sufficient stock before deduction.
--=========================================================
create or replace function fn_deduct_product_stock()
returns trigger as $$
declare
    v_current_stock_qty int;
begin
    -- Get current stock quantity for the product
    select qty_sto into v_current_stock_qty
    from stock
    where id_pro = new.id_pro;

    -- Check if there's enough stock
    if v_current_stock_qty < new.qty_pre_pro then
        raise exception 'O produto com ID % não tem stock suficiente (Requisitou: %, Disponível: %)',
                        new.id_pro, new.qty_pre_pro, v_current_stock_qty;
    end if;

    -- Deduct stock
    update stock
    set qty_sto = qty_sto - new.qty_pre_pro
    where id_pro = new.id_pro;

    return new;
end;
$$ language plpgsql;

--=========================================================
-- FUNCTION 5: fn_block_past_appointments
-- Prevents scheduling appointments with a start date in the past.
--=========================================================
create or replace function fn_block_past_appointments()
returns trigger as $$
begin
    if new.sta_dat_app < current_timestamp then
        raise exception 'A data de início da consulta não pode ser no passado.';
    end if;
    return new;
end;
$$ language plpgsql;