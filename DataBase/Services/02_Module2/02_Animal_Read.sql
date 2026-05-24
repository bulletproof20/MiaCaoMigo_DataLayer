-- =========================================================
-- MODULE 2 — ANIMAL READ (svc_* public API)
-- FILE: 02_Animal_Read.sql
-- =========================================================
--
-- Public read facades over Schema views. No duplicated joins.
-- Legacy fn_* aliases at file bottom (deprecated).
-- =========================================================

drop function if exists svc_list_internal_animals_available();
drop function if exists svc_get_active_ownership_by_animal(int);
drop function if exists svc_get_animal_catalog_entry(int);

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

-- deprecated aliases (Phase 1)
drop function if exists fn_list_internal_animals_available();
create function fn_list_internal_animals_available()
returns setof vw_internal_animals_available
language sql stable parallel safe as $$
    select * from svc_list_internal_animals_available();
$$;

drop function if exists fn_get_active_ownership_by_animal(int);
create function fn_get_active_ownership_by_animal(p_id_ani int)
returns setof vw_active_ownership_detail
language sql stable parallel safe as $$
    select * from svc_get_active_ownership_by_animal(p_id_ani);
$$;

drop function if exists fn_get_animal_catalog_entry(int);
create function fn_get_animal_catalog_entry(p_id_ani int)
returns vw_animal_catalog_detail
language sql stable parallel safe as $$
    select svc_get_animal_catalog_entry(p_id_ani);
$$;
