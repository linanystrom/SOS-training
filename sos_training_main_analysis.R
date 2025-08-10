################################################################################

# Main analysis

################################################################################
# Basic setup ------------------------------------------------------------------

packages <- c("gtools", "readr", "tibble", "dplyr", "data.table", "tidyr",
              "readxl", "ggplot2", "lme4", "lmerTest")

lapply(packages, library, character.only = TRUE)

my_df <- read_csv("data/excell_long.csv")

# Plots ------------------------------------------------------------------------

## Plot preparation

plot_df <- my_df

test_df<-plot_df[complete.cases(plot_df),]


## Factor training & details (critical, noncritical)

plot_df$sos_training <- factor(plot_df$sos_training,
                                          levels = c(0, 1),
                                          labels = c("Basic","SoS"))

plot_df$critical <- factor(plot_df$critical,
                                      levels = c(0, 1),
                                      labels = c("Non-critical", "Critical"))


## Descriptive statistics - information disclosure

desc <- plot_df[complete.cases(plot_df),] %>% 
  group_by(sos_training, critical) %>% 
  summarise(
    Mean = mean(detail, na.rm = TRUE),
    SD = sd(detail, na.rm = TRUE),
    Median = median(detail, na.rm = TRUE),
    SE = SD/sqrt(n()),
    Upper = Mean + (1.96*SE),
    Lower = Mean - (1.96*SE)
  )


## Descriptive statistics - Also grouping by interview

desc_by_interview <- plot_df[complete.cases(plot_df),] %>% 
  group_by(condition, interview, critical) %>% 
  summarise(
    Mean = mean(detail, na.rm = TRUE),
    SD = sd(detail, na.rm = TRUE),
    Median = median(detail, na.rm = TRUE),
    SE = SD/sqrt(n()),
    Upper = Mean + (1.96*SE),
    Lower = Mean - (1.96*SE)
  )




## Means plot - Information disclosure

mean_plot <- ggplot(desc, aes(x = critical,
                              y = Mean,
                              colour = sos_training)
                              ) + 
                          geom_errorbar(aes(
                              ymin = Lower,
                              ymax = Upper),
                              width = .1
                              ) +
                          geom_point(
                              size = 2
                              ) +
                          labs(
                              y = "Disclosed details",
                              x = "Detail type",
                              color = "Training"
                              ) +
                          scale_color_manual(values = c(
                              "#607466",
                              "#E00078"))


## Plotting information disclosure over the 6 interviews for each condition

plot2_df <- plot_df %>% filter(interview < 4)

inital_plot <- ggplot(plot2_df,
                      aes(
                        x = interview,
                        y = detail)
                      ) +
                      geom_smooth(
                        aes(
                          group = sos_training,
                          color = sos_training),
                          method=lm,
                          se = TRUE
                      ) +
                      labs(
                        y = "Disclosed details",
                        x = "Interview",
                        color = "Training"
                      ) +
                      scale_x_continuous(
                        labels = c("1", "2", "3","4"),
                        breaks = 0:3
                      ) +
                      ylim(0, 5
                      ) +
                      scale_color_manual(values = c(
                        "#607466",
                        "#E00078")) +
                      facet_wrap(
                        ~ critical
                      )

delay_plot <- ggplot(plot_df,
                      aes(
                        x = interview,
                        y = detail)
) +
  geom_smooth(
    aes(
      group = condition,
      color = condition),
    method=lm,
    se = TRUE
  ) +
  labs(
    y = "Disclosed details",
    x = "Interview",
    color = "Condition"
  ) +
  scale_x_continuous(
    labels = c("1", "2", "3","4","5","6"),
    breaks = 0:5
  ) +
  ylim(0, 5
  ) +
  facet_wrap(
    ~ critical)


# Hypothesis testing -----------------------------------------------------------


## Model created to assess variance attributed to random effects

M0 <- lmer(detail 
          ~ 1
          + (1|id)                 #interviewer
          + (1|mc_sequence:interviewee) #interviewee nested in MC
          + (1|mc_sequence),
          data=my_df,
          REML=TRUE)

summary(M0)


## Assessing variance associated with random effects, effects with ICC below 0.05 will be excluded from models below

performance::icc(M0, by_group = TRUE)


## Main effects

simple_model <- lmer(detail
                    ~ sos_training 
                    + critical 
                    + interview
                    + (1|id)                  #interviewer
                    + (1|mc_sequence:interviewee) #interviewee nested in MC
                    + (1|mc_sequence), #removed to simplify model if applicable
                    data=my_df,
                    REML=FALSE)

summary(simple_model)


# Interaction effects

interaction_model <- lmer(detail
                     ~ sos_training 
                     + critical 
                     + interview
                     + sos_training*critical
                     + sos_training*interview
                     + (1|id)                  #interviewer
                     + (1|mc_sequence:interviewee) #interviewee nested in MC
                     + (1|mc_sequence), #removed to simplify model if applicable
                     data=my_df,
                     REML=FALSE)

summary(interaction_model)

emmeans_int <- emmeans::emmeans(interaction_model, specs = ~ sos_training + critical)

pairs(emmeans_int)

emmeans::eff_size(emmeans_int, sigma = sigma(interaction_model), edf = 627)


## Compare model fit

model_comp <- anova(simple_model, interaction_model, refit=FALSE) 


# 3- way Interaction effects

three_way_interaction_model <- lmer(detail
                          ~ sos_training 
                          + critical 
                          + interview
                          + sos_training*critical*interview
                          + (1|id)                  #interviewer
                          + (1|mc_sequence:interviewee) #interviewee nested in MC
                          + (1|mc_sequence), #removed to simplify model if applicable
                          data=my_df,
                          REML=FALSE)

summary(three_way_interaction_model)

anova(interaction_model,
      three_way_interaction_model,
      refit=FALSE) 

