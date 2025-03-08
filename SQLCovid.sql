--Queries used to discover the data


-- Looking at the Total cases vs Total deaths, Ratio of death
select location, date, total_cases,total_deaths, (CAST(total_deaths AS FLOAT) / convert(float,total_cases))*100 AS DeathPercentage	
from PortfolioProjectSQL1..CovidDeaths
WHERE continent is not null 
order by 1,2


--Looking at the final Total cases vs Total deaths
select location, max(total_cases) as total_cases ,max(total_deaths) as total_deaths, convert(float,max(total_deaths)) / convert(float,max(total_cases))*100 AS DeathPercentage
from PortfolioProjectSQL1..CovidDeaths
WHERE continent is not null 
group by location
order by 4 desc


-- Check most deadly countries to get corona in
select location, date, total_cases,total_deaths, CAST(total_deaths AS FLOAT) / NULLIF(total_cases, 0)*100 AS DeathPercentage
from PortfolioProjectSQL1..CovidDeaths 
WHERE total_cases > 5000 AND continent is not null
order by 5 DESC


select location,  max(CAST(total_cases as INT)) as total_cases , population,  max(CAST(total_cases as FLOAT)) / population *100 AS DeathPercentage
from PortfolioProjectSQL1..CovidDeaths 
WHERE continent is not null
group by location, population
order by 4 DESC


-- What percentage of population got Covid
select location, date, total_cases, population, CAST(total_cases AS FLOAT) / NULLIF(population,0) *100 as Infection_Rate
from PortfolioProjectSQL1..CovidDeaths 
WHERE continent is not null
order by 5 DESC

select location, max(total_cases)
from PortfolioProjectSQL1..CovidDeaths
WHERE continent is not null
group by location
order by 2 desc


-- Countries with higehst death percentage among population
select location, date,total_deaths, population, CAST(total_deaths AS FLOAT) / NULLIF(population,0) *100 as Death_Rate
from PortfolioProjectSQL1..CovidDeaths 
WHERE continent is not null
order by 5 DESC


-- Countries with higehst death percentage among infected
select location, date, total_cases,total_deaths, CAST(total_deaths AS FLOAT) / CAST(total_cases AS FLOAT) *100 as Death_Rate
from PortfolioProjectSQL1..CovidDeaths 
WHERE continent is not null
order by 5 DESC

select location, max(total_deaths) as total_deaths
from PortfolioProjectSQL1..CovidDeaths
WHERE continent is not null
group by location
order by 2 desc

-- By continent

select location, max(total_deaths)
from PortfolioProjectSQL1..CovidDeaths
WHERE continent is null AND location != 'World'
group by location
order by 2 desc

-- below is wrong --
select continent, max(total_deaths)
from PortfolioProjectSQL1..CovidDeaths
WHERE continent is not null
group by continent
order by 2 desc
-- above is wrong --

-- Global Numbers 
select location, date, total_cases, total_deaths
from PortfolioProjectSQL1..CovidDeaths
where location = 'World'
order by 2

-- Death Percentage Per Day
select location, date,  sum(CAST(new_cases as INT)) as total_cases , sum(CAST(new_deaths as INT)) as total_deaths,  sum(CAST(new_deaths AS FLOAT)) / sum(NULLIF(new_cases, 0))*100 AS DeathPercentage
from PortfolioProjectSQL1..CovidDeaths
WHERE location = 'World'
GROUP by location, date
order by 2

-- Total Death Percentage
select location, date,  max(CAST(total_cases as INT)) as total_cases , max(CAST(total_deaths as INT)) as total_deaths,  max(CAST(total_deaths AS FLOAT)) / max(NULLIF(total_cases, 0))*100 AS DeathPercentage
from PortfolioProjectSQL1..CovidDeaths
WHERE location = 'World'
GROUP by location, date
order by 2


-- Classification of countries
WITH RiskInfo AS 
(
SELECT	location, 
		CAST(MAX(total_cases) AS FLOAT)/NULLIF(MAX(population),0)*100 AS Infection_Rate 
FROM PortfolioProjectSQL1..CovidDeaths 
WHERE continent IS NOT NULL GROUP BY location 
) 
SELECT	location, 
		Infection_Rate, 
