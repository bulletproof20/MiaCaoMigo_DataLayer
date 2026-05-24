-- =========================================================
-- SERVICES — CORE (fn_* normalization — identity)
-- FILE: 01_Normalization_Identity.sql
-- =========================================================

drop function if exists fn_normalize_email(varchar);
drop function if exists fn_normalize_email_nullable(varchar);
drop function if exists fn_normalize_nif(varchar);
drop function if exists fn_normalize_nif_nullable(varchar);
drop function if exists fn_normalize_digits_only(varchar);
drop function if exists fn_normalize_digits_only_nullable(varchar);
drop function if exists fn_normalize_phone(varchar);
drop function if exists fn_normalize_phone_nullable(varchar);
drop function if exists fn_normalize_postal_code_pt(varchar);
drop function if exists fn_normalize_postal_code_pt_nullable(varchar);
drop function if exists fn_normalize_secret(varchar);
drop function if exists fn_normalize_omv_number(varchar);
drop function if exists fn_normalize_omv_number_nullable(varchar);

create function fn_normalize_email(p_email varchar)
returns varchar
language sql
immutable
parallel safe
as $$
    select lower(trim(p_email));
$$;

create function fn_normalize_email_nullable(p_email varchar)
returns varchar
language sql
immutable
parallel safe
as $$
    select nullif(lower(trim(p_email)), '');
$$;

create function fn_normalize_nif(p_nif varchar)
returns varchar
language sql
immutable
parallel safe
as $$
    select regexp_replace(trim(p_nif), '\s', '', 'g');
$$;

create function fn_normalize_nif_nullable(p_nif varchar)
returns varchar
language sql
immutable
parallel safe
as $$
    select nullif(regexp_replace(trim(p_nif), '\s', '', 'g'), '');
$$;

create function fn_normalize_digits_only(p_value varchar)
returns varchar
language sql
immutable
parallel safe
as $$
    select regexp_replace(trim(p_value), '[^0-9]', '', 'g');
$$;

create function fn_normalize_digits_only_nullable(p_value varchar)
returns varchar
language sql
immutable
parallel safe
as $$
    select nullif(regexp_replace(trim(p_value), '[^0-9]', '', 'g'), '');
$$;

create function fn_normalize_phone(p_phone varchar)
returns varchar
language sql
immutable
parallel safe
as $$
    select regexp_replace(trim(p_phone), '[\s\-().]', '', 'g');
$$;

create function fn_normalize_phone_nullable(p_phone varchar)
returns varchar
language sql
immutable
parallel safe
as $$
    select nullif(regexp_replace(trim(p_phone), '[\s\-().]', '', 'g'), '');
$$;

create function fn_normalize_postal_code_pt(p_postal_code varchar)
returns varchar
language sql
immutable
parallel safe
as $$
    select regexp_replace(trim(p_postal_code), '\s*-\s*', '-', 'g');
$$;

create function fn_normalize_postal_code_pt_nullable(p_postal_code varchar)
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

create function fn_normalize_secret(p_secret varchar)
returns varchar
language sql
immutable
parallel safe
as $$
    select trim(p_secret);
$$;

create function fn_normalize_omv_number(p_omv varchar)
returns varchar
language sql
immutable
parallel safe
as $$
    select trim(p_omv);
$$;

create function fn_normalize_omv_number_nullable(p_omv varchar)
returns varchar
language sql
immutable
parallel safe
as $$
    select nullif(trim(p_omv), '');
$$;
