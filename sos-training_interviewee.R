################################################################################

# Interviewee's Experiences

################################################################################

# Basic set up -----------------------------------------------------------------

packages <- c("gtools", "readr", "tibble", "dplyr", "data.table", "tidyr",
              "readxl", "ggplot2", "lme4", "lmerTest")

lapply(packages, library, character.only = TRUE)

interviewee_df <- read_csv("data/qualtrics_clean.csv") 

interviewee_df$sos_training <- factor(interviewee_df$sos_training,
                                      levels = c(0, 1),
                                      labels = c("Basic","SoS")
                                      )

# Pre-interview questionnaire --------------------------------------------------

## Confidence

condidence_desc <- interviewee_df %>% 
  group_by(sos_training) %>% 
  summarise(
    Mean = mean(confidence, na.rm = TRUE),
    SD = sd(confidence, na.rm = TRUE),
    Median = median(confidence, na.rm = TRUE),
    SE = SD/sqrt(n()),
    Upper = Mean + (1.96*SE),
    Lower = Mean - (1.96*SE)
  )

confidence_test <- t.test(
  confidence ~ sos_training,
  data = interviewee_df
)

## Motivation

motivation_desc <- interviewee_df %>% 
  group_by(sos_training) %>% 
  summarise(
    Mean = mean(motivation, na.rm = TRUE),
    SD = sd(motivation, na.rm = TRUE),
    Median = median(motivation, na.rm = TRUE),
    SE = SD/sqrt(n()),
    Upper = Mean + (1.96*SE),
    Lower = Mean - (1.96*SE)
  )

motivation_test <- t.test(
  motivation ~ sos_training,
  data = interviewee_df
)

# Post-interview questionnaire -------------------------------------------------

## Self-assessment of performance

performance_desc <- interviewee_df %>%
  group_by(sos_training) %>%
  summarise(
    Mean = mean(self_assessment, na.rm = TRUE),
    SD = sd(self_assessment, na.rm = TRUE),
    Median = median(self_assessment, na.rm = TRUE)
  )

### Main effects

performance_simple_model <- lmer(self_assessment
                                 ~ sos_training
                              + interview
                              + (1|id) #interviewer
                              + (1|mc),
                              data = interviewee_df,
                              REML = FALSE)

summary(performance_simple_model)

### Interaction effects

performance_int_model <- lmer(self_assessment
                                 ~ sos_training
                                 + interview
                                 + sos_training*interview
                                 + (1|id) #interviewer
                                 + (1|mc),
                                 data = interviewee_df,
                                 REML = FALSE)

summary(performance_int_model)

## Compare model fit

anova(performance_simple_model, performance_int_model, refit=FALSE) 

## Perception of interviewer's existing knowledge

knowledge_desc <- interviewee_df %>%
  group_by(sos_training) %>%
  summarise(
    Mean = mean(knowledge_before, na.rm = TRUE),
    SD = sd(knowledge_before, na.rm = TRUE),
    Median = median(knowledge_before, na.rm = TRUE)
  )


### Main effects

knowledge_simple_model <- lmer(knowledge_before
                                 ~ sos_training
                                 +  interview
                                 + (1|id) #interviewer
                                 + (1|mc),
                                 data = interviewee_df,
                                 REML = FALSE)

summary(knowledge_simple_model)

### Interaction effects

knowledge_int_model <- lmer(knowledge_before
                              ~ sos_training
                              + interview
                              + sos_training*interview
                              + (1|id) #interviewer
                              + (1|mc),
                              data = interviewee_df,
                              REML = FALSE)

summary(knowledge_int_model)

## Compare model fit

anova(knowledge_simple_model, knowledge_int_model, refit=FALSE) 

## Perception of interviewer's information yield

yield_desc <- interviewee_df %>%
  group_by(sos_training) %>%
  summarise(
    Mean = mean(new_info, na.rm = TRUE),
    SD = sd(new_info, na.rm = TRUE),
    Median = median(new_info, na.rm = TRUE)
  )


