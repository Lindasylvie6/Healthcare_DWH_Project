## 📊 Consume Layer – Power BI Analytics

The Consume Layer represents the final stage of the medallion architecture, where curated Gold Layer data is transformed into actionable insights through interactive Power BI dashboards.

This layer enables business users, analysts, and stakeholders to explore healthcare data through intuitive visualizations and key performance indicators (KPIs).

---
#### 🎯 Objectives
- Deliver business-ready insights from trusted data models
- Enable self-service analytics for stakeholders
- Monitor financial, operational, and clinical performance
- Support data-driven decision making in healthcare

---
#### 🏗️ Data Source

All dashboards are built on top of the Gold Layer star schema, including:

- dim_patient
- dim_provider
- dim_date
- fact_encounters
- fact_claims
- fact_denials
- fact_clinical
- fact_monthly_kpis
- fact_provider_performance

---
#### 📌 Dashboards Overview
##### 1. 🧠 Executive Summary

Provides a high-level overview of hospital performance.

###### Key Metrics:

- Total Encounters: 70K
- Total Billed: $437M
- Denial Rate: 8.5%
- Readmission Rate: 15.7%

###### Insights:

- Monthly readmission trend analysis
- Billed vs Paid comparison
- Encounter distribution by department
- Denial rate breakdown across departments
  
 ##### 2. 🏥 Clinical Quality

Focuses on patient outcomes and care quality.

###### Key Visuals:

- Length of Stay by Department
- Readmission Rate by Specialty
- Chronic Condition Distribution

###### Insights:

- Identifies departments with longer stays
- Highlights high readmission areas
- Tracks prevalence of chronic conditions

##### 3. 💰 Revenue Cycle

Analyzes financial performance and claims efficiency.

###### Key Visuals:

- Denial Rate by Payer
- Appeal Success Rate (30.89%)
- Billed vs Paid Amount by Insurance Provider

###### Insights:

- Detects underperforming payers
- Measures revenue leakage
- Tracks claim recovery effectiveness

---
#### 📈 Key Business Impact

- Improved visibility into hospital operations
- Early detection of data quality issues (e.g., incorrect readmission logic)
- Enhanced revenue cycle transparency
- Better tracking of clinical outcomes
- Empowered stakeholders with real-time insights

---
#### ⚙️ Tools & Technologies

- Power BI : Data visualization & dashboarding
- DAX : KPI calculations & measures
- SQL Server : Data source (Gold Layer)
- Star Schema Modeling : Optimized for analytics

---
##### 💡 Highlights
- Built on a Medallion Architecture (Bronze → Silver → Gold → Consume)
- Designed for healthcare analytics use cases
- Focused on real-world KPIs (readmissions, denials, revenue)
- Demonstrates end-to-end data engineering + analytics workflow

---
##### 📸 Dashboard Preview
<img width="1440" height="900" alt="Screenshot 2026-04-28 at 4 55 50 PM" src="https://github.com/user-attachments/assets/8f4e802d-307c-4f09-8b2b-c0d32f270a0f" />
<img width="1440" height="900" alt="Screenshot 2026-04-29 at 4 51 42 PM" src="https://github.com/user-attachments/assets/438ec57e-e8ad-4726-976e-0b157e765864" />
<img width="1440" height="900" alt="Screenshot 2026-04-29 at 2 22 03 PM" src="https://github.com/user-attachments/assets/af6bbdec-653a-4f0d-b901-05c22aa5d6a5" />


