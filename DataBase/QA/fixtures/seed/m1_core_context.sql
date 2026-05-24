-- =========================================================================
-- QA FIXTURE — MODULE 1 — CORE CONTEXT
-- =========================================================================
-- TYPE:
--   Fixture dataset (deterministic QA context)
--
-- PURPOSE:
--   Provides stable QA employees, veterinarians, clients,
--   authentication sessions, schedules and absence seeds
--   required by integrity, stress and manual validation.
--
-- REQUIRES:
--   Bootstrap init_qa (Master only)
--
-- PROVIDES:
--   - QA inactive employee
--   - QA active clients
--   - QA registrar employee
--   - QA veterinarian + expert specialties
--   - QA clockable employee
--   - QA absence overlap employee
--   - Active login session fixture (12@)
--   - Schedule seed for overlap/exclusion validation
--
-- CONTRACTS:
--   contracts/01_QA_Functions.sql
--
-- GUARANTEES:
--   - Deterministic semantic lookup targets
--   - Idempotent reruns
--   - Stable contract-based identifiers
--   - Isolation from Bootstrap/Demo datasets
--
-- ISOLATION STRATEGY:
--   QA-only emails, NIFs, OMV numbers and reg_id prefixes

--   are used to avoid collisions with production/demo data
--   and allow scoped cleanup/reset operations.
--
-- CLEANUP:
--   fixtures/reset/global_qa_state.sql
-- =========================================================================



-- -------------------------------------------------------------------------
-- QA inactive employee
-- -------------------------------------------------------------------------
-- Covers inactive-account authentication scenarios.
-- Reuses existing user_account by email for idempotent reruns.
-- Uses QA-only identifiers for isolated cleanup.
-- -------------------------------------------------------------------------
do $$
declare
    v_usr int;
begin
    select u.id_usr into v_usr
      from user_account u
     where u.ema_usr = 'qa.manual.inactive@qa.miacaomigo.pt';

    if v_usr is null then
        insert into user_account (nam_usr, add_usr, pos_usr, nif_usr, pho_usr, ema_usr)
        values (
            'QA Manual Inactive Employee',
            'Rua QA Manual 1, Braga',
            '4700-901',
            '619000901',
            '+351910390901',
            'qa.manual.inactive@qa.miacaomigo.pt'
        )
        returning id_usr into v_usr;
    end if;

    if not exists (
        select 1 from employee where ema_emp = 'qa-manual-inactive@miacaomigo.pt'
    ) then
        insert into employee (
            id_usr, reg_dat_emp, dea_dat_emp, aut_ina_emp, aut_reg_emp,
            pho_emp, ema_emp, pas_emp
        )
        values (
            v_usr,
            current_timestamp - interval '2 years',
            current_timestamp - interval '1 year',
            1,
            1,
            '+351253390901',
            'qa-manual-inactive@miacaomigo.pt',
            '$2b$12$cstress_u12_active'
        );
    end if;
end;
$$;

-- -------------------------------------------------------------------------
-- Additional QA specialties
-- -------------------------------------------------------------------------
-- Extends Bootstrap specialty baseline for expert, mismatch
-- and appointment validation scenarios.
-- Inserts only missing specialties (idempotent).
-- -------------------------------------------------------------------------
insert into specialty (nam_spe, des_spe)
select v.nam, v.des
  from (values
    ('medicina interna', 'internal medicine QA'),
    ('cirurgia de tegumentos', 'dermatologic surgery QA'),
    ('ortopedia', 'orthopedics QA'),
    ('dermatologia', 'dermatology QA'),
    ('anestesiologia', 'anesthesiology QA'),
    ('imagiologia', 'imaging QA'),
    ('medicina felina', 'feline medicine QA')
  ) as v(nam, des)
where not exists (select 1 from specialty s where s.nam_spe = v.nam);



