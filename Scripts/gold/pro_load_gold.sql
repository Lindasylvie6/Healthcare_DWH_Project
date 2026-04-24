-- =============================================
-- GOLD: dim_date
-- Calendar table for Power BI time intelligence
-- Covers 2024-2026 ( data range)
-- No source table — generated mathematically
-- =============================================
CREATE OR ALTER PROCEDURE gold.load_dim_date
AS
BEGIN
    TRUNCATE TABLE gold.dim_date;

    WITH date_series AS (
        SELECT CAST('2024-01-01' AS DATE) AS full_date
        UNION ALL
        SELECT DATEADD(day, 1, full_date)
        FROM date_series
        WHERE full_date < '2026-12-31'
    )
    INSERT INTO gold.dim_date (
        date_sk,
        full_date,
        year,
        quarter,
        month,
        month_name,
        week,
        day_of_week,
        is_weekend,
        fiscal_year,
        fiscal_quarter
    )
    SELECT
        CAST(FORMAT(full_date, 'yyyyMMdd') AS INT) AS date_sk,
        full_date,
        YEAR(full_date)                            AS year,
        DATEPART(quarter, full_date)               AS quarter,
        MONTH(full_date)                           AS month,
        DATENAME(month, full_date)                 AS month_name,
        DATEPART(week, full_date)                  AS week,
        DATENAME(weekday, full_date)               AS day_of_week,
        CASE
            WHEN DATEPART(weekday, full_date) IN (1,7) THEN 1
            ELSE 0
        END                                        AS is_weekend,
        CASE
            WHEN MONTH(full_date) >= 10
            THEN YEAR(full_date) + 1
            ELSE YEAR(full_date)
        END                                        AS fiscal_year,
        CASE
            WHEN MONTH(full_date) IN (10,11,12) THEN 1
            WHEN MONTH(full_date) IN (1,2,3)    THEN 2
            WHEN MONTH(full_date) IN (4,5,6)    THEN 3
            WHEN MONTH(full_date) IN (7,8,9)    THEN 4
        END                                        AS fiscal_quarter
    FROM date_series
    OPTION (MAXRECURSION 0);  -- ← changed from 1000 to 0

END;
GO

EXEC gold.load_dim_date;

-- =============================================
-- GOLD: dim_patient
-- Source: silver.patients
-- Rows expected: 60,000
-- One row per patient for Power BI slicers
-- =============================================
CREATE OR ALTER PROCEDURE gold.load_dim_patient
AS
BEGIN
    -- Clear gold table before loading
    TRUNCATE TABLE gold.dim_patient;

    -- Insert from silver patients
    INSERT INTO gold.dim_patient (
        patient_sk,
        patient_id,
        full_name,
        dob,
        age,
        gender,
        ethnicity,
        insurance_type,
        marital_status,
        city,
        state,
        zip
    )
    SELECT
        -- Use row number as surrogate key
        ROW_NUMBER() OVER (ORDER BY patient_id)  AS patient_sk,
        patient_id,
        -- Combine first and last name
        first_name + ' ' + last_name             AS full_name,
        dob,
        age,
        gender,
        ethnicity,
        insurance_type,
        marital_status,
        city,
        state,
        zip
    FROM silver.patients
    WHERE patient_id IS NOT NULL;

END;
GO

EXEC gold.load_dim_patient;

-- =============================================
-- GOLD: dim_provider
-- Source: silver.providers
-- Rows expected: 1,491
-- One row per provider for Power BI slicers
-- =============================================
CREATE OR ALTER PROCEDURE gold.load_dim_provider
AS
BEGIN
    -- Clear gold table before loading
    TRUNCATE TABLE gold.dim_provider;

    -- Insert from silver providers
    INSERT INTO gold.dim_provider (
        provider_sk,
        provider_id,
        name,
        department,
        specialty,
        npi,
        inhouse,
        location,
        years_experience
    )
    SELECT
        -- Use row number as surrogate key
        ROW_NUMBER() OVER (ORDER BY provider_id) AS provider_sk,
        provider_id,
        name,
        department,
        specialty,
        npi,
        inhouse,
        location,
        years_experience
    FROM silver.providers
    WHERE provider_id IS NOT NULL;

END;
GO
EXEC gold.load_dim_provider;

