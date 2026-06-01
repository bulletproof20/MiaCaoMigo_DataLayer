-- =========================================================
-- NARRATIVE DEMO — 05 SCHEDULES
-- Story: standard week + Ivo update 20 May (Wed afternoon-only)
-- =========================================================

set timezone to 'Europe/Lisbon';

-- Standard team Mon–Fri + Sat (pre-20 May for Ivo)
insert into schedule (id_emp, day_wee_sch, sta_tim_sch, fin_hou_sch)
select e.id_emp, d.day, t.sta, t.fin
from (values (2),(3),(4),(5),(6),(8),(9),(10)) as e(id_emp)
cross join generate_series(1, 5) as d(day)
cross join (values ('08:00'::time, '12:00'::time), ('14:00'::time, '18:00'::time)) as t(sta, fin)
where e.id_emp <> 2 or d.day <> 3;

insert into schedule (id_emp, day_wee_sch, sta_tim_sch, fin_hou_sch) values
    (2, 3, '12:00', '18:00'),
    (3, 6, '10:00', '15:00'),
    (4, 6, '10:00', '15:00'),
    (5, 6, '10:00', '15:00'),
    (6, 6, '10:00', '15:00'),
    (8, 6, '10:00', '15:00'),
    (9, 6, '10:00', '15:00'),
    (10, 6, '10:00', '15:00');

-- Ivo Saturday extension from 20 May (replace Sat row)
delete from schedule where id_emp = 2 and day_wee_sch = 6;
insert into schedule (id_emp, day_wee_sch, sta_tim_sch, fin_hou_sch) values
    (2, 6, '08:00', '15:00');
