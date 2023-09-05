################################################################################

# Main analysis

################################################################################
# Basic setup ------------------------------------------------------------------

packages <- c("gtools", "readr", "tibble", "dplyr", "data.table", "tidyr",
              "readxl", "ggplot2", "lme4", "lmerTest")

lapply(packages, library, character.only = TRUE)

my_df <- read_csv("./sim_training.csv") # Replace with real data

# Plots ------------------------------------------------------------------------

## Plot preparation

plot_df <- my_df


## Factor training & details (critical, noncritical)

plot_df$sos_training <- factor(plot_df$sos_training,
                                          levels = c(0, 1),
                                          labels = c("Basic","SoS"))

plot_df$critical <- factor(plot_df$critical,
                                      levels = c(0, 1),
                                      labels = c("Non-critical", "Critical"))


## Descriptive statistics - information disclosure

desc <- plot_df %>% 
  group_by(sos_training, critical) %>% 
  summarise(
    Mean = mean(trans_det, na.rm = TRUE),
    SD = sd(trans_det, na.rm = TRUE),
    Median = median(trans_det, na.rm = TRUE),
    SE = SD/sqrt(n()),
    Upper = Mean + (1.96*SE),
    Lower = Mean - (1.96*SE)
  )


## Descriptive statistics - Also grouping by interview

desc_by_interview <- plot_df %>% 
  group_by(sos_training, critical, interview) %>% 
  summarise(
    Mean = mean(trans_det, na.rm = TRUE),
    SD = sd(trans_det, na.rm = TRUE),
    Median = median(trans_det, na.rm = TRUE),
    SE = SD/sqrt(n()),
    Upper = Mean + (1.96*SE),
    Lower = Mean - (1.96*SE)
  )


## Means plot - Information disclosure

mean_plot <- ggplot(desc, aes(x=critical,
                              y=Mean,
                              colour=sos_training)
                              ) + 
                          geom_errorbar(aes(
                              ymin=Mean-SE,
                              ymax=Mean+SE),
                              width=.1
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

inital_plot <- ggplot(plot_df,
                      aes(
                        x = interview,
                        y = trans_det)
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
                        labels = c("1", "2", "3","4","5","6"),
                        breaks = 0:5
                      ) +
                      ylim(0, 5
                      ) +
                      scale_color_manual(values = c(
                        "#607466",
                        "#E00078"))


# Hypothesis testing -----------------------------------------------------------

## Model created to assess variance attributed to random effects

M0 <- lmer(trans_det 
          ~ 1
          + (1|id)                 #interviewer
          + (1|mc_seq:interviewee) #interviewee nested in MC
          + (1|mc_seq),
          data=my_df,
          REML=TRUE)

summary(M0)

## Assessing variance associated with random effects, effects with ICC below 0.05 will be excluded from models below

performance::icc(M0, by_group = TRUE)


## Main effects

simple_model <- lmer(trans_det
                    ~ sos_training 
                    + critical 
                    + interview
                    + (1|id)                  #interviewer
                    + (1|mc_seq:interviewee), #interviewee nested in MC
                    #+ (1|mc_seq), #removed to simplify model if applicable
                    data=my_df,
                    REML=FALSE)

summary(simple_model)

# Interaction effects

interaction_model <- lmer(trans_det
                     ~ sos_training 
                     + critical 
                     + interview
                     + sos_training*critical
                     + sos_training*interview
                     + (1|id)                  #interviewer
                     + (1|mc_seq:interviewee), #interviewee nested in MC
                     #+ (1|mc_seq), #removed to simplify model if applicable
                     data=my_df,
                     REML=FALSE)

summary(interaction_model)

## Compare model fit

anova(simple_model, interaction_model, refit=FALSE) 
