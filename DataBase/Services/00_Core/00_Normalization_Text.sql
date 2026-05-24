-- =========================================================
-- SERVICES — CORE (fn_* normalization — text)
-- FILE: 00_Normalization_Text.sql
-- =========================================================
--
-- Internal helpers only. Public API must not reimplement trim/lower rules.
-- Official naming: fn_normalize_* (no legacy aliases).
-- =========================================================

drop function if exists fn_normalize_text(text);
drop function if exists fn_normalize_text_nullable(text);
drop function if exists fn_normalize_text_lower(varchar);
drop function if exists fn_normalize_text_lower_nullable(varchar);

create function fn_normalize_text(p_text text)
returns text
language sql
immutable
parallel safe
as $$
    select trim(p_text);
$$;

create function fn_normalize_text_nullable(p_text text)
returns text
language sql
immutable
parallel safe
as $$
    select nullif(trim(p_text), '');
$$;

create function fn_normalize_text_lower(p_text varchar)
returns varchar
language sql
immutable
parallel safe
as $$
    select lower(trim(p_text));
$$;

create function fn_normalize_text_lower_nullable(p_text varchar)
returns varchar
language sql
immutable
parallel safe
as $$
    select nullif(lower(trim(p_text)), '');
$$;
