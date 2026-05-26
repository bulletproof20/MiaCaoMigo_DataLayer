-- =========================================================
-- NARRATIVE DEMO — 09 EXTERNAL ENTITIES
-- Story: Patinhas shelter | Resgate Minhoto | NorteVet supplier
-- =========================================================
-- id_ext_ent 1 Patinhas | 2 Resgate Minhoto | 3 NorteVet Supply
-- =========================================================

set timezone to 'Europe/Lisbon';

insert into external_entity (id_ext_ent, nam_ext_ent, loc_ext_ent, pho_ext_ent, ema_ext_ent, typ_ext_ent)
overriding system value
values
    (1, 'Associação Patinhas do Ave', 'Avenida Marechal Gomes da Costa, Vila Nova de Famalicão', '+351252401880', 'contacto@patinhasave.pt', 'Shelter'),
    (2, 'Resgate Minhoto', 'Guimarães periphery', '+351253555012', 'urgencias@resgateminho.pt', 'Rescue'),
    (3, 'NorteVet Supply Lda', 'Zona Industrial de Palmeira, Braga', '+351253800120', 'comercial@nortevetsupply.pt', 'Supplier');

select setval(pg_get_serial_sequence('external_entity', 'id_ext_ent'),
    (select coalesce(max(id_ext_ent), 1) from external_entity));
