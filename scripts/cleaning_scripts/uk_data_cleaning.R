# script to tidy UK productivity measurements

# load libriaries
library(tidyverse)
library(readxl)
library(janitor)
library(naniar)

uk_education_prod <- read_excel(
  "raw_data/additional_data/UK Education Productivity.xlsx",
  skip = 3,
  n_max = 3)

uk_education_exp <- read_excel(
  "raw_data/additional_data/UK Education Productivity.xlsx",
  sheet = 8, 
  skip = 2, 
  n_max = 10)

uk_historic_prod <- read_excel(
  "raw_data/additional_data/UK Labour Productivity - Historical.xls", 
  sheet = 3,
  skip = 3)

uk_labour_prod_industry = read_xls(
  "raw_data/additional_data/UK Labour Productivity - Industry division.xls",
  sheet = 4, 
  skip = 6)

uk_sickness_records = read_xlsx(
  "raw_data/additional_data/UK Labour Market - Sickness and Absence.xlsx", 
  sheet = 6, skip = 5, n_max = 15)

uk_arg_prod <- read_xls(
  "raw_data/additional_data/UK Agriculture Productivity .xls", 
  sheet = 2, 
  skip = 9, 
  n_max = 3)

uk_arg_breakdown <- read_xls(
  "raw_data/additional_data/UK Agriculture Productivity .xls",
  sheet = 2, 
  skip = 16, 
  n_max = 4)

uk_berd_exp_sources <- read_xls(
  "raw_data/additional_data/UK Business Enterprise Research and Development.xls",
  sheet = 4, 
  skip = 23, 
  n_max = 20)

uk_berd_exp <- read_xls(
  "raw_data/additional_data/UK Business Enterprise Research and Development.xls", 
   sheet = 2,
  skip = 3)

uk_infra_invest = read_xls(
  "raw_data/data/Experimental Measures of Infrastructure Investment Dataset.xls", 
  sheet = 3, 
  skip = 3)

uk_intangible_assests = read_xlsx(
  "raw_data/data/Experimental Estimates of Investment in Intangible Assets in the UK.xlsx", 
  sheet = 2, 
  skip = 3)

uk_labour_prod_public = read_xlsx(
  "raw_data/data/UK Public Service Productivity.xlsx", 
  sheet = 2, 
  skip = 4,
  n_max = 21)

labour_productivity = read_xlsx(
  "raw_data/data/Uk Labour Productivity - Time Series.xlsx")

uk_yearly_gdp = read_xlsx(
  "raw_data/data/UK GDP Estimates - Time Series.xlsx")
# note, gdp data is subject to change over time, this particular series is from June 2019

# This data may be useful but due to time limitations on the project it will not be processed at this point
uk_labour_prod_region = read_xls("raw_data/additional_data/UK Labour Productivity - Jobs in Regions by Industry.xls")
uk_labour_prod_rural_urban = read_xls("raw_data/additional_data/UK Labour productivity - Rural and urban areas.xls")


# clean the data


## FACTORS

# education data
uk_education_prod_clean <- uk_education_prod %>%
  rename("education_measure" = "...1") %>%
  pivot_longer(cols = -education_measure, 
               values_to = "education_prod_value", 
               names_to = "time") %>%
  filter(time != "Average annual percentage change")

uk_education_exp_percent_clean <- uk_education_exp %>%
  rename("education_level" = "...1") %>%
  pivot_longer(cols = -education_level,
               values_to = "education_ex_value", 
               names_to = "time")


# historic productivity
uk_historic_prod_output_clean <- uk_historic_prod[-c(1,2, 3,4,5, 6),  c(2, 4, 6, 8, 10)  ]  %>%
  rename(c("time" = "...2", 
           "whole_economy_per_job_(historic prod)"  = "...4", 
           "production_per_job_(historic prod)" = "Production",
           "manufacturing_per_job_(historic prod)" = "Manufacturing", 
           "services_per_job_(historic prod)" = "Services")) %>% # select output per job as this data is more complete than the other metrics
  subset(nchar(as.character(time)) == 4)

# industry productivity
uk_labour_prod_industry_clean <- uk_labour_prod_industry %>%
  separate("Description:", 
           into = c("time", "quarter"),
           sep = " ") # split year and quarter apart

uk_labour_prod_industry_clean <- uk_labour_prod_industry_clean %>%
  group_by(time) %>%
  summarise_at(vars(c(2:68)), funs(mean(., na.rm=TRUE)))
# take the average across four quarters for each year

# uk sickness records
uk_sickness_records_clean <- uk_sickness_records %>%
  rename("reason_given" = "...1") %>%
  mutate_at(vars(-("reason_given")), as.numeric) %>%
  pivot_longer(cols = -reason_given, 
               names_to = "time", 
               values_to = "abscences_millions") %>%
  filter(!is.na(reason_given))


