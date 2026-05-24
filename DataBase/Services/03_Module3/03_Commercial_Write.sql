-- =========================================================
-- MODULE 3 — COMMERCIAL WRITE (svc_* public API)
-- FILE: 03_Commercial_Write.sql
-- =========================================================

drop function if exists svc_receive_purchase(int);
drop function if exists svc_check_restock_needs();

create function svc_receive_purchase(p_id_pur int)
returns void
language plpgsql
as $$
begin
    call sp_receive_purchase(p_id_pur);
end;
$$;

create function svc_check_restock_needs()
returns void
language plpgsql
as $$
begin
    call sp_check_restock_needs();
end;
$$;

-- deprecated aliases (Phase 1)
drop function if exists fn_receive_purchase(int);
create function fn_receive_purchase(p_id_pur int)
returns void language plpgsql as $$
begin perform svc_receive_purchase(p_id_pur); end; $$;

drop function if exists fn_check_restock_needs();
create function fn_check_restock_needs()
returns void language plpgsql as $$
begin perform svc_check_restock_needs(); end; $$;
