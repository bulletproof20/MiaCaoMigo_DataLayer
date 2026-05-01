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
-- - Appointment scheduling and tracking with status management
-- - Clinical records (anamnesis and assessment)
-- - Prescription management
-- - Association of employees, clients and animals to appointments
-- - Billing through invoices with status tracking

--=========================================================
-- 0. CLEANUP
--=========================================================
-- Drops only tables related to this module in reverse dependency order


drop table if exists appointment cascade;
drop table if exists overall_assessment cascade;
drop table if exists anamnesis cascade;
drop table if exists prescription cascade;
drop table if exists rel_app_product cascade;
drop table if exists client_notification cascade;
drop table if exists rel_pre_prod cascade;

-- Custom types
drop type if exists appointment_status cascade;
drop type if exists invoice_status cascade;

--=========================================================
-- 1. TYPES
--=========================================================
-- Defines custom ENUM types for status fields to ensure data consistency.

create type appointment_status as enum (
    'Scheduled', 
    'In Progress', 
    'Completed', 
    'Cancelled', 
    'No-Show'
);

create type invoice_status as enum (
    'Pending', 
    'Paid', 
    'Overdue', 
    'Cancelled'
);

--=========================================================
-- 2. APPOINTMENT
--=========================================================
-- Stores appointment scheduling, status, and general information.
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
    -- Actual start datetime of the consultation

    end_dat_app timestamp not null,
    -- Actual end datetime of the consultation

    status_app appointment_status not null default 'Scheduled',
    -- Current status of the appointment (e.g., Scheduled, Completed)

    dia_app varchar(100),
    -- Diagnosis resulting from the appointment. Filled upon completion.

    com_app text,
    -- General comments or observations about the appointment

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
    -- Ensures the end time is after the start time
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
    -- Foreign key to the related appointment

    reg_dat_ana timestamp not null default current_timestamp,
    -- Record date and time

    des_ana text,
    -- Detailed description of the patient's history and symptoms

    constraint pk_anamnesis primary key (id_ana),
    -- Unique identifier

    constraint fk_anamnesis_appointment 
        foreign key (id_app)
        references appointment(id_app)
        on delete cascade
    -- Links to appointment. If appointment is deleted, this record is also deleted.
);

--=========================================================
<<<<<<< HEAD
-- 3. ASSESSMENT
--=========================================================
-- Stores clinical evaluation results
create table assessment (
    id_ass int generated always as identity,
    -- Assessment identifier

    id_app int not null,
    -- Foreign key to the related appointment

    reg_dat_ass timestamp not null default current_timestamp,
    -- Record date and time

    des_ass text,
    -- Detailed description of the clinical findings

    constraint pk_assessment primary key (id_ass),
    -- Unique identifier

    constraint fk_assessment_appointment 
        foreign key (id_app)
        references appointment(id_app)
        on delete cascade
    -- Links to appointment. If appointment is deleted, this record is also deleted.
);

--=========================================================
=======
>>>>>>> 86b290baa0a7fff5681770d597ff529f1509d490
-- 4. PRESCRIPTION
--=========================================================
-- Stores prescriptions issued during appointment
create table prescription (
    id_pre int generated always as identity,
    -- Prescription identifier

    id_app int not null,
    -- Foreign key to the related appointment

    reg_dat_pre timestamp not null default current_timestamp,
    -- Issue date and time of the prescription

    des_pre text,
    -- General instructions or description for the prescription

    constraint pk_prescription primary key (id_pre),
    -- Unique identifier

    constraint fk_prescription_appointment 
        foreign key (id_app)
        references appointment(id_app)
        on delete cascade
    -- Links to appointment. If appointment is deleted, this record is also deleted.
);

--=========================================================
-- 5. ASSOCIATIVE TABLE BETWEEN APPOINTMENT AND PRODUCTS
--=========================================================
<<<<<<< HEAD
-- Stores billing information related to appointments or other sales.
create table invoice (
    id_inv int generated always as identity,
    -- Invoice identifier

    val_inv numeric(10,2) not null,
    -- Total value of the invoice. Must be non-negative.

    dat_inv timestamp not null default current_timestamp,
    -- Issue date of the invoice

    status_inv invoice_status not null default 'Pending',
    -- Current status of the invoice (e.g., Pending, Paid)

    bod_inv text,
    -- Description/content of the invoice (e.g., list of items and services)

    id_app int,
    -- Associated appointment (optional, as an invoice can be for product sales alone)
=======
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
>>>>>>> 86b290baa0a7fff5681770d597ff529f1509d490

    constraint fk_app_pro_appointment 
        foreign key (id_app)
        references appointment(id_app)
<<<<<<< HEAD
        on delete set null,
    -- If an appointment is deleted, the invoice remains but is unlinked for record-keeping.

    constraint chk_val_inv check (val_inv >= 0)
    -- Ensures the invoice value is not negative
);

--=========================================================
-- 6. ASSOCIATIVE TABLES
--=========================================================
-- Defines many-to-many relationships between core entities.