-- =============================================
-- GOLD: fact_encounters
-- Source: silver.encounters + silver.claims
--         + silver.diagnoses
-- Rows expected: ~70,000
-- Fix: added ROW_NUMBER() for encounter_sk
-- =============================================
CREATE OR ALTER PROCEDURE gold.load_fact_encounters
AS
BEGIN
    -- Clear gold table before loading
    TRUNCATE TABLE gold.fact_encounters;

    -- Insert from silver encounters
    INSERT INTO gold.fact_encounters (
        encounter_sk,
        encounter_id,
        patient_id,
        provider_id,
        visit_date_sk,
        discharge_date_sk,
        visit_type,
        department,
        reason_for_visit,
        admission_type,
        length_of_stay,
        status,
        readmitted_flag,
        primary_dx_code,
        total_billed,
        total_paid,
        total_unpaid,
        total_procedures,
        total_medications,
        total_lab_tests,
        gold_load_dt
    )
    SELECT
        -- Generate surrogate key
        ROW_NUMBER() OVER (ORDER BY e.encounter_id) AS encounter_sk,
        e.encounter_id,
        e.patient_id,
        e.provider_id,
        CAST(FORMAT(e.visit_date, 'yyyyMMdd') AS INT)      AS visit_date_sk,
        CAST(FORMAT(e.discharge_date, 'yyyyMMdd') AS INT)  AS discharge_date_sk,
        e.visit_type,
        e.department,
        e.reason_for_visit,
        e.admission_type,
        e.length_of_stay,
        e.status,
        e.readmitted_flag,
        d.diagnosis_code                                   AS primary_dx_code,
        ISNULL(c.billed_amount, 0)                         AS total_billed,
        ISNULL(c.paid_amount, 0)                           AS total_paid,
        ISNULL(c.billed_amount, 0)
            - ISNULL(c.paid_amount, 0)                     AS total_unpaid,
        ISNULL(p.total_procedures, 0)                      AS total_procedures,
        ISNULL(m.total_medications, 0)                     AS total_medications,
        ISNULL(l.total_lab_tests, 0)                       AS total_lab_tests,
        GETUTCDATE()                                       AS gold_load_dt
    FROM silver.encounters e
    LEFT JOIN silver.diagnoses d
        ON e.encounter_id = d.encounter_id
        AND d.primary_flag = 1
    LEFT JOIN silver.claims c
        ON e.encounter_id = c.encounter_id
    LEFT JOIN (
        SELECT encounter_id,
               COUNT(*) AS total_procedures
        FROM silver.procedures
        GROUP BY encounter_id
    ) p ON e.encounter_id = p.encounter_id
    LEFT JOIN (
        SELECT encounter_id,
               COUNT(*) AS total_medications
        FROM silver.medications
        GROUP BY encounter_id
    ) m ON e.encounter_id = m.encounter_id
    LEFT JOIN (
        SELECT encounter_id,
               COUNT(*) AS total_lab_tests
        FROM silver.lab_tests
        GROUP BY encounter_id
    ) l ON e.encounter_id = l.encounter_id
    WHERE e.encounter_id IS NOT NULL;

END;
GO

-- Execute
EXEC gold.load_fact_encounters;

-- =============================================
-- GOLD: fact_claims
-- Source: silver.claims
-- Rows expected: 70,000
-- Revenue cycle reporting
-- =============================================
CREATE OR ALTER PROCEDURE gold.load_fact_claims
AS
BEGIN
    TRUNCATE TABLE gold.fact_claims;

    INSERT INTO gold.fact_claims (
        claim_sk,
        claim_id,
        billing_id,
        patient_id,
        encounter_id,
        claim_date_sk,
        insurance_provider,
        payment_method,
        billed_amount,
        paid_amount,
        unpaid_amount,
        claim_status,
        is_denied,
        denial_reason,
        gold_load_dt
    )
    SELECT
        ROW_NUMBER() OVER (ORDER BY claim_id)               AS claim_sk,
        claim_id,
        billing_id,
        patient_id,
        encounter_id,
        CAST(FORMAT(claim_billing_date, 'yyyyMMdd') AS INT) AS claim_date_sk,
        insurance_provider,
        payment_method,
        billed_amount,
        paid_amount,
        ISNULL(billed_amount, 0)
            - ISNULL(paid_amount, 0)                        AS unpaid_amount,
        claim_status,
        is_denied,
        denial_reason,
        GETUTCDATE()                                        AS gold_load_dt
    FROM silver.claims
    WHERE claim_id IS NOT NULL;

