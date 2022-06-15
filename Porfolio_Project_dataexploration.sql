SELECT *
FROM PorfolioProject1..covid_deaths
WHERE continent is not null
order by 3,4

SELECT *
FROM PorfolioProject1..covid_vaccionations
order by 3,4

--Select Data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PorfolioProject1..covid_deaths
ORDER BY 1,2

--Looking at Total cases vs Total Deaths
--Shows the Death rate of dying from Covid in the United States

SELECT Location, date, total_cases,total_deaths, (Total_deaths/total_cases)*100 as DeathRate
FROM PorfolioProject1..covid_deaths
Where location like '%states%'
ORDER BY 1,2

--Total Cases vs Population

SELECT Location, date, total_cases,population, (total_cases/population)*100 as Population_Percentage_Infected
FROM PorfolioProject1..covid_deaths
--Where location like '%states%'
ORDER BY 1,2

--Highest Infection Rate


SELECT Location, population, Max(total_cases) as Highest_Infected, Max(total_cases/population)*100 as Population_Percentage_Infected
FROM PorfolioProject1..covid_deaths
--Where location like '%states%'
Group by location, population
ORDER BY Population_Percentage_Infected desc

--Highest Death Count per Capita

SELECT Location, MAX(cast(total_deaths as bigint)) as Total_Death_Count 
From PorfolioProject1..covid_deaths
--Where location like '%states%'
Group by location
ORDER BY Total_Death_Count desc


--Continent


SELECT continent, MAX(cast(total_Deaths as bigint)) as Total_Death_Count
From PorfolioProject1..covid_deaths
Where continent is not null
Group by continent
order by Total_Death_Count desc

-- Global Numbers

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PorfolioProject1..covid_deaths
where continent is not null
--Group by date
order by 1,2

--Vaccination Population


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location,dea.date) as Total_Pop_Vac
--, (Total_Pop_Vac/population)*100
FROM PorfolioProject1..covid_deaths dea
Join PorfolioProject1..covid_vaccionations vac
	on dea.location = vac.location
	and dea.date =vac.date
WHERE dea.continent is not null
order by 2,3

--CTE

With PopvsVac (Continent, Location, date, population, new_vaccinations, Total_Pop_Vac)
as
(Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location,dea.date) as Total_Pop_Vac
--, (Total_Pop_Vac/population)*100
FROM PorfolioProject1..covid_deaths dea
Join PorfolioProject1..covid_vaccionations vac
	on dea.location = vac.location
	and dea.date =vac.date
WHERE dea.continent is not null
--order by 2,3
)
SELECT*, (Total_Pop_Vac/population)*100 as PercentVac
FROM PopvsVac

--TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table	#PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
Total_Pop_Vac numeric
)


Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location,dea.date) as Total_Pop_Vac
--, (Total_Pop_Vac/population)*100
FROM PorfolioProject1..covid_deaths dea
Join PorfolioProject1..covid_vaccionations vac
	on dea.location = vac.location
	and dea.date =vac.date
WHERE dea.continent is not null
--order by 2,3

SELECT *, (Total_Pop_Vac/population)*100 as PercentVac
From #PercentPopulationVaccinated

--View for Tableau

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location,dea.date) as Total_Pop_Vac
--, (Total_Pop_Vac/population)*100
FROM PorfolioProject1..covid_deaths dea
Join PorfolioProject1..covid_vaccionations vac
	on dea.location = vac.location
	and dea.date =vac.date
WHERE dea.continent is not null
--order by 2,3
