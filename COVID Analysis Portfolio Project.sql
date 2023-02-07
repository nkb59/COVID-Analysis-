/*
Covid 19 Data Exploration (Mainly focusing on the United States)

Skills used: CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types 

*/

SELECT * from coviddeaths WHERE continent is not null order by 3,4;

-- Select data that weare going to be using 

SELECT Location, date, total_cases, new_cases, total_deaths, population 
from coviddeaths 
where location like '%states%'
and continent is not null 
order by 1,2;

-- Looking at the total cases vs total deaths in the United States
-- Shows likelihood of dying if you get COVID in your respective country 

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from coviddeaths 
where location like '%states%'
order by 1,2;

-- Looking at the total cases vs population 
-- Shows what percentage of the population contracted Covid

SELECT Location, date, population, total_cases, (total_cases/population)*100 as PercentofPopulationInfected
from coviddeaths 
where location like '%states%'
order by 1,2;

-- Looking at countries with the highest infection rate vs population 

SELECT Location, population, MAX(total_cases) as HighestInfectionCount, (MAX(total_cases)/population)*100 as PercentofPopulationInfected
from coviddeaths 
-- where location like '%states%'
group by population,location
order by PercentofPopulationInfected desc;

-- Showing the countries with the Highest Death Count per Population

ALTER TABLE coviddeaths MODIFY total_deaths varchar(50) NOT NULL; -- Change text type into varchar before changing it into int type
ALTER TABLE coviddeaths MODIFY total_deaths bigint NOT NULL;


SELECT Location, MAX(total_deaths) as TotalDeathCount
from coviddeaths  
-- where location like '%states%'
WHERE continent is not null
group by location
order by TotalDeathCount desc;


-- BREAKING THINGS DOWN BY CONTINENTS 

-- Continents with the highest death count 

ALTER TABLE coviddeaths MODIFY total_deaths varchar(50) NOT NULL;
AlTER TABLE coviddeaths MODIFY total_deaths bigint NOT NULL;



SELECT continent, MAX(total_deaths) as TotalDeathCount
from coviddeaths 
-- where location like '%states%'
where continent is not null 
group by continent 
order by TotalDeathCount desc;

-- GLOBAL NUMBERS

ALTER TABLE coviddeaths MODIFY new_deaths varchar(50) NOT NULL;
ALTER TABLE coviddeaths MODIFY new_deaths bigint NOT NULL; 


SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, (SUM(new_deaths)/SUM(new_cases))*100 as DeathPercentage
FROM coviddeaths 
where continent is not null 
order by 1,2;

-- Total Population vs. Vaccinations 
-- This shows is the percentage of the population has at least gotten one vaccine 

ALTER TABLE coviddeaths MODIFY newvaccinations varchar(50) NOT NULL;
ALTER TABLE coviddeaths MODIFY newvaccinations bigint NOT NULL; 

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM( vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
FROM coviddeaths dea
JOIN covidvaccinations vac
		ON dea.location = vac.location
        AND dea.date = vac.date
WHERE dea.continent is not null
order by 2,3;



-- Using CTE to perform calculation on partition by in previous query 

ALTER TABLE coviddeaths MODIFY newvaccinations varchar(50) NOT NULL;
ALTER TABLE coviddeaths MODIFY newvaccinations bigint NOT NULL; 

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM( vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
FROM coviddeaths dea
JOIN covidvaccinations vac
		ON dea.location = vac.location
        AND dea.date = vac.date
WHERE dea.continent is not null
-- order by 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100 
FROM PopvsVac

-- Using temp table to perform calculations on partition by previous query 

DROP Table if exists PercentPopulationVaccinated

CREATE Table PercentPopulationVaccinated 
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

ALTER TABLE coviddeaths MODIFY newvaccinations varchar(50) NOT NULL;
ALTER TABLE coviddeaths MODIFY newvaccinations bigint NOT NULL; 

INSERT INTO PercentofPopulationVaccinated 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM( vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
FROM coviddeaths dea
JOIN covidvaccinations vac
		ON dea.location = vac.location
        AND dea.date = vac.date
-- WHERE dea.continent is not null
-- order by 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100 
FROM #PercentofPopulationVaccinated

-- Creating View to store data for later visualizations 

Create View PercentPopulationVaccinated1 as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM( vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
FROM coviddeaths dea
JOIN covidvaccinations vac
		ON dea.location = vac.location
        AND dea.date = vac.date
WHERE dea.continent is not null
