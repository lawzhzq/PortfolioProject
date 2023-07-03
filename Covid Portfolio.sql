Select *
From CovidDeath
order by 3,4 ;

Select *
From CovidVaccination
order by 3,4 ;

Select Location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
order by 1,2 ;

-- looking at Total Cases vs Total Deaths
-- shows likelihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
Where location like '%states%'
order by 1,2;

-- looking at Total Cases vs Population
-- shows what percentage of population got Covid

Select Location, date, total_cases, population, (total_deaths/population)*100 as DeathPercentage
from CovidDeaths
Where location like '%states%'
order by 1,2 ;

-- looking at Countries with Highest Infection Rate compared to Population
Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_deaths/population))*100 as PercentagePopulationInfected
from CovidDeaths
-- Where location like '%states%'
Group by location, Population
order by PercentagePopulationInfected desc;

-- showing countries with Highest Death Count per population


Select Location, MAX(CAST(total_deaths AS unsigned)) as TotalDeathCount
from CovidDeaths
-- Where location like '%states%'
Where continent is not null
Group by location
order by TotalDeathCount desc;

-- Beak into  group by continent
Select continent, MAX(CAST(total_deaths AS unsigned)) as TotalDeathCount
from CovidDeaths
-- Where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc;

-- Showing continents with the highest death count per population
Select continent, MAX(CAST(total_deaths AS unsigned)) as TotalDeathCount
from CovidDeaths
-- Where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc;

-- Globle numbers
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as unsigned)) as total_deaths, SUM(cast(new_deaths as unsigned))/SUM(New_cases)*100 as DeathPercentage
from CovidDeaths
-- Where location like '%states%'
Where continent is not null
Group by date ;

-- Looking at Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea. population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.Location order by dea.location, dea. date) as RollingPeopleVaccinated

FROM CovidDeaths as dea
Join CovidVaccinations as vac
	On dea.location = vac. location
    and dea.date = vac.date
Where dea.continent is not null
order by 2,3; 

-- USE CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as(
Select dea.continent, dea.location, dea.date, dea. population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.Location order by dea.location, dea. date) as RollingPeopleVaccinated

FROM CovidDeaths as dea
Join CovidVaccinations as vac
	On dea.location = vac. location
    and dea.date = vac.date
Where dea.continent is not null
order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac;

-- TEMP Table
Create table `PercentPopulationVaccinated`

(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
);

Insert into `PercentPopulationVaccinated`
Select dea.continent, dea.location, dea.date, dea. population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.Location order by dea.location, dea. date) as RollingPeopleVaccinated

FROM CovidDeaths as dea
Join CovidVaccinations as vac
	On dea.location = vac. location
    and dea.date = vac.date
Where dea.continent is not null
order by 2,3; 

Select *, (RollingPeopleVaccinated/Population)*100
From PercentPopulationVaccinated;

-- Creating view to store data for later visualizations

Create View PercentPopulationVaccinated_View as
Select dea.continent, dea.location, dea.date, dea. population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.Location order by dea.location, dea. date) as RollingPeopleVaccinated

FROM CovidDeaths as dea
Join CovidVaccinations as vac
	On dea.location = vac. location
    and dea.date = vac.date
Where dea.continent is not null
order by 2,3; 