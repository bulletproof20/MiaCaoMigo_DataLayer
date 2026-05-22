--==============================
-- DEBUG / VALIDATION
--==============================

-- active sessions

select *
from login_record
where sou_tim_log is null
  and suc_log = true;


-- authentication history

select *
from login_record
order by sig_tim_log desc;


-- active employee records

select
    id_emp,
    id_usr,
    ema_emp,
    reg_dat_emp,
    dea_dat_emp
from employee
where dea_dat_emp is null
order by id_usr;


-- inactive employee records

select
    id_emp,
    id_usr,
    ema_emp,
    reg_dat_emp,
    dea_dat_emp
from employee
where dea_dat_emp is not null
order by id_usr;