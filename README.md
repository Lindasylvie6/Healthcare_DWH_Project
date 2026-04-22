# Healthcare Data Warehouse and Analytics Project
---
### 🚀 Overview

This project demonstrates the design of an end-to-end healthcare data pipeline using Azure Data Factory concepts and a **medallion architecture** (Bronze, Silver, Gold). It incorporates **ETL processes**, **SQL**-based data transformation, and data modeling to ingest, clean, and standardize raw datasets into analytics-ready data.

The project emphasizes **data integration, data quality validation, and troubleshooting**, reflecting core data engineering responsibilities such as **building, optimizing, and maintaining scalable data pipelines**. 

---

### 🧱 Data Architecture (Medallion Model)
The pipeline is orchestrated using Azure Data Factory, which manages ingestion, transformation, and data movement across layers.
<img width="716" height="535" alt="DWH_Architecture" src="https://github.com/user-attachments/assets/dbec3efd-2558-4b25-876f-2e091290f961" />

#### 🟤 Bronze Layer (Raw Data)
- Stores raw CSV files as-is
- Minimal transformation
- Batch ingestion
  
#### 🥈 Silver Layer (Cleaned Data)
- Data cleaning and standardization
- Deduplication and validation
- Ensures data quality
  
#### 🥇 Gold Layer (Business-Ready Data)
- Business logic and aggregations
- Star schema (fact and dimension tables)
- Optimized for reporting

#### 📊 Consume Layer
- Power BI dashboards
- Reports and analytics
- End-user data access

---
### ⚙️ Data Pipeline (ADF)
- Pipeline orchestration using Azure Data Factory
- Copy Activity for ingestion
- Data Flows / SQL for transformations
- Scheduling and monitoring
- Error handling and logging

---
### 🧪 Data Quality & Validation
- Removed duplicate records
- Handled missing values
- Validated primary and foreign keys
- Standardized formats (dates, text fields)
- Ensured referential integrity

---
### 📊 Example Use Cases
- Patient visit analysis
- Provider performance tracking
- Claims and billing insights
- Denial rate analysis

---
### 🛠️ Tools & Technologies

- **Azure Data Factory (Concepts)** : Pipeline orchestration, data ingestion, and transformation  
- **SQL** : Data transformation, validation, and modeling  
- **Tableau Public** : Data visualization and reporting  
- **Draw.io** : Data architecture and pipeline diagrams  
- **Notion** : Project planning, task tracking, and documentation  

---
### License

This project is licensed under the [MIT LICENSE](LICENSE). You are free to use, modify, and share this project with proper attribution.

---
### 👤 About me

Hi there! I 'm **Sylvie Linda**. I am a data professional with experience in data analysis and a strong interest in data engineering. I enjoy working with data pipelines, transforming raw data into meaningful insights, and improving data quality and efficiency.

This project reflects my focus on building scalable data solutions and applying best practices in data engineering, including ETL processes, data modeling, and pipeline design.
