-- =========================================================
-- QA FIXTURE — MODULE 2 — ANIMALS AND OWNERSHIP
-- =========================================================
-- TYPE:     fixture (data only)
-- REQUIRES: Bootstrap init_qa (Master species) + contracts + Mod1
--
-- SEMANTIC CATALOG (reg_id_ani — stable contract keys):
--   QA-ANI-001  internal + welfare delivery     -> qa_animal_internal_id()
--   QA-ANI-002  internal, no delivery, foster   -> qa_animal_no_delivery_id()
--   QA-ANI-003  adopted (Mod4 scheduling)       -> qa_animal_adopted_id()
--   QA-ANI-004  internal + shelter delivery     -> qa_animal_delivery_shelter_id()
--   QA-ANI-005  internal stress adoption race   -> qa_animal_stress_internal_id()
--
-- SPECIES: qa_species_dog_id / cat_id / bird_id (EN or PT Master labels)
-- IDEMPOTENT: upsert by reg_id_ani; postflight contract gate
-- =========================================================

-- -------------------------------------------------------------------------
-- Master-safe QA catalog extensions (species / breeds)
-- -------------------------------------------------------------------------
do $$
declare
    v_dog_spc int := qa_species_dog_id();
    v_cat_spc int := qa_species_cat_id();
    v_bird_spc int := qa_species_bird_id();
begin
    if v_dog_spc is null or v_cat_spc is null then
        raise exception 'QA Mod2 fixture: Master dog/cat species missing — use init_qa bootstrap';
    end if;

    if v_bird_spc is null then
        insert into species (nam_spc, sci_nam_spc)
        values ('Bird', 'Aves');
        v_bird_spc := qa_species_bird_id();
    end if;

    if v_bird_spc is null then
        raise exception 'QA Mod2 fixture: bird species unavailable after catalog seed';
    end if;

    insert into breed (nam_bre, sci_nam_bre, id_spc)
    select v.nam, v.sci, v.id_spc
      from (values
        ('QA Labrador', 'Canis lupus familiaris', v_dog_spc),
        ('QA German Shepherd', 'Canis lupus familiaris', v_dog_spc),
        ('QA Siamese', 'Felis catus', v_cat_spc),
        ('QA Persian', 'Felis catus', v_cat_spc),
        ('QA Canary', 'Serinus canaria', v_bird_spc)
      ) as v(nam, sci, id_spc)
     where not exists (
         select 1 from breed b
          where b.nam_bre = v.nam and b.id_spc = v.id_spc
     );
end;
$$;

-- -------------------------------------------------------------------------
-- QA external partners
-- -------------------------------------------------------------------------
insert into external_entity (nam_ext_ent, loc_ext_ent, pho_ext_ent, ema_ext_ent, typ_ext_ent)
select v.nam, v.loc, v.pho, v.ema, v.typ
  from (values
    ('QA Happy Paws Shelter', 'Lisbon', '+351912345678', 'shelter@qa.miacaomigo.pt', 'Shelter'),
    ('QA Pro Feed Supplier', 'Porto', '+351223456789', 'supplier@qa.miacaomigo.pt', 'Supplier'),
    ('QA Animal Welfare Assoc', 'Coimbra', '+351239123456', 'welfare@qa.miacaomigo.pt', 'Association')
  ) as v(nam, loc, pho, ema, typ)
 where not exists (select 1 from external_entity e where e.ema_ext_ent = v.ema);

-- -------------------------------------------------------------------------
-- QA animals (explicit upsert per reg_id_ani)
-- -------------------------------------------------------------------------
do $$
declare
    v_dog_spc int := qa_species_dog_id();
    v_cat_spc int := qa_species_cat_id();
    v_bird_spc int := qa_species_bird_id();
    v_bre_lab int;
    v_bre_gsd int;
    v_bre_sia int;
    v_bre_can int;
    rec record;
begin
    select id_bre into v_bre_lab from breed where nam_bre = 'QA Labrador' and id_spc = v_dog_spc limit 1;
    select id_bre into v_bre_gsd from breed where nam_bre = 'QA German Shepherd' and id_spc = v_dog_spc limit 1;
    select id_bre into v_bre_sia from breed where nam_bre = 'QA Siamese' and id_spc = v_cat_spc limit 1;
    select id_bre into v_bre_can from breed where nam_bre = 'QA Canary' and id_spc = v_bird_spc limit 1;

    if v_bre_lab is null or v_bre_gsd is null or v_bre_sia is null or v_bre_can is null then
        raise exception 'QA Mod2 fixture: QA breeds missing — breed seed step failed';
    end if;

    for rec in
        select *
          from (values
            ('QA-ANI-001', 'Bobby QA', date '2020-05-10', 'M', 'Street', 'Interno', v_dog_spc, v_bre_lab),
            ('QA-ANI-002', 'Luna QA', date '2021-02-20', 'F', 'Clinic born', 'Interno', v_dog_spc, v_bre_gsd),
            ('QA-ANI-003', 'Miau QA', date '2019-11-15', 'M', 'External delivery', 'Interno', v_cat_spc, v_bre_sia),
            ('QA-ANI-004', 'Pipocas QA', date '2022-08-01', 'F', 'Street', 'Interno', v_bird_spc, v_bre_can),
            ('QA-ANI-005', 'Rex QA', date '2018-03-12', 'M', 'Abandonment', 'Interno', v_dog_spc, v_bre_gsd)
          ) as t(reg_id, nam, bir, gen, ori, sta, id_spc, id_bre)
    loop
        insert into animal (
            reg_id_ani, nam_ani, dat_bir_ani, gen_ani, ori_ani, sta_ani, id_spc, id_bre
        )
        select
            rec.reg_id, rec.nam, rec.bir, rec.gen, rec.ori, rec.sta, rec.id_spc, rec.id_bre
         where not exists (
             select 1 from animal a where a.reg_id_ani = rec.reg_id
         );
    end loop;
