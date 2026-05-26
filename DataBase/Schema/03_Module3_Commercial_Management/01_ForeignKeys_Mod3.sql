--=========================================================
-- MODULE 3: FOREIGN KEYS (COMMERCIAL MANAGEMENT)
--=========================================================
--
-- Deferred and cross-module FKs for commercial entities live here
-- so that all tables (Modules 1–4) exist before linking.
--
-- Only required (non-optional) relationships are enforced. Nullable
-- cross-references (invoice on purchase, client on purchase, stock on
-- purchase_line, invoice_line on return, product snapshot pointers)
-- are application-maintained without FK constraints.
--
--=========================================================

-- product → family
alter table product drop constraint if exists fk_product_family;
alter table product
    add constraint fk_product_family
        foreign key (id_fam)
        references family(id_fam)
        on delete restrict;

-- stock → product
alter table stock drop constraint if exists fk_stock_product;
alter table stock
    add constraint fk_stock_product
        foreign key (id_pro)
        references product(id_pro)
        on delete cascade;

-- purchase → employee (required on every purchase in domain model)
alter table purchase drop constraint if exists fk_purchase_invoice;
alter table purchase drop constraint if exists fk_purchase_client;
alter table purchase drop constraint if exists fk_purchase_employee;
alter table purchase
    add constraint fk_purchase_employee
        foreign key (id_emp)
        references employee(id_emp)
        on delete set null;

-- purchase_line → purchase, product
alter table purchase_line drop constraint if exists fk_purchase_line_purchase;
alter table purchase_line
    add constraint fk_purchase_line_purchase
        foreign key (id_pur)
        references purchase(id_pur)
        on delete cascade;

alter table purchase_line drop constraint if exists fk_purchase_line_product;
alter table purchase_line
    add constraint fk_purchase_line_product
        foreign key (id_pro)
        references product(id_pro)
        on delete restrict;

alter table purchase_line drop constraint if exists fk_purchase_line_stock;

-- invoice_line → invoice, product
alter table invoice_line drop constraint if exists fk_invoice_line_invoice;
alter table invoice_line
    add constraint fk_invoice_line_invoice
        foreign key (id_inv)
        references invoice(id_inv)
        on delete cascade;

alter table invoice_line drop constraint if exists fk_invoice_line_product;
alter table invoice_line
    add constraint fk_invoice_line_product
        foreign key (id_pro)
        references product(id_pro)
        on delete restrict;

-- return → client, employee, product (required on every return)
alter table "return" drop constraint if exists fk_return_client;
alter table "return"
    add constraint fk_return_client
        foreign key (id_cli)
        references client(id_cli)
        on delete restrict;

alter table "return" drop constraint if exists fk_return_employee;
alter table "return"
    add constraint fk_return_employee
        foreign key (id_emp)
        references employee(id_emp)
        on delete restrict;

alter table "return" drop constraint if exists fk_return_product;
alter table "return"
    add constraint fk_return_product
        foreign key (id_pro)
        references product(id_pro)
        on delete restrict;

alter table "return" drop constraint if exists fk_return_invoice_line;

-- legacy optional FKs on product (columns removed)
alter table product drop constraint if exists fk_purchase_product;
alter table product drop constraint if exists fk_product_stock;
alter table product drop constraint if exists fk_product_return;
