-- --Changing date format---
set SQL_Safe_updates = 0;
update CovidDeaths set date = date_format(Str_to_date(date,'%d/%m/%Y'),'%Y-%m-%d');
update CovidVaccinations set date = date_format(Str_to_date(date,'%d/%m/%Y'),'%Y-%m-%d');
-- checking the data to ensure they are correct--  
select * from CovidVaccinations limit 5;
select * from CovidDeaths;

-- --Selecting the data we are going to be using-- 
select id, location, date, total_cases, new_cases,
total_deaths, population
from CovidDeaths order by location,date;

-- --Total cases vs Total Deaths and location wise--
select location, max(total_cases) as Cases, 
max(total_deaths) Deaths,
concat(round((max(total_deaths)/max(total_cases))*100,2),'%') as Deaths_per_cases
from CovidDeaths
where continet is not null
Group by location 
order by location;
-- --2nd selection 
select total_deaths, total_cases, (total_deaths/total_cases)*100 as DeathPercentage, 
date from CovidDeaths 
where location like '%Canada%' order by date;

-- --Total cases VS the population and percentage population got covid--
select population, total_cases, (total_cases/population)*100 as CasesPercentage, 
date from CovidDeaths 
where location like '%Canada%' order by date asc;

-- --Country with the highest infection rate compared to the population
select location, max(total_cases), avg(population), (max(total_cases)/avg(population))*100 as Percent_Population_infected 
from CovidDeaths
where continent is not null 
Group by location
order by Percent_Population_infected Desc;

-- --countries with the highest death count per population--
select location, max(total_deaths) as Total_Deaths_Count, avg(population), concat(round((max(total_deaths)/avg(population))*100, 5),'%') as PercentDeaths 
from CovidDeaths
where continent is not null 
Group by location
order by PercentDeaths Desc;
-- --2nd similar query--
select location, max(total_deaths) as Total_Death_Count
from CovidDeaths 
where continent!=''
Group by location
order by Total_Death_Count Desc;
-- --3rd Query-- 
select location, max(total_deaths) as Total_Death_Count
from CovidDeaths 
where continent=''
Group by location
order by Total_Death_Count Desc;

-- --Continents with the highest death count per population
select location, max(total_deaths) as Total_Death_Count, 
		(max(total_deaths)/avg(population))*100 as Continent_Death_Count 
from CovidDeaths 
where continent=''
Group by location
order by Total_Death_Count Desc;

-- --Global numbers
select location, total_deaths, total_cases, (total_deaths/total_cases)*100 as DeathPercentage, 
date from CovidDeaths 
where continent !=''
order by date

-- --Deaths percentage filtered by date accross the world
select date, sum(new_cases) as Total_Cases, sum(new_deaths) as Total_Deaths,
	(sum(new_deaths)/sum(new_cases))*100 as Deaths_per_cases
-- , total_deaths, total_cases, (total_deaths/total_cases)*100 as DeathPercentage, 
from CovidDeaths 
where continent !=''
group by date
order by date,Total_Cases; 

-- --Total Deaths in the world 
select sum(new_cases) as Total_Cases, sum(new_deaths) as Total_Deaths,
	(sum(new_deaths)/sum(new_cases))*100 as Deaths_per_cases
-- , total_deaths, total_cases, (total_deaths/total_cases)*100 as DeathPercentage, 
from CovidDeaths 
where continent !=''
-- group by date
-- order by date,Total_Cases; 

-- Using the two tables 

select * from CovidDeaths dea join CovidVaccinations vac
on dea.location=vac.location 
and dea.date=vac.date;

-- Total population VS Vaccination
select dea.location, dea.population,dea.continent, dea.date,
vac.new_vaccinations, 
Sum(vac.new_vaccinations) over (partition by dea.location order by dea.location,dea.date)as Vaccination_Rate_Rolling
-- (Max(Vaccination_Rate_Rolling)/avg(population))*100 as People_Vaccinated
-- , max(total_vaccinations),max(people_vaccinated), max(people_fully_vaccinated),
-- (max(total_vaccinations)/avg(population))*100 as Percent_population_vaccinated
from CovidDeaths dea join CovidVaccinations vac
on dea.location=vac.location 
and dea.date=vac.date
where dea.continent !=''
-- group by dea.location;
order by 1,4;

