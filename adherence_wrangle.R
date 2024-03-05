################################################################################

# Adherence wrangling 

################################################################################

packages <- c("readr", "dplyr", "readxl", "tidyr", "haven")

lapply(packages, library, character.only = TRUE)

# Load data --------------------------------------------------------------------

excell_raw <- read_excel("data/coding_solved.xlsx") # Replace with real data

condition_info <- excell_raw %>% 
  select(c("ID","condition", "int1_st1", "int1_st2", "int1_st3", "int1_st4", "int1_st5", "int1_st6",
           "int2_st1", "int2_st2", "int2_st2", "int2_st3", "int2_st4", "int2_st5", "int2_st6",
           "int3_st1", "int3_st2", "int3_st3", "int3_st4", "int3_st5", "int3_st6",
           "int4_st1", "int4_st2", "int4_st3", "int4_st4", "int4_st5", "int4_st6"))

ana_data <- read_sav("data/SoSCodingFramework.sav")

ana_data <- merge(ana_data, condition_info, by = "ID")

ana_data <- ana_data %>% 
  mutate(sos_training = if_else(condition == "SoS-Delay", case_when(
    Interview_nr == 1 ~ 0,
    Interview_nr == 2 ~ 0,
    Interview_nr == 3 ~ 1,
    Interview_nr == 4 ~ 1
  ),
  ifelse(condition == "Basic", case_when(
    Interview_nr == 1 ~ 0,
    Interview_nr == 2 ~ 0,
    Interview_nr == 3 ~ 0,
    Interview_nr == 4 ~ 0
  ),
  ifelse(condition == "SoS", case_when(
    Interview_nr == 1 ~ 1,
    Interview_nr == 2 ~ 1,
    Interview_nr == 3 ~ 1,
    Interview_nr == 4 ~ 1
  ), NA))))

ana_data <- ana_data %>% 
  mutate(int_sum = case_when(
    Interview_nr == 1 ~ (int1_st1+int1_st2+int1_st3+int1_st4+int1_st5+int1_st6),
    Interview_nr == 2 ~ (int2_st1+int2_st2+int2_st3+int2_st4+int2_st5+int2_st6),
    Interview_nr == 3 ~ (int3_st1+int3_st2+int3_st3+int3_st4+int3_st5+int3_st6),
    Interview_nr == 4 ~ (int4_st1+int4_st2+int4_st3+int4_st4+int4_st5+int4_st6)),
    crit_sum = case_when(
      Interview_nr == 1 ~ (int1_st5+int1_st6),
      Interview_nr == 2 ~ (int2_st5+int2_st6),
      Interview_nr == 3 ~ (int3_st5+int3_st6),
      Interview_nr == 4 ~ (int4_st5+int4_st6)
    ))

ana_data <- ana_data %>% 
  mutate(Specific_questions_R = case_when(
    Specific_questions == 0 ~ 4,
    Specific_questions == 1 ~ 3,
    Specific_questions == 2 ~ 2,
    Specific_questions == 3 ~ 1,
    Specific_questions == 4 ~ 0), NA)

ana_data <- ana_data %>% 
  mutate(adherence  = (Introduction+
                         Approach+
                         Structure+
                         Challenge_inconsistencies+
                         Request_explanation+
                         Reinforce_truth+
                         Change_topic+
                         Specific_questions_R))

ana_data <- ana_data %>% 
  select(c("ID","condition", "Interview_nr", "sos_training", "adherence", "int_sum", "crit_sum", everything()))

ana_data <- ana_data %>% 
  select(-c("Group","int1_st1", "int1_st2", "int1_st3", "int1_st4", "int1_st5", "int1_st6",
            "int2_st1", "int2_st2", "int2_st2", "int2_st3", "int2_st4", "int2_st5", "int2_st6",
            "int3_st1", "int3_st2", "int3_st3", "int3_st4", "int3_st5", "int3_st6",
            "int4_st1", "int4_st2", "int4_st3", "int4_st4", "int4_st5", "int4_st6", "Information_elicited"))


write.csv(
  ana_data,
  "./SoSCodingFramework.csv",
  row.names = FALSE
)