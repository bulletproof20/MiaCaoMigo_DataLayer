--=========================================================
-- FUNCTIONS - MODULE 2 (ANIMAL MANAGEMENT / ADOPTION)
-- Contains business logic for adoptions and animal flow
--=========================================================

--=========================================================
-- FUNCTION 1: fn_register_adoption
-- Registers a new animal adoption (ownership relation)
-- and validates if the animal is available.
--=========================================================

-- drop function if exists fn_register_adoption(int, int, int, varchar);

create or replace function fn_register_adoption(
    p_id_cli int,
    p_id_ani int,
    p_id_emp int,
    p_motive varchar
) returns trigger
as $$
begin
    -- 1. Check if the animal is already adopted or deceased
    if exists (
        select 1
        from animal
        where id_ani = p_id_ani
          and sta_ani in ('Adotado', 'Falecido')
    ) then
        -- Block adoption if status is not compatible
        raise exception 'Animal with ID % is not available (Status: %).',
            p_id_ani, (select sta_ani from animal where id_ani = p_id_ani);
    end if;

    -- 2. Create the ownership record
    insert into Titularidade (id_cli, id_ani, id_emp, mot_own, sta_dat_own)
    values (p_id_cli, p_id_ani, p_id_emp, p_motive, current_date);

end;
$$ language plpgsql;


--=========================================================
-- FUNCTION 2: fn_register_delivery_team
-- Registers an animal rescue/delivery involving multiple 
-- employees and updates status to 'Interno'.
--=========================================================

drop function if exists fn_register_delivery_team(int, int, varchar, varchar, int[]);

create or replace function fn_register_delivery_team(
    p_id_ani int,
    p_id_ext int,
    p_location varchar,
    p_status_clinic varchar,
    p_emp_ids int[]
) returns void as $$
declare
    v_id_del int;
    v_emp_id int;
begin
    -- 1. Create the delivery record
    insert into delivery (id_ani, id_ext_ent, res_loc_del, cli_sta_del, res_dat_del)
    values (p_id_ani, p_id_ext, p_location, p_status_clinic, current_timestamp)
    returning id_del into v_id_del;

    -- 2. Associate each team member from the array
    foreach v_emp_id in array p_emp_ids loop
        insert into delivery_employee (id_del, id_emp)
        values (v_id_del, v_emp_id);
    end loop;

    -- 3. Update the animal status to internal
    update animal
    set sta_ani = 'Interno'
    where id_ani = p_id_ani;

end;
$$ language plpgsql;


--=========================================================
-- FUNCTION 3: fn_animal_exit
-- Processes a definitive exit of an animal from the clinic
-- and terminates active ownerships.
--=========================================================

drop function if exists fn_animal_exit(int, varchar);

create or replace function fn_animal_exit(
    p_id_ani int,
    p_reason varchar
) returns void as $$
begin
    -- 1. Update animal status (e.g., to 'Falecido' or 'Outro')
    update animal
    set sta_ani = p_reason
    where id_ani = p_id_ani;

    -- 2. Close any ownership record that is still open
    update ownership
    set end_dat_own = current_date
    where id_ani = p_id_ani
      and end_dat_own is null;

end;
$$ language plpgsql;


--=========================================================
-- FUNCTION 4: fn_get_animal_history
-- Retrieves the chronological history of an animal merging
-- ownership and concession records.
--=========================================================

drop function if exists fn_get_animal_history(int);

create or replace function fn_get_animal_history(p_id_ani int)
returns table(event_date date, description text) as $$
begin
    -- 1. Return query merging different history sources
    return query
    select sta_dat_own, 'Adotado por Cliente ID: ' || id_cli::text
    from ownership
    where id_ani = p_id_ani
    
    union all
    
    select dat_con, 'Cedido para Entidade ID: ' || id_ext_ent::text
    from concession
    where id_ani = p_id_ani
    
    order by 1 desc;

end;
$$ language plpgsql;
