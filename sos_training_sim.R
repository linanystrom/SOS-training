################################################################################

# LRT Power Simulation 

################################################################################

# Set up environment -----------------------------------------------------------

## Packages

packages <- c("gtools",
              "readr",
              "tibble",
              "dplyr",
              "data.table",
              "tidyr",
              "simr",
              "ggplot2")

lapply(packages, library, character.only = TRUE)

## Seed

set.seed(1337)

# Set up design-----------------------------------------------------------------

nr_mcs    <- 6                   #Number of mock crimes
nr_stages <- 6                   #Number of stages per mock crime
nr_cond   <- 3                   #Number of conditions
nr_int    <- 6                   #Number of interviews
poss_det  <- 5                   #Possible details disclosed
group_sz  <- 20                  #Group size
sample    <- group_sz*nr_cond
data_point<- nr_stages * nr_int  #Total data points per participant
tot_interview <- nr_int*sample
interviewee <- tot_interview

MC          <- c("MC1","MC2","MC3", "MC4", "MC5", "MC6")
cond        <- c("basic", "sos", "sos_delayed")

stage     <- 0:(nr_stages - 1)
interview <- 0:(nr_mcs  - 1)
detail    <- 0:(poss_det)
id_mc     <- 1:sample
time      <- 0:(data_point - 1)

# Set up basic data structure---------------------------------------------------


df <- expand.grid(stage = stage, interview = interview) %>% 
  cbind(data.frame(time))

df_full <- df[rep(1:nrow(df), group_sz * length(cond)), ]

id <- sort(rep(1:(group_sz * length(cond)), data_point))

mc <- rep((sample(MC, nr_mcs)), sample)

df_full$id <- id

df_full$condition <- sort(rep(cond, group_sz * data_point))

df_full <- df_full %>% 
  select(id, everything())

mc_vec <- rep(NA, sample)

for (i in 1:sample) {
  make_mc <- list(sample(MC))
  mc_vec[i] <- make_mc
}

mc_seq <- unlist(mc_vec)

mc_seq <- data.frame(mc_seq)

mc_seq$id <- sort(rep(1:(group_sz * length(cond)), nr_int))

mc_seq$interview <- rep(0:(nr_int-1), sample)

df_2 <- merge(df_full, mc_seq, by = c("id", "interview"))

df_2$condition <- sort(rep(cond, group_sz * data_point))

df_2$condition <- factor(df_2$condition,
                                levels = c("basic", "sos", "sos_delayed"))
new_id <- sample(sample)

df_2$interviewee <- rep(c(1:interviewee), each = nr_stages)

df_2$new_id <- rep(c(new_id), each = data_point)

complete_df <- df_2


# Create slopes ----------------------------------------------------------------

complete_df <- complete_df %>% 
  mutate(critical = case_when(
    stage == 0 ~ 0,
    stage == 1 ~ 0,
    stage == 2 ~ 0,
    stage == 3 ~ 0,
    stage == 4 ~ 1,
    stage == 5 ~ 1))


complete_df <- complete_df %>% 
  mutate(sos_training = if_else(condition == "sos_delayed", case_when(
        interview == 0 ~ 0,
        interview == 1 ~ 0,
        interview == 2 ~ 0,
        interview == 3 ~ 1,
        interview == 4 ~ 1,
        interview == 5 ~ 1
      ),
      ifelse(condition == "basic", case_when(
        interview == 0 ~ 0,
        interview == 1 ~ 0,
        interview == 2 ~ 0,
        interview == 3 ~ 0,
        interview == 4 ~ 0,
        interview == 5 ~ 0
    ),
    ifelse(condition == "sos", case_when(
      interview == 0 ~ 1,
      interview == 1 ~ 1,
      interview == 2 ~ 1,
      interview == 3 ~ 1,
      interview == 4 ~ 1,
      interview == 5 ~ 1), NA))))

# Set up coefficients ----------------------------------------------------------

coeff <- c( "(Intercept)"                  =     0,
            "sos_training"                 =  0.80, # critical effect
            "critical"                     = -0.50,
            "interview"                    =  0.05)

variances <- list(1.53131, 1.50000, 0.00000)

## Random effects, id, interviewee, MC

sim_detail_lmer <- makeLmer(
  formula = detail 
  ~ sos_training
  + critical
  + interview
  + (1|id)
  + (1|mc_seq:interviewee)
  + (1|mc_seq), 
  fixef = coeff,
  VarCorr = variances,
  sigma = 1,
  data = complete_df
)

power_sim_60 <- powerSim(sim_detail_lmer,
                         test = fixed("sos_training", method = "t"),
                         nsim = 1000)

coeff_2 <- c(
            "(Intercept)"                                 =     0,
            "sos_training"                                =  0.80,
            "critical"                                    = -0.50,
            "interview"                                   =  0.05,
            "sos_training:critical"                       =  0.20)

variances_2 <- list(1.53131, 1.50000, 0.00000)

sim_detail_int <- makeLmer(
  formula = detail 
  ~ sos_training
  + critical
  + interview
  + sos_training*critical
  + (1|id)
  + (1|mc_seq:interviewee)
  + (1|mc_seq), 
  fixef = coeff_2,
  VarCorr = variances_2,
  sigma = 1,
  data = complete_df
)

power_sim_int <- powerSim(sim_detail_int,
                         test = fixed("sos_training:critical", method = "t"),
                         nsim = 1000)

detail_data <- getData(sim_detail_int)

## Force data into "shape"

sort_detail_data <- detail_data %>% arrange(desc(detail))

assign_0 <- quantile(sort_detail_data$detail, 0.1667)
assign_1 <- quantile(sort_detail_data$detail, (0.1667*2))
assign_2 <- quantile(sort_detail_data$detail, (0.1667*3))
assign_3 <- quantile(sort_detail_data$detail, (0.1667*4))
assign_4 <- quantile(sort_detail_data$detail, (0.1667*5))

transform_detail <- sort_detail_data %>% mutate(
  trans_det = case_when(
    detail > assign_4 ~ 5,
    detail <= assign_4 & detail > assign_3 ~ 4,
    detail <= assign_3 & detail > assign_2 ~ 3,
    detail <= assign_2 & detail > assign_1 ~ 2,
    detail <= assign_1 & detail > assign_0 ~ 1,
    detail <= assign_0  ~ 0,
  )
)


# Save data --------------------------------------------------------------------

write.csv(
  transform_detail,
  "./sim_training.csv",
  row.names = FALSE
)
