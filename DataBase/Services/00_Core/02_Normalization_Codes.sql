-- =========================================================
-- SERVICES — CORE NORMALIZATION (CODES & REFERENCES)
-- FILE: 02_Normalization_Codes.sql
-- =========================================================
--
-- Batch codes, order numbers, animal registration IDs (Modules 2–3).
-- =========================================================

drop function if exists normalize_code(varchar);
drop function if exists normalize_code_nullable(varchar);
drop function if exists normalize_reference(varchar);
drop function if exists normalize_reference_nullable(varchar);

-- ---------------------------------------------------------
-- normalize_code — trim + uppercase (reg_id_ani, bat_*, etc.)
-- ---------------------------------------------------------
create function normalize_code(p_code varchar)
returns varchar
language sql
immutable
parallel safe
as $$
    select upper(trim(p_code));
$$;

create function normalize_code_nullable(p_code varchar)
returns varchar
language sql
immutable
parallel safe
as $$
    select nullif(upper(trim(p_code)), '');
$$;

-- ---------------------------------------------------------
-- normalize_reference — purchase orders, document refs (case preserved)
-- ---------------------------------------------------------
create function normalize_reference(p_reference varchar)
returns varchar
language sql
immutable
parallel safe
as $$
    select trim(p_reference);
$$;

create function normalize_reference_nullable(p_reference varchar)
returns varchar
language sql
immutable
parallel safe
as $$
    select nullif(trim(p_reference), '');
$$;