-- -------------------------------------------------------------------------
-- QA clients
-- -------------------------------------------------------------------------
-- Deterministic QA portal clients used by authentication,
-- ownership and appointment validation scenarios.
-- Uses stable emails/contracts and idempotent inserts.
-- -------------------------------------------------------------------------
insert into user_account (nam_usr, add_usr, pos_usr, nif_usr, pho_usr, ema_usr)
select v.nam, v.add, v.pos, v.nif, v.pho, v.ema
  from (values
    ('Goncalo Miguel Pratas QA', 'Rua da Se 12, Faro', '8000-078', '610000023', '+351910300023', 'goncalo.pratas.cstress@gmail.com'),
    ('Goncalo Filipe Machado QA', 'Rua de Santa Justa 14, Lisboa', '1100-483', '610000034', '+351910300034', 'goncalo.machado.cstress@gmail.com')
  ) as v(nam, add, pos, nif, pho, ema)
 where not exists (select 1 from user_account u where u.ema_usr = v.ema);

insert into client (id_usr, pas_cli, reg_dat_cli, ina_dat_cli)
select u.id_usr, v.pas, current_timestamp - interval '2 years', null
  from (values
    ('goncalo.pratas.cstress@gmail.com', '$2b$12$cstress_cli_pure_u023'),
    ('goncalo.machado.cstress@gmail.com', '$2b$12$cstress_cli_pure_u034')
  ) as v(ema, pas)
  join user_account u on u.ema_usr = v.ema
 where not exists (select 1 from client c where c.id_usr = u.id_usr);



-- -------------------------------------------------------------------------
-- QA registrar employee
-- -------------------------------------------------------------------------
-- Deterministic registrar employee used for authentication,
-- ownership and employee-role validation scenarios.
-- Reuses existing user/account rows for idempotent reruns.
-- -------------------------------------------------------------------------
do $$
declare
    v_usr int;
    v_emp int;
begin
    select u.id_usr into v_usr
      from user_account u
     where u.ema_usr = 'claudia.faria.cstress@icloud.com';

    if v_usr is null then
        insert into user_account (nam_usr, add_usr, pos_usr, nif_usr, pho_usr, ema_usr)
        values (
            'QA Registrar Spell',
            'Rua Goncalo Sampaio 412, Porto',
            '4150-564',
            '610000020',
            '+351910300020',
            'claudia.faria.cstress@icloud.com'
        )
        returning id_usr into v_usr;
    end if;

    select e.id_emp into v_emp
      from employee e
     where e.ema_emp = '20@miacaomigo.pt';

    if v_emp is null then
        insert into employee (id_usr, reg_dat_emp, aut_reg_emp, pho_emp, pho_emg, ema_emp, pas_emp)
        values (
            v_usr,
            current_timestamp - interval '4 years',
            1,
            '+351253440020',
            '+351912340020',
            '20@miacaomigo.pt',
            '$2b$12$cstress_registrar_emp001'
        )
        returning id_emp into v_emp;
    end if;

    insert into occupies (id_emp, id_pro)
    select v_emp, 1
     where not exists (
         select 1 from occupies o where o.id_emp = v_emp and o.id_pro = 1
     );
end;
$$;

-- -------------------------------------------------------------------------
-- Bootstrap admin schedule seed
-- -------------------------------------------------------------------------
-- Provides deterministic schedule context for schedule
-- exclusion and overlap integrity validation.
-- Inserts only missing weekly schedule rows.
-- -------------------------------------------------------------------------
insert into schedule (id_emp, day_wee_sch, sta_tim_sch, fin_hou_sch)
select e.id_emp, 1, '08:00', '18:00'
  from employee e
 where e.ema_emp = '1@miacaomigo.pt'
   and not exists (
       select 1 from schedule s
        where s.id_emp = e.id_emp and s.day_wee_sch = 1
   );



