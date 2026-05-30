-- =========================================================
-- NARRATIVE DEMO — 02 EMPLOYEES
-- Story: Ivo (1 May), team (4 May), Isabel (5 May), Bernardo inactive (15 Mar)
-- =========================================================
-- id_emp 2 Ivo | 3 Tiago | 4 Navarro | 5 Marcelo | 6 Isabel | 7 Bernardo (inactive)
-- =========================================================

set timezone to 'Europe/Lisbon';

insert into employee (
    id_emp, id_usr, reg_dat_emp, aut_reg_emp, dea_dat_emp, aut_ina_emp,
    pho_emp, pho_emg, ema_emp, pas_emp
)
overriding system value
values
    (2, 2, '2026-05-01 09:00:00+01', 1, null, null, '+351911911912', '+351911911913', '2@miacaomigo.pt', '15e2b0d3c33891ebb0f1ef609ec419420c20e320ce94c65fbc8c3312448eb225'),
    (3, 3, '2026-05-04 08:00:00+01', 2, null, null, '+351922922923', null, '3@miacaomigo.pt', '15e2b0d3c33891ebb0f1ef609ec419420c20e320ce94c65fbc8c3312448eb225'),
    (4, 4, '2026-05-04 08:05:00+01', 2, null, null, '+351933933934', null, '4@miacaomigo.pt', '15e2b0d3c33891ebb0f1ef609ec419420c20e320ce94c65fbc8c3312448eb225'),
    (5, 5, '2026-05-04 08:10:00+01', 2, null, null, '+351944944945', '+351944944946', '5@miacaomigo.pt', '15e2b0d3c33891ebb0f1ef609ec419420c20e320ce94c65fbc8c3312448eb225'),
    (6, 6, '2026-05-05 08:00:00+01', 2, null, null, '+351955955956', null, '6@miacaomigo.pt', '15e2b0d3c33891ebb0f1ef609ec419420c20e320ce94c65fbc8c3312448eb225'),
    (7, 7, '2025-09-01 09:00:00+01', 1, '2026-03-15 17:00:00+01', 2, '+351912340299', null, '7@miacaomigo.pt', '15e2b0d3c33891ebb0f1ef609ec419420c20e320ce94c65fbc8c3312448eb225');

insert into assistant (id_emp, fun_ass) values
    (3, 'Animal care and shelter intake'),
    (4, 'Commercial desk and inventory'),
    (6, 'Public desk and customer intake'),
    (7, 'Public desk (historical)');

insert into veterinarian (id_emp, num_omv_vet) values
    (5, 'OMV-PT-2026-BC-00412');

select setval(pg_get_serial_sequence('employee', 'id_emp'),
    (select coalesce(max(id_emp), 1) from employee));
