-- =========================================================
-- SERVICES — CORE (fn_* normalization — search)
-- FILE: 03_Normalization_Search.sql
-- =========================================================

drop function if exists fn_normalize_search_term(text);

create function fn_normalize_search_term(p_term text)
returns text
language sql
immutable
parallel safe
as $$
    select nullif(regexp_replace(lower(trim(p_term)), '\s+', ' ', 'g'), '');
$$;
