select *
from PortfolioProject..CovidDeaths
order by 3,4


select Location, date, total_cases,new_cases,total_deaths,population
from CovidDeaths
order by 1,2

--Looking at total cases vs total deaths(percentage of people dying against those who are diagnosed)


--shows the likelyhood if you are infected in a particular country 
select Location, date, total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
where Location = 'India'
order by 1,2


---looking at toal cases vs the population of a particular country
--- Change the Location From India To a country whoose data you want
select Location, date, total_cases,population,(total_cases/population)*100 as infectionRate 
from CovidDeaths
--where Location = 'India'
order by 1,2

--Finding out which country has the highest infectionRate 
select Location,max( total_cases)as HighestInfectedpeople,population,max ((total_cases/population)*100) as infectionRate 
from CovidDeaths
group by location,population
order by infectionRate desc

---Showing countries with highest death rate for their population
select Location,population, max(total_deaths)as TotaldeathCount, max((total_deaths/population)*100) as MaxDeathpercentage
From CovidDeaths
group by location,population
order by MaxDeathpercentage desc

--or
select Location,max(cast(total_deaths as int)) as deathCount 
from CovidDeaths
group by location
order by deathCount desc

---Checking out things by continent

select location,max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is null
group by location
order by TotalDeathCount desc


---GLOBAL NUMBERS

select  sum(new_cases) as TotalCases,sum (cast(new_deaths as int)) as TotalDeaths,sum(cast (new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from CovidDeaths
where continent is not null
--group by date 
order by 1,2

---Looking at Total population Vs Vaccination
select CovidDeaths.continent,CovidVaccinations.location, CovidDeaths.date, CovidDeaths.population,
CovidVaccinations.new_vaccinations, sum (cast(CovidVaccinations.new_vaccinations as int)) over 
(partition by CovidDeaths.Location order by CovidDeaths.location,Coviddeaths.date)
as TotalVaccinationofACountry
from CovidDeaths
join CovidVaccinations
on CovidDeaths.location= CovidVaccinations.Location
and CovidDeaths.date=CovidVaccinations.date
where CovidDeaths.continent is not null
order by 2,3


---USING CTE TO FIND OUT VACCINATION RATE USING THE COLUMN WE JUST CREATED

with VaccinationRate(continent,location,date,population,New_Vaccinations,TotalVaccinationofaCountry)
as
(
select CovidDeaths.continent,CovidVaccinations.location, CovidDeaths.date, CovidDeaths.population,
CovidVaccinations.new_vaccinations, sum (cast(CovidVaccinations.new_vaccinations as int)) over 
(partition by CovidDeaths.Location order by CovidDeaths.location,Coviddeaths.date)
as TotalVaccinationofACountry
from CovidDeaths
join CovidVaccinations
on CovidDeaths.location= CovidVaccinations.Location
and CovidDeaths.date=CovidVaccinations.date
where CovidDeaths.continent is not null
)

select *,(TotalVaccinationofaCountry/population)*100 as VaccinationRate
from VaccinationRate

--select location,max ((TotalVaccinationofaCountry/population)*100) as VaccinationRate
--from VaccinationRate
--group by location

---TEMP TABLE

create table #PercentPopulationVaccinated
(continent nvarchar (255),
location nvarchar(255),
date datetime,
population bigint,
New_Vaccinations int,
TotalVaccinationofACountry bigint)


insert into #PercentPopulationVaccinated
select CovidDeaths.continent,CovidVaccinations.location, CovidDeaths.date, CovidDeaths.population,
CovidVaccinations.new_vaccinations, sum (cast(CovidVaccinations.new_vaccinations as int)) over 
(partition by CovidDeaths.Location order by CovidDeaths.location,Coviddeaths.date)
as TotalVaccinationofACountry
from CovidDeaths
join CovidVaccinations
on CovidDeaths.location= CovidVaccinations.Location
and CovidDeaths.date=CovidVaccinations.date
where CovidDeaths.continent is not null

Select *,(TotalVaccinationofaCountry/population)*100 as VaccinationRate
from #PercentPopulationVaccinated



