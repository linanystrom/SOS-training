
# Latent class analysis - Interviewers

# Set up environment -----------------------------------------------------------

library(poLCA)

df <- read_csv("data/interviewer_measures_clean.csv")

# Data wrangling ---------------------------------------------------------------

## Create variable unique id variable?

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

f <- cbind(Introduction,
           Free_recall_rc,
           Guilt_presumption_rc,
           Funnel_structure_rc,
           Challenge_inconsistencies_rc,
           Request_explanation_rc,
           Reinforce_truth_rc,
           Supportive_transistions_rc,
           Leading_questions_rc)~1

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
M0 <- poLCA(f, df, nclass = 1, nrep = 200, maxiter = 1000, na.rm = FALSE)
M1 <- poLCA(f, df, nclass = 2, nrep = 200, maxiter = 1000, na.rm = FALSE)
M2 <- poLCA(f, df, nclass = 3, nrep = 200, maxiter = 1000, na.rm = FALSE)
M3 <- poLCA(f, df, nclass = 4, nrep = 200, maxiter = 1000, na.rm = FALSE)

entropy_M1 <- calculate_entropy(M1)
entropy_M2 <- calculate_entropy(M2)
entropy_M3 <- calculate_entropy(M3)

model_comparison <- data.frame(
  Classes = c(2, 3, 4),
  AIC = c(M1$aic, M2$aic, M3$aic),
  BIC = c(M1$bic, M2$bic, M3$bic),
  LogLikelihood = c(M1$ll, M2$ll, M3$ll),
  Entropy = c(entropy_M1, entropy_M2, entropy_M3)
)

plot_comparison <- plot_model_comparison(model_comparison, "Test")

df_2 <- cbind(df, "Predicted_class_M3" = M3$predclass)

df_2 <- cbind(df_2, "Predicted_class_M1" = M1$predclass)

write.csv(
  df_2,
  "data/lcmm_4class.csv",
  row.names = FALSE
)

saveRDS(M3, file = "M03.rds")
my_model <- readRDS("M03.rds")

M3_freq <- table(df_2$sos_training,df_2$Predicted_class_M3) #0 = Basic, 1 = SoS

M1_freq <- table(df_2$sos_training,df_2$Predicted_class_M1) #0 = Basic, 1 = SoS



#LCMM approach -----------------------------------------------------------------

## Deprecated

lcmm_01 <- multlcmm(
  fixed = Introduction
  + Free_recall 
  + Guilt_presumption 
  + Funnel_structure 
  + Challenge_inconsistencies 
  + Request_explanation 
  + Reinforce_truth
  + Supportive_transistions
  + Leading_questions
  ~ 1,
  random  = ~ 1 + ID,
  subject = "ID",
  ng      = 1,
  data    = df,
  verbose = TRUE,
  nproc = 6
)

# STOP

lcmm_02 <- multlcmm(
  fixed = Introduction
  + Free_recall 
  + Guilt_presumption 
  + Funnel_structure 
  + Challenge_inconsistencies 
  + Request_explanation 
  + Reinforce_truth
  + Supportive_transistions
  + Leading_questions
  ~ 1,
  mixture = ~ 1 + ID,
  random  = ~ 1 + ID,
  subject = "ID",
  ng      = 2,
  data    = df,
  B       = lcmm_01,
  verbose = TRUE
)

lcmm_03 <- multlcmm(
  fixed = Introduction
  + Free_recall 
  + Guilt_presumption 
  + Funnel_structure 
  + Challenge_inconsistencies 
  + Request_explanation 
  + Reinforce_truth
  + Supportive_transistions
  + Leading_questions
  ~ 1,
  mixture = ~ 1,
  random  = ~ 1 + ID,
  subject = "ID",
  ng      = 3,
  data    = df,
  B       = lcmm_01,
  verbose = TRUE
)
