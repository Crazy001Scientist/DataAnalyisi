
select *
from portfolioProject..covid
order by location

--deth percantage
select location, date, population, total_cases, total_deaths,
(total_deaths/total_cases)*100 as DeathPercentage, 
(total_cases/population)*100 as DeathPercentageToThePopulation
from portfolioProgect..covid
order by 1,2 
 
--total death count in the continents
 select continent, 
Max(convert(int, total_deaths)) as TotalDeathCount
from portfolioProject..covid
where continent is not NULL
group by continent
order by TotalDeathCount desc

--total death in a location
 select continent, location, 
Max(convert(int, total_deaths)) as TotalDeathCount
from portfolioProject..covid
where continent is not null
group by continent, location
order by TotalDeathCount desc

--total vaccination count
select continent, location, date, convert(bigint, new_vaccinations) as Vaccination,
sum(convert(bigint, new_vaccinations)) 
over (partition by location order by location, date)
as TotalVaccinetionCount
from portfolioProject..covid
where continent is not null
order by location, date

--percentage of population(infected) vaccinated
select continent, location, date, new_cases,
sum(new_cases) over (partition by location order by location, date)
as TotalCasesCount,
convert(bigint, new_vaccinations) as NewVaccination,
sum(convert(bigint, new_vaccinations)) 
over (partition by location order by location, date)
as TotalVaccinetionCount,
(people_vaccinated/nullif(total_cases, 0))*100 as PersentageOfVacciantedInfectedPeople,
(people_vaccinated/population)*100 as PersentageOfPopulationVaccianted
from portfolioProject..covid
where continent is not null
order by location, date
