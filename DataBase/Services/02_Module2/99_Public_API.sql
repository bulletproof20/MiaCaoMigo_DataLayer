-- =========================================================
-- MODULE 2 — PUBLIC API (svc_*)
-- FILE: Services/02_Module2/99_Public_API.sql
-- =========================================================
--
-- Sole Services layer for Module 2: public entry points only.
-- Workflows live in Schema (sp_assign_ownership, sp_record_delivery).
-- =========================================================

drop function if exists svc_register_adoption(int, int, int, varchar);
drop function if exists svc_register_delivery(int, int, varchar, varchar, int[]);
drop function if exists svc_animal_exit(int, varchar);
drop function if exists svc_get_animal_history(int);
drop function if exists svc_list_internal_animals_available();
drop function if exists svc_get_active_ownership_by_animal(int);
drop function if exists svc_get_animal_catalog_entry(int);

-- --- lifecycle (sp_* delegation + controlled DML) ---

create function svc_register_adoption(
    p_id_cli int,
    p_id_ani int,
    p_id_emp int,
    p_mot_own varchar
)
returns void
language plpgsql
as $$
begin
    call sp_assign_ownership(p_id_ani, p_id_cli, p_id_emp, p_mot_own);
end;
$$;

create function svc_register_delivery(
    p_id_ani int,
    p_id_ext_ent int,
    p_location varchar,
    p_status_clinic varchar,
    p_emp_ids int[]
)
returns void
language plpgsql
as $$
begin
    call sp_record_delivery(
        p_id_ani,
        current_timestamp,
        p_location,
        p_status_clinic,
        p_id_ext_ent,
        p_emp_ids
    );
end;
$$;

create function svc_animal_exit(
    p_id_ani int,
    p_sta_ani varchar
)
returns void
language plpgsql
as $$
begin
    update animal
    set sta_ani = p_sta_ani
    where id_ani = p_id_ani;

    update ownership
    set end_dat_own = current_date
    where id_ani = p_id_ani
      and end_dat_own is null;

exception
    when others then
        raise exception using
            message = format('svc_animal_exit failed for animal %s', p_id_ani),
            detail = sqlerrm,
            errcode = sqlstate;
end;
$$;

create function svc_get_animal_history(p_id_ani int)
returns table(event_date date, description text)
language sql
stable
parallel safe
as $$
    select o.sta_dat_own, 'Adopted by client id: ' || o.id_cli::text
    from ownership o
    where o.id_ani = p_id_ani
    union all
    select c.dat_con, 'Conceded to entity id: ' || c.id_ext_ent::text
    from concession c
    where c.id_ani = p_id_ani
    order by 1 desc;
$$;

-- --- read (vw_* facades) ---

create function svc_list_internal_animals_available()
returns setof vw_internal_animals_available
language sql
stable
parallel safe
as $$
    select *
    from vw_internal_animals_available
    order by reg_dat_ani desc;
$$;

create function svc_get_active_ownership_by_animal(p_id_ani int)
returns setof vw_active_ownership_detail
language sql
stable
parallel safe
as $$
    select *
    from vw_active_ownership_detail
    where id_ani = p_id_ani;
$$;

create function svc_get_animal_catalog_entry(p_id_ani int)
returns vw_animal_catalog_detail
language sql
stable
parallel safe
as $$
    select *
    from vw_animal_catalog_detail
    where id_ani = p_id_ani;
$$;
