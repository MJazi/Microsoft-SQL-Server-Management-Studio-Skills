select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4;

--select *
--from PortfolioProject..CovidVaccinations
--order by 3,4

-- select the data that we are going to be using

select 
	Location,
	date,
	total_cases,
	new_cases,
	total_deaths, 
	population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2;

--looking at total cases vs total deaths

-- showing the likelihood of dying of covid-19 in two different countries i.e. Iran and USA
--Iran cases
select 
	Location,
	date,
	total_cases,
	total_deaths,
	(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%iran%' 
	and continent is not null
order by 2 desc;

--USA cases
select 
	Location,
	date,
	total_cases,
	total_deaths,
	(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%states%'
	and continent is not null
order by 1,2 desc;

--looking at total cases vs population 
--shows what percentage of population got covid

--USA cases
select 
	Location,
	date,
	total_cases,
	population,
	(total_cases/Population)*100 as Percentage_of_Population_Infected
from PortfolioProject..CovidDeaths
where location like '%states%'
	and continent is not null
order by 1,2 desc;

--Cases in Iran
select 
	Location,
	date,
	total_cases,
	population,
	(total_cases/Population)*100 as Percentage_of_Population_Infected
from PortfolioProject..CovidDeaths
where location like '%iran%'
	and continent is not null
order by 1,2 desc;

--Looking at countries with the highest infection/covid-19 rate

select 
	Location,
	population,
	max(total_cases) as HighestInfectionCount,
	max((total_cases/Population))*100 as Percentage_of_Population_Infected
from PortfolioProject..CovidDeaths
where continent is not null
group by location, population
order by 3 desc;

-- showing countries with the highest number of deaths per population

select 
	Location,
	population,
	max(cast(total_deaths as int)) as HighestDeathCount,
	max((total_deaths/Population))*100 as Percentage_of_Fatalities_Population
from PortfolioProject..CovidDeaths
where continent is not null
group by location, population
order by 3 desc;

-- let us break the numbers down by contintent 
-- note that numbers will be not be as accurate if you filter by continent

--filter by continent 
select 
	continent,
	max(cast(total_deaths as int)) as HighestDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by 2 desc;

--The numbers will be correct if you filter by location and exclude some unwanted values from location
select 
	location,
	max(cast(total_deaths as int)) as HighestDeathCount
from PortfolioProject..CovidDeaths
where continent is null 
	and location not in ('High income','Low income','Upper middle income','Lower middle income')
group by location
order by 2 desc;

-- let us look at the global numbers per day

select 
	date,
	sum(new_cases) as total_cases,
	sum(cast(new_deaths as int)) as total_deaths,
	sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2 desc;

-- let us look at the unformated global numbers

select 
	sum(new_cases) as total_cases,
	sum(cast(new_deaths as int)) as total_deaths,
	sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2 desc;

-- let us look at the formated global numbers

select 
	format(sum(new_cases),'N', 'en-US') as total_cases,
	format(sum(cast(new_deaths as int)),'N', 'en-US') as total_deaths,
	round(sum(cast(new_deaths as int))/sum(new_cases)*100,2) as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2 desc;

-- joining two tables and looking at the total population vs vaccination 

select 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population,
	vac.new_vaccinations, 
	SUM(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaxed
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
order by 2,3;

--creating CTE

With PopvsVac (continent, location, date, population, newe_vaccinations, RollingPeopleVaxed) as (

select 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population,
	vac.new_vaccinations, 
	SUM(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaxed
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null

)

select *,(RollingPeopleVaxed/population)*100 as Percentage_of_PopVaxed
from PopvsVac;

--Create a temporary table 

Drop table if exists #PercentagePopVaxed
create table #PercentagePopVaxed 

(
continent nvarchar(255), 
location nvarchar(255), 
date datetime, 
population numeric, 
new_vaccinations numeric,
RollingPeopleVaxed numeric
)

insert into #PercentagePopVaxed
select 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population,
	vac.new_vaccinations, 
	SUM(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaxed
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
--where dea.continent is not null

select *,(RollingPeopleVaxed/population)*100 as Percentage_of_PopVaxed
from #PercentagePopVaxed;

--create view(s) to store data for later visualizations

--First example of a view

Drop view if exists PercentagePopVaxed;
Go
create view PercentagePopVaxed as 
select 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population,
	vac.new_vaccinations, 
	SUM(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaxed
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
--where dea.continent is not null
Go

select *
from PercentagePopVaxed

--second example of a view

Drop view if exists CovidDeathPercentageinIran;
Go
create view CovidDeathPercentageinIran as 

select 
	Location,
	date,
	total_cases,
	population,
	(total_cases/Population)*100 as Percentage_of_Population_Infected
from PortfolioProject..CovidDeaths
where location like '%iran%'
	and continent is not null
Go