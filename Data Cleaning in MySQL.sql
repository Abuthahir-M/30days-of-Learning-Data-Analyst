-- DATA CLEANING

	# create new schema
	# import dataset as csv files it is raw data in to tables

SELECT *
FROM layoffs;
 
-- 1. Remove Duplicates
-- 2. Standardize the Data
-- 3. Null values and Blank values
-- 4. Remove the columns and rows if necessary

	# create copy of raw Data to work and it is called as staging

CREATE TABLE layoffs_staging
LIKE layoffs;

SELECT *
FROM layoffs_staging;

	# copy the raw data to new table

INSERT layoffs_staging
SELECT *
FROM layoffs;

	# remove the duplicate through row_number

select *,
row_number() over(
partition by company, industry, total_laid_off, percentage_laid_off, `date`) as row_num
from layoffs_staging;

with duplicate_cte as
(
select *,
row_number() over(
partition by company, industry, total_laid_off, percentage_laid_off, `date`) as row_num
from layoffs_staging
)
select * from duplicate_cte
where row_num > 1;

	# need to check it is correctly marked as duplicates so here we go
    # check with any company name

select * from layoffs_staging
where company = 'oda';
	# look the funds_raised_millions column this is technically not duplicate

	# change the CTE partition by to every columns like below
    
with duplicate_cte as
(
select *,
row_number() over(
partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
from layoffs_staging
)
select * from duplicate_cte
where row_num > 1;
	# look at the compant name "oda" is not there because "oda" is not a duplicate

	# again need to check it is correctly marked as duplicates so here we go
    # check with any company name

select * from layoffs_staging
where company = 'Casper';
	# yes there is duplicates there is check with date there is 2 duplicates in 2021
    # remove the only one row
    
    # copy Data to another table as staging2 to delect the duplicates

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT		# add this column form staging table to add data
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

select * from layoffs_staging2;

	# add data into staging2 table with below query to find the duplicates as row_number

INSERT INTO layoffs_staging2
select *,
row_number() over(
partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
from layoffs_staging;

select * from layoffs_staging2;

	# check the duplicates
    
select * from layoffs_staging2
where row_num > 1;
	
    # delete the duplicates from table staging2

delete from layoffs_staging2
where row_num > 1;

	# check it.. it was deleted or not
    
SELECT * FROM layoffs_staging2
WHERE row_num > 1;

-- 2. Standardizing the data

	# find the issue in the data and fixing it for each columns

select company, trim(company) # cleaning the white space
from layoffs_staging2;

	# update to the table

update layoffs_staging2
set company = trim(company);

SELECT distinct industry
FROM layoffs_staging2
order by 1;

	# look at the Crypto industry there is some difference in it need to change.

SELECT *
FROM layoffs_staging2
where industry like "crypto%";

update layoffs_staging2
set industry = 'Crypto'
where industry like "crypto%";

SELECT distinct location
FROM layoffs_staging2
order by 1;
	# locations is good to go
    
SELECT distinct country
FROM layoffs_staging2
order by 1;
	# look at the United States with dot
    # fix this

SELECT distinct country, trim(trailing '.' from country)
FROM layoffs_staging2
order by 1;

update layoffs_staging2
set country = trim(trailing '.' from country)
where country like 'United States%';

	# now goto date columns that is in text format but date is a datetime format we need to fix it

SELECT `date`
FROM layoffs_staging2;

SELECT `date`,
str_to_date(`date`, '%m/%d/%Y')
FROM layoffs_staging2;

update layoffs_staging2
set `date` = str_to_date(`date`, '%m/%d/%Y');
	# we have change the format of date but we need change the type of date in tables

alter table layoffs_staging2
modify column `date` DATE;

-- REMOVE OR MODIFY THE NULL and BLANK VALUES

SELECT * FROM layoffs_staging2;

SELECT *
FROM layoffs_staging2
where total_laid_off is null
;
	# we can't go with only total_laid_off but we need to look into percentage_laid_off also

SELECT *
FROM layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;

	# ok but there is lot NULL and BLANK values in all columns 

SELECT *
FROM layoffs_staging2
where industry is null
or industry = ''
;
	# need to check where there is any other company have the same industry was update in other year
    # look into it

SELECT *
FROM layoffs_staging2
where company = 'Airbnb';

	# here we go yes there is a same company but in different year
    # but need to check all the location are same

select *
from layoffs_staging2 t1
join layoffs_staging2 t2
	on t1.company = t2.company
    and t1.location = t2.location
where (t1.industry is null or t1.industry = '')
and t2.industry is not null;

update layoffs_staging2 t1
join layoffs_staging2 t2
	on t1.company = t2.company
set t1.industry = t2.industry
where (t1.industry is null or t1.industry = '')
and t2.industry is not null;

	# there will be a problem while update because we need to change the blank values to null

update layoffs_staging2
set industry = null
where industry = '';

	# now update this nulls
    
update layoffs_staging2 t1
join layoffs_staging2 t2
	on t1.company = t2.company
set t1.industry = t2.industry
where t1.industry is null
and t2.industry is not null;

	# now check this where it is updated or not

SELECT *
FROM layoffs_staging2
where company = 'Airbnb';	# Yes it is updated superb

	# delete the rows where total_laid_off and percentage_laid_off is null
    
delete 
FROM layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;

select *
from layoffs_staging2;

	# here we don't need the unwanted column like row_num do delete it

alter table layoffs_staging2
drop column row_num;

-- That's all this is the finilize data superb

select *
from layoffs_staging2;

-- DO PRACTICE AGAIN THIS AND DO THIS WITH DIFFERENT DATASET IT HELP TO DEVELOP THE SKILL IN SQL
-- YOU GUYS ARE GREAT, DONE IT... 









