-- =========================================================
-- NARRATIVE DEMO — 11 OWNERSHIPS
-- Story: pre-existing pets + adoption prep
-- =========================================================

set timezone to 'Europe/Lisbon';

insert into ownership (id_own, id_cli, id_ani, sta_dat_own, end_dat_own, mot_own, id_emp)
overriding system value
values
    (1, 1, 1, '2026-01-10', null, 'primary registration goncalo rego', 2),
    (2, 5, 8, '2023-05-01', null, 'isabel carvalho cat tico', 2),
    (3, 5, 9, '2024-02-01', null, 'isabel carvalho cat teco', 2),
    (4, 5, 10, '2022-08-01', null, 'isabel carvalho dog jeronimo', 2),
    (5, 4, 11, '2025-12-15', null, 'pedro costa dog thor', 2),
    (6, 3, 6, '2018-01-01', null, 'ana lourenco cat bento', 2);

update animal set sta_ani = 'Adotado' where id_ani = 1;
update animal set sta_ani = 'Adotado' where id_ani in (8, 9, 10);
update animal set sta_ani = 'Adotado' where id_ani = 11;
update animal set sta_ani = 'Adotado' where id_ani = 6;

select setval(pg_get_serial_sequence('ownership', 'id_own'),
    (select coalesce(max(id_own), 1) from ownership));
