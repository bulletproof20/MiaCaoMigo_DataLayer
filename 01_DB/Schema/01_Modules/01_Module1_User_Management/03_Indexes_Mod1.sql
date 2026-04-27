-- Login Record table

-- unique session per email address
create unique index uq_login_single_active_session_email
on login_record(eml_usr)
where sou_tim_log is null 
  and suc_log = true
  and eml_usr is not null;

