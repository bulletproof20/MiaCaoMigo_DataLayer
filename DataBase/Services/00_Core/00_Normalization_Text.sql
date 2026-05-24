-- =========================================================
-- SERVICES — CORE (fn_* normalization — text / names)
-- FILE: 00_Normalization_Text.sql
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