-- -------------------------------------------------------------------------
-- QA primary veterinarian
-- -------------------------------------------------------------------------
-- Deterministic veterinarian fixture used for appointment,
-- specialty, expert and integrity validation scenarios.
-- Guarantees stable OMV-based contract resolution and
-- expert specialty assignments for QA workflows.
-- Reuses existing rows for idempotent reruns.
-- -------------------------------------------------------------------------
do $$
declare
    v_usr int;
    v_emp int;
    v_spe1 int;
    v_spe7 int;
begin

    -- Resolve QA specialties used for expert assignments
    select id_spe into v_spe1
      from specialty
     where nam_spe = 'medicina interna'
       and des_spe = 'internal medicine QA'
     limit 1;

    select id_spe into v_spe7
      from specialty
     where nam_spe = 'medicina felina'
       and des_spe = 'feline medicine QA'
     limit 1;

    -- Resolve existing QA user account by stable email
    select u.id_usr into v_usr
      from user_account u
     where u.ema_usr = 'bruno.matos.cstress@outlook.pt';

    -- Create QA veterinarian user if missing
    if v_usr is null then
        insert into user_account (nam_usr, add_usr, pos_usr, nif_usr, pho_usr, ema_usr)
        values (
            'Bruno Filipe Matos QA Vet',
            'Rua da Junqueira 55, Coimbra',
            '3000-341',
            '610000004',
            '+351910300004',
            'bruno.matos.cstress@outlook.pt'
        )
        returning id_usr into v_usr;
    end if;

    -- Resolve veterinarian through deterministic OMV contract
    select v.id_emp into v_emp
      from veterinarian v
     where v.num_omv_vet = 'OMV-QA-PRIMARY';

    if v_emp is null then

        -- Reuse active QA employee email if already present
        select e.id_emp into v_emp
          from employee e
         where e.ema_emp = '8@miacaomigo.pt'
           and e.dea_dat_emp is null
         limit 1;

        -- Reuse latest active employee linked to QA user
        if v_emp is null then
            select e.id_emp into v_emp
              from employee e
             where e.id_usr = v_usr
               and e.dea_dat_emp is null
             order by e.reg_dat_emp desc
             limit 1;
        end if;

        -- Create QA employee spell if none exists
        if v_emp is null then
            insert into employee (id_usr, reg_dat_emp, aut_reg_emp, pho_emp, pho_emg, ema_emp, pas_emp)
            values (
                v_usr,
                current_timestamp - interval '3 years',
                1,
                '+351253444001',
                '+351912344001',
                '8@miacaomigo.pt',
                '$2b$12$cstress_u04_vet_track'
            )
            returning id_emp into v_emp;
        end if;

        -- Create veterinarian role using stable OMV identifier
        insert into veterinarian (id_emp, num_omv_vet)
        select v_emp, 'OMV-QA-PRIMARY'
         where not exists (
             select 1 from veterinarian v where v.num_omv_vet = 'OMV-QA-PRIMARY'
         );

        -- Refresh veterinarian employee id after role creation
        select v.id_emp into v_emp
          from veterinarian v
         where v.num_omv_vet = 'OMV-QA-PRIMARY';
    end if;

    -- Ensure veterinarian occupies veterinarian profession
    insert into occupies (id_emp, id_pro)
    select v_emp, 2
     where not exists (
         select 1 from occupies o where o.id_emp = v_emp and o.id_pro = 2
     );

    -- Ensure internal medicine expert assignment exists
    if v_spe1 is not null then
        insert into expert (id_emp, id_spe)
        select v_emp, v_spe1
         where not exists (
             select 1 from expert ex where ex.id_emp = v_emp and ex.id_spe = v_spe1
         );
    end if;

    -- Ensure feline medicine expert assignment exists
    if v_spe7 is not null then
        insert into expert (id_emp, id_spe)
        select v_emp, v_spe7
         where not exists (
             select 1 from expert ex where ex.id_emp = v_emp and ex.id_spe = v_spe7
         );
    end if;

