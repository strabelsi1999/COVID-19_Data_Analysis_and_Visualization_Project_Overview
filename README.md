# COVID-19_Data_Analysis_and_Visualization_Project_Overview
## Objective:
This project explores the global impact of COVID-19 using SQL for data extraction, transformation, and analysis, and Tableau for data visualization. It provides insights into infection rates, mortality rates, and vaccination progress worldwide.

## Data Source: 
Our World in Data - COVID-19 Dataset (https://ourworldindata.org/covid-deaths)

## Tools & Skills Used:
    1. SQL: Joins, CTEs, Temp Tables, Window Functions, Aggregate Functions, Data Type Conversions, Views
    2. Tableau: Interactive Dashboard Design

## SQL Analysis Breakdown:
-Data Exploration:Extracted key fields: Location, Date, Total_Cases, New_Cases, Total_Deaths, Population.
-Mortality Rate Analysis:Calculated the likelihood of death from COVID-19 by dividing total deaths by total cases, showing results as a percentage.
-Infection Rate Analysis:Determined the percentage of the population infected by dividing total cases by the population size.
-Countries with Highest Infection Rate:Identified countries with the highest infection counts and infection rates relative to their population.
-Countries with Highest Death Count:Ranked countries by total COVID-19 deaths.
-Continental Death Counts:Aggregated total deaths per continent.
-Global Statistics:Summarized total cases, deaths, and calculated global death percentages.
-Vaccination Progress:Used joins and window functions to calculate rolling vaccination numbers and the percentage of the population vaccinated.
-CTEs and Temp Tables:Leveraged Common Table Expressions (CTEs) and temporary tables to streamline complex calculations.

##Tableau Dashboard:

-Total Cases and Deaths Overview:A line graph showing the global trend of COVID-19 cases and deaths over time.
-Mortality Rate Analysis:A bar chart displaying death percentages by country.
-Infection Rate by Population:A map visualizing the spread and infection percentage across countries.
-Vaccination Progress:A cumulative line graph illustrating vaccination rollout worldwide.
-Highest Infection and Death Rates:Ranked tables highlighting countries with the most severe COVID-19 impact.

## Conclusion: 
This project combines SQL’s robust data manipulation capabilities with Tableau’s powerful visualization features to provide a comprehensive analysis of COVID-19’s impact. It effectively identifies key insights, such as high-risk regions, mortality trends, and vaccination progress, enabling data-driven decision-making.
