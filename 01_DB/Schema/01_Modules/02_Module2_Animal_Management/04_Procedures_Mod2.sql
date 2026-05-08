--=========================================================
-- PROCEDURES - MODULE 2 (ANIMAL MANAGEMENT)
--=========================================================
-- Purpose:
-- Provides stored procedures for common business operations
-- related to animal management, simplifying data manipulation
-- and enforcing business logic.
--=========================================================

--=========================================================
-- PROCEDURE 1: prc_register_animal
-- Registers a new animal in the system.
--=========================================================
create or replace procedure prc_register_animal(
    p_reg_id_ani varchar,
    p_nam_ani varchar,
    p_dat_bir_ani date,
    p_gen_ani char,
    p_ori_ani varchar,
    p_sta_ani varchar,
    p_id_spc int,
    p_id_bre int default null
)
language plpgsql
as $$
begin
    insert into animal (
        reg_id_ani,
        nam_ani,
        dat_bir_ani,
        gen_ani,
        ori_ani,
        sta_ani,
        id_spc,
        id_bre
    ) values (
        p_reg_id_ani,
        p_nam_ani,
        p_dat_bir_ani,
        p_gen_ani,
        p_ori_ani,
        p_sta_ani,
        p_id_spc,
        p_id_bre
    );
end;
$$;

--=========================================================
-- PROCEDURE 2: prc_assign_ownership
-- Assigns an animal to a client, creating an ownership record
-- and updating the animal's status to 'Adotado'.
--=========================================================
create or replace procedure prc_assign_ownership(
    p_id_ani int,
    p_id_cli int,
    p_id_emp int,
    p_mot_own varchar
)
language plpgsql
as $$
declare
    v_animal_status varchar;
begin
    -- 1. Check if the animal is available for adoption
    select sta_ani into v_animal_status
    from animal
    where id_ani = p_id_ani;

    if v_animal_status is null then
        raise exception 'Animal com ID % não encontrado.', p_id_ani;
    end if;

    if v_animal_status <> 'Interno' then
        raise exception 'Animal com ID % não está disponível para adoção (Status: %).', p_id_ani, v_animal_status;
    end if;

    -- 2. Create the new ownership record
    insert into ownership (
        id_cli,
        id_ani,
        id_emp,
        sta_dat_own,
        mot_own
    ) values (
        p_id_cli,
        p_id_ani,
        p_id_emp,
        current_date,
        p_mot_own
    );

    -- 3. Update the animal's status to 'Adotado'
    update animal
    set sta_ani = 'Adotado'
    where id_ani = p_id_ani;

end;
$$;

--=========================================================
-- PROCEDURE 3: prc_end_ownership
-- Ends an active ownership for an animal, setting the end date
-- and changing the animal's status back to 'Interno'.
--=========================================================
create or replace procedure prc_end_ownership(
    p_id_ani int,
    p_reason varchar
)
language plpgsql
as $$
declare
    v_ownership_id int;
begin
    -- 1. Find the active ownership record for the animal
    select id_own into v_ownership_id
    from ownership
    where id_ani = p_id_ani and end_dat_own is null;

    if v_ownership_id is null then
        raise exception 'Nenhuma posse ativa encontrada para o animal com ID %.', p_id_ani;
    end if;

    -- 2. Update the ownership record with an end date and reason
    update ownership
    set 
        end_dat_own = current_date,
        mot_own = p_reason
    where id_own = v_ownership_id;

    -- 3. Update the animal's status back to 'Interno' (available)
    update animal
    set sta_ani = 'Interno'
    where id_ani = p_id_ani;

end;
$$;

--=========================================================
-- PROCEDURE 4: prc_search_available_animals
-- Searches for animals that are available for adoption ('Interno')
-- and returns them in a temporary table.
--=========================================================
create or replace procedure prc_search_available_animals()
language plpgsql
as $$
begin
    -- Create a temporary table to hold the results
    create temp table if not exists temp_available_animals (
        id_ani int,
        nome_animal varchar,
        especie varchar,
        raca varchar,
        idade interval,
        genero char
    );

    -- Clear previous results
    truncate table temp_available_animals;

    -- Insert available animals into the temp table
    insert into temp_available_animals (id_ani, nome_animal, especie, raca, idade, genero)
    select
        a.id_ani,
        a.nam_ani,
        s.nam_spc,
        b.nam_bre,
        age(current_date, a.dat_bir_ani),
        a.gen_ani
    from animal a
    join species s on a.id_spc = s.id_spc
    left join breed b on a.id_bre = b.id_bre
    where a.sta_ani = 'Interno';

end;
$$;

-- Example of how to use the search procedure:
--
-- CALL prc_search_available_animals();
-- SELECT * FROM temp_available_animals;