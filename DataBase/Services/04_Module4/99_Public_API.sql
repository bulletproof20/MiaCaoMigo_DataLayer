-- =========================================================
-- MODULE 4 — PUBLIC API (svc_*)
-- FILE: Services/04_Module4/99_Public_API.sql
-- =========================================================
--
-- Sole Services layer for Module 4: public read entry points.
-- Operational boards use Schema views; filtered lists add API parameters.
-- =========================================================

drop function if exists svc_list_vet_appointments_from(int, date);
drop function if exists svc_list_animal_appointment_history(int);

create function svc_list_vet_appointments_from(
    p_id_emp int,
    p_from_date date default current_date
)
returns setof vw_appointment_detail
language sql
stable
parallel safe
as $$
    select *
    from vw_appointment_detail d
    where d.id_emp = p_id_emp
      and d.sch_dat_app::date >= p_from_date
      and d.status_app = 'scheduled'
    order by d.sch_dat_app;
$$;

create function svc_list_animal_appointment_history(p_id_ani int)
returns setof vw_appointment_detail
language sql
stable
parallel safe
as $$
    select *
    from vw_appointment_detail d
    where d.id_ani = p_id_ani
    order by d.sch_dat_app desc;
$$;
