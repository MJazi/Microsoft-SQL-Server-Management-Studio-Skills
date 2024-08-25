Overview
This SQL script is designed to analyze COVID-19 data, focusing on cases, deaths, and vaccination rates across different countries and continents. The analysis is performed using a series of SELECT statements, Common Table Expressions (CTEs), temporary tables, and views. The script covers various aspects such as the percentage of population infected, death rates, and vaccination coverage.

Script Breakdown

1. Initial Data Exploration
Query: SELECT * FROM PortfolioProject..CovidDeaths WHERE continent is not null ORDER BY 3,4;
Purpose: To explore the structure of the CovidDeaths table by selecting all columns where the continent is specified.

2. Data Selection for Analysis
Query: SELECT Location, date, total_cases, new_cases, total_deaths, population FROM PortfolioProject..CovidDeaths WHERE continent is not null ORDER BY 1,2;
Purpose: To select specific columns from the CovidDeaths table that will be used for further analysis.

3. Case Fatality Analysis
Iran vs. USA:
Purpose: To compare the percentage of deaths relative to total cases between Iran and the USA.
Queries:
For Iran: SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage FROM PortfolioProject..CovidDeaths WHERE location like '%iran%' AND continent is not null ORDER BY 2 desc;
For USA: SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage FROM PortfolioProject..CovidDeaths WHERE location like '%states%' AND continent is not null ORDER BY 1,2 desc;

4. Infection Rate Analysis
Percentage of Population Infected:
Purpose: To determine the percentage of the population infected with COVID-19 in the USA and Iran.
Queries:
For USA: SELECT Location, date, total_cases, population, (total_cases/Population)*100 as Percentage_of_Population_Infected FROM PortfolioProject..CovidDeaths WHERE location like '%states%' AND continent is not null ORDER BY 1,2 desc;
For Iran: SELECT Location, date, total_cases, population, (total_cases/Population)*100 as Percentage_of_Population_Infected FROM PortfolioProject..CovidDeaths WHERE location like '%iran%' AND continent is not null ORDER BY 1,2 desc;

5. Global Analysis
Highest Infection and Death Rates:
Purpose: To identify countries with the highest infection and death rates relative to their population.
Queries:
Highest Infection Rate: SELECT Location, population, max(total_cases) as HighestInfectionCount, max((total_cases/Population))*100 as Percentage_of_Population_Infected FROM PortfolioProject..CovidDeaths WHERE continent is not null GROUP BY location, population ORDER BY 3 desc;
Highest Death Rate: SELECT Location, population, max(cast(total_deaths as int)) as HighestDeathCount, max((total_deaths/Population))*100 as Percentage_of_Fatalities_Population FROM PortfolioProject..CovidDeaths WHERE continent is not null GROUP BY location, population ORDER BY 3 desc;

6. Continent-Level Analysis
Purpose: To summarize COVID-19 data by continent.
Queries:
Death Count by Continent: SELECT continent, max(cast(total_deaths as int)) as HighestDeathCount FROM PortfolioProject..CovidDeaths WHERE continent is not null GROUP BY continent ORDER BY 2 desc;
Death Count by Location (excluding income categories): SELECT location, max(cast(total_deaths as int)) as HighestDeathCount FROM PortfolioProject..CovidDeaths WHERE continent is null AND location not in ('High income','Low income','Upper middle income','Lower middle income') GROUP BY location ORDER BY 2 desc;

7. Global Daily Analysis
Purpose: To aggregate global COVID-19 cases and deaths per day.
Queries:
Formatted and unformatted global numbers: Various queries to sum up new cases and deaths globally and calculate the death percentage.

8. Vaccination Analysis
Purpose: To compare the total population vs. the number of vaccinations administered.
Queries:
Joining CovidDeaths and CovidVaccinations tables to compute rolling vaccination totals.

9. Common Table Expressions (CTEs) and Temporary Tables
Purpose: To create intermediate results for further analysis.
Queries:
CTE: WITH PopvsVac (...) AS (...) SELECT *,(RollingPeopleVaxed/population)*100 as Percentage_of_PopVaxed FROM PopvsVac;
Temporary Table: Creation and use of a temporary table to store and query vaccination data.

10. Creating Views
Purpose: To store intermediate results for later use in visualizations.
Views Created:
PercentagePopVaxed: Stores vaccination data for further analysis.
CovidDeathPercentageinIran: Focuses on COVID-19 death percentages in Iran.

Notes

Commenting: Some sections of the script are commented out for specific analytical purposes. Uncomment these sections as needed.
Table and View Names: The script assumes the existence of tables PortfolioProject..CovidDeaths and PortfolioProject..CovidVaccinations. Ensure these tables are available in the database before running the script.
Data Accuracy: Filtering by continent might result in less accurate data compared to filtering by specific locations.
Conclusion
This script provides a comprehensive analysis of COVID-19 data, offering insights into infection and death rates across different countries and continents, as well as the impact of vaccination efforts. The use of CTEs, temporary tables, and views makes the script flexible for various types of analysis and visualization.