CASE	WHEN Infection_Rate > 10 
			THEN 'High Risk' 
		WHEN Infection_Rate BETWEEN 5 AND 10 
			THEN 'Medium Risk' 
		ELSE 'Low Risk' 
END AS Risk_Level 
FROM RiskInfo 
ORDER BY Infection_Rate DESC;

--Ranking Countries by continent
 WITH DeathRateInfo AS 
 ( 
 SELECT	location, 
		continent, 
		MAX(total_deaths) AS max_total_deaths, 
		MAX(total_cases) AS max_total_cases, 
		CAST(MAX(total_deaths) AS FLOAT)/NULLIF(MAX(total_cases),0)*100 AS Death_Rate 
FROM PortfolioProjectSQL1..CovidDeaths 
WHERE continent IS NOT NULL 
GROUP BY location, continent 
) 
SELECT	location, 
		continent, 
		max_total_deaths, 
		max_total_cases, 
		Death_Rate, 
		RANK() OVER (PARTITION BY continent ORDER BY Death_Rate DESC) AS Death_Rate_Rank 
FROM DeathRateInfo 
ORDER BY continent, Death_Rate_Rank;



---Ranking countries
 WITH DeathRateInfo AS 
 ( 
 SELECT	location,  
		MAX(total_deaths) AS max_total_deaths, 
		MAX(total_cases) AS max_total_cases, 
		CAST(MAX(total_deaths) AS FLOAT)/NULLIF(MAX(total_cases),0)*100 AS Death_Rate 
FROM PortfolioProjectSQL1..CovidDeaths 
WHERE continent IS NOT NULL 
GROUP BY location
) 
SELECT	location, 
		max_total_deaths, 
		max_total_cases, 
		Death_Rate, 
		RANK() OVER (ORDER BY Death_Rate DESC) AS Death_Rate_Rank 
FROM DeathRateInfo 
ORDER BY Death_Rate_Rank;


--Growth rate of the infected

 WITH GrowthRate AS 
 ( 
 SELECT	location, 
		date, 
		total_cases, 
		LAG(total_cases, 1) OVER (PARTITION BY location ORDER BY date) AS Previous_Total_Cases 
FROM PortfolioProjectSQL1..CovidDeaths 
WHERE continent IS NOT NULL 
) 
SELECT	location, 
		date, 
		total_cases, 
		Previous_Total_Cases, 
CASE 
	WHEN Previous_Total_Cases = 0 OR Previous_Total_Cases IS NULL 
		THEN NULL ELSE ((CAST(total_cases AS FLOAT) - Previous_Total_Cases) / Previous_Total_Cases) * 100 
END AS Daily_Growth_Rate 
FROM GrowthRate 
where total_cases > 500
ORDER BY 1,2





--Vaccination


-- Total Population vs Vaccination
select	dea.continent, 
		dea.location, 
		dea.date, 
		dea.population, 
		vac.new_vaccinations, 
		dea.new_cases,
		dea.total_deaths,
		dea.new_deaths,
		CAST(dea.total_deaths AS FLOAT) / NULLIF(total_cases, 0)*100 AS DeathPercentage,
		sum(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location ,dea.date) as Rolling_Vaccinations
		from PortfolioProjectSQL1..CovidDeaths dea
join	PortfolioProjectSQL1..CovidVaccinations vac
on		dea.location = vac.location 
and		dea.date = vac.date
where dea.continent is not null AND new_vaccinations is not null
order by 2,3;


-- Country with most vaccination rate
select	dea.location, 
		dea.population, 
		round(max(convert(float,vac.total_vaccinations))/population,3) as vaccinations_ratio
		from PortfolioProjectSQL1..CovidDeaths dea
join	PortfolioProjectSQL1..CovidVaccinations vac
on		dea.location = vac.location 
GROUP by dea.location, dea.population
order by 3 desc


