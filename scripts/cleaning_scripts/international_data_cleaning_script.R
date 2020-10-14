# script to take international data that could influence productivity 
# and combine it into one data-frame where possible 

# load libriaries
library(tidyverse)
library(readxl)
library(janitor)
library(countrycode)
library(naniar)

# read in data
CC_employment_prot = read_xlsx(
  "raw_data/additional_data/Cross country Employment Protection .xlsx", 
  skip = 3)

CC_infra_invest = read_xls(
  "raw_data/data/Cross country infrastructure investment.xls")

CC_r_and_d = read_xls(
  "raw_data/data/Cross country Gross Domestic Spending on R&D.xls")

CC_mental_health = read_csv(
  "raw_data/data/Cross Country Mental Health.csv")

CC_GDP_growth = read_xls(
  "raw_data/additional_data/Growth Of Output.xls",
  skip =3)

CC_mental_health = read_csv(
  "raw_data/data/Cross Country Mental Health.csv",
   col_names = c("location", "remove_4", "2010", "2009", "2008", "2007",
                 "2006", "2005", "2004", "remove_1", "remove_2", "remove_3"))

population_data <- read_csv(
  "raw_data/data/world_population_data.csv",
  skip = 3
)

global_comeptitiveness = read_xlsx(
  "raw_data/additional_data/Global Competitiveness Dataset.xlsx",
  sheet = 2, 
  skip = 2)

# a decision was made to focus on the top 23 'most producitive' countries
# this decision was aimed at saving time and making better conclusions on what
# factors best improve productivity

# define our countries and convert them to an abbreviated form
top_23 <- c("Australia", "Austria", "Belgium", "Canada", "Denmark", "Finland", "France", "Germany", "Greece", "Iceland", "Ireland", "Italy", "Japan", "Luxembourg", "Netherlands", "New Zealand", "Norway", "Portugal", "Spain", "Sweden", "Switzerland", "United Kingdom","United States")

top_23 <- countrycode(top_23, # change full country names to their abbreviated versions
                      origin = 'country.name', 
                      destination  = 'iso3c')




# clean each data set:
CC_employment_prot_clean <- CC_employment_prot %>%
  select(-...2) %>%
  filter(Time != "Country") %>%
  head(-1) %>%
  rename("location" = "Time") %>%
  mutate(location = countrycode(location, # change full country names to their abbreviated versions
                                origin = 'country.name',
                                destination  = 'iso3c')) %>%
  pivot_longer(cols = -location, names_to = "time", values_to = "employment_protection_value") %>%
  mutate_at(vars(-("location")), as.numeric) %>%
  filter(time < 2014) # no data available for 2014 onwards


CC_infra_invest_clean <- CC_infra_invest %>%
  clean_names() %>%
  filter(measure == "EUR") %>% # measure total euros spent instead of % of GDP
  mutate( value = replace_na(value, 0)) %>% # if NA let's assume there was no spending that year for that subject
  group_by(location, time) %>%
  summarise(total_investment = sum(value)) # sum up the total investment for that year


CC_r_and_d_clean <- CC_r_and_d %>%
  clean_names() %>%
  filter(measure == "MLN_USD") %>% # filter by USD millions
  select(c("location", "time", "value")) %>%
  rename("r_d_research_value" = "value")

CC_GDP_growth_clean <- CC_GDP_growth %>%
  select(-c("Country Name", "Indicator Name", "Indicator Code")) %>%
  rename("location" = "Country Code") %>%
  pivot_longer(cols = -"location", names_to = "time", values_to = "gdp_growth") %>%
  mutate_at(vars(-("location")), as.numeric) 

CC_mental_health_clean <- CC_mental_health %>%
  select(-c("remove_1", "remove_2", "remove_3", "remove_4")) %>%
  tail(-2) %>%
  pivot_longer(cols = -location, 
               names_to = "time", 
               values_to = "new_mental_health_units") %>%
  mutate(new_mental_health_units = 
           replace_na(new_mental_health_units, 0)) %>% # if NA assume no new units 
  mutate_at(vars(-("location")), as.numeric) %>%
  mutate(location = countrycode(location, # change full country names to their abbreviated versions
                              origin = 'country.name',
                              destination  = 'iso3c'))


population_data_clean <- population_data %>%
  select(-c("Country Name", "Indicator Name", "Indicator Code")) %>%
  pivot_longer(cols = -"Country Code", names_to = "time", values_to = "population") %>%
  rename("location" = "Country Code") %>%
  mutate(time = as.numeric(time))

# there is only 2 years worth of data within the Global Competitiveness but
# it may be useful for reference in future
top_23_append <- c("...5", "...6","...9", top_23)
global_comeptitiveness <- global_comeptitiveness[ ,colnames(global_comeptitiveness) %in% top_23_append, with=FALSE]


global_comeptitiveness_clean <- global_comeptitiveness %>%
  filter(...9 == "VALUE" | ...9 == "RANK") %>% 
  rename("measure" = "...5", "units" = "...6", "attribute" = "...9") %>%
  # select(-attribute) %>% # remove atribute column
  pivot_longer(cols = -c("measure", "units", "attribute"), names_to = "location", values_to = "global_competitiveness_value")


# join the data
CC_data <- CC_employment_prot_clean %>%
  full_join(CC_infra_invest_clean, by = c("location", "time")) %>%
  full_join(CC_r_and_d_clean, by = c("location", "time")) %>%
  full_join(CC_GDP_growth_clean, by = c("location", "time")) %>%
  full_join(CC_mental_health_clean, by = c("location", "time")) %>%
  full_join(population_data_clean, by = c("location", "time"))


CC_data <- CC_data %>%
  filter(location %in% top_23)
# export results to CSV
write_csv(CC_data, "clean_data/CC_data.csv")



