-- =========================================================
-- QUERIES — MODULE 1 — USER CREATION (inspection)
-- =========================================================
-- TYPE:
--   Observational / debugging queries
--
-- PURPOSE:
--   Inspect identity bindings, employment spells, role rows,
--   and RBAC after manual or fixture mutations.
--
-- REQUIRES:
--   init_qa (+ optional QA fixtures)
--
-- RELATED:
--   QA/05_Manual/01_Module1/User_Creation/
--   Services/01_Module1/02_User_Creation/
-- =========================================================

--==============================
-- CLIENT BINDINGS
--==============================

select
    u.id_usr,
    u.nam_usr,
    u.nif_usr,
    u.ema_usr,
    c.id_cli,
    c.reg_dat_cli,
    c.ina_dat_cli
  from user_account u
  join client c on c.id_usr = u.id_usr
 where u.ema_usr like '%cstress%'
    or u.ema_usr like 'qa.manual.%'
    or u.ema_usr = 'platform.admin@ipca.pt'
 order by u.id_usr desc;


--==============================
-- EMPLOYEE BINDINGS
--==============================

select
    u.id_usr,
    u.nam_usr,
    e.id_emp,
    e.ema_emp,
    e.reg_dat_emp,
    e.dea_dat_emp
  from user_account u
  join employee e on e.id_usr = u.id_usr
 where u.ema_usr like '%cstress%'
    or u.ema_usr like 'qa.manual.%'
    or u.ema_usr = 'platform.admin@ipca.pt'
    or e.ema_emp like '%@miacaomigo.pt'
 order by e.id_emp desc;


--==============================
-- SHARED CLIENT + EMPLOYEE IDENTITIES
--==============================

select
    u.id_usr,
    u.nam_usr,
    c.id_cli,
    e.id_emp,
    e.ema_emp
  from user_account u
  join client c on c.id_usr = u.id_usr
  join employee e on e.id_usr = u.id_usr
 where e.dea_dat_emp is null
 order by u.id_usr desc;


--==============================
-- EMPLOYMENT SPELL HISTORY
--==============================

select
    e.id_usr,
    u.nam_usr,
    count(*) as total_spells,
    min(e.reg_dat_emp) as first_registration,
    max(e.reg_dat_emp) as latest_registration
  from employee e
  join user_account u on u.id_usr = e.id_usr
 group by e.id_usr, u.nam_usr
having count(*) > 1
 order by total_spells desc;


--==============================
-- ASSISTANT ROLE ASSOCIATIONS
--==============================

select
    a.id_emp,
    u.nam_usr,
    e.ema_emp,
    a.fun_ass
  from assistant a
  join employee e on e.id_emp = a.id_emp
  join user_account u on u.id_usr = e.id_usr
 order by a.id_emp;


--==============================
-- VETERINARIAN ROLE ASSOCIATIONS
--==============================

select
    v.id_emp,
    u.nam_usr,
    e.ema_emp,
    v.num_omv_vet
  from veterinarian v
  join employee e on e.id_emp = v.id_emp
  join user_account u on u.id_usr = e.id_usr
 order by v.id_emp;


--==============================
-- VETERINARIAN SPECIALTIES (expert)
--==============================

select
    v.id_emp,
    u.nam_usr,
    v.num_omv_vet,
    s.nam_spe
  from veterinarian v
  join employee e on e.id_emp = v.id_emp
  join user_account u on u.id_usr = e.id_usr
  left join expert ex on ex.id_emp = v.id_emp
  left join specialty s on s.id_spe = ex.id_spe
 order by v.id_emp, s.nam_spe;


--==============================
-- RBAC PROFILE OCCUPATIONS
--==============================

select
    e.id_emp,
    u.nam_usr,
    p.nam_pro
  from employee e
  join user_account u on u.id_usr = e.id_usr
  left join occupies o on o.id_emp = e.id_emp
  left join profile p on p.id_pro = o.id_pro
 order by e.id_emp;


--==============================
-- ASSISTANT / VETERINARIAN EXCLUSIVITY
-- expected: zero rows
--==============================

select
    e.id_emp,
    u.nam_usr,
    a.fun_ass,
    v.num_omv_vet
  from employee e
  join user_account u on u.id_usr = e.id_usr
  join assistant a on a.id_emp = e.id_emp
  join veterinarian v on v.id_emp = e.id_emp;