-- CTE 
With PopvsVac(continent, location, date, population,new_vaccinations, Rolling_Vaccinations)
as
(
select	dea.continent, 
		dea.location, 
		dea.date, 
		dea.population, 
		vac.new_vaccinations, 
		sum(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location ,dea.date) as Rolling_Vaccinations
		from PortfolioProjectSQL1..CovidDeaths dea
join	PortfolioProjectSQL1..CovidVaccinations vac
on		dea.location = vac.location 
and		dea.date = vac.date
where dea.continent is not null and new_vaccinations is not null
)
select *, 
       (CAST(Rolling_Vaccinations AS FLOAT) / population) * 100 as Rolling_Vaccination_Population
from PopvsVac;



-- TEMP TABLE
DROP TABLE IF EXISTS TablePercentPopulationVaccinated
Create table TablePercentPopulationVaccinated
(
continent nvarchar(255), location nvarchar(255), date date, population numeric, new_vaccinations numeric, Rolling_Vaccinations numeric
)
insert into TablePercentPopulationVaccinated
select	dea.continent, 
		dea.location, 
		dea.date, 
		dea.population, 
		vac.new_vaccinations, 
		sum(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location ,dea.date) as Rolling_Vaccinations
		from PortfolioProjectSQL1..CovidDeaths dea
join	PortfolioProjectSQL1..CovidVaccinations vac
on		dea.location = vac.location 
and		dea.date = vac.date
where dea.continent is not null
select *, 
       (CAST(Rolling_Vaccinations AS FLOAT) / population) * 100 as Rolling_Vaccination_Population
from TablePercentPopulationVaccinated;



-- Creating view to store for visualizations
DROP VIEW IF EXISTS ViewPercentPopulationVaccinated;
Create View ViewPercentPopulationVaccinated as 
select	dea.continent, 
		dea.location, 
		dea.date, 
		dea.population, 
		vac.new_vaccinations, 
		sum(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location ,dea.date) as Rolling_Vaccinations
		from PortfolioProjectSQL1..CovidDeaths dea
join	PortfolioProjectSQL1..CovidVaccinations vac
on		dea.location = vac.location 
and		dea.date = vac.date
where dea.continent is not null;



--All previous information
select dea.location, dea.date, dea.total_cases, dea.total_deaths, vac.total_vaccinations,
		sum(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.date) as Rolling_Vaccinations,
		round(convert(float,vac.total_vaccinations)/dea.population,3) as vaccinations_ratio,
		CAST(dea.total_deaths AS FLOAT) / NULLIF(dea.population,0) *100 as Death_Rate,
		CAST(dea.total_cases AS FLOAT) / NULLIF(dea.population,0) *100 as Infection_Rate
		from PortfolioProjectSQL1..CovidDeaths dea
join	PortfolioProjectSQL1..CovidVaccinations vac
on		dea.location = vac.location 
and		dea.date = vac.date
where dea.location = 'World'
order by 2

-- All

With AllInfo(location,population, date, total_cases, total_deaths, total_vaccinations, Rolling_Vaccinations, vaccinations_ratio,Death_Rate,Infection_Rate )
as
(
select dea.location,dea.population, dea.date, dea.total_cases, dea.total_deaths, vac.total_vaccinations,
		sum(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.date) as Rolling_Vaccinations,
		round(convert(float,vac.total_vaccinations)/dea.population,3) as vaccinations_ratio,
		CAST(dea.total_deaths AS FLOAT) / NULLIF(dea.population,0) *100 as Death_Rate,
		CAST(dea.total_cases AS FLOAT) / NULLIF(dea.population,0) *100 as Infection_Rate
		from PortfolioProjectSQL1..CovidDeaths dea
join	PortfolioProjectSQL1..CovidVaccinations vac
on		dea.location = vac.location 
and		dea.date = vac.date
where dea.location = 'World'
)
select *, 
       (CAST(Rolling_Vaccinations AS FLOAT) / population) * 100 as Rolling_Vaccination_Population
from AllInfo;




--Queries used for Tableau Project

