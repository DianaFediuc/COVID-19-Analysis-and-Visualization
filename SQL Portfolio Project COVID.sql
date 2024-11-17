
select * 
from PortfolioProject..CovidDeaths
where continent is not null
order by 3, 4

--select *
--from PortfolioProject..CovidVaccinations
--order by 3, 4

select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1, 2


-- Looking at Total Cases vs Total Deaths

select Location, date, total_cases, total_deaths, (total_deaths*1.0/total_cases)*100 as death_rate
from PortfolioProject..CovidDeaths
where location like 'United Kingdom'
and continent is not null
order by 1, 2


-- Looking at Total Cases vs Population 

select Location, date, population, total_cases, (total_cases*1.0/population)*100 as infection_rate
from PortfolioProject..CovidDeaths
where location like 'United Kingdom'
and continent is not null
order by 1, 2


-- Looking at Countries with Highest Infection Rate compared to Population

select Location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases*1.0/population))*100 as PopulationInfected
from PortfolioProject..CovidDeaths
group by location, population
order by PopulationInfected desc


-- Showing Countries with Highest Death Count per Population

select Location, MAX(total_deaths) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc


-- LET´S BREAK THINGS DOWN BY CONTINENT
-- Showing Continents with the Highest Death Count per Population

select location, MAX(total_deaths) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is null
group by location
order by TotalDeathCount desc


-- GLOBAL NUMBERS

select SUM(new_cases) as total_cases , SUM(cast(new_deaths as int)) as total_deaths , SUM(cast(new_deaths as int))*1.0/SUM(new_cases)*100 as DeathRate
from PortfolioProject..CovidDeaths
where continent is not null
-- group by date
order by 1, 2



-- Looking at Total Population vs Vaccinations

with PopvsVac (Continent,Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) 
OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
select *, (RollingPeopleVaccinated/population)*100 as vaccination_rate
from PopvsVac


-- Creating View to store data for later visualizations

create view vaccination_rate as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) 
OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null



select *
from vaccination_rate