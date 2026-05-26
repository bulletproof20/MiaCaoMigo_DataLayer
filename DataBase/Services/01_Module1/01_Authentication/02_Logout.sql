-- =========================================================
-- LOGOUT (MODULE 1 — AUTHENTICATION)
-- BUSINESS WORKFLOW: sp_auth_logout
-- =========================================================

drop function if exists sp_auth_logout(varchar);

create or replace function sp_auth_logout(p_email varchar)
returns boolean
language plpgsql
as $$
declare
    v_closed boolean;
begin

    p_email := fn_normalize_email(p_email);

    v_closed := fn_close_active_sessions_by_email(p_email);

    if not v_closed then
        raise notice 'Logout attempt Fail (no active session): %', p_email;
        return false;
    end if;

    raise notice 'Logged out successfully: %', p_email;
    return true;

end;
$$;
