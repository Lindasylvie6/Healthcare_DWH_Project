/*
===============================================================================
DDL Script: Create Gold Views
===============================================================================
Script Purpose:
    This script creates views for the Gold layer in the data warehouse. 
    The Gold layer represents the final dimension and fact tables (Star Schema)

    Each view performs transformations and combines data from the Silver layer 
    to produce a clean, enriched, and business-ready dataset.

Usage:
    - These views can be queried directly for analytics and reporting.
===============================================================================
*/

-- =============================================
-- GOLD 1: dim_patient
-- One row per patient - for Power BI slicing
-- =============================================
CREATE TABLE gold.dim_patient (
    patient_sk        BIGINT PRIMARY KEY,
    patient_id        VARCHAR(20),
    full_name         VARCHAR(400),
    dob               DATE,
    age               INT,
    age_group         VARCHAR(20),
    gender            VARCHAR(20),
    ethnicity         VARCHAR(100),
    insurance_type    VARCHAR(100),
    marital_status    VARCHAR(50),
    city              VARCHAR(100),
    state             VARCHAR(10),
    zip               VARCHAR(20),
    registration_date DATE
);

-- =============================================
-- GOLD 2: dim_provider
-- One row per provider - for Power BI slicing
-- =============================================
CREATE TABLE gold.dim_provider (
    provider_sk       BIGINT PRIMARY KEY,
    provider_id       VARCHAR(20),
    name              VARCHAR(500),
    department        VARCHAR(200),
    specialty         VARCHAR(200),
    npi               VARCHAR(20),
    inhouse           BIT,
    location          VARCHAR(100),
    years_experience  INT
);

-- =============================================
-- GOLD 3: dim_date
-- Calendar table - every date Power BI needs
-- =============================================
CREATE TABLE gold.dim_date (
    date_sk           INT PRIMARY KEY,
    full_date         DATE,
    year              INT,
    quarter           INT,
    quarter_name      VARCHAR(10),
    month             INT,
    month_name        VARCHAR(20),
    week              INT,
    day_of_week       VARCHAR(20),
    is_weekend        BIT,
    fiscal_year       INT,
    fiscal_quarter    INT
);

-- =============================================
-- GOLD 4: fact_encounters
-- One row per visit - foundation of all reports
-- =============================================
CREATE TABLE gold.fact_encounters (
    encounter_sk        BIGINT PRIMARY KEY,
    encounter_id        VARCHAR(20),
    patient_id          VARCHAR(20),
    provider_id         VARCHAR(20),
    visit_date_sk       INT,
    discharge_date_sk   INT,
    visit_type          VARCHAR(100),
    department          VARCHAR(200),
    reason_for_visit    VARCHAR(500),
    primary_dx_code     VARCHAR(20),
    admission_type      VARCHAR(100),
    length_of_stay      INT,
    status              VARCHAR(50),
    readmitted_flag     BIT,
    total_billed        DECIMAL(18,2),
    total_paid          DECIMAL(18,2),
    total_unpaid        DECIMAL(18,2),
    total_procedures    INT,
    total_medications   INT,
    total_lab_tests     INT,
    gold_load_dt        DATETIME2 DEFAULT GETUTCDATE()
);

-- =============================================
-- GOLD 5: fact_claims
-- One row per claim - revenue cycle reporting
-- =============================================
CREATE TABLE gold.fact_claims (
    claim_sk            BIGINT PRIMARY KEY,
    claim_id            VARCHAR(20),
    billing_id          VARCHAR(20),
    patient_id          VARCHAR(20),
    encounter_id        VARCHAR(20),
    claim_date_sk       INT,
    insurance_provider  VARCHAR(200),
    payment_method      VARCHAR(100),
    billed_amount       DECIMAL(18,2),
    paid_amount         DECIMAL(18,2),
    unpaid_amount       DECIMAL(18,2),
    claim_status        VARCHAR(50),
    is_denied           BIT,
    denial_reason       VARCHAR(500),
    gold_load_dt        DATETIME2 DEFAULT GETUTCDATE()
);

-- =============================================
-- GOLD 6: fact_denials
-- One row per denial - denial management
-- =============================================
CREATE TABLE gold.fact_denials (
    denial_sk               BIGINT PRIMARY KEY,
    denial_id               VARCHAR(20),
    claim_id                VARCHAR(20),
    patient_id              VARCHAR(20),
    denial_date_sk          INT,
    denial_reason_code      VARCHAR(20),
    denial_reason_description VARCHAR(500),
    denied_amount           DECIMAL(18,2),
    appeal_filed            BIT,
    appeal_status           VARCHAR(50),
    final_outcome           VARCHAR(100),
    days_to_resolution      INT,
    was_overturned          BIT,
    gold_load_dt            DATETIME2 DEFAULT GETUTCDATE()
);

-- =============================================
-- GOLD 7: fact_clinical
-- One row per encounter - clinical outcomes
-- =============================================
CREATE TABLE gold.fact_clinical (
    clinical_sk           BIGINT IDENTITY(1,1) PRIMARY KEY,
    encounter_id          VARCHAR(20),
    patient_id            VARCHAR(20),
    visit_date_sk         INT,
    primary_dx_code       VARCHAR(20),
    primary_dx_desc       VARCHAR(500),
    chronic_condition_cnt INT,
    total_diagnoses       INT,
    total_procedures      INT,
    total_lab_tests       INT,
    abnormal_lab_cnt      INT,
    total_medications     INT,
    total_procedure_cost  DECIMAL(18,2),
    total_medication_cost DECIMAL(18,2),
    readmitted_flag       BIT,
    gold_load_dt          DATETIME2 DEFAULT GETUTCDATE()
);

-- =============================================
-- GOLD 8: fact_monthly_kpis
-- Pre-aggregated KPIs - executive dashboard
-- =============================================
CREATE TABLE gold.fact_monthly_kpis (
    kpi_sk                BIGINT IDENTITY(1,1) PRIMARY KEY,
    year_month            CHAR(7),
    department            VARCHAR(200),
    visit_type            VARCHAR(100),
    total_encounters      INT,
    avg_length_of_stay    DECIMAL(5,2),
    readmission_count     INT,
    readmission_rate      DECIMAL(5,4),
    total_billed          DECIMAL(18,2),
    total_paid            DECIMAL(18,2),
    total_unpaid          DECIMAL(18,2),
    collection_rate       DECIMAL(5,4),
    total_denials         INT,
    denial_rate           DECIMAL(5,4),
    appeals_filed         INT,
    appeals_overturned    INT,
    overturn_rate         DECIMAL(5,4),
    total_procedures      INT,
    total_lab_tests       INT,
    abnormal_lab_rate     DECIMAL(5,4),
    gold_load_dt          DATETIME2 DEFAULT GETUTCDATE()
);

-- =============================================
-- GOLD 9: fact_provider_performance
-- One row per provider per month
-- =============================================
CREATE TABLE gold.fact_provider_performance (
    perf_sk               BIGINT IDENTITY(1,1) PRIMARY KEY,
    provider_id           VARCHAR(20),
    year_month            CHAR(7),
    department            VARCHAR(200),
    specialty             VARCHAR(200),
    total_encounters      INT,
    avg_length_of_stay    DECIMAL(5,2),
    total_billed          DECIMAL(18,2),
    total_paid            DECIMAL(18,2),
    readmission_count     INT,
    readmission_rate      DECIMAL(5,4),
    total_procedures      INT,
    avg_procedure_cost    DECIMAL(18,2),
    total_medications     INT,
    gold_load_dt          DATETIME2 DEFAULT GETUTCDATE()
);
