-- =========================================================
-- SERVICES — CORE (fn_* normalization — identity fields)
-- FILE: 01_Normalization_Identity.sql
-- =========================================================

drop function if exists fn_normalize_email(varchar);
drop function if exists fn_normalize_nif(varchar);
drop function if exists fn_normalize_phone_nullable(varchar);
drop function if exists fn_normalize_postal_code_pt(varchar);

create function fn_normalize_email(p_email varchar)
returns varchar
language sql
immutable
parallel safe
as $$
    select lower(trim(p_email));
$$;

create function fn_normalize_nif(p_nif varchar)
returns varchar
language sql
immutable
parallel safe
as $$
    select regexp_replace(trim(p_nif), '\s', '', 'g');
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
