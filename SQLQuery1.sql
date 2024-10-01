select * from covidproject..coviddeaths
order by 3,4

--select * from covidproject..covidvaccine
--order by 3,4

--select location, date, total_cases, new_cases, total_deaths , population 
--from covidproject..coviddeaths
--order by 1,2

--how many cases in country and how many deaths, Tolal cases vs Total Deaths
select location, date, total_cases, new_cases, total_deaths , population ,round((total_deaths/total_cases)*100,  2) as Deathpercent
from covidproject..coviddeaths
where location = 'india'
order by 1,2

--- Total cases vs population
--percentage of population affected by covid

select location, date, total_cases, new_cases, total_deaths , population ,round((total_deaths/population)*100, 2) as covid_affect_rate
from covidproject..coviddeaths
where location = 'india'
order by 1,2

--country that was most infected compared to population 

select location, population, max(total_cases) as highest_infected ,max((total_cases/population)*100) as percentofpopulation_infected
from covidproject..coviddeaths
group by location , population
order by percentofpopulation_infected desc


---query country with highest death rate per population

select location, max(cast(total_deaths as int)) as highest_death
from covidproject..coviddeaths
where continent is not null
group by location
order by highest_death desc

--- breaking down by continent 

select continent, max(cast(total_deaths as int)) as highest_death
from covidproject..coviddeaths
where continent is not null
group by continent
order by highest_death desc

---break down by global

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From covidproject..CovidDeaths
where continent is not null 
order by 1,2

--- FIND total vaccinated population

select covd.continent, covv.location, covv.date,covd.population, covv.new_vaccinations
from covidproject..coviddeaths covd
join covidproject..covidvaccine covv
on covd.location = covv.location
and covd.date = covv.date
where covd.continent is not null
order by 2, 3


---

select covd.continent, covv.location, covv.date,covd.population, covv.new_vaccinations ,
sum(convert(int,covv.new_vaccinations)) over (partition by covd.location order by covd.location, covd.date) as vaccinated_population
from covidproject..coviddeaths covd
join covidproject..covidvaccine covv
on covd.location = covv.location
and covd.date = covv.date
where covd.continent is not null
order by 2, 3

----- total population rate vaccinated

select covd.continent, covv.location, covv.date,covd.population, covv.new_vaccinations ,
sum(convert(int,covv.new_vaccinations)) over (partition by covd.location order by covd.location, covd.date) as vaccinated_population
(vaccinated_population/population)*100
from covidproject..coviddeaths covd
join covidproject..covidvaccine covv
on covd.location = covv.location
and covd.date = covv.date
where covd.continent is not null
order by 2, 3


---total population vaccinated in specific contry

with populationvsVaccined (continent , location , date, population , new_vaccinations, vaccinated_population ) as 
(
select covd.continent, covv.location, covv.date,covd.population, covv.new_vaccinations ,
sum(convert(int,covv.new_vaccinations)) over (partition by covd.location order by covd.location, covd.date) as vaccinated_population
from covidproject..coviddeaths covd
join covidproject..covidvaccine covv
on covd.location = covv.location
and covd.date = covv.date
where covd.continent is not null
)
select *, (vaccinated_population/population)*100
from populationvsVaccined 


-- Using Temp Table to perform Calculation on Partition By in previous query

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
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From covidproject..CovidDeaths dea
Join covidproject..CovidVaccine vac
	On dea.location = vac.location
	and dea.date = vac.date

--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From covidproject..CovidDeaths dea
Join covidproject..CovidVaccine vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 