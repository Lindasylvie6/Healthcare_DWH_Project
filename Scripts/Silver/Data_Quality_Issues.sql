/*
Readmission Rate Data Quality Validation

While building the Power BI dashboard, the readmission rate initially appeared as **52%**, which seemed clinically unrealistic.

I first checked the Power BI model, column relationships, and DAX logic. After confirming that the dashboard logic was working as expected, I traced the issue back to the warehouse layer.

Using SQL validation queries, I analyzed `visit_type`, `encounter_id`, and `readmitted_flag` in the Silver and Gold layers. The investigation showed that the source data contained `readmitted_flag = TRUE` for `Outpatient` and `Telehealth` visits, which is not clinically appropriate because readmission logic should only apply to inpatient encounters.

The corrected inpatient-only readmission rate was **16%**, which is much more reasonable for healthcare reporting.

This validation improved the accuracy of the Gold Layer KPI logic and ensured that the Power BI dashboard reflects clinically meaningful metrics.
*/
/* Identified wrong metric in Power BI
        ↓
Traced it back to gold layer SQL
        ↓
Traced it back to silver layer data quality
        ↓
Fixed at the correct layer (silver)
        ↓
Reloaded gold layer
        ↓
Refreshed Power BI
*/

---SQL DATA TROUBLESHOOTING QUERIES:
---data quality check
SELECT 
    visit_type,
    COUNT(*) AS total_encounters,
    SUM(CAST(ISNULL(readmitted_flag,0) AS INT)) AS readmissions,
    CAST(SUM(CAST(ISNULL(readmitted_flag,0) AS INT)) AS FLOAT) 
        / COUNT(*) AS rate
FROM silver.encounters
GROUP BY visit_type
ORDER BY visit_type


SELECT 
    readmitted_flag,
    COUNT(*) AS count
FROM silver.encounters
GROUP BY readmitted_flag

-- Should return 0 rows after the fix
SELECT visit_type, COUNT(*) 
FROM silver.encounters
WHERE readmitted_flag = 1
AND visit_type != 'Inpatients'
GROUP BY visit_type

--- Fix data quality issue in silver layer
UPDATE silver.encounters
SET readmitted_flag = 0
WHERE visit_type IN ('Outpatient', 'Telehealth', 'Emergency')
AND readmitted_flag = 1
--- Reload the Gold Layer
EXEC gold.load_fact_monthly_kpis