END;
GO

EXEC gold.load_fact_claims;
-- =============================================
-- GOLD: fact_denials
-- Source: silver.denials
-- Rows expected: 5,998
-- Denial analytics and appeal tracking
-- =============================================
CREATE OR ALTER PROCEDURE gold.load_fact_denials
AS
BEGIN
    TRUNCATE TABLE gold.fact_denials;

    INSERT INTO gold.fact_denials (
        denial_sk,
        denial_id,
        claim_id,
        patient_id,
        denial_date_sk,
        denial_reason_code,
        denial_reason_description,
        denied_amount,
        appeal_filed,
        appeal_status,
        final_outcome,
        days_to_resolution,
        was_overturned,
        gold_load_dt
    )
    SELECT
        ROW_NUMBER() OVER (ORDER BY d.denial_id)            AS denial_sk,
        d.denial_id,
        d.claim_id,
        c.patient_id,
        CAST(FORMAT(d.denial_date, 'yyyyMMdd') AS INT)      AS denial_date_sk,
        d.denial_reason_code,
        d.denial_reason_description,
        d.denied_amount,
        d.appeal_filed,
        d.appeal_status,
        d.final_outcome,
        d.days_to_resolution,
        -- Was overturned = appeal approved
        CASE
            WHEN UPPER(d.appeal_status) = 'APPROVED' THEN 1
            ELSE 0
        END                                                 AS was_overturned,
        GETUTCDATE()                                        AS gold_load_dt
    FROM silver.denials d
    LEFT JOIN silver.claims c ON d.claim_id = c.claim_id
    WHERE d.denial_id IS NOT NULL;

END;
GO

EXEC gold.load_fact_denials;

-- =============================================
-- GOLD: fact_clinical
-- Source: silver.diagnoses + silver.encounters
--         + silver.procedures + silver.lab_tests
--         + silver.medications
-- Rows expected: ~70,000
-- Clinical quality reporting
-- =============================================
CREATE OR ALTER PROCEDURE gold.load_fact_clinical
AS
BEGIN
    TRUNCATE TABLE gold.fact_clinical;

    INSERT INTO gold.fact_clinical (
        encounter_id,
        patient_id,
        visit_date_sk,
        primary_dx_code,
        primary_dx_desc,
        chronic_condition_cnt,
        total_diagnoses,
        total_procedures,
        total_lab_tests,
        abnormal_lab_cnt,
        total_medications,
        total_procedure_cost,
        total_medication_cost,
        readmitted_flag,
        gold_load_dt
    )
    SELECT
        e.encounter_id,
        e.patient_id,
        CAST(FORMAT(e.visit_date, 'yyyyMMdd') AS INT)       AS visit_date_sk,
        pd.diagnosis_code                                   AS primary_dx_code,
        pd.diagnosis_description                            AS primary_dx_desc,
        ISNULL(cc.chronic_condition_cnt, 0)                 AS chronic_condition_cnt,
        ISNULL(td.total_diagnoses, 0)                       AS total_diagnoses,
        ISNULL(pr.total_procedures, 0)                      AS total_procedures,
        ISNULL(lt.total_lab_tests, 0)                       AS total_lab_tests,
        ISNULL(lt.abnormal_lab_cnt, 0)                      AS abnormal_lab_cnt,
        ISNULL(m.total_medications, 0)                      AS total_medications,
        ISNULL(pr.total_procedure_cost, 0)                  AS total_procedure_cost,
        ISNULL(m.total_medication_cost, 0)                  AS total_medication_cost,
        e.readmitted_flag,
        GETUTCDATE()                                        AS gold_load_dt
    FROM silver.encounters e
    LEFT JOIN silver.diagnoses pd
        ON e.encounter_id = pd.encounter_id
        AND pd.primary_flag = 1
    LEFT JOIN (
        SELECT encounter_id,
               SUM(CAST(chronic_flag AS INT)) AS chronic_condition_cnt
        FROM silver.diagnoses
        GROUP BY encounter_id
    ) cc ON e.encounter_id = cc.encounter_id
    LEFT JOIN (
        SELECT encounter_id,
               COUNT(*) AS total_diagnoses
        FROM silver.diagnoses
        GROUP BY encounter_id
    ) td ON e.encounter_id = td.encounter_id
    LEFT JOIN (
        SELECT encounter_id,
               COUNT(*)            AS total_procedures,
               SUM(procedure_cost) AS total_procedure_cost
        FROM silver.procedures
        GROUP BY encounter_id
    ) pr ON e.encounter_id = pr.encounter_id
    LEFT JOIN (
        SELECT encounter_id,
               COUNT(*)                      AS total_lab_tests,
               SUM(CAST(is_abnormal AS INT)) AS abnormal_lab_cnt
        FROM silver.lab_tests
        GROUP BY encounter_id
    ) lt ON e.encounter_id = lt.encounter_id
    LEFT JOIN (
        SELECT encounter_id,
               COUNT(*) AS total_medications,
               SUM(cost) AS total_medication_cost
        FROM silver.medications
        GROUP BY encounter_id
    ) m ON e.encounter_id = m.encounter_id
    WHERE e.encounter_id IS NOT NULL;
