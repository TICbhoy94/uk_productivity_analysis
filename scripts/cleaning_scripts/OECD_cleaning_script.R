# script to take data from the OECD website and combine it into one data-frame 

# load libriaries
library(tidyverse)
library(readxl)
library(janitor)
library(countrycode)
library(naniar)

# read in the data
OECD_broadband_stats = read_xls(
  "raw_data/additional_data/Broadband and mobile statistics - OECD.xls",
  skip = 2, 
  n_max = 37)

OECD_export_business_size  = read_xlsx(
  "raw_data/additional_data/Exports by business size - OECD.xlsx")

OECD_labour_productivity = read_csv(
  "raw_data/additional_data/Labour Productivity - OECD Countries.csv")

OECD_multifactor_productivity = read_xls(
  "raw_data/additional_data/Multifactor Productivity - OECD Countries.xls")

OECD_adult_education = read_xlsx(
  "raw_data/additional_data/OECD Adult Education Levels.xlsx")

OECD_average_wages = read_xlsx(
  "raw_data/additional_data/OECD Average Wages.xlsx")

OECD_human_capital_quality = read_xlsx(
  "raw_data/additional_data/OECD Quality of human capital.xlsx", 
  skip = 5)

OECD_tertiary_education_exp = read_xlsx(
  "raw_data/additional_data/OECD Tertiary Education Expenditure.xlsx", sheet = 1)

OECD_real_min_wages = read_xlsx(
  "raw_data/additional_data/Real minimum wages OECD.xlsx",
  skip = 5)

OECD_in_goods_services = read_xlsx(
  "raw_data/additional_data/Trade in good and services - OECD.xlsx")

OECD_trade_union_density = read_xlsx(
  "raw_data/additional_data/Trade union density - OECD.xlsx",
  skip = 5, 
  n_max = 55)


# clean each data set:

OECD_broadband_stats_clean <- OECD_broadband_stats %>%
  rename("location" = "...1") %>%
  mutate_at(vars(-("location")), as.numeric) %>%
  clean_names()

OECD_broadband_stats_clean <- OECD_broadband_stats_clean %>%
  mutate("2003" = q4_2003, # change bi-annual values to a single value from the end of the year
         "2004" = q4_2004,
         "2005" = q4_2005,
         "2006" = q4_2006,
         "2007" = q4_2007,
         "2008" = q4_2008,
         "2009" = x2009_q4,
         "2010" = x2010_q4,
         "2011" = x2011_q4,
         "2012" = x2012_q4,
         "2013" = x2013_q4,
         "2014" = x2014_q4,
         "2015" = x2015_q4,
         "2016" = x2016_q4,
         "2017" = x2017_q4) %>% 
  mutate(location = countrycode(location, # change full country names to their abbreviated versions
                                origin = 'country.name', 
                                destination  = 'iso3c')) %>%
  select(c("location", "2003", "2004","2005","2006","2007","2008","2009","2010","2011","2012","2013","2014","2015","2016","2017")) %>%
  pivot_longer(cols = c("2003", "2004","2005","2006","2007","2008","2009","2010","2011","2012","2013","2014","2015","2016","2017"),
               names_to = "time",  
               names_transform = list(time = as.numeric), 
               values_to = "broadband_value") 


OECD_export_business_size_clean <- OECD_export_business_size %>%
  clean_names() %>%
  select(c("location", "subject", "time", "value"))   %>%
  rename("export_by_business_size_value" = "value", 
         "export_business_size_subject" = "subject")


OECD_labour_productivity_clean <- OECD_labour_productivity %>%
  clean_names() %>%
  select(c("location","measure", "time", "value")) %>%
  rename("labour_productivity_value" = "value", 
         "labour_productivity_measure" = "measure") 


OECD_multifactor_productivity_clean <- OECD_multifactor_productivity %>%
  clean_names() %>%
  select(c("location", "measure", "time", "value")) %>%
  rename("multifactor_productivity_value" = "value", 
         "multifactor_productivity_measure" = "measure") 


OECD_adult_education_clean <- OECD_adult_education %>%
  clean_names() %>%
  select(c("location", "time", "value")) %>%
  rename("adult_education_level_value" = "value")


OECD_average_wages_clean <- OECD_average_wages %>%
  clean_names() %>%
  select(c("location", "time", "value")) %>%
  rename("average_wages_value" = "value")


