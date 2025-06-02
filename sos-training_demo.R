################################################################################

# Demographics

################################################################################

# Interviewers -----------------------------------------------------------------

## Wrangling -------------------------------------------------------------------

TrainingStudy_postq <- read_csv("data/Qualtrics/TrainingStudy_postq.csv") %>%
  slice(-1, -2)

TrainingStudy_postq <- (type_convert(TrainingStudy_postq))

TrainingStudy_postq <- TrainingStudy_postq %>% mutate(
  interview = ifelse(ResponseId == "R_1OoWgOnV4cVLJYl",
                     2,
                     interview),
  interviewer_age = ifelse(ResponseId == "R_1OoWgOnV4cVLJYl",
                           NA, interviewer_age),
  interviewer_gender = ifelse(ResponseId == "R_1OoWgOnV4cVLJYl",
                              NA, interviewer_gender)
  )# Correcting input error from participant #26


# Interviewer tables ------------------------------------------------------------

## Age 

interviewer_age_table <- TrainingStudy_postq %>% 
  summarise(
    Age_M = mean(interviewer_age, na.rm = TRUE),
    Age_SD = sd(interviewer_age, na.rm = TRUE),
    Age_Mdn = median(interviewer_age, na.rm = TRUE),
    Age_Min = min(interviewer_age, na.rm = TRUE),
    Age_Max = max(interviewer_age, na.rm = TRUE)
  ) 


## Gender

interviewer_gender_table <- TrainingStudy_postq %>%
  filter(interview == 1) %>% 
  group_by(interviewer_gender) %>% 
  summarise(
    n = n()) %>%
  mutate(rel_freq = paste0(round(100 * n/sum(n), 0), "%"))


## Condition

my_df <- read_csv("data/excell_long.csv")


interviewer_condition_table <- my_df %>%
  filter(interview == 0, activity == 0) %>% 
  group_by(condition) %>% 
  summarise(
    n = n()) %>%
  mutate(rel_freq = paste0(round(100 * n/sum(n), 0), "%"))


# Interviewees -----------------------------------------------------------------

## Wrangling -------------------------------------------------------------------

interviewee_df <- read_csv("data/qualtrics_clean.csv") 

# Clean data from suspects not providing data

interviewee_6 <- subset(interviewee_df,id == 6 & interview <= 2)

interviewee_4 <- subset(interviewee_df,id == 4 & interview == 6)

interviewee_8 <- subset(interviewee_df,id == 8 & interview >= 5)

rest_interviewer <- interviewee_df %>% filter(interview <= 4)

rest_interviewer <- rest_interviewer %>% filter(id != 6)

clean_interviewee <- do.call("rbind", list(rest_interviewer,
                                           interviewee_6,
                                           interviewee_4,
                                           interviewee_8
                                           ))

# Interviewee tables -----------------------------------------------------------
  
## Age 

interviewee_age_table <- clean_interviewee %>% 
  summarise(
    Age_M = mean(age, na.rm = TRUE),
    Age_SD = sd(age, na.rm = TRUE),
    Age_Mdn = median(age, na.rm = TRUE),
    Age_min = min(age, na.rm = TRUE),
    Age_max = max(age, na.rm = TRUE)
  ) 


## Gender 

### 1 = Male, 2 = Female, 3 = Non-Binary, 4 = Prefer not to say 

interviewee_gender_table <- clean_interviewee %>% 
  group_by(gender) %>% 
  summarise(
    n = n()) %>%
  mutate(rel_freq = paste0(round(100 * n/sum(n), 0), "%"))


# Condition Interviewers

interviewee_condition_table <- interviewee_df %>% 
  group_by(condition) %>% 
  summarise(
    n = n()) %>%
  mutate(rel_freq = paste0(round(100 * n/sum(n), 0), "%"))

