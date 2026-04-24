/*
Master Pipeline Procedure: dbo.run_full_pipeline

This procedure orchestrates the full data warehouse pipeline using a Medallion Architecture.

It executes all Silver and Gold layer transformations in sequence:
*/

CREATE OR ALTER PROCEDURE dbo.run_full_pipeline
AS
BEGIN
    -- Silver
    EXEC silver.load_patients;
    EXEC silver.load_encounters;
    EXEC silver.load_claims;
    EXEC silver.load_denials;
    EXEC silver.load_diagnoses;
    EXEC silver.load_procedures;
    EXEC silver.load_lab_tests;
    EXEC silver.load_medications;
    EXEC silver.load_providers;
    -- Gold
    EXEC gold.load_dim_date;
    EXEC gold.load_dim_patient;
    EXEC gold.load_dim_provider;
    EXEC gold.load_fact_encounters;
    EXEC gold.load_fact_claims;
    EXEC gold.load_fact_denials;
    EXEC gold.load_fact_clinical;
    EXEC gold.load_fact_monthly_kpis;
    EXEC gold.load_fact_provider_performance;
END;
GO

---Usage:
EXEC dbo.run_full_pipeline;
