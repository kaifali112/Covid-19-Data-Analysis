
select * from PortfolioProject..CovidDeaths$
where continent is not null 
order by 3,4



select * from PortfolioProject..CovidVaccinations$
order by 3,4

select location, date, total_cases, new_cases, total_deaths, population 
from PortfolioProject..CovidDeaths$
order by 1, 2

-- looking at Total cases vs Total Deaths


select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from PortfolioProject..CovidDeaths$
where location like '%India%'
order by 1, 2


-- Total cases vs Population
--Shows what percentage of population got covid

select location, date, population, total_cases, (total_cases/population)*100 as cases_Percentage
from PortfolioProject..CovidDeaths$
where location like '%India%'
order by 1, 2



--Looking at countries highest Infection Rate compared to Population


select location, population, max(total_cases) as Highest_infection_count, max(total_cases/population)*100 as percentage_population_affected
from PortfolioProject..CovidDeaths$
--where location like '%India%'
group by location, population
order by percentage_population_affected desc


--Showing countries with Highest Death Count 

select location, max(cast(Total_deaths as int)) as Total_Death_count
from PortfolioProject..CovidDeaths$
--where location like '%India%'
where continent is not null 
group by location
order by Total_Death_count desc


--Showing continents with highest death count per population

select continent, max(cast(Total_deaths as int)) as Total_Death_count
from PortfolioProject..CovidDeaths$
--where location like '%India%'
where continent is not null 
group by continent
order by Total_Death_count desc

--Global Numbers

select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as death_percentage
from PortfolioProject..CovidDeaths$ 
--where location like '%India%'
where continent is not null 
group by date
order by 1, 2


--Total population vs total vaccination


select d.continent, d.location, d.date, d.population, v.new_vaccinations, 
sum(convert(int,v.new_vaccinations))  over (partition by d.location order by d.location, d.date) as total_vaccination
from PortfolioProject..CovidDeaths$ d
join PortfolioProject..CovidVaccinations$ v
on d.location = v.location
and d.date = v.date 
where d.continent is not null
order by 2, 3


--Use CTE

with PopvsVac (continent, location, date, Population, new_vaccinatiion, total_vaccination)
as


(
select d.continent, d.location, d.date, d.population, v.new_vaccinations, 
sum(convert(int,v.new_vaccinations))  over (partition by d.location order by d.location, d.date) as total_vaccination
from PortfolioProject..CovidDeaths$ d
join PortfolioProject..CovidVaccinations$ v
on d.location = v.location
and d.date = v.date 
where d.continent is not null
)select *, (total_vaccination/population)*100
from PopvsVac


--Temp table

drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
 continent nvarchar(255),
 location nvarchar(255),
 date datetime,
 population int,
 new_vaccinations int,
 total_vaccinations int
 )

insert into #percentpopulationvaccinated

select d.continent, d.location, d.date, d.population, v.new_vaccinations, 
sum(convert(int,v.new_vaccinations))  over (partition by d.location order by d.location, d.date) as total_vaccination
from PortfolioProject..CovidDeaths$ d
join PortfolioProject..CovidVaccinations$ v
on d.location = v.location
and d.date = v.date 
where d.continent is not null
order by 2, 3

select *, (total_vaccinations/population)*100 
from #percentpopulationvaccinated


--creating view 

create view percentpopulationvaccinated as 
select d.continent, d.location, d.date, d.population, v.new_vaccinations, 
sum(convert(int,v.new_vaccinations))  over (partition by d.location order by d.location, d.date) as total_vaccination
from PortfolioProject..CovidDeaths$ d
join PortfolioProject..CovidVaccinations$ v
on d.location = v.location
and d.date = v.date 
where d.continent is not null



select * from percentpopulationvaccinated