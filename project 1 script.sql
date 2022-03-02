/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

-- Select data that we are going to be starting with

select * 
from portfolio_project_1..['covid deaths$']
order by 3,4



select location, date, total_cases, new_cases, total_deaths, population
from portfolio_project_1..['covid deaths$']
order by 1,2

--looking at total cases vs total deaths
--shows the likelihood of dying if you contract covid in Ireland

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from portfolio_project_1..['covid deaths$']
where location='Ireland'
and continent is not null 
order by 1,2

--looking at total cases vs population
--shows what percentage of population got covid

select location, population, date, total_cases, (total_cases/population)*100 as PercentageOfPopulationInfected
from portfolio_project_1..['covid deaths$']
where location='Ireland'
and continent is not null 
order by 1,2

--looking at the countries with the highest infection rate compared to population

select location, population, MAX(total_cases)as HighestInfectionCount, MAX((total_cases/population))*100 as PercentageOfPopulationInfected
from portfolio_project_1..['covid deaths$']
group by location, population
order by 4 desc

--showing the countries with the highest death count per population

select location, MAX(cast(total_deaths as int))as TotalDeathCount
from portfolio_project_1..['covid deaths$']
where continent is not null
group by location
order by 2 desc


--LET'S BREAK THINGS DOWN BY CONTINENT


-- showing the continents with the highest death counts

select continent, MAX(cast(total_deaths as int))as TotalDeathCount
from portfolio_project_1..['covid deaths$']
where continent is not null
group by continent
order by 2 desc



-- GLOBAL NUMBERS



select date, sum(new_cases) as TotalNewCases, 
sum(cast(new_deaths as int)) as TotalNewDeaths,
sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from portfolio_project_1..['covid deaths$']
where continent is not null
group by date
order by 1,2


select sum(new_cases) as TotalNewCases, 
sum(cast(new_deaths as int)) as TotalNewDeaths,
sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from portfolio_project_1..['covid deaths$']
where continent is not null
--group by date
--order by 1,2



--looking at total population vs vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine


select dea.continent,dea.location,dea.date,
dea.population, vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over 
(partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
from portfolio_project_1..['covid deaths$'] dea
join portfolio_project_1..['covid vaccinations$'] vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
order by 2,3

-- Using CTE to perform calculation on partition by in previous query

with PopVsVac (continent, location, date, population,
new_vaccinations, RollingPeopleVaccinated)
as 
(
select dea.continent,dea.location,dea.date,
dea.population, vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over 
(partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
from portfolio_project_1..['covid deaths$'] dea
join portfolio_project_1..['covid vaccinations$'] vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select *,(RollingPeopleVaccinated/population)*100
from PopVsVac


-- Using temp table to perform calculation on partition by in previous query

drop table if exists PercentPopulationVaccinated
create table PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime, 
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into PercentPopulationVaccinated
select dea.continent,dea.location,dea.date,
dea.population, vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over 
(partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
from portfolio_project_1..['covid deaths$'] dea
join portfolio_project_1..['covid vaccinations$'] vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3

select *,(RollingPeopleVaccinated/population)*100
from PercentPopulationVaccinated



-- Creating view to store data for later visualizations

create view PercentPopulationVaccinatedView as
select dea.continent,dea.location,dea.date,
dea.population, vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over 
(partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
from portfolio_project_1..['covid deaths$'] dea
join portfolio_project_1..['covid vaccinations$'] vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3

