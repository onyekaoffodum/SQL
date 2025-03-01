--EXPLORATORY DATA ANALYSIS

--maximum number laid off and maximum percentage laid off
select max(total_laid_off) as highest_no_laid_off, max(percentage_laid_off) as highest_percent_laid_off
from layoffs_staging1

--companies that laid off all staff in order of highest funds raised descending
select *
from layoffs_staging1
where percentage_laid_off = 1
order by funds_raised_millions desc

--total laid off in companies
select company, sum(total_laid_off) as total_laid_off
from layoffs_staging1
group by company
order by 2 desc

--date period of laid off
select min([date]), max([date])
from layoffs_staging1

--number laid off each year
select year([date]) as year, sum(total_laid_off) as total_laid_off
from layoffs_staging1
group by YEAR([date])
order by 1 desc

--number laid off for each stage
select stage, sum(total_laid_off) as total_laid_off
from layoffs_staging1
group by stage
order by 2 desc

--percentage laid off in companies
select company, sum(percentage_laid_off) as percent_laid_off
from layoffs_staging1
group by company
order by 2 desc

--total laid off on monthly basis
SELECT 
    FORMAT([date], 'yyyy-MM') AS year_month,
    SUM(total_laid_off) AS total_laid_off_sum
FROM layoffs_staging1
Where FORMAT([date], 'yyyy-MM') is not null
GROUP BY FORMAT([date], 'yyyy-MM')
ORDER BY year_month;

--total laid off on monthly progression
WITH Rolling_Total AS
(
    SELECT 
        FORMAT([date], 'yyyy-MM') AS year_month, -- Year and month in 'YYYY-MM' format
        SUM(total_laid_off) AS total_laid_off_sum
    FROM layoffs_staging1
    WHERE [date] IS NOT NULL
    GROUP BY FORMAT([date], 'yyyy-MM') -- Group by formatted year and month
)
SELECT 
    year_month,total_laid_off_sum,
    SUM(total_laid_off_sum) OVER (ORDER BY year_month ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS rolling_total
FROM Rolling_Total
ORDER BY year_month;

--total laid off in companies yearly
select company, year([date]) as year, sum(total_laid_off) as total_laid_off
from layoffs_staging1
group by company,year([date])
order by 3 desc

--top 5 companies that laid off yearly
WITH Company_Year (company, years, total_laid_off) AS
(
select company, year([date]), sum(total_laid_off)
from layoffs_staging1
group by company,year([date])
), 
company_year_rank as
(select *,
dense_rank() over (partition by years order by total_laid_off desc) as ranking
from Company_Year
where years is not null
)
select *
from company_year_rank
where ranking <= 5