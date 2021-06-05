select *
from [SQL Portfolio]..[Covid Deaths]
where continent is not null

--select *
--from [SQL Portfolio]..[Covid Vaccinations]
--order by 3,4


--Selecting Data that we will be usisng for the project

select location, date, total_cases, new_cases, total_deaths, population
from [SQL Portfolio]..[Covid Deaths]
order by 1, 2

--Order by in the above query is described by 1 then 2. In this case it orders by location first (alphabetic order), then by date. Reference the 'select' statement.

--Looking at the total cases vs total deaths


--The below query shows the likelihood of dying if you contract Covid in a given country.
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from [SQL Portfolio]..[Covid Deaths]
where location like'%states%' --The percent sign before and after 'states' allows the query to look up United States because we are unsure how it is formatted.
order by 1, 2


--Looking at the total cases vs Population
--Shows what percentage of population got covid
select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from [SQL Portfolio]..[Covid Deaths]
where location like'%states%'
order by 1, 2


--Looking at countries with highest infection rate compared to Population

select location, population, MAX(total_cases) as HighInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
from [SQL Portfolio]..[Covid Deaths]
--where location like'%states%'
group by location, population
order by PercentPopulationInfected desc


--This is showing the countries with the highest death count per population

select location, Max(cast(total_deaths as int)) as Totaldeathcount
from [SQL Portfolio]..[Covid Deaths]
--where location like'%states%'
where continent is not null
group by location
order by Totaldeathcount desc


--Breaking down the count by continent instead of country
--Showing the continents with the high death counts

select continent, Max(cast(total_deaths as int)) as Totaldeathcount
from [SQL Portfolio]..[Covid Deaths]
--where location like'%states%'
where continent is not null
group by continent
order by Totaldeathcount desc


--Global Numbers

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage
from dbo.[Covid Deaths]
where continent is not null
group by date
order by 1, 2


--Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) Over (Partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
--, (rollingpeoplevaccinated/population)*100
from dbo.[Covid Deaths] dea
join dbo.[Covid Vaccinations] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2, 3



--Use CTE

with PopvsVac (Continent, Location, Date, Population, New_vaccinations,rollingpeoplevaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) Over (Partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
--, (rollingpeoplevaccinated/population)*100
from dbo.[Covid Deaths] dea
join dbo.[Covid Vaccinations] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3
)
Select *, (rollingpeoplevaccinated/Population)*100
from PopvsVac



--Temp Table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) Over (Partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
--, (rollingpeoplevaccinated/population)*100
from dbo.[Covid Deaths] dea
join dbo.[Covid Vaccinations] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3

Select *, (rollingpeoplevaccinated/Population)*100
from #PercentPopulationVaccinated