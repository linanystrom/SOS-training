################################################################################

# Interviewer's Experiences

################################################################################

# Basic set up -----------------------------------------------------------------

packages <- c("gtools", "readr", "tibble", "dplyr", "data.table", "tidyr",
              "readxl", "ggplot2", "lme4", "lmerTest")

lapply(packages, library, character.only = TRUE)

# Wrangling --------------------------------------------------------------------

interviewer_df <- read_csv("data/Qualtrics/TrainingStudy_postq.csv") %>%
  slice(-1, -2)


interviewer_df <- (type_convert(interviewer_df))


## Correcting input error from participant #26

interviewer_df <- interviewer_df %>%
  mutate(
  interview = ifelse(ResponseId == "R_1OoWgOnV4cVLJYl",
                     2,
                     interview),
  interviewer_age = ifelse(ResponseId == "R_1OoWgOnV4cVLJYl",
                           NA,
                           interviewer_age),
  interviewer_gender = ifelse(ResponseId == "R_1OoWgOnV4cVLJYl",
                              NA,
                              interviewer_gender)
)


interviewer_df <- interviewer_df %>%
  group_by(interviewer) %>% 
  fill(training, .direction = "downup") %>%
  ungroup


interviewer_df<- interviewer_df %>%
  mutate(interview = recode(interview,
                              '1'='0',
                              '2'='1',
                              '3'='2',
                              '4'='3',
                              '5'='4',
                              '6'='5'))


interviewer_df <- interviewer_df %>% 
  mutate(
    interviewee = paste(as.character(interviewer),
                        as.character(interview), sep = "_"))


my_df <- read_csv("data/excell_long.csv") 


merge_data <- my_df  %>% 
  select(c("interviewee", "sos_training")) 


merge_data <- unique(merge_data)


merge_data <- na.omit(merge_data)


interviewer_df <- merge(interviewer_df, merge_data,
                        by = c("interviewee"))


interviewer_df <- interviewer_df %>% 
  mutate(
    planning_int = case_when(
      planning_int == 1 ~ 1,
      planning_int == 2 ~ 2,
      planning_int == 3 ~ 3,
      planning_int == 4 ~ 4,
      planning_int == 5 ~ 5,
      planning_int == 6 ~ 6,
      planning_int == "Extremely well" ~ 7))


interviewer_df <- interviewer_df %>% 
  mutate(
    conducting_int = case_when(
      conducting_int == 1 ~ 1,
      conducting_int == 2 ~ 2,
      conducting_int == 3 ~ 3,
      conducting_int == 4 ~ 4,
      conducting_int == 5 ~ 5,
      conducting_int == 6 ~ 6,
      conducting_int == "Extremely well" ~ 7))


interviewer_df <- interviewer_df %>% 
  mutate(
    new_info_interviewer = case_when(
      new_info_interviewer == "Nothing at all" ~ 1,
      new_info_interviewer == 2 ~ 2,
      new_info_interviewer == 3 ~ 3,
      new_info_interviewer == 4 ~ 4,
      new_info_interviewer == 5 ~ 5,
      new_info_interviewer == 6 ~ 6,
      new_info_interviewer == "A substantial amount" ~ 7))
      

# Self assessment of Planning --------------------------------------------------


planning_desc <- interviewer_df %>% 
  group_by(sos_training) %>% 
  summarise(
    Mean = mean(planning_int, na.rm = TRUE),
    SD = sd(planning_int, na.rm = TRUE),
    Median = median(planning_int, na.rm = TRUE),
    SE = SD/sqrt(n()),
    Upper = Mean + (1.96*SE),
    Lower = Mean - (1.96*SE)
  )


## Main effects

planning_simple_model <- lmer(planning_int
                     ~ sos_training 
                     + interview
                     + (1|interviewer), #interviewer
                     + (1|mc)
                     + (1|interviewee),
                     data = interviewer_df,
                     REML = FALSE)

summary(planning_simple_model)


## Interaction effects

planning_interaction_model <- lmer(planning_int
                          ~ sos_training
                          + interview
                          + sos_training*interview
                          + (1|interviewer) #interviewer
                          + (1|mc)
                          + (1|interviewee),
                          data = interviewer_df,
                          REML = FALSE)

summary(planning_interaction_model)


## Compare model fit

anova(planning_simple_model, planning_interaction_model, refit=FALSE) 


# Self-assessment of Performance -----------------------------------------------

conducting_desc <- interviewer_df %>% 
  group_by(sos_training) %>% 
  summarise(
    Mean = mean(conducting_int, na.rm = TRUE),
    SD = sd(conducting_int, na.rm = TRUE),
    Median = median(conducting_int, na.rm = TRUE),
    SE = SD/sqrt(n()),
    Upper = Mean + (1.96*SE),
    Lower = Mean - (1.96*SE)
  )


## Main effects

conducting_simple_model <- lmer(conducting_int
                              ~ sos_training 
                              + as.numeric(interview)
                              + (1|interviewer), #interviewer
                              data = interviewer_df,
                              REML = FALSE)

summary(conducting_simple_model)


## Interaction effects

conducting_interaction_model <- lmer(conducting_int
                                   ~ sos_training
                                   + as.numeric(interview)
                                   + sos_training*as.numeric(interview)
                                   + (1|interviewer), #interviewer
                                   data = interviewer_df,
                                   REML = FALSE)

summary(conducting_interaction_model)


## Compare model fit

anova(conducting_simple_model, conducting_interaction_model, refit=FALSE) 


# Self-assessment of new information yield -------------------------------------

new_info_interviewer_desc <- interviewer_df %>% 
  group_by(sos_training) %>% 
  summarise(
    Mean = mean(new_info_interviewer, na.rm = TRUE),
    SD = sd(new_info_interviewer, na.rm = TRUE),
    Median = median(new_info_interviewer, na.rm = TRUE),
    SE = SD/sqrt(n()),
    Upper = Mean + (1.96*SE),
    Lower = Mean - (1.96*SE)
  )


## Main effects

new_info_interviewer_simple_model <- lmer(new_info_interviewer
                                ~ sos_training 
                                + as.numeric(interview)
                                + (1|interviewer), #interviewer
                                data = interviewer_df,
                                REML = FALSE)

summary(new_info_interviewer_simple_model)


## Interaction effects

new_info_interviewer_interaction_model <- lmer(new_info_interviewer
                                     ~ sos_training
                                     + as.numeric(interview)
                                     + sos_training*as.numeric(interview)
                                     + (1|interviewer), #interviewer
                                     data = interviewer_df,
                                     REML = FALSE)

summary(new_info_interviewer_interaction_model)


## Compare model fit

anova(new_info_interviewer_simple_model, new_info_interviewer_interaction_model, refit=FALSE)
