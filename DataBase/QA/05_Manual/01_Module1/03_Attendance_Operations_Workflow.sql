-- =========================================================
-- MANUAL TEST — MODULE 1
-- WORKFLOW: Clock-in/out, schedule, absence (operational)
-- =========================================================
-- PURPOSE:
--   fn_clock_employee toggle, operational views, schedule slot,
--   absence registration with overlap rules.
--
-- EXPECTED:
--   - CLOCK_IN then CLOCK_OUT for qa.clockable@miacaomigo.pt employee
--   - vw_open_clock_in_sessions reflects state
--   - Future absence insert succeeds; overlapping absence fails
--
-- REQUIRES: init_qa + fixtures/01_Module1/01_Core_Context.sql (qa_emp_clockable_id)
-- =========================================================

do $$ begin
    raise notice 'MANUAL M1-03 — Attendance operations';
end $$;

do $$ begin
    raise notice '--- BEFORE: open clock-ins (vw_open_clock_in_sessions) ---';
end $$;

select * from vw_open_clock_in_sessions where id_emp = qa_emp_clockable_id();

do $$ begin
    raise notice '--- STEP: toggle clock until CLOCK_OUT ---';
end $$;

select fn_clock_employee(qa_emp_clockable_id()) as clock_action_1;
select fn_clock_employee(qa_emp_clockable_id()) as clock_action_2;

select * from vw_open_clock_in_sessions where id_emp = qa_emp_clockable_id();

do $$ begin
    raise notice '--- STEP: schedule row (Mon 09:00-17:00) ---';
end $$;

insert into schedule (id_emp, day_wee_sch, sta_tim_sch, fin_hou_sch)
select qa_emp_clockable_id(), 1, time '09:00', time '17:00'
 where not exists (
     select 1 from schedule s
      where s.id_emp = qa_emp_clockable_id() and s.day_wee_sch = 1
 );

select id_emp, day_wee_sch, sta_tim_sch, fin_hou_sch
from schedule
where id_emp = qa_emp_clockable_id()
order by day_wee_sch, sta_tim_sch;

do $$ begin
    raise notice '--- STEP: future absence (should succeed) ---';
end $$;

insert into absence (id_emp, sta_dat_tim_abs, end_dat_tim_abs, mot_abs, sta_abs)
values (
    qa_emp_clockable_id(),
    current_timestamp + interval '30 days',
    current_timestamp + interval '32 days',
    'manual qa ferias',
    'approved'
);

select * from vw_operational_absences
where id_emp = qa_emp_clockable_id()
order by sta_dat_tim_abs desc
limit 3;

do $$ begin
    raise notice '--- STEP: overlapping absence (uncomment to probe trigger) ---';
end $$;

-- insert into absence (id_emp, sta_dat_tim_abs, end_dat_tim_abs, mot_abs, sta_abs)
-- values (
--     6,
--     current_timestamp + interval '31 days',
--     current_timestamp + interval '33 days',
--     'manual qa overlap probe',
--     'approved'
-- );