### Main effects


yield_simple_model <- lmer(new_info
                               ~ sos_training
                               + interview
                               + (1|id) #interviewer
                               + (1|mc),
                               data = interviewee_df,
                               REML = FALSE)

summary(yield_simple_model)

### Interaction effects

yield_int_model <- lmer(new_info
                            ~ sos_training
                            + interview
                            + sos_training*interview
                            + (1|id) #interviewer
                            + (1|mc),
                            data = interviewee_df,
                            REML = FALSE)

summary(yield_int_model)

### Compare model fit

anova(yield_simple_model, yield_int_model, refit=FALSE) 

## Change of Strategy

change_strat_desc <- interviewee_df %>%
  drop_na (change_strategy) %>% 
  group_by(sos_training, change_strategy) %>%
  summarise(
    n = n()) %>%
  mutate(rel_freq = paste0(round(100 * n/sum(n), 0), "%")
  )

### Main effects

change_strat_main_model <- glmer(as.factor(change_strategy)
                                 ~ sos_training
                                 + interview
                                 + (1|id) #interviewer
                                 + (1|mc),
                                 data = interviewee_df,
                                 family = binomial,
                                 control = glmerControl(optimizer = "bobyqa")
                                )


summary(change_strat_main_model)

### Chi square approach

change_strat <-
  table(interviewee_df$sos_training,
        interviewee_df$change_strategy)


change_strat_chisq <- prop.test(x = change_strat,
                               n = rowSums(change_strat),
                               correct = FALSE)


## Perception of Interview

interview_desc <- interviewee_df %>%
  group_by(sos_training) %>%
  summarise(
    Mean = mean(interview_perc, na.rm = TRUE),
    SD = sd(interview_perc, na.rm = TRUE),
    Median = median(interview_perc, na.rm = TRUE)
  )


### Main effects

interview_simple_model <- lmer(interview_perc
                           ~ sos_training
                           + interview
                           + (1|id) #interviewer
                           + (1|mc),
                           data = interviewee_df,
                           REML = FALSE)

summary(interview_simple_model)

### Interaction effects

interview_int_model <- lmer(interview_perc
                        ~ sos_training
                        + interview
                        + sos_training*interview
                        + (1|id) #interviewer
                        + (1|mc),
                        data = interviewee_df,
                        REML = FALSE)

summary(interview_int_model)

### Compare model fit

anova(interview_simple_model, interview_int_model, refit=FALSE) 

## Perception of Interviewer

interviewer_desc <- interviewee_df %>%
  group_by(sos_training) %>%
  summarise(
    Mean = mean(interviewer_perc, na.rm = TRUE),
    SD = sd(interviewer_perc, na.rm = TRUE),
    Median = median(interviewer_perc, na.rm = TRUE)
  )


### Main effects

interviewer_simple_model <- lmer(interviewer_perc
                               ~ sos_training
                               + interview
                               + (1|id) #interviewer
                               + (1|mc),
                               data = interviewee_df,
                               REML = FALSE)

summary(interviewer_simple_model)

### Interaction effects

interviewer_int_model <- lmer(interviewer_perc
                            ~ sos_training
                            + interview
                            + sos_training*interview
                            + (1|id) #interviewer
                            + (1|mc),
                            data = interviewee_df,
                            REML = FALSE)

summary(interviewer_int_model)

### Compare model fit

anova(interviewer_simple_model, interviewer_int_model, refit=FALSE)

## Engagement with clips

engagement_desc <- interviewee_df %>% 
  group_by(sos_training) %>% 
  summarise(
    Mean = mean(engagement, na.rm = TRUE),
    SD = sd(engagement, na.rm = TRUE),
    Median = median(engagement, na.rm = TRUE),
    SE = SD/sqrt(n()),
    Upper = Mean + (1.96*SE),
    Lower = Mean - (1.96*SE)
  )

engagement_test <- t.test(
  engagement ~ sos_training,
  data = interviewee_df
)
