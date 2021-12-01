############################

# This is just me modifying the original data to make it 
# more suitable for this exercise

############################


# Libraries needed --------------------------------------------------------

library(tidyverse)
library(janitor)
library(here)

# Functions needed --------------------------------------------------------


source(here("functions", "theme_pepe.R"))


# Data handling -----------------------------------------------------------


dat <- read_csv(here("data_from_site", "Macrocystis_pyrifera_net_primary_production_and_growth_with_SE_20191204.csv"))

dat %>% 
  clean_names() %>% 
  group_by(year) %>% 
  nest() %>%
  pwalk(~write_csv(x = .y, path = str_c(here("data"), "/Kelp_NPP_", .x, ".csv") ) )

