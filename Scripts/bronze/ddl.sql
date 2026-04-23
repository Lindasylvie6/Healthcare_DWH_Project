/*
===============================================================================
DDL Script: Create Bronze Tables
===============================================================================
Script Purpose:
    This script creates tables in the 'bronze' schema, dropping existing tables 
    if they already exist.
	  Run this script to re-define the DDL structure of 'bronze' Tables
===============================================================================
*/
-- Drop old generic tables
DROP TABLE IF EXISTS bronze.claims_raw;
DROP TABLE IF EXISTS bronze.encounters_raw;
DROP TABLE IF EXISTS bronze.patients_raw;
DROP TABLE IF EXISTS bronze.claim_lines_raw;
DROP TABLE IF EXISTS bronze.eligibility_raw;
DROP TABLE IF EXISTS bronze.providers_raw;
DROP TABLE IF EXISTS bronze.diagnoses_raw;
DROP TABLE IF EXISTS bronze.lab_results_raw;
DROP TABLE IF EXISTS bronze.pharmacy_raw;

-- =============================================
-- BRONZE 1: patients.csv
-- 60,000 rows | patient demographics
-- =============================================
CREATE TABLE bronze.patients_raw (
    load_id           BIGINT IDENTITY(1,1) PRIMARY KEY,
    source_file_name  VARCHAR(500),
    load_datetime     DATETIME2 DEFAULT GETUTCDATE(),
    patient_id        VARCHAR(20),
    first_name        VARCHAR(200),
    last_name         VARCHAR(200),
    dob               VARCHAR(50),
    age               VARCHAR(10),
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
    registration_date VARCHAR(50)
);

-- =============================================
-- BRONZE 2: encounters.csv
-- 70,000 rows | visits and admissions
-- =============================================
CREATE TABLE bronze.encounters_raw (
    load_id           BIGINT IDENTITY(1,1) PRIMARY KEY,
    source_file_name  VARCHAR(500),
    load_datetime     DATETIME2 DEFAULT GETUTCDATE(),
    encounter_id      VARCHAR(20),
    patient_id        VARCHAR(20),
    provider_id       VARCHAR(20),
    visit_date        VARCHAR(50),
    visit_type        VARCHAR(100),
    department        VARCHAR(200),
    reason_for_visit  VARCHAR(500),
    diagnosis_code    VARCHAR(20),
    admission_type    VARCHAR(100),
    discharge_date    VARCHAR(50),
    length_of_stay    VARCHAR(20),
    status            VARCHAR(50),
    readmitted_flag   VARCHAR(10)
);

-- =============================================
-- BRONZE 3: claims_and_billing.csv
-- 70,000 rows | billing and payments
-- =============================================
CREATE TABLE bronze.claims_raw (
    load_id           BIGINT IDENTITY(1,1) PRIMARY KEY,
    source_file_name  VARCHAR(500),
    load_datetime     DATETIME2 DEFAULT GETUTCDATE(),
    billing_id        VARCHAR(20),
    patient_id        VARCHAR(20),
    encounter_id      VARCHAR(20),
    insurance_provider VARCHAR(200),
    payment_method    VARCHAR(100),
    claim_id          VARCHAR(20),
    claim_billing_date VARCHAR(50),
    billed_amount     VARCHAR(50),
    paid_amount       VARCHAR(50),
    claim_status      VARCHAR(50),
    denial_reason     VARCHAR(500)
);

-- =============================================
-- BRONZE 4: denials.csv
-- 5,998 rows | denied claims detail
-- =============================================
CREATE TABLE bronze.denials_raw (
    load_id                 BIGINT IDENTITY(1,1) PRIMARY KEY,
    source_file_name        VARCHAR(500),
    load_datetime           DATETIME2 DEFAULT GETUTCDATE(),
    claim_id                VARCHAR(20),
    denial_id               VARCHAR(20),
    denial_reason_code      VARCHAR(20),
    denial_reason_description VARCHAR(500),
    denied_amount           VARCHAR(50),
    denial_date             VARCHAR(50),
    appeal_filed            VARCHAR(10),
    appeal_status           VARCHAR(50),
    appeal_resolution_date  VARCHAR(50),
    final_outcome           VARCHAR(100)
);

