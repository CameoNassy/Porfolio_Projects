Select * 
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 3,4

-- Select * 
-- From PortfolioProject..CovidVaccinations
-- Order by 3,4

-- Select the data to be used

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of death in case of covid contract

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where location like 'pakistan' and continent is not null
Order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

Select location, date, population, total_cases, (total_cases/population)*100 as InfectionPercentage
From PortfolioProject..CovidDeaths
where location like '%pakistan%'
Order by 1,2

-- Looking at countries with Highest Infection Rrate Compares to population

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as InfectionPercentage
From PortfolioProject..CovidDeaths
Group by location, population
order by InfectionPercentage desc

-- Showing Countries with Highest Death Count per Population

Select location, MAX(total_deaths) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by location
order by TotalDeathCount desc

-- Let's Break things down by continent

Select continent, MAX(total_deaths) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathCount desc

-- Showing the continents with the highest death count per population

Select continent, MAX(total_deaths) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(New_deaths)/SUM(New_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
--Group by date
Order by 1,2



-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null



Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location order by dea.location, dea.date) as Rolling_People_Vaccinations
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

--Use CTE to know how much percentage of population is vaccinated each day

With PopvsVac (continet, Loacation, Date, Population, New_Vaccination, Rolling_People_Vaccinated)
as
(Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location order by dea.location, dea.date) as Rolling_People_Vaccinations
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
)

Select *, (Rolling_People_Vaccinated/Population)*100 as Rolling_Vac_Percent
From PopvsVac


-- Temp Table

Drop Table if exists #Rolling_Vac_Percent
Create Table #Rolling_Vac_Percent
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric
,Rolling_People_Vaccinated numeric
) 

Insert into #Rolling_Vac_Percent
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location order by dea.location, dea.date) as Rolling_People_Vaccinations
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

Select *, (Rolling_People_Vaccinated/Population)*100 as Rolling_Vac_Percent
From #Rolling_Vac_Percent


-- Creating View to store data for later visualisations

Create View Rolling_Vac_Percent as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location order by dea.location, dea.date) as Rolling_People_Vaccinations
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

Select *
From Rolling_Vac_Percent