end;
$$;

-- -------------------------------------------------------------------------
-- Ownership baseline (adopted + closed foster)
-- -------------------------------------------------------------------------
do $$
declare
    v_cli_active int := qa_client_active_id();
    v_cli_sec int := qa_client_secondary_id();
    v_reg int := qa_registrar_emp_id();
begin
    if v_cli_active is null or v_reg is null then
        raise exception 'QA Mod2 fixture: missing client/registrar contracts — run Mod1 fixture first';
    end if;

    insert into ownership (id_cli, id_ani, id_emp, sta_dat_own, end_dat_own, mot_own)
    select v_cli_active, a.id_ani, v_reg, date '2026-01-10', null, 'QA adoption for Mod4 scheduling'
      from animal a
     where a.reg_id_ani = 'QA-ANI-003'
       and not exists (
           select 1 from ownership o
            where o.id_ani = a.id_ani and o.end_dat_own is null
       );

    update animal
       set sta_ani = 'Adotado'
     where reg_id_ani = 'QA-ANI-003'
       and sta_ani <> 'Adotado';

    if v_cli_sec is not null then
        insert into ownership (id_cli, id_ani, id_emp, sta_dat_own, end_dat_own, mot_own)
        select v_cli_sec, a.id_ani, v_reg, date '2026-02-01', date '2026-03-01', 'QA temporary foster'
          from animal a
         where a.reg_id_ani = 'QA-ANI-002'
           and not exists (
               select 1 from ownership o
                where o.id_ani = a.id_ani
                  and o.id_cli = v_cli_sec
                  and o.sta_dat_own = date '2026-02-01'
           );
    end if;
end;
$$;

-- -------------------------------------------------------------------------
-- Deliveries (single intake per animal — uq_animal_single_delivery)
-- -------------------------------------------------------------------------
insert into delivery (reg_dat_del, res_dat_del, del_dat_del, res_loc_del, cli_sta_del, id_ext_ent, id_ani)
select
    current_timestamp - interval '2 hours',
    current_timestamp - interval '3 hours',
    current_timestamp - interval '2 hours',
    'Lower Street, Braga',
    'Malnourished',
    e.id_ext_ent,
    a.id_ani
  from animal a
  join external_entity e on e.ema_ext_ent = 'shelter@qa.miacaomigo.pt'
 where a.reg_id_ani = 'QA-ANI-004'
   and not exists (select 1 from delivery d where d.id_ani = a.id_ani);

insert into delivery (reg_dat_del, res_dat_del, del_dat_del, res_loc_del, cli_sta_del, id_ext_ent, id_ani)
select
    current_timestamp - interval '26 hours',
    current_timestamp - interval '27 hours',
    current_timestamp - interval '25 hours',
    'City Park',
    'Healthy',
    e.id_ext_ent,
    a.id_ani
  from animal a
  join external_entity e on e.ema_ext_ent = 'welfare@qa.miacaomigo.pt'
 where a.reg_id_ani = 'QA-ANI-001'
   and not exists (
       select 1 from delivery d
        where d.id_ani = a.id_ani and d.res_loc_del = 'City Park'
   );

insert into delivery_employee (id_del, id_emp)
select d.id_del, qa_registrar_emp_id()
  from delivery d
  join animal a on a.id_ani = d.id_ani
 where a.reg_id_ani in ('QA-ANI-001', 'QA-ANI-004')
   and not exists (
       select 1 from delivery_employee de
        where de.id_del = d.id_del and de.id_emp = qa_registrar_emp_id()
   );

insert into concession (dat_con, mot_con, cli_sta_con, id_ext_ent, id_emp, id_ani)
select date '2026-04-15', 'QA transfer to specialized shelter', 'Healthy', e.id_ext_ent, qa_registrar_emp_id(), a.id_ani
  from animal a
  join external_entity e on e.ema_ext_ent = 'shelter@qa.miacaomigo.pt'
 where a.reg_id_ani = 'QA-ANI-002'
   and not exists (select 1 from concession c where c.id_ani = a.id_ani);

-- -------------------------------------------------------------------------
-- Postflight — contract gate (fail fast if catalog incomplete)
-- -------------------------------------------------------------------------
do $$
begin
    if qa_animal_internal_id() is null
       or qa_animal_no_delivery_id() is null
       or qa_animal_adopted_id() is null
       or qa_animal_delivery_shelter_id() is null
       or qa_animal_stress_internal_id() is null
       or qa_external_entity_shelter_id() is null then
        raise exception
            'QA Mod2 fixture incomplete — expected QA-ANI-001..005 and shelter entity';
    end if;
end;
$$;
