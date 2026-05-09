--=========================================================
-- REPORTING & ANALYTICS — APPOINTMENTS (cross-module)
--=========================================================
-- Depends on: appointment (Mod 4), specialty (Mod 1), client,
-- employee, user_account, animal. Loaded after comments layer.
--=========================================================

create or replace view v_appointment_operational_detail as
select
    a.id_app,
    a.sch_dat_app,
    a.sta_dat_app,
    a.end_dat_app,
    a.status_app,
    a.dia_app,
    a.com_app,
    a.id_cli,
    a.id_animal,
    a.id_emp,
    a.id_spe,
    sp.nam_spe as specialty_name,
    sp.des_spe as specialty_description,
    uc_cli.nam_usr as client_display_name,
    ua_vet.nam_usr as veterinarian_display_name,
    an.nam_ani as animal_name
from appointment a
join specialty sp on a.id_spe = sp.id_spe
join client c on a.id_cli = c.id_cli
join user_account uc_cli on c.id_usr = uc_cli.id_usr
join employee e on a.id_emp = e.id_emp
join user_account ua_vet on e.id_usr = ua_vet.id_usr
join animal an on a.id_animal = an.id_ani;

comment on view v_appointment_operational_detail is
'appointment header enriched with specialty catalog, client/vet display names, and animal label for dashboards';


create or replace view v_specialty_workload_month as
select
    date_trunc('month', a.sch_dat_app) as month_bucket,
    a.id_spe,
    sp.nam_spe,
    count(*) filter (where a.status_app in ('Scheduled', 'In Progress')) as open_or_active_count,
    count(*) filter (where a.status_app = 'Completed') as completed_count,
    count(*) as total_count
from appointment a
join specialty sp on a.id_spe = sp.id_spe
group by 1, 2, 3
order by 1 desc, 3;

comment on view v_specialty_workload_month is
'monthly aggregates by consultation specialty for capacity and analytics';
