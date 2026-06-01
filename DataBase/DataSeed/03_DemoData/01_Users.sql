-- =========================================================
-- NARRATIVE DEMO — 01 USERS
-- Story: cast registration + Bernardo archive (Mar 2026)
-- =========================================================
-- id_usr 2 Ivo | 3 Tiago | 4 Navarro | 5 Marcelo | 6 Isabel | 7 Bernardo
-- id_usr 8 Gonçalo | 9 Marta | 10 Ana | 11 Pedro (clientes)
-- id_usr 12 Sofia | 13 Ricardo | 14 Miguel (RH demo — cargos em falta)
-- =========================================================

set timezone to 'Europe/Lisbon';

insert into user_account (id_usr, nam_usr, add_usr, pos_usr, nif_usr, pho_usr, ema_usr)
overriding system value
values
    (2, 'Ivo Sá', 'Campus do IPCA, Vila Frescaínha S. Martinho', '4750-810', '000000001', '+351911911911', 'ivo.dev@gmail.com'),
    (3, 'Tiago Mendes', 'Campus do IPCA, Vila Frescaínha S. Martinho', '4750-810', '000000002', '+351922922922', 'tiago.mendes.dev@gmail.com'),
    (4, 'João Navarro', 'Campus do IPCA, Vila Frescaínha S. Martinho', '4750-810', '000000003', '+351933933933', 'joao.navarro.dev@gmail.com'),
    (5, 'João Marcelo', 'Campus do IPCA, Vila Frescaínha S. Martinho', '4750-810', '000000004', '+351944944944', 'joao.marcelo.dev@gmail.com'),
    (6, 'Isabel Carvalho', 'Campus do IPCA, Vila Frescaínha S. Martinho', '4750-810', '000000005', '+351955955955', 'isabel.carvalho.dev@gmail.com'),
    (7, 'Bernardo Silva', 'Rua de São Marcos 18, Braga', '4700-294', '000000007', '+351912340299', 'bernardo.silva.dev@gmail.com'),
    (8, 'Gonçalo Rego', 'Campus do IPCA, Vila Frescaínha S. Martinho', '4750-810', '000000006', '+351966966966', 'goncalo.rego.dev@gmail.com'),
    (9, 'Marta Ribeiro', 'Rua do Raio 152, Braga', '4700-325', '000000008', '+351912340308', 'marta.ribeiro.dev@gmail.com'),
    (10, 'Ana Lourenço', 'Avenida Central 102, Guimarães', '4800-201', '000000009', '+351912340309', 'ana.lourenco.dev@gmail.com'),
    (11, 'Pedro Costa', 'Urbanização Bouça do Monte 45, Braga', '4700-051', '000000010', '+351912340310', 'pedro.costa.dev@gmail.com'),
    (12, 'Sofia Mendes', 'Campus do IPCA, Vila Frescaínha S. Martinho', '4750-810', '000000011', '+351977977977', 'sofia.mendes.dev@gmail.com'),
    (13, 'Ricardo Almeida', 'Campus do IPCA, Vila Frescaínha S. Martinho', '4750-810', '000000012', '+351988988988', 'ricardo.almeida.dev@gmail.com'),
    (14, 'Miguel Santos', 'Campus do IPCA, Vila Frescaínha S. Martinho', '4750-810', '000000013', '+351999999999', 'miguel.santos.dev@gmail.com');

update setup set lan_set = 'en-us', the_set = 'dark' where id_usr = 2;
update setup set lan_set = 'pt-pt', the_set = 'dark' where id_usr = 3;
update setup set lan_set = 'en-us', the_set = 'light' where id_usr = 4;
update setup set lan_set = 'en-us', the_set = 'dark' where id_usr = 5;
update setup set lan_set = 'pt-pt', the_set = 'light' where id_usr = 6;
update setup set lan_set = 'pt-pt', the_set = 'light' where id_usr = 7;
update setup set lan_set = 'pt-pt', the_set = 'dark' where id_usr = 8;
update setup set lan_set = 'pt-pt', the_set = 'light' where id_usr = 9;
update setup set lan_set = 'pt-pt', the_set = 'light' where id_usr = 10;
update setup set lan_set = 'pt-pt', the_set = 'light' where id_usr = 11;
update setup set lan_set = 'pt-pt', the_set = 'light' where id_usr = 12;
update setup set lan_set = 'pt-pt', the_set = 'dark' where id_usr = 13;
update setup set lan_set = 'pt-pt', the_set = 'light' where id_usr = 14;

select setval(pg_get_serial_sequence('user_account', 'id_usr'),
    (select coalesce(max(id_usr), 1) from user_account));