END;
GO

EXEC gold.load_fact_clinical;

-- =============================================
-- GOLD: fact_provider_performance
-- Source: silver.encounters + silver.claims
--         + silver.procedures + silver.medications
-- Provider-level monthly performance metrics
-- =============================================
CREATE OR ALTER PROCEDURE gold.load_fact_provider_performance
AS
BEGIN
    TRUNCATE TABLE gold.fact_provider_performance;

    INSERT INTO gold.fact_provider_performance (
        provider_id,
        year_month,
        department,
        specialty,
        total_encounters,
        avg_length_of_stay,
        total_billed,
        total_paid,
        readmission_count,
        readmission_rate,
        total_procedures,
        avg_procedure_cost,
        total_medications,
        gold_load_dt
    )
    SELECT
        e.provider_id,
        FORMAT(e.visit_date, 'yyyy-MM')                    AS year_month,
        p.department,
        p.specialty,
        COUNT(DISTINCT e.encounter_id)                     AS total_encounters,
        AVG(CAST(e.length_of_stay AS FLOAT))               AS avg_length_of_stay,
        SUM(ISNULL(c.billed_amount, 0))                    AS total_billed,
        SUM(ISNULL(c.paid_amount, 0))                      AS total_paid,
        SUM(CAST(ISNULL(e.readmitted_flag,0) AS INT))      AS readmission_count,
        CASE
            WHEN COUNT(DISTINCT e.encounter_id) > 0
            THEN CAST(SUM(CAST(ISNULL(e.readmitted_flag,0) AS INT)) AS FLOAT)
                / COUNT(DISTINCT e.encounter_id)
            ELSE 0
        END                                                AS readmission_rate,
        COUNT(DISTINCT pr.procedure_id)                    AS total_procedures,
        CASE
            WHEN COUNT(DISTINCT pr.procedure_id) > 0
            THEN SUM(ISNULL(pr.procedure_cost,0))
                / COUNT(DISTINCT pr.procedure_id)
            ELSE 0
        END                                                AS avg_procedure_cost,
        COUNT(DISTINCT m.medication_id)                    AS total_medications,
        GETUTCDATE()                                       AS gold_load_dt
    FROM silver.encounters e
    LEFT JOIN silver.providers p
        ON e.provider_id = p.provider_id
    LEFT JOIN silver.claims c
        ON e.encounter_id = c.encounter_id
    LEFT JOIN silver.procedures pr
        ON e.encounter_id = pr.encounter_id
    LEFT JOIN silver.medications m
        ON e.encounter_id = m.encounter_id
    WHERE e.provider_id IS NOT NULL
    AND e.visit_date IS NOT NULL
    GROUP BY
        e.provider_id,
        FORMAT(e.visit_date, 'yyyy-MM'),
        p.department,
        p.specialty;
END;
GO

EXEC gold.load_fact_provider_performance;


