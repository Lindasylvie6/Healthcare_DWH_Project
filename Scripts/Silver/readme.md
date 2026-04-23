# SILVER LAYER – DATA CLEANING, STANDARDIZATION, VALIDATION

#### Description:
This script creates the Silver layer of the healthcare data warehouse.
The Silver layer transforms raw Bronze data into cleaned, structured,
and validated tables that are ready for downstream business logic.

#### Purpose:
- Improve data quality and consistency
- Standardize raw string-based fields into proper SQL data types
- Apply validation and light transformation rules
- Add derived columns that support analysis
- Prepare trusted datasets for the Gold layer
---
## Bronze to Silver Data Changes

The following examples show how raw Bronze fields were cleaned and standardized 
in the Silver layer to improve data quality and analytical usability.

#### Key Transformations:
- Convert VARCHAR dates into DATE
- Convert numeric text fields into DECIMAL
- Standardize boolean flags into BIT
- Create derived metrics and helper columns
- Preserve grain while improving usability

#### Design Approach:
- Bronze stores raw source data as-is
- Silver applies cleaning and standardization
- Gold will handle business logic, aggregations, and reporting models

#### Notes:
- Silver tables are built from Bronze tables
- Transformation logic focuses on structure and data quality, not reporting
- This layer creates the trusted foundation for analytics

=============================================================
