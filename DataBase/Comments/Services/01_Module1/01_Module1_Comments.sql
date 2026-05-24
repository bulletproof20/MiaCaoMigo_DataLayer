-- =========================================================
-- comments: services — module 1 (user management)
-- =========================================================

-- identity (fn_* internal)
comment on function fn_is_employee_email(character varying) is
'Internal: true when email belongs to corporate @miacaomigo.pt domain.';

comment on function fn_get_user_by_email(character varying) is
'Internal: resolves id_usr from employee.ema_emp or user_account.ema_usr.';

comment on function fn_get_user_by_nif(character varying) is
'Internal: returns id_usr for a NIF on user_account.';

comment on function fn_get_user_by_employee(integer) is
'Internal: maps id_emp to id_usr.';

comment on function fn_get_user_by_client(integer) is
'Internal: maps id_cli to id_usr.';

comment on function fn_get_active_employee_by_user(integer) is
'Internal: active id_emp for a user (ranked).';

comment on function fn_get_client_by_user(integer) is
'Internal: id_cli for a user when client profile exists.';

comment on function fn_user_exists_by_email(character varying) is
'Internal: email exists on employee or user_account.';

comment on function fn_user_exists_by_nif(character varying) is
'Internal: NIF exists on user_account.';

comment on function fn_client_exists(integer) is
'Internal: user already has client row.';

comment on function fn_has_active_employee(integer) is
'Internal: user has active employee row.';

comment on function fn_is_veterinarian(integer) is
'Internal: employee id in veterinarian.';

comment on function fn_is_assistant(integer) is
'Internal: employee id in assistant.';

-- validations (fn_* internal)
comment on function fn_is_account_active(character varying) is
'Internal: active employee or client for normalized email.';

-- query helpers (fn_pick_* internal)
comment on function fn_pick_latest_login_record(integer, boolean, boolean) is
'Internal: latest login_record for user with optional outcome filter.';

comment on function fn_pick_most_recent_employee(integer) is
'Internal: canonical id_emp for user (renewal/lifecycle).';

comment on function fn_pick_schedule_source_employee() is
'Internal: latest inactive employee with schedules for replication.';

comment on function fn_pick_open_clock_session(integer) is
'Internal: active open clock-in session for employee.';

comment on function fn_validate_password(character varying, character varying) is
'Internal: compares API hash with pas_emp or pas_cli.';

-- session helpers (fn_* internal)
comment on function fn_has_active_sessions(character varying) is
'Internal: open successful login_record session exists for email.';

comment on function fn_close_active_sessions_by_email(character varying) is
'Internal: closes open sessions for email; returns true when rows updated.';

-- business workflows (sp_* — Services layer)
comment on function sp_auth_login(character varying, character varying, inet) is
'Business workflow: authenticate, enforce single session, audit login_record.';

comment on function sp_auth_logout(character varying) is
'Business workflow: close active session for email.';

comment on procedure sp_create_client(character varying, text, character varying, character varying, character varying, character varying, character varying, character varying, integer) is
'Business workflow: register client with identity reuse rules.';

comment on procedure sp_create_employee(character varying, text, character varying, character varying, character varying, character varying, character varying, character varying, character varying, integer, integer) is
'Business workflow: register employee with corporate email.';

comment on function sp_create_assistant(character varying, text, character varying, character varying, character varying, character varying, character varying, character varying, character varying, integer, character varying) is
'Business workflow: onboard assistant (employee + assistant row).';

comment on function sp_create_veterinarian(character varying, text, character varying, character varying, character varying, character varying, character varying, character varying, character varying, integer, character varying) is
'Business workflow: onboard veterinarian (employee + OMV row).';

comment on procedure sp_renew_employee_record(integer, integer, integer) is
'Business workflow: inactivate latest employee row and insert successor.';

comment on function sp_promote_to_veterinarian(integer, character varying, integer) is
'Business workflow: renew employment and attach veterinarian role.';

comment on function sp_promote_to_assistant(integer, character varying, integer) is
'Business workflow: renew employment and attach assistant role.';

comment on function sp_demote_to_general_employee(integer, integer) is
'Business workflow: renew employment without role extension.';

comment on procedure sp_clock_toggle(integer, character varying) is
'Business workflow: clock-in/out toggle.';

comment on procedure sp_replicate_schedule(integer) is
'Business workflow: copy schedule from historical employee to target.';

-- public API (svc_*)
comment on function svc_auth_login(character varying, character varying, inet) is
'Public API: application login entry point.';

comment on function svc_auth_logout(character varying) is
'Public API: application logout entry point.';

comment on function svc_create_client(character varying, text, character varying, character varying, character varying, character varying, character varying, character varying) is
'Public API: register client.';

comment on function svc_create_employee(character varying, text, character varying, character varying, character varying, character varying, character varying, character varying, character varying, integer) is
'Public API: register employee.';

comment on function svc_create_assistant(character varying, text, character varying, character varying, character varying, character varying, character varying, character varying, character varying, integer, character varying) is
'Public API: onboard assistant.';

comment on function svc_create_veterinarian(character varying, text, character varying, character varying, character varying, character varying, character varying, character varying, character varying, integer, character varying) is
'Public API: onboard veterinarian.';

comment on function svc_promote_to_veterinarian(integer, character varying, integer) is
'Public API: promote employee to veterinarian.';

comment on function svc_promote_to_assistant(integer, character varying, integer) is
'Public API: promote employee to assistant.';

comment on function svc_demote_to_general_employee(integer, integer) is
'Public API: demote to general employee.';

comment on function svc_clock_toggle(integer) is
'Public API: clock-in/out toggle.';

comment on function svc_replicate_schedule(integer) is
'Public API: replicate weekly schedule.';

comment on function fn_create_user_account(character varying, text, character varying, character varying, character varying, character varying) is
'Internal: inserts user_account (setup via trigger).';

comment on function fn_assign_profile(integer, integer) is
'Internal: links employee to profile via occupies.';

