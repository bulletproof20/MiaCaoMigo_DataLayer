select * from user_account u inner join employee e on u.id_usr = e.id_usr


select *
from user_account u 
inner join client c on u.id_usr = c.id_usr
inner join login_record l on u.id_usr = l.id_usr


select * from employee e
inner join occupies o on e.id_usr=o.id_emp
inner join profile p on o.id_pro = p.id_pro 


select e.*, u.nam_usr
from user_account u
inner join employee e on u.id_usr = e.id_usr

-- inner join occupies o on e.id_emp = o.id_emp
-- inner join client c on c.id_usr = u.id_usr


insert into login_record(sou_tim_log)
values (current_timestamp)

-- Atualiza a password hash para o funcionário associado ao user_account com id_usr = 1
UPDATE employee
SET pas_emp = '15e2b0d3c33891ebb0f1ef609ec419420c20e320ce94c65fbc8c3312448eb225'
WHERE id_usr = 1;

    select * from animal

-- =========================================================
-- Funcionários de teste para validar dashboards/permissões
-- Password comum: 123456789
-- Hash: 15e2b0d3c33891ebb0f1ef609ec419420c20e320ce94c65fbc8c3312448eb225
-- =========================================================


-- teste.admin@miacaomigo.pt → perfil administrador
-- teste.vet@miacaomigo.pt → veterinarian, OMV, perfil veterinario
-- teste.assistente@miacaomigo.pt → assistant, perfil animal manager
-- teste.rececao@miacaomigo.pt → assistant, perfil public support
-- teste.comercial@miacaomigo.pt → assistant, perfil commercial manager



-- Limpeza para permitir reexecutar este bloco sem colisões.
delete from user_account
where ema_usr in (
    'teste.staff.admin@example.com',
    'teste.staff.vet@example.com',
    'teste.staff.assistente@example.com',
    'teste.staff.rececao@example.com',
    'teste.staff.comercial@example.com'
);

-- ADMIN / DIREÇÃO: vê praticamente tudo.
with new_user as (
    insert into user_account (nam_usr, add_usr, pos_usr, nif_usr, pho_usr, ema_usr)
    values (
        'Teste Admin Direcao',
        'Rua Teste Staff 1',
        '4750-001',
        '599888701',
        '+351910000001',
        'teste.staff.admin@example.com'
    )
    returning id_usr
),
new_employee as (
    insert into employee (id_usr, aut_reg_emp, pho_emp, pho_emg, ema_emp, pas_emp)
    select
        id_usr,
        1,
        '+351911111101',
        '+351922222201',
        'teste.admin@miacaomigo.pt',
        '15e2b0d3c33891ebb0f1ef609ec419420c20e320ce94c65fbc8c3312448eb225'
    from new_user
    returning id_emp
)
insert into occupies (id_emp, id_pro)
select id_emp, 1
from new_employee;

-- VETERINÁRIO: foca-se na própria agenda e gestão clínica.
with new_user as (
    insert into user_account (nam_usr, add_usr, pos_usr, nif_usr, pho_usr, ema_usr)
    values (
        'Teste Veterinario',
        'Rua Teste Staff 2',
        '4750-002',
        '599888702',
        '+351910000002',
        'teste.staff.vet@example.com'
    )
    returning id_usr
),
new_employee as (
    insert into employee (id_usr, aut_reg_emp, pho_emp, pho_emg, ema_emp, pas_emp)
    select
        id_usr,
        1,
        '+351911111102',
        '+351922222202',
        'teste.vet@miacaomigo.pt',
        '15e2b0d3c33891ebb0f1ef609ec419420c20e320ce94c65fbc8c3312448eb225'
    from new_user
    returning id_emp
),
vet as (
    insert into veterinarian (id_emp, num_omv_vet)
    select id_emp, 'OMV-TEST-001'
    from new_employee
)
insert into occupies (id_emp, id_pro)
select id_emp, 2
from new_employee;

-- ASSISTENTE / ENFERMEIRO: apoio clínico/animal care.
with new_user as (
    insert into user_account (nam_usr, add_usr, pos_usr, nif_usr, pho_usr, ema_usr)
    values (
        'Teste Assistente Clinico',
        'Rua Teste Staff 3',
        '4750-003',
        '599888703',
        '+351910000003',
        'teste.staff.assistente@example.com'
    )
    returning id_usr
),
new_employee as (
    insert into employee (id_usr, aut_reg_emp, pho_emp, pho_emg, ema_emp, pas_emp)
    select
        id_usr,
        1,
        '+351911111103',
        '+351922222203',
        'teste.assistente@miacaomigo.pt',
        '15e2b0d3c33891ebb0f1ef609ec419420c20e320ce94c65fbc8c3312448eb225'
    from new_user
    returning id_emp
),
assistant_role as (
    insert into assistant (id_emp, fun_ass)
    select id_emp, 'Animal care and clinical support'
    from new_employee
)
insert into occupies (id_emp, id_pro)
select id_emp, 5
from new_employee;

-- RECEÇÃO / SECRETARIA: marcações e apoio ao público.
with new_user as (
    insert into user_account (nam_usr, add_usr, pos_usr, nif_usr, pho_usr, ema_usr)
    values (
        'Teste Rececao',
        'Rua Teste Staff 4',
        '4750-004',
        '599888704',
        '+351910000004',
        'teste.staff.rececao@example.com'
    )
    returning id_usr
),
new_employee as (
    insert into employee (id_usr, aut_reg_emp, pho_emp, pho_emg, ema_emp, pas_emp)
    select
        id_usr,
        1,
        '+351911111104',
        '+351922222204',
        'teste.rececao@miacaomigo.pt',
        '15e2b0d3c33891ebb0f1ef609ec419420c20e320ce94c65fbc8c3312448eb225'
    from new_user
    returning id_emp
),
assistant_role as (
    insert into assistant (id_emp, fun_ass)
    select id_emp, 'Public desk and customer intake'
    from new_employee
)
insert into occupies (id_emp, id_pro)
select id_emp, 8
from new_employee;

-- GESTOR COMERCIAL: stock/faturação.
with new_user as (
    insert into user_account (nam_usr, add_usr, pos_usr, nif_usr, pho_usr, ema_usr)
    values (
        'Teste Gestor Comercial',
        'Rua Teste Staff 5',
        '4750-005',
        '599888705',
        '+351910000005',
        'teste.staff.comercial@example.com'
    )
    returning id_usr
),
new_employee as (
    insert into employee (id_usr, aut_reg_emp, pho_emp, pho_emg, ema_emp, pas_emp)
    select
        id_usr,
        1,
        '+351911111105',
        '+351922222205',
        'teste.comercial@miacaomigo.pt',
        '15e2b0d3c33891ebb0f1ef609ec419420c20e320ce94c65fbc8c3312448eb225'
    from new_user
    returning id_emp
),
assistant_role as (
    insert into assistant (id_emp, fun_ass)
    select id_emp, 'Commercial desk and inventory'
    from new_employee
)
insert into occupies (id_emp, id_pro)
select id_emp, 6
from new_employee;

select
    u.nam_usr,
    e.ema_emp as login_email,
    coalesce(v.num_omv_vet, a.fun_ass, 'admin') as funcao,
    p.nam_pro as perfil
from employee e
inner join user_account u on u.id_usr = e.id_usr
left join veterinarian v on v.id_emp = e.id_emp
left join assistant a on a.id_emp = e.id_emp
left join occupies o on o.id_emp = e.id_emp
left join profile p on p.id_pro = o.id_pro
where e.ema_emp like 'teste.%@miacaomigo.pt'
order by e.ema_emp;