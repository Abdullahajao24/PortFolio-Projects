Select *
From PortfolioProject..CovidVaccinations$
order by 3, 4

Select *
From PortfolioProject..['CovidDeaths$']
order by 3, 4

--Select Data that I am going to be using

Select Location, date, total_cases, 
new_cases, total_deaths, population
From PortfolioProject..['CovidDeaths$']
order by 1,2

-- Looking at the Total cases Vs Total Deaths
--Shows likelihood of dying of Covid in Nigeria

Select Location, date, total_cases, total_deaths,
(total_deaths/total_cases)* 100 as DeathPercentage
From PortfolioProject..['CovidDeaths$']
where location = 'Nigeria'
order by 1,2

--Looking at the Total Cases Vs Population
--Show what percentage have contracted covid

Select Location, date, total_cases, population,
(total_cases/Population)* 100 as InfectedPercentage
From PortfolioProject..['CovidDeaths$']
where location like '%Nigeria%'
order by 1,2

--Looking at countries with highest Infecton rate in Africa

Select Location,Population, max(total_cases) as HighestInfectionCount,
max((total_cases/population))* 100 as PercentPopulationInfected
From PortfolioProject..['CovidDeaths$']
where continent = 'Africa'
Group by location, population
order by PercentPopulationInfected desc

--Showing Africa countries with Highest Death Count per Population

Select Location,Population, max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..['CovidDeaths$']
where continent = 'Africa'
Group by location, population
order by TotalDeathCount desc

--Breaking things down by continent

Select continent, max(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..['CovidDeaths$']
where continent is not null
Group by continent
order by TotalDeathCount desc

--Global Daily Death

Select date, sum(new_cases) as CasesCount, sum(cast(new_deaths as int)) as DeathCount, 
sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From PortfolioProject..['CovidDeaths$']
where continent is not null
Group by date
order by DeathPercentage desc

--Show global count

Select sum(new_cases) as CasesCount, sum(cast(new_deaths as int)) as DeathCount, 
sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From PortfolioProject..['CovidDeaths$']
where continent is not null
--Group by date
--order by DeathPercentage desc

--Join the CovidDeath and CovidVaccinations

Select *
From PortfolioProject..['CovidDeaths$'] dea
Join PortfolioProject..CovidVaccinations$ vac
on dea.location = vac.location and
dea.date = vac.date

--Compare the Vaccination to the population in Africa

Select dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int, vac.new_vaccinations)) OVER 
(Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..['CovidDeaths$'] dea
Join PortfolioProject..CovidVaccinations$ vac
on dea.location = vac.location and
dea.date = vac.date
where dea.continent like '%Africa%' and vac.new_vaccinations is not null
--where dea.continent is not null


--Use CTE

with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) 
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int, vac.new_vaccinations)) OVER 
(Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From PortfolioProject..['CovidDeaths$'] dea
Join PortfolioProject..CovidVaccinations$ vac
on dea.location = vac.location and
dea.date = vac.date
where dea.continent like '%Africa%' and vac.new_vaccinations is not null
--where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac


--TEMP Table
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.Continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int, vac.new_vaccinations)) OVER 
(Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..['CovidDeaths$'] dea
Join PortfolioProject..CovidVaccinations$ vac
on dea.location = vac.location and
dea.date = vac.date
where dea.continent like '%Africa%' and vac.new_vaccinations is not null
--where dea.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--Create a View to store data for lataer visualization

Drop view PercentPopulationVaccinated
Drop view PercentVaccinatedPopulation
Drop view PecentVaccinationPopulation

Create view PercentVaccinatedPopulation as
Select dea.Continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int, vac.new_vaccinations)) OVER 
(Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..['CovidDeaths$'] dea
Join PortfolioProject..CovidVaccinations$ vac
on dea.location = vac.location and
dea.date = vac.date
where dea.continent like '%Africa%' and vac.new_vaccinations is not null
--where dea.continent is not null





