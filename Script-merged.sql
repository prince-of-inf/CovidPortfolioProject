SELECT *
from owid_covid_data ocd;

-- cases (can by repeated) vs death
SELECT date, location, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPerc 
from owid_covid_data ocd 
WHERE location like "Poland"

-- deaths to population
SELECT location, population, MAX(cast(total_deaths as int)), max((total_deaths /population))*100 as PercPopDeceased
from owid_covid_data ocd 
group by location 
order by PercPopDeceased desc;

-- deaths to population
SELECT location, population, continent,  MAX(cast(total_deaths as int)) as Deaths, max((total_deaths /population))*100 as PercPopDeceased
from owid_covid_data ocd 
where ocd.continent <> '' -- only countries, not regions, is not null if blanks set to null
group by location
order by Deaths desc;

-- change blanks to NULL
update owid_covid_data 
set continent = NULLIF(continent, '');

-- deaths to population, by region
SELECT location, population, continent,  MAX(cast(total_deaths as int)) as Deaths, max((total_deaths /population))*100 as PercPopDeceased
from owid_covid_data ocd 
where ocd.continent is null -- only regions, 'is not null' if blanks set to null
group by location
order by Deaths desc;

-- createing CTE (common table expression) - temporary table
with PopvsVac (location, continent, date, population, new_vaccinations)
as
(
select cd.location, cd.continent , cd.`date` , vd.population , vd.new_vaccinations 
from vac_data vd 
join covid_data cd 
on vd.location = cd.location 
and vd.`date` = cd.`date`
) 
select *
from PopvsVac;

-- create new table
create table #PopvsVac
(location varchar(255),
continent varchar(255),
date datetime,
population numeric,
new_vaccinations numeric)

insert into #PopvsVac
select cd.location, cd.continent , cd.`date` , vd.population , vd.new_vaccinations 
from vac_data vd 
join covid_data cd 
on vd.location = cd.location 
and vd.`date` = cd.`date`

-- SUM(vd.new_vaccinations) over (PARTITION by cd.location order by cd.location, cd.`date`) as CumulatedVaccinated
