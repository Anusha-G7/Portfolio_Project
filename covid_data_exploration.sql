
--- INSPECTING COVID DEATHS

--- Query no. 1 to sort the covid deaths by 3 and 4
SELECT *
FROM [Portfolio Project]..covid_deaths
WHERE continent IS NOT NULL
ORDER BY 3,4

--- Query no. 2 to sort the covid vaccinations by 3 - location and 4 - date
SELECT *
FROM [Portfolio Project]..covid_vaccinations
WHERE continent IS NOT NULL
ORDER BY 3,4

--- Extract the needed columns from the 1st table
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM [Portfolio Project]..covid_deaths
WHERE continent IS NOT NULL
ORDER BY 1,2

--- Total cases vs Total deaths
--- Probability (Likelihood) of dying if infected
SELECT location, date, total_cases, total_deaths, (CAST(total_deaths AS int)/total_cases)*100 AS percent_deaths
FROM [Portfolio Project]..covid_deaths
WHERE location = 'India'
AND continent IS NOT NULL
ORDER BY 1,2

--- Total cases vs Population
--- Percent infected by Covid - 19
SELECT location, date, population, total_cases, (total_cases/population)*100 AS percent_infected
FROM [Portfolio Project]..covid_deaths
WHERE location = 'India'
AND continent IS NOT NULL
ORDER BY 1,2

--- Any other countries that I might be interested in!
--SELECT location, date, population, total_cases, (total_cases/population)*100 AS percent_infected
--FROM [Portfolio Project]..covid_deaths
--WHERE location like '%korea%'
--ORDER BY 1,2

--- Highest infected rates vs Population of different countries
SELECT location, population, MAX(total_cases) AS highest_infection_count, (MAX(total_cases)/population)*100 AS max_percent_infected
FROM [Portfolio Project]..covid_deaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY 4 DESC

--- Highest death rates vs Population of different countries
SELECT location, population, MAX(CAST(total_deaths AS int)) AS highest_death_count, (MAX(CAST(total_deaths AS int))/population)*100 AS max_percent_deaths
FROM [Portfolio Project]..covid_deaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY 3 DESC

--- Highest death counts for various locations
SELECT location, MAX(CAST(total_deaths AS int)) AS highest_death_count
FROM [Portfolio Project]..covid_deaths
WHERE continent IS NULL
GROUP BY location
ORDER BY 2 DESC

--- Highest death counts for various continents
SELECT continent, MAX(CAST(total_deaths AS int)) AS total_death_count
FROM [Portfolio Project]..covid_deaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY 2 DESC

--- There are instances in the dataset where location is replaced by continent and as a result of that continent is NULL
--- The following 2 queries give us an opportunity to cross-check our total death count
SELECT continent, SUM(CAST(total_deaths AS int)) AS total_death_count
FROM [Portfolio Project]..covid_deaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY 2 DESC

SELECT location, SUM(CAST(total_deaths AS int)) AS total_death_count
FROM [Portfolio Project]..covid_deaths
WHERE continent IS NULL
GROUP BY location
ORDER BY 2 DESC

--- GLOBAL NUMBERS
--- The data of the whole world by dates

SELECT SUM(total_cases) AS cases, SUM(CAST(total_deaths AS int)) AS deaths, SUM(CAST(total_deaths AS int))/SUM(total_cases)*100 AS percent_deaths
FROM [Portfolio Project]..covid_deaths
---WHERE location = 'India'
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2

SELECT SUM(new_cases) AS cases, SUM(CAST(new_deaths as int)) AS deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS percent_deaths
FROM [Portfolio Project]..covid_deaths
--WHERE location = 'India'
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2

--- Total cases vs Total deaths
SELECT date, SUM(total_cases) AS total_cases, SUM(CAST(total_deaths AS int)) AS total_deaths, SUM(CAST(total_deaths AS int))/SUM(total_cases)*100 AS percent_deaths
FROM [Portfolio Project]..covid_deaths
---WHERE location = 'India'
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

--- New cases vs New deaths
SELECT date, SUM(new_cases) AS new_cases, SUM(cast(new_deaths as int)) AS new_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS percent_deaths
FROM [Portfolio Project]..covid_deaths
--WHERE location = 'India'
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2


--- INSPECTING COVID VACCINATIONS

--- Let's jog our memory on the vaccinations table
SELECT *
FROM [Portfolio Project]..covid_vaccinations

--- Joining the above two tables
SELECT *
FROM [Portfolio Project]..covid_deaths AS dea
JOIN [Portfolio Project]..covid_vaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date

--- Population vs vaccinations for different locations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM [Portfolio Project]..covid_deaths AS dea
JOIN [Portfolio Project]..covid_vaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3

--- Since, there are a lot of NULL values in new_vaccinations column, we can use partition by to add them as they come in
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_sum_vac
FROM [Portfolio Project]..covid_deaths AS dea
JOIN [Portfolio Project]..covid_vaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3

--- Use CTE as operations can't be performed directly with created columns
WITH PopvsVac (continent, location, date, population, new_vaccinations, rolling_sum_vac)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_sum_vac
FROM [Portfolio Project]..covid_deaths AS dea
JOIN [Portfolio Project]..covid_vaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3
)

SELECT *, rolling_sum_vac/population*100 AS rolling_vac_percent
FROM PopvsVac

--- To get the total people vaccinated precentage
--SELECT location, population, MAX(rolling_sum_vac), (MAX(rolling_sum_vac)/population)*100
--FROM PopvsVac
--WHERE rolling_sum_vac IS NOT NULL
--GROUP BY location, population



--- TEMP TABLE

DROP TABLE IF EXISTS PopvsVac_Temp
CREATE TABLE PopvsVac_Temp
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_sum_vac numeric
)

INSERT INTO PopvsVac_Temp
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_sum_vac
FROM [Portfolio Project]..covid_deaths AS dea
JOIN [Portfolio Project]..covid_vaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3

SELECT *
FROM PopvsVac_Temp



--- Creating VIEWS to store data for later

CREATE VIEW PopvsVac_View AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_sum_vac
FROM [Portfolio Project]..covid_deaths AS dea
JOIN [Portfolio Project]..covid_vaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3

SELECT location, population, MAX(rolling_sum_vac) AS total_vac, (MAX(rolling_sum_vac)/population)*100 AS total_vac_percent
FROM PopvsVac_View
WHERE rolling_sum_vac IS NOT NULL
GROUP BY location, population
ORDER BY 3 DESC

