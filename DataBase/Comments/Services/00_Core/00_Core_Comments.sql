-- =========================================================
-- comments: services — core (fn_normalize_*)
-- =========================================================

comment on function fn_normalize_text(text) is
'Internal helper: trim text fields (passwords, OMV, job function, address lines).';

comment on function fn_normalize_name(text) is
'Internal helper: trim, collapse whitespace, and initcap person names.';

comment on function fn_normalize_email(varchar) is
'Internal helper: lower(trim) for email channel consistency.';

comment on function fn_normalize_nif(varchar) is
'Internal helper: trim and remove whitespace from NIF input.';

comment on function fn_normalize_phone_nullable(varchar) is
'Internal helper: nullable phone cleanup (spaces, dashes, parentheses).';

comment on function fn_normalize_postal_code_pt(varchar) is
'Internal helper: trim and normalize dash spacing for Portuguese postal codes.';

