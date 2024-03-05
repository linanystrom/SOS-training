################################################################################

# Adherence analysis

################################################################################

packages <- c("gtools", "readr", "tibble", "dplyr", "data.table", "tidyr",
              "readxl", "ggplot2", "lme4", "lmerTest")

lapply(packages, library, character.only = TRUE)

ana_df  <- read_csv("./SoSCodingFramework.csv")

# ------------------------------------------------------------------------------

adherence_desc <- ana_df %>% 
  group_by(sos_training) %>% 
  summarise(
    Mean = mean(adherence, na.rm = TRUE),
    SD = sd(adherence, na.rm = TRUE),
    Median = median(adherence, na.rm = TRUE),
    SE = SD/sqrt(n()),
    Upper = Mean + (1.96*SE),
    Lower = Mean - (1.96*SE)
  )

## Main effects

adherence_model <- lmer(adherence
                     ~ sos_training
                     + (1|ID),
                     data=ana_df,
                     REML=FALSE)

summary(adherence_model)

## Overall yield

yield_model <- lmer(int_sum
                        ~ adherence
                        + (1|ID),
                        data=ana_df,
                        REML=FALSE)

summary(yield_model)

## Critical information

crit_model <- lmer(crit_sum
                    ~ adherence
                    + (1|ID),
                    data=ana_df,
                    REML=FALSE)

summary(crit_model)
