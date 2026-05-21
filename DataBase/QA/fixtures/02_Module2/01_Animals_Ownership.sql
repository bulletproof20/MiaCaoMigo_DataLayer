-- =========================================================
-- QA FIXTURE — MODULE 2 — ANIMALS AND OWNERSHIP
-- =========================================================
-- TYPE:     fixture (data only)
-- REQUIRES: fixtures/01_Module1/01_Core_Context.sql + contracts
-- PROVIDES: QA-ANI-001 (internal), QA-ANI-003 (adopted), QA-ANI-005 (stress)
-- =========================================================

insert into species (nam_spc, sci_nam_spc)
select 'Bird', 'Aves'
 where not exists (select 1 from species where nam_spc = 'Bird');

insert into breed (nam_bre, sci_nam_bre, id_spc)
select v.nam, v.sci, s.id_spc
  from (values
    ('QA Labrador', 'Canis lupus', 'Dog'),
    ('QA German Shepherd', 'Canis lupus', 'Dog'),
    ('QA Siamese', 'Felis catus', 'Cat'),
    ('QA Persian', 'Felis catus', 'Cat'),
    ('QA Canary', 'Serinus canaria', 'Bird')
  ) as v(nam, sci, spc)
  join species s on s.nam_spc = v.spc
 where not exists (select 1 from breed b where b.nam_bre = v.nam);

insert into external_entity (nam_ext_ent, loc_ext_ent, pho_ext_ent, ema_ext_ent, typ_ext_ent)
select v.nam, v.loc, v.pho, v.ema, v.typ
  from (values
    ('QA Happy Paws Shelter', 'Lisbon', '+351912345678', 'shelter@qa.miacaomigo.pt', 'Shelter'),
    ('QA Pro Feed Supplier', 'Porto', '+351223456789', 'supplier@qa.miacaomigo.pt', 'Supplier'),
    ('QA Animal Welfare Assoc', 'Coimbra', '+351239123456', 'welfare@qa.miacaomigo.pt', 'Association')
  ) as v(nam, loc, pho, ema, typ)
 where not exists (select 1 from external_entity e where e.ema_ext_ent = v.ema);

insert into animal (reg_id_ani, nam_ani, dat_bir_ani, gen_ani, ori_ani, sta_ani, id_spc, id_bre)
select v.reg, v.nam, v.bir, v.gen, v.ori, v.sta, s.id_spc, b.id_bre
  from (values
    ('QA-ANI-001', 'Bobby QA', date '2020-05-10', 'M', 'Street', 'Interno', 'Dog', 'QA Labrador'),
    ('QA-ANI-002', 'Luna QA', date '2021-02-20', 'F', 'Clinic born', 'Interno', 'Dog', 'QA German Shepherd'),
    ('QA-ANI-003', 'Miau QA', date '2019-11-15', 'M', 'External delivery', 'Interno', 'Cat', 'QA Siamese'),
    ('QA-ANI-004', 'Pipocas QA', date '2022-08-01', 'F', 'Street', 'Interno', 'Bird', 'QA Canary'),
    ('QA-ANI-005', 'Rex QA', date '2018-03-12', 'M', 'Abandonment', 'Interno', 'Dog', 'QA German Shepherd')
  ) as v(reg, nam, bir, gen, ori, sta, spc, bre)
  join species s on s.nam_spc = v.spc
  join breed b on b.nam_bre = v.bre
 where not exists (select 1 from animal a where a.reg_id_ani = v.reg);

do $$
declare
    v_cli_active int := qa_client_active_id();
    v_cli_sec int := qa_client_secondary_id();
    v_reg int := qa_registrar_emp_id();
begin
    if v_cli_active is null or v_reg is null then
        raise exception 'QA Mod2 fixture: missing client/registrar contracts.';
    end if;

    insert into ownership (id_cli, id_ani, id_emp, sta_dat_own, end_dat_own, mot_own)
    select v_cli_active, a.id_ani, v_reg, date '2026-01-10', null, 'QA adoption for Mod4 scheduling'
      from animal a where a.reg_id_ani = 'QA-ANI-003'
       and not exists (
           select 1 from ownership o
            where o.id_ani = a.id_ani and o.end_dat_own is null
       );

    update animal set sta_ani = 'Adotado' where reg_id_ani = 'QA-ANI-003';

    if v_cli_sec is not null then
        insert into ownership (id_cli, id_ani, id_emp, sta_dat_own, end_dat_own, mot_own)
        select v_cli_sec, a.id_ani, v_reg, date '2026-02-01', date '2026-03-01', 'QA temporary foster'
          from animal a where a.reg_id_ani = 'QA-ANI-002'
           and not exists (select 1 from ownership o where o.id_ani = a.id_ani);
    end if;
end;
$$;

insert into delivery (reg_dat_del, res_dat_del, res_loc_del, cli_sta_del, id_ext_ent, id_ani)
select current_timestamp, current_timestamp - interval '2 hours', 'Lower Street, Braga', 'Malnourished', e.id_ext_ent, a.id_ani
  from animal a
  join external_entity e on e.ema_ext_ent = 'shelter@qa.miacaomigo.pt'
 where a.reg_id_ani = 'QA-ANI-004'
   and not exists (select 1 from delivery d where d.id_ani = a.id_ani);

insert into delivery (reg_dat_del, res_dat_del, res_loc_del, cli_sta_del, id_ext_ent, id_ani)
select current_timestamp - interval '1 day', current_timestamp - interval '25 hours', 'City Park', 'Healthy', e.id_ext_ent, a.id_ani
  from animal a
  join external_entity e on e.ema_ext_ent = 'welfare@qa.miacaomigo.pt'
 where a.reg_id_ani = 'QA-ANI-001'
   and not exists (select 1 from delivery d where d.id_ani = a.id_ani and d.res_loc_del = 'City Park');

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
