################################################################################

# Data preparation - Information disclosure

################################################################################

# Begin by running this script

# Basic setup ------------------------------------------------------------------

packages <- c("readr", "dplyr", "readxl", "tidyr")

lapply(packages, library, character.only = TRUE)

# Load data --------------------------------------------------------------------

excell_raw <- read_excel("data/coding_solved.xlsx") 

# ------------------------------------------------------------------------------

excell_raw <- excell_raw %>% 
  rename(
    id  = ID
  )

excell_long <- excell_raw  %>% 
  pivot_longer(
    cols = c("int1_st1",
             "int1_st2",
             "int1_st3",
             "int1_st4",
             "int1_st5",
             "int1_st6",
             "int2_st1",
             "int2_st2",
             "int2_st3",
             "int2_st4",
             "int2_st5",
             "int2_st6",
             "int3_st1",
             "int3_st2",
             "int3_st3",
             "int3_st4",
             "int3_st5",
             "int3_st6",
             "int4_st1",
             "int4_st2",
             "int4_st3",
             "int4_st4",
             "int4_st5",
             "int4_st6",
             "int5_st1",
             "int5_st2",
             "int5_st3",
             "int5_st4",
             "int5_st5",
             "int5_st6",
             "int6_st1",
             "int6_st2",
             "int6_st3",
             "int6_st4",
             "int6_st5",
             "int6_st6"),
    names_to = "stage",
    values_to = "detail")

# Assign interview -------------------------------------------------------------

excell_long <- excell_long %>% 
  mutate(
    interview = case_when(
      startsWith(stage,"int1") ~ 0,
      startsWith(stage,"int2") ~ 1,
      startsWith(stage,"int3") ~ 2,
      startsWith(stage,"int4") ~ 3,
      startsWith(stage,"int5") ~ 4,
      startsWith(stage,"int6") ~ 5
      
    ),
    activity = case_when(
      endsWith(stage, "st1") ~ 0,
      endsWith(stage, "st2") ~ 1,
      endsWith(stage, "st3") ~ 2,
      endsWith(stage, "st4") ~ 3,
      endsWith(stage, "st5") ~ 4,
      endsWith(stage, "st6") ~ 5
      
    ),
    critical = case_when(
      endsWith(stage, "st1") ~ 0,
      endsWith(stage, "st2") ~ 0,
      endsWith(stage, "st3") ~ 0,
      endsWith(stage, "st4") ~ 0,
      endsWith(stage, "st5") ~ 1,
      endsWith(stage, "st6") ~ 1
    ))


excell_long <- excell_long %>% 
  mutate(
    interviewee = paste(as.character(id), as.character(interview), sep = "_"))

excell_long <- excell_long %>% 
  mutate(sos_training = if_else(condition == "SoS-Delay", case_when(
    interview == 0 ~ 0,
    interview == 1 ~ 0,
    interview == 2 ~ 1,
    interview == 3 ~ 1
  ),
  ifelse(condition == "Basic", case_when(
    interview == 0 ~ 0,
    interview == 1 ~ 0,
    interview == 2 ~ 0,
    interview == 3 ~ 0,
    interview == 4 ~ 0,
    interview == 5 ~ 0
  ),
  ifelse(condition == "SoS", case_when(
    interview == 0 ~ 1,
    interview == 1 ~ 1,
    interview == 2 ~ 1,
    interview == 3 ~ 1
    ), NA))))
      

write.csv(
  excell_long,
  "data/excell_long.csv",
  row.names = FALSE
)

      
      