select * 
from PortfoliaProject..covidDeaths
order by 3,4;

select *
from PortfoliaProject..covidvaccinations
order by 3,4;


select location, date, total_cases,new_cases,total_deaths,population
from PortfoliaProject..covidDeaths
order by 1,2;

-- total cases vs total deaths by location

select location, date, total_cases,total_deaths,((total_deaths/total_cases)*100) as death_percentage
from PortfoliaProject..covidDeaths
order by 1,2;

select location, date, total_cases,total_deaths,((total_deaths/total_cases)*100) as death_percentage
from PortfoliaProject..covidDeaths
where location like 'India'
order by 1,2;

select location, date, total_cases,total_deaths,((total_deaths/total_cases)*100) as death_percentage
from PortfoliaProject..covidDeaths
where location like '%New%'
order by 1,2;


-- total cases vs Population in India
select location, date,Population, total_cases,((total_cases/population)*100) as cases_per_population
from PortfoliaProject..covidDeaths
where location like 'India'
order by 1,2;

select location, date,Population, total_cases,((total_cases/population)*100) as PercentPopulationInfected
from PortfoliaProject..covidDeaths
where continent is not null
--where location like 'India'
order by 1,2;

-- countries with highest infection rate compared to population from highest to Lowest

select location,Population, max(total_cases) as highestInfectionCount,max((total_cases/population))*100 as PercentPopulationInfected
from PortfoliaProject..covidDeaths
where continent is not null
group by location, Population
order by PercentPopulationInfected desc;

-- Countries which have the highest Death Count per population

select location,Population, max(cast(total_deaths as int)) as highestDeathCount
from PortfoliaProject..covidDeaths
where continent is not null
group by location, Population
order by highestDeathCount desc; -- gives data for continent also

select location,Population, max(cast(total_deaths as int)) as TotalDeathCount
from PortfoliaProject..covidDeaths
where continent is not null 
group by location, Population
order by TotalDeathCount desc;


-- The Continents with highest Death Counts

select continent,Population, max(cast(total_deaths as int)) as TotalDeathCount
from PortfoliaProject..covidDeaths
where continent is not null 
group by continent, Population
order by TotalDeathCount desc;


select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfoliaProject..covidDeaths
where continent is null 
group by location
order by TotalDeathCount desc;

-- Global Covid Numbers

select sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths,
sum(cast(new_deaths as int))/Sum(new_cases)*100 as Death_Percentage
from PortfoliaProject..covidDeaths
where continent is not null;

select date,sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths,
sum(cast(new_deaths as int))/Sum(new_cases)*100 as Death_Percentage
from PortfoliaProject..covidDeaths
where continent is not null
group by date
order by 1,2;


select *
from PortfoliaProject..covidDeaths dea
join PortfoliaProject..covidDeaths vac
on dea.location= vac.location
and dea.date = vac.date;
-- Total Population that got vaccnianated

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
from PortfoliaProject..covidDeaths dea
join PortfoliaProject..covidvaccinations vac
on dea.location= vac.location
and dea.date = vac.date;

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as People_Vaccinated_Rolling
from PortfoliaProject..covidDeaths dea
join PortfoliaProject..covidvaccinations vac
on dea.location= vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3;


with PopVsVac(continent,location,date,population,new_vaccinations,People_Vaccinated_Rolling)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as People_Vaccinated_Rolling
from PortfoliaProject..covidDeaths dea
join PortfoliaProject..covidvaccinations vac
on dea.location= vac.location
and dea.date = vac.date
where dea.continent is not null
)
select *,(People_Vaccinated_Rolling/population)*100 as People_vaccinated_rolling_Percentage from
PopVsVac

--Views

create view PercentPopulationVaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as People_Vaccinated_Rolling
from PortfoliaProject..covidDeaths dea
join PortfoliaProject..covidvaccinations vac
on dea.location= vac.location
and dea.date = vac.date
where dea.continent is not null

select * from PercentPopulationVaccinated;