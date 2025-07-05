# Data-Cleaning-Project
📊 SQL Data Cleaning Project — Layoffs Dataset
This project demonstrates a complete data cleaning pipeline using SQL, focused on preparing a real-world layoffs dataset for accurate and insightful analysis. The entire process was performed using MySQL, leveraging staging tables, window functions, and string/date operations to refine the data.

✅ Project Objectives

The key steps carried out in this project include:

-- Remove Duplicates
Used ROW_NUMBER() with PARTITION BY to identify and delete duplicate records based on key columns like company, location, date, and layoff details.

--Standardize the Data
Applied TRIM(), pattern matching (LIKE), and date formatting functions (STR_TO_DATE) to correct inconsistencies in textual and date fields like company, industry, country, and date.

--Handle Null or Blank Values
Identified and treated missing entries in columns like industry, total_laid_off, and percentage_laid_off. Also used self-joins to fill missing values by referencing complete records of the same company.

--Remove Unnecessary Columns
Dropped helper columns like row_num after their purpose (deduplication) was fulfilled to ensure a clean final dataset.

🛠 Tools & Techniques Used

-- MySQL

-- Window Functions (ROW_NUMBER())

-- String Functions (TRIM, LIKE)

-- Date Conversion (STR_TO_DATE)

-- CTEs and Subqueries

-- Data Validation & Cleanup



📌 Outcomes

-- A clean, analysis-ready dataset

-- Eliminated redundancies and formatting errors

-- Improved consistency across categorical fields

-- Ready for use in dashboards (Power BI, Tableau) or further analytics


