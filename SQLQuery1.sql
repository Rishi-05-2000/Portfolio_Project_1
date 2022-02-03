--Select the Dataset:
select *
from Portfolio_Project..Covid_Deaths
where continent is not null
order by 3,4

--Select the specific data that we want:
select Location,date,total_cases,new_cases,total_deaths,population
from Portfolio_Project..Covid_Deaths
where continent is not null
order by 1,2

--Comparison of Total cases vs Total Deaths:
--Represents the probabity of death if infected.
select Location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as Death_Percentage
from Portfolio_Project..Covid_Deaths
where location = 'India'
and continent is not null
order by 1,2

--Comparison of Total cases vs Population:
--Represents the number of people infected.
select Location,date,population,total_cases,(total_cases/population)*100 as infected_Percentage
from Portfolio_Project..Covid_Deaths
where location = 'India' and continent is not null
order by 1,2

--Countries with highest infection rate:
select Location,Population,MAX(total_cases) as Total_infection_Cout,MAX((total_cases/population))*100 as Infected_Percentage
from Portfolio_Project..Covid_Deaths
where continent is not null
group by location,population
order by infected_Percentage desc 

--Countries with highest death count per population:
select Location,MAX(CAST(Total_Deaths as int)) as Total_Deaths
from Portfolio_Project..Covid_Deaths
where continent is not null
group by location
order by Total_Deaths desc

-- Death count by continents:
select continent,MAX(CAST(Total_Deaths as int)) as Total_Deaths
from Portfolio_Project..Covid_Deaths
where continent is not null
group by continent
order by Total_Deaths desc

--Global Figures:
select date,SUM(new_cases) as Total_cases,SUM(CAST(new_deaths as int)) as Total_deaths,SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as Death_percentage
from Portfolio_Project..Covid_Deaths
where continent is not null
group by date
order by 1,2

--Global Summary Table:
select SUM(new_cases) as Total_cases,SUM(CAST(new_deaths as int)) as Total_deaths,SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as Death_percentage
from Portfolio_Project..Covid_Deaths
where continent is not null
--group by date
order by 1,2

--Comparison between Vaccinations and Total Population:
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(Convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as Rolling_people_vaccinated
--, (Rolling_people_vaccinated/population)*100
from Portfolio_Project..Covid_Deaths dea 
join Portfolio_Project..Covid_Vaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

--Using CTE:
with popvsvac (continent,location,date,population,new_vaccinations,Rolling_people_vaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,dea.date) as Rolling_people_vaccinated
--, (Rolling_people_vaccinated/population)*100
from Portfolio_Project..Covid_Deaths dea 
join Portfolio_Project..Covid_Vaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *,(Rolling_people_vaccinated/population)*100
from popvsvac

--Temp Table
DROP Table if exists #PercentofPopulationVaccinated
Create Table #PercentofPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Rolling_people_vaccinated numeric
)

Insert into #PercentofPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date) as Rolling_people_vaccinated
--, (Rolling_people_vaccinated/population)*100
from Portfolio_Project..Covid_Deaths dea 
join Portfolio_Project..Covid_Vaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *,(Rolling_people_vaccinated/population)*100
from #PercentofPopulationVaccinated

--Creating View to store Data for later visualization:
create view PercentofPopulationVaccinated as 
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date) as Rolling_people_vaccinated
--, (Rolling_people_vaccinated/population)*100
from Portfolio_Project..Covid_Deaths dea 
join Portfolio_Project..Covid_Vaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
from PercentofPopulationVaccinated
