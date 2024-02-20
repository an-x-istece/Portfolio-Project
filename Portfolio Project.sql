SELECT *
FROM [Tutorial Projects]..CovidDeaths
WHERE location like '%world%'

SELECT *
FROM [Tutorial Projects]..CovidDeaths
order by 2

--SELECT *
--FROM [Tutorial Projects]..CovidVaccinations

--Data to be used
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM [Tutorial Projects]..CovidDeaths
WHERE continent is not NULL
ORDER BY 1, 2

-- Total Cases Vs Total Deaths
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM [Tutorial Projects]..CovidDeaths
WHERE location like 'Nigeria'
ORDER BY 1, 2

--Total Cases vs Population
SELECT location, date, total_cases, population, (total_cases/population)*100 as PercentageOfThePopulationWithCOVID
FROM [Tutorial Projects]..CovidDeaths
WHERE location like '%states%'
ORDER BY 5 DESC

--Looking at countries with highest infection rate compared to population
SELECT location, MAX(total_cases) AS HighestInfectionCount, population, MAX((total_cases/population))*100 as PercentageInfected
FROM [Tutorial Projects]..CovidDeaths
WHERE continent is not NULL
GROUP BY location, population
ORDER BY 4 DESC

-- Looking at countries with highest death count per population
SELECT location, MAX(cast(total_deaths as int)) AS FatalityCount
FROM [Tutorial Projects]..CovidDeaths
WHERE continent is not NULL
GROUP BY location
ORDER BY 2 DESC

-- BREAKING THINS DOWN BY CONTINENT SOMEWHAT CORRECTLY
SELECT location, MAX(cast(total_deaths as int)) AS FatalityCount
FROM [Tutorial Projects]..CovidDeaths
WHERE continent is  NULL
GROUP BY location
ORDER BY 2 DESC

-- BREAKING THINGS DOWN BY CONTINENT FOR VISUALIZATION 
SELECT continent, MAX(cast(total_deaths as int)) AS FatalityCount
FROM [Tutorial Projects]..CovidDeaths
WHERE continent is  not NULL
GROUP BY continent
ORDER BY 2 DESC

--SHOWING THE CONTINENT WITH THE HIGHEST DEATH COUNT PER POPULATION
SELECT continent, MAX(cast(total_deaths as int) / population) AS FatalityCount
FROM [Tutorial Projects]..CovidDeaths
WHERE continent is not NULL
GROUP BY continent
ORDER BY 2 DESC


--GLOBAL NUMBERS
SELECT SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) AS TotalDeaths,( SUM(cast(new_deaths as int)) / SUM(new_cases) )* 100 as deathrate
FROM [Tutorial Projects]..CovidDeaths
ORDER BY 1 DESC

--TOTAL POPULATION VS VACCINATION
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
AS RollingPeopleVaccinated
FROM [Tutorial Projects]..CovidDeaths dea
JOIN [Tutorial Projects]..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2, 3

--FINDING OUT WHAT FRACTION OF A COUNTRY'S POPULATION IS VACCINATED USING A CTE
WITH CTE_VaccinatedPeople (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
AS RollingPeopleVaccinated
FROM [Tutorial Projects]..CovidDeaths dea
JOIN [Tutorial Projects]..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2, 3
)

SELECT *, (RollingPeopleVaccinated / population) * 100 AS PercentageOfVaccinatedPeeps
FROM CTE_VaccinatedPeople



--FINDING OUT WHAT FRACTION OF A COUNTRY'S POPULATION IS VACCINATED USING A TEMP TABLE
DROP TABLE IF EXISTS #Temp_VaccineStats

CREATE TABLE #Temp_VaccineStats(
continent varchar(50),
location varchar(50),
date datetime,
population int,
new_vaccinations int,
RollingPeopleVaccinated int
)

INSERT INTO #Temp_VaccineStats
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
AS RollingPeopleVaccinated
FROM [Tutorial Projects]..CovidDeaths dea
JOIN [Tutorial Projects]..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null

SELECT *, (RollingPeopleVaccinated / population) * 100 AS PercentageOfVaccinatedPeeps
FROM #Temp_VaccineStats

-- CREATING A VIEW
CREATE VIEW PercentageContinentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
AS RollingPeopleVaccinated
FROM [Tutorial Projects]..CovidDeaths dea
JOIN [Tutorial Projects]..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null