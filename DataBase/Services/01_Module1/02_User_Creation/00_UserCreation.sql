-- =========================================================
-- USER CREATION — COMMON (MODULE 1)
-- FILE: Services/01_Module1/02_User_Creation/00_UserCreation.sql
-- =========================================================
--
-- PURPOSE
-- Shared helpers for creating user_account rows and assigning
-- employee profiles used by client/employee creation flows.
--
-- DEPENDENCIES
--   - Services/00_Core/00_Normalization_Text.sql
--   - Services/00_Core/01_Normalization_Identity.sql
--   - Schema/01_Module1_User_Management/02_Functions_Mod1.sql (fn_create_default_setup trigger)
--   - Schema/01_Module1_User_Management/00_Tables_Mod1.sql (user_account, occupies)
--
-- LOADED BY
--   - Bootstrap/Loaders/06_Services.sql (before 01_NewClient.sql … 04_NewVeterinarian.sql)
-- =========================================================

drop function if exists fn_create_user_account(
    varchar, text, varchar, varchar, varchar, varchar
);

-- ---------------------------------------------------------
-- FUNCTION: fn_create_user_account
-- ---------------------------------------------------------
-- INTENT:
--   Insert a new shared user_account identity row.
-- FLOW:
--   1. Normalize input fields via 00_Core helpers.
--   2. INSERT into user_account; setup row is created by trigger.
-- EXPECTED RESULT:
--   id_usr of the newly created user.
-- ---------------------------------------------------------

create or replace function fn_create_user_account(
    p_nam_usr varchar,
    p_add_usr text,
    p_pos_usr varchar,
    p_nif_usr varchar,
    p_pho_usr varchar,
    p_ema_usr varchar
)
returns int
language plpgsql
as $$

declare
    v_id_usr int;

begin

    p_nam_usr := normalize_text(p_nam_usr);
    p_add_usr := normalize_text(p_add_usr);
    p_pos_usr := normalize_postal_code_pt(p_pos_usr);
    p_nif_usr := normalize_nif(p_nif_usr);
    p_pho_usr := normalize_phone_nullable(p_pho_usr);
    p_ema_usr := normalize_email(p_ema_usr);

    insert into user_account (
        nam_usr,
        add_usr,
        pos_usr,
        nif_usr,
        pho_usr,
        ema_usr
    )
    values (
        p_nam_usr,
        p_add_usr,
        p_pos_usr,
        p_nif_usr,
        p_pho_usr,
        p_ema_usr
    )
    returning id_usr
    into v_id_usr;

    return v_id_usr;

exception
    when unique_violation then
        raise exception using
            message = 'User already exists.',
            detail = sqlerrm,
            errcode = sqlstate;
    when check_violation then
        raise exception using
            message = 'User data validation failed.',
            detail = sqlerrm,
            errcode = sqlstate;
    when invalid_text_representation then
        raise exception using
            message = 'Invalid textual value provided.',
            detail = sqlerrm,
            errcode = sqlstate;
    when others then
        raise exception using
            message = 'Unexpected error while creating user account.',
            detail = sqlerrm,
            errcode = sqlstate;
end;

$$;


drop function if exists fn_assign_profile(int, int);

-- ---------------------------------------------------------
-- FUNCTION: fn_assign_profile
-- ---------------------------------------------------------
-- INTENT:
--   Link an employee to an RBAC profile through occupies.
-- FLOW:
--   1. INSERT (id_emp, id_pro) into occupies.
-- EXPECTED RESULT:
--   void; profile association persisted or constraint error raised.
-- ---------------------------------------------------------

create or replace function fn_assign_profile(
    p_id_emp int,
    p_id_pro int
)
returns void
language plpgsql
as $$

begin

    insert into occupies (id_emp, id_pro)
    values (p_id_emp, p_id_pro);

exception
    when unique_violation then
        raise exception using
            message = 'Profile already assigned to employee.',
            detail = sqlerrm,
            errcode = sqlstate;
    when foreign_key_violation then
        raise exception using
            message = 'Invalid employee or profile reference.',
            detail = sqlerrm,
            errcode = sqlstate;
    when others then
        raise exception using
            message = 'Unexpected error while assigning profile.',
            detail = sqlerrm,
            errcode = sqlstate;
end;

$$;
