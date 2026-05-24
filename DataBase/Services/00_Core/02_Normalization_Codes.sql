-- =========================================================
-- SERVICES — CORE (fn_* normalization — codes)
-- FILE: 02_Normalization_Codes.sql
-- =========================================================

drop function if exists fn_normalize_code(varchar);
drop function if exists fn_normalize_code_nullable(varchar);
drop function if exists fn_normalize_reference(varchar);
drop function if exists fn_normalize_reference_nullable(varchar);

create function fn_normalize_code(p_code varchar)
returns varchar
language sql
immutable
parallel safe
as $$
    select upper(trim(p_code));
$$;

create function fn_normalize_code_nullable(p_code varchar)
returns varchar
language sql
immutable
parallel safe
as $$
    select nullif(upper(trim(p_code)), '');
$$;

create function fn_normalize_reference(p_reference varchar)
returns varchar
language sql
immutable
parallel safe
as $$
    select trim(p_reference);
$$;

create function fn_normalize_reference_nullable(p_reference varchar)
returns varchar
language sql
immutable
parallel safe
as $$
    select nullif(trim(p_reference), '');
$$;
