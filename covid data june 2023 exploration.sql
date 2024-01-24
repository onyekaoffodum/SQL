/*
Covid 19 Data Exploration
Using covid deaths and covid vaccination data files.

Skills used:Joins, CTEs, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/



select *
from [Covid data exploration]..['covid death']
where continent is not null
order by 3,4



--select the data that we are going to be starting with

select location,date,total_cases, new_Cases,total_deaths,population
from [Covid data exploration]..['covid death']
where continent is not null
order by 1,2

--total cases vs total death
--shows likelihood of dying if you contract covid in your country

select location,date,total_cases, 
cast(total_deaths as int) as cleaned_total_deaths,(cast(total_deaths as int))/(cast(total_cases as int))*100 as death_percentage  
from [Covid data exploration]..['covid death']
where continent is not null
--where location like '%states%'
order by 1,2

 --OR

 select location,date,total_cases, total_deaths,(cast(total_deaths as int))/(cast(total_cases as int))*100 as death_percentage  
from [Covid data exploration]..['covid death']
where continent is not null
--where location like '%states%'
order by 1,2


--total cases vs population
--shows what percentage of population infected with covid

select location,date,population,total_cases,
(total_cases/population) *100 as percentage_population_infected
from [Covid data exploration]..['covid death']
--where location like '%states%'
order by 1,2


--countries with highest infection rate compared to population

select location,population,sum(cast (new_cases as bigint)) as highest_infection_count,
(sum(cast (new_cases as bigint))/population) *100 as percentage_population_infected
from [Covid data exploration]..['covid death']
--where location like '%states%'
group by location, population
order by Percentage_Population_Infected desc

--continent and class with highest death count

select location,max(cast(total_deaths as int)) as total_death_count
from [Covid data exploration]..['covid death']
where continent is null
--where location like '%states%'
group by location
order by Total_Death_Count desc


--countries with highest death count 

select location,max(cast(total_deaths as int)) as total_death_count
from [Covid data exploration]..['covid death']
where continent is not null
--where location like '%africa%'
group by location
order by Total_Death_Count desc



--showing continents with the highest death count per population

select continent,max(cast(total_deaths as int)) as total_death_count
from [Covid data exploration]..['covid death']
where continent is not null
--where location like '%africa%'
group by continent
order by total_death_count desc


--Global numbers
--death percentage in the world

select date, sum(new_cases) as total_Cases, sum(new_deaths) as total_Deaths, sum(new_deaths)/sum(new_cases)*100 as death_percentage  
from [Covid data exploration]..['covid death']
where continent is not null and new_cases <>0
--where location like '%states%'
group by date
order by 1,2


--total population vs vaccination
--shows percentage of population that has received at least one covid vaccine

select dea.continent,dea.location, dea.date,dea.population,vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
from [Covid data exploration]..['covid death'] dea
join [Covid data exploration]..['covid vaccination'] vac
          on dea.location = vac.location
		  and dea.date= vac.date
		  where dea.continent is not null
		  order by 2,3



--Using CTE to perform calculation on Partion By in previous query

with popvsVac(continent,location,date,population, new_vaccinations,rolling_People_Vaccinated)
as
(
select dea.continent,dea.location, dea.date,dea.population,vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
from [Covid data exploration]..['covid death'] dea
join [Covid data exploration]..['covid vaccination'] vac
          on dea.location = vac.location
		  and dea.date= vac.date
		  where dea.continent is not null
		  --order by 2,3
		  )
select *,(rolling_people_vaccinated/population) * 100 as "%_rolling_people_vaccinated"
from popvsVac


--Using Temp table to perform calculation on Partition By in previous query

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
Rolling_People_Vaccinated numeric)


Insert into #PercentPopulationVaccinated
select dea.continent,dea.location, dea.date,dea.population,vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
from [Covid data exploration]..['covid death'] dea
join [Covid data exploration]..['covid vaccination'] vac
          on dea.location = vac.location
		  and dea.date= vac.date
		 -- where dea.continent is not null
		  --order by 2,3

select *,(rolling_people_vaccinated/population) * 100 as "%_rolling_people_vaccinated"
from #PercentPopulationVaccinated



--creating view to store data for later visualizations


create view Percent_Population_Vaccinated as
select dea.continent,dea.location, dea.date,dea.population,vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
--,(rolling_people_vaccinated/population) * 100 as "%_rolling_people_vaccinated"
from [Covid data exploration]..['covid death'] dea
join [Covid data exploration]..['covid vaccination'] vac
          on dea.location = vac.location
		  and dea.date= vac.date
		 where dea.continent is not null









