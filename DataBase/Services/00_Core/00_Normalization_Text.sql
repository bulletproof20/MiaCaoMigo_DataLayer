-- =========================================================
-- SERVICES — CORE NORMALIZATION (TEXT)
-- FILE: 00_Normalization_Text.sql
-- =========================================================
--
-- Deterministic text cleanup only (no validation rules).
-- Mirrors trim / lower(trim) expectations in schema CHECK clauses.
-- =========================================================

drop function if exists normalize_text(text);
drop function if exists normalize_text_nullable(text);
drop function if exists normalize_text_lower(varchar);
drop function if exists normalize_text_lower_nullable(varchar);

-- ---------------------------------------------------------
-- normalize_text — required trim
-- ---------------------------------------------------------
create function normalize_text(p_text text)
returns text
language sql
immutable
parallel safe
as $$
    select trim(p_text);
$$;

-- ---------------------------------------------------------
-- normalize_text_nullable — blank → NULL
-- ---------------------------------------------------------
create function normalize_text_nullable(p_text text)
returns text
language sql
immutable
parallel safe
as $$
    select nullif(trim(p_text), '');
$$;

-- ---------------------------------------------------------
-- normalize_text_lower — matches profile/permission/specialty storage
-- ---------------------------------------------------------
create function normalize_text_lower(p_text varchar)
returns varchar
language sql
immutable
parallel safe
as $$
    select lower(trim(p_text));
$$;

-- ---------------------------------------------------------
-- normalize_text_lower_nullable
-- ---------------------------------------------------------
create function normalize_text_lower_nullable(p_text varchar)
returns varchar
language sql
immutable
parallel safe
as $$
    select nullif(lower(trim(p_text)), '');
$$;
