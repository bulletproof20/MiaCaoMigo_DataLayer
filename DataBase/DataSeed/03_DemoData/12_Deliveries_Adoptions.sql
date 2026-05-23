-- =========================================================
-- NARRATIVE DEMO — 12 DELIVERIES & ADOPTIONS (procedures)
-- Story: Tiago intake 4–5 May | adoptions 8 May | Max concession 20 May | Bento 28 May
-- =========================================================

set timezone to 'Europe/Lisbon';

-- 4 May — Rogerim from Patinhas (Tiago id_emp 3)
do $body$
begin
    call sp_record_delivery(
        2,
        '2026-05-04 15:30:00+01'::timestamp,
        'Parque da Ponte, Braga',
        'Dehydrated, responsive',
        1,
        array[3]
    );
end;
$body$;

-- 4 May — Quico from Resgate Minhoto
do $body$
begin
    call sp_record_delivery(
        3,
        '2026-05-04 17:00:00+01'::timestamp,
        'A3 rest area km 98',
        'Anxious, no visible injury',
        2,
        array[3, 5]
    );
end;
$body$;

-- 5 May — Pipoca transfer
do $body$
begin
    call sp_record_delivery(
        4,
        '2026-05-05 11:00:00+01'::timestamp,
        'Famalicão shelter intake bay',
        'Stable for transfer',
        1,
        array[3]
    );
end;
$body$;

-- 8 May — Rogerim → Gonçalo
do $body$
begin
    call sp_assign_ownership(2, 1, 3, 'clinic adoption rogerim');
end;
$body$;

-- 8 May — Pipoca → Ana
do $body$
begin
    call sp_assign_ownership(4, 3, 3, 'clinic adoption pipoca');
end;
$body$;

-- 8 May — Felix → Marta (registered same morning)
do $body$
begin
    call sp_assign_ownership(7, 2, 3, 'local shelter adoption felix');
end;
$body$;

-- 20 May — Max concession back to Patinhas
do $body$
begin
    call sp_process_concession(
        5,
        1,
        3,
        'long term placement specialist unit',
        'stable for partner transfer'
    );
end;
$body$;

-- Bento euthanasia (28 May) runs after appointments — see 15_Appointments.sql
