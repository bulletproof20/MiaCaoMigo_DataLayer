-- =========================================================
-- SERVICES — CORE NORMALIZATION (IDENTITY)
-- FILE: 01_Normalization_Identity.sql
-- =========================================================
--
-- Email, NIF, phone, postal code, secrets, professional IDs.
-- Aligns with ck_ema_usr_format, ck_nif_usr_format, ck_pho_*_format,
-- ck_pos_usr_format (validation remains in schema / validation services).
-- =========================================================

drop function if exists normalize_email(varchar);
drop function if exists normalize_email_nullable(varchar);
drop function if exists normalize_nif(varchar);
drop function if exists normalize_nif_nullable(varchar);
drop function if exists normalize_digits_only(varchar);
drop function if exists normalize_digits_only_nullable(varchar);
drop function if exists normalize_phone(varchar);
drop function if exists normalize_phone_nullable(varchar);
drop function if exists normalize_postal_code_pt(varchar);
drop function if exists normalize_postal_code_pt_nullable(varchar);
drop function if exists normalize_secret(varchar);
drop function if exists normalize_omv_number(varchar);
drop function if exists normalize_omv_number_nullable(varchar);

-- ---------------------------------------------------------
-- normalize_email — required channel (login, storage)
-- ---------------------------------------------------------
create function normalize_email(p_email varchar)
returns varchar
language sql
immutable
parallel safe
as $$
    select lower(trim(p_email));
$$;

-- ---------------------------------------------------------
-- normalize_email_nullable — optional external / future writers
-- ---------------------------------------------------------
create function normalize_email_nullable(p_email varchar)
returns varchar
language sql
immutable
parallel safe
as $$
    select nullif(lower(trim(p_email)), '');
$$;

-- ---------------------------------------------------------
-- normalize_nif — trim + remove whitespace (not length validation)
-- ---------------------------------------------------------
create function normalize_nif(p_nif varchar)
returns varchar
language sql
immutable
parallel safe
as $$
    select regexp_replace(trim(p_nif), '\s', '', 'g');
$$;

create function normalize_nif_nullable(p_nif varchar)
returns varchar
language sql
immutable
parallel safe
as $$
    select nullif(regexp_replace(trim(p_nif), '\s', '', 'g'), '');
$$;

-- ---------------------------------------------------------
-- normalize_digits_only — strip non-digits
-- ---------------------------------------------------------
create function normalize_digits_only(p_value varchar)
returns varchar
language sql
immutable
parallel safe
as $$
    select regexp_replace(trim(p_value), '[^0-9]', '', 'g');
$$;

create function normalize_digits_only_nullable(p_value varchar)
returns varchar
language sql
immutable
parallel safe
as $$
    select nullif(regexp_replace(trim(p_value), '[^0-9]', '', 'g'), '');
$$;

-- ---------------------------------------------------------
-- normalize_phone — E.164-oriented cleanup (no country prefix injection)
-- ---------------------------------------------------------
create function normalize_phone(p_phone varchar)
returns varchar
language sql
immutable
parallel safe
as $$
    select regexp_replace(trim(p_phone), '[\s\-().]', '', 'g');
$$;

create function normalize_phone_nullable(p_phone varchar)
returns varchar
language sql
immutable
parallel safe
as $$
    select nullif(regexp_replace(trim(p_phone), '[\s\-().]', '', 'g'), '');
$$;

-- ---------------------------------------------------------
-- normalize_postal_code_pt — trim + normalize dash spacing
-- ---------------------------------------------------------
create function normalize_postal_code_pt(p_postal_code varchar)
returns varchar
language sql
immutable
parallel safe
as $$
    select regexp_replace(trim(p_postal_code), '\s*-\s*', '-', 'g');
$$;

create function normalize_postal_code_pt_nullable(p_postal_code varchar)
returns varchar
language sql
immutable
parallel safe
as $$
    select nullif(
        regexp_replace(trim(p_postal_code), '\s*-\s*', '-', 'g'),
        ''
    );
$$;

-- ---------------------------------------------------------
-- normalize_secret — password hashes (trim only, never lower)
-- ---------------------------------------------------------
create function normalize_secret(p_secret varchar)
returns varchar
language sql
immutable
parallel safe
as $$
    select trim(p_secret);
$$;

-- ---------------------------------------------------------
-- normalize_omv_number — veterinarian registration identifier
-- ---------------------------------------------------------
create function normalize_omv_number(p_omv varchar)
returns varchar
language sql
immutable
parallel safe
as $$
    select trim(p_omv);
$$;

create function normalize_omv_number_nullable(p_omv varchar)
returns varchar
language sql
immutable
parallel safe
as $$
    select nullif(trim(p_omv), '');
$$;
