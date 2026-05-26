-- =========================================================
-- QUERIES — MODULE 1 — AUTHENTICATION (reference)
-- =========================================================
-- TYPE:     Queries/ (reusable SELECTs — not a manual workflow)
-- REQUIRES: init_demo or init_qa with login data present
-- WORKFLOWS: QA/05_Manual/01_Module1/Authentication/
-- API:       svc_auth_login / svc_auth_logout (Services/01_Module1/99_Public_API/)
-- =========================================================

-- Recent login attempts (audit trail)
select
    lr.id_log,
    lr.ema_log,
    lr.suc_log,
    lr.sig_tim_log,
    lr.sou_tim_log,
    lr.ip_add_log,
    lr.id_usr
from login_record lr
order by lr.sig_tim_log desc
limit 20;

-- Open sessions (successful login without logout timestamp)
select
    lr.id_log,
    lr.id_usr,
    ua.ema_usr,
    lr.sig_tim_log,
    lr.ip_add_log
from login_record lr
left join user_account ua on ua.id_usr = lr.id_usr
where lr.suc_log = true
  and lr.sou_tim_log is null
order by lr.sig_tim_log desc;
