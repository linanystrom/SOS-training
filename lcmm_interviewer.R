
# Latent class analysis - Interviewers

# Set up environment -----------------------------------------------------------

library(poLCA)

df <- read_csv("data/interviewer_measures_clean.csv")

# Data wrangling ---------------------------------------------------------------

df <- rename(df, Supportive_transistions = `Supportive transistions`)

x <- 1

df <- df %>% 
  mutate(
    Free_recall_rc = Free_recall + x,
    Guilt_presumption_rc = Guilt_presumption + x,
    Funnel_structure_rc = Funnel_structure + x,
    Challenge_inconsistencies_rc = Challenge_inconsistencies + x,
    Request_explanation_rc = Request_explanation + x,
    Reinforce_truth_rc = Reinforce_truth + x,
    Supportive_transistions_rc = Supportive_transistions + x,
    Leading_questions_rc = Leading_questions + x
  )

df <- df %>% 
  rename(
    INT = Introduction,
    FR = Free_recall_rc,
    GP = Guilt_presumption_rc,
    FS = Funnel_structure_rc,
    CI = Challenge_inconsistencies_rc,
    RE = Request_explanation_rc,
    RT = Reinforce_truth_rc,
    ST= Supportive_transistions_rc,
    LQ = Leading_questions_rc
  )

f <- cbind(INT,
           FR,
           GP,
           FS,
           CI,
           RE,
           RT,
           ST,
           LQ)~1

# Functions --------------------------------------------------------------------

calculate_entropy <- function(model) {
  posterior <- model$posterior
  nume.E <- -sum(posterior * log(posterior), na.rm=TRUE)
  n <- nrow(posterior)
  k <- ncol(posterior)
  deno.E <- n * log(k)
  ent <- 1 - (nume.E / deno.E)
  return(ent)
}

## plot model function
plot_model_comparison <- function(model_comparison, wave_title) {
  # Create a secondary axis scale for Entropy (typically 0-1)
  entropy_scale <- max(model_comparison$AIC, model_comparison$BIC) / 5
  
  ggplot(model_comparison, aes(x = Classes)) +
    geom_line(aes(y = AIC, color = "AIC"), size = 1) +
    geom_line(aes(y = BIC, color = "BIC"), size = 1) +
    geom_line(aes(y = Entropy * entropy_scale, color = "Entropy"), size = 1, linetype = "dashed") +
    geom_point(aes(y = AIC, color = "AIC"), size = 3) +
    geom_point(aes(y = BIC, color = "BIC"), size = 3) +
    geom_point(aes(y = Entropy * entropy_scale, color = "Entropy"), size = 3) +
    scale_y_continuous(
      name = "AIC / BIC",
      sec.axis = sec_axis(~./entropy_scale, name = "Entropy")
    ) +
    labs(title = paste("Model Fit Comparison -", wave_title), 
         x = "Number of Classes", 
         color = "Measure") +
    scale_color_manual(values = c("AIC" = "blue", "BIC" = "red", "Entropy" = "green")) +
    theme_minimal() +
    theme(
      legend.position = "bottom",
      axis.title.y.right = element_text(color = "green"),
      axis.text.y.right = element_text(color = "green")
    )
}

# Latent class analysis --------------------------------------------------------

set.seed(666)
M0 <- poLCA(f, df, nclass = 1, nrep = 200, maxiter = 1000, na.rm = FALSE) #1 class
M1 <- poLCA(f, df, nclass = 2, nrep = 200, maxiter = 1000, na.rm = FALSE) #2 class
M2 <- poLCA(f, df, nclass = 3, nrep = 200, maxiter = 1000, na.rm = FALSE) #3 class
M3 <- poLCA(f, df, nclass = 4, nrep = 200, maxiter = 1000, na.rm = FALSE) #4 class
M4 <- poLCA(f, df, nclass = 5, nrep = 200, maxiter = 1000, na.rm = FALSE) #5 class


entropy_M1 <- calculate_entropy(M1)
entropy_M2 <- calculate_entropy(M2)
entropy_M3 <- calculate_entropy(M3)
entropy_M4 <- calculate_entropy(M4)

model_comparison <- data.frame(
  Classes = c( 2, 3, 4, 5),
  AIC = c( M1$aic, M2$aic, M3$aic, M4$aic),
  BIC = c( M1$bic, M2$bic, M3$bic, M4$bic),
  LogLikelihood = c( M1$ll, M2$ll, M3$ll, M4$ll),
  Entropy = c( entropy_M1, entropy_M2, entropy_M3, entropy_M4)
)


df_2 <- cbind(df, "Predicted_class_M3" = M3$predclass)

write.csv(
  df_2,
  "data/lcmm_4class.csv",
  row.names = FALSE
)

M3_freq <- table(df_2$sos_training,df_2$Predicted_class_M3) #0 = Basic, 1 = SoS

interviewee_df <- read_csv("data/qualtrics_clean.csv")

interviewee_df <- interviewee_df %>% 
  mutate(
    interviewee = paste(as.character(id), as.character(interview), sep = "_"))

df_2 <- df_2 %>% 
  mutate(
    interviewee = paste(as.character(ID), as.character(Interview_nr), sep = "_"))

interviewee_df <- interviewee_df %>% dplyr::select(c("interviewee",
                                                     "change_strategy"))

interviewer_df <- df_2 %>% dplyr::select(c("interviewee",
                                           "Predicted_class_M3"))

class_change_df <- merge(interviewee_df,
                         interviewer_df,
                         by = c("interviewee"),
                         na.rm = FALSE)

class_change = data.frame(class_change_df$Predicted_class_M3,
                          class_change_df$change_strategy)

## Change strategy:  1 = "Yes", 2 = "No" 

change_data = table(class_change_df$Predicted_class_M3,
                    class_change_df$change_strategy)

change_data_prop <- class_change_df %>%
  drop_na (change_strategy) %>% 
  group_by(Predicted_class_M3, change_strategy) %>%
  summarise(
    n = n()) %>%
  mutate(rel_freq = paste0(round(100 * n/sum(n), 0), "%")
  )

chisq_object <- chisq.test(change_data)

chisq_object$stdres

chisq_prop <- prop.test(x = change_data,
                      n = rowSums(change_data),
                      correct = FALSE)

## HERE

## Load info disc sum + critical sum - match with ID and then table

info_df <- read_csv("data/excell_long.csv")

info_df$critical <- factor(info_df$critical,
                           levels = c(0, 1),
                           labels = c("Non-critical", "Critical"))

class_infodisc_df <- merge(info_df,
                         interviewer_df,
                         by = c("interviewee"),
                         na.rm = FALSE)



desc_class_info <- class_infodisc_df [complete.cases(class_infodisc_df ),] %>% 
  group_by(Predicted_class_M3, critical) %>% 
  summarise(
    Mean = mean(detail, na.rm = TRUE),
    SD = sd(detail, na.rm = TRUE),
    Median = median(detail, na.rm = TRUE),
    SE = SD/sqrt(n()),
    Upper = Mean + (1.96*SE),
    Lower = Mean - (1.96*SE)
  )