-- --USE CTE
with PopvsVac (location, population, continent, date, new_vaccinations, Vaccination_Rate_Rolling) 
as(
select dea.location, dea.population,dea.continent, dea.date,
vac.new_vaccinations, 
Sum(vac.new_vaccinations) over (partition by dea.location order by dea.location,dea.date)as Vaccination_Rate_Rolling
-- (Max(Vaccination_Rate_Rolling)/avg(population))*100 as People_Vaccinated
-- , max(total_vaccinations),max(people_vaccinated), max(people_fully_vaccinated),
-- (max(total_vaccinations)/avg(population))*100 as Percent_population_vaccinated
from CovidDeaths dea join CovidVaccinations vac
on dea.location=vac.location 
and dea.date=vac.date
where dea.continent !=''
-- group by dea.location;
-- order by 1,4
 )
select *, (Vaccination_Rate_Rolling/population)*100 
from PopvsVac;
-- you can use Temp Table to do this as well 

-- creating a view to store data for later visualisation 
create view PopvsVac as
select dea.location, dea.population,dea.continent, dea.date,
vac.new_vaccinations, 
Sum(vac.new_vaccinations) over (partition by dea.location order by dea.location,dea.date)as Vaccination_Rate_Rolling
-- (Max(Vaccination_Rate_Rolling)/avg(population))*100 as People_Vaccinated
-- , max(total_vaccinations),max(people_vaccinated), max(people_fully_vaccinated),
-- (max(total_vaccinations)/avg(population))*100 as Percent_population_vaccinated
from CovidDeaths dea join CovidVaccinations vac
on dea.location=vac.location 
and dea.date=vac.date
where dea.continent !=''
-- group by dea.location;
order by 1,4;

create view Canada_Deaths_per_Cases as 
select total_deaths, total_cases, (total_deaths/total_cases)*100 as DeathPercentage, 
date from CovidDeaths 
where continent !='' and 
location like '%Canada%' order by date;

Create view Percent_Population_Infected as
select population, total_cases, (total_cases/population)*100 as CasesPercentage, 
date from CovidDeaths 
where continent !='' 
and location like '%Canada%' order by date asc;

Create view Countries_with_highest_infections as
select location, max(total_cases), avg(population), (max(total_cases)/avg(population))*100 as Percent_Population_infected 
from CovidDeaths
where continent !='' 
Group by location
order by Percent_Population_infected Desc;

Create view Countries_With_Highest_Death_Count_per_Population as
select location, max(total_deaths) as Total_Death_Count
from CovidDeaths 
where continent!=''
Group by location
order by Total_Death_Count Desc;

create View Deaths_Percent_by_date_worldwide as
select date, sum(new_cases) as Total_Cases, sum(new_deaths) as Total_Deaths,
	(sum(new_deaths)/sum(new_cases))*100 as Deaths_per_cases
-- , total_deaths, total_cases, (total_deaths/total_cases)*100 as DeathPercentage, 
from CovidDeaths 
where continent !=''
group by date
order by date,Total_Cases; 

create view Total_Deaths_worldwide as  
select sum(new_cases) as Total_Cases, sum(new_deaths) as Total_Deaths,
	(sum(new_deaths)/sum(new_cases))*100 as Deaths_per_cases
-- , total_deaths, total_cases, (total_deaths/total_cases)*100 as DeathPercentage, 
from CovidDeaths 
where continent !=''
group by date
order by date,Total_Cases; 

create view Total_population_VS_Vaccination as
select dea.location, dea.population,dea.continent, dea.date,
vac.new_vaccinations, 
Sum(vac.new_vaccinations) over (partition by dea.location order by dea.location,dea.date)as Vaccination_Rate_Rolling
-- (Max(Vaccination_Rate_Rolling)/avg(population))*100 as People_Vaccinated
-- , max(total_vaccinations),max(people_vaccinated), max(people_fully_vaccinated),
-- (max(total_vaccinations)/avg(population))*100 as Percent_population_vaccinated
from CovidDeaths dea join CovidVaccinations vac
on dea.location=vac.location 
and dea.date=vac.date
where dea.continent !=''
-- group by dea.location;
order by 1,4;

















