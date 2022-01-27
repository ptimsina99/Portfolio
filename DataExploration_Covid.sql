/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/


-- Select Data that we will be using from CovidDeaths excel file

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Order by 1, 2


-- Analyze total cases vs total deaths
-- Shows the likelihood of dying if you contract COVID in Canada

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercent
From PortfolioProject..CovidDeaths
where location like '%canada%'
and continent is not null
Order by 1, 2


-- Total Cases vs Population
-- Shows what percentage of Canadian population got COVID

Select location, date, population, total_cases, (total_cases/population)*100 as PopulationWithCovid
From PortfolioProject..CovidDeaths
where location like '%canada%'
and continent is not null
Order by 1, 2


-- Countries with the Highest Infection Rate compared to population

Select location, population, Max(total_cases) as HighestInfectionCount, 
Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
where continent is not null
Group by location, population
Order by 4 Desc


-- Countries with highest death count per population

Select Location, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
-- world is showing up as location because some continents are in Country column
where continent is not null
Group by Location
Order by 2 desc


-- Continents with highest death count

Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null
Group by continent
Order by 2 desc


-- Global Numbers: Total Death Percentage

Select date, Sum(total_cases) as t_cases, Sum(cast(total_deaths as int)) as t_deaths, 
(Sum(cast(total_deaths as int))/Sum(total_cases))*100 as GlobalDeathPercent
From PortfolioProject..CovidDeaths
-- where location like '%canada%'
where continent is not null
Group by date
Order by 4 Desc


-- Join two tables and look at Cumulative Vaccinations per country

Select death.continent, death.location, death.date, death.population, vac.new_vaccinations, 
Sum(cast(vac.new_vaccinations as bigint)) Over (Partition by death.location order by death.location, 
death.date) as CumulativeVac
From PortfolioProject..CovidDeaths death
Join PortfolioProject..CovidVaccinations vac
	on death.location = vac.location
	and death.date = vac.date
where death.continent is not null
order by 2,3


-- Use CTE to get Cumulative Population Vaccinated Percentage

With PopVac (Continent, Location, Date, Population, New_Vaccinations, CumulativeVac)
As
(
Select death.continent, death.location, death.date, death.population, vac.new_vaccinations, 
Sum(cast(vac.new_vaccinations as bigint)) Over (Partition by death.location order by death.location, 
death.date) as CumulativeVac
From PortfolioProject..CovidDeaths death
Join PortfolioProject..CovidVaccinations vac
	on death.location = vac.location
	and death.date = vac.date
where death.continent is not null
)
Select *, (CumulativeVac/Population)*100 as CumulativePopVac
From PopVac
where location like '%Canada%'


-- Use TEMP TABLE to get Cumulative Population Vaccinated Percentage

Drop table if exists #PercentVaccinated
Create Table #PercentVaccinated
(
Continent nvarchar(250),
Location nvarchar(250),
Date datetime,
Population numeric,
New_Vaccinations numeric,
CumulativeVac numeric
)

Insert into #PercentVaccinated
Select death.continent, death.location, death.date, death.population, vac.new_vaccinations, 
Sum(cast(vac.new_vaccinations as bigint)) Over (Partition by death.location order by death.location, 
death.date) as CumulativeVac
From PortfolioProject..CovidDeaths death
Join PortfolioProject..CovidVaccinations vac
	on death.location = vac.location
	and death.date = vac.date
where death.continent is not null

Select *, (CumulativeVac/Population)*100 as CumulativePopVac
From #PercentVaccinated