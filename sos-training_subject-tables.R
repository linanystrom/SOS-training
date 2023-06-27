################################################################################

# SoS Training - Create data tables for each interviewer

################################################################################

# Load packages ----------------------------------------------------------------

library(readr)
library(tidyr)
library(dplyr)
library(stringr)

# Load data --------------------------------------------------------------------

assignment <- read_csv("data/random_assignment.csv")

mc_links   <- read_csv("data/mc-links.csv")

# Wrangle ----------------------------------------------------------------------

if (!dir.exists("data/sub-data")) {
  
  dir.create("data/sub-data")
  
}

for (i in 1:length(unique(assignment$ID))) {
  
  df_temp <- assignment[assignment$ID == assignment$ID[i], ]
  
  df_temp <- df_temp %>% 
    extract(
      col   = "sequence",
      into  = paste("interview_", 1:6, sep = ""),
      regex = "(.) (.) (.) (.) (.) (.)"
    )
  
  df_long <- df_temp %>% 
    pivot_longer(
      cols         = starts_with("interview_"),
      names_to     = "interview",
      names_prefix = "interview_",
      values_to    = "mc"
    )
  
  df_long <- df_long %>%
    type_convert() %>% 
    left_join(mc_links, by = "mc") %>% 
    select(
      ID, interview, mc, link
    )
  
  df_long$response_id <- NA
  
  write_csv(df_long, 
            paste("data/sub-data/sos-training_subject-", 
                  str_pad(i, width = 2, pad = "0"),
                  ".csv",
                  sep = ""))
  
}
