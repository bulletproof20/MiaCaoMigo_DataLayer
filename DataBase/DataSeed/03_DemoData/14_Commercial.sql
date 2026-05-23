-- =========================================================
-- NARRATIVE DEMO — 14 COMMERCIAL
-- Story: Navarro sales, return, supplier receive, overdue invoice
-- =========================================================

set timezone to 'Europe/Lisbon';

-- Supplier PO (pending then received 19 May)
insert into purchase (id_pur, pur_dat_pur, sta_pur, id_emp, ord_num_pur, pay_met_pur)
overriding system value
values
    (1, '2026-05-08 10:00:00+01', 'received', 4, 'PO-NVS-2026-0142', 'bank transfer'),
    (2, '2026-05-17 09:00:00+01', 'pending', 4, 'PO-NVS-2026-0158', 'bank transfer');

insert into purchase_line (id_pur, id_pro, bat_pln, qty_pln, uni_cos_pln) values
    (1, 3, 'LOT-AMX-2026-C1', 40, 7.20),
    (1, 6, 'LOT-GLO-2026-F1', 30, 4.10),
    (2, 1, 'LOT-NUT-2026-A3', 50, 28.50);

do $body$
begin
    call sp_receive_purchase(2);
end;
$body$;

insert into employee_purchase (id_emp, id_pur) values (4, 1), (4, 2);

-- Invoices
insert into invoice (id_inv, dat_inv, sta_inv, bod_inv, id_app)
overriding system value
values
    (1, '2026-05-10 11:30:00+01', 'paid', 'Gonçalo — food and toys', null),
    (2, '2026-05-09 16:00:00+01', 'paid', 'Marta — kibble and lead', null),
    (3, '2026-05-08 12:00:00+01', 'paid', 'Ana — adoption starter kit', null),
    (4, '2026-05-18 10:15:00+01', 'paid', 'Gonçalo — dermatology diet', null),
    (5, '2026-05-14 17:00:00+01', 'pending', 'Marta — post visit pharmacy', null),
    (6, '2026-05-22 12:45:00+01', 'paid', 'Tico consultation products', null),
    (7, '2026-05-14 16:30:00+01', 'paid', 'Felix consultation and meds', null);

-- Mark Marta pending as overdue (unpaid since 14 May; narrative 5 Jun)
update invoice set sta_inv = 'overdue' where id_inv = 5;

insert into purchase (id_pur, pur_dat_pur, sta_pur, id_inv, id_cli, id_emp, pay_met_pur)
overriding system value
values
    (3, '2026-05-10 11:30:00+01', 'received', 1, 1, 4, 'card'),
    (4, '2026-05-09 16:00:00+01', 'received', 2, 2, 4, 'card'),
    (5, '2026-05-08 12:00:00+01', 'received', 3, 3, 4, 'card'),
    (6, '2026-05-18 10:15:00+01', 'received', 4, 1, 4, 'card'),
    (7, '2026-05-14 17:00:00+01', 'received', 5, 2, 4, 'card'),
    (8, '2026-05-22 12:45:00+01', 'received', 6, 5, 4, 'card'),
    (9, '2026-05-14 16:30:00+01', 'received', 7, 2, 4, 'card');

insert into invoice_line (id_inv, id_pro, qty_inv_lin, uni_pri_inv_lin, iva_inv_lin) values
    (1, 1, 1, 42.90, 23.00),
    (1, 8, 2, 6.50, 23.00),
    (2, 1, 1, 42.90, 23.00),
    (2, 7, 1, 11.00, 23.00),
    (2, 8, 1, 6.50, 23.00),
    (3, 2, 2, 18.50, 23.00),
    (3, 7, 1, 11.00, 23.00),
    (4, 9, 1, 54.00, 23.00),
    (5, 4, 1, 24.80, 6.00),
    (6, 3, 1, 12.40, 6.00),
    (6, 2, 1, 18.50, 23.00),
    (7, 4, 1, 24.80, 6.00);

-- 18 May return — Marta defective toy (invoice_line 5 on inv 2)
insert into "return" (id_ret, mot_ret, id_inv_lin, qty_ret)
overriding system value
values (1, 'defective rubber toy batch', 5, 1);

insert into return_product (id_ret, id_pro, qty_ret_pro) values (1, 8, 1);
insert into employee_return (id_emp, id_ret) values (4, 1);

select setval(pg_get_serial_sequence('purchase', 'id_pur'), (select max(id_pur) from purchase));
select setval(pg_get_serial_sequence('invoice', 'id_inv'), (select max(id_inv) from invoice));
select setval(pg_get_serial_sequence('invoice_line', 'id_inv_lin'), (select max(id_inv_lin) from invoice_line));
select setval(pg_get_serial_sequence('return', 'id_ret'), (select max(id_ret) from return));