-- 1. 

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as float))/SUM(convert(float,New_Cases))*100 as DeathPercentage
From PortfolioProjectSQL1..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2


-- 2. 

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProjectSQL1..CovidDeaths
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc


-- 3.

Select Location, date,  MAX(total_cases) as HighestInfectionCount,  Max((convert(float,total_cases)/convert(float,population)))*100 as PercentPopulationInfected
From PortfolioProjectSQL1..CovidDeaths
--Where location like '%states%'
Group by Location, date
order by 1,2


-- 4.


Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((convert(float,total_cases)/convert(float,population)))*100 as PercentPopulationInfected
From PortfolioProjectSQL1..CovidDeaths
--Where location like '%states%'
WHERE continent is not null
Group by Location, Population, date
order by 1, date


-- 5.

Select dea.continent, dea.location, dea.date, dea.population
, MAX(vac.total_vaccinations) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProjectSQL1..CovidDeaths dea
Join PortfolioProjectSQL1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
group by dea.continent, dea.location, dea.date, dea.population
order by 1,2,3







select	dea.continent, 
		dea.date, 
		dea.population, 
		vac.new_vaccinations, 
		dea.new_cases,
		dea.total_deaths,
		dea.new_deaths,
		CAST(dea.total_deaths AS FLOAT) / NULLIF(total_cases, 0)*100 AS DeathPercentage,
		sum(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location ,dea.date) as Rolling_Vaccinations
		from PortfolioProjectSQL1..CovidDeaths dea
join	PortfolioProjectSQL1..CovidVaccinations vac
on		dea.location = vac.location 
and		dea.date = vac.date
where dea.continent is not null AND new_vaccinations is not null
order by 6 Desc;




-- Barplot Death

SELECT 
    continent, 
	date,
    SUM(new_cases) AS total_cases, 
    SUM(CAST(new_deaths AS INT)) AS total_deaths, 
    (SUM(CAST(new_deaths AS FLOAT)) / NULLIF(SUM(CONVERT(FLOAT, new_cases)), 0)) * 100 AS DeathPercentage
FROM PortfolioProjectSQL1..CovidDeaths
WHERE continent IS NOT NULL 
GROUP BY continent, date
ORDER BY 1,2;


-- Barplot vaccine
SELECT 
    dea.continent,
	dea.date,
    SUM(CAST(dea.new_vaccinations AS INT)) AS total_vacinations
from PortfolioProjectSQL1..CovidVaccinations dea
WHERE dea.continent IS NOT NULL 
GROUP BY dea.continent, dea.date
ORDER BY 1,2;

-- Table

Select	dea.date,
		dea.location,
		dea.population,
		SUM(new_cases) as total_cases, 
		SUM(cast(new_deaths as int)) as total_deaths, 
		SUM(cast(new_deaths as float)) / NULLIF(SUM(convert(float, new_cases)), 0) * 100 as DeathPercentage,
		SUM(CAST(vac.new_vaccinations AS INT)) AS total_vacinations,
		MAX(vac.total_vaccinations) as RollingPeopleVaccinated,
		SUM(cast(vac.new_vaccinations as float)) / NULLIF(SUM(convert(float, dea.population)), 0) * 100 as VaccinationPercentage
from PortfolioProjectSQL1..CovidDeaths dea
join	PortfolioProjectSQL1..CovidVaccinations vac
on		dea.location = vac.location 
and		dea.date = vac.date
--Where location like '%states%'
where dea.continent is not null 
group by dea.location, dea.population, dea.date
--Group By date
order by 2,1


-- Percent People Vaccinated

Select dea.Location, dea.continent, dea.date,  dea.population, MAX(vac.total_vaccinations) as TotalVaccinations, Max((convert(float,vac.total_vaccinations)/convert(float,population)))*100 as PercentPopulationVaccinated
From PortfolioProjectSQL1..CovidDeaths dea
Join PortfolioProjectSQL1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--Where location like '%states%'
Group by dea.continent, dea.Location, population, dea.date
order by  6 desc

