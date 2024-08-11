
Select Location, date, total_cases, total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0))*100 as DeathPercentage
from dbo.covid_deaths
where continent is not null and location like '%Denmark%'
order by 1,2

-- looking at total cases vs population

Select Location, date, total_cases, population, (CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0))*100 as RatioOfPopulatio
from dbo.covid_deaths
where continent is not null and location like '%Denmark%'
order by 1,2

-- looking for country with highest infection rate compared to population

Select Location, population, max(total_cases) as HighestInfectionCount, max((CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0)))*100 as RatioOfPopulatioInfected
from dbo.covid_deaths
where continent is not null
group by location, population
order by RatioOfPopulatioInfected desc

-- Looking for country with highest death count per popluation

Select Location, max(cast(total_deaths as int)) as TotalDeathCount
from dbo.covid_deaths
where continent is not null
group by location
order by TotalDeathCount desc

-- Grouping the data by continent

Select location, max(cast(total_deaths as int)) as TotalDeathCount
from dbo.covid_deaths
where continent is null
group by location
order by TotalDeathCount desc

Select continent, max(cast(total_deaths as int)) as TotalDeathCountContinent
from dbo.covid_deaths
where continent is not null
group by continent
order by TotalDeathCountContinent desc

-- Continent with the highest death count

--total_cases, total_deaths, (CONVERT(float, total_deaths) / nullif(CONVERT(float, total_cases),0)*100) as DeathPercentage_Continent

select sum(try_cast(new_cases as float)) as total_cases, sum(try_cast(new_deaths as float)) as total_deaths, ((sum(try_cast(new_deaths as float))/nullif(sum(try_cast(new_cases as float)),0))*100) as DeathPercentage
from dbo.covid_deaths
--where location like '%Denmark%'
where continent is not null
--group by date
order by 1,2


-- Looking at total population vs vaccination

select Deaths.continent, Deaths.location, Deaths.date, Deaths.population, Vac.new_vaccinations,
sum(try_cast(Vac.new_vaccinations as float)) over (partition by Deaths.location order by Deaths.location) as total_vaccinations
from dbo.covid_deaths as Deaths
join dbo.covid_vacinations as Vac
	on Deaths.location = Vac.location
	and Deaths.date = vac.date
where Deaths.continent is not null
order by 2,3

--CTE

with Pop_VS_Vac (continent, location, date, population, new_vaccinations, total_vaccinations)
as ( 
select Deaths.continent, Deaths.location, Deaths.date, Deaths.population, Vac.new_vaccinations,
sum(try_cast(Vac.new_vaccinations as float)) over (partition by Deaths.location order by Deaths.location) as total_vaccinations
from dbo.covid_deaths as Deaths
join dbo.covid_vacinations as Vac
	on Deaths.location = Vac.location
	and Deaths.date = vac.date
where Deaths.continent is not null
)
select * , (total_vaccinations/population)*100
from Pop_VS_Vac

-- Temp Table

Drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
total_vaccinations numeric)

insert into #PercentPopulationVaccinated
select Deaths.continent, Deaths.location, Deaths.date, Deaths.population, Vac.new_vaccinations,
sum(try_cast(Vac.new_vaccinations as float)) over (partition by Deaths.location order by Deaths.location) as total_vaccinations
from dbo.covid_deaths as Deaths
join dbo.covid_vacinations as Vac
	on Deaths.location = Vac.location
	and Deaths.date = vac.date
where Deaths.continent is not null

-- Creating a view to store data for later visualization
create view PercentPopulationVaccinated as
select Deaths.continent, Deaths.location, Deaths.date, Deaths.population, Vac.new_vaccinations,
sum(try_cast(Vac.new_vaccinations as float)) over (partition by Deaths.location order by Deaths.location) as total_vaccinations
from dbo.covid_deaths as Deaths
join dbo.covid_vacinations as Vac
	on Deaths.location = Vac.location
	and Deaths.date = vac.date
where Deaths.continent is not null
