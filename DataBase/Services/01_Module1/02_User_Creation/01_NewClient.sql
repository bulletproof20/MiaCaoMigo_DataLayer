-- =========================================================
-- NEW CLIENT (MODULE 1 — USER CREATION)
-- BUSINESS WORKFLOW: sp_create_client
-- =========================================================

drop procedure if exists sp_create_client(
    varchar, text, varchar, varchar, varchar, varchar, varchar, varchar, out int
);

create or replace procedure sp_create_client(
    p_nam_usr varchar,
    p_add_usr text,
    p_pos_usr varchar,
    p_nif_usr varchar,
    p_pho_usr varchar,
    p_ema_usr varchar,
    p_pas_cli varchar,
    p_existing_password varchar,
    out p_id_cli int
)
language plpgsql
as $$
declare
    v_id_usr int;
    v_id_usr_by_nif int;
    v_id_usr_by_email int;
begin

    p_nif_usr := fn_normalize_nif(p_nif_usr);
    p_ema_usr := fn_normalize_email(p_ema_usr);

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
    and not fn_validate_password(p_ema_usr, p_existing_password) then
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
    values (v_id_usr, fn_normalize_text(p_pas_cli))
    returning id_cli
    into p_id_cli;

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
