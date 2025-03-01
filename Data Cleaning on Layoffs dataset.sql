-- DATA CLEANING

--view data
select *
from layoffs

----Steps taken for this data cleaning
--1. change to right data types for the columns
--2. Remove duplicates
--3. Standardize the data
--4. Handling null values or blank
--5. Remove any rows or columns not needed

--lets create table to begin as we are going to change a lot in the data
SELECT TOP 0 * INTO layoffs_staging1
FROM layoffs;

select *
from layoffs_staging1

--Duplicate the data into layoffs_staging1
INSERT INTO layoffs_staging1
SELECT *
FROM layoffs;


----1. change to right data types for the columns
--converting the data while handling the nulls in the columns
SELECT 
    company, 
    location, 
    industry, 
    -- Handle NULL and convert valid numeric values to BIGINT
    CASE 
        WHEN total_laid_off IS NULL THEN NULL 
        ELSE TRY_CAST(total_laid_off AS bigint) 
    END AS total_laid_off,
    
    -- Handle NULL and convert valid percentage to DECIMAL
    CASE 
        WHEN percentage_laid_off IS NULL THEN NULL 
        ELSE TRY_CAST(percentage_laid_off AS decimal(10, 2)) 
    END AS percentage_laid_off,
    
    -- Handle NULL and convert date strings to DATE format
    CASE 
        WHEN [date] IS NULL THEN NULL 
        ELSE TRY_CAST(CAST([date] AS nvarchar(50)) AS DATE) 
    END AS [date],
    
    stage, 
    country, 
    
    -- Handle NULL and convert valid numeric values to BIGINT
    CASE 
        WHEN funds_raised_millions IS NULL THEN NULL 
        ELSE TRY_CAST(funds_raised_millions AS bigint) 
    END AS funds_raised_millions
FROM layoffs_staging1;

--update of the converted data into the table
UPDATE layoffs_staging1
SET 
    total_laid_off = CASE 
        WHEN total_laid_off IS NULL THEN NULL 
        ELSE TRY_CAST(total_laid_off AS bigint) 
    END,
    percentage_laid_off = CASE 
        WHEN percentage_laid_off IS NULL THEN NULL 
        ELSE TRY_CAST(percentage_laid_off AS decimal(10, 2)) 
    END,
    [date] = CASE 
        WHEN [date] IS NULL THEN NULL 
        ELSE TRY_CAST([date] AS DATE) 
    END,
    funds_raised_millions = CASE 
        WHEN funds_raised_millions IS NULL THEN NULL 
        ELSE TRY_CAST(funds_raised_millions AS bigint) 
    END;

--modifying the table to reflect the update

ALTER TABLE layoffs_staging1
ALTER COLUMN total_laid_off BIGINT;

ALTER TABLE layoffs_staging1
ALTER COLUMN percentage_laid_off DECIMAL(10, 2);

ALTER TABLE layoffs_staging1
ALTER COLUMN funds_raised_millions BIGINT;

ALTER TABLE layoffs_staging1
ALTER COLUMN [date] DATE;


--confirming number of data in the columns containing nulls
select count(funds_raised_millions)
	from layoffs_staging1

SELECT COUNT(*)
FROM layoffs_staging1
WHERE funds_raised_millions is NULL;



----2. Remove duplicates
--checking for duplicates
select *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, [date], stage, country, funds_raised_millions
ORDER BY [date]) AS row_num
FROM layoffs_staging1

--viewing the duplicates
WITH duplicate_cte AS
(
    SELECT *,
           ROW_NUMBER() OVER (
    PARTITION BY 
           company, location, industry, total_laid_off, percentage_laid_off, [date], stage, country, funds_raised_millions
    ORDER BY [date]
           ) AS row_num
    FROM layoffs_staging1
)
select *
from duplicate_cte
where row_num > 1

--deleting the duplicates
WITH duplicate_cte AS
(
    SELECT *,
           ROW_NUMBER() OVER (
    PARTITION BY 
           company, location, industry, total_laid_off, percentage_laid_off, [date], stage, country, funds_raised_millions
    ORDER BY [date]
           ) AS row_num
    FROM layoffs_staging1
)
delete
from duplicate_cte
where row_num > 1



----3. Standardizing data
--viewing the columns to identify issues
select distinct company
from layoffs_staging1
order by 1

select distinct location
from layoffs_staging1
order by 1

select distinct industry
from layoffs_staging1
order by 1

select distinct stage
from layoffs_staging1
order by 1

select distinct country
from layoffs_staging1
order by 1

--remove "." from United States
select distinct country, TRIM (TRAILING '.' FROM country)
from layoffs_staging1
where country like 'United States%'
order by 1

UPDATE layoffs_staging1
SET country = TRIM (TRAILING '.' FROM country)
where country like 'United States%'


--remove leading and trailing spaces from string-based columns.
UPDATE layoffs_staging1
SET 
    company = LTRIM(RTRIM(company)),
    location = LTRIM(RTRIM(location)),
    industry = LTRIM(RTRIM(industry)),
    stage = LTRIM(RTRIM(stage)),
    country = LTRIM(RTRIM(country));

select *
from layoffs_staging1



----4. Handling nulls or blank
select *
from layoffs_staging1
where industry = '' or industry = 'null'

--checking if i can match industry name to same having nulls
select *
from layoffs_staging1
where company = 'airbnb'

--checking using a self join if i could match industry name to same having nulls
select *
from layoffs_staging1 t1
join layoffs_staging1 t2
     on t1.company=t2.company
where (t1.industry = '' or t1.industry = 'null')
and (t2.industry != '' or t2.industry != 'null')

--industry name was discovered for some nulls, so below was used to update same in the table
UPDATE t1
SET t1.industry = t2.industry
FROM layoffs_staging1 t1
JOIN layoffs_staging1 t2
    ON t1.company = t2.company
WHERE (t1.industry = '' OR t1.industry = 'null')
AND (t2.industry != '' AND t2.industry != 'null');



----5. deleting rows/columns not needed in this analysis
--checking for nulls in columns that are important
select *
from layoffs_staging1
where total_laid_off is null
and percentage_laid_off is null

--delete rows not important as above
delete
from layoffs_staging1
where total_laid_off is null
and percentage_laid_off is null

--viewing the cleaned data
select *
from layoffs_staging1






