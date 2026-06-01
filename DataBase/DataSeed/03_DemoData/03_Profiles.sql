-- =========================================================
-- NARRATIVE DEMO — 03 PROFILES & SPECIALTIES
-- Story: Ivo seeds team RBAC (4 May) + dermatology specialty
-- =========================================================
-- RBAC occupies (id_pro): 1 administrador | 2 veterinario
--   3 assistente | 4 gestor comercial
-- id_emp 2 Ivo→1 | 3 Tiago→3 | 4 Navarro→4 | 5 Marcelo→2
--   6 Isabel→3 | 7 Bernardo→3 (inactive, historical)
--   8 Sofia→5 | 9 Ricardo→6 | 10 Miguel — sem occupies (funcionario generico)
-- id_spe 2 dermatology (Marcelo expert)
-- =========================================================

set timezone to 'Europe/Lisbon';

insert into specialty (id_spe, nam_spe, des_spe)
overriding system value
values (2, 'dermatology', 'dermatological conditions and allergy workups for companion animals');

-- Demo team profile assignments (MasterData defines profiles 1–6)
insert into occupies (id_emp, id_pro) values
    (2, 1),   -- Ivo Sá — administrador
    (3, 3),   -- Tiago Mendes — assistente (animal care / shelter intake)
    (4, 4),   -- João Navarro — gestor comercial (commercial desk)
    (5, 2),   -- João Marcelo — veterinario (clinical lead)
    (6, 3),   -- Isabel — assistente (public desk / scheduling)
    (7, 3),   -- Bernardo — assistente (historical, inactive)
    (8, 5),   -- Sofia Mendes — gestor rh
    (9, 6);   -- Ricardo Almeida — diretor clinico

insert into expert (id_emp, id_spe) values
    (5, 1),
    (5, 2);

select setval(pg_get_serial_sequence('specialty', 'id_spe'),
    (select coalesce(max(id_spe), 1) from specialty));