-- =============================================
-- BRONZE 5: diagnoses.csv
-- 70,000 rows | ICD-10 codes per encounter
-- =============================================
CREATE TABLE bronze.diagnoses_raw (
    load_id               BIGINT IDENTITY(1,1) PRIMARY KEY,
    source_file_name      VARCHAR(500),
    load_datetime         DATETIME2 DEFAULT GETUTCDATE(),
    diagnosis_id          VARCHAR(20),
    encounter_id          VARCHAR(20),
    diagnosis_code        VARCHAR(20),
    diagnosis_description VARCHAR(500),
    primary_flag          VARCHAR(10),
    chronic_flag          VARCHAR(10)
);

-- =============================================
-- BRONZE 6: procedures.csv
-- 126,021 rows | CPT codes per encounter
-- =============================================
CREATE TABLE bronze.procedures_raw (
    load_id               BIGINT IDENTITY(1,1) PRIMARY KEY,
    source_file_name      VARCHAR(500),
    load_datetime         DATETIME2 DEFAULT GETUTCDATE(),
    procedure_id          VARCHAR(20),
    encounter_id          VARCHAR(20),
    procedure_code        VARCHAR(20),
    procedure_description VARCHAR(500),
    procedure_date        VARCHAR(50),
    provider_id           VARCHAR(20),
    procedure_cost        VARCHAR(50)
);

-- =============================================
-- BRONZE 7: lab_tests.csv
-- 54,537 rows | lab and imaging results
-- =============================================
CREATE TABLE bronze.lab_tests_raw (
    load_id          BIGINT IDENTITY(1,1) PRIMARY KEY,
    source_file_name VARCHAR(500),
    load_datetime    DATETIME2 DEFAULT GETUTCDATE(),
    lab_id           VARCHAR(20),
    encounter_id     VARCHAR(20),
    test_name        VARCHAR(500),
    test_code        VARCHAR(50),
    specimen_type    VARCHAR(100),
    test_result      VARCHAR(200),
    units            VARCHAR(50),
    normal_range     VARCHAR(100),
    test_date        VARCHAR(50),
    status           VARCHAR(50)
);

-- =============================================
-- BRONZE 8: medications.csv
-- 94,498 rows | prescriptions
-- =============================================
CREATE TABLE bronze.medications_raw (
    load_id          BIGINT IDENTITY(1,1) PRIMARY KEY,
    source_file_name VARCHAR(500),
    load_datetime    DATETIME2 DEFAULT GETUTCDATE(),
    medication_id    VARCHAR(20),
    encounter_id     VARCHAR(20),
    drug_name        VARCHAR(500),
    dosage           VARCHAR(100),
    route            VARCHAR(100),
    frequency        VARCHAR(100),
    duration         VARCHAR(100),
    prescribed_date  VARCHAR(50),
    prescriber_id    VARCHAR(20),
    cost             VARCHAR(50)
);

-- =============================================
-- BRONZE 9: providers.csv
-- 1,491 rows | provider registry
-- =============================================
CREATE TABLE bronze.providers_raw (
    load_id           BIGINT IDENTITY(1,1) PRIMARY KEY,
    source_file_name  VARCHAR(500),
    load_datetime     DATETIME2 DEFAULT GETUTCDATE(),
    provider_id       VARCHAR(20),
    name              VARCHAR(500),
    department        VARCHAR(200),
    specialty         VARCHAR(200),
    npi               VARCHAR(20),
    inhouse           VARCHAR(10),
    location          VARCHAR(100),
    years_experience  VARCHAR(10),
    contact_info      VARCHAR(100),
    email             VARCHAR(200)
);
