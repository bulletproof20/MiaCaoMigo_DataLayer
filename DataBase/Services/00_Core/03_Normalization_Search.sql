-- =========================================================
-- SERVICES — CORE NORMALIZATION (SEARCH)
-- FILE: 03_Normalization_Search.sql
-- =========================================================
--
-- Read-side / filter input cleanup (no LIKE escaping here).
-- =========================================================

drop function if exists normalize_search_term(text);

-- ---------------------------------------------------------
-- normalize_search_term — lower(trim) + collapsed whitespace
-- ---------------------------------------------------------
create function normalize_search_term(p_term text)
returns text
language sql
immutable
parallel safe
as $$
    select nullif(regexp_replace(lower(trim(p_term)), '\s+', ' ', 'g'), '');
$$;
