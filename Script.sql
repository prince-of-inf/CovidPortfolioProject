-- select all, order by third and then forth selected column
SELECT *
from covid_database.covid_data
order by 3,4

-- select all, order by third and then forth selected column
SELECT *
from covid_database.vac_data vd
order by 3,4

-- Cases vs total deaths
SELECT total_cases, total_deaths, (total_cases/total_deaths)*100 as DeathPercent
from covid_database.covid_data

-- Cases vs total deaths in Poland
SELECT location, total_cases, total_deaths, (total_cases/total_deaths)*100 as DeathPercent
from covid_database.covid_data
WHERE location LIKE "%Poland"


SELECT *
FROM covid_data as cd 
inner join vac_data as vd 

-- join tables (key columns repeat)

SELECT *
FROM covid_data as cd 
inner join vac_data as vd 
on cd.iso_code = vd.iso_code 
and
cd.`date` = vd.`date`

-- join tables (key coumns not repeated)
-- USING doesn't work?
-- SELECT vd.population 
-- FROM covid_data as cd 
-- inner join vac_data as vd 
-- using (cd.iso_code, cd.'date')