end;
$$;

-- -------------------------------------------------------------------------
-- QA clockable employee
-- -------------------------------------------------------------------------
-- Deterministic employee fixture used for clock-in,
-- concurrency and active-session integrity validation.
-- Guarantees a single active clock_in row for stress and
-- overlap validation scenarios.
-- Reuses existing rows for idempotent reruns.
-- -------------------------------------------------------------------------
do $$
declare
    v_usr int;
    v_emp int;
begin

    -- Resolve existing QA user account by stable email
    select u.id_usr into v_usr
      from user_account u
     where u.ema_usr = 'qa.clockable.user@gmail.com';

    -- Create QA user account if missing
    if v_usr is null then
        insert into user_account (nam_usr, add_usr, pos_usr, nif_usr, pho_usr, ema_usr)
        values (
            'QA Clockable Employee',
            'Avenida Central 100, Braga',
            '4700-100',
            '610000099',
            '+351910300099',
            'qa.clockable.user@gmail.com'
        )
        returning id_usr into v_usr;
    end if;

    -- Resolve QA employee by deterministic QA email
    select e.id_emp into v_emp
      from employee e
     where e.ema_emp = 'qa.clockable@miacaomigo.pt';

    if v_emp is null then

        -- Create QA employee spell if missing
        insert into employee (id_usr, reg_dat_emp, aut_reg_emp, pho_emp, ema_emp, pas_emp)
        values (
            v_usr,
            current_timestamp - interval '1 year',
            1,
            '+351253000099',
            'qa.clockable@miacaomigo.pt',
            '$2b$12$cstress_u12_active'
        )
        returning id_emp into v_emp;

    else

        -- Reactivate employee if previously deactivated
        update employee
           set dea_dat_emp = null
         where id_emp = v_emp
           and dea_dat_emp is not null;

    end if;

    -- Close previous open clock_in rows for deterministic baseline
    update clock_in
       set end_dat_clk = current_timestamp
     where id_emp = v_emp
       and end_dat_clk is null;

    -- Create single active clock_in session
    insert into clock_in (id_emp, sta_dat_clk)
    select v_emp, current_timestamp - interval '75 minutes'
     where not exists (
         select 1 from clock_in c
          where c.id_emp = v_emp and c.end_dat_clk is null
     );

end;
$$;

-- -------------------------------------------------------------------------
-- QA absence overlap employee
-- -------------------------------------------------------------------------
-- Deterministic veterinarian fixture used for absence,
-- overlap and appointment integrity validation scenarios.
-- Guarantees a stable pending absence window for conflict
-- and scheduling validation workflows.
-- Reuses existing rows for idempotent reruns.
-- -------------------------------------------------------------------------
do $$
declare
    v_usr int;
    v_emp int;
