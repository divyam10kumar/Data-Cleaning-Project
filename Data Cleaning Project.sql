-- 📌 Step 1: View Original Table
SELECT * 
FROM layoffs;

-- ------------------------------------------------------
-- 🧹 Step 2: Create Staging Table to Work On (layoffs_staging)
-- This avoids modifying the original data
-- ------------------------------------------------------
CREATE TABLE layoffs_staging
LIKE layoffs;

-- Copy data from original table into staging
INSERT INTO layoffs_staging
SELECT *
FROM layoffs;

-- ------------------------------------------------------
-- 🔍 Step 3: Identify Duplicates using ROW_NUMBER()
-- ------------------------------------------------------
-- Assign row numbers partitioned by key identifying columns
SELECT *, 
	ROW_NUMBER() OVER (
		PARTITION BY company, location, industry, total_laid_off, `date`, stage, country, funds_raised_millions
	) AS row_num
FROM layoffs_staging;

-- Using CTE to filter duplicate rows
WITH duplicate_cte AS (
	SELECT *, 
		ROW_NUMBER() OVER (
			PARTITION BY company, location, industry, total_laid_off, `date`, stage, country, funds_raised_millions
		) AS row_num
	FROM layoffs_staging
)
SELECT * 
FROM duplicate_cte
WHERE row_num > 1;

-- Optional: Check a specific company
SELECT * 
FROM layoffs_staging
WHERE company = 'Advata';

-- ------------------------------------------------------
-- 🧱 Step 4: Create Cleaned Staging Table (layoffs_staging2)
-- Adds a row_num column for later deduplication
-- ------------------------------------------------------
CREATE TABLE layoffs_staging2 (
  company TEXT,
  location TEXT,
  industry TEXT,
  total_laid_off INT DEFAULT NULL,
  percentage_laid_off TEXT,
  `date` TEXT,
  stage TEXT,
  country TEXT,
  funds_raised_millions INT DEFAULT NULL,
  row_num INT
);

-- Insert data with row numbers to help remove duplicates
INSERT INTO layoffs_staging2
SELECT *, 
	ROW_NUMBER() OVER (
		PARTITION BY company, location, industry, total_laid_off, `date`, stage, country, funds_raised_millions
	) AS row_num
FROM layoffs_staging;

-- Remove duplicate rows (where row_num > 1)
DELETE 
FROM layoffs_staging2
WHERE row_num > 1;

-- Check result
SELECT * 
FROM layoffs_staging2;

-- ------------------------------------------------------
-- ✨ Step 5: Standardize Company Names (Trim spaces)
-- ------------------------------------------------------
-- Preview trimming effect
SELECT company, TRIM(company)
FROM layoffs_staging2;

-- Update trimmed values
UPDATE layoffs_staging2
SET company = TRIM(company);

-- ------------------------------------------------------
-- ✨ Step 6: Clean & Standardize Industry and Country
-- ------------------------------------------------------
-- Fix inconsistent industry names like "Crypto Blockchain" → "Crypto"
SELECT DISTINCT industry
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- Fix country names like "United States." → "United States"
SELECT *
FROM layoffs_staging2
WHERE country LIKE 'United States%';

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

-- ------------------------------------------------------
-- 🗓️ Step 7: Standardize Date Format to DATE type
-- ------------------------------------------------------
-- Preview conversion
SELECT `date`, STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoffs_staging2;

-- Apply conversion
UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

-- Alter column type from TEXT to DATE
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

-- ------------------------------------------------------
-- ❓ Step 8: Handle Missing or Null Values
-- ------------------------------------------------------
-- Find rows with no total or percentage laid off
SELECT * 
FROM layoffs_staging2
WHERE total_laid_off IS NULL 
AND percentage_laid_off IS NULL;

-- Identify null or empty industries
SELECT DISTINCT industry
FROM layoffs_staging2
WHERE industry IS NULL OR industry = '';

-- Fix blanks in industry column by converting '' → NULL
UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

-- Auto-fill missing industry using values from same company
SELECT t1.industry, t2.industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2 ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = '')
  AND t2.industry IS NOT NULL;

-- Apply update using self-join
UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2 ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL 
  AND t2.industry IS NOT NULL;

-- Recheck cleaned data
SELECT * 
FROM layoffs_staging2;

-- ------------------------------------------------------
-- 🧹 Step 9: Remove Fully Null Rows (no layoff info)
-- ------------------------------------------------------
SELECT * 
FROM layoffs_staging2
WHERE total_laid_off IS NULL 
AND percentage_laid_off IS NULL;

DELETE 
FROM layoffs_staging2
WHERE total_laid_off IS NULL 
AND percentage_laid_off IS NULL;

-- ------------------------------------------------------
-- 🧽 Step 10: Drop row_num Column (no longer needed)
-- ------------------------------------------------------
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

-- ✅ Final cleaned dataset:
SELECT *
FROM layoffs_staging2;
