--=========================================================
-- PROCEDURE: prc_auto_end_clsd_time_in_appointment
-- Closes open appointments by setting the end time to the current timestamp.
-- This procedure can be called by a scheduled job to ensure that
--=========================================================

create or replace procedure prc_auto_close_clock_in_midnight()
language plpgsql
as $$
begin

    -- Update all open clock-in records from previous days
    update clock_in
    set end_dat_clk = date_trunc('day', now())  -- current day at 00:00
    where end_dat_clk is null
      and sta_dat_clk < date_trunc('day', now()); -- started before today

end;
$$;

--=========================================================
-- PROCEDURE: prc_generate_appointment_warnings
-- Generates a warning message for clients who have an appointment the next day.
-- This procedure is intended to be called by a scheduled job.
--=========================================================
create or replace procedure prc_generate_appointment_warnings()
language plpgsql
as $$
declare
    consulta record;
    v_aviso text;
begin
    for consulta in (
        select
            a.id_cli,
            c.nam_usr as nome_cliente,
            e.nam_emp as nome_veterinario,
            an.nam_ani as nome_animal
        from appointment a
        join client c on a.id_cli = c.id_cli
        join animal an on a.id_animal = an.id_ani
        join employee e on a.id_emp = e.id_emp
        where a.sta_dat_app::date = current_date + interval '1 day' and a.status_app = 'Scheduled'
    ) loop
        v_aviso := format('Lembrete: Bom dia %s! A sua consulta para o animal %s com o/a Dr(a). %s está marcada para amanhã.', consulta.nome_cliente, consulta.nome_animal, consulta.nome_veterinario);
        insert into appointment_notification (id_cli, message) values (consulta.id_cli, v_aviso);
    end loop;
end;
$$;

--=========================================================
-- PROCEDURE: prc_cancel_appointment
-- Cancels an appointment by setting its status to 'Cancelled'.
-- The cancellation is only allowed if done more than 24 hours
-- before the appointment's start time.
--=========================================================
create or replace procedure prc_cancel_appointment(cancl_app_id int)
language plpgsql
as $$
declare
    v_appointment_start timestamp;
begin
    -- Get the appointment start time and lock the row
    select sta_dat_app into v_appointment_start from appointment where id_app = cancl_app_id for update;

    if not found then
        raise exception 'Consulta com ID % não encontrada.', cancl_app_id;
    end if;

    if ((now() + interval '24 hours') - v_appointment_start <= 1) then
    -- Check if the cancellation is being made within the allowed window
        raise exception 'A consulta só pode ser cancelada com mais de 24 horas de antecedência.';
    end if;

    -- Update the status to 'Cancelled'
    update appointment set status_app = 'Cancelled' where id_app = cancl_app_id;
end;
$$;

--=========================================================
-- PROCEDURE: prc_update_appointment_time
-- Updates the start and end time of an existing appointment.
-- The update is only allowed if done more than 24 hours
-- before the original appointment's start time.
--=========================================================
create or replace procedure prc_update_appointment_time(cancl_app_id int, p_new_start_time timestamp, p_new_end_time timestamp)
language plpgsql
as $$
declare
    v_original_start_time timestamp;
begin
    -- Get the original start time and lock the row
    select sta_dat_app into v_original_start_time from appointment where id_app = cancl_app_id for update;

    if not found then
        raise exception 'Consulta com ID % não encontrada.', cancl_app_id;
    end if;

    -- Check if the update is being made within the allowed window
    if v_original_start_time <= (now() + interval '24 hours') then
        raise exception 'A consulta só pode ser reagendada com mais de 24 horas de antecedência.';
    end if;

    -- Perform the update (this will trigger other checks like overlapping appointments)
    update appointment set sta_dat_app = p_new_start_time, end_dat_app = p_new_end_time where id_app = cancl_app_id;
end;
$$;
