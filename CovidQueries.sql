select * from dbo.covid_deaths
where continent is not null
order by 3,4;

-- select relevant Data to use
SELECT Location, date, total_cases, new_cases, total_deaths, population 
FROM dbo.covid_deaths
where continent is not null
order by 1,2

-- look at cases vs deaths
-- death_rate the likelihood of dying if you catch COVID in your country
SELECT Location, date, total_cases, total_deaths, 
(CAST(total_deaths AS float) / CAST(total_cases AS float))*100 as death_rate
FROM dbo.covid_deaths
where (location = 'United States') 
order by 1,2

-- Looking at cases vs population
-- Shows percentage of population with COVID
SELECT Location, date, total_cases, population, 
(CAST(total_cases AS float) / CAST(population AS float))*100 as infection_rate
FROM dbo.covid_deaths
--where (location = 'United States')
order by 1,2


-- Looking at countries with the highest infection rate
SELECT Location, MAX(total_cases) as highest_infection_count, population, 
MAX(CAST(total_cases AS float) / CAST(population AS float))*100 as infection_rate
FROM dbo.covid_deaths
where continent is not null
GROUP BY Location, population
order by infection_rate desc

-- Create view of total deaths in each country
GO
CREATE VIEW dbo.total_death_by_country
AS
SELECT Location, continent, MAX(total_deaths) as total_deaths
FROM dbo.covid_deaths
GROUP BY Location, continent
GO

-- Total number of deaths for each continent
SELECT continent, sum(total_deaths) as deaths
from dbo.total_death_by_country as td
where continent is not null
group by continent
order by deaths desc


-- Global counts
SELECT date, sum(new_cases) as new_cases, sum(new_deaths) as new_deaths
FROM dbo.covid_deaths
where continent is not null
group by date
order by date


-- look at total population vs vaccination
select cd.continent, cd.location, cd.date, population, cv.new_vaccinations,
sum(cv.new_vaccinations) OVER ( Partition by cd.location Order by cd.location, cd.date) as rolling_vax_total
from dbo.covid_deaths as cd
join dbo.covid_vax as cv
on cd.location = cv.location
and cd.date = cv.date
where cd.continent is not null
order by 2,3

DROP TABLE if exists PopulationVaccination
-- Table for exploring the vaccination rates of countries
CREATE Table PopulationVaccination
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population int,
new_vax int,
rolling_vax int,
rolling_fully_vax int,
vax_rate float,
fully_vax_rate float
)

Insert into PopulationVaccination( continent, location, date, population, 
	new_vax, rolling_vax,rolling_fully_vax,vax_rate,fully_vax_rate)
select cd.continent, cd.location, cd.date, population, isnull(cv.new_vaccinations,0),
cv.people_vaccinated as rolling_vax,
cv.people_fully_vaccinated as rolling_fully_vax, 
(cv.people_vaccinated / population)*100 as vax_rate, 
(cv.people_fully_vaccinated / population)*100 as fully_vax_rate 
from dbo.covid_deaths as cd
join dbo.covid_vax as cv
on cd.location = cv.location
and cd.date = cv.date
where cd.continent is not null 

select *
from PopulationVaccination


-- create view for later vizzes
GO
CREATE View Vax as
select *
from PopulationVaccination
GO

