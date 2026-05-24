-- =========================================================
-- TABLES — MODULE 3 (COMMERCIAL MANAGEMENT)
-- FILE: Schema/03_Module3_Commercial_Management/00_Tables_Mod3.sql
-- =========================================================
-- PURPOSE:   Products, stock, purchases, invoices, returns
-- DOMAIN:    Module 3 — Commercial Management
-- LOADED BY: Bootstrap/Loaders/01_Structure.sql
-- CLEANUP:   inline DROP (module 3 only) then CREATE
-- FK LAYER:  01_ForeignKeys_Mod3.sql (purchase_status from 01_Types.sql)
-- =========================================================


--=========================================================
-- 0. CLEANUP
--=========================================================
-- Drops only tables related to this module in reverse dependency order

drop table if exists purchase_line cascade;
drop table if exists invoice_line cascade;
drop table if exists "return" cascade;
drop table if exists purchase cascade;
drop table if exists stock cascade;
drop table if exists product cascade;
drop table if exists invoice cascade;
drop table if exists family cascade;


--=========================================================
-- 1. FAMILY
--=========================================================
-- Defines product categories

create table family (
    id_fam int generated always as identity,
    -- Family identifier

    nam_fam varchar(70) not null,
    -- Display name

    des_fam text,
    -- Description

    constraint pk_family primary key (id_fam)
);


--=========================================================
-- 2. INVOICE
--=========================================================
-- Billing header optionally linked to an appointment

create table invoice (
    id_inv int generated always as identity,
    -- Invoice identifier

    val_inv numeric(10, 2),
    -- Monetary total (maintained by triggers)

    dat_inv timestamp,
    -- Issue timestamp

    bod_inv text,
    -- Free-text body or notes
    
    sta_inv invoice_status default 'pending',
    -- Invoice workflow state (centralized enum)

    id_app int,
    -- Consultation back-reference (maintained by appointment.id_inv sync trigger in Module 4)

    constraint pk_invoice primary key (id_inv)
);


--=========================================================
-- 3. PRODUCT
--=========================================================
-- Catalog item with pricing, tax, and lifecycle metadata

create table product (
    id_pro int generated always as identity,
    -- Product identifier

    ref_pro varchar(50),
    -- Internal reference code

    bar_pro varchar(50),
    -- Barcode

    nam_pro varchar(100) not null,
    -- Product name

    des_pro text,
    -- Description

    pri_pro numeric(10, 2),
    -- Unit list price

    iva_pro numeric(5, 2),
    -- VAT percentage

    reg_dat_pro timestamp default current_timestamp not null,
    -- Registration timestamp

    ina_dat_pro timestamp,
    -- Inactivation timestamp

    id_fam int not null,
    -- Required catalog family (FK in 01_ForeignKeys_Mod3.sql)

    min_sto int not null default 5,
    -- Minimum stock threshold

    constraint pk_product primary key (id_pro),

    constraint ck_min_sto_positive
    check (min_sto >= 0)
);


--=========================================================
-- 4. STOCK
--=========================================================
-- Quantity ledger per product with batch and expiry metadata

create table stock (
    id_sto int generated always as identity,
    -- Stock row identifier

    id_pro int not null,
    -- Product being stocked (FK in 01_ForeignKeys_Mod3.sql)

    bat_sto varchar(50),
    -- Batch or lot identifier

    qty_sto int not null,
    -- Available quantity in this batch

    val_dat_sto date,
    -- Expiration date

    ent_dat_sto date,
    -- Warehouse entry date

    constraint pk_stock primary key (id_sto),

    constraint ck_qty_sto
    check (qty_sto >= 0)
);


--=========================================================
-- 5. PURCHASE
--=========================================================
-- Purchase order header with totals and workflow status

create table purchase (
    id_pur int generated always as identity,
    -- Purchase identifier

    pur_dat_pur timestamp default current_timestamp not null,
    -- Purchase timestamp

    tot_val_pur numeric(10, 2),
    -- Order total

    ord_num_pur varchar(50),
    -- External order reference

    pay_met_pur varchar(50),
    -- Payment method label

    sta_pur purchase_status default 'pending',
    -- Workflow state (centralized enum)

    id_inv int,
    -- Linked invoice when billed (nullable; no FK — supplier POs may omit)

    id_cli int,
    -- Client for retail purchases (nullable; no FK — supplier POs may omit)

    id_emp int,
    -- Employee responsible (FK in 01_ForeignKeys_Mod3.sql)

    constraint pk_purchase primary key (id_pur)
);


--=========================================================
-- 6. PURCHASE_LINE
--=========================================================
-- Line-level detail for incoming stock tied to a purchase

create table purchase_line (
    id_pur_lin int generated always as identity,
    -- Line identifier

    id_pur int not null,
    -- Parent purchase (FK in 01_ForeignKeys_Mod3.sql)

    id_pro int not null,
    -- Product being procured (FK in 01_ForeignKeys_Mod3.sql)

    bat_pln varchar(50),
    -- Batch label captured at receipt

    qty_pln int not null,
    -- Ordered quantity

    uni_cos_pln numeric(10, 2) not null,
    -- Unit cost

    id_sto int,
    -- Stock row created on receive (nullable; no FK — set by sp_receive_purchase)

    constraint pk_purchase_line primary key (id_pur_lin),

    constraint ck_qty_pln
    check (qty_pln > 0)
);


--=========================================================
-- 7. INVOICE_LINE
--=========================================================
-- Sales line items contributing to invoice totals

create table invoice_line (
    id_inv_lin int generated always as identity,
    -- Invoice line identifier

    id_inv int not null,
    -- Parent invoice (FK in 01_ForeignKeys_Mod3.sql)

    id_pro int not null,
    -- Product sold (FK in 01_ForeignKeys_Mod3.sql)

    qty_inv_lin int not null,
    -- Quantity sold

    uni_pri_inv_lin numeric(10, 2) not null,
    -- Unit selling price

    iva_inv_lin numeric(5, 2) not null,
    -- VAT rate applied to the line

    constraint pk_invoice_line primary key (id_inv_lin),

    constraint ck_qty_inv_lin
    check (qty_inv_lin > 0)
);


--=========================================================
-- 8. RETURN
--=========================================================
-- Commercial return: one client, one employee, one product per header.
-- Optional invoice_line reference for sale traceability and qty validation.

create table "return" (
    id_ret int generated always as identity,
    -- Return identifier

    id_cli int not null,
    -- Client (FK in 01_ForeignKeys_Mod3.sql)

    id_emp int not null,
    -- Responsible employee (FK in 01_ForeignKeys_Mod3.sql)

    id_pro int not null,
    -- Returned product (FK in 01_ForeignKeys_Mod3.sql)

    mot_ret varchar(100),
    -- Reason narrative

    ina_dat_ret timestamp,
    -- Closure or inactivation timestamp

    id_inv_lin int,
    -- Optional originating invoice line (nullable; no FK — audit/qty check in trigger)

    qty_ret int not null default 1,
    -- Quantity being returned

    constraint pk_return primary key (id_ret),

    constraint ck_qty_ret
    check (qty_ret > 0)
);
