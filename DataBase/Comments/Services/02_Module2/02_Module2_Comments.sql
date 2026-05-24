-- =========================================================
-- comments: services — module 2 (animal management)
-- =========================================================

comment on function svc_register_adoption(integer, integer, integer, character varying) is
'Public API: adoption workflow via sp_assign_ownership.';

comment on function svc_register_delivery(integer, integer, character varying, character varying, integer[]) is
'Public API: shelter intake via sp_record_delivery.';

comment on function svc_animal_exit(integer, character varying) is
'Public API: definitive animal exit (status update + ownership closure).';

comment on function svc_get_animal_history(integer) is
'Public API: merged ownership and concession timeline for one animal.';

comment on function svc_list_internal_animals_available() is
'Public API: read vw_internal_animals_available.';

comment on function svc_get_active_ownership_by_animal(integer) is
'Public API: read vw_active_ownership_detail for one animal.';

comment on function svc_get_animal_catalog_entry(integer) is
'Public API: read vw_animal_catalog_detail by id_ani.';

comment on function fn_register_adoption(integer, integer, integer, character varying) is
'DEPRECATED alias for svc_register_adoption.';

comment on function fn_register_delivery_team(integer, integer, character varying, character varying, integer[]) is
'DEPRECATED alias for svc_register_delivery.';

comment on function fn_animal_exit(integer, character varying) is
'DEPRECATED alias for svc_animal_exit.';

comment on function fn_get_animal_history(integer) is
'DEPRECATED alias for svc_get_animal_history.';

comment on function fn_list_internal_animals_available() is
'DEPRECATED alias for svc_list_internal_animals_available.';

comment on function fn_get_active_ownership_by_animal(integer) is
'DEPRECATED alias for svc_get_active_ownership_by_animal.';

comment on function fn_get_animal_catalog_entry(integer) is
'DEPRECATED alias for svc_get_animal_catalog_entry.';
