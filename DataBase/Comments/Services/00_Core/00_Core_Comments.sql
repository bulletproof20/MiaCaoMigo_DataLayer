-- =========================================================
-- comments: services — core (fn_normalize_*)
-- =========================================================

comment on function fn_normalize_text(text) is
'Internal helper: trim required text fields before persistence or comparison.';

comment on function fn_normalize_text_nullable(text) is
'Internal helper: trim text; blank input becomes NULL.';

comment on function fn_normalize_text_lower(varchar) is
'Internal helper: lower(trim) for profile/permission/specialty-style storage.';

comment on function fn_normalize_text_lower_nullable(varchar) is
'Internal helper: lower(trim); blank input becomes NULL.';

comment on function fn_normalize_email(varchar) is
'Internal helper: lower(trim) for email channel consistency (matches ck_ema_* storage).';

comment on function fn_normalize_email_nullable(varchar) is
'Internal helper: nullable email normalization for optional external contacts.';

comment on function fn_normalize_nif(varchar) is
'Internal helper: trim and remove whitespace from NIF input (not checksum validation).';

comment on function fn_normalize_nif_nullable(varchar) is
'Internal helper: nullable NIF normalization.';

comment on function fn_normalize_digits_only(varchar) is
'Internal helper: strip non-digit characters from numeric identifiers.';

comment on function fn_normalize_digits_only_nullable(varchar) is
'Internal helper: nullable digits-only normalization.';

comment on function fn_normalize_phone(varchar) is
'Internal helper: E.164-oriented cleanup (trim; remove spaces, dashes, parentheses).';

comment on function fn_normalize_phone_nullable(varchar) is
'Internal helper: nullable phone normalization.';

comment on function fn_normalize_postal_code_pt(varchar) is
'Internal helper: trim and normalize dash spacing for Portuguese postal codes.';

comment on function fn_normalize_postal_code_pt_nullable(varchar) is
'Internal helper: nullable Portuguese postal code normalization.';

comment on function fn_normalize_secret(varchar) is
'Internal helper: trim password hash strings (never lowercase).';

comment on function fn_normalize_omv_number(varchar) is
'Internal helper: trim veterinarian OMV registration identifiers.';

comment on function fn_normalize_omv_number_nullable(varchar) is
'Internal helper: nullable OMV normalization.';

comment on function fn_normalize_code(varchar) is
'Internal helper: upper(trim) for batch codes and registration identifiers.';

comment on function fn_normalize_code_nullable(varchar) is
'Internal helper: nullable code normalization.';

comment on function fn_normalize_reference(varchar) is
'Internal helper: trim document and order references (case preserved).';

comment on function fn_normalize_reference_nullable(varchar) is
'Internal helper: nullable reference normalization.';

comment on function fn_normalize_search_term(text) is
'Internal helper: lower(trim) with collapsed whitespace for read-side filters.';

comment on function validate_password(character varying, character varying) is
'DEPRECATED alias for fn_validate_password. Use fn_validate_password in new code.';