# uk agricultural data
uk_arg_prod_clean <- uk_arg_prod %>%
  rename("arg_measure" = "...1") %>%
  pivot_longer(cols = -arg_measure, 
               values_to = "arg_prod_value", 
               names_to = "time")

uk_arg_breakdown_clean <- uk_arg_breakdown  %>%
  rename("measure" = "...1") %>%
  pivot_longer(cols = -measure,
               values_to = "arg_prod_specific_value",
               names_to = "time") %>%
  mutate(measure = case_when(
    measure == "Productivity by \nintermediate consumption"~"Intermediate Consumption", 
    measure == "Productivity by capital consumption" ~ "Capital Consumption", 
    measure == "Productivity by labour" ~ "Labour Productivity", 
    TRUE ~"Land Productivity"
  ))


# R and D expenditure
uk_berd_exp_clean <- uk_berd_exp %>%
  remove_empty() %>%
  select(-c("...1", "...3", "...5", "...15")) %>%
  filter(...2 %in% c("Constant prices (2017)", "As a % of GDP")) %>%
  rename("r_d_exp_measure" = ...2) %>%
  mutate_at(vars(-("r_d_exp_measure")), as.numeric) %>% 
  pivot_longer(cols = -r_d_exp_measure,
               names_to = "time", 
               values_to = "r_d_exp_value")

uk_berd_exp_sources_clean <- uk_berd_exp_sources %>%
  remove_empty() %>%
  select(-...16) %>%
  filter(...2 %in% c("UK Government",
                     "Overseas total", 
                     "Other UK Business", 
                     "Own funds",
                     "Other 1")) %>%
  mutate_at(vars(-(...2)), as.numeric) %>%
  rename("r_d_exp_source" = ...2) %>%
  pivot_longer(cols = -r_d_exp_source,
               names_to = "time", values_to =
                 "r_d_exp_source_percent")


uk_infra_invest_clean <- uk_infra_invest %>%
  filter(...1 == "Total") %>%
  rename("total_infrastructure_investment" = ...1) %>%
  pivot_longer(cols = -total_infrastructure_investment,
               names_to = "time",
               values_to = "infra_invest_billions")

# data has not been adjusted in this data-set therefore it may not be suitable for analysis

# uk intangible assests
uk_intangible_assests_clean <- uk_intangible_assests %>%
  rename("asset_category" = ...1) %>%
  head(-7) %>%
  tail(-1) %>%
  mutate_at(vars(-(asset_category)), as.numeric) %>%
  pivot_longer(cols = -asset_category,
               names_to = "time",
               values_to = "asset_value_billions") %>%
  filter(!is.na(as.numeric(time))) # remove percentage row entries

# uk public productivity
uk_labour_prod_public_clean <- uk_labour_prod_public[-1, c(1,4)] %>%
  rename("time" = "...1", "public_productivity" = "Productivity...4") %>%
  mutate(public_productivity = as.numeric(public_productivity),
         time = as.character(time))


## OUTPUTS

# uk productivity and regional productivity
uk_labour_productivity_clean <- labour_productivity %>%
  tail(-6) %>% # remove useless information from the top
  mutate(Title = as.numeric(Title)) %>% # removing quarterly data
  filter(!is.na(Title)) %>%
  select(c("Title", grep("^UK|GVA per hour worked", 
                          names(labour_productivity)))) %>% # subset to only the columns we are interested in
  pivot_longer(cols = -Title, names_to = "uk_productivity_measure", values_to = "uk_productivity_value") %>%
  rename("time" = "Title") 

# uk_gdp_estimates

# define a function that will remove a column if all the rows entries in that column are NA
uk_yearly_gdp_clean <- uk_yearly_gdp %>%
  mutate(Title = as.numeric(Title)) %>% # removing quarterly data
  filter(!is.na(Title)) %>%
  select(c("Title", grep("^Gross Domestic Product", 
                         names(uk_yearly_gdp)))) %>%
  rename("time" = "Title")
# join data into a single data-frame

uk_prod_factors_data <- uk_education_prod_clean %>%
  full_join(uk_education_exp_percent_clean, by = "time") %>%
  full_join(uk_historic_prod_output_clean, by = "time") %>%
  full_join(uk_sickness_records_clean, by = "time") %>%
  full_join(uk_arg_prod_clean, by = "time") %>%
  full_join(uk_berd_exp_clean, by = "time") %>%
  full_join(uk_berd_exp_sources_clean, by = "time") %>%
  full_join(uk_intangible_assests_clean, by = "time") %>%
  full_join(uk_labour_prod_public_clean, by = "time") 

# sort rows by least number of NAs, this makes it easier to read the data in
uk_prod_factors_data  <- uk_prod_factors_data  %>% 
  arrange(rowSums(is.na(.)))

# export to csv

write_csv(uk_prod_factors_data, "clean_data/uk_productivity_factors.csv")

write_csv(uk_labour_productivity_clean, "clean_data/uk_regional_productivity.csv")

write_csv(uk_yearly_gdp_clean, "clean_data/uk_yearly_gdp.csv")
