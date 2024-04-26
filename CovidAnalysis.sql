SELECT *
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is NOT NULL
ORDER BY 3, 4

--SElECT *
--FROM PortfolioProject.dbo.CovidVaccinations
--ORDER BY 3, 4

--- Select data that we are going to use

SELECT Location, date, total_cases, new_cases, total_deaths, population 
FROM PortfolioProject.dbo.CovidDeaths
ORDER BY 1, 2

-- looking at total cases vs total deaths
-- Shows likelihood of dying if you contract covid in certain countries
SELECT Location, date, total_cases, total_deaths, (100.0 * total_deaths/total_cases)  AS death_percent
FROM PortfolioProject.dbo.CovidDeaths
WHERE Location = 'Canada'
ORDER BY 1,2

-- Looking at total cases vs populatuion
SELECT Location, date, population, total_cases, total_deaths, (100.0 * total_cases/population)  AS PercentofPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
--WHERE Location = 'Canada'
ORDER BY 1,2


--looking at countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases) AS HighestInflectionCount, MAX((100.0 * total_cases/population))  
AS PercentofPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
--WHERE Location = 'Canada'
WHERE continent is NOT NULL
GROUP BY location, population
ORDER BY PercentofPopulationInfected DESC


--Showing Countries with highest Death count per population


SELECT continent, MAX(total_deaths) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
--WHERE Location = 'Canada'
WHERE continent is NOT NULL
GROUP BY continent 
ORDER BY TotalDeathCount DESC

-- LET'S BREAK THINGS DOWN BY CONTINENT



-- Showing the continents with the highest death count

SELECT continent, MAX(total_deaths) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
--WHERE Location = 'Canada'
WHERE continent is NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- Global numbers

SELECT SUM(new_cases) as TotalCases, SUM(new_deaths) as TotalDeaths,
CASE 
    WHEN SUM(new_cases) = 0 THEN NULL
    ELSE 100.0* SUM(new_deaths)/SUM(new_cases)
END as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not NULL
--GROUP by date
ORDER BY 1, 2

-- Joined to of the tables together
-- looking at total population vs vaccination

SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations
, SUM(CONVERT(BIGINT,new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,
dea.date) as RolloingPeopleVaccinated
, (100 * RolloingPeopleVaccinated/population)
FROM PortfolioProject.dbo.CovidDeaths AS dea
JOIN PortfolioProject.dbo.CovidVaccinations AS vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent is not NULL
ORDER BY 2, 3

-- USE CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, RolloingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,
dea.date) as RolloingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths AS dea
JOIN PortfolioProject.dbo.CovidVaccinations AS vac
        ON dea.location = vac.location
        AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, 100.0 * RolloingPeopleVaccinated / population 
FROM  PopvsVac


-- CReating view to store data for later visualiztions

CREATE View TotalDeathCount AS
SELECT continent, MAX(total_deaths) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
--WHERE Location = 'Canada'
WHERE continent is NOT NULL
GROUP BY continent
--ORDER BY TotalDeathCount DESC





























