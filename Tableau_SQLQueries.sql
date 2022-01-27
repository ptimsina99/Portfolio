-- Link to tableau Dashboard: https://public.tableau.com/app/profile/prayash.timsina/viz/CovidDashboard_16431611956170/Dashboard1?publish=yes

--------------------------------------------------------------------------------------------

-- Views of the data to be used in Tabloid Dashboard

Create View PercentVaccinated as
Select death.continent, death.location, death.date, death.population, vac.new_vaccinations, 
Sum(cast(vac.new_vaccinations as bigint)) Over (Partition by death.location order by death.location, 
death.date) as CumulativeVac
From PortfolioProject..CovidDeaths death
Join PortfolioProject..CovidVaccinations vac
	on death.location = vac.location
	and death.date = vac.date
where death.continent is not null



Create View GlobalDeathPercentage as
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as GlobalDeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%Canada%'
where continent is not null 
--Group By date



Create view TotalDeathCount as
Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%canada%'
Where continent is null 
and location not in ('World', 'European Union', 'International', 'Upper middle income', 
'High income', 'Lower middle income', 'Low income')
Group by location



Create view PercentPopCovid as
Select location, date, population, Max(total_cases) as HighestInfectionCount, 
Max(total_cases/population)*100 as PopulationWithCovid
From PortfolioProject..CovidDeaths
--where location like '%canada%'
where continent is not null
Group by location, population, date
