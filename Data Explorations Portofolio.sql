SELECT *
FROM PortofolioProject..CovidDeaths
ORDER BY 3,4


SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortofolioProject..CovidDeaths
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortofolioProject..CovidDeaths
WHERE location = 'Indonesia'
ORDER BY 1,2

-- Looking at Total Cases vs Population

SELECT location, date,population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM PortofolioProject..CovidDeaths
WHERE location = 'Indonesia'
ORDER BY 1,2

-- Looking at Country with Highest Infection Rate compared to Population

SELECT location,population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortofolioProject..CovidDeaths
GROUP BY location,population
ORDER BY PercentPopulationInfected DESC

-- Showing Countries with Highest Death Count per Population

SELECT location, MAX(CAST(total_deaths AS INT)) as TotalDeathCount
FROM PortofolioProject..CovidDeaths
WHERE continent IS NOT null
GROUP BY location,population
ORDER BY TotalDeathCount DESC

-- by Continent

SELECT location, MAX(CAST(total_deaths AS INT)) as TotalDeathCount
FROM PortofolioProject..CovidDeaths
WHERE continent IS null
GROUP BY location
ORDER BY TotalDeathCount DESC


-- Showing Continent with the Highest Death Count

SELECT continent, MAX(CAST(total_deaths AS INT)) as TotalDeathCount
FROM PortofolioProject..CovidDeaths
WHERE continent IS NOT null
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- Global Number

SELECT date, SUM (new_cases) AS TotalCases, SUM(CAST(new_deaths AS INT)) AS TotalDeaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage 
FROM PortofolioProject..CovidDeaths
WHERE continent IS NOT null
GROUP BY date
ORDER BY 1,2

-- Looking at Total Population vs Vaccinations

-- USE CTE
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortofolioProject..CovidDeaths AS dea
JOIN PortofolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

-- USE TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortofolioProject..CovidDeaths AS dea
JOIN PortofolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

-- Create View to Store Data for Visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortofolioProject..CovidDeaths AS dea
JOIN PortofolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL