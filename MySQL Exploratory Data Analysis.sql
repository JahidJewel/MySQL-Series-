----------  Exploratory Data  analysis




Select * from layoffs_staging2;

Select max(total_laid_off) , max(percentage_laid_off)
from layoffs_staging2;



Select *
from layoffs_staging2
where percentage_laid_off =1
order by total_laid_off desc
;


select company, sum(total_laid_off)
from layoffs_staging2
group by company
order by 2 desc;


select industry, sum(total_laid_off)
from layoffs_staging2
group by industry
order by 2 desc;



select country, sum(total_laid_off)
from layoffs_staging2
group by country
order by 2 desc;


select year(`date`), sum(total_laid_off)
from layoffs_staging2
group by year(`date`)
order by 1 desc;



select substring(`date`, 1, 7) as `month`, sum(total_laid_off)
from layoffs_staging2
where substring(`date`, 1, 7) is not null
group by `month`
order by 1 asc;



with Rolling_Total as 
(
select substring(`date`, 1, 7) as `month`, sum(total_laid_off) as total_off
from layoffs_staging2
where substring(`date`, 1, 7) is not null
group by `month`
order by 1 asc
)
select `month`, total_off, 
sum(total_off) over (order by `month`) as rolling_total
from Rolling_Total;


select company, sum(total_laid_off)
from layoffs_staging2
group by company
order by 2 desc; 

select company, year(`date`), sum(total_laid_off)
from layoffs_staging2
group by company, year(`date`)
order by company asc

;



with company_year(comapny, years, total_laid_off) as
(
select company, year(`date`), sum(total_laid_off)
from layoffs_staging2
group by company, year(`date`)
), company_year_rank as (
		select *, 
dense_rank() over (partition by years order by total_laid_off desc) as ranking
from company_year
where years is not null
)

select *
from company_year_rank
where ranking <=5


;