OECD_human_capital_quality_clean <- OECD_human_capital_quality %>%
  select(-"...2") %>%
  rename("location" = "Year") %>%
  filter(location != c("Country", "Data extracted on 04 Feb 2019 11:20 UTC (GMT) from OECD.Stat")) %>%
  mutate_at(vars(-("location")), as.numeric) %>%
  pivot_longer(cols = -c("location"), 
               names_to = "time", 
               names_transform = list(time = as.numeric), 
               values_to = "hc_quality_value") %>%
  mutate(location = countrycode(location, # change full country names to their abbreviated versions
                                origin = 'country.name', 
                                destination  = 'iso3c'))


OECD_tertiary_education_exp_clean <- OECD_tertiary_education_exp %>%
  clean_names() %>%
  select(c("location", "subject", "time", "value")) %>%
  rename("tertiary_education_exp_value" = "value", 
         "tertiary_education_subject" = "subject")

OECD_real_min_wages_clean <- OECD_real_min_wages %>%
  select(-"...2") %>%
  rename("location" = "Time") %>%
  filter(location != c("Country", 
                       "Data extracted on 01 Feb 2019 14:38 UTC (GMT) from OECD.Stat")) %>%
  mutate_at(vars(-("location")), as.numeric) %>%
  pivot_longer(cols = -c("location"), 
               names_to = "time",
               names_transform = list(time = as.numeric), 
               values_to = "min_wages_value") %>%
  mutate(location = countrycode(location, # change full country names to their abbreviated versions
                                origin = 'country.name',
                                destination  = 'iso3c')) 

OECD_in_goods_services_clean <- OECD_in_goods_services %>%
  clean_names() %>%
  select(c("location", "measure", "subject", "time", "value")) %>%
  rename("in_goods_services_value" = "value", 
         "in_goods_services_measure" = "measure",
         "in_goods_services_subject" = "subject")



#its difficult to say from this data if the countries are in order, so when it says NA after Sweden for example, it is still referring to Sweden but as a different source of data for the union density. I am assuming that is true:
OECD_trade_union_density$Year <- zoo::na.locf(OECD_trade_union_density$Year, fromLast = FALSE) # replace NA values in location with the country above

OECD_trade_union_density_clean <- OECD_trade_union_density %>%
  select(-c("...2", "...3")) %>%
  rename("location" = "Year") %>%
  replace_with_na_at(.vars = vars(-("location")), ~.  == "..") %>% # replace ".." with NA
  group_by(location) %>%
  mutate_at(vars(-("location")), as.numeric) %>%
  summarise_each(funs(mean(., na.rm = TRUE))) %>% # if there are more than 2 sources of data, take the mean values
  pivot_longer(cols = -c("location"), 
               names_to = "time",
               names_transform = list(time = as.numeric),
               values_to = "trade_union_density (%)") %>%
  clean_names() %>%
  filter(location !="Country") %>%
  mutate(location = countrycode(location, # change full country names to their abbreviated versions
                                origin = 'country.name', 
                                destination  = 'iso3c'))


# join the data

OECD_data <- OECD_adult_education_clean %>%
  full_join(OECD_average_wages_clean, by = c("location", "time")) %>%
  full_join(OECD_broadband_stats_clean, by = c("location", "time")) %>%
  full_join(OECD_export_business_size_clean, by = c("location", "time")) %>%
  full_join(OECD_human_capital_quality_clean, by = c("location", "time")) %>%
  full_join(OECD_labour_productivity_clean, by = c("location", "time")) %>%
  full_join(OECD_multifactor_productivity_clean, by = c("location", "time")) %>%
  full_join(OECD_real_min_wages_clean, by = c("location", "time")) %>%
  full_join(OECD_tertiary_education_exp_clean, by = c("location", "time")) %>%
  full_join(OECD_trade_union_density_clean, by = c("location", "time")) %>%
  full_join(OECD_in_goods_services_clean, by = c("location", "time"))

# filter by our top 23 countries
top_23 <- c("Australia", "Austria", "Belgium", "Canada", "Denmark", "Finland", "France", "Germany", "Greece", "Iceland", "Ireland", "Italy", "Japan", "Luxembourg", "Netherlands", "New Zealand", "Norway", "Portugal", "Spain", "Sweden", "Switzerland", "United Kingdom","United States")

top_23 <- countrycode(top_23, # change full country names to their abbreviated versions
                      origin = 'country.name', 
                      destination  = 'iso3c')

OECD_data <- OECD_data %>% 
  filter(location %in% top_23) %>%
  arrange(rowSums(is.na(.))) # sort rows by least number of NAs, this makes it easier to read the data in


# export results to CSV
write_csv(OECD_data, "clean_data/OECD_data.csv")
