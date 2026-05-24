-- =========================================================
-- MODULE 2 — ANIMAL LIFECYCLE (svc_* public API)
-- FILE: 01_Animal_Lifecycle.sql
-- =========================================================
--
-- Orchestrates Schema procedures (sp_*) or controlled DML.
-- Legacy fn_* aliases at file bottom (deprecated).
-- =========================================================

drop function if exists svc_register_adoption(int, int, int, varchar);
drop function if exists svc_register_delivery(int, int, varchar, varchar, int[]);
drop function if exists svc_animal_exit(int, varchar);
drop function if exists svc_get_animal_history(int);

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

-- deprecated aliases (Phase 1)
drop function if exists fn_register_adoption(int, int, int, varchar);
create function fn_register_adoption(int, int, int, varchar)
returns void language plpgsql as $$
begin perform svc_register_adoption($1, $2, $3, $4); end; $$;

drop function if exists fn_register_delivery_team(int, int, varchar, varchar, int[]);
create function fn_register_delivery_team(int, int, varchar, varchar, int[])
returns void language plpgsql as $$
begin perform svc_register_delivery($1, $2, $3, $4, $5); end; $$;

drop function if exists fn_animal_exit(int, varchar);
create function fn_animal_exit(int, varchar)
returns void language plpgsql as $$
begin perform svc_animal_exit($1, $2); end; $$;

drop function if exists fn_get_animal_history(int);
create function fn_get_animal_history(p_id_ani int)
returns table(event_date date, description text)
language sql stable parallel safe as $$
    select * from svc_get_animal_history(p_id_ani);
$$;