-- EMPLOYEE ↔ APPOINTMENT
-- Associates one or more employees (e.g., vet, assistant) with an appointment.
create table employee_appointment (
    id_emp int not null,
    -- Employee

    id_app int not null,
    -- Appointment

    constraint pk_employee_appointment primary key (id_emp, id_app),

    constraint fk_emp_app_employee 
        foreign key (id_emp)
        references employee(id_emp)
=======
>>>>>>> 86b290baa0a7fff5681770d597ff529f1509d490
        on delete cascade,

    constraint fk_pre_pro_product 
        foreign key (id_pro)
        references product(id_pro)
        on delete restrict,

    constraint chk_qty_pre
    check (qty_pre_pro > 0)
    -- Ensures valid quantity
);

<<<<<<< HEAD
-- CLIENT ↔ APPOINTMENT
-- Associates one or more clients (tutors) with an appointment.
create table client_appointment (
=======
--=========================================================
-- 7. CLIENT_NOTIFICATION
--=========================================================
-- Stores notifications generated for clients
create table client_notification (
    id_not int generated always as identity,
    -- Notification identifier

>>>>>>> 86b290baa0a7fff5681770d597ff529f1509d490
    id_cli int not null,
    -- Client associated with the notification

    message text not null,
    -- The notification message

    created_at timestamp default current_timestamp,
    -- Timestamp when the notification was created

    is_read boolean default false,
    -- Flag to indicate if the client has read the notification

    constraint pk_client_notification primary key (id_not),
    constraint fk_client_notification_client foreign key (id_cli) references client(id_cli) on delete cascade
);

<<<<<<< HEAD
-- ANIMAL ↔ APPOINTMENT
-- Associates one or more animals (patients) with an appointment.
create table animal_appointment (
    id_ani int not null,
    -- Animal

    id_app int not null,
    -- Appointment

    constraint pk_animal_appointment primary key (id_ani, id_app),

    constraint fk_ani_app_animal 
        foreign key (id_ani)
        references animal(id_ani)
        on delete cascade,

    constraint fk_ani_app_appointment 
        foreign key (id_app)
        references appointment(id_app)
        on delete cascade
);

-- PRESCRIPTION ↔ PRODUCT
-- Details the products included in a prescription, with quantity and dosage.
create table prescription_product (
=======
--=========================================================
-- 6. ASSOCIATIVE TABLE BETWEEN PRESCRIPTION AND PRODUCTS
--=========================================================
create table rel_pre_prod (
>>>>>>> 86b290baa0a7fff5681770d597ff529f1509d490
    id_pre int not null,
    -- Prescription

    id_pro int not null,
    -- Product

    qty_pre_pro int not null,
    -- Quantity of the product prescribed

    dos_pre_pro varchar(100),
    -- Dosage instructions (e.g., '1 pill every 8 hours')

    constraint pk_prescription_product primary key (id_pre, id_pro),

    constraint fk_pre_pro_prescription 
        foreign key (id_pre)
        references prescription(id_pre)
        on delete cascade,

    constraint fk_pre_pro_product 
        foreign key (id_pro)
        references product(id_pro)
        on delete restrict,
    -- Prevents deleting a product that is part of an existing prescription.

    constraint chk_qty_pre
    check (qty_pre_pro > 0)
<<<<<<< HEAD
    -- Ensures prescribed quantity is a positive number
);

-- EMPLOYEE ↔ ANAMNESIS
-- Associates employee(s) with an anamnesis record. Useful for tracking who
-- collected the information or for collaborative/supervisory scenarios.
create table employee_anamnesis (
    id_emp int not null,
    -- Employee

    id_ana int not null,
    -- Anamnesis

    constraint pk_employee_anamnesis primary key (id_emp, id_ana),

    constraint fk_emp_ana_employee 
        foreign key (id_emp)
        references employee(id_emp)
        on delete cascade,

    constraint fk_emp_ana_anamnesis 
        foreign key (id_ana)
        references anamnesis(id_ana)
        on delete cascade
);

-- EMPLOYEE ↔ ASSESSMENT
-- Associates employee(s) with an assessment record. Useful for tracking who
-- performed the assessment or for collaborative/supervisory scenarios.
create table employee_assessment (
    id_emp int not null,
    -- Employee

    id_ass int not null,
    -- Assessment

    constraint pk_employee_assessment primary key (id_emp, id_ass),

    constraint fk_emp_ass_employee 
        foreign key (id_emp)
        references employee(id_emp)
        on delete cascade,

    constraint fk_emp_ass_assessment 
        foreign key (id_ass)
        references assessment(id_ass)
        on delete cascade
);

-- EMPLOYEE ↔ PRESCRIPTION
-- Associates employee(s) with a prescription. Useful for tracking who
-- issued the prescription, especially in a multi-vet environment.
create table employee_prescription (
    id_emp int not null,
    -- Employee

    id_pre int not null,
    -- Prescription

    constraint pk_employee_prescription primary key (id_emp, id_pre),

    constraint fk_emp_pre_employee 
        foreign key (id_emp)
        references employee(id_emp)
        on delete cascade,

    constraint fk_emp_pre_prescription 
        foreign key (id_pre)
        references prescription(id_pre)
        on delete cascade
=======
    -- Ensures valid quantity
>>>>>>> 86b290baa0a7fff5681770d597ff529f1509d490
);