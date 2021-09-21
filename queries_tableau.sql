
--- CREATE VIEWS TO WORK WITH TABLEAU

--- VIEW OF TOTAL CASES, DEATHS AND DEATH PERCENT
CREATE VIEW Total_Cases AS 
SELECT SUM(new_cases) AS cases, SUM(CAST(new_deaths as int)) AS deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS percent_deaths
FROM [Portfolio Project]..covid_deaths
--WHERE location = 'India'
WHERE continent IS NOT NULL
--GROUP BY date
--ORDER BY 1,2

SELECT *
FROM Total_Cases


--- VIEW OF TOTAL DEATHS BY LOCATION
CREATE VIEW Deaths_by_Loc AS
SELECT location, SUM(CAST(new_deaths as int)) AS total_deaths
FROM [Portfolio Project]..covid_deaths
--WHERE location = 'India'
WHERE continent IS NULL
AND location NOT IN ('World', 'International', 'European Union')
GROUP BY location
--ORDER BY 2

SELECT *
FROM Deaths_by_Loc
ORDER BY 2


--- VIEW OF TOTAL CASES BY LOCATION AND POPULATION
CREATE VIEW CasevsPop AS
SELECT location, population, MAX(total_cases) AS highest_infection_count, (MAX(total_cases)/population)*100 AS max_percent_infected
FROM [Portfolio Project]..covid_deaths
GROUP BY location, population
--ORDER BY 4 DESC

SELECT *
FROM CasevsPop


--- VIEW OF TOTAL CASES BY DATE
CREATE VIEW DatevsPop AS
SELECT location, population, date, MAX(total_cases) AS highest_infection_count, (MAX(total_cases)/population)*100 AS max_percent_infected
FROM [Portfolio Project]..covid_deaths
GROUP BY location, population, date
--ORDER BY 4 DESC

SELECT *
FROM DatevsPop
order by max_percent_infected desc