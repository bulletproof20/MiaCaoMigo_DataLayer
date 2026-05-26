-- =========================================================
-- SERVICES — CORE (fn_* normalization — text / names)
-- FILE: Services/00_Core/00_Normalization_Text.sql
-- =========================================================
--
-- PURPOSE
-- Immutable text/name normalization helpers shared across Modules 1–4.
--
-- DEPENDENCIES
--   - None (core tier; loaded before Module 1 workflows)
--
-- LOADED BY
--   - Bootstrap/Loaders/06_Services.sql
-- =========================================================

drop function if exists fn_normalize_text(text);
drop function if exists fn_normalize_name(text);

create function fn_normalize_text(p_text text)
returns text
language sql
immutable
parallel safe
as $$
    select trim(p_text);
$$;

create function fn_normalize_name(p_name text)
returns text
language sql
immutable
returns null on null input
as $$
    select initcap(
        regexp_replace(
            trim(p_name),
            '\s+',
            ' ',
            'g'
        )
    );
$$;
