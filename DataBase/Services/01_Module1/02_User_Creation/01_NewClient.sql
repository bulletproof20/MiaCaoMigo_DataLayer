-- =========================================================
-- NEW CLIENT (MODULE 1 — USER CREATION)
-- FILE: Services/01_Module1/02_User_Creation/01_NewClient.sql
-- =========================================================
--
-- PURPOSE
-- Create a client account, optionally reusing an existing user_account
-- identity when NIF/email already exist.
--
-- DEPENDENCIES
--   - Services/01_Module1/02_User_Creation/00_UserCreation.sql (fn_create_user_account)
--   - Services/01_Module1/00_Core_Mod1/01_Identity.sql (fn_get_user_by_nif, fn_get_user_by_email, fn_client_exists)
--   - Services/01_Module1/00_Core_Mod1/02_Validations.sql (validate_password)
--   - Services/00_Core/00_Normalization.sql (normalize_email)
--   - Schema/01_Module1_User_Management/00_Tables_Mod1.sql (client)
--
-- LOADED BY
--   - Bootstrap/Loaders/06_Services.sql
-- =========================================================

drop function if exists fn_create_client(
    varchar, text, varchar, varchar, varchar, varchar,
    varchar, varchar
);

-- ---------------------------------------------------------
-- FUNCTION: fn_create_client
-- ---------------------------------------------------------
-- INTENT:
--   Register a client linked to a shared or new user identity.
-- FLOW:
--   1. Normalize NIF/email; resolve identity by NIF and email.
--   2. Reject conflicting identities and duplicate client rows.
--   3. Validate password when reusing an existing identity.
--   4. Create user_account when needed, then INSERT client.
-- EXPECTED RESULT:
--   id_cli of the newly created client row.
-- ---------------------------------------------------------

create or replace function fn_create_client(
    p_nam_usr varchar,
    p_add_usr text,
    p_pos_usr varchar,
    p_nif_usr varchar,
    p_pho_usr varchar,
    p_ema_usr varchar,
    p_pas_cli varchar,
    p_existing_password varchar default null
)
returns int
language plpgsql
as $$

declare
    v_id_usr int;
    v_id_cli int;
    v_id_usr_by_nif int;
    v_id_usr_by_email int;

begin

    p_nif_usr := trim(p_nif_usr);
    p_ema_usr := normalize_email(p_ema_usr);

    v_id_usr_by_nif := fn_get_user_by_nif(p_nif_usr);
    v_id_usr_by_email := fn_get_user_by_email(p_ema_usr);

    if v_id_usr_by_nif is distinct from v_id_usr_by_email then
        raise exception using
            message = 'NIF and email belong to different identities.';
    end if;

    v_id_usr := v_id_usr_by_nif;

    if v_id_usr is not null and fn_client_exists(v_id_usr) then
        raise exception using
            message = 'User already has a client account.';
    end if;

    if v_id_usr is not null
    and not validate_password(p_ema_usr, p_existing_password) then
        raise exception using
            message = 'Identity ownership validation failed.';
    end if;

    if v_id_usr is null then
        v_id_usr := fn_create_user_account(
            p_nam_usr,
            p_add_usr,
            p_pos_usr,
            p_nif_usr,
            p_pho_usr,
            p_ema_usr
        );
    end if;

    insert into client (id_usr, pas_cli)
    values (v_id_usr, trim(p_pas_cli))
    returning id_cli
    into v_id_cli;

    return v_id_cli;

exception
    when check_violation then
        raise exception using
            message = 'Client data validation failed.',
            detail = sqlerrm,
            errcode = sqlstate;
    when foreign_key_violation then
        raise exception using
            message = 'Invalid user association.',
            detail = sqlerrm,
            errcode = sqlstate;
    when unique_violation then
        raise exception using
            message = 'Client account already exists.',
            detail = sqlerrm,
            errcode = sqlstate;
    when others then
        raise exception using
            message = 'Unexpected error while creating client account.',
            detail = sqlerrm,
            errcode = sqlstate;
end;

$$;
