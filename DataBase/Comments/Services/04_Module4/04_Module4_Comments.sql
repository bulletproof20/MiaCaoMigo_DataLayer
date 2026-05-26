-- =========================================================
-- comments: services — module 4 (appointment management)
-- =========================================================

comment on function svc_list_appointments_today() is
'Public API: operational board from vw_appointments_today.';

comment on function svc_list_appointments_tomorrow() is
'Public API: reminder shortlist from vw_scheduled_appointments_tomorrow.';

comment on function svc_get_appointment_detail(integer) is
'Public API: single row from vw_appointment_detail.';

comment on function svc_list_vet_appointments_from(integer, date) is
'Public API: scheduled appointments for a veterinarian from vw_appointment_detail.';

comment on function svc_list_animal_appointment_history(integer) is
'Public API: appointment history for one animal from vw_appointment_detail.';