-- =============================================
-- GOLD: fact_monthly_kpis
-- Source: silver.encounters + silver.claims
--         + silver.denials + silver.lab_tests
-- Pre-aggregated monthly KPIs
-- Powers executive dashboard in Power BI
-- =============================================
CREATE OR ALTER PROCEDURE gold.load_fact_monthly_kpis
AS
BEGIN
    TRUNCATE TABLE gold.fact_monthly_kpis;

    INSERT INTO gold.fact_monthly_kpis (
        year_month,
        department,
        visit_type,
        total_encounters,
        avg_length_of_stay,
        readmission_count,
        readmission_rate,
        total_billed,
        total_paid,
        total_unpaid,
        collection_rate,
        total_denials,
        denial_rate,
        appeals_filed,
        appeals_overturned,
        overturn_rate,
        total_procedures,
        total_lab_tests,
        abnormal_lab_rate,
        gold_load_dt
    )
    SELECT
        FORMAT(e.visit_date, 'yyyy-MM')                    AS year_month,
        e.department,
        e.visit_type,
        COUNT(DISTINCT e.encounter_id)                     AS total_encounters,
        -- Cap LOS at 999.99
        CAST(ISNULL(AVG(CAST(
            CASE WHEN e.length_of_stay > 999 
            THEN NULL 
            ELSE e.length_of_stay END AS FLOAT)),0) 
            AS DECIMAL(10,2))                              AS avg_length_of_stay,
        SUM(CAST(ISNULL(e.readmitted_flag,0) AS INT))      AS readmission_count,
        CAST(CASE
            WHEN COUNT(DISTINCT e.encounter_id) > 0
            THEN CAST(SUM(CAST(ISNULL(e.readmitted_flag,0) AS INT)) AS FLOAT)
                / COUNT(DISTINCT e.encounter_id)
            ELSE 0
        END AS DECIMAL(10,4))                              AS readmission_rate,
        SUM(ISNULL(c.billed_amount, 0))                    AS total_billed,
        SUM(ISNULL(c.paid_amount, 0))                      AS total_paid,
        SUM(ISNULL(c.billed_amount,0)
            - ISNULL(c.paid_amount,0))                     AS total_unpaid,
        CAST(CASE
            WHEN SUM(ISNULL(c.billed_amount,0)) > 0
            THEN SUM(ISNULL(c.paid_amount,0))
                / SUM(ISNULL(c.billed_amount,0))
            ELSE 0
        END AS DECIMAL(10,4))                              AS collection_rate,
        COUNT(DISTINCT CASE WHEN c.is_denied = 1
            THEN c.claim_id END)                           AS total_denials,
        CAST(CASE
            WHEN COUNT(DISTINCT c.claim_id) > 0
            THEN CAST(COUNT(DISTINCT CASE WHEN c.is_denied = 1
                THEN c.claim_id END) AS FLOAT)
                / COUNT(DISTINCT c.claim_id)
            ELSE 0
        END AS DECIMAL(10,4))                              AS denial_rate,
        ISNULL(SUM(CAST(d.appeal_filed AS INT)), 0)        AS appeals_filed,
        COUNT(DISTINCT CASE
            WHEN UPPER(d.appeal_status) = 'APPROVED'
            THEN d.denial_id END)                          AS appeals_overturned,
        CAST(CASE
            WHEN ISNULL(SUM(CAST(d.appeal_filed AS INT)),0) > 0
            THEN CAST(COUNT(DISTINCT CASE
                WHEN UPPER(d.appeal_status) = 'APPROVED'
                THEN d.denial_id END) AS FLOAT)
                / NULLIF(SUM(CAST(d.appeal_filed AS INT)),0)
            ELSE 0
        END AS DECIMAL(10,4))                              AS overturn_rate,
        COUNT(DISTINCT pr.procedure_id)                    AS total_procedures,
        COUNT(DISTINCT lt.lab_id)                          AS total_lab_tests,
        CAST(CASE
            WHEN COUNT(DISTINCT lt.lab_id) > 0
            THEN CAST(SUM(CAST(ISNULL(lt.is_abnormal,0) AS INT)) AS FLOAT)
                / COUNT(DISTINCT lt.lab_id)
            ELSE 0
        END AS DECIMAL(10,4))                              AS abnormal_lab_rate,
        GETUTCDATE()                                       AS gold_load_dt
    FROM silver.encounters e
    LEFT JOIN silver.claims c
        ON e.encounter_id = c.encounter_id
    LEFT JOIN silver.denials d
        ON c.claim_id = d.claim_id
    LEFT JOIN silver.procedures pr
        ON e.encounter_id = pr.encounter_id
    LEFT JOIN silver.lab_tests lt
        ON e.encounter_id = lt.encounter_id
    WHERE e.visit_date IS NOT NULL
    GROUP BY
        FORMAT(e.visit_date, 'yyyy-MM'),
        e.department,
        e.visit_type;
END;
GO

EXEC gold.load_fact_monthly_kpis;
