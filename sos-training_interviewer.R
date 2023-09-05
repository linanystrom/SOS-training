################################################################################

# Interviewer's Experiences

################################################################################
# Basic set up -----------------------------------------------------------------

packages <- c("gtools", "readr", "tibble", "dplyr", "data.table", "tidyr",
              "readxl", "ggplot2", "lme4", "lmerTest")

lapply(packages, library, character.only = TRUE)

interviewer_df <- read_csv() # Replace with real data

interviewer_df$sos_training <- factor(interviewer_df$sos_training,
                               levels = c(0, 1),
                               labels = c("Basic","SoS"))

# Demographics -----------------------------------------------------------------

## Age

interviewer_age_table <- interviewer_df %>% 
  summarise(
    Age_M = mean(interviewer_age, na.rm = TRUE),
    Age_sd = sd(interviewer_age, na.rm = TRUE),
    Age_Mdn = median(interviewer_age, na.rm = TRUE)
  ) 

## Gender

### 1 = Male, 2 = Female, 3 = Non-Binary, 4 = Prefer not to say 

interviewer_gender_table <- interviewer_df %>% 
  group_by(interviewer_gender) %>% 
  summarise(
    n = n()
  )

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
                     + (1|id) #interviewer
                     + (1|mc_seq)
                     + (1|interviewee),
                     data = interviewer_df,
                     REML = FALSE)

summary(planning_simple_model)


## Interaction effects

planning_interaction_model <- lmer(planning_int
                          ~ sos_training
                          + interview
                          + sos_training*interview
                          + (1|id) #interviewer
                          + (1|mc_seq)
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
                              + interview
                              + (1|id) #interviewer
                              + (1|mc_seq:interviewee), #interviewee nested in MC
                              data = interviewer_df,
                              REML = FALSE)

summary(conducting_simple_model)


## Interaction effects

conducting_interaction_model <- lmer(conducting_int
                                   ~ sos_training
                                   + interview
                                   + sos_training*interview
                                   + (1|id) #interviewer
                                   + (1|mc_seq:interviewee), #interviewee nested in MC
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
                                + interview
                                + (1|id) #interviewer
                                + (1|mc_seq:interviewee), #interviewee nested in MC
                                data = interviewer_df,
                                REML = FALSE)

summary(new_info_interviewer_simple_model)


## Interaction effects

new_info_interviewer_interaction_model <- lmer(new_info_interviewer
                                     ~ sos_training
                                     + interview
                                     + sos_training*interview
                                     + (1|id) #interviewer
                                     + (1|mc_seq:interviewee), #interviewee nested in MC
                                     data = interviewer_df,
                                     REML = FALSE)

summary(new_info_interviewer_interaction_model)

## Compare model fit

anova(new_info_interviewer_simple_model, new_info_interviewer_interaction_model, refit=FALSE)