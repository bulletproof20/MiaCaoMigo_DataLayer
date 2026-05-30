-- =========================================================
-- NARRATIVE DEMO — 99 FINAL VALIDATION
-- Story coverage assertions for launch simulation
-- =========================================================

set timezone to 'Europe/Lisbon';

do $validate$
declare
    v_cnt int;
begin
    -- Cast present
    if not exists (select 1 from employee where id_emp = 2 and dea_dat_emp is null) then
        raise exception 'VALIDATION: Ivo Sá (id_emp=2) missing';
    end if;
    if not exists (select 1 from occupies where id_emp = 3 and id_pro = 3) then
        raise exception 'VALIDATION: Tiago assistente profile missing';
    end if;
    if not exists (select 1 from occupies where id_emp = 4 and id_pro = 4) then
        raise exception 'VALIDATION: Navarro gestor comercial profile missing';
    end if;
    if not exists (select 1 from occupies where id_emp = 5 and id_pro = 2) then
        raise exception 'VALIDATION: Marcelo veterinario profile missing';
    end if;
    if not exists (select 1 from occupies where id_emp = 6 and id_pro = 3) then
        raise exception 'VALIDATION: Isabel assistente profile missing';
    end if;

    -- Animal states
    select count(*) into v_cnt from animal where sta_ani = 'Interno';
    if v_cnt < 1 then raise exception 'VALIDATION: expected shelter Interno animals'; end if;
    if not exists (select 1 from animal where nam_ani = 'Max' and sta_ani = 'Transferido') then
        raise exception 'VALIDATION: Max concession state missing';
    end if;
    if not exists (select 1 from animal where nam_ani = 'Bento' and sta_ani = 'Falecido') then
        raise exception 'VALIDATION: Bento Falecido missing';
    end if;

    -- Appointment states
    select count(distinct status_app) into v_cnt from appointment;
    if v_cnt < 4 then
        raise exception 'VALIDATION: insufficient appointment status diversity (got % distinct)', v_cnt;
    end if;
    if not exists (select 1 from appointment where status_app = 'no_show') then
        raise exception 'VALIDATION: Pedro no_show appointment missing';
    end if;
    if not exists (select 1 from appointment where status_app = 'scheduled' and sch_dat_app > '2026-06-08') then
        raise exception 'VALIDATION: future scheduled appointments missing';
    end if;

    -- Commercial
    if not exists (select 1 from invoice where sta_inv = 'overdue') then
        raise exception 'VALIDATION: Marta overdue invoice missing';
    end if;
    if not exists (select 1 from "return") then
        raise exception 'VALIDATION: Marta return missing';
    end if;

    -- HR
    if not exists (select 1 from absence where sta_abs = 'detected') then
        raise exception 'VALIDATION: detected absences missing';
    end if;
    if not exists (select 1 from absence where sta_abs = 'pending') then
        raise exception 'VALIDATION: pending absences missing';
    end if;

    -- Notifications
    if not exists (select 1 from appointment_notification) then
        raise exception 'VALIDATION: appointment_notification rows missing';
    end if;

    -- Inactive personas
    if not exists (select 1 from employee where id_emp = 7 and dea_dat_emp is not null) then
        raise exception 'VALIDATION: Bernardo inactive employee missing';
    end if;
    if not exists (select 1 from client where id_cli = 4 and ina_dat_cli is not null) then
        raise exception 'VALIDATION: Pedro inactive client missing';
    end if;

    raise notice 'PASS: narrative demo validation completed — launch simulation coherent';
end;
$validate$;
