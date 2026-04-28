--=========================================================
-- MODULE 4: APPOINTMENT MANAGEMENT (Por retificar)
--=========================================================

--=========================================================
-- DESCRIPTION
--=========================================================
-- This module defines the structure responsible for appointment
-- and clinical management. It includes scheduling, medical records,
-- prescriptions, and billing associated with consultations.
--
-- The module supports:
-- - Appointment scheduling and tracking
-- - Clinical records (anamnesis and assessment)
-- - Prescription management
-- - Association of employees, clients and animals to appointments
-- - Billing through invoices

--=========================================================
-- 0. CLEANUP
--=========================================================
-- Drops only tables related to this module in reverse dependency order


drop table if exists appointment cascade;
drop table if exists overall_assessment cascade;
drop table if exists anamnesis cascade;
drop table if exists prescription cascade;
drop table if exists rel_app_product cascade;
drop table if exists rel_pre_prod cascade;

--=========================================================
-- 1. APPOINTMENT
--=========================================================
-- Stores appointment scheduling and general information
create table appointment (
    id_app int generated always as identity,
    -- Appointment identifier

    --Animal identifier    
    id_animal int NOT NULL,

    -- Employee (Veterinarian) identifier
    id_emp int NOT NULL,

    --client identifier
    id_cli NOT NULL,

    sch_dat_app timestamp,
    -- Scheduled datetime

    sta_dat_app timestamp not null,
    -- Start datetime

    end_dat_app timestamp not null,
    -- End datetime

    dia_app varchar(100),
    -- Diagnosis

    com_app text,
    -- Comments

    constraint pk_appointment primary key (id_app),
    -- Unique identifier

    -- Foreign Key linkage to animal
    CONSTRAINT fk_animal 
        FOREIGN KEY (id_animal)
        REFERENCES animal(id_ani)
        on delete cascade,
        
    -- Foreign Key linkage to employee (veterinarian)
    CONSTRAINT fk_appointment_employee
        FOREIGN KEY (id_emp)
        REFERENCES employee(id_emp)
        on delete restrict, -- Prevent deleting employee with active appointments

    -- Foreign Key linkage to client
    CONSTRAINT fk_client 
        FOREIGN KEY (id_cli)
        REFERENCES client(id_cli)
        on delete cascade,

    constraint chk_app_time
    check (sta_dat_app < end_dat_app)
    -- Ensures valid time interval
);

--=========================================================
-- 2. Overall Assessment
--=========================================================
-- Stores clinical history collected during appointment
CREATE TABLE overall_assessment (
    id_app INT NOT NULL, -- PK and FK
    body_temp FLOAT,     -- Body temperature in °C
    weight FLOAT,        -- Weight in kg
    hrt_rate FLOAT,      -- Heart rate (BPM)
    resp_rate FLOAT,     -- Respiratory rate (MPM)
    general_status TEXT, -- Notations about the animal
    
    -- Defining the Primary Key
    CONSTRAINT pk_overall_assessment PRIMARY KEY (id_app),
    
    -- Foreign Key linkage
    CONSTRAINT fk_appointment 
        FOREIGN KEY (id_app)
        REFERENCES appointment(id_app)
        on delete cascade,
        
    -- Safety checks to prevent impossible medical data
    CONSTRAINT chk_body_temp CHECK (body_temp > 0 AND body_temp < 50),
    CONSTRAINT chk_weight CHECK (weight > 0)
);

--=========================================================
-- 3. ANAMNESIS
--=========================================================
-- Stores patient history collected during appointment
create table anamnesis (
    id_ana int generated always as identity,
    -- Anamnesis identifier

    id_app int not null,
    -- Appointment

    reg_dat_ana timestamp default current_timestamp,
    -- Record date

    des_ana text,
    -- Description

    constraint pk_anamnesis primary key (id_ana),
    -- Unique identifier

    constraint fk_anamnesis_appointment 
        foreign key (id_app)
        references appointment(id_app)
        on delete cascade
    -- Links to appointment
);

--=========================================================
-- 4. PRESCRIPTION
--=========================================================
-- Stores prescriptions issued during appointment
create table prescription (
    id_pre int generated always as identity,
    -- Prescription identifier

    id_app int not null,
    -- Appointment

    reg_dat_pre timestamp default current_timestamp,
    -- Issue date

    des_pre text,
    -- Description

    constraint pk_prescription primary key (id_pre),
    -- Unique identifier

    constraint fk_prescription_appointment 
        foreign key (id_app)
        references appointment(id_app)
        on delete cascade
    -- Links to appointment
);

--=========================================================
-- 5. ASSOCIATIVE TABLE BETWEEN APPOINTMENT AND PRODUCTS
--=========================================================
create table rel_app_product (
    id_app int not null,
    -- Prescription

    id_pro int not null,
    -- Product

    qty_pre_pro int not null,
    -- Quantity

    dos_pre_pro varchar(100),
    -- Dosage

    constraint pk_appointment_product primary key (id_app, id_pro),

    constraint fk_app_pro_appointment 
        foreign key (id_app)
        references appointment(id_app)
        on delete cascade,

    constraint fk_pre_pro_product 
        foreign key (id_pro)
        references product(id_pro)
        on delete restrict,

    constraint chk_qty_pre
    check (qty_pre_pro > 0)
    -- Ensures valid quantity
);

--=========================================================
-- 6. ASSOCIATIVE TABLE BETWEEN PRESCRIPTION AND PRODUCTS
--=========================================================
create table rel_pre_prod (
    id_pre int not null,
    -- Prescription

    id_pro int not null,
    -- Product

    qty_pre_pro int not null,
    -- Quantity

    dos_pre_pro varchar(100),
    -- Dosage

    constraint pk_prescription_product primary key (id_pre, id_pro),

    constraint fk_pre_pro_prescription 
        foreign key (id_pre)
        references prescription(id_pre)
        on delete cascade,

    constraint fk_pre_pro_product 
        foreign key (id_pro)
        references product(id_pro)
        on delete restrict,

    constraint chk_qty_pre
    check (qty_pre_pro > 0)
    -- Ensures valid quantity
);