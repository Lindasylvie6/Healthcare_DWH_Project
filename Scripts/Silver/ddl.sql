/*
===============================================================================
DDL Script: Create Silver Tables
===============================================================================
Script Purpose:
    This script creates tables in the 'silver' schema.
	  Run this script to re-define the DDL structure of 'bronze' Tables
===============================================================================
*/

-- =============================================
-- SILVER 1: patients
-- Cleaned, typed, age calculated
-- =============================================
CREATE TABLE silver.patients (
    patient_sk        BIGINT IDENTITY(1,1) PRIMARY KEY,
    patient_id        VARCHAR(20) NOT NULL,
    first_name        VARCHAR(200),
    last_name         VARCHAR(200),
    full_name         AS (first_name + ' ' + last_name),
    dob               DATE,
    age               INT,
    gender            VARCHAR(20),
    ethnicity         VARCHAR(100),
    insurance_type    VARCHAR(100),
    marital_status    VARCHAR(50),
    address           VARCHAR(500),
    city              VARCHAR(100),
    state             VARCHAR(10),
    zip               VARCHAR(20),
    phone             VARCHAR(50),
    email             VARCHAR(200),
    registration_date DATE,
    silver_load_dt    DATETIME2 DEFAULT GETUTCDATE()
);

-- =============================================
-- SILVER 2: encounters
-- Typed dates, LOS calculated, flags cleaned
-- =============================================
CREATE TABLE silver.encounters (
    encounter_sk      BIGINT IDENTITY(1,1) PRIMARY KEY,
    encounter_id      VARCHAR(20) NOT NULL,
    patient_id        VARCHAR(20),
    provider_id       VARCHAR(20),
    visit_date        DATE,
    visit_type        VARCHAR(100),
    department        VARCHAR(200),
    reason_for_visit  VARCHAR(500),
    diagnosis_code    VARCHAR(20),
    admission_type    VARCHAR(100),
    discharge_date    DATE,
    length_of_stay    INT,
    status            VARCHAR(50),
    readmitted_flag   BIT,
    silver_load_dt    DATETIME2 DEFAULT GETUTCDATE()
);

-- =============================================
-- SILVER 3: claims
-- Typed amounts, cleaned status
-- =============================================
CREATE TABLE silver.claims (
    claim_sk           BIGINT IDENTITY(1,1) PRIMARY KEY,
    billing_id         VARCHAR(20),
    patient_id         VARCHAR(20),
    encounter_id       VARCHAR(20),
    claim_id           VARCHAR(20) NOT NULL,
    insurance_provider VARCHAR(200),
    payment_method     VARCHAR(100),
    claim_billing_date DATE,
    billed_amount      DECIMAL(18,2),
    paid_amount        DECIMAL(18,2),
    unpaid_amount      AS (CAST(billed_amount AS DECIMAL(18,2)) 
                          - CAST(paid_amount AS DECIMAL(18,2))),
    claim_status       VARCHAR(50),
    denial_reason      VARCHAR(500),
    is_denied          BIT,
    silver_load_dt     DATETIME2 DEFAULT GETUTCDATE()
);

-- =============================================
-- SILVER 4: denials
-- Typed amounts and dates, appeal tracking
-- =============================================
CREATE TABLE silver.denials (
    denial_sk               BIGINT IDENTITY(1,1) PRIMARY KEY,
    claim_id                VARCHAR(20),
    denial_id               VARCHAR(20) NOT NULL,
    denial_reason_code      VARCHAR(20),
    denial_reason_description VARCHAR(500),
    denied_amount           DECIMAL(18,2),
    denial_date             DATE,
    appeal_filed            BIT,
    appeal_status           VARCHAR(50),
    appeal_resolution_date  DATE,
    final_outcome           VARCHAR(100),
    days_to_resolution      INT,
    silver_load_dt          DATETIME2 DEFAULT GETUTCDATE()
);

-- =============================================
-- SILVER 5: diagnoses
-- Typed flags, ICD10 cleaned
-- =============================================
CREATE TABLE silver.diagnoses (
    diagnosis_sk          BIGINT IDENTITY(1,1) PRIMARY KEY,
    diagnosis_id          VARCHAR(20),
    encounter_id          VARCHAR(20),
    diagnosis_code        VARCHAR(20),
    diagnosis_description VARCHAR(500),
    primary_flag          BIT,
    chronic_flag          BIT,
    silver_load_dt        DATETIME2 DEFAULT GETUTCDATE()
);

-- =============================================
-- SILVER 6: procedures
-- Typed cost and date, CPT code cleaned
-- =============================================
CREATE TABLE silver.procedures (
    procedure_sk          BIGINT IDENTITY(1,1) PRIMARY KEY,
    procedure_id          VARCHAR(20),
    encounter_id          VARCHAR(20),
    procedure_code        VARCHAR(20),
    procedure_description VARCHAR(500),
    procedure_date        DATE,
    provider_id           VARCHAR(20),
    procedure_cost        DECIMAL(18,2),
    silver_load_dt        DATETIME2 DEFAULT GETUTCDATE()
);

-- =============================================
-- SILVER 7: lab_tests
-- Typed date, abnormal flag derived
-- =============================================
CREATE TABLE silver.lab_tests (
    lab_sk           BIGINT IDENTITY(1,1) PRIMARY KEY,
    lab_id           VARCHAR(20),
    encounter_id     VARCHAR(20),
    test_name        VARCHAR(500),
    test_code        VARCHAR(50),
    specimen_type    VARCHAR(100),
    test_result      VARCHAR(200),
    units            VARCHAR(50),
    normal_range     VARCHAR(100),
    test_date        DATE,
    status           VARCHAR(50),
    is_abnormal      BIT,
    silver_load_dt   DATETIME2 DEFAULT GETUTCDATE()
);

-- =============================================
-- SILVER 8: medications
-- Typed cost and date, route standardized
-- =============================================
CREATE TABLE silver.medications (
    medication_sk    BIGINT IDENTITY(1,1) PRIMARY KEY,
    medication_id    VARCHAR(20),
    encounter_id     VARCHAR(20),
    drug_name        VARCHAR(500),
    dosage           VARCHAR(100),
    route            VARCHAR(100),
    frequency        VARCHAR(100),
    duration         VARCHAR(100),
    prescribed_date  DATE,
    prescriber_id    VARCHAR(20),
    cost             DECIMAL(18,2),
    silver_load_dt   DATETIME2 DEFAULT GETUTCDATE()
);

-- =============================================
-- SILVER 9: providers
-- NPI validated, inhouse flag typed
-- =============================================
CREATE TABLE silver.providers (
    provider_sk      BIGINT IDENTITY(1,1) PRIMARY KEY,
    provider_id      VARCHAR(20) NOT NULL,
    name             VARCHAR(500),
    department       VARCHAR(200),
    specialty        VARCHAR(200),
    npi              VARCHAR(20),
    inhouse          BIT,
    location         VARCHAR(100),
    years_experience INT,
    contact_info     VARCHAR(100),
    email            VARCHAR(200),
    silver_load_dt   DATETIME2 DEFAULT GETUTCDATE()
);
