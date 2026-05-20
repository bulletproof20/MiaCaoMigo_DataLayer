-- =========================================================
-- INTEGRITY — MODULE 2 — DUPLICATE ACTIVE OWNERSHIP
-- =========================================================
-- TYPE:     01_Integrity
-- REQUIRES: 04_Loaders/03_TestData.sql
-- RULE:     sp_assign_ownership + trg_prevent_duplicate_active_ownership
-- FIXTURES: animal 3 adopted (id_cli 4); client 5 available
-- =========================================================
-- expected:
-- - second active ownership on adopted animal blocked
-- =========================================================

do $$
begin
    call sp_assign_ownership(3, 5, 1, 'Integrity duplicate adoption attempt');
    raise notice 'FAIL: duplicate ownership should be blocked';
exception
    when others then
        if sqlerrm like '%ownership%'
           or sqlerrm like '%active owner%'
           or sqlerrm like '%Interno%'
           or sqlerrm like '%disponível%'
           or sqlerrm like '%Adotado%' then
            raise notice 'PASS: duplicate ownership blocked — %', sqlerrm;
        else
            raise notice 'FAIL: unexpected duplicate ownership error — %', sqlerrm;
        end if;
end;
$$;