begin

    -- Resolve existing QA user account by stable email
    select u.id_usr into v_usr
      from user_account u
     where u.ema_usr = 'filipe.castro.cstress@outlook.pt';

    -- Create QA user account if missing
    if v_usr is null then
        insert into user_account (nam_usr, add_usr, pos_usr, nif_usr, pho_usr, ema_usr)
        values (
            'QA Absence Overlap Vet',
            'Rua Ferreira Borges 10, Aveiro',
            '3800-041',
            '610000021',
            '+351910300021',
            'filipe.castro.cstress@outlook.pt'
        )
        returning id_usr into v_usr;
    end if;

    -- Resolve QA employee by deterministic QA email
    select e.id_emp into v_emp
      from employee e
     where e.ema_emp = '21@miacaomigo.pt';

    if v_emp is null then

        -- Create QA veterinarian employee spell
        insert into employee (id_usr, reg_dat_emp, aut_reg_emp, pho_emp, ema_emp, pas_emp)
        values (
            v_usr,
            current_timestamp - interval '3 years',
            1,
            '+351253461001',
            '21@miacaomigo.pt',
            '$2b$12$cstress_u21_vet'
        )
        returning id_emp into v_emp;

        -- Ensure veterinarian profession assignment exists
        insert into occupies (id_emp, id_pro)
        select v_emp, 2
         where not exists (
             select 1 from occupies o where o.id_emp = v_emp and o.id_pro = 2
         );

        -- Ensure veterinarian role exists
        insert into veterinarian (id_emp, num_omv_vet)
        select v_emp, 'OMV-PT-2023-CR-03319'
         where not exists (
             select 1 from veterinarian v where v.num_omv_vet = 'OMV-PT-2023-CR-03319'
         );
    end if;

    -- Reset previous QA absence overlap seed
    delete from absence
     where id_emp = v_emp
       and mot_abs like 'qa fixture%';

    -- Create deterministic pending absence overlap window
    insert into absence (id_emp, sta_dat_tim_abs, end_dat_tim_abs, mot_abs, sta_abs, cre_tim_abs)
    select
        v_emp,
        current_timestamp + interval '15 days',
        current_timestamp + interval '16 days',
        'qa fixture pending absence overlap seed',
        'pending',
        current_timestamp - interval '3 days'
     where not exists (
         select 1 from absence a
          where a.id_emp = v_emp
            and a.mot_abs = 'qa fixture pending absence overlap seed'
            and a.sta_abs = 'pending'
     );

end;
$$;

-- -------------------------------------------------------------------------
-- QA login session employee
-- -------------------------------------------------------------------------
-- Deterministic employee fixture used for authentication,
-- session and concurrency validation scenarios.
-- Guarantees a single active login session for duplicate
-- login blocking and session lifecycle validation.
-- Reuses existing rows for idempotent reruns.
-- -------------------------------------------------------------------------
do $$
declare
    v_usr int;
    v_emp int;
begin

    -- Resolve existing QA user account by stable email
    select u.id_usr into v_usr
      from user_account u
     where u.ema_usr = 'duarte.ramos.cstress@gmail.com';

    -- Create QA user account if missing
    if v_usr is null then
        insert into user_account (nam_usr, add_usr, pos_usr, nif_usr, pho_usr, ema_usr)
        values (
            'QA Login Session Employee',
            'Largo do Toural 14, Guimaraes',
            '4810-431',
            '610000012',
            '+351910300012',
            'duarte.ramos.cstress@gmail.com'
        )
        returning id_usr into v_usr;
    end if;

    -- Resolve QA employee by deterministic QA email
    select e.id_emp into v_emp
      from employee e
     where e.ema_emp = '12@miacaomigo.pt';

    -- Create QA employee spell if missing
    if v_emp is null then
        insert into employee (id_usr, reg_dat_emp, aut_reg_emp, pho_emp, ema_emp, pas_emp)
        values (
            v_usr,
            current_timestamp - interval '8 months',
            1,
            '+351253452002',
            '12@miacaomigo.pt',
            '$2b$12$cstress_u12_active'
        )
        returning id_emp into v_emp;
    end if;

    -- Resolve effective user linked to QA employee
    select u.id_usr into v_usr
      from employee e
      join user_account u on u.id_usr = e.id_usr
     where e.id_emp = v_emp;

    -- Reset previous active login sessions
    delete from login_record
     where ema_log = '12@miacaomigo.pt'
       and sou_tim_log is null;

    -- Create deterministic active login session
    insert into login_record (sig_tim_log, sou_tim_log, suc_log, ip_add_log, ema_log, id_usr)
    select
        current_timestamp - interval '90 minutes',
        null,
        true,
        '192.168.60.77'::inet,
        '12@miacaomigo.pt',
        v_usr
     where not exists (
         select 1 from login_record lr
          where lr.ema_log = '12@miacaomigo.pt'
            and lr.sou_tim_log is null
            and lr.suc_log = true
     );

end;
$$;
