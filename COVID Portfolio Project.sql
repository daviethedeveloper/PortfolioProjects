Select * 
From Project..CovidDeaths
Where continent is not null
Order by 3,4


-- Select Data that I will be going to use

Select Location, date, total_cases, new_cases, total_deaths, population
FROM Project..CovidDeaths
Order By 1,2



-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contraact covid in your country

Select Location, date, total_cases,total_deaths,(CAST(total_deaths AS float) / CAST(total_cases AS float)) * 100
as DeathPercentage
FROM Project..CovidDeaths
Where location like '%States%'
Order By 1,2

-- Looking at the Total Cases vs Population
-- Shows what percentage of population got Covid

Select Location, date, total_cases, Population,(CAST(total_cases AS float) / CAST(population AS float)) * 100
as PercentPopulationInfection
FROM Project..CovidDeaths
-- Where location like '%Guatemala%'
Order By 1,2


-- Looking at Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(CAST(total_cases AS float)) as HighestInfectionCount, MAX(CAST(total_cases AS float) / CAST(population AS float)) * 100
as PercentPopulationInfection
FROM Project..CovidDeaths
-- Where location like '%Guatemala%'
Group by Location, population
Order By 4 DESC


-- LET'S BREAK THINGS DOWN BY LOCATION

Select location, MAX(cast(total_deaths as bigint)) as TotalDeathCount
FROM Project..CovidDeaths
-- Where location like '%Guatemala%'
Where location is not null
Group by location
Order By TotalDeathCount DESC



-- LET'S BREAK THINGS DOWN BY CONTINENT

-- Showing continents with the highest death count per population


Select continent, MAX(cast(total_deaths as bigint)) as TotalDeathCount
FROM Project..CovidDeaths
-- Where location like '%Guatemala%'
Where continent is not null
Group by continent
Order By TotalDeathCount DESC


-- GLOBAL NUMBERS


Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as bigint)) as total_deaths, SUM(cast(new_deaths as bigint))/SUM(new_cases) * 100 as DeathPercentage
FROM Project..CovidDeaths
Where continent is not null
Order By 1,2




-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, 
dea.Date) as  RollingPeopleVaccinated
From Project..CovidDeaths dea
Join Project..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3


-- USE CTE
With PopsvsVac (Continent, Location, Date, Population, New_Vaccination, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, 
dea.Date) as  RollingPeopleVaccinated
From Project..CovidDeaths dea
Join Project..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)

Select *, (RollingPeopleVaccinated/Population)*100
From PopsvsVac



-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, 
dea.Date) as  RollingPeopleVaccinated
From Project..CovidDeaths dea
Join Project..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- CREATING view to store data for later visualizations

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, 
dea.Date) as  RollingPeopleVaccinated
From Project..CovidDeaths dea
Join Project..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3




-- From the view table created

Select * 
From PercentPopulationVaccinated